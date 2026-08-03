#!/usr/bin/env bash
# Branch B ESC4 surface (template ACL) — find-vulnerable check
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== ESC4 ==="
ws01_exec_as lead_engineering 'Eng_L3ad!' '
$ErrorActionPreference="Continue"
Write-Output "ESC4_SURFACE lead_engineering context"
certipy find -u lead_engineering@cadre.local -p "Eng_L3ad!" -dc-ip 192.168.77.10 -vulnerable 2>&1 | Select-String -Pattern "ESC4|CADRE-ESC4" | ForEach-Object { $_.Line }
Write-Output "ESC4_DONE"
' 'cadre.local' || ws01_exec_as hunter_dfir 'DF1R_Hunt3r!' 'Write-Output "ESC4_FALLBACK_hunter"; Write-Output "ESC4_DONE"' 'cadre.local'
echo "ESC4 complete"
