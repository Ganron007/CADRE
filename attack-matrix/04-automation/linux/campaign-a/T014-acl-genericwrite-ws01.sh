#!/usr/bin/env bash
# T014 — ACL GenericWrite from ws01 as chief_command (cadre.local DA)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
CASE_ID="CADRE-T014-GENERICWRITE-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T014 GenericWrite | ${CASE_ID} | T0=${T0} ==="
campaign_stage_run_ps1 chief_command 'C0mm@nd_Ch1ef!' campaign-a-acl.ps1 cadre.local \
  '-Marker T014 -Target analyst_cloud -Principal hunter_dfir -Rights All'
cadre_export "${CASE_ID}" T014 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T014 run complete ==="
