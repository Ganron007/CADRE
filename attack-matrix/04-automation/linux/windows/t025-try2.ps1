$ErrorActionPreference = 'Stop'
$user = 'cadre.local\analyst_cloud'
$pass = 'Cl0ud_An@lyst!'
$asd = 'LDAP://CN=AdminSDHolder,CN=System,DC=cadre,DC=local'

# Approach: set SecurityMasks before reading ObjectSecurity, then add ACE and commit
$de = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
$de.Options.SecurityMasks = [DirectoryServices.SecurityMasks]::Dacl -bor [DirectoryServices.SecurityMasks]::Owner -bor [DirectoryServices.SecurityMasks]::Group
$sd = $de.ObjectSecurity
$sid = (New-Object Security.Principal.NTAccount('cadre.local\analyst_cloud')).Translate([Security.Principal.SecurityIdentifier])

# Add GenericAll ACE
$rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $sid,
    [System.DirectoryServices.ActiveDirectoryRights]::GenericAll,
    [System.Security.AccessControl.AccessControlType]::Allow)
$sd.AddAccessRule($rule)
try {
    $de.CommitChanges()
    Write-Output 'T025_COMMIT_OK'
} catch {
    Write-Output ('T025_COMMIT_FAIL ' + $_.Exception.Message)
}

# Re-read to verify
$de2 = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
$sd2 = $de2.ObjectSecurity
foreach ($r in $sd2.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])) {
    $ref = $r.IdentityReference.Value
    try { $refSid = (New-Object Security.Principal.NTAccount($ref)).Translate([Security.Principal.SecurityIdentifier]).Value } catch { $refSid = $ref }
    if ($refSid -eq $sid.Value) {
        Write-Output ("MY_ACE " + $r.AccessControlType + " rights=" + $r.ActiveDirectoryRights + " inherit=" + $r.InheritanceType)
    }
}
