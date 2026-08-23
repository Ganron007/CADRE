#!/usr/bin/env bash
# Branch B ESC4 surface — Certify.exe at C:\Tools
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== ESC4 ==="
campaign_stage_run_ps1 lead_engineering 'Eng_L3ad!' campaign-a-esc-surface.ps1 cadre.local \
  '-Marker ESC4 -Pattern CADRE-ESC4 -AllTemplates'
echo "ESC4 complete"
