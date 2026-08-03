#!/usr/bin/env bash
# T099 — Golden dMSA / BadSuccessor prereqs (WT099)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== T099 dMSA prereqs ==="
PS1="${SCRIPT_DIR}/../windows/wt099-dmsa-prereq.ps1"
B64=$(base64 -w0 < "${PS1}" 2>/dev/null || base64 < "${PS1}" | tr -d '\n')
ws01_exec_as chief_command 'C0mm@nd_Ch1ef!' \
  "\$b=[Convert]::FromBase64String('${B64}'); \$t=[IO.Path]::GetTempFileName()+'.ps1'; [IO.File]::WriteAllBytes(\$t,\$b); powershell -NoProfile -File \$t; Remove-Item \$t -Force" \
  'cadre.local'
echo "T099 complete"
