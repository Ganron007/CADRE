#!/usr/bin/env bash
# T035C — RDP prereqs (3.5C) — Rule 3: port + SMB auth, not full mstsc
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== T035C RDP prereqs ==="
PS1="${SCRIPT_DIR}/../windows/wt035c-rdp-prereq.ps1"
B64=$(base64 -w0 < "${PS1}" 2>/dev/null || base64 < "${PS1}" | tr -d '\n')
ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "\$b=[Convert]::FromBase64String('${B64}'); \$t=[IO.Path]::GetTempFileName()+'.ps1'; [IO.File]::WriteAllBytes(\$t,\$b); powershell -NoProfile -File \$t; Remove-Item \$t -Force"
echo "T035C complete"
