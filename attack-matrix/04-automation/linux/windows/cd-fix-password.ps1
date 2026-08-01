# Reset svc_sccm password to the documented value + set DONT_EXPIRE_PASSWORD (0x1000000)
# (as svc_naa, range DA — restoring the attack-surface credential)
$ErrorActionPreference = 'Stop'
$dc   = '192.168.77.12'
$user = 'range\svc_naa'
$pass = 'N@A_s3rv1c3!'
$dn   = 'CN=svc_sccm,OU=Adversary,DC=range,DC=local'
$newPw = 's3rv1c3_SCCM!'

$de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$dc/$dn", $user, $pass)
$de.RefreshCache(@('userAccountControl','pwdLastSet'))

# 1) Reset password
$de.Invoke('SetPassword', @($newPw)) | Out-Null
Write-Output "PASSWORD_RESET"

# 2) Add DONT_EXPIRE_PASSWORD (0x1000000)
$uac = [int]$de.Properties['userAccountControl'].Value
$newUac = $uac -bor 0x1000000
if ($newUac -ne $uac) {
    $de.Properties['userAccountControl'].Value = $newUac
    $de.CommitChanges()
    Write-Output ("UAC_AFTER=" + ('0x{0:X}' -f $newUac))
} else {
    Write-Output "UAC_UNCHANGED"
}
Write-Output "DONE"
