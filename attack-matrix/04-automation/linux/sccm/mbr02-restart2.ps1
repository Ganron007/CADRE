Restart-Service SMS_EXECUTIVE -Force -ErrorAction Stop
Write-Output 'SMS_EXECUTIVE restarted'
Start-Sleep -Seconds 45
Write-Output '--- notification server back? ---'
netstat -ano | findstr 10123
Write-Output 'RESTART2_DONE'
