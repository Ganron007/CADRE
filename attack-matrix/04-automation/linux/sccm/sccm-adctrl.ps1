# Read adctrl.log + ADService.log tails — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$siteLogs = 'C:\Program Files\Microsoft Configuration Manager\Logs'

Write-Output '=== adctrl.log tail 60 ==='
Get-Content "$siteLogs\adctrl.log" -Tail 60 -ErrorAction SilentlyContinue | ForEach-Object {
  if ($_ -match '^(.*?)\s+\$\$<([^>]+)>') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ }
}

Write-Output '=== ADService.log tail 40 ==='
Get-Content "$siteLogs\ADService.log" -Tail 40 -ErrorAction SilentlyContinue | ForEach-Object {
  if ($_ -match '^(.*?)\s+\$\$<([^>]+)>') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ }
}
Write-Output 'ADCTRL_DONE'
