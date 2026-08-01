@echo off
REM Check ADCS tooling on ws01
where.exe certipy 2>&1
where.exe certipy-ad 2>&1
python -c "import certipy" 2>&1
if exist C:\Tools\cadre-attack\Certify.exe echo CERTIFY_YES
if exist C:\Tools\cadre-attack\Rubeus.exe echo RUBEUS_YES
if exist C:\Tools\cadre-attack\pkinittools-src\gettgtpkinit.py echo GETTGTPKINIT_YES
if exist C:\Tools\cadre-attack\pkinittools-src\getnthash.py echo GETNTHASH_YES
if exist C:\Tools\cadre-attack\pywhisker-src\pywhisker.py echo PYWHISKER_YES
dir /b C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts | findstr /i cert
