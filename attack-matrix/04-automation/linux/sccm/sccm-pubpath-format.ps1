# Inspect PublishingPath validation + SMS_ADForest class — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue

Write-Output '=== PublishingPath parameter validation ==='
$cmd = Get-Command Set-CMActiveDirectoryForest
$p = $cmd.Parameters['PublishingPath']
foreach ($a in $p.Attributes) {
  Write-Output ("  Attr: " + $a.GetType().Name)
  if ($a -is [System.Management.Automation.ValidatePatternAttribute]) { Write-Output ("    Pattern: " + $a.RegexPattern) }
  if ($a -is [System.Management.Automation.ValidateLengthAttribute]) { Write-Output ("    MinLength=" + $a.MinLength + " MaxLength=" + $a.MaxLength) }
}

Write-Output '=== SMS_ADForest class (PublishingPath doc/format) ==='
try {
  $cls = Get-WmiObject -Namespace root\SMS\site_CAD -Class SMS_ADForest -ErrorAction Stop
  Write-Output ("  class OK")
} catch { Write-Output ("  class ERROR: " + $_.Exception.Message) }

Write-Output '=== Try to understand expected format via existing object/help ==='
Get-Help Set-CMActiveDirectoryForest -Parameter PublishingPath -ErrorAction SilentlyContinue | Out-String -Width 250 | ForEach-Object { Write-Output $_ }

Write-Output '=== Try alternate formats (dry run) ==='
$candidates = @(
  'CN=System Management,CN=System,DC=range,DC=local',
  'LDAP://CN=System Management,CN=System,DC=range,DC=local',
  'System Management/System,DC=range,DC=local',
  'System Management/System',
  'CN=System Management,CN=System,DC=Range,DC=Local'
)
foreach ($c in $candidates) {
  try {
    Set-CMActiveDirectoryForest -ForestFqdn 'range.local' -PublishingPath $c -EnableDiscovery $true -WhatIf -ErrorAction Stop | Out-Null
    Write-Output ("  ACCEPTED(WhatIf): " + $c)
  } catch {
    Write-Output ("  rejected: " + $c + "  -> " + $_.Exception.Message.Split("`n")[0])
  }
}
Write-Output 'VALIDATION_DONE'
