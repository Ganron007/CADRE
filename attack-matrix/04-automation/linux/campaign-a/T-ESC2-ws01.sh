#!/usr/bin/env bash
# Branch B ESC2 — Any Purpose template (WT051/ESC2) via certipy on ws01 if present
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== ESC2 ==="
ws01_exec_as hunter_dfir 'DF1R_Hunt3r!' '
$ErrorActionPreference="Continue"
$c = Get-Command certipy -ErrorAction SilentlyContinue
if (-not $c) { $c = Get-ChildItem "C:\Python*\Scripts\certipy.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 }
if (-not $c) { Write-Output "ESC2_CERTIPY_MISSING"; exit 0 }
& certipy find -u hunter_dfir@cadre.local -p "DF1R_Hunt3r!" -dc-ip 192.168.77.10 -vulnerable 2>&1 | Select-String -Pattern "ESC2|CADRE-ESC2" | ForEach-Object { $_.Line }
Write-Output "ESC2_SURFACE_DONE"
' 'cadre.local'
echo "ESC2 complete"
