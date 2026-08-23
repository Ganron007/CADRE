#!/usr/bin/env bash
# Attacker operator: RedStrike on Kali, Windows beachhead via ws01-exec.
set -uo pipefail
export CADRE_ROOT="${CADRE_ROOT:-$HOME/CADRE}"
export PATH="$CADRE_ROOT/tools/red-strike/.venv/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export REDSTRIKE_UNGATED=1
export REDSTRIKE_PREFER_SCRIPT=1
ENGAGE="${REDSTRIKE_ENGAGE:-mcp-llm-20260822T105200Z}"
SCOPE="$CADRE_ROOT/attack-matrix/Campaign/automation/scope.cadre.example.yaml"
GRAPH="$CADRE_ROOT/attack-matrix/Campaign/automation/campaign-graph.yaml"
SEED="$CADRE_ROOT/attack-matrix/Campaign/automation/lab-seed-creds.json"
LOG="$HOME/redstrike-runs/${ENGAGE}.console"
RS="$CADRE_ROOT/tools/red-strike/.venv/bin/redstrike-campaign"
mkdir -p "$(dirname "$LOG")"
exec > >(stdbuf -oL tee -a "$LOG") 2>&1

ts() { date -u +%Y-%m-%dT%H:%M:%S.%3NZ; }
step() { printf '\n======== %s %s ========\n' "$(ts)" "$*"; }

export REDSTRIKE_AUTOMATION_ROOT="$CADRE_ROOT/attack-matrix/04-automation/linux"
COMMON=(
  --engage "$ENGAGE"
  --beachhead windows
  --operator provisioning
  --branch all
  --profile autonomous
  --ungated --scope "$SCOPE"
  --graph "$GRAPH"
  --seed "$SEED"
  --automation-root "$REDSTRIKE_AUTOMATION_ROOT"
  --json
)

step "RedStrike start ledger"
"$RS" start "${COMMON[@]}" || true

step "RedStrike EXECUTE ws01 scripts T002 T035A T035-CREDS"
"$RS" run "${COMMON[@]}" --prefer-script --execute --no-stop-on-hitl --no-preflight \
  --nodes T002,T035A-WINLOGON,T035-CREDS || echo "RS_SPINE_RC=$?"

step "RedStrike EXECUTE T004-MBR01-BH"
"$RS" run "${COMMON[@]}" --prefer-script --execute --no-stop-on-hitl --no-preflight \
  --nodes T004-MBR01-BH || echo "RS_BH_RC=$?"

step "attacker pass $(ts)"
