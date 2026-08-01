# WT027 — SPN Jacking cleanup — remove the planted SPN from analyst_cloud
# Run AFTER the TGS verification; restores the object to pre-attack state.
# Binds as chief_command (DA) — same account that planted the SPN.
$ErrorActionPreference = 'Stop'

$dc   = '192.168.77.10'
$user = 'cadre\chief_command'
$pass = 'C0mm@nd_Ch1ef!'
$spn  = 'MSSQLSvc/dc01.cadre.local:14333'   # free SPN claimed by the WT027 attack
$dn   = 'CN=analyst_cloud,OU=Cloud,DC=cadre,DC=local'

try {
    $de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$dc/$dn", $user, $pass)
    $de.RefreshCache(@('servicePrincipalName'))
    $before = @($de.Properties['servicePrincipalName'])
    Write-Output ("BEFORE_SPNS=" + ($before -join '|'))

    if ($before -contains $spn) {
        $de.Properties['servicePrincipalName'].Remove($spn)
        $de.CommitChanges()
        Write-Output "SPN_REMOVED"
    } else {
        Write-Output "SPN_NOT_PRESENT"
    }

    $de2 = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$dc/$dn", $user, $pass)
    $de2.RefreshCache(@('servicePrincipalName'))
    $after = @($de2.Properties['servicePrincipalName'])
    Write-Output ("AFTER_SPNS=" + ($after -join '|'))

    if ($after -contains $spn) {
        Write-Output "CLEANUP_FAIL"
        exit 1
    }
    Write-Output "CLEANUP_OK"
}
catch {
    Write-Output ("CLEANUP_ERROR=" + $_.Exception.Message)
    exit 1
}
