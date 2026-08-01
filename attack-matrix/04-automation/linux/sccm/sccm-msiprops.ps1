# Full ccmsetup MSI props + client startup logs — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$cl = 'C:\Program Files\SMS_CCM\Logs'

Write-Output '=== ccmsetup.log: MSI PROPERTIES + SmsSetClientConfig (18:24-18:25) ==='
Get-Content 'C:\Windows\ccmsetup\Logs\ccmsetup.log' | Where-Object { $_ -match 'MSI PROPERTIES|Expanded MSI|SmsSetClientConfig|SMSSITECODE|SMSMP=|Invalid argument|New client|new client|Installation succeeded|installation succeeded' } | Select-Object -Last 20 | ForEach-Object {
  if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) }
}

Write-Output '=== ClientIDManagerStartup.log tail 20 ==='
$f = "$cl\ClientIDManagerStartup.log"
if (Test-Path $f) { Get-Content $f -Tail 20 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) } } }

Write-Output '=== ClientLocation.log tail 20 ==='
$f = "$cl\ClientLocation.log"
if (Test-Path $f) { Get-Content $f -Tail 20 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) } } }

Write-Output '=== setuppolicyevaluator.log tail 25 ==='
$f = "$cl\setuppolicyevaluator.log"
if (Test-Path $f) { Get-Content $f -Tail 25 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) } } }

Write-Output '=== CcmExec.log tail 15 ==='
$f = "$cl\CcmExec.log"
if (Test-Path $f) { Get-Content $f -Tail 15 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) } } }
Write-Output 'MSIPROPS_DONE'
