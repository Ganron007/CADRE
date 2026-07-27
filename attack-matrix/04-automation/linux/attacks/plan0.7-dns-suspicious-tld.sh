#!/bin/bash
# CADRE — Plan 0.7: DNS Suspicious TLD Test
# Triggers: SID:1000028 (CADRE DNS suspicious TLD), ET:2000021 (ET DNS malicious domain), cadre-dns-anomaly.zeek
# Run from linux01 via SSH jump from provisioning VM. Requires dig.
# NOTE: Must run from linux01 — provisioning VM cannot reach DC DNS on UDP/53.

source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — DNS Suspicious TLD Test"
start_attack "0.7-dns-suspicious-tld" "DNS Suspicious TLD Queries"

require_tool dig

step "Querying domains with suspicious TLDs (.tk, .ml, .ga, .cf, .gq) from linux01"
# SSH into linux01 and run dig from there — provisioning VM can't reach DC DNS
ssh -o StrictHostKeyChecking=no vagrant@$LINUX01 "
for tld in tk ml ga cf gq; do
    dig +short +timeout=2 test-domain.\$tld @$DC01 A 2>/dev/null
    dig +short +timeout=2 malware-c2.\$tld @$DC01 A 2>/dev/null
    dig +short +timeout=2 data-exfil.\$tld @$DC01 A 2>/dev/null
done
"

echo ""
ok "Suspicious TLD simulation complete — check Suricata eve.json and Zeek notice.log"
result 0 "DNS suspicious TLD test finished"
