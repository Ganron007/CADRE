# T024 diagnostics: KDS root key + gMSA managed password read via DSInternals/ADModule
$ErrorActionPreference = 'Continue'
Write-Output "=== Get-KdsRootKey (KDS root keys) ==="
try {
  $kds = Get-KdsRootKey -ErrorAction Stop
  if ($kds) { $kds | Format-List | Out-String | Write-Output } else { Write-Output 'KDS_ROOT_KEY_NONE' }
} catch { Write-Output "KDS_ERR $($_.Exception.Message)" }

Write-Output "=== Get-ADServiceAccount gmsaTools (msDS-ManagedPassword) ==="
try {
  Import-Module ActiveDirectory -ErrorAction Stop
  $sa = Get-ADServiceAccount -Identity 'gmsaTools' -Properties msDS-ManagedPassword,msDS-ManagedPasswordId,msDS-ManagedPasswordInterval,msDS-GroupMSAMembership,SamAccountName -ErrorAction Stop
  Write-Output "GMSA_SA $($sa.SamAccountName)"
  Write-Output "PW_ID $($sa.'msDS-ManagedPasswordId' -join ',')"
  Write-Output "PW_BLOB_LEN $(($sa.'msDS-ManagedPassword'.Length))"
  Write-Output "MEMBER $($sa.'msDS-GroupMSAMembership' -join ',')"
} catch { Write-Output "GMSA_ERR $($_.Exception.Message)" }

Write-Output "=== Get-ADComputer + gMSA group membership (what can read) ==="
try {
  Get-ADGroup 'gmsaReadGroup' -ErrorAction SilentlyContinue | Select-Object Name | Out-String | Write-Output
} catch { Write-Output 'gmsaReadGroup_ERR' }
Write-Output 'CHECK_DONE'
