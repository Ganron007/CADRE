#!/usr/bin/env bash
# Branch B ESC7 / ESC9 surface — Certify.exe at C:\Tools
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== ESC7/ESC9 surface ==="
campaign_stage_run_ps1 hunter_dfir 'DF1R_Hunt3r!' campaign-a-esc-surface.ps1 cadre.local \
  '-Marker ESC7_ESC9 -Pattern "CADRE-ESC7|CADRE-ESC9"'
echo "ESC7/9 complete"
