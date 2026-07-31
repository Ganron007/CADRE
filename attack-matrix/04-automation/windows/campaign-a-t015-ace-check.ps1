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

$hunterSid = (New-Object System.Security.Principal.NTAccount("$DomainRoot\$AttackUser")).Translate([System.Security.Principal.SecurityIdentifier]).Value
Write-Output "=== HUNTER SID ==="
Write-Output $hunterSid

Write-Output "=== ACL ENTRIES MATCHING HUNTER ==="
$entry.ObjectSecurity.Access | Where-Object { $_.IdentityReference -match $hunterSid } | ForEach-Object {
  $id = $_.IdentityReference.Translate([System.Security.Principal.SecurityIdentifier])
  [PSCustomObject]@{
    Identity = $id.Value
    Type = $_.AccessControlType
    Rights = $_.ActiveDirectoryRights
    ObjectType = $_.ObjectType
    Inherited = $_.IsInherited
  }
} | Format-Table -AutoSize
