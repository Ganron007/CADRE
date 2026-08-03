#!/usr/bin/env bash
# Branch B ESC7 / ESC9 surface checks (ManageCA / NoSecurityExtension)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== ESC7/ESC9 surface ==="
ws01_exec_as hunter_dfir 'DF1R_Hunt3r!' '
$ErrorActionPreference="Continue"
certipy find -u hunter_dfir@cadre.local -p "DF1R_Hunt3r!" -dc-ip 192.168.77.10 -vulnerable 2>&1 | Select-String -Pattern "ESC7|ESC9|CADRE-ESC9|ManageCA" | ForEach-Object { $_.Line }
Write-Output "ESC7_ESC9_SURFACE_DONE"
' 'cadre.local'
echo "ESC7/9 complete"
