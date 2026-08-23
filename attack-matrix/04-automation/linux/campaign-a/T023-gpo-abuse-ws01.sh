#!/usr/bin/env bash
# T023 — GPO abuse from ws01 as analyst_cloud
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
CASE_ID="CADRE-T023-GPO-ABUSE-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T023 GPO abuse | ${CASE_ID} | T0=${T0} ==="
campaign_stage_run_ps1 analyst_cloud 'Cl0ud_An@lyst!' campaign-a-t023-gpo.ps1 cadre.local
cadre_export "${CASE_ID}" T023 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T023 run complete ==="
