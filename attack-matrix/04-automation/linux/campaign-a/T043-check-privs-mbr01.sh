#!/usr/bin/env bash
# T043 check privileges on mbr01 as analyst_t1 via WinRS from ws01.
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T043-CHECK-PRIVS-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T043 check privs | ${CASE_ID} | T0=${T0} ==="

campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t043-check-privs-mbr01.ps1

cadre_export "${CASE_ID}" T043-CHECK-PRIVS "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T043 check privs complete ==="
