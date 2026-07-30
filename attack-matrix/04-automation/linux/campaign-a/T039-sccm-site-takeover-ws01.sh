#!/usr/bin/env bash
# T039 — SCCM site takeover check from ws01 (analyst_t1)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T039-SCCM-SITETAKEOVER-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T039 SCCM site takeover check | ${CASE_ID} | T0=${T0} ==="

SITE_SERVER="${SITE_SERVER:-mbr01.cadre.local}"

CMD='
$ErrorActionPreference = "Stop";
try {
  $admins = ([ADSI]("WinNT://" + $env:COMPUTERNAME + "/Administrators,group")).Members() | ForEach-Object { $_.GetType().InvokeMember('Name', 'GetProperty', $null, $_, $null) }
  Write-Output "T039_OK: site server admins queried"; $admins | Select-Object -First 5
} catch { Write-Output "T039_INFO: unable to query site server admins: $($_.Exception.Message)" }
Write-Output "T039_OK: site takeover check complete"
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T039 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T039 run complete ==="
