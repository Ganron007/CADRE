# Boundary/group fix round 3 — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
$ns = 'root\SMS\site_CAD'
$scope = New-Object System.Management.ManagementScope("\\localhost\$ns")
$scope.Connect()

Write-Output '=== AddSiteSystem method params ==='
try {
  $bgObj0 = Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "Name='CADRE-Lab-BG'" -ErrorAction SilentlyContinue
  $mp = $bgObj0.GetMethodParameters('AddSiteSystem')
  $mp.Properties | ForEach-Object { Write-Output ('PARAM: ' + $_.Name + ' type=' + $_.Type) }
  $mp2 = $bgObj0.GetMethodParameters('AddBoundary')
  $mp2.Properties | ForEach-Object { Write-Output ('BPARAM: ' + $_.Name + ' type=' + $_.Type) }
} catch { Write-Output ('PARAM_ERR=' + $_.Exception.Message) }

Write-Output '=== Site system resource list (MBR02) ==='
try {
  Get-WmiObject -Namespace $ns -Class SMS_SystemResourceList -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('SRL: ' + $_.RoleName + ' | ' + $_.ServerName + ' | ' + $_.NALPath) }
} catch { Write-Output ('SRL_ERR=' + $_.Exception.Message) }
Write-Output '=== SMS_SCI_SysResUse (site systems) ==='
try {
  Get-WmiObject -Namespace $ns -Class SMS_SCI_SysResUse -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('SYS: ' + $_.RoleName + ' | ' + $_.SiteSystem + ' | ' + $_.NALPath) }
} catch { Write-Output ('SYS_ERR=' + $_.Exception.Message) }

Write-Output '=== Create boundary via New-CimInstance ==='
$bid = $null
try {
  $b = New-CimInstance -ClassName SMS_Boundary -Namespace $ns -Property @{
    DisplayName = 'CADRE-Lab-Subnet'
    BoundaryType = 0
    Value = @('192.168.77.0/24')
    DefaultSiteCode = 'CAD'
  } -ErrorAction Stop
  $got = Get-WmiObject -Namespace $ns -Class SMS_Boundary -Filter "Value='192.168.77.0/24'" -ErrorAction SilentlyContinue
  if ($got) { $bid = $got.BoundaryID }
  Write-Output ('BOUNDARY_CREATED id=' + $bid)
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
Write-Output '=== Verify ==='
Get-WmiObject -Namespace $ns -Class SMS_Boundary -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('BOUNDARY: ' + $_.DisplayName + ' ' + $_.Value) }
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "Name='CADRE-Lab-BG'" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('BG: ' + $_.Name + ' id=' + $_.GroupID) }
Write-Output 'CFG_DONE'
