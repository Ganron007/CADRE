#!/bin/bash
# CADRE — WT#004 Unconstrained Delegation
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#004 — Unconstrained Delegation"
start_attack "004" "Unconstrained Delegation"

require_tool impacket-findDelegation
require_env DC01 "DC01"
require_env ATTACK_USER "ATTACK_USER"
require_env ATTACK_PASS "ATTACK_PASS"
require_env DOMAIN_ROOT "DOMAIN_ROOT"

step "Step 1: Enumerate unconstrained delegation trust"
run_cmd "impacket-findDelegation \"$DOMAIN_ROOT/$ATTACK_USER:'$ATTACK_PASS'\""

# NOTE: Full exploitation requires Rubeus on mbr01 (Windows).
# From mbr01: dump LSASS for TGTs, or coerce DC02 to connect then capture TGT.

result $? "Unconstrained delegation enumeration completed"
