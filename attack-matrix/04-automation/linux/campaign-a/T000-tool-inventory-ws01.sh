#!/usr/bin/env bash
# T000 — Tool inventory on ws01
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T000-INVENTORY-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T000 | ${CASE_ID} | T0=${T0} ==="

campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t000-tool-inventory.ps1

cadre_export "${CASE_ID}" T000 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T000 complete ==="
