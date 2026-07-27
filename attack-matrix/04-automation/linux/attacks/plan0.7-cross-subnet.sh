#!/bin/bash
# CADRE — Plan 0.7: Cross-Subnet Connection Test
# Triggers: cadre-tcp-profile.zeek (alerts on connections crossing subnets)
# Run from provisioning VM. Requires curl or nc.
# Note: cadre-tcp-profile.zeek alerts on 192.168.77.x <-> 10.x/172.16.x connections.
# This generates traffic from provisioning VM (.60) to any non-vmnet2 address.
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — Cross-Subnet Connection Test"
start_attack "0.7-cross-subnet" "Cross-Subnet Connection"

require_tool curl

step "Generating outbound connection to non-lab IP (should trigger cadre-tcp-profile)"
run_cmd "curl -k --max-time 5 https://10.0.0.1/ 2>&1 || true"

step "Generating outbound connection to 172.16.x range"
run_cmd "curl -k --max-time 5 https://172.16.0.1/ 2>&1 || true"

step "Generating DNS query to external resolver (cross-subnet traffic)"
run_cmd "dig +short +timeout=2 example.com @8.8.8.8"

echo ""
ok "Cross-subnet test complete — check Zeek notice.log for cadre-tcp-profile"
result 0 "Cross-subnet connection test finished"
