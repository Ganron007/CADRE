#!/usr/bin/env bash
# T106 — IFEO persistence (WT106)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== T106 IFEO ==="
OUT="$(campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' wt106-ifeo-run.ps1)"
printf '%s\n' "${OUT}"
campaign_require_ok T106 "${OUT}" 'IFEO_DEBUGGER_SET|WT106_DONE|T106_OK'
echo "T106 complete"
