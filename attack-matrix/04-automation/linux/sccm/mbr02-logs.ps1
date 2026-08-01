Write-Output '=== CcmMessaging.log tail ==='
Get-Content 'C:\Windows\CCM\Logs\CcmMessaging.log' -Tail 20 -ErrorAction SilentlyContinue
Write-Output '=== ClientLocation.log tail ==='
Get-Content 'C:\Windows\CCM\Logs\ClientLocation.log' -Tail 10 -ErrorAction SilentlyContinue
Write-Output '=== PolicyAgent.log tail ==='
Get-Content 'C:\Windows\CCM\Logs\PolicyAgent.log' -Tail 10 -ErrorAction SilentlyContinue
Write-Output '=== CcmExec log dir listing ==='
Get-ChildItem 'C:\Windows\CCM\Logs' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 15 Name, LastWriteTime, Length
Write-Output 'LOG_DONE'
