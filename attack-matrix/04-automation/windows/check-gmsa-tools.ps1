# Check staged gMSA tooling on ws01 + list gMSA-related binaries
$paths = @('C:\Tools\cadre-attack','C:\Tools\ADTools','C:\Tools\RedStrike')
foreach ($p in $paths) {
  if (Test-Path $p) {
    Write-Output "=== $p ==="
    Get-ChildItem $p -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'gmsa|golden|whisker|rubeus|certipy|dsinternals' } | ForEach-Object { Write-Output $_.FullName }
  }
}
# Check KDS key container with correct DN under Configuration
$root = "LDAP://dc01.cadre.local/CN=Kds-KDC,CN=Configuration,DC=cadre,DC=local"
try {
  $e = New-Object System.DirectoryServices.DirectoryEntry($root, 'chief_command', 'C0mm@nd_Ch1ef!')
  $e.RefreshCache()
  Write-Output "KDS_CONTAINER_CN $($e.Name)"
  $kids = $e.Children
  Write-Output "KDS_ROOT_KEYS $($kids.Count)"
  foreach ($k in $kids) {
    $k.RefreshCache()
    Write-Output "KDS_KEY|$($k.Properties['cn'][0])|effective=$($k.Properties['creationtime'][0])"
  }
} catch { Write-Output "KDS_ERR $($_.Exception.Message)" }
