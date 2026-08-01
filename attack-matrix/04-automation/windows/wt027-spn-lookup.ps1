# WT027 — SPN owner lookup (root-cause the constraint violation)
# Explicit-cred LDAP against dc01 (cadre.local) to find who owns the target SPN.
$ErrorActionPreference = 'Stop'
$dc   = '192.168.77.10'
$user = 'cadre\chief_command'
$pass = 'C0mm@nd_Ch1ef!'

function Search-Spn([string]$filter) {
    $de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$dc/DC=cadre,DC=local", $user, $pass)
    $searcher = New-Object System.DirectoryServices.DirectorySearcher($de)
    $searcher.PageSize = 500
    $searcher.Filter = $filter
    $searcher.PropertiesToLoad.AddRange(@('distinguishedName','servicePrincipalName')) | Out-Null
    $searcher.FindAll()
}

try {
    # 1) Who owns the documented SPN?
    $r1 = Search-Spn '(servicePrincipalName=MSSQLSvc/mbr01.child.cadre.local:1433)'
    if ($r1.Count -gt 0) {
        foreach ($r in $r1) {
            Write-Output ("OWNER_DOC_SPN=" + $r.Properties['distinguishedname'])
            Write-Output ("  spns=" + ($r.Properties['serviceprincipalname'] -join '|'))
        }
    } else {
        Write-Output "OWNER_DOC_SPN=NONE_FOUND"
    }

    # 2) mbr01$ SPNs (the real SQL host in child.cadre.local)
    $r2 = Search-Spn '(&(objectCategory=computer)(sAMAccountName=mbr01$))'
    foreach ($r in $r2) {
        Write-Output ("MBR01_DN=" + $r.Properties['distinguishedname'])
        Write-Output ("MBR01_SPNS=" + ($r.Properties['serviceprincipalname'] -join '|'))
    }

    # 3) Is the fallback SPN (different port) free?
    $r3 = Search-Spn '(servicePrincipalName=MSSQLSvc/mbr01.child.cadre.local:14333)'
    if ($r3.Count -gt 0) {
        foreach ($r in $r3) {
            Write-Output ("OWNER_ALT_SPN=" + $r.Properties['distinguishedname'])
        }
    } else {
        Write-Output "OWNER_ALT_SPN=FREE"
    }
}
catch {
    Write-Output ("LOOKUP_ERROR=" + $_.Exception.Message)
    exit 1
}
