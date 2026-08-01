# Check ws01 admin rights + LanmanServer state to plan port-445 freeing
$ErrorActionPreference = "Continue"

Write-Output "=== whoami ==="
whoami

Write-Output "=== admin group membership (S-1-5-32-544) ==="
whoami /groups | Select-String "S-1-5-32-544|Mandatory Label"

Write-Output "=== port 445 owner ==="
netstat -ano | Select-String ":445 " | Select-Object -First 5

Write-Output "=== LanmanServer service state ==="
sc.exe query LanmanServer

Write-Output "=== LanmanServer recovery config ==="
sc.exe qfailure LanmanServer

Write-Output "=== try stop LanmanServer (dry check) ==="
# We'll attempt stop + immediate recheck of 445 within the window
Stop-Service LanmanServer -Force -ErrorAction SilentlyContinue
$before = (Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Output "port445_listeners_after_stop=$before"
Start-Sleep -Seconds 6
$after = (Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Output "port445_listeners_6s=$after"
sc.exe query LanmanServer
Write-Output "=== CHECK_DONE ==="
