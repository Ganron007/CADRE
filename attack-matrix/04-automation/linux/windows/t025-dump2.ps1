$ErrorActionPreference = 'Stop'
$user = 'cadre.local\analyst_cloud'
$pass = 'Cl0ud_An@lyst!'
$asd = 'LDAP://CN=AdminSDHolder,CN=System,DC=cadre,DC=local'

$de = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
$sd = $de.ObjectSecurity
$sid = (New-Object Security.Principal.NTAccount('cadre.local\analyst_cloud')).Translate([Security.Principal.SecurityIdentifier])

$all = $sd.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])
Write-Output ("TOTAL_ACES " + $all.Count)
$ac = $sd.GetAccessRules($true, $false, [Security.Principal.SecurityIdentifier])
Write-Output ("ACCESS_ACES " + $ac.Count)
Write-Output ("PROTECTED " + $sd.AreAccessRulesProtected)

# List distinct identity references for a quick sanity check
$ac | Group-Object { $_.IdentityReference.Value } | ForEach-Object {
    Write-Output ("TRUSTEE " + $_.Name + " count=" + $_.Count)
}
