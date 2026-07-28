#!/usr/bin/env bash
# T004-BH — BloodHound collection from ws01 (analyst_t1 context)
# Runs SharpHound.exe (pre-staged in C:\Tools\ADTools).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T004-BH-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T004-BH BloodHound collection | ${CASE_ID} | T0=${T0} ==="

CMD='
$bh = "C:\Tools\ADTools\BloodHound-master\Collectors\SharpHound.exe";
if (-not (Test-Path $bh)) { throw "SharpHound.exe not found" }
& $bh -c DCOnly -d child.cadre.local --domaincontroller dc02.child.cadre.local --ldapusername child.cadre.local\analyst_t1 --ldappassword T13r_An@lyst! --outputdirectory C:\Tools\ADTools\T004-bh-out 2>&1 | Tee-Object C:\Tools\ADTools\T004-bh-log.txt;
$z = Get-ChildItem C:\Tools\ADTools\T004-bh-out -Filter *.zip -ErrorAction SilentlyContinue | Select-Object -First 1;
if ($z) { Write-Output ("T004_OK: BloodHound zip: " + $z.FullName) } else { Write-Output "T004_INFO: no zip produced" }
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T004-BH "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T004-BH run complete ==="
