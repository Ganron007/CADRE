# CcmMessaging transport detail — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$clientLogs = 'C:\Program Files\SMS_CCM\Logs'

Write-Output '=== All CcmMessaging*.log files ==='
Get-ChildItem $clientLogs -Filter 'CcmMessaging*.log' | ForEach-Object { Write-Output ("  " + $_.Name + " | " + $_.LastWriteTime) }

$files = Get-ChildItem $clientLogs -Filter 'CcmMessaging*.log' | Sort-Object LastWriteTime -Descending | Select-Object -First 3
foreach ($f in $files) {
  Write-Output ("=== " + $f.Name + " : transport/MP lines ===")
  Get-Content $f.FullName | Where-Object { $_ -match 'http|https|Failed|failed|error|Error|503|500|403|401|MP_LocationManager|send|Send|sync|TLS|connection|Connection|WinHttp|WinHTTP' } | Select-Object -Last 25 | ForEach-Object {
    if ($_ -match '<LOG\[(.*?)\]LOG\]!><time="([^"]+)"') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ }
  }
}
Write-Output 'MESSAGING_DONE'
