#!/usr/bin/env bash
# T098 — Golden gMSA prereqs
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== T098 Golden gMSA prereqs ==="
PY="${SCRIPT_DIR}/../windows/wt098-golden-gmsa.py"
if [[ -f "${PY}" ]] && python3 -c 'import ldap3' 2>/dev/null; then
  python3 "${PY}" || true
fi
OUT="$(campaign_stage_run_ps1 chief_command 'C0mm@nd_Ch1ef!' campaign-a-t098-gmsa.ps1 cadre.local)"
printf '%s\n' "${OUT}"
campaign_require_ok T098 "${OUT}" 'GMSA\||T098_PREREQ_DONE'
echo "T098 complete"
