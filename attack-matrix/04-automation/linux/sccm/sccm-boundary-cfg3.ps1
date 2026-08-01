# Boundary/group fix round 4 — CONFIG, vagrant on mbr02 (correct NAL path + no DefaultSiteCode)
$ErrorActionPreference = 'Continue'
$ns = 'root\SMS\site_CAD'
Write-Output '=== Create boundary (New-CimInstance, no DefaultSiteCode) ==='
$bid = $null
try {
  $existing = Get-WmiObject -Namespace $ns -Class SMS_Boundary -Filter "Value='192.168.77.0/24'" -ErrorAction SilentlyContinue
  if ($existing) { $bid = $existing.BoundaryID; Write-Output ('BOUNDARY_EXISTS id=' + $bid) }
  else {
    $b = New-CimInstance -ClassName SMS_Boundary -Namespace $ns -Property @{
      DisplayName = 'CADRE-Lab-Subnet'
      BoundaryType = 0
      Value = @('192.168.77.0/24')
    } -ErrorAction Stop
    $got = Get-WmiObject -Namespace $ns -Class SMS_Boundary -Filter "Value='192.168.77.0/24'" -ErrorAction SilentlyContinue
    if ($got) { $bid = $got.BoundaryID }
    Write-Output ('BOUNDARY_CREATED id=' + $bid)
  }
} catch { Write-Output ('BOUNDARY_ERR=' + $_.Exception.Message) }

Write-Output '=== Add boundary to group ==='
$gid = (Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "Name='CADRE-Lab-BG'" -ErrorAction SilentlyContinue).GroupID
if ($bid -and $gid) {
  try {
    $bgObj = Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "GroupID=$gid"
    $inP = $bgObj.GetMethodParameters('AddBoundary')
    $inP['BoundaryID'] = [uint32]$bid
    $bgObj.InvokeMethod('AddBoundary', $inP, $null) | Out-Null
    Write-Output 'BOUNDARY_ADDED'
  } catch { Write-Output ('ADD_ERR=' + $_.Exception.Message) }
}
Write-Output '=== Add site systems to group (NAL path) ==='
if ($gid) {
  $bgObj2 = Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "GroupID=$gid"
  $nal = '["Display=\\mbr02.range.local\"]MSWNET:["SMS_SITE=CAD"]\\mbr02.range.local\'
  try {
    $inP2 = $bgObj2.GetMethodParameters('AddSiteSystem')
    $inP2['ServerNALPath'] = $nal
    $bgObj2.InvokeMethod('AddSiteSystem', $inP2, $null) | Out-Null
    Write-Output 'SITESYSTEM_ADDED'
  } catch { Write-Output ('SS_ERR=' + $_.Exception.Message) }
}
Write-Output '=== Verify ==='
Get-WmiObject -Namespace $ns -Class SMS_Boundary -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('BOUNDARY: ' + $_.DisplayName + ' ' + ($_.Value -join ',')) }
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "Name='CADRE-Lab-BG'" -ErrorAction SilentlyContinue | ForEach-Object {
  Write-Output ('BG: ' + $_.Name + ' id=' + $_.GroupID)
}
Write-Output '=== Boundary group members ==='
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupMembers -Filter "BoundaryGroupID=$gid" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('MEMBER_BOUNDARY: ' + $_.BoundaryID) }
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupSiteSystems -Filter "BoundaryGroupID=$gid" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('MEMBER_SITESYSTEM: ' + $_.ServerName) }
Write-Output 'CFG_DONE'
