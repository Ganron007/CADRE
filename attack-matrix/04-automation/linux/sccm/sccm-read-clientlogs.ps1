# Read client logs at C:\Program Files\SMS_CCM\Logs — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$logdir = 'C:\Program Files\SMS_CCM\Logs'

Write-Output '=== All log files ==='
Get-ChildItem $logdir -Filter '*.log' | Sort-Object LastWriteTime -Descending | Select-Object -First 40 | ForEach-Object { Write-Output ("  " + $_.Name + " | " + $_.LastWriteTime) }

Write-Output '=== LocationServices.log (if exists) ==='
$ls = "$logdir\LocationServices.log"
if (Test-Path $ls) { Get-Content $ls -Tail 40 | ForEach-Object { Write-Output $_ } } else { Write-Output '  (no LocationServices.log)' }

Write-Output '=== PolicyAgent.log (if exists) ==='
$pa = "$logdir\PolicyAgent.log"
if (Test-Path $pa) { Get-Content $pa -Tail 40 | ForEach-Object { Write-Output $_ } } else { Write-Output '  (no PolicyAgent.log)' }

Write-Output '=== CcmExec.log tail 40 ==='
Get-Content "$logdir\CcmExec.log" -Tail 40 -ErrorAction SilentlyContinue | ForEach-Object { Write-Output $_ }

Write-Output '=== CcmMessaging.log tail 30 ==='
Get-Content "$logdir\CcmMessaging.log" -Tail 30 -ErrorAction SilentlyContinue | ForEach-Object { Write-Output $_ }
Write-Output 'CLIENTLOGS_DONE'
