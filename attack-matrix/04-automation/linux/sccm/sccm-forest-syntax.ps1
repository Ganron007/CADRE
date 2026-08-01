# Get forest cmdlet syntax + site definition — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue

Write-Output '=== New-CMActiveDirectoryForest syntax ==='
Get-Command New-CMActiveDirectoryForest -Syntax -ErrorAction SilentlyContinue | Out-String -Width 250 | ForEach-Object { Write-Output $_ }

Write-Output '=== Get-CMSiteDefinition / site definition cmdlets ==='
Get-Command -Module ConfigurationManager -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'SiteDefinition' } | ForEach-Object { Write-Output ("  " + $_.Name) }

Write-Output '=== Current forest object publishing state ==='
try {
  $f = Get-CMActiveDirectoryForest -ForestFqdn 'range.local' -ErrorAction Stop
  Write-Output ("  ForestFqdn=" + $f.ForestFqdn)
  Write-Output ("  ADForestName=" + $f.ADForestName)
  Write-Output ("  PublishingPath=" + $f.PublishingPath)
  Write-Output ("  IsPublished=" + $f.IsPublished)
  Write-Output ("  EnableDiscovery=" + $f.EnableDiscovery)
  $f | Format-List * | Out-String -Width 250 | ForEach-Object { $_.Split("`n") | Where-Object { $_ -match 'Publish|AD|Forest|Path|Site' } | ForEach-Object { Write-Output ("    " + $_.Trim()) } }
} catch { Write-Output ("  Get forest ERROR: " + $_.Exception.Message) }

Write-Output '=== SMS_SCI_SiteDefinition instances ==='
try {
  Get-WmiObject -Namespace root\SMS\site_CAD -Class SMS_SCI_SiteDefinition -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Output ("  SiteCode=" + $_.SiteCode + " SiteName=" + $_.SiteName)
  }
} catch { Write-Output ("  SiteDefinition ERROR: " + $_.Exception.Message) }
Write-Output 'FORESTSYNTAX_DONE'
