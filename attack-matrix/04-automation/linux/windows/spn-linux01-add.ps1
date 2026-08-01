# Register nfs/<host> SPNs on LINUX01$ machine account (chief_command DA)
$ErrorActionPreference = "Continue"
try {
  $de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://192.168.77.10/CN=LINUX01,CN=Computers,DC=cadre,DC=local", "chief_command@cadre.local", "C0mm@nd_Ch1ef!")
  $de.RefreshCache()
  $spns = $de.Properties["servicePrincipalName"]
  Write-Output "=== before ==="
  foreach ($spn in $spns) { Write-Output "SPN: $spn" }
  $added = @()
  if (-not ($spns | Where-Object { $_ -ieq "nfs/linux01" })) { $spns.Add("nfs/linux01") | Out-Null; $added += "nfs/linux01" }
  if (-not ($spns | Where-Object { $_ -ieq "nfs/linux01.cadre.local" })) { $spns.Add("nfs/linux01.cadre.local") | Out-Null; $added += "nfs/linux01.cadre.local" }
  if ($added.Count -gt 0) {
    $de.CommitChanges()
    Write-Output "ADDED: $($added -join ', ')"
  } else { Write-Output "NO_CHANGE" }
  Write-Output "=== after ==="
  $de.RefreshCache()
  foreach ($spn in $de.Properties["servicePrincipalName"]) { Write-Output "SPN: $spn" }
} catch { Write-Output "err: $($_.Exception.Message)" }
Write-Output "=== SPN_ADD_DONE ==="
