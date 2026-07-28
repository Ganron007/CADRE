#!/usr/bin/env bash
# T023 — GPO abuse from ws01 (analyst_t1) using PowerView
# Enumerates GPOs and links a GPO to an OU (read-only demonstration).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T023-GPO-ABUSE-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T023 GPO abuse | ${CASE_ID} | T0=${T0} ==="

DC02="${DC02:-dc02.child.cadre.local}"
DOMAIN_CHILD="${DOMAIN_CHILD:-child.cadre.local}"

CMD='
$pv = "C:\Tools\cadre-attack\PowerView.ps1";
if (-not (Test-Path $pv)) { throw "PowerView.ps1 not found" }
. $pv;
$ErrorActionPreference = "Stop";
Write-Output "=== GPOs ===";
Get-DomainGPO -DomainController "'''"${DC02}"'''" -Domain "'''"${DOMAIN_CHILD}"'''" | Select-Object displayName, gpcFileSysPath | Format-Table -AutoSize;
Write-Output "=== GPO Links ===";
Get-DomainGPO -DomainController "'''"${DC02}"'''" -Domain "'''"${DOMAIN_CHILD}"'''" | Get-DomainObjectAcl -ResolveGUIDs | Select-Object ObjectDN, ActiveDirectoryRights, SecurityIdentifier | Format-Table -AutoSize;
Write-Output "T023_OK: GPO enumeration complete"
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T023 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T023 run complete ==="
