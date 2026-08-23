#!/usr/bin/env bash
# T037 — SCCM CMPivot check from ws01
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
CASE_ID="CADRE-T037-SCCM-CMPOINT-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T037 SCCM CMPivot check | ${CASE_ID} | T0=${T0} ==="
campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t037-sccm-cmpivot.ps1
cadre_export "${CASE_ID}" T037 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T037 run complete ==="
