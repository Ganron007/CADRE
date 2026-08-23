#!/usr/bin/env bash
# T041 — xp_cmdshell via SQL from ws01 (analyst_t1 → IMPERSONATE sa)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T041-XPCMD-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
MBR01="${MBR01:-192.168.77.22}"
echo "=== T041 | ${CASE_ID} | T0=${T0} ==="

OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t041-xpcmd.ps1 child.cadre.local "-Server ${MBR01}")"
printf '%s\n' "${OUT}"
campaign_require_ok T041 "${OUT}" 'SQL_OK|T041_OK'

cadre_export "${CASE_ID}" T041 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
