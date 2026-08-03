#!/usr/bin/env bash
# RedStrike Campaign v3 — FULL graph coverage harness (graph v9+)
# Operator mode: provisioning (hybrid) — orchestrator on .60 → SSH/ws01-exec to ws01.
# Pair with native ws01: 04-automation/windows/redstrike-campaign-v3-ws01-native.ps1
# Rule 1 hybrid: tools execute on ws01 via ws01-exec; process lives on provisioning.
# Rule 4: Branch H = provisioning attacker, ws01 target.
set -euo pipefail

ENGAGE="${REDSTRIKE_ENGAGE:-camp-v3-full-$(date -u +%Y%m%d)}"
BEACH="${REDSTRIKE_BEACHHEAD:-windows}"
OPERATOR="${REDSTRIKE_OPERATOR:-provisioning}"
LOG_DIR="${HOME}/redstrike-runs"
LOG="${LOG_DIR}/${ENGAGE}-$(date -u +%Y%m%dT%H%M%SZ).log"

export CADRE_ROOT="${CADRE_ROOT:-${HOME}/CADRE}"
export CADRE_AUTOMATION_ROOT="${CADRE_AUTOMATION_ROOT:-${CADRE_ROOT}/attack-matrix/04-automation/linux}"
export REDSTRIKE_WS01_SSH_KEY="${REDSTRIKE_WS01_SSH_KEY:-${HOME}/.ssh/cadre-ws01-key}"
export REDSTRIKE_SEED="${REDSTRIKE_SEED:-${CADRE_ROOT}/attack-matrix/Campaign/automation/lab-seed-creds.json}"
export REDSTRIKE_OPERATOR="${OPERATOR}"
export PATH="/usr/bin:/bin:${HOME}/.local/bin:${HOME}/RedStrike/.venv/bin:${PATH}"

mkdir -p "${LOG_DIR}"
exec > >(tee -a "${LOG}") 2>&1

echo "=== RedStrike FULL CampaignOrchestrator run | engage=${ENGAGE} | operator=${OPERATOR} | $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
echo "CADRE_ROOT=${CADRE_ROOT}"
echo "GRAPH=${CADRE_ROOT}/attack-matrix/Campaign/automation/campaign-graph.yaml"
echo "SEED=${REDSTRIKE_SEED}"

command -v redstrike-campaign >/dev/null 2>&1 || {
  echo "redstrike-campaign not on PATH — pip install -e ~/RedStrike" >&2
  exit 1
}
[[ -f "${REDSTRIKE_WS01_SSH_KEY}" ]] || {
  echo "missing ${REDSTRIKE_WS01_SSH_KEY}" >&2
  exit 1
}

ssh -i "${REDSTRIKE_WS01_SSH_KEY}" -o BatchMode=yes -o StrictHostKeyChecking=accept-new \
  analyst_t1@192.168.77.62 "whoami && hostname"

redstrike-campaign start --beachhead "${BEACH}" --operator "${OPERATOR}" --engage "${ENGAGE}"

for gate in dcsync ticket forest persistence acl_write site_takeover; do
  redstrike-campaign approve --gate "${gate}" --engage "${ENGAGE}" --operator "${OPERATOR}" --note "operator-approved full v9 harness"
done

run_phase() {
  local phase="$1"
  local branch="${2:-spine}"
  local beach="${3:-${BEACH}}"
  echo "--- run phase=${phase} branch=${branch} beachhead=${beach} operator=${OPERATOR} ---"
  redstrike-campaign run \
    --phase "${phase}" \
    --beachhead "${beach}" \
    --operator "${OPERATOR}" \
    --engage "${ENGAGE}" \
    --branch "${branch}" \
    --execute \
    --prefer-script \
    --no-stop-on-hitl \
    || echo "WARN: phase ${phase} branch ${branch} returned non-zero"
}

# ----- Spine -----
run_phase "0" spine linux          # T028
run_phase "0.5-3" spine windows    # H-ASSUME + T003/T002/T041/T043
run_phase "3.5-4" spine windows    # creds, BH, T035C, …
run_phase "5-8" spine windows      # coerce, tickets, forest, Post-DA wired nodes

# ----- Branch A (ACL) — phase 4 + 5 -----
run_phase "4-5" A windows

# ----- Branch B (ADCS) -----
run_phase "5" B windows

# ----- Branch C (SCCM) -----
run_phase "8" C windows

# ----- Branch D (Linux) -----
run_phase "3-3.5" D windows        # T040/T044 via ws01
run_phase "3.5" D linux            # T045–T048 via linux01-exec

# ----- Branch G (spray + RBCD) -----
run_phase "1" G linux              # T031 spray
run_phase "5" G windows            # T007 RBCD

# ----- Branch H (initial access) -----
run_phase "0.5" H linux

# ----- Streams E / F -----
run_phase "9" E linux
run_phase "10" F linux

redstrike-campaign status --engage "${ENGAGE}" --json | tee "${LOG_DIR}/${ENGAGE}-final-status.json"

echo "=== FULL run complete — log=${LOG} ==="
echo "Deferred stubs (expected SKIP): T100 T103 T104 T107 T108 T-SQL-AI WT093"
