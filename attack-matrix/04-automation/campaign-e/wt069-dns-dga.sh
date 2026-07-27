#!/bin/bash
# CADRE — WT069 — DNS DGA Simulation
# Triggers: SID:1000025 (CADRE DNS high entropy), ET:2000022 (ET DGA), cadre-dns-anomaly.zeek
# Run from provisioning VM. Requires dig.
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — DNS DGA Query Test"
start_attack "0.7-dns-dga" "DNS DGA Simulation"

require_tool dig

step "Generating 25 random DGA-style domain queries against DC01"
for i in $(seq 1 25); do
    label=$(cat /dev/urandom | tr -dc 'a-z0-9' | head -c${RANDOM:0:1}12)
    run_cmd "dig +short +timeout=2 $label.example.com @$DC01 A"
done

step "Generating 15 high-entropy labels (15+ chars) against DC02"
for i in $(seq 1 15); do
    label=$(cat /dev/urandom | tr -dc 'a-z0-9' | head -c16)
    run_cmd "dig +short +timeout=2 $label.malware-c2.evil @$DC02 A"
done

echo ""
ok "DGA simulation complete — check Suricata eve.json and Zeek notice.log"
result 0 "DGA DNS test finished"

