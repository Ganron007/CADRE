param(
    [string]$Principal = 'hunter_dfir',
    [string]$TargetUser = 'analyst_cloud',
    [string]$DomainRoot = 'cadre.local',
    [string]$RunAsUser = 'chief_command',
    [string]$RunAsPass = 'C0mm@nd_Ch1ef!',
    [string]$Dc = 'dc01.cadre.local'
)
$ErrorActionPreference = 'Stop'

function Resolve-Dn {
  param([string]$Sam, [string]$Server, [string]$User, [string]$Pass)
  $searcher = New-Object System.DirectoryServices.DirectorySearcher
  $searcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Server/DC=cadre,DC=local", $User, $Pass)
  $searcher.Filter = "(sAMAccountName=$Sam)"
  $searcher.PropertiesToLoad.AddRange(@('distinguishedName'))
  $result = $searcher.FindOne()
  if (-not $result) { throw "Object $Sam not found" }
  return $result.Properties['distinguishedname'][0]
}

Write-Output "=== T014 GenericWrite: $RunAsUser grants $Principal WriteProperty(all) on $TargetUser ==="
$cred = New-Object System.Management.Automation.PSCredential("$DomainRoot\$RunAsUser", (ConvertTo-SecureString $RunAsPass -AsPlainText -Force))
$net = $cred.GetNetworkCredential()

$targetDn = Resolve-Dn -Sam $TargetUser -Server $Dc -User $net.UserName -Pass $net.Password
$principalDn = Resolve-Dn -Sam $Principal -Server $Dc -User $net.UserName -Pass $net.Password
Write-Output "TARGET_DN $targetDn"
Write-Output "PRINCIPAL_DN $principalDn"

$entry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Dc/$targetDn", $net.UserName, $net.Password)
$entry.RefreshCache()

$identity = New-Object System.Security.Principal.NTAccount("$DomainRoot\$Principal")
$sid = $identity.Translate([System.Security.Principal.SecurityIdentifier]).Value

$rights = [System.DirectoryServices.ActiveDirectoryRights]'ReadProperty, WriteProperty, ExtendedRight'
$accessType = [System.Security.AccessControl.AccessControlType]'Allow'
$rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($identity, $rights, $accessType)

$acl = $entry.ObjectSecurity
$acl.AddAccessRule($rule)
$entry.ObjectSecurity = $acl
$entry.CommitChanges()
Write-Output "T014_APPLIED"

# Verify
$vEntry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Dc/$targetDn", $net.UserName, $net.Password)
$vEntry.RefreshCache()
$found = $false
$vEntry.ObjectSecurity.Access | Where-Object { $_.IdentityReference -like "*$Principal*" } | ForEach-Object {
  $found = $true
  Write-Output "ACE|$($_.IdentityReference)|$($_.ActiveDirectoryRights)|$($_.ObjectType)"
}
if (-not $found) { Write-Output "ACE_MISSING" }
