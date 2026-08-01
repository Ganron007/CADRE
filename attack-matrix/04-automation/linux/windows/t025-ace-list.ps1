$ErrorActionPreference = 'Stop'
$user = 'cadre.local\chief_command'
$pass = 'C0mm@nd_Ch1ef!'
$asd = 'LDAP://CN=AdminSDHolder,CN=System,DC=cadre,DC=local'

$de = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
$sd = $de.ObjectSecurity
$all = $sd.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])
Write-Output ("TOTAL_ACES " + $all.Count)
$i = 0
foreach ($r in $all) {
    $i++
    Write-Output ("ACE{0}|{1}|{2}|{3}|{4}|{5}|{6}" -f $i, $r.IdentityReference.Value, $r.AccessControlType, $r.ActiveDirectoryRights, $r.InheritanceFlags, $r.ObjectType, $r.InheritanceType)
}
