[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
$root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc02.child.cadre.local/DC=child,DC=cadre,DC=local", "child\analyst_t1", "T13r_An@lyst!")
$ds = New-Object System.DirectoryServices.DirectorySearcher($root)
$ds.Filter = "(&(objectClass=computer)(sAMAccountName=MBR01$))"
[void]$ds.PropertiesToLoad.Add("msDS-AllowedToActOnBehalfOfOtherIdentity")
$r = $ds.FindOne()
if (-not $r) { throw "MBR01$ not found via LDAP" }
$prop = $r.Properties["msds-allowedtoactonbehalfofotheridentity"]
Write-Output ("msDS-AllowedToActOnBehalfOfOtherIdentity present: " + ($prop.Count -gt 0))
Write-Output "T007_OK: RBCD check complete"
