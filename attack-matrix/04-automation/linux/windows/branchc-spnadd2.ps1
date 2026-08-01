$ErrorActionPreference = "Stop"
Write-Output "=== Check for SPN duplicates across range.local ==="
$root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/DC=range,DC=local", "range\svc_naa", "N@A_s3rv1c3!")
$searcher = New-Object System.DirectoryServices.DirectorySearcher($root)
$searcher.PageSize = 1000
$searcher.Filter = "(servicePrincipalName=cifs/mbr02.range.local)"
$dup = $searcher.FindAll()
Write-Output "DUPLICATES_cifs=$($dup.Count)"
foreach ($d in $dup) { Write-Output "  OWNER: $($d.Properties['distinguishedname'])" }
$searcher.Filter = "(servicePrincipalName=HTTP/mbr02.range.local)"
$dup2 = $searcher.FindAll()
Write-Output "DUPLICATES_http=$($dup2.Count)"
foreach ($d in $dup2) { Write-Output "  OWNER: $($d.Properties['distinguishedname'])" }

Write-Output "=== Find mbr02 computer object ==="
$searcher.Filter = "(&(objectClass=computer)(sAMAccountName=mbr02$))"
$result = $searcher.FindOne()
if (-not $result) { Write-Output "MBR02 NOT FOUND"; exit 1 }
$dn = $result.Properties['distinguishedname'][0]
Write-Output "DN=$dn"

$entry = $result.GetDirectoryEntry()
$spns = $entry.Properties["servicePrincipalName"]
Write-Output "=== SPNs before ==="
foreach ($s in $spns) { Write-Output "  $s" }
if (-not $spns.Contains("cifs/mbr02.range.local")) {
    $spns.Add("cifs/mbr02.range.local") | Out-Null
    Write-Output "ADDED cifs/mbr02.range.local"
}
if (-not $spns.Contains("HTTP/mbr02.range.local")) {
    $spns.Add("HTTP/mbr02.range.local") | Out-Null
    Write-Output "ADDED HTTP/mbr02.range.local"
}
try {
    $entry.CommitChanges()
    Write-Output "COMMIT_OK"
} catch {
    Write-Output "COMMIT_FAIL: $($_.Exception.Message)"
}
$entry2 = $result.GetDirectoryEntry()
Write-Output "=== SPNs after ==="
foreach ($s in $entry2.Properties["servicePrincipalName"]) { Write-Output "  $s" }
Write-Output "DONE"
