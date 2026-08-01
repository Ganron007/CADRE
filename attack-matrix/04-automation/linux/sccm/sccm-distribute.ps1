# Distribute client package CAD00003 to DP (correct cmdlet usage) — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue

Write-Output '=== 1. All distribution points (raw names) ==='
Get-CMDistributionPoint -ErrorAction SilentlyContinue | ForEach-Object {
  Write-Output ('  DP_RAW: ' + ($_ | ConvertTo-Json -Compress -Depth 2))
}
Write-Output '=== 2. Start-CMContentDistribution params ==='
try {
  (Get-Command Start-CMContentDistribution -ErrorAction Stop).Parameters.Keys | ForEach-Object { Write-Output ('  PARAM: ' + $_) }
} catch { Write-Output ('  CMD_ERR=' + $_.Exception.Message) }

Write-Output '=== 3. Distribute ==='
try {
  $dp = Get-CMDistributionPoint -ErrorAction Stop | Select-Object -First 1
  if ($dp) {
    Write-Output ('  DP_NETPATH=' + $dp.NetworkOSPath)
    Start-CMContentDistribution -PackageId 'CAD00003' -DistributionPointName $dp.NetworkOSPath -ErrorAction Stop
    Write-Output '  DIST_STARTED'
  } else { Write-Output '  NO_DP_FOUND' }
} catch { Write-Output ('  DIST_ERR=' + $_.Exception.Message) }
Write-Output 'DIST_DONE'
