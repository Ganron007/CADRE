#!/usr/bin/env bash
# CADRE-integrated live campaign: all graph methods in scope, UTC activity journal.
# Usage: bash redstrike-llm-run.sh [--windows|--linux|--both]
set -euo pipefail
CADRE_ROOT="${CADRE_ROOT:-$HOME/CADRE}"
ENGINE="${ENGINE:-$CADRE_ROOT/tools/red-strike}"
VENV="${VENV:-$ENGINE/.venv}"
SCOPE="${REDSTRIKE_SCOPE:-$CADRE_ROOT/attack-matrix/Campaign/automation/scope.cadre.example.yaml}"
ENGAGE="${REDSTRIKE_ENGAGE:-llm-$(date -u +%Y%m%dT%H%M%SZ)}"
WHICH="${1:---both}"
ART="$CADRE_ROOT/attack-matrix/Campaign/artifacts/redstrike-activity"
mkdir -p "$ART" "$HOME/redstrike-runs"

export CADRE_ROOT
export REDSTRIKE_UNGATED=1
export REDSTRIKE_PREFER_SCRIPT=1
export REDSTRIKE_GRAPH="${REDSTRIKE_GRAPH:-$CADRE_ROOT/attack-matrix/Campaign/automation/campaign-graph.yaml}"
export REDSTRIKE_SEED="${REDSTRIKE_SEED:-$CADRE_ROOT/attack-matrix/Campaign/automation/lab-seed-creds.json}"
export REDSTRIKE_AUTOMATION_ROOT="${REDSTRIKE_AUTOMATION_ROOT:-$CADRE_ROOT/attack-matrix/04-automation/linux}"
export REDSTRIKE_ACTIVITY_LOG="$ART/${ENGAGE}.jsonl"
export PATH="$HOME/.local/bin:$VENV/bin:/usr/local/bin:/usr/bin:$PATH"

echo "T0_UTC=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ) engage=$ENGAGE activity=$REDSTRIKE_ACTIVITY_LOG"

run_one() {
  local beach="$1"
  local out="$HOME/redstrike-runs/${ENGAGE}-${beach}.json"
  echo "T_START_${beach}=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)"
  "$VENV/bin/redstrike-campaign" start \
    --engage "$ENGAGE" \
    --beachhead "$beach" \
    --operator provisioning \
    --branch all \
    --profile autonomous \
    --ungated --scope "$SCOPE" \
    --json >"$HOME/redstrike-runs/${ENGAGE}-${beach}-start.json" || true
  "$VENV/bin/redstrike-campaign" run \
    --engage "$ENGAGE" \
    --beachhead "$beach" \
    --operator provisioning \
    --phase 0-10 \
    --branch all \
    --profile autonomous \
    --ungated --scope "$SCOPE" \
    --prefer-script \
    --execute --no-stop-on-hitl \
    --json >"$out"
  echo "T_END_${beach}=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ) out=$out"
}

case "$WHICH" in
  --windows) run_one windows ;;
  --linux) run_one linux ;;
  --both)
    run_one windows
    run_one linux
    ;;
  *)
    echo "usage: $0 [--windows|--linux|--both]" >&2
    exit 2
    ;;
esac

echo "T1_UTC=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)"
echo "ACTIVITY_JSONL=$REDSTRIKE_ACTIVITY_LOG"
echo "ACTIVITY_LOG=${REDSTRIKE_ACTIVITY_LOG%.jsonl}.log"
