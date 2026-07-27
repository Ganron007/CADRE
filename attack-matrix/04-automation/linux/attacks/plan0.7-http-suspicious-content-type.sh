#!/bin/bash
# CADRE — Plan 0.7: HTTP Suspicious Content-Type Test
# Triggers: ET:2000072 (ET HTTP Suspicious Content-Type)
# Run from provisioning VM. Requires curl.
# Note: This triggers on RESPONSE Content-Type, so target must return x-msdownload/octet-stream.
# Workaround: upload a file via POST with the suspicious Content-Type header.
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — HTTP Suspicious Content-Type Test"
start_attack "0.7-http-contenttype" "HTTP Suspicious Content-Type"

require_tool curl

step "Sending POST with application/x-msdownload Content-Type"
run_cmd "curl -X POST -H 'Content-Type: application/x-msdownload' -d 'FAKE_MALWARE_PAYLOAD' http://$DC01/ -o /dev/null -s -w '%{http_code}' 2>&1 || true"

step "Sending POST with application/octet-stream Content-Type"
run_cmd "curl -X POST -H 'Content-Type: application/octet-stream' -d 'FAKE_BINARY_DATA' http://$DC01/ -o /dev/null -s -w '%{http_code}' 2>&1 || true"

echo ""
ok "Suspicious Content-Type test complete — check Suricata eve.json for ET:2000072"
result 0 "HTTP suspicious content-type test finished"
