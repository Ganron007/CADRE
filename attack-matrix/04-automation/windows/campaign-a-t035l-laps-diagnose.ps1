[CmdletBinding()]
param(
    [string]$LdapServer = "dc02.child.cadre.local",
    [string]$Username = "child\analyst_t1",
    [string]$Password = "T13r_An@lyst!"
)
$ErrorActionPreference = "Continue"

Add-Type -AssemblyName System.DirectoryServices

# 1. List all computers + presence of ms-Mcs-AdmPwd / msLAPS attributes
$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.PageSize = 1000
$searcher.Filter = "(objectClass=computer)"
$searcher.PropertiesToLoad.AddRange(@("name", "ms-Mcs-AdmPwd", "ms-Mcs-AdmPwdExpirationTime", "msLAPS-Password", "msLAPS-EncryptedPassword"))
$searcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$LdapServer", $Username, $Password)
$results = $searcher.FindAll()
$count = 0
foreach ($r in $results) {
    $count++
    $name = $r.Properties["name"]
    $mcspwd = $r.Properties["ms-Mcs-AdmPwd"]
    $mslaps = $r.Properties["msLAPS-Password"]
    $enc = $r.Properties["msLAPS-EncryptedPassword"]
    $hasMcspwd = $mcspwd -and $mcspwd.Count -gt 0
    $hasMsLaps = $mslaps -and $mslaps.Count -gt 0
    $hasEnc = $enc -and $enc.Count -gt 0
    Write-Output "COMPUTER|$name|ms-Mcs-AdmPwd=$hasMcspwd|msLAPS-Password=$hasMsLaps|msLAPS-Encrypted=$hasEnc"
}
Write-Output "COMPUTER_TOTAL $count"

# 2. Check legacy LAPS schema availability + ACL on the attribute
$schema = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$LdapServer/CN=ms-Mcs-AdmPwd,CN=Schema,CN=Configuration,DC=child,DC=cadre,DC=local", $Username, $Password)
if ($schema) { Write-Output "SCHEMA ms-Mcs-AdmPwd exists" } else { Write-Output "SCHEMA ms-Mcs-AdmPwd missing" }

# 3. Attempt authenticated read of attribute ACL on a computer object
$comp = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$LdapServer/CN=MBR01,OU=Servers,DC=child,DC=cadre,DC=local", $Username, $Password)
if ($comp) {
    $comp.RefreshCache()
    $acl = $comp.ObjectSecurity
    Write-Output "COMP_ACL_READ ok"
} else {
    Write-Output "COMP_ACL_READ failed (object not found - wrong DN?)"
}
