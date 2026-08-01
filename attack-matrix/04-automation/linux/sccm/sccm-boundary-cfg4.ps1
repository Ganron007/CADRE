# Boundary/group fix round 5 — CONFIG, vagrant on mbr02 (typed CIM + direct join classes)
$ErrorActionPreference = 'Continue'
$ns = 'root\SMS\site_CAD'

Write-Output '=== Create boundary ==='
$bid = $null
try {
  $existing = Get-WmiObject -Namespace $ns -Class SMS_Boundary -Filter "Value='192.168.77.0/24'" -ErrorAction SilentlyContinue
  if ($existing) { $bid = $existing.BoundaryID; Write-Output ('BOUNDARY_EXISTS id=' + $bid) }
  else {
    $b = New-CimInstance -ClassName SMS_Boundary -Namespace $ns -Property @{
      DisplayName = 'CADRE-Lab-Subnet'
      BoundaryType = [int16]0
      Value = [string[]]@('192.168.77.0/24')
    } -ErrorAction Stop
    $got = Get-WmiObject -Namespace $ns -Class SMS_Boundary -Filter "Value='192.168.77.0/24'" -ErrorAction SilentlyContinue
    if ($got) { $bid = $got.BoundaryID }
    Write-Output ('BOUNDARY_CREATED id=' + $bid)
  }
} catch { Write-Output ('BOUNDARY_ERR=' + $_.Exception.Message) }

Write-Output '=== Get/create boundary group id ==='
$gid = $null
try {
  $bg = Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "Name='CADRE-Lab-BG'" -ErrorAction SilentlyContinue
  if ($bg) { $gid = $bg.GroupID }
} catch { Write-Output ('BG_QUERY_ERR=' + $_.Exception.Message) }

if ($bid -and $gid) {
  Write-Output '=== Add boundary member (direct join) ==='
  try {
    $m = New-CimInstance -ClassName SMS_BoundaryGroupMembers -Namespace $ns -Property @{
      BoundaryGroupID = [int32]$gid
      BoundaryID = [int32]$bid
    } -ErrorAction Stop
    Write-Output 'MEMBER_BOUNDARY_ADDED'
  } catch { Write-Output ('MEMB_ERR=' + $_.Exception.Message) }
  Write-Output '=== Add site system member (direct join, NAL) ==='
  try {
    $nal = '["Display=\\mbr02.range.local\"]MSWNET:["SMS_SITE=CAD"]\\mbr02.range.local\'
    $m2 = New-CimInstance -ClassName SMS_BoundaryGroupSiteSystems -Namespace $ns -Property @{
      BoundaryGroupID = [int32]$gid
      ServerNALPath = $nal
    } -ErrorAction Stop
    Write-Output 'MEMBER_SITESYSTEM_ADDED'
  } catch { Write-Output ('SS_ERR=' + $_.Exception.Message) }
}
Write-Output '=== Verify ==='
Get-WmiObject -Namespace $ns -Class SMS_Boundary -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('BOUNDARY: ' + $_.DisplayName + ' ' + ($_.Value -join ',')) }
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "Name='CADRE-Lab-BG'" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('BG: ' + $_.Name + ' id=' + $_.GroupID) }
if ($gid) {
  Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupMembers -Filter "BoundaryGroupID=$gid" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('MEMB_BOUNDARY: ' + $_.BoundaryID) }
  Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupSiteSystems -Filter "BoundaryGroupID=$gid" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('MEMB_SITESYSTEM: ' + $_.ServerNALPath) }
}
Write-Output 'CFG_DONE'
