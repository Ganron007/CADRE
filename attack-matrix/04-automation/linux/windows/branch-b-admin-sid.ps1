$ErrorActionPreference = "Continue"
# Get Administrator SID via ADSI (works on ws01 as analyst_t1)
try {
    $de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc01.cadre.local/CN=Administrator,CN=Users,DC=cadre,DC=local", "cadre.local\chief_command", "C0mm@nd_Ch1ef!")
    $sid = $de.objectSid[0]
    $sidStr = (New-Object System.Security.Principal.SecurityIdentifier($sid, 0)).Value
    Write-Output "ADMIN_SID $sidStr"
} catch {
    Write-Output "ADSI_FAIL $($_.Exception.Message)"
}
# Also try via Get-ADUser using AD module
try {
    . C:\Tools\cadre-attack\ADModule-master\Import-ActiveDirectory.ps1
    Import-ActiveDirectory
    $u = Get-ADUser administrator -Server dc01.cadre.local -Properties objectSid
    Write-Output "ADMODULE_SID $($u.objectSid)"
} catch {
    Write-Output "ADMODULE_FAIL $($_.Exception.Message)"
}
