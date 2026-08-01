# WT027 — SPN owner lookup in child.cadre.local (dc02) — confirm cross-domain duplicate
$ErrorActionPreference = 'Stop'
$dc   = '192.168.77.11'   # dc02 = child.cadre.local
$user = 'cadre\chief_command'
$pass = 'C0mm@nd_Ch1ef!'

function Search-Spn([string]$base, [string]$filter) {
    $de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$dc/$base", $user, $pass)
    $searcher = New-Object System.DirectoryServices.DirectorySearcher($de)
    $searcher.PageSize = 500
    $searcher.Filter = $filter
    $searcher.PropertiesToLoad.AddRange(@('distinguishedName','servicePrincipalName')) | Out-Null
    $searcher.FindAll()
}

try {
    # 1) Who owns the documented SPN in the child domain?
    $r1 = Search-Spn 'DC=child,DC=cadre,DC=local' '(servicePrincipalName=MSSQLSvc/mbr01.child.cadre.local:1433)'
    if ($r1.Count -gt 0) {
        foreach ($r in $r1) {
            Write-Output ("OWNER_DOC_SPN=" + $r.Properties['distinguishedname'])
            Write-Output ("  spns=" + ($r.Properties['serviceprincipalname'] -join '|'))
        }
    } else {
        Write-Output "OWNER_DOC_SPN=NONE_FOUND"
    }

    # 2) mbr01$ SPNs
    $r2 = Search-Spn 'DC=child,DC=cadre,DC=local' '(&(objectCategory=computer)(sAMAccountName=mbr01$))'
    foreach ($r in $r2) {
        Write-Output ("MBR01_DN=" + $r.Properties['distinguishedname'])
        Write-Output ("MBR01_SPNS=" + ($r.Properties['serviceprincipalname'] -join '|'))
    }

    # 3) cross-forest check — is the SPN in range.local too (mbr02 / dc03)?
    $r3 = Search-Spn 'DC=range,DC=local' '(servicePrincipalName=MSSQLSvc/mbr01.child.cadre.local:1433)'
    if ($r3.Count -gt 0) {
        foreach ($r in $r3) {
            Write-Output ("OWNER_RANGE_SPN=" + $r.Properties['distinguishedname'])
        }
    } else {
        Write-Output "OWNER_RANGE_SPN=NONE_FOUND"
    }
}
catch {
    Write-Output ("LOOKUP_ERROR=" + $_.Exception.Message)
    exit 1
}
