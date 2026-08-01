$ErrorActionPreference = 'Stop'
$user = 'range.local\svc_naa'
$pass = 'N@A_s3rv1c3!'
$asd = 'LDAP://192.168.77.12/CN=AdminSDHolder,CN=System,DC=range,DC=local'

$de = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
$sd = $de.ObjectSecurity
$all = $sd.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])
Write-Output ("RANGE_TOTAL_ACES " + $all.Count)
$i = 0
foreach ($r in $all) {
    $i++
    Write-Output ("ACE{0}|{1}|{2}|{3}|{4}|{5}|{6}" -f $i, $r.IdentityReference.Value, $r.AccessControlType, $r.ActiveDirectoryRights, $r.InheritanceFlags, $r.ObjectType, $r.InheritanceType)
}
