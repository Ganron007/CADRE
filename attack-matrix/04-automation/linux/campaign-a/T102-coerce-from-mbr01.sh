#!/usr/bin/env bash
# T102 — Coerce dc02$ to authenticate to mbr01 (mbr01 beachhead helper)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T102-COERCE-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T102 | ${CASE_ID} | T0=${T0} ==="

campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t102-mbr01-coerce.ps1

cadre_export "${CASE_ID}" T102 "${T0}" 192.168.77.22
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T102 run complete ==="
