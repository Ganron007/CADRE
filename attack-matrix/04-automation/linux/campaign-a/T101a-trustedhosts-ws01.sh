#!/usr/bin/env bash
# T101a — one-time ws01 config: add mbr01 to TrustedHosts for PSRemoting pivot.
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T101A-TRUSTEDHOSTS-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T101A | ${CASE_ID} | T0=${T0} ==="

campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t101a-trustedhosts.ps1

cadre_export "${CASE_ID}" T101A "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T101A run complete ==="
