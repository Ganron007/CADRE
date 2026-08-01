# Deeper MP/client transport diagnostics on mbr02 — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$siteLogs = 'C:\Program Files\Microsoft Configuration Manager\Logs'
$clientLogs = 'C:\Program Files\SMS_CCM\Logs'

Write-Output '=== Site logs: MP* files ==='
Get-ChildItem $siteLogs -Filter 'MP*.log' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  " + $_.Name + " | " + $_.LastWriteTime + " | " + $_.Length) }
if (-not (Get-ChildItem $siteLogs -Filter 'MP*.log' -ErrorAction SilentlyContinue)) { Write-Output '  (no MP*.log in site logs)' }

Write-Output '=== LocationServices.log full context around failures ==='
if (Test-Path "$clientLogs\LocationServices.log") {
  $lines = Get-Content "$clientLogs\LocationServices.log"
  $start = [Math]::Max(0, $lines.Count - 120)
  for ($i = $start; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '<LOG\[(.*?)\]LOG\]!><time="([^"]+)"') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $lines[$i] }
  }
} else { Write-Output '  (no LocationServices.log)' }

Write-Output '=== DNS resolution of mbr02.range.local (from mbr02) ==='
try { Resolve-DnsName mbr02.range.local -Type A -ErrorAction Stop | ForEach-Object { Write-Output ("  " + $_.Name + " -> " + $_.IPAddress) } } catch { Write-Output ("  ERROR: " + $_.Exception.Message) }

Write-Output '=== IIS sites + bindings ==='
Import-Module WebAdministration -ErrorAction SilentlyContinue
if (Get-Command Get-Website -ErrorAction SilentlyContinue) {
  Get-Website | ForEach-Object { Write-Output ("  SITE: " + $_.Name + " | State=" + $_.State) }
  Get-WebBinding | ForEach-Object { Write-Output ("  BINDING: " + $_.protocol + "://" + $_.bindingInformation) }
} else { Write-Output '  WebAdministration module not available' }

Write-Output '=== Listening ports 80/443/4430 ==='
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -in @(80,443,4430,445) } | ForEach-Object { Write-Output ("  LISTEN " + $_.LocalAddress + ":" + $_.LocalPort + " pid=" + $_.OwningProcess) }

Write-Output '=== IIS app pools (SMS*) ==='
if (Get-Command Get-ChildItem -ErrorAction SilentlyContinue) {
  Get-ChildItem 'IIS:\AppPools' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'SMS|CCM' } | ForEach-Object { Write-Output ("  POOL: " + $_.Name + " | " + $_.State) }
}
Write-Output 'DEEPDIAG_DONE'
