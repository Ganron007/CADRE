#!/usr/bin/env bash
# RedStrike Campaign v3 — full execute run from provisioning (.60)
# Rule 1: ws01-exec.sh uses direct SSH (cadre-ws01-key).
set -euo pipefail

ENGAGE="${REDSTRIKE_ENGAGE:-camp-v3-20260803}"
BEACH="${REDSTRIKE_BEACHHEAD:-windows}"
LOG_DIR="${HOME}/redstrike-runs"
LOG="${LOG_DIR}/${ENGAGE}-$(date -u +%Y%m%dT%H%M%SZ).log"

export CADRE_ROOT="${CADRE_ROOT:-${HOME}/CADRE}"
export CADRE_AUTOMATION_ROOT="${CADRE_AUTOMATION_ROOT:-${CADRE_ROOT}/attack-matrix/04-automation/linux}"
export REDSTRIKE_WS01_SSH_KEY="${REDSTRIKE_WS01_SSH_KEY:-${HOME}/.ssh/cadre-ws01-key}"
export PATH="${HOME}/.local/bin:${HOME}/RedStrike/.venv/bin:${PATH}"

mkdir -p "${LOG_DIR}"

exec > >(tee -a "${LOG}") 2>&1

echo "=== RedStrike Campaign v3 full run | engage=${ENGAGE} | $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
echo "CADRE_ROOT=${CADRE_ROOT}"
echo "GRAPH=${CADRE_ROOT}/attack-matrix/Campaign/automation/campaign-graph.yaml"

if ! command -v redstrike-campaign >/dev/null 2>&1; then
  echo "redstrike-campaign not on PATH — pip install -e ~/RedStrike" >&2
  exit 1
fi

if [[ ! -f "${REDSTRIKE_WS01_SSH_KEY}" ]]; then
  echo "missing ${REDSTRIKE_WS01_SSH_KEY}" >&2
  exit 1
fi

ssh -i "${REDSTRIKE_WS01_SSH_KEY}" -o BatchMode=yes -o StrictHostKeyChecking=accept-new \
  analyst_t1@192.168.77.62 "whoami && hostname"

redstrike-campaign start --beachhead "${BEACH}" --engage "${ENGAGE}"

for gate in dcsync ticket forest persistence acl_write site_takeover; do
  redstrike-campaign approve --gate "${gate}" --engage "${ENGAGE}" --note "operator-approved full v3 run"
done

run_phase() {
  local phase="$1"
  local branch="${2:-spine}"
  local beach="${3:-${BEACH}}"
  echo "--- run phase=${phase} branch=${branch} beachhead=${beach} ---"
  redstrike-campaign run \
    --phase "${phase}" \
    --beachhead "${beach}" \
    --engage "${ENGAGE}" \
    --branch "${branch}" \
    --execute \
    --prefer-script \
    --no-stop-on-hitl \
    || echo "WARN: phase ${phase} branch ${branch} returned non-zero"
}

export PATH="/usr/bin:/bin:${PATH}"

# Spine 0–8 (windows beachhead / ws01 scripts)
run_phase "0" spine windows
run_phase "0.5-3" spine windows
run_phase "3.5-4" spine windows
run_phase "5-8" spine windows

# Branches (graph v8)
run_phase "5" A windows
run_phase "5" B windows
run_phase "8" C windows
run_phase "3-3.5" D linux
run_phase "0.5" H linux

# Post-DA stubs (spine) — recorded as SKIP/stub in orchestrator
run_phase "3.5-7" spine windows

# Streams E/F (provisioning direct)
run_phase "9" E linux
run_phase "10" F linux

redstrike-campaign status --engage "${ENGAGE}" --json | tee "${LOG_DIR}/${ENGAGE}-final-status.json"

echo "=== Run complete — log=${LOG} ==="
