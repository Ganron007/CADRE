#!/bin/bash
# CADRE — WT081 — Outbound Anomaly / C2 Callback
# Triggers: Z1 cadre-outbound (Zeek internal → unknown external)
# Run from linux01 or provisioning VM.
source ../linux/lib/cadre-env.sh 2>/dev/null || source ./lib/cadre-env.sh 2>/dev/null
print_banner "WT081 — Outbound Anomaly (C2 Callback Simulation)"
start_attack "081" "Outbound Anomaly"

step "Making outbound connections to non-lab IPs (simulates C2 callback)"
run_cmd "curl -s --connect-timeout 5 http://203.0.113.1/ || true"
run_cmd "curl -s --connect-timeout 5 http://10.0.0.1/ || true"
run_cmd "curl -s --connect-timeout 5 http://172.16.0.1/ || true"

step "DNS query to external-style domain"
run_cmd "host nonexi$tent-c2-domain.com 192.168.77.10"

echo ""
ok "Outbound anomaly simulation complete — check Zeek notice.log for cadre-outbound alerts"
result 0 "WT081 completed"
