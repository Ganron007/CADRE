Get-Content 'C:\Windows\CCM\Logs\Scripts.log' -Tail 30 -ErrorAction SilentlyContinue
Write-Output '=== CcmNotificationAgent tail ==='
Get-Content 'C:\Windows\CCM\Logs\CcmNotificationAgent.log' -Tail 10 -ErrorAction SilentlyContinue
Write-Output 'SCRIPTS_DONE'
