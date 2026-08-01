# Measure how long 445 stays free after stopping SMB server drivers
$ErrorActionPreference = "Continue"
Write-Output "=== stop SMB stack ==="
Stop-Service LanmanServer -Force -ErrorAction SilentlyContinue
sc.exe stop srv2 | Out-Null
sc.exe stop srv | Out-Null
sc.exe stop srvnet | Out-Null

Write-Output "=== poll 445 every 2s for 60s ==="
$bound = $null
for ($i=0; $i -lt 30; $i++) {
  $c = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
  $state = if ($c) { "BOUND(pid=$($c.OwningProcess))" } else { "free" }
  Write-Output "t=$($i*2)s 445=$state"
  if (-not $c) { $bound = $i }
  Start-Sleep -Seconds 2
}
Write-Output "last_free_t=$($bound*2)s"

Write-Output "=== restore ==="
sc.exe start srvnet | Out-Null
sc.exe start srv2 | Out-Null
Start-Sleep -Seconds 2
Start-Service LanmanServer -ErrorAction SilentlyContinue
Write-Output "lanman=$( (Get-Service LanmanServer -ErrorAction SilentlyContinue).Status )"
