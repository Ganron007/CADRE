# Fix-run: WT079 SSH brute + WT080 long connection from ws01 (corrected Windows methods)
$ErrorActionPreference = 'Continue'
$LINUX01 = '192.168.77.40'
$MBR02 = '192.168.77.23'
$log = 'C:\Users\analyst_t1\campaign-e-results.txt'

# --- WT079 SSH brute force: feed wrong password via process stdin ---
Write-Output '[WT079] SSH brute force: 10 failed logins to linux01'
foreach ($pass in 'wrong1','wrong2','wrong3','wrong4','wrong5','wrong6','wrong7','wrong8','wrong9','wrong10') {
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = 'C:\Windows\System32\OpenSSH\ssh.exe'
  $psi.Arguments = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL -o NumberOfPasswordPrompts=1 -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=3 vagrant@$LINUX01 exit"
  $psi.UseShellExecute = $false
  $psi.RedirectStandardInput = $true
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.CreateNoWindow = $true
  $p = [System.Diagnostics.Process]::Start($psi)
  Start-Sleep -Milliseconds 600
  $p.StandardInput.WriteLine($pass)
  Start-Sleep -Seconds 2
  if (-not $p.HasExited) { $p.Kill() }
  $p.Dispose()
}
Write-Output '  -> 10 ssh auth attempts sent to linux01'
Add-Content $log '[WT079] SSH brute force: 10 failed logins to linux01 -> done (stdin-fed attempts)'

# --- WT080 long connection: hold TCP to mbr02:443 (listener exists) ---
Write-Output '[WT080] Long TCP connection to mbr02:443 (beacon hold ~90s)'
try {
  $client = New-Object System.Net.Sockets.TcpClient
  $client.Connect($MBR02, 443)
  $stream = $client.GetStream()
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  while ($sw.Elapsed.TotalSeconds -lt 90 -and $client.Connected) {
    try { $b = [byte[]](0x42); $stream.Write($b,0,1); $stream.Flush() } catch {}
    Start-Sleep -Seconds 10
  }
  $client.Close()
  Write-Output '  -> 90s beacon connection done'
  Add-Content $log '[WT080] Long TCP connection to mbr02:443 (beacon hold ~90s) -> done'
} catch { Write-Output ('  -> connect failed: ' + $_.Exception.Message); Add-Content $log ('[WT080] -> connect failed: ' + $_.Exception.Message) }
Write-Output '=== fix run complete ==='
