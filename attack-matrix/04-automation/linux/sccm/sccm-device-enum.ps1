# Device records + client state in SMS Provider (run on ws01 as svc_sccm via explicit creds)
$ErrorActionPreference = 'Continue'
$u = 'range\svc_sccm'; $p = 's3rv1c3_SCCM!'
$sec = ConvertTo-SecureString $p -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($u, $sec)
$ns = 'root\SMS\site_CAD'
Write-Output '=== SMS_R_System (filter Name=MBR02) ==='
try {
  Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_R_System -Filter "Name='MBR02'" -ErrorAction Stop |
    Select-Object ResourceID, Name, Client, ClientVersion, DistinguishedName | Format-List | Out-String | Write-Output
} catch { Write-Output ("ERR: " + $_.Exception.Message) }
Write-Output '=== SMS_R_System count ==='
try { Write-Output ("COUNT=" + (Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_R_System -ErrorAction Stop).Count) } catch { Write-Output ("ERR: " + $_.Exception.Message) }
Write-Output '=== SMS_System count + names ==='
try {
  Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_System -ErrorAction Stop |
    Select-Object ResourceID, Name | Format-Table -AutoSize | Out-String -Width 200 | Write-Output
} catch { Write-Output ("ERR: " + $_.Exception.Message) }
Write-Output '=== SMS_ResolvedSite ==='
try {
  Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_ResolvedSite -ErrorAction Stop |
    Select-Object SiteCode, SiteName, Version | Format-Table -AutoSize | Out-String -Width 200 | Write-Output
} catch { Write-Output ("ERR: " + $_.Exception.Message) }
Write-Output '=== SMS_DiscoveryDataManager/Client component state ==='
try {
  $cc = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace $ns -Class SMS_SCI_Component -Filter "ComponentName='SMS_CLIENT_CONFIG_MANAGER'" -ErrorAction Stop
  Write-Output ("CLIENT_CONFIG=" + ($cc | Out-String))
} catch { Write-Output ("ERR: " + $_.Exception.Message) }
Write-Output 'DEVICE_ENUM_DONE'
