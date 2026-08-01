# Verify svc_sccm constrained-delegation surface in range.local (as svc_naa, DA)
$ErrorActionPreference = 'Continue'
$dc   = '192.168.77.12'
$user = 'range\svc_naa'
$pass = 'N@A_s3rv1c3!'

$de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$dc/DC=range,DC=local", $user, $pass)
$searcher = New-Object System.DirectoryServices.DirectorySearcher($de)
$searcher.Filter = '(&(objectCategory=user)(sAMAccountName=svc_sccm))'
$searcher.PropertiesToLoad.AddRange(@('distinguishedName','servicePrincipalName','msDS-AllowedToDelegateTo','userAccountControl','msDS-AllowedToActOnBehalfOfOtherIdentity','objectSid')) | Out-Null
$r = $searcher.FindOne()
if ($r) {
    $p = $r.Properties
    Write-Output ("DN=" + $p['distinguishedname'])
    Write-Output ("SPN=" + ($p['serviceprincipalname'] -join ','))
    Write-Output ("ALLOWED_TO_DELEGATE=" + ($p['msds-allowedtodelegateto'] -join ','))
    Write-Output ("UAC=" + $p['useraccountcontrol'])
    Write-Output ("RBCD=" + ($p['msds-allowedtoactonbehalfofotheridentity'] -join ','))
} else { Write-Output "SVC_SCCM_NOT_FOUND" }

# Who owns HTTP/mbr02.range.local?
$s2 = New-Object System.DirectoryServices.DirectorySearcher($de)
$s2.Filter = '(servicePrincipalName=HTTP/mbr02.range.local)'
$s2.PropertiesToLoad.AddRange(@('distinguishedName')) | Out-Null
$r2 = $s2.FindOne()
if ($r2) { Write-Output ("SPN_OWNER=" + $r2.Properties['distinguishedname']) } else { Write-Output "SPN_OWNER=NONE" }

Write-Output "DONE"
