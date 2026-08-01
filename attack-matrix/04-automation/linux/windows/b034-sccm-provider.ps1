# SCCM provider reach from ws01: remote WMI to mbr02 root\SMS\site_CAD
$ErrorActionPreference = "Continue"
$user = "range.local\svc_sccm"
$pass = "s3rv1c3_SCCM!"
$cred = New-Object System.Management.Automation.PSCredential($user, (ConvertTo-SecureString $pass -AsPlainText -Force))

Write-Output "=== WMI namespace discovery on mbr02 ==="
try {
  $ns = Get-WmiObject -ComputerName "mbr02.range.local" -Namespace "root\SMS" -Class "__NAMESPACE" -Credential $cred -ErrorAction Stop
  $ns | ForEach-Object { Write-Output "NS: $($_.Name)" }
} catch { Write-Output "root\SMS enum err: $($_.Exception.Message)" }

Write-Output "=== site_CAD query ==="
try {
  $site = Get-WmiObject -ComputerName "mbr02.range.local" -Namespace "root\SMS\site_CAD" -Class "SMS_Site" -Credential $cred -ErrorAction Stop
  $site | ForEach-Object { Write-Output "SITE: $($_.SiteCode) $($_.ServerName) $($_.SiteName)" }
} catch { Write-Output "site_CAD query err: $($_.Exception.Message)" }

Write-Output "=== SMS_Admin query (SCCM admins) ==="
try {
  $admins = Get-WmiObject -ComputerName "mbr02.range.local" -Namespace "root\SMS\site_CAD" -Class "SMS_Admin" -Credential $cred -ErrorAction Stop
  $admins | ForEach-Object { Write-Output "ADMIN: $($_.LogonName) [$($_.RoleName -join ',')]" }
} catch { Write-Output "SMS_Admin query err: $($_.Exception.Message)" }

Write-Output "=== SCCM_DIAG_DONE ==="
