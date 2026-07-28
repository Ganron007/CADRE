#!/bin/bash
# CADRE — Plan 0.7: DNS IP Literal Query Test
# Triggers: SID:1000029 (CADRE DNS IP literal — matches X.X.X.X.in-addr.arpa format)
# Run from linux01 via SSH jump from provisioning VM. Requires dig.
# NOTE: Must run from linux01 — provisioning VM cannot reach DC DNS on UDP/53.

source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — DNS IP Literal Query Test"
start_attack "0.7-dns-ip-literal" "DNS IP Literal Queries"

require_tool dig

step "Querying DNS with IP literal format (PTR lookups for X.X.X.X.in-addr.arpa)"
# SSH into linux01 and run dig from there — provisioning VM can't reach DC DNS
ssh -o StrictHostKeyChecking=no vagrant@$LINUX01 "
for ip in 8.8.8.8 192.168.77.10 10.0.0.1 172.16.0.1; do
    dig +short +timeout=1 \$ip.in-addr.arpa @8.8.8.8 PTR 2>/dev/null
done
"

echo ""
ok "IP literal DNS simulation complete — check Suricata eve.json for SID:1000029"
result 0 "DNS IP literal test finished"
