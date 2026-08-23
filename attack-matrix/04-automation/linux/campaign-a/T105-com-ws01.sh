#!/usr/bin/env bash
# T105 — COM hijack persistence (WT105) via SYSTEM channel on mbr01
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== T105 COM hijack ==="
OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' wt105-com-run.ps1)"
printf '%s\n' "${OUT}"
campaign_require_ok T105 "${OUT}" 'COM_DLL|WT105_DONE|T105_OK'
echo "T105 complete"
