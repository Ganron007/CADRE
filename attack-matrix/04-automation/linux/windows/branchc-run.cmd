@echo off
cd /d C:\Tools\ADTools
SharpSCCM.exe get admins -sms mbr02.range.local -sc CAD > C:\Tools\cadre-attack\sccm-out.txt 2>&1
