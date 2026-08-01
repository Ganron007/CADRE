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
Write-Output "=== HUNTER SID: $hunterSid ==="
Write-Output "=== ALL ACEs (first 40) ==="
$entry.ObjectSecurity.Access | Select-Object -First 40 | ForEach-Object {
  $id = $_.IdentityReference
  try { $sidVal = ([System.Security.Principal.NTAccount]$id).Translate([System.Security.Principal.SecurityIdentifier]).Value } catch { $sidVal = $id }
  Write-Output "ACE|Identity=$id|SID=$sidVal|Type=$($_.AccessControlType)|Rights=$($_.ActiveDirectoryRights)|ObjType=$($_.ObjectType)|Inherited=$($_.IsInherited)"
}
Write-Output "=== Count: $($entry.ObjectSecurity.Access.Count) ==="
