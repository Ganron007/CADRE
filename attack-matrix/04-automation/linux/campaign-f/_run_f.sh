#!/bin/bash
# Plan 1.1 M5 — run npm-threat-emulation scenario on linux01 (or local if already there).
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
  local remote_cmd="cd '${NPM_ROOT}' && if [[ -f setup_test_env.sh ]]; then source setup_test_env.sh; fi && bash './scenarios/scenario_${n}.sh'"
  if [[ -d "${NPM_ROOT}/scenarios" ]]; then
    step "Running scenario_${n}.sh locally (${NPM_ROOT})"
    bash -lc "$remote_cmd"
  else
    step "SSH ${LINUX01_USER}@${LINUX01_HOST} → scenario_${n}.sh"
    require_tool ssh
    ssh -o BatchMode=yes -o StrictHostKeyChecking=no \
      "${LINUX01_USER}@${LINUX01_HOST}" "$remote_cmd"
  fi
  ok "F scenario_${n} finished — check auditd / Zeek / Elastic npm-* rules"
  result 0 "${label} complete"
}
