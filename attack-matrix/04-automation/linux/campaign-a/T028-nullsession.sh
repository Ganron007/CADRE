#!/usr/bin/env bash
# T028 — Null session (Phase 0 external from .60 — expect Server 2025 block)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T028-NULL-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
DC01="${DC01:-192.168.77.10}"
echo "=== T028 | ${CASE_ID} | T0=${T0} ==="

set +e
rpcclient -U "" -N "${DC01}" -c enumdomusers 2>&1 | tee "/tmp/${CASE_ID}.log"
RC=$?
set -e

if grep -qE 'NT_STATUS_ACCESS_DENIED|NT_STATUS_LOGON_FAILURE|NT_STATUS_ACCOUNT' "/tmp/${CASE_ID}.log"; then
  echo "T028_OK"
elif grep -qiE 'user:\[' "/tmp/${CASE_ID}.log"; then
  echo "T028_FAIL: null session enumerated users (unexpected on Server 2025)" >&2
  exit 1
else
  echo "T028_FAIL: no expected deny in rpcclient output (rc=${RC})" >&2
  exit 1
fi

cadre_export "${CASE_ID}" T028 "${T0}" 192.168.77.60
echo "T0=${T0} rpcclient_rc=${RC}" | tee "/tmp/${CASE_ID}.t0"
