#!/usr/bin/env bash
# T012 — Diamond ticket (Rubeus diamond — Windows-only, staged on ws01)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T012-DIAMOND-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T012 | ${CASE_ID} | T0=${T0} ==="

ws01_ensure_rubeus
campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t012-diamond.ps1

cadre_export "${CASE_ID}" T012 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
