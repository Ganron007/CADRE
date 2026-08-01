$ErrorActionPreference = 'Stop'
$user = 'cadre.local\analyst_cloud'
$pass = 'Cl0ud_An@lyst!'
$asd = 'LDAP://CN=AdminSDHolder,CN=System,DC=cadre,DC=local'

# Try 1: clean 3-arg constructor (no object GUID, no inheritance) — matches playbook pattern
try {
    $de = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
    $sd = $de.ObjectSecurity
    $identity = New-Object Security.Principal.NTAccount('cadre.local\analyst_cloud')
    $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
        $identity,
        [System.DirectoryServices.ActiveDirectoryRights]::GenericAll,
        [System.Security.AccessControl.AccessControlType]::Allow)
    $sd.AddAccessRule($rule)
    $de.CommitChanges()
    Write-Output 'T025_3ARG_COMMIT_OK'
} catch {
    Write-Output ('T025_3ARG_FAIL ' + $_.Exception.Message)
}

# Re-read verify
$de2 = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
$sd2 = $de2.ObjectSecurity
$sid = (New-Object Security.Principal.NTAccount('cadre.local\analyst_cloud')).Translate([Security.Principal.SecurityIdentifier])
foreach ($r in $sd2.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])) {
    $ref = $r.IdentityReference.Value
    try { $refSid = (New-Object Security.Principal.NTAccount($ref)).Translate([Security.Principal.SecurityIdentifier]).Value } catch { $refSid = $ref }
    if ($refSid -eq $sid.Value) {
        Write-Output ("MY_ACE " + $r.AccessControlType + " rights=" + $r.ActiveDirectoryRights + " inherit=" + $r.InheritanceType)
    }
}
