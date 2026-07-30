#!/usr/bin/env bash
# T052 — ADCS web enrollment NTLM relay / ESC8 from ws01 as chief_command (cadre.local DA)
# Requests HTTP to ADCS web enrollment; telemetry check only.
# Entry credential: chief_command (earned via Branch A T015 ForceChangePassword)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T052-ESC8-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T052 ESC8 web enrollment check | ${CASE_ID} | T0=${T0} ==="

CMD='
$url = "http://dc01.cadre.local/certsrv/";
try { $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5; Write-Output "T052_OK: web enrollment reachable RC=$($r.StatusCode)" } catch { Write-Output "T052_INFO: web enrollment not reachable or requires auth: $($_.Exception.Message)" }
'

ws01_exec_as chief_command 'C0mm@nd_Ch1ef!' "$CMD" 'cadre.local'

cadre_export "${CASE_ID}" T052 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T052 run complete ==="
