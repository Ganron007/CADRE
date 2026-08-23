#!/usr/bin/env bash
# T004-BH — BloodHound zip check from ws01
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
CASE_ID="CADRE-T004-BH-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T004-BH BloodHound collection | ${CASE_ID} | T0=${T0} ==="
OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t004-bh.ps1)"
printf '%s\n' "${OUT}"
if ! printf '%s' "${OUT}" | grep -q 'T004_BH_OK'; then
  echo "T004-BH needs a SharpHound zip on ws01 (run collector as analyst_t1, then re-run)." >&2
  exit 1
fi
cadre_export "${CASE_ID}" T004-BH "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T004-BH run complete ==="
