#!/usr/bin/env bash
# T035C — RDP prereqs (3.5C) — Rule 3: port + SMB auth, not full mstsc
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== T035C RDP prereqs ==="
campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' wt035c-rdp-prereq.ps1
echo "T035C complete"
