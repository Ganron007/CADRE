#!/usr/bin/env bash
# CADRE-integrated ungated API on provisioning loopback.
# Cursor MCP reaches this via SSH tunnel: 127.0.0.1:8890 -> 127.0.0.1:8890 on this host.
set -euo pipefail
CADRE_ROOT="${CADRE_ROOT:-$HOME/CADRE}"
ENGINE="${ENGINE:-$CADRE_ROOT/tools/red-strike}"
VENV="${VENV:-$ENGINE/.venv}"
SCOPE="${REDSTRIKE_SCOPE:-$CADRE_ROOT/attack-matrix/Campaign/automation/scope.cadre.example.yaml}"
LOG="${REDSTRIKE_API_LOG:-$HOME/redstrike-runs/api-ungated.log}"

export CADRE_ROOT
export REDSTRIKE_UNGATED=1
export REDSTRIKE_PREFER_SCRIPT=1
export REDSTRIKE_GRAPH="${REDSTRIKE_GRAPH:-$CADRE_ROOT/attack-matrix/Campaign/automation/campaign-graph.yaml}"
export REDSTRIKE_SEED="${REDSTRIKE_SEED:-$CADRE_ROOT/attack-matrix/Campaign/automation/lab-seed-creds.json}"
export REDSTRIKE_AUTOMATION_ROOT="${REDSTRIKE_AUTOMATION_ROOT:-$CADRE_ROOT/attack-matrix/04-automation/linux}"
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"

mkdir -p "$(dirname "$LOG")"
if [ ! -x "$VENV/bin/redstrike-api" ]; then
  echo "missing $VENV/bin/redstrike-api" >&2
  exit 1
fi
if [ ! -f "$SCOPE" ]; then
  echo "missing scope $SCOPE" >&2
  exit 1
fi

if ss -ltn | grep -q ':8890 '; then
  echo "port 8890 already listening"
  exit 0
fi

nohup "$VENV/bin/redstrike-api" \
  --ungated --scope "$SCOPE" \
  --host 127.0.0.1 --port 8890 \
  >"$LOG" 2>&1 &
echo $! >"$HOME/redstrike-runs/api-ungated.pid"
sleep 1
echo "api pid=$(cat "$HOME/redstrike-runs/api-ungated.pid") log=$LOG"
