#!/usr/bin/env bash
# T040 — MSSQL linked server hop to linux01 from ws01
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
CASE_ID="CADRE-T040-MSSQL-LINKED-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T040 MSSQL linked server hop | ${CASE_ID} | T0=${T0} ==="
campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t040-mssql-linked.ps1
cadre_export "${CASE_ID}" T040 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T040 run complete ==="
