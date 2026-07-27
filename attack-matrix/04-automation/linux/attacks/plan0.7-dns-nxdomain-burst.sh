#!/bin/bash
# CADRE — Plan 0.7: DNS NXDOMAIN Burst Test
# Triggers: SID:1000027 (CADRE DNS NXDOMAIN burst, count 20/60s), cadre-dns-anomaly.zeek
# Run from provisioning VM. Requires dig.
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — DNS NXDOMAIN Burst Test"
start_attack "0.7-dns-nxdomain" "DNS NXDOMAIN Burst"

require_tool dig

step "Sending 30 NXDOMAIN queries in rapid burst (must exceed threshold of 20/60s)"
for i in $(seq 1 30); do
    run_cmd "dig +short +timeout=1 nonexistent-host-$RANDOM.cadre.local @$DC01 A"
done

echo ""
ok "NXDOMAIN burst complete — check Suricata eve.json and Zeek notice.log"
result 0 "DNS NXDOMAIN burst test finished"
