#!/bin/bash
# CADRE — WT#005 Constrained Delegation (Protocol Transition)
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#005 — Constrained Delegation (Protocol Transition)"
start_attack "005" "Constrained Delegation (Protocol Transition)"

require_tool impacket-findDelegation
require_env DC03 "DC03"
require_env DOMAIN_EXT "DOMAIN_EXT"

step "Step 1: Enumerate constrained delegation (including protocol transition)"
run_cmd "impacket-findDelegation \"$DOMAIN_EXT/analyst_osint:'0S1NT_An@lyst!'\" -dc-ip $DC03"

# NOTE: Full exploitation (S4U2Self+S4U2Proxy) requires Rubeus on Windows.
# Protocol transition allows S4U2Self without TGT — use Rubeus s4u /impersonateuser.

result $? "Constrained delegation (protocol transition) enumeration completed"
