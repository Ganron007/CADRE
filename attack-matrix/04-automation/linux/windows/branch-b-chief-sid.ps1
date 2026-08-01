$ErrorActionPreference = "Continue"
$de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc01.cadre.local/CN=Chief Command,CN=Users,DC=cadre,DC=local", "cadre.local\chief_command", "C0mm@nd_Ch1ef!")
$sid = $de.objectSid[0]
$sidStr = (New-Object System.Security.Principal.SecurityIdentifier($sid, 0)).Value
Write-Output "CHIEF_COMMAND_SID $sidStr"
