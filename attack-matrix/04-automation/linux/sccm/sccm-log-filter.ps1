# Filter the 17:44 install run in ccmsetup.log — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$log = 'C:\Windows\ccmsetup\Logs\ccmsetup.log'
$patterns = 'command line|SMSSITECODE|SMSMP|SmsSetClientConfig|SmsSetClientConfigInit|Property|Assign|Existing client|new client|Upgrad|Location|Management Point|Policy|MP:'
Write-Output '=== FILTERED ccmsetup.log (17:44 run) ==='
Get-Content $log | Where-Object { $_ -match '17:4[4-9]|17:5[0-9]' -and $_ -match $patterns } | ForEach-Object {
  if ($_ -match '<LOG\[(.*?)\]LOG\]!><time="([^"]+)"') {
    Write-Output ("[" + $matches[2] + "] " + ($matches[1] -replace '\r',' '))
  } else { Write-Output $_ }
}
Write-Output '=== client.msi.log tail (MSI-level, shows properties received) ==='
$ml = 'C:\Windows\ccmsetup\Logs\client.msi.log'
if (Test-Path $ml) {
  Get-Content $ml -Tail 40 | Where-Object { $_ -match 'Property|SMSSITECODE|SMSMP|Assigned|CommandLine|Config' } | ForEach-Object { Write-Output $_ }
} else { Write-Output '  no client.msi.log' }
Write-Output 'FILTER_DONE'
