#!/usr/bin/env bash
# T101 — Lateral movement: WinRS/PSRemoting from ws01 to mbr01 as analyst_t1.
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T101-WINRS-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TARGET="${TARGET:-mbr01}"
TARGET_IP="${TARGET_IP:-192.168.77.22}"

echo "=== T101 | ${CASE_ID} | T0=${T0} ==="

OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t101-winrs-pivot.ps1 child.cadre.local \
  "-Source ws01 -Target ${TARGET} -TargetIP ${TARGET_IP} -Username 'child.cadre.local\\analyst_t1' -Password 'T13r_An@lyst!'")"
printf '%s\n' "${OUT}"
campaign_require_ok T101 "${OUT}" 'T101_OK|WINRS_OK'

cadre_export "${CASE_ID}" T101 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T101 run complete ==="
