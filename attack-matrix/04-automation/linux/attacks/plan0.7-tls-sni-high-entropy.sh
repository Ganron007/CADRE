#!/bin/bash
# CADRE — Plan 0.7: TLS High Entropy SNI Test
# Triggers: ET:2000032 (ET TLS SNI High Entropy)
# Run from provisioning VM. Requires curl with --resolve.
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — TLS High Entropy SNI Test"
start_attack "0.7-tls-sni" "TLS High Entropy SNI"

require_tool curl

step "Connecting with 20+ char alphanumeric SNI labels (mbr01 — lab HTTPS endpoint)"
for label in a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6 aaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbb; do
    run_cmd "curl -k --resolve ${label}.evil.com:443:$MBR01 --max-time 5 https://${label}.evil.com/ 2>&1 || true"
done

step "Connecting with random high-entropy domain SNI"
rand_domain=$(cat /dev/urandom | tr -dc 'a-z0-9' | head -c24)
run_cmd "curl -k --resolve ${rand_domain}.xyz:443:$MBR01 --max-time 5 https://${rand_domain}.xyz/ 2>&1 || true"

echo ""
ok "High entropy SNI test complete — check Suricata eve.json for ET:2000032"
result 0 "TLS high entropy SNI test finished"
