#!/usr/bin/env bash
# T043 stage — push GodPotato to mbr01 from ws01 via WinRS as analyst_t1.
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T043-STAGE-MBR01-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T043 stage | ${CASE_ID} | T0=${T0} ==="

campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t043-stage-mbr01.ps1

cadre_export "${CASE_ID}" T043-STAGE-MBR01 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T043 stage complete ==="
