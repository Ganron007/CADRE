#!/bin/bash
# CADRE — Plan 0.7: TLS Certificate Chain Length Test
# Triggers: SID:1000014 (CADRE TLS cert chain length > 5)
# Run from provisioning VM. Requires curl.
# Note: SID:1000014 fires when tls.cert_chain_len > 5. Standard servers have 2-3 certs.
# To trigger this, we'd need a server with a deeply nested cert chain, which is rare.
# This script verifies the rule logic by connecting to various endpoints and logging chain lengths.
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — TLS Certificate Chain Length Test"
start_attack "0.7-tls-certchain" "TLS Certificate Chain Length > 5"

require_tool curl

step "Connecting to DC01 — check cert chain length in Zeek ssl.log"
run_cmd "curl -k -v https://$DC01/ 2>&1 | grep -i 'certificate' || true"

step "Connecting to DC02 — check cert chain length in Zeek ssl.log"
run_cmd "curl -k -v https://$DC02/ 2>&1 | grep -i 'certificate' || true"

step "Connecting to MBR01 — check cert chain length in Zeek ssl.log"
run_cmd "curl -k -v https://$MBR01/ 2>&1 | grep -i 'certificate' || true"

echo ""
ok "TLS cert chain test complete — rule SID:1000014 fires when chain > 5 certs"
ok "Lab servers typically have 2-3 cert chains — this rule may not fire in lab"
ok "Check Zeek ssl.log for tls_server.cert_chain_len fields"
result 0 "TLS cert chain test finished"
