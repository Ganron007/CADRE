# Dump all ACEs on AdminSDHolder as analyst_cloud (ws01 native)
$ErrorActionPreference = "Stop"
$user = "cadre.local\analyst_cloud"
$pass = "Cl0ud_An@lyst!"
$asd = "LDAP://CN=AdminSDHolder,CN=System,DC=cadre,DC=local"

try {
    $de = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
    $sd = $de.ObjectSecurity
    $rules = $sd.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])
    Write-Output "TOTAL_ACES $($rules.Count)"
    foreach ($r in $rules) {
        $sidVal = $r.IdentityReference.Value
        try { $sidVal = $r.IdentityReference.Translate([Security.Principal.SecurityIdentifier]).Value } catch {}
        Write-Output ("ACE|" + $r.AccessControlType + "|" + $r.ActiveDirectoryRights + "|" + $r.InheritanceType + "|" + $sidVal)
    }
} catch {
    Write-Output "DUMP_FAIL $_"
    exit 1
}
