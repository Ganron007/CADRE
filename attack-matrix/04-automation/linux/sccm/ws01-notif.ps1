Write-Output '=== ws01 CcmNotificationAgent.log tail ==='
Get-Content 'C:\Windows\CCM\Logs\CcmNotificationAgent.log' -Tail 30 -ErrorAction SilentlyContinue
Write-Output 'WS01_NOTIF_DONE'
