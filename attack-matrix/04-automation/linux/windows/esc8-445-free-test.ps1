# Standalone test: can we free port 445 on ws01?
$ErrorActionPreference = "Continue"
Write-Output "=== stopping LanmanServer ==="
Stop-Service LanmanServer -Force
Start-Sleep -Seconds 3
$ls = Get-Service LanmanServer -ErrorAction SilentlyContinue
Write-Output "lanman_state=$($ls.Status)"

Write-Output "=== stopping srv2 driver ==="
sc.exe stop srv2
Start-Sleep -Seconds 4
$c = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
Write-Output "445_listening=$([bool]$c)"

Write-Output "=== restarting srv2 + LanmanServer ==="
sc.exe start srv2
Start-Sleep -Seconds 3
Start-Service LanmanServer -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
$ls2 = Get-Service LanmanServer -ErrorAction SilentlyContinue
Write-Output "lanman_state_after=$($ls2.Status)"
