# Remove MP role to force clean re-provision — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue

Write-Output '=== Get-CMSiteRole syntax (confirm params) ==='
Get-Command Remove-CMSiteRole -Syntax -ErrorAction SilentlyContinue | Out-String -Width 250 | ForEach-Object { Write-Output $_ }

Write-Output '=== Remove MP role ==='
try {
  Remove-CMSiteRole -SiteSystemServerName 'mbr02.range.local' -SiteCode 'CAD' -RoleName 'SMS Management Point' -Force -ErrorAction Stop
  Write-Output '  Remove-CMSiteRole OK'
} catch { Write-Output ("  Remove-CMSiteRole ERROR: " + $_.Exception.Message) }

Write-Output '=== Verify role removed ==='
try {
  $r = Get-CMSiteRole -SiteCode CAD -ErrorAction SilentlyContinue | Where-Object { $_.RoleName -eq 'SMS Management Point' }
  if ($r) { Write-Output '  MP role STILL present' } else { Write-Output '  MP role removed (pending sitecomp processing)' }
} catch { Write-Output ("  check ERROR: " + $_.Exception.Message) }

Write-Output '=== Current MP files (before reinstall) ==='
foreach ($f in @('C:\Program Files\SMS_CCM\ccmisapi.dll','C:\Program Files\SMS_CCM\sms_mp.dll','C:\Program Files\SMS_CCM\mp_hinv.dll')) {
  Write-Output ("  " + $f + " = " + (Test-Path $f))
}
Write-Output 'MPREMOVE_DONE'
