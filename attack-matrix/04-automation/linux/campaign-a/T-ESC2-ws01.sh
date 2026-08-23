#!/usr/bin/env bash
# Branch B ESC2 surface — Certify.exe at C:\Tools (hop PATH is empty; analyst_t1 Python is not readable)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== ESC2 ==="
campaign_stage_run_ps1 hunter_dfir 'DF1R_Hunt3r!' campaign-a-esc-surface.ps1 cadre.local \
  '-Marker ESC2 -Pattern CADRE-ESC2'
echo "ESC2 complete"
