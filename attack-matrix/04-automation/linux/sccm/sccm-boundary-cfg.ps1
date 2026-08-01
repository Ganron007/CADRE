# Create SCCM boundary + boundary group on site CAD (CONFIG, vagrant on mbr02)
$ErrorActionPreference = 'Continue'
$ns = 'root\SMS\site_CAD'
$scope = New-Object System.Management.ManagementScope("\\localhost\$ns")
$scope.Connect()

Write-Output '=== SMS_BoundaryGroup methods ==='
try {
  $bgcls = New-Object System.Management.ManagementClass($scope, (New-Object System.Management.ManagementPath('SMS_BoundaryGroup')), $null)
  $bgcls.Methods | ForEach-Object { Write-Output ('METHOD: ' + $_.Name) }
} catch { Write-Output ('META_ERR=' + $_.Exception.Message) }

Write-Output '=== Create boundary (idempotent) ==='
$bid = $null
try {
  $existing = Get-WmiObject -Namespace $ns -Class SMS_Boundary -Filter "Value='192.168.77.0/24'" -ErrorAction SilentlyContinue
  if ($existing) { $bid = $existing.BoundaryID; Write-Output ('BOUNDARY_EXISTS id=' + $bid) }
  else {
    $cls = New-Object System.Management.ManagementClass($scope, (New-Object System.Management.ManagementPath('SMS_Boundary')), $null)
    $mo = $cls.CreateInstance()
    $mo['DisplayName'] = 'CADRE-Lab-Subnet'
    $mo['BoundaryType'] = 0
    $mo['Value'] = [string[]]@('192.168.77.0/24')
    $mo['DefaultSiteCode'] = 'CAD'
    $mo.Put()
    $got = Get-WmiObject -Namespace $ns -Class SMS_Boundary -Filter "Value='192.168.77.0/24'" -ErrorAction SilentlyContinue
    if ($got) { $bid = $got.BoundaryID }
    Write-Output ('BOUNDARY_CREATED id=' + $bid)
  }
} catch { Write-Output ('BOUNDARY_ERR=' + $_.Exception.Message) }

Write-Output '=== Create boundary group (idempotent) ==='
$gid = $null
try {
  $existingBG = Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "Name='CADRE-Lab-BG'" -ErrorAction SilentlyContinue
  if ($existingBG) { $gid = $existingBG.GroupID; Write-Output ('BG_EXISTS id=' + $gid) }
  else {
    $cls2 = New-Object System.Management.ManagementClass($scope, (New-Object System.Management.ManagementPath('SMS_BoundaryGroup')), $null)
    $g = $cls2.CreateInstance()
    $g['Name'] = 'CADRE-Lab-BG'
    $g.Put()
    $gotBG = Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "Name='CADRE-Lab-BG'" -ErrorAction SilentlyContinue
    if ($gotBG) { $gid = $gotBG.GroupID }
    Write-Output ('BG_CREATED id=' + $gid)
  }
} catch { Write-Output ('BG_ERR=' + $_.Exception.Message) }

Write-Output '=== Add boundary + site systems to group ==='
if ($gid) {
  $bgObj = Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "GroupID=$gid" -ErrorAction SilentlyContinue
  if ($bid) {
    try {
      $inP = $bgObj.GetMethodParameters('AddBoundary')
      $inP['BoundaryID'] = [uint32]$bid
      $bgObj.InvokeMethod('AddBoundary', $inP, $null) | Out-Null
      Write-Output 'BOUNDARY_ADDED'
    } catch { Write-Output ('ADD_ERR=' + $_.Exception.Message) }
  }
  foreach ($ss in @('MBR02.RANGE.LOCAL','MBR02')) {
    try {
      $inP2 = $bgObj.GetMethodParameters('AddSiteSystem')
      $inP2['ServerName'] = $ss
      $bgObj.InvokeMethod('AddSiteSystem', $inP2, $null) | Out-Null
      Write-Output ('SITESYSTEM_ADDED: ' + $ss)
    } catch { Write-Output ('SS_ERR(' + $ss + ')=' + $_.Exception.Message) }
  }
}
Write-Output '=== Verify ==='
try {
  Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "Name='CADRE-Lab-BG'" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('BG: ' + $_.Name + ' id=' + $_.GroupID) }
  Get-WmiObject -Namespace $ns -Class SMS_Boundary -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('BOUNDARY: ' + $_.DisplayName + ' ' + $_.Value) }
} catch { Write-Output ('VERIFY_ERR=' + $_.Exception.Message) }
Write-Output 'CFG_DONE'
