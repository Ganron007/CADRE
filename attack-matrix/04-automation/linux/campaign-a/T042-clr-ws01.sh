#!/usr/bin/env bash
# T042 — MSSQL CLR probe from ws01 → mbr02 (range.local SQL)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T042-CLR-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
MBR02="${MBR02:-192.168.77.23}"
echo "=== T042 | ${CASE_ID} | T0=${T0} ==="

OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t042-clr.ps1 child.cadre.local "-Server ${MBR02}")"
printf '%s\n' "${OUT}"
campaign_require_ok T042 "${OUT}" 'SQL_OK|T042_OK'
RC=0

cadre_export "${CASE_ID}" T042 "${T0}" 192.168.77.62
echo "T0=${T0} sql_rc=${RC}" | tee "/tmp/${CASE_ID}.t0"
