#!/usr/bin/env bash
# T034 — SCCM site enumeration from ws01 (analyst_t1)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T034-SCCM-ENUM-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T034 SCCM enumeration | ${CASE_ID} | T0=${T0} ==="

SITE_SERVER="${SITE_SERVER:-mbr01.cadre.local}"

CMD='
$w = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe";
$ErrorActionPreference = "Stop";
$reg = Get-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\CCMSetup" -ErrorAction SilentlyContinue;
if ($reg) { Write-Output "T034_OK: SCCM client setup found"; Write-Output $reg } else { Write-Output "T034_INFO: SCCM client setup not found on ws01" }
Write-Output "T034_OK: SCCM site check complete"
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T034 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T034 run complete ==="
