$ErrorActionPreference = 'Stop'
$user = 'cadre.local\analyst_cloud'
$pass = 'Cl0ud_An@lyst!'
$asd = 'LDAP://CN=AdminSDHolder,CN=System,DC=cadre,DC=local'

$de = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
$sd = $de.ObjectSecurity
$sid = (New-Object Security.Principal.NTAccount('cadre.local\analyst_cloud')).Translate([Security.Principal.SecurityIdentifier])

Write-Output ("ANALYST_CLOUD_SID " + $sid.Value)
$all = $sd.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])
foreach ($r in $all) {
    $ref = $r.IdentityReference.Value
    try { $refSid = (New-Object Security.Principal.NTAccount($ref)).Translate([Security.Principal.SecurityIdentifier]).Value } catch { $refSid = $ref }
    if ($refSid -eq $sid.Value) {
        Write-Output ("MY_ACE " + $r.AccessControlType + " rights=" + $r.ActiveDirectoryRights + " flags=" + $r.InheritanceFlags + " objType=" + $r.ObjectType + " inherit=" + $r.InheritanceType)
    }
}
Write-Output ("PROTECTED " + $sd.AreAccessRulesProtected)
Write-Output ("SD_FLAGS " + $sd.ControlFlags)
