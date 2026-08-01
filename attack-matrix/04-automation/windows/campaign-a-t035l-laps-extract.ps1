[CmdletBinding()]
param(
    [string]$LdapServer = "dc02.child.cadre.local",
    [string]$Username = "child\analyst_t1",
    [string]$Password = "T13r_An@lyst!"
)
$ErrorActionPreference = "Continue"

Add-Type -AssemblyName System.DirectoryServices

$secPass = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($Username, $secPass)

try {
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.PageSize = 1000
    $searcher.Filter = "(objectClass=computer)"
    $searcher.PropertiesToLoad.AddRange(@("name", "ms-Mcs-AdmPwd", "ms-Mcs-AdmPwdExpirationTime"))
    # Bind explicitly to the child domain DC
    $searcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$LdapServer", $Username, $Password)
    $results = $searcher.FindAll()
    $found = 0
    foreach ($r in $results) {
        $name = $r.Properties["name"]
        $pwd = $r.Properties["ms-Mcs-AdmPwd"]
        if ($pwd -and $pwd.Count -gt 0) {
            $found++
            Write-Output "LAPS_COMPUTER $name PASSWORD $($pwd[0])"
        }
    }
    Write-Output "LAPS_READABLE $found"
} catch {
    Write-Output "LAPS_LDAP_ERROR: $($_.Exception.Message)"
    exit 1
}
