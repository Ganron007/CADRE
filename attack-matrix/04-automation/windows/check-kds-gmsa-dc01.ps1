# Check KDS root key + gMSA provisioning state on dc01 (as chief_command)
$ErrorActionPreference = 'Continue'
$credUser = 'chief_command'
$credPass = 'C0mm@nd_Ch1ef!'

# KDS root keys (Configuration NC)
$root = "LDAP://dc01.cadre.local/CN=Kds-KDC,CN=Configuration,DC=cadre,DC=local"
try {
  $e = New-Object System.DirectoryServices.DirectoryEntry($root, $credUser, $credPass)
  $e.RefreshCache()
  $kids = $e.Children
  Write-Output "KDS_ROOT_KEYS $($kids.Count)"
  foreach ($k in $kids) {
    $k.RefreshCache()
    Write-Output "KDS_KEY|$($k.Name)|created=$($k.Properties['cn'][0])"
  }
} catch { Write-Output "KDS_ERR $($_.Exception.Message)" }

# gMSA account msDS-ManagedPassword presence
$g = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc01.cadre.local/CN=gmsaTools,CN=Managed Service Accounts,DC=cadre,DC=local", $credUser, $credPass)
try {
  $g.RefreshCache()
  Write-Output "GMSA_DN $($g.distinguishedName)"
  $blob = $g.Properties['msDS-ManagedPassword'].Value
  if ($blob) { Write-Output "GMSA_BLOB_LEN $($blob.Length)" } else { Write-Output "GMSA_BLOB_MISSING" }
  # Also check msDS-ManagedPasswordPreviousId, msDS-ManagedPasswordId
  $g.Properties.PropertyNames | Sort-Object | Where-Object { $_ -match 'msds-managed|msds-group' } | ForEach-Object {
    Write-Output "ATTR $_ = $(($g.Properties[$_]) -join ',')"
  }
} catch { Write-Output "GMSA_ERR $($_.Exception.Message)" }
Write-Output 'CHECK_DONE'
