Write-Output '=== ws01 CcmMessaging.log tail ==='
Get-Content 'C:\Windows\CCM\Logs\CcmMessaging.log' -Tail 15 -ErrorAction SilentlyContinue
Write-Output '=== ws01 LocationServices.log tail ==='
Get-Content 'C:\Windows\CCM\Logs\LocationServices.log' -Tail 10 -ErrorAction SilentlyContinue
Write-Output '=== ws01 CCM logs recent ==='
Get-ChildItem 'C:\Windows\CCM\Logs' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 10 Name, LastWriteTime
Write-Output 'WS01LOG_DONE'
