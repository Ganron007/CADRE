# Identify ALL SMB server drivers and test raw 445 bind
$ErrorActionPreference = "Continue"
Write-Output "=== SMB server drivers present ==="
sc.exe query srv
sc.exe query srv2
sc.exe query srvnet

Write-Output "=== stopping LanmanServer + srv2 + srv ==="
Stop-Service LanmanServer -Force -ErrorAction SilentlyContinue
sc.exe stop srv2 | Out-Null
sc.exe stop srv | Out-Null
sc.exe stop srvnet | Out-Null
Start-Sleep -Seconds 4

Write-Output "=== raw bind test on 445 ==="
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, 445)
try {
  $listener.Start()
  Write-Output "BIND_OK port 445 is free"
  $listener.Stop()
} catch {
  Write-Output "BIND_FAIL: $($_.Exception.Message)"
}

Write-Output "=== 445 listener after stop ==="
$c = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
if ($c) { $c | Format-Table LocalAddress,LocalPort,OwningProcess -AutoSize } else { Write-Output "no listener" }

Write-Output "=== restarting all ==="
sc.exe start srv | Out-Null
sc.exe start srv2 | Out-Null
sc.exe start srvnet | Out-Null
Start-Sleep -Seconds 3
Start-Service LanmanServer -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Output "lanman=$( (Get-Service LanmanServer -ErrorAction SilentlyContinue).Status )"
