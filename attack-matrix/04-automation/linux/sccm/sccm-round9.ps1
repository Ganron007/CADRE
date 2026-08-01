# Round 9: ExecMethod_ + InParameters.SpawnInstance_ (canonical COM) — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
$ns = 'root\SMS\site_CAD'
$wmi = New-Object -ComObject WbemScripting.SWbemLocator
$svc = $wmi.ConnectServer('localhost', $ns)
$gid = (Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "Name='CADRE-Lab-BG'" -ErrorAction SilentlyContinue).GroupID
$bid = (Get-WmiObject -Namespace $ns -Class SMS_Boundary -Filter "Value='192.168.77.0/24'" -ErrorAction SilentlyContinue).BoundaryID
Write-Output ('GID=' + $gid + ' BID=' + $bid)
if ($gid -and $bid) {
  try {
    $bg = $svc.Get("SMS_BoundaryGroup.GroupID=$gid")
    $ip = $bg.Methods_('AddBoundary').InParameters.SpawnInstance_()
    $ip.BoundaryID = [uint32]$bid
    $bg.ExecMethod_('AddBoundary', $ip) | Out-Null
    Write-Output 'BOUNDARY_ADDED'
  } catch { Write-Output ('ADD_ERR=' + $_.Exception.Message) }
  try {
    $bg2 = $svc.Get("SMS_BoundaryGroup.GroupID=$gid")
    $nal = '["Display=\\mbr02.range.local\"]MSWNET:["SMS_SITE=CAD"]\\mbr02.range.local\'
    $ip2 = $bg2.Methods_('AddSiteSystem').InParameters.SpawnInstance_()
    $ip2.ServerNALPath = $nal
    $bg2.ExecMethod_('AddSiteSystem', $ip2) | Out-Null
    Write-Output 'SITESYSTEM_ADDED'
  } catch { Write-Output ('SS_ERR=' + $_.Exception.Message) }
}
Write-Output '=== Verify members ==='
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupMembers -Filter "GroupID=$gid" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('MEMB_B: ' + $_.BoundaryID) }
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupSiteSystems -Filter "GroupID=$gid" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('MEMB_SS: ' + $_.ServerNALPath) }
Write-Output 'CFG_DONE'
