# Query LINUX01$ machine account SPNs from AD (chief_command)
$ErrorActionPreference = "Continue"
try {
  $de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://192.168.77.10/CN=LINUX01,CN=Computers,DC=cadre,DC=local", "chief_command@cadre.local", "C0mm@nd_Ch1ef!")
  $de.RefreshCache()
  Write-Output "=== LINUX01$ attributes ==="
  Write-Output "cn: $($de.Properties['cn'][0])"
  Write-Output "dNSHostName: $($de.Properties['dNSHostName'][0])"
  Write-Output "sAMAccountName: $($de.Properties['sAMAccountName'][0])"
  Write-Output "=== servicePrincipalName ==="
  foreach ($spn in $de.Properties['servicePrincipalName']) { Write-Output "SPN: $spn" }
  Write-Output "=== userAccountControl ==="
  Write-Output "UAC: $($de.Properties['userAccountControl'][0])"
} catch { Write-Output "err: $($_.Exception.Message)" }
Write-Output "=== SPN_DONE ==="
