#!/usr/bin/env bash
# T043-alt — Local Privilege Escalation alternatives staged from ws01 to mbr01.
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T043-ALT-LPE-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
MBR01="${MBR01:-192.168.77.22}"
echo "=== T043-ALT | ${CASE_ID} | T0=${T0} ==="

echo "[*] Ensuring LPE binaries on ws01 (beachhead) ..."
ws01_ensure_lpe_binaries
campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t043-lpe-alternatives.ps1 child.cadre.local \
  "-Target ${MBR01} -TargetFqdn mbr01.child.cadre.local -Username 'child.cadre.local\\analyst_t1' -Password 'T13r_An@lyst!' -ToolSource 'C:\\Tools\\ADTools'"

cadre_export "${CASE_ID}" T043-ALT "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T043-ALT complete ==="
