# Set svc_sccm UAC to the CANONICAL constrained-delegation value: 0x80200
# (NORMAL_ACCOUNT 0x200 + TRUSTED_TO_AUTH_FOR_DELEGATION 0x80000, NO unconstrained 0x10000)
$ErrorActionPreference = 'Stop'
$dc   = '192.168.77.12'
$user = 'range\svc_naa'
$pass = 'N@A_s3rv1c3!'
$dn   = 'CN=svc_sccm,OU=Adversary,DC=range,DC=local'

$de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$dc/$dn", $user, $pass)
$de.RefreshCache(@('userAccountControl'))
$uac = [int]$de.Properties['userAccountControl'].Value
Write-Output ("UAC_BEFORE=" + ('0x{0:X}' -f $uac))

# 0x80200 = NORMAL (0x200) + TRUSTED_TO_AUTH_FOR_DELEGATION (0x80000). Keep NORMAL base; drop 0x10000.
$base = $uac -band 0x2FF        # keep normal-account + low bits, drop 0x10000/0x80000
$newUac = $base -bor 0x80000
$de.Properties['userAccountControl'].Value = $newUac
$de.CommitChanges()
Write-Output ("UAC_AFTER=" + ('0x{0:X}' -f $newUac))
Write-Output "UAC_SET_CLEAN"
Write-Output "DONE"
