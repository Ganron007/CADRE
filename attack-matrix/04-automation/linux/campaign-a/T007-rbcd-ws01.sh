#!/usr/bin/env bash
# T007 — RBCD standalone from ws01 (analyst_t1) using PowerView
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T007-RBCD-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T007 RBCD standalone | ${CASE_ID} | T0=${T0} ==="

DC02="${DC02:-dc02.child.cadre.local}"
DOMAIN_CHILD="${DOMAIN_CHILD:-child.cadre.local}"
TARGET_COMPUTER="${TARGET_COMPUTER:-MBR01}"

CMD='
$pv = "C:\Tools\cadre-attack\PowerView.ps1";
if (-not (Test-Path $pv)) { throw "PowerView.ps1 not found" }
. $pv;
$ErrorActionPreference = "Stop";
$c = Get-DomainComputer -Identity "'''"${TARGET_COMPUTER}"'''" -DomainController "'''"${DC02}"'''" -Domain "'''"${DOMAIN_CHILD}"'''";
  $prop = $c | Select-Object -ExpandProperty 'msDS-AllowedToActOnBehalfOfOtherIdentity' -ErrorAction SilentlyContinue
  Write-Output ("msDS-AllowedToActOnBehalfOfOtherIdentity present: " + ($prop -ne $null));
Write-Output "T007_OK: RBCD check complete"
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T007 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T007 run complete ==="
