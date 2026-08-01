# Step-by-step 445 freeing with visible results (no abort)
$ErrorActionPreference = "Continue"
Write-Output "=== step A: stop LanmanServer ==="
Stop-Service LanmanServer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
$ls = Get-Service LanmanServer -ErrorAction SilentlyContinue
Write-Output "lanman=$($ls.Status)"

Write-Output "=== step B: stop srv2 (verbose) ==="
sc.exe stop srv2
Start-Sleep -Seconds 2

Write-Output "=== step C: stop srvnet (verbose) ==="
sc.exe stop srvnet
Start-Sleep -Seconds 3

Write-Output "=== state after stops ==="
sc.exe query srv2 | Select-String STATE
sc.exe query srvnet | Select-String STATE
$c = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
Write-Output "445_listener=$([bool]$c)"
if ($c) { $c | Format-Table LocalAddress,OwningProcess -AutoSize }

Write-Output "=== bind test ==="
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, 445)
try {
  $listener.Start()
  Write-Output "BIND_OK"
  $listener.Stop()
} catch {
  Write-Output "BIND_FAIL: $($_.Exception.Message)"
}

Write-Output "=== restart all ==="
sc.exe start srvnet | Out-Null
sc.exe start srv2 | Out-Null
Start-Sleep -Seconds 3
Start-Service LanmanServer -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Output "lanman_after=$( (Get-Service LanmanServer -ErrorAction SilentlyContinue).Status )"
