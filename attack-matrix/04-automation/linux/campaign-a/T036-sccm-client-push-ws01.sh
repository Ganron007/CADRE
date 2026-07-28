#!/usr/bin/env bash
# T036 — SCCM client push relay check from ws01 (analyst_t1)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T036-SCCM-CLIENTPUSH-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T036 SCCM client push relay check | ${CASE_ID} | T0=${T0} ==="

CMD='
$ErrorActionPreference = "Stop";
try { $s = Get-Service -Name CcmExec -ErrorAction SilentlyContinue; if ($s) { Write-Output "T036_OK: CcmExec service status: $($s.Status)" } else { Write-Output "T036_INFO: CcmExec service not found" } } catch { Write-Output "T036_INFO: $_" }
Write-Output "T036_OK: client push relay check complete"
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T036 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T036 run complete ==="
