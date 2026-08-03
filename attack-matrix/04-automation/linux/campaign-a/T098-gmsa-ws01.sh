#!/usr/bin/env bash
# T098 — Golden gMSA prereqs (WT098) — extract KDS id + gMSA SID + ManagedPasswordId
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== T098 Golden gMSA prereqs ==="
PY="${SCRIPT_DIR}/../windows/wt098-golden-gmsa.py"
if [[ -f "${PY}" ]] && python3 -c 'import ldap3' 2>/dev/null; then
  python3 "${PY}" || true
fi
# Surface check via LDAP from ws01 as DA
ws01_exec_as chief_command 'C0mm@nd_Ch1ef!' '
$ErrorActionPreference="Continue"
$g = Get-ADServiceAccount -Filter * -Server dc01.cadre.local -Properties msDS-ManagedPasswordId,SID -ErrorAction SilentlyContinue
if ($g) { $g | ForEach-Object { Write-Output ("GMSA|" + $_.Name + "|" + $_.SID) } } else { Write-Output "GMSA_ENUM_ALT" }
Write-Output "T098_PREREQ_DONE"
' 'cadre.local'
echo "T098 complete"
