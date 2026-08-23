#!/usr/bin/env bash
# T052 / T056 — ADCS web enrollment surface (ESC8) from ws01
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
CASE_ID="CADRE-T052-ESC8-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T052 ESC8 web enrollment check | ${CASE_ID} | T0=${T0} ==="
campaign_stage_run_ps1 chief_command 'C0mm@nd_Ch1ef!' campaign-a-t052-esc8.ps1 cadre.local
cadre_export "${CASE_ID}" T052 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T052 run complete ==="
