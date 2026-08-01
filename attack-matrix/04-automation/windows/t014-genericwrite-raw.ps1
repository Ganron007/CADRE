# T014 — Grant GenericWrite on analyst_cloud to hunter_dfir (as chief_command DA)
# Runs on DC01 via WinRM as cadre.local\chief_command
$ErrorActionPreference = 'Stop'
$domain = 'cadre.local'
$targetDn = 'CN=analyst_cloud,OU=Cloud,DC=cadre,DC=local'
$trustee = 'hunter_dfir'

Add-Type -AssemblyName System.DirectoryServices
Add-Type -AssemblyName System.DirectoryServices.AccountManagement

$ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, $domain)
$trusteePrinc = [System.DirectoryServices.AccountManagement.Principal]::FindByIdentity($ctx, $trustee)
if (-not $trusteePrinc) { throw "Trustee $trustee not found" }
$trusteeSid = New-Object System.Security.Principal.SecurityIdentifier($trusteePrinc.Sid)

$entry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$targetDn")
$entry.RefreshCache()
$sec = $entry.ObjectSecurity
$adRights = [System.DirectoryServices.ActiveDirectoryRights]::GenericWrite
$type = [System.Security.AccessControl.AccessControlType]::Allow
$inheritance = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::All
$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($trusteeSid, $adRights, $type, $inheritance)
$sec.AddAccessRule($ace)
$entry.CommitChanges()
Write-Output "T014_OK: GenericWrite granted to $trustee on $targetDn"
