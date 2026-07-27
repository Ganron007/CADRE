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

cadre_export "${CASE_ID}" T028 "${T0}" 192.168.77.60
echo "T0=${T0} rpcclient_rc=${RC}" | tee "/tmp/${CASE_ID}.t0"
