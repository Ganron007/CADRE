#!/usr/bin/env bash
# Plan 1 — Campaign A continuation (T028, T031, T041, T043) from provisioning
set -euo pipefail

AUTO="${CADRE_AUTO_ROOT:-$HOME/attack-matrix/04-automation/linux}"
ORCH="${CADRE_ORCH:-$HOME/plan1-orchestrator.sh}"
ATTACKS="${AUTO}/attacks"
DATE=$(date -u +%Y%m%d-%H%M)

# Strip CRLF if scripts were copied from Windows host
sed -i 's/\r$//' "${AUTO}/lib/"*.sh "${ATTACKS}/"*.sh 2>/dev/null || true

# User list for password spray (child + root domain accounts)
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

run_script "CADRE-T028-NULL-${DATE}" "T028" "${ATTACKS}/WT028-null-session-enumeration.sh"
run_script "CADRE-T031-SPRAY-${DATE}" "T031" "${ATTACKS}/WT031-password-spray.sh"
run_script "CADRE-T041-XPCMD-${DATE}" "T041" "${ATTACKS}/WT041-mssql-xp-cmdshell.sh"
run_script "CADRE-T043-IMPERSON-${DATE}" "T043" "${ATTACKS}/WT043-mssql-impersonation.sh"

echo "Campaign A batch (partial) complete."
