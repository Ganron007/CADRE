#!/usr/bin/env bash
# T099 — Golden dMSA / BadSuccessor prereqs (WT099)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== T099 dMSA prereqs ==="
OUT="$(campaign_stage_run_ps1 chief_command 'C0mm@nd_Ch1ef!' wt099-dmsa-prereq.ps1 cadre.local)"
printf '%s\n' "${OUT}"
campaign_require_ok T099 "${OUT}" 'T099_OK|dMSA|BadSuccessor|msDS-DelegatedManagedServiceAccount'
echo "T099 complete"
