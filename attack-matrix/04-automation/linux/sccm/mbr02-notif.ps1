Write-Output '=== find notification logs on mbr02 ==='
Get-ChildItem 'C:\Program Files\SMS_CCM\Logs','C:\Program Files\Microsoft Configuration Manager\Logs' -Filter '*otification*' -ErrorAction SilentlyContinue | Select-Object FullName, LastWriteTime
Get-ChildItem 'C:\Program Files\SMS_CCM\Logs','C:\Program Files\Microsoft Configuration Manager\Logs' -Filter '*ClientMessaging*' -ErrorAction SilentlyContinue | Select-Object FullName, LastWriteTime
Get-ChildItem 'C:\Program Files\SMS_CCM\Logs','C:\Program Files\Microsoft Configuration Manager\Logs' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'SMS_Notification|NotificationServer|MP_ClientMessaging|ClientMessaging' } | Select-Object FullName, LastWriteTime
Write-Output '=== SMS_NotificationManager / Server log tail ==='
$nf = Get-ChildItem 'C:\Program Files\SMS_CCM\Logs','C:\Program Files\Microsoft Configuration Manager\Logs' -Filter '*Notification*.log' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 3
foreach ($f in $nf) { Write-Output ("--- " + $f.FullName + " ---"); Get-Content $f.FullName -Tail 15 -ErrorAction SilentlyContinue }
Write-Output 'NOTIF_DONE'
