#!/usr/bin/env bash
# H-ASSUME — verify ws01 beachhead SSH (analyst_t1) before assume-breach spine.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== H-ASSUME beachhead check ==="
OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-h-assume.ps1 child.cadre.local)"
echo "${OUT}"
echo "${OUT}" | grep -qi analyst_t1
echo "H_ASSUME_OK"
