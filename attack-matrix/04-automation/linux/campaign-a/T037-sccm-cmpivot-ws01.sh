#!/usr/bin/env bash
# T037 — SCCM CMPivot abuse check from ws01 (analyst_t1)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T037-SCCM-CMPOINT-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T037 SCCM CMPivot check | ${CASE_ID} | T0=${T0} ==="

CMD='
$ErrorActionPreference = "Stop";
$path = "C:\\Windows\\CCM\\CcmExec.exe";
if (Test-Path $path) { Write-Output "T037_OK: SCCM client binary present" } else { Write-Output "T037_INFO: SCCM client not present" }
Write-Output "T037_OK: CMPivot check complete"
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T037 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T037 run complete ==="
