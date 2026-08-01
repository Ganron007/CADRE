# Re-add MP role after removal — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue

Write-Output '=== Waiting 120s for uninstall to process ==='
Start-Sleep -Seconds 120

Write-Output '=== Add MP role (HTTP) ==='
try {
  Add-CMManagementPoint -SiteSystemServerName 'mbr02.range.local' -SiteCode 'CAD' -CommunicationType Http -ClientConnectionType Intranet -AllowDevice -ErrorAction Stop
  Write-Output '  Add-CMManagementPoint OK'
} catch { Write-Output ("  Add-CMManagementPoint ERROR: " + $_.Exception.Message) }

Write-Output '=== Verify role re-added ==='
try {
  $r = Get-CMSiteRole -SiteCode CAD -ErrorAction SilentlyContinue | Where-Object { $_.RoleName -eq 'SMS Management Point' }
  if ($r) { Write-Output '  MP role present in DB' } else { Write-Output '  MP role not in DB yet (sitecomp processing)' }
} catch { Write-Output ("  check ERROR: " + $_.Exception.Message) }

Write-Output '=== Waiting 240s for sitecomp to install MP (mp.msi) ==='
Start-Sleep -Seconds 240

Write-Output '=== Verify MP files restored ==='
foreach ($f in @('C:\Program Files\SMS_CCM\ccmisapi.dll','C:\Program Files\SMS_CCM\sms_mp.dll','C:\Program Files\SMS_CCM\mp_hinv.dll','C:\Program Files\SMS_CCM\SMS_MP','C:\Program Files\SMS_CCM\ServiceData\System','C:\Program Files\SMS_CCM\CCM_STS')) {
  Write-Output ("  " + $f + " = " + (Test-Path $f))
}

Write-Output '=== MP control manager status (mpcontrol.log tail) ==='
Get-Content 'C:\Program Files\Microsoft Configuration Manager\Logs\mpcontrol.log' -Tail 8 -ErrorAction SilentlyContinue | ForEach-Object { if ($_ -match '^(.*?)\s+\$\$<([^>]+)>') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ } }
Write-Output 'MPADD_DONE'
