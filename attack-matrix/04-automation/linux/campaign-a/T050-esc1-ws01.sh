#!/usr/bin/env bash
# T050 — ADCS ESC1 enumeration from ws01 as chief_command
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
CASE_ID="CADRE-T050-ESC1-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T050 ESC1 | ${CASE_ID} | T0=${T0} ==="
campaign_stage_run_ps1 chief_command 'C0mm@nd_Ch1ef!' campaign-a-t050-esc1.ps1 cadre.local
cadre_export "${CASE_ID}" T050 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T050 run complete ==="
