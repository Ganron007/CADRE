# Test: disable SMB stack start types, stop, verify 445 stays free, restore
$ErrorActionPreference = "Continue"

Write-Output "=== step 1: disable start types ==="
sc.exe config LanmanServer start= disabled | Out-Null
sc.exe config srv2 start= disabled | Out-Null
sc.exe config srvnet start= disabled | Out-Null
Write-Output "disabled ok"

Write-Output "=== step 2: stop stack ==="
Stop-Service LanmanServer -Force -ErrorAction SilentlyContinue
sc.exe stop srv2 | Out-Null
sc.exe stop srvnet | Out-Null
Start-Sleep -Seconds 5

Write-Output "=== step 3: poll 445 for 30s ==="
$bound = $null
for ($i=0; $i -lt 15; $i++) {
  $c = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
  $state = if ($c) { "BOUND(pid=$($c.OwningProcess))" } else { "free" }
  Write-Output "t=$($i*2)s 445=$state"
  if (-not $c) { $bound = $i }
  Start-Sleep -Seconds 2
}
Write-Output "last_free_t=$($bound*2)s"

Write-Output "=== step 4: bind test ==="
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, 445)
try {
  $listener.Start()
  Write-Output "BIND_OK"
  $listener.Stop()
} catch {
  Write-Output "BIND_FAIL: $($_.Exception.Message)"
}

Write-Output "=== step 5: restore start types + start ==="
sc.exe config LanmanServer start= auto | Out-Null
sc.exe config srv2 start= demand | Out-Null
sc.exe config srvnet start= demand | Out-Null
sc.exe start srvnet | Out-Null
sc.exe start srv2 | Out-Null
Start-Sleep -Seconds 2
Start-Service LanmanServer -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Output "lanman=$( (Get-Service LanmanServer -ErrorAction SilentlyContinue).Status )"
