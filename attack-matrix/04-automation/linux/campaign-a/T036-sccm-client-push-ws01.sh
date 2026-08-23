#!/usr/bin/env bash
# T036 — SCCM client push relay check from ws01
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
CASE_ID="CADRE-T036-SCCM-CLIENTPUSH-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T036 SCCM client push relay check | ${CASE_ID} | T0=${T0} ==="
campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t036-sccm-push.ps1
cadre_export "${CASE_ID}" T036 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T036 run complete ==="
