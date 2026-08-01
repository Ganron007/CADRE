# Get Remove-CMSiteRole / Add-CMManagementPoint syntax — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue

Write-Output '=== Remove-CMSiteRole syntax ==='
Get-Command Remove-CMSiteRole -Syntax -ErrorAction SilentlyContinue | Out-String -Width 250 | ForEach-Object { Write-Output $_ }
Write-Output '=== Add-CMManagementPoint syntax ==='
Get-Command Add-CMManagementPoint -Syntax -ErrorAction SilentlyContinue | Out-String -Width 250 | ForEach-Object { Write-Output $_ }
Write-Output '=== Set-CMManagementPoint syntax ==='
Get-Command Set-CMManagementPoint -Syntax -ErrorAction SilentlyContinue | Out-String -Width 250 | ForEach-Object { Write-Output $_ }
Write-Output '=== Get-CMManagementPoint -SiteSystemServerName attempt ==='
try {
  Get-CMManagementPoint -SiteSystemServerName 'mbr02.range.local' -ErrorAction SilentlyContinue | Format-List | Out-String -Width 200 | ForEach-Object { Write-Output $_ }
} catch { Write-Output ("  ERROR: " + $_.Exception.Message) }
Write-Output 'SYNTAX2_DONE'
