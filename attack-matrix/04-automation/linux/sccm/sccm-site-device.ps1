# Site-side: check WS01 device record + client status — CONFIG, vagrant (mbr02 console)
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue
Write-Output '=== Get-CMDevice -Name WS01 ==='
try {
  Get-CMDevice -Name 'WS01' -ErrorAction SilentlyContinue | Format-List Name, ResourceID, ClientVersion, Active, AssignedSiteCode, ClientType, DiscoverySource, LastPolicyRequestTime, LastMPServerName, SMSID | Out-String -Width 200 | ForEach-Object { Write-Output $_ }
} catch { Write-Output ("  ERROR: " + $_.Exception.Message) }
Write-Output '=== Also check all devices (recent) ==='
try {
  Get-CMDevice -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'WS01|MBR02' } | ForEach-Object { Write-Output ("  " + $_.Name + " | ResourceID=" + $_.ResourceID + " | ClientVer=" + $_.ClientVersion + " | Active=" + $_.Active + " | AssignedSite=" + $_.AssignedSiteCode) }
} catch { Write-Output ("  list ERROR: " + $_.Exception.Message) }
Write-Output 'SITEDEVICE_DONE'
