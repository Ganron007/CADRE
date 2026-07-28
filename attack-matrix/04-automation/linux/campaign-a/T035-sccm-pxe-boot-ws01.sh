#!/usr/bin/env bash
# T035 — SCCM PXE boot abuse check from ws01 (analyst_t1)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T035-SCCM-PXE-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T035 SCCM PXE check | ${CASE_ID} | T0=${T0} ==="

CMD='
$ErrorActionPreference = "Stop";
$pxe = Get-WindowsFeature -Name WDS-Transport -ErrorAction SilentlyContinue;
if ($pxe -and $pxe.Installed) { Write-Output "T035_OK: WDS/PXE role installed" } else { Write-Output "T035_INFO: WDS/PXE role not present" }
Write-Output "T035_OK: PXE check complete"
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T035 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T035 run complete ==="
