# Check svc_sccm SCCM roles + CMPivot permission (Get-WmiObject -Credential path) — analyst_t1 (ws01)
$ErrorActionPreference = 'Stop'
$svcUser = 'RANGE\svc_sccm'
$svcPass = 's3rv1c3_SCCM!'
$sec = ConvertTo-SecureString $svcPass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($svcUser, $sec)
$ns = 'root\SMS\site_CAD'
$mp = 'mbr02.range.local'

Write-Output ("[+] Connecting to " + $mp + " " + $ns + " as " + $svcUser)

Write-Output '=== SMS_Admin: svc_sccm ==='
$admins = Get-WmiObject -ComputerName $mp -Credential $cred -Namespace $ns -Class SMS_Admin -ErrorAction Stop | Where-Object { $_.LogonName -like '*svc_sccm*' }
foreach ($a in $admins) {
  Write-Output ("  LogonName=" + $a.LogonName + " | AdminID=" + $a.AdminID + " | DisplayName=" + $a.DisplayName)
  Write-Output ("  Roles=" + ($a.Roles -join ' , '))
}

Write-Output '=== All admin roles: which contain CMPivot / Run Script operations ==='
$roles = Get-WmiObject -ComputerName $mp -Credential $cred -Namespace $ns -Class SMS_AdminRole -ErrorAction SilentlyContinue
foreach ($role in $roles) {
  $ops = $role.Operations
  $hit = $ops | Where-Object { $_ -match 'CMPivot|Run Script|Create Script|Script' }
  if ($hit) { Write-Output ("  Role=" + $role.RoleName + " => " + ($hit -join ' | ')) }
}
Write-Output '--- All roles summary ---'
foreach ($role in $roles) { Write-Output ("  " + $role.RoleName + " | ops=" + @($role.Operations).Count) }
Write-Output 'ROLES2_DONE'
