# MP health logs — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$siteLogs = 'C:\Program Files\Microsoft Configuration Manager\Logs'

Write-Output '=== mpcontrol.log tail 40 ==='
Get-Content "$siteLogs\mpcontrol.log" -Tail 40 -ErrorAction SilentlyContinue | ForEach-Object { if ($_ -match '^(.*?)\s+\$\$<([^>]+)>') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ } }

Write-Output '=== MPSetup.log tail 40 ==='
Get-Content "$siteLogs\MPSetup.log" -Tail 40 -ErrorAction SilentlyContinue | ForEach-Object { if ($_ -match '^(.*?)\s+\$\$<([^>]+)>') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ } }

Write-Output '=== compmon.log tail 30 (component status) ==='
Get-Content "$siteLogs\compmon.log" -Tail 30 -ErrorAction SilentlyContinue | ForEach-Object { if ($_ -match '^(.*?)\s+\$\$<([^>]+)>') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ } }

Write-Output '=== sitecomp.log tail 25 ==='
Get-Content "$siteLogs\sitecomp.log" -Tail 25 -ErrorAction SilentlyContinue | ForEach-Object { if ($_ -match '^(.*?)\s+\$\$<([^>]+)>') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ } }
Write-Output 'MPHEALTH_DONE'
