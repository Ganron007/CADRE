Write-Output '=== SMS_MP logs dir ==='
Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\Logs' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'Smsmp|MP_|Notification|SMS_NOTIFICATION|ClientMessaging|MPClient' } | Sort-Object LastWriteTime -Descending | Select-Object Name, LastWriteTime, Length | Select-Object -First 12
Write-Output '=== Smsmp.log tail ==='
Get-Content 'C:\Program Files\Microsoft Configuration Manager\Logs\Smsmp.log' -Tail 20 -ErrorAction SilentlyContinue
Write-Output '=== Notification/ClientMessaging log tail ==='
$nf = Get-ChildItem 'C:\Program Files\Microsoft Configuration Manager\Logs' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'Notification' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($nf) { Write-Output ("FILE: " + $nf.Name); Get-Content $nf.FullName -Tail 20 -ErrorAction SilentlyContinue }
Write-Output 'MPLOG_DONE'
