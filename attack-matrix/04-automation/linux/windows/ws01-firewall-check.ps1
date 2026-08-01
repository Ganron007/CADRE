# Check ws01 firewall: SMB-In rule, domain profile, and whether 445/80 inbound is allowed
$ErrorActionPreference = "Continue"

Write-Output "=== profiles ==="
Get-NetFirewallProfile | Format-Table Name,Enabled,DefaultInboundAction -AutoSize

Write-Output "=== SMB/File-Printer rules (all, incl disabled) ==="
Get-NetFirewallRule -ErrorAction SilentlyContinue |
  Where-Object { $_.DisplayName -match "File and Printer|SMB-In|445|FPS-SMB" } |
  Format-Table DisplayName,Direction,Action,Enabled,Profile -AutoSize

Write-Output "=== any inbound allow rule for TCP 445 or 80 ==="
$rules = Get-NetFirewallRule -Direction Inbound -Action Allow -Enabled True -ErrorAction SilentlyContinue
foreach ($r in $rules) {
  $pf = $r | Get-NetFirewallPortFilter -ErrorAction SilentlyContinue
  if ($pf -and $pf.Protocol -eq "TCP" -and ($pf.LocalPort -eq 445 -or $pf.LocalPort -eq 80)) {
    Write-Output "$($r.DisplayName) | proto=$($pf.Protocol) port=$($pf.LocalPort) | profile=$($r.Profile)"
  }
}

Write-Output "=== netstat 445/80/135 listeners ==="
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
  Where-Object { $_.LocalPort -in 445,80,135 } |
  Format-Table LocalAddress,LocalPort,OwningProcess -AutoSize

Write-Output "=== can dc01 reach ws01:445/80? (from ws01, test to own lab IP via raw TCP) ==="
$t445 = Test-NetConnection -ComputerName 192.168.77.62 -Port 445 -WarningAction SilentlyContinue
Write-Output "tcp_445_self=$($t445.TcpTestSucceeded)"
