#!/bin/bash
# Plan 1.1 M5 — run npm-threat-emulation scenario on linux01.
set -euo pipefail
_RUN_F_HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${_RUN_F_HERE}/../lib/cadre-env.sh"
# shellcheck disable=SC1091
source "${_RUN_F_HERE}/../lib/common.sh"

NPM_ROOT="${NPM_THREAT_ROOT:-/opt/npm-threat-emulation}"
LINUX01_HOST="${LINUX01:-192.168.77.40}"
LINUX01_USER="${LINUX01_SSH_USER:-vagrant}"

_run_f_scenario() {
  local n="$1"
  local label="$2"
  print_banner "Campaign F — ${label}"
  start_attack "F-$(printf '%02d' "$n")" "$label"

  local stage="/tmp/npm-f-stage-$$"
  # Stage only the files each scenario needs into a writable temp dir on linux01.
  local remote_cmd="
set -e
rm -rf '${stage}'
mkdir -p '${stage}'
cp '${NPM_ROOT}/setup_test_env.sh' '${stage}/'
cp '${NPM_ROOT}/start_mock_server.sh' '${stage}/' 2>/dev/null || true
cp '${NPM_ROOT}/mock_server.py' '${stage}/' 2>/dev/null || true
cp '${NPM_ROOT}/scenarios/scenario_${n}.sh' '${stage}/'
export NPM_THREAT_ROOT='${stage}'
cd '${stage}'
if [[ -f setup_test_env.sh ]]; then source setup_test_env.sh; fi
bash './scenario_${n}.sh'
"
  if [[ -d "${NPM_ROOT}/scenarios" ]]; then
    # Fallback: run locally if npm-threat-emulation is mounted on provisioning.
    step "Running scenario_${n}.sh locally (${NPM_ROOT})"
    bash -lc "$remote_cmd"
  else
    step "SSH ${LINUX01_USER}@${LINUX01_HOST} → scenario_${n}.sh (staged in ${stage})"
    require_tool ssh
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no \
      "${LINUX01_USER}@${LINUX01_HOST}" "$remote_cmd"
  fi
  ok "F scenario_${n} finished — check auditd / Zeek / Elastic npm-* rules"
  result 0 "${label} complete"
}
