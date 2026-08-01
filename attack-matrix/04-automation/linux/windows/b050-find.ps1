# T050 phase 1 - certipy find as chief_command (direct ws01 SSH, Rule 1 compliant)
$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
$out = "C:\Tools\cadre-attack\esc1-find"
if (Test-Path "$out.txt") { Remove-Item "$out.txt" -Force }
& $certpy find -u "chief_command@cadre.local" -p "C0mm@nd_Ch1ef!" -dc-ip 192.168.77.10 -vulnerable -text -out $out 2>&1 | Select-Object -Last 40
Write-Output "find_rc=$LASTEXITCODE"
Write-Output "=== FIND_DONE ==="
