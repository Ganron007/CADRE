# Enumerate AD/site publishing cmdlets + inspect site control — CONFIG, vagrant
$ErrorActionPreference = 'Continue'

Write-Output '=== ConfigurationManager cmdlets for Site/AD/Publish ==='
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Get-Command -Module ConfigurationManager -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'CMSite|AD|Publish|Forest|Discovery' } | ForEach-Object { Write-Output ("  " + $_.Name) }

Write-Output '=== Get-CMSite full object (AD fields) ==='
try {
  Set-Location 'CAD:' -ErrorAction SilentlyContinue
  $site = Get-CMSite -SiteCode CAD -ErrorAction Stop
  $site | Format-List | Out-String -Width 250 | ForEach-Object { $_.Split("`n") | Where-Object { $_ -match 'AD|Forest|Domain|Publish' } | ForEach-Object { Write-Output ("  " + $_.Trim()) } }
} catch { Write-Output ("  ERROR: " + $_.Exception.Message) }

Write-Output '=== Site control AD components (raw WMI via provider) ==='
try {
  Set-Location 'CAD:'
  Get-WmiObject -Namespace root\SMS\site_CAD -Query "SELECT * FROM SMS_SCI_Component" -ErrorAction SilentlyContinue | Where-Object { $_.ComponentName -match 'AD' } | ForEach-Object {
    Write-Output ("  Component: " + $_.ComponentName)
    $_.Props | Where-Object { $_.PropertyName -match 'AD|Forest|Domain|User|Interval|Schedule' } | ForEach-Object { Write-Output ("    " + $_.PropertyName + " = " + $_.Value1) }
  }
} catch { Write-Output ("  site control ERROR: " + $_.Exception.Message) }
Write-Output 'CMDLET_DONE'
