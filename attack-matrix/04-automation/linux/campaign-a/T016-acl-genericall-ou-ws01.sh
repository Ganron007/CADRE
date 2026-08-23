#!/usr/bin/env bash
# T016 — ACL GenericAll on OU from ws01 as chief_command (cadre.local DA)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
CASE_ID="CADRE-T016-GENERICALL-OU-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T016 GenericAll on OU | ${CASE_ID} | T0=${T0} ==="
campaign_stage_run_ps1 chief_command 'C0mm@nd_Ch1ef!' campaign-a-acl.ps1 cadre.local \
  '-Marker T016 -Target "OU=Command,DC=cadre,DC=local" -Principal hunter_dfir -Rights All'
cadre_export "${CASE_ID}" T016 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T016 run complete ==="
