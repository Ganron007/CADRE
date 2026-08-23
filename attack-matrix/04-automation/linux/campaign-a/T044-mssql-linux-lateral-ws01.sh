#!/usr/bin/env bash
# T044 — MSSQL linked-server lateral to linux01 from ws01
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== T044 MSSQL → linux01 linked hop ==="
campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-t044-mssql-linux.ps1
echo "T044 complete"
