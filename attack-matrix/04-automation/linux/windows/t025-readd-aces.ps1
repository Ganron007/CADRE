# Re-add the 2 group-inheritance RU ACEs that Set-ADObject SDDL round-trip dropped.
# Expected final: 24 ACEs = range.default(23) + analyst_cloud WriteDacl surface.
# Missing (range group-class variants):
#   (OA;;RP;037088f8-0ae1-11d2-b422-00a0c968f939;bf967aba-0de6-11d0-a285-00aa003049e2;RU)
#   (OA;;RP;59ba2f42-79a2-11d0-9020-00c04fc2d3cf;bf967aba-0de6-11d0-a285-00aa003049e2;RU)
$ErrorActionPreference = "Stop"
$user = "cadre.local\chief_command"
$pass = "C0mm@nd_Ch1ef!"
$asd = "LDAP://CN=AdminSDHolder,CN=System,DC=cadre,DC=local"

try {
    $de = New-Object System.DirectoryServices.DirectoryEntry($asd, $user, $pass)
    $de.PsBase.Options.SecurityMasks = [System.DirectoryServices.SecurityMasks]::Dacl
    $sd = $de.PsBase.ObjectSecurity

    $ruSid = 'S-1-5-32-554'
    Write-Output "RU_SID $ruSid"
    $ruIdentity = [System.Security.Principal.SecurityIdentifier]$ruSid

    $guidA = [Guid]'037088f8-0ae1-11d2-b422-00a0c968f939'   # User-Account-Restrictions (attribute set)
    $guidB = [Guid]'59ba2f42-79a2-11d0-9020-00c04fc2d3cf'   # domain-DNS? read property attr
    $inheritGroup = [Guid]'bf967aba-0de6-11d0-a285-00aa003049e2'  # group class
    $inheritUser = [Guid]'4828cc14-1437-45bc-9b07-ad6f015e5f28'   # user class

    # Check current state of these two ACEs before adding
    $rules = $sd.GetAccessRules($true, $true, [System.Security.Principal.SecurityIdentifier])
    $haveA = $false; $haveB = $false
    foreach ($r in $rules) {
        if ($r.IdentityReference.Value -ne $ruSid) { continue }
        if ($r.ObjectType -eq $guidA -and $r.InheritedObjectType -eq $inheritGroup) { $haveA = $true }
        if ($r.ObjectType -eq $guidB -and $r.InheritedObjectType -eq $inheritGroup) { $haveB = $true }
    }
    Write-Output "PRE_HAS_037088f8_group $haveA"
    Write-Output "PRE_HAS_59ba2f42_group $haveB"

    if (-not $haveA) {
        $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
            $ruIdentity,
            [System.DirectoryServices.ActiveDirectoryRights]::ReadProperty,
            [System.Security.AccessControl.AccessControlType]::Allow,
            $guidA, [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None,
            $inheritGroup)
        $sd.AddAccessRule($rule)
        Write-Output "ADDED_037088f8_group"
    }
    if (-not $haveB) {
        $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
            $ruIdentity,
            [System.DirectoryServices.ActiveDirectoryRights]::ReadProperty,
            [System.Security.AccessControl.AccessControlType]::Allow,
            $guidB, [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None,
            $inheritGroup)
        $sd.AddAccessRule($rule)
        Write-Output "ADDED_59ba2f42_group"
    }

    $de.PsBase.CommitChanges()
    Write-Output "COMMIT_OK"
} catch {
    Write-Output "FAIL $_"
    exit 1
}
