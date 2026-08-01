# Check srv2/srvnet recovery config + retry the working stop sequence
$ErrorActionPreference = "Continue"
Write-Output "=== failure config for srv2/srvnet ==="
sc.exe qc srv2 | Select-String "FAILURE|SERVICE_START_NAME|START_TYPE"
sc.exe qc srvnet | Select-String "FAILURE|SERVICE_START_NAME|START_TYPE"
Write-Output "=== stop sequence (retry) ==="
Stop-Service LanmanServer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
sc.exe stop srv2 | Out-Null
sc.exe stop srvnet | Out-Null
Start-Sleep -Seconds 2
Write-Output "--- query immediately after stop ---"
sc.exe query srv2 | Select-String STATE
sc.exe query srvnet | Select-String STATE
$c = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
Write-Output "445_immediate=$([bool]$c)"
Start-Sleep -Seconds 3
Write-Output "--- query after 3s ---"
sc.exe query srv2 | Select-String STATE
sc.exe query srvnet | Select-String STATE
$c2 = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
Write-Output "445_after3s=$([bool]$c2)"

Write-Output "=== bind test ==="
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, 445)
try {
  $listener.Start()
  Write-Output "BIND_OK"
  $listener.Stop()
} catch {
  Write-Output "BIND_FAIL: $($_.Exception.Message)"
}

Write-Output "=== restart ==="
sc.exe start srvnet | Out-Null
sc.exe start srv2 | Out-Null
Start-Sleep -Seconds 3
Start-Service LanmanServer -ErrorAction SilentlyContinue
Write-Output "lanman_after=$( (Get-Service LanmanServer -ErrorAction SilentlyContinue).Status )"
