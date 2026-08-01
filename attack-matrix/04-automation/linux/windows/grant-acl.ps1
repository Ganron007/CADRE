param(
    [string]$Principal = 'hunter_dfir',
    [string]$TargetDn = 'CN=Command-Cadre,OU=Command,DC=cadre,DC=local',
    [string]$Rights = 'GenericAll',
    [string]$DomainRoot = 'cadre.local',
    [string]$RunAsUser = 'chief_command',
    [string]$RunAsPass = 'C0mm@nd_Ch1ef!',
    [string]$Dc = 'dc01.cadre.local'
)
$ErrorActionPreference = 'Stop'

Write-Output "=== ACL grant: $RunAsUser grants $Principal $Rights on $TargetDn ==="
$cred = New-Object System.Management.Automation.PSCredential("$DomainRoot\$RunAsUser", (ConvertTo-SecureString $RunAsPass -AsPlainText -Force))
$net = $cred.GetNetworkCredential()

$identity = New-Object System.Security.Principal.NTAccount("$DomainRoot\$Principal")
$sid = $identity.Translate([System.Security.Principal.SecurityIdentifier]).Value
Write-Output "PRINCIPAL_SID $sid"

switch ($Rights) {
  'GenericAll'   { $rightsValue = [System.DirectoryServices.ActiveDirectoryRights]'GenericAll' }
  'WriteDacl'    { $rightsValue = [System.DirectoryServices.ActiveDirectoryRights]'WriteDacl' }
  'WriteOwner'   { $rightsValue = [System.DirectoryServices.ActiveDirectoryRights]'WriteOwner' }
  'GenericWrite' { $rightsValue = [System.DirectoryServices.ActiveDirectoryRights]'ReadProperty, WriteProperty, ExtendedRight' }
  default        { $rightsValue = [System.DirectoryServices.ActiveDirectoryRights]$Rights }
}

# Resolve target object via searcher (avoids LDAP referral issues on direct DN bind)
$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Dc/DC=cadre,DC=local", $net.UserName, $net.Password)
$searcher.SearchScope = [System.DirectoryServices.SearchScope]'Subtree'
$searcher.PageSize = 500
$cnName = ($TargetDn -split ',')[0] -replace '^CN=',''
$searcher.Filter = "(&(objectClass=group)(cn=$cnName))"
Write-Output "FILTER1 $($searcher.Filter)"
$result = $searcher.FindOne()
if (-not $result) {
  $searcher.Filter = "(cn=$cnName)"
  Write-Output "FILTER2 $($searcher.Filter)"
  $result = $searcher.FindOne()
}
if (-not $result) { throw "Target $TargetDn not found in search" }
Write-Output "RESOLVED $($result.Properties['distinguishedname'][0])"

$entry = $result.GetDirectoryEntry()
$entry.RefreshCache()
$acl = $entry.ObjectSecurity
$rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($identity, $rightsValue, 'Allow')
$acl.AddAccessRule($rule)
$entry.ObjectSecurity = $acl
$entry.CommitChanges()
Write-Output "ACL_APPLIED|$TargetDn|$Principal|$Rights"

# Verify
$vResult = $searcher.FindOne()
if ($vResult) {
  $vEntry = $vResult.GetDirectoryEntry()
  $vEntry.RefreshCache()
  $found = $false
  $vEntry.ObjectSecurity.Access | Where-Object { $_.IdentityReference -like "*$Principal*" } | ForEach-Object {
    $found = $true
    Write-Output "ACE|$($_.IdentityReference)|$($_.ActiveDirectoryRights)|$($_.ObjectType)|$($_.InheritanceType)"
  }
  if (-not $found) { Write-Output "ACE_MISSING" }
} else {
  Write-Output "VERIFY_RESOLVE_FAILED"
}
