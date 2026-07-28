#!/usr/bin/env bash
# T004-BH — BloodHound collection from ws01 (analyst_t1 context)
# MANUAL GATE: SharpHound cannot bind to LDAP from a WinRM-impersonated session.
# Run the command below as analyst_t1 via RDP or runas, then re-run this script to record T0.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T004-BH-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T004-BH BloodHound collection | ${CASE_ID} | T0=${T0} ==="

echo
echo "MANUAL STEP REQUIRED (WinRM cannot bind to LDAP for SharpHound):"
echo "On ws01, run as child.cadre.local\\analyst_t1 (RDP or runas):"
echo
echo '  mkdir C:\Tools\ADTools\T004-bh-out'
echo '  C:\Tools\ADTools\BloodHound-master\Collectors\SharpHound.exe -c DCOnly -d child.cadre.local -domaincontroller dc02.child.cadre.local -outputdirectory C:\Tools\ADTools\T004-bh-out'
echo
echo "Credentials: child.cadre.local\\analyst_t1 / T13r_An@lyst!"
echo

CMD='
$out = "C:\Tools\ADTools\T004-bh-out";
if (-not (Test-Path $out)) { New-Item -ItemType Directory -Path $out -Force | Out-Null }
$z = Get-ChildItem $out -Filter *.zip -ErrorAction SilentlyContinue | Select-Object -First 1;
if ($z) { Write-Output ("T004_OK: BloodHound zip found: " + $z.FullName) } else { Write-Output ("T004_INFO: no zip found in $out — run the manual step first.") }
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T004-BH "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T004-BH run complete ==="
