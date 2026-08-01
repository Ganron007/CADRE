# Get Set-CMSite + AD forest cmdlet syntax — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue

Write-Output '=== Set-CMSite syntax ==='
Get-Command Set-CMSite -Syntax | Out-String -Width 250 | ForEach-Object { Write-Output $_ }

Write-Output '=== Set-CMSite parameters (AD-related) ==='
(Get-Command Set-CMSite).Parameters.Keys | Where-Object { $_ -match 'AD|Publish|Forest|Domain|Site' } | ForEach-Object { Write-Output ("  " + $_ + " [" + (Get-Command Set-CMSite).Parameters[$_].ParameterType.Name + "]") }

Write-Output '=== New/Set/Get-CMActiveDirectoryForest ==='
Get-Command New-CMActiveDirectoryForest -ErrorAction SilentlyContinue | Out-String -Width 250 | ForEach-Object { Write-Output $_ }
Get-Command Set-CMActiveDirectoryForest -Syntax -ErrorAction SilentlyContinue | Out-String -Width 250 | ForEach-Object { Write-Output $_ }

Write-Output '=== Existing AD forests ==='
try {
  Get-CMActiveDirectoryForest -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  Forest: " + $_.ForestFQDN + " | " + $_.ADForestName) }
} catch { Write-Output ("  Get-CMActiveDirectoryForest ERROR: " + $_.Exception.Message) }
Write-Output 'SYNTAX_DONE'
