#!/bin/bash
# CADRE — WT#012 Diamond Ticket
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#012 — Diamond Ticket"
start_attack "012" "Diamond Ticket"

step "Step 1: Note platform limitation"
run_cmd "echo 'WT#012 requires Rubeus on a Windows VM — see walkthrough doc'"

step "Step 2: Display alternative approach"
run_cmd "echo 'On Linux: Use impacket-ticketer with modified PAC options (limited support)'"

step "Step 3: Reference prerequisite"
run_cmd "echo 'Run WT#009 DCSync first to obtain krbtgt hash and domain SID for Rubeus'"

result $? "Diamond Ticket guidance displayed"
