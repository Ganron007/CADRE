param(
    [string]$TargetUser = 'chief_command',
    [string]$DomainRoot = 'cadre.local',
    [string]$AttackUser = 'hunter_dfir',
    [string]$AttackPassword = 'DF1R_Hunt3r!',
    [string]$Dc = 'dc01.cadre.local'
)

$ErrorActionPreference = 'Stop'

$cred = New-Object System.Management.Automation.PSCredential("$DomainRoot\$AttackUser", (ConvertTo-SecureString $AttackPassword -AsPlainText -Force))
$netCred = $cred.GetNetworkCredential()
$targetDn = "CN=$TargetUser,OU=Command,DC=cadre,DC=local"

$entry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Dc/$targetDn", $netCred.UserName, $netCred.Password)
$entry.RefreshCache()

Write-Output "=== CURRENT ACL ==="
$entry.ObjectSecurity.Access | ForEach-Object {
  $id = $_.IdentityReference.Translate([System.Security.Principal.SecurityIdentifier])
  [PSCustomObject]@{
    Identity = $id.Value
    Type = $_.AccessControlType
    Rights = $_.ActiveDirectoryRights
    ObjectType = $_.ObjectType
    Inherited = $_.IsInherited
  }
} | Format-Table -AutoSize

Write-Output "=== SID RESOLVE ==="
$identity = New-Object System.Security.Principal.NTAccount("$DomainRoot\$AttackUser")
$sid = $identity.Translate([System.Security.Principal.SecurityIdentifier])
$sidBinary = New-Object byte[] ($sid.BinaryLength)
$sid.GetBinaryForm($sidBinary, 0)
Write-Output "Account: $DomainRoot\$AttackUser"
Write-Output "SID: $($sid.Value)"
Write-Output "Binary: $([BitConverter]::ToString($sidBinary))"
