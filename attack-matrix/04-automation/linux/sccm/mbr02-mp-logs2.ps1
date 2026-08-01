Write-Output '=== C:\Program Files\SMS_CCM\Logs listing ==='
Get-ChildItem 'C:\Program Files\SMS_CCM\Logs' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 20 Name, LastWriteTime, Length
Write-Output '=== Smsmp.log tail ==='
Get-Content 'C:\Program Files\SMS_CCM\Logs\Smsmp.log' -Tail 25 -ErrorAction SilentlyContinue
Write-Output '=== MP_ClientMessaging / ClientOp logs ==='
Get-ChildItem 'C:\Program Files\SMS_CCM\Logs' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'ClientMessaging|ClientOperation|MP_|Notification|CCM_Messaging' } | ForEach-Object { Write-Output ("--- " + $_.Name + " ---"); Get-Content $_.FullName -Tail 12 -ErrorAction SilentlyContinue }
Write-Output 'MPLOG2_DONE'
