# Check svc_sccm SCCM roles + CMPivot permission — analyst_t1 (ATTACK, ws01)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$svcUser = 'RANGE\svc_sccm'
$svcPass = 's3rv1c3_SCCM!'
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD")
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = $svcUser
$opts.Password = $svcPass
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope.Options = $opts
$scope.Connect()
Write-Output ("[+] Connected to SMS provider as " + $svcUser)

Write-Output '=== SMS_Admin: svc_sccm ==='
Get-WmiObject -Class SMS_Admin -Namespace root\SMS\site_CAD -Scope $scope -ErrorAction Stop | Where-Object { $_.LogonName -like '*svc_sccm*' } | ForEach-Object {
  Write-Output ("  LogonName=" + $_.LogonName)
  Write-Output ("  AdminID=" + $_.AdminID)
  Write-Output ("  DisplayName=" + $_.DisplayName)
  Write-Output ("  Roles=" + ($_.Roles -join ','))
  Write-Output ("  Categories=" + ($_.Categories -join ','))
}

Write-Output '=== Full Administrator role operations (look for CMPivot) ==='
Get-WmiObject -Class SMS_AdminRole -Namespace root\SMS\site_CAD -Scope $scope -ErrorAction SilentlyContinue | ForEach-Object {
  $ops = $_.Operations
  $hasCmp = $false
  if ($ops -match 'Run CMPivot') { $hasCmp = $true }
  Write-Output ("  Role=" + $_.RoleName + " | has 'Run CMPivot' op=" + $hasCmp + " | opCount=" + @($ops).Count)
  if ($hasCmp) { Write-Output ("    matching ops: " + (($ops | Where-Object { $_ -match 'CMPivot|Run' }) -join ' | ')) }
}

Write-Output '=== Search all roles for CMPivot operations ==='
Get-WmiObject -Class SMS_AdminRole -Namespace root\SMS\site_CAD -Scope $scope -ErrorAction SilentlyContinue | ForEach-Object {
  $m = $_.Operations | Where-Object { $_ -match 'CMPivot|Run Script|Script' }
  if ($m) { Write-Output ("  " + $_.RoleName + ": " + ($m -join ' | ')) }
}
Write-Output 'ROLES_DONE'
