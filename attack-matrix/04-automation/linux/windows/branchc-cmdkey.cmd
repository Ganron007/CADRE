@echo off
chcp 437 >nul
cd /d C:\Tools\ADTools
echo === CMDKEY add ===
cmdkey /add:mbr02.range.local /user:range\svc_sccm /pass:s3rv1c3_SCCM!
echo === NET VIEW test ===
net view \\mbr02.range.local
echo NETVIEW_RC=%errorlevel%
echo === SHARPSCCM get admins ===
SharpSCCM.exe get admins -sms mbr02.range.local -sc CAD
echo === CLEANUP cmdkey ===
cmdkey /delete:mbr02.range.local >nul 2>&1
echo DONE
