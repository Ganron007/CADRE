# Fix svc_sccm CD surface: add TRUSTED_TO_AUTH_FOR_DELEGATION (0x80000) to userAccountControl
# Current UAC 0x10200 (TRUSTED_FOR_DELEGATION + NORMAL) -> 0x90200 (adds 0x80000)
$ErrorActionPreference = 'Stop'
$dc   = '192.168.77.12'
$user = 'range\svc_naa'
$pass = 'N@A_s3rv1c3!'
$dn   = 'CN=svc_sccm,OU=Adversary,DC=range,DC=local'

$de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$dc/$dn", $user, $pass)
$de.RefreshCache(@('userAccountControl','servicePrincipalName','msDS-AllowedToDelegateTo'))
$uac = [int]$de.Properties['userAccountControl'].Value
Write-Output ("UAC_BEFORE=" + ('0x{0:X}' -f $uac))
Write-Output ("SPN=" + ($de.Properties['servicePrincipalName'] -join ','))
Write-Output ("ATD=" + ($de.Properties['msDS-AllowedToDelegateTo'] -join ','))

if (($uac -band 0x80000) -eq 0) {
    $newUac = $uac -bor 0x80000
    $de.Properties['userAccountControl'].Value = $newUac
    $de.CommitChanges()
    Write-Output ("UAC_AFTER=" + ('0x{0:X}' -f $newUac))
    Write-Output "UAC_UPDATED"
} else {
    Write-Output "UAC_ALREADY_OK"
}
Write-Output "DONE"
