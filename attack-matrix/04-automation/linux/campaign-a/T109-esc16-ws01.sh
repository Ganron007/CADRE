#!/usr/bin/env bash
# T109 — ESC16 surface: cadre-CA config on dc01
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== T109 ESC16 surface ==="
OUT="$(campaign_stage_run_ps1 chief_command 'C0mm@nd_Ch1ef!' campaign-a-t109-esc16.ps1 cadre.local)"
printf '%s\n' "${OUT}"
campaign_require_ok T109 "${OUT}" 'T109_OK'
echo "T109 complete"
