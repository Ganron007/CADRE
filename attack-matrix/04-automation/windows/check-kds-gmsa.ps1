# Check KDS root key + gMSA provisioning state on dc01
$ErrorActionPreference = 'Continue'
$user = 'cadre.local\chief_command'
$pass = ConvertTo-SecureString 'C0mm@nd_Ch1ef!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($user, $pass)

# KDS root keys (in Configuration NC)
$root = "LDAP://dc01.cadre.local/CN=Kds-KDC,CN=Configuration,DC=cadre,DC=local"
try {
  $e = New-Object System.DirectoryServices.DirectoryEntry($root, 'chief_command', 'C0mm@nd_Ch1ef!')
  $e.RefreshCache()
  $kids = $e.Children
  Write-Output "KDS_ROOT_KEYS $($kids.Count)"
  foreach ($k in $kids) {
    $k.RefreshCache()
    Write-Output "KDS_KEY|$($k.Name)|created=$($k.Properties['cn'][0])|effective=$($k.Properties['creationtime'][0])"
  }
} catch { Write-Output "KDS_ERR $($_.Exception.Message)" }

# Check gMSA object attributes
$g = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc01.cadre.local/CN=gmsaTools,CN=Managed Service Accounts,DC=cadre,DC=local", 'chief_command', 'C0mm@nd_Ch1ef!')
$g.RefreshCache()
$g.Properties.PropertyNames | Sort-Object | ForEach-Object {
  if ($_ -match 'msds|ms-ds|useraccount|managed|kds') {
    $vals = ($g.Properties[$_]) -join ','
    Write-Output "ATTR $_ = $vals"
  }
}
