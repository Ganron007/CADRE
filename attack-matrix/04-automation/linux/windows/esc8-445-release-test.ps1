# Test: does port 445 EVER free after clean LanmanServer stop (recovery cleared)?
$ErrorActionPreference = "Continue"

Write-Output "=== clear recovery via cmd /c (proper quoting) ==="
cmd /c 'sc failure LanmanServer reset= 86400 actions= ""'
Write-Output "cmd_rc=$LASTEXITCODE"

Write-Output "=== qfailure after clear ==="
sc.exe qfailure LanmanServer

Write-Output "=== stop + poll 445 for 60s ==="
Stop-Service LanmanServer -Force
for ($i = 0; $i -lt 60; $i++) {
  Start-Sleep -Seconds 1
  $state = (sc.exe query LanmanServer | Select-String "STATE").ToString().Trim()
  $listener = [bool](Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue)
  if ($i % 5 -eq 0 -or -not $listener -or $state -match "RUNNING") {
    Write-Output "t=$i state='$state' listener=$listener"
  }
  if (-not $listener) { Write-Output "PORT_445_FREED_AT_T=$i"; break }
  if ($state -match "RUNNING") { Write-Output "SERVICE_CAME_BACK_AT_T=$i"; break }
}

Write-Output "=== restore ==="
cmd /c 'sc failure LanmanServer reset= 86400 actions= restart/60000/restart/120000' | Out-Null
Start-Service LanmanServer -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
(sc.exe query LanmanServer | Select-String "STATE").ToString()
Write-Output "=== POLL_DONE ==="
