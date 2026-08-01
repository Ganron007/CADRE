# T024 — gMSA ACL + ReadGMSAPassword rights check on dc01
$ErrorActionPreference = 'Continue'
Import-Module ActiveDirectory -ErrorAction SilentlyContinue
$gmsa = Get-ADServiceAccount -Identity 'gmsaTools$' -Properties msDS-GroupMSAMembership,DistinguishedName,objectSid,SamAccountName,msDS-ManagedPasswordId
Write-Output "GMSA $($gmsa.SamAccountName)"
Write-Output "DN $($gmsa.DistinguishedName)"
Write-Output "SID $($gmsa.objectSid)"
Write-Output "PWID_PRESENT $(if($gmsa.'msDS-ManagedPasswordId'){'YES'}else{'NO'})"
$members = $gmsa.'msDS-GroupMSAMembership'
Write-Output "GROUPMSA_MEMBERS $($members -join ';')"

# Read ACL for ReadGMSAPassword (extended right GUID 05c74c5e-4deb-43b4-bd9b-862e1085234d)
$entry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$($gmsa.DistinguishedName)", 'chief_command', 'C0mm@nd_Ch1ef!')
$entry.RefreshCache()
$sec = $entry.ObjectSecurity
$readGmsaGuid = '05c74c5e-4deb-43b4-bd9b-862e1085234d'
$rules = $sec.GetAccessRules($true, $true, [System.Security.Principal.NTAccount])
Write-Output "=== ACEs granting ReadGMSAPassword or GenericAll ==="
foreach ($r in $rules) {
  $isReadGmsa = $false
  try {
    if ($r.ObjectType.ToString() -eq $readGmsaGuid) { $isReadGmsa = $true }
  } catch {}
  $rights = [string]$r.ActiveDirectoryRights
  if ($isReadGmsa -or $rights -match 'GenericAll|WriteDacl|WriteOwner') {
    Write-Output "ACE|$($r.IdentityReference)|$rights|$($r.ObjectType)|$($r.AccessControlType)"
  }
}
Write-Output 'T024_ACL_DONE'
