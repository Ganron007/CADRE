# Site-side client status for MBR02 + WS01 — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue
Write-Output '=== Devices: MBR02 + WS01 (full status) ==='
foreach ($n in @('MBR02','WS01')) {
  $d = Get-CMDevice -Name $n -ErrorAction SilentlyContinue
  if ($d) {
    Write-Output ("  --- " + $n + " ---")
    Write-Output ("    ResourceID=" + $d.ResourceID)
    Write-Output ("    ClientVersion=" + $d.ClientVersion)
    Write-Output ("    SMSID=" + $d.SMSID)
    Write-Output ("    Active=" + $d.Active)
    Write-Output ("    ClientActiveStatus=" + $d.ClientActiveStatus)
    Write-Output ("    AssignedSiteCode=" + $d.AssignedSiteCode)
    Write-Output ("    LastMPServerName=" + $d.LastMPServerName)
    Write-Output ("    LastPolicyRequestTime=" + $d.LastPolicyRequestTime)
    Write-Output ("    LastHeartbeatTime=" + $d.LastHardwareScan)
  } else { Write-Output ("  " + $n + " NOT FOUND") }
}
Write-Output 'SITESTATUS_DONE'
