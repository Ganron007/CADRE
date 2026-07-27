#!/usr/bin/env bash
# Re-run fixed Campaign A attacks (T031, T041, T043) only
set -euo pipefail
AUTO="${CADRE_AUTO_ROOT:-$HOME/attack-matrix/04-automation/linux}"
ORCH="${CADRE_ORCH:-$HOME/plan1-orchestrator.sh}"
ATTACKS="${AUTO}/attacks"
DATE=$(date -u +%Y%m%d-r3)

sed -i 's/\r$//' "${AUTO}/lib/"*.sh "${ATTACKS}/"*.sh 2>/dev/null || true

cat > /tmp/users.txt <<'USERS'
intern_blue
analyst_t2
svc_mssql
analyst_t1
chief_command
analyst_dfir
analyst_cloud
USERS

run_script() {
  local case_id="$1" t="$2" script="$3"
  local base
  base=$(basename "$script")
  bash "$ORCH" "$case_id" "$t" -- bash -c "cd '${ATTACKS}' && bash './${base}'"
}

run_script "CADRE-T041-XPCMD-${DATE}" "T041" "${ATTACKS}/WT041-mssql-xp-cmdshell.sh"
run_script "CADRE-T043-IMPERSON-${DATE}" "T043" "${ATTACKS}/WT043-mssql-impersonation.sh"
