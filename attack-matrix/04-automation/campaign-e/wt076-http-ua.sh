#!/bin/bash
# CADRE — WT076 — Suspicious HTTP User-Agent
# Triggers: ET:2000041 (ET Suspicious HTTP User-Agent)
# Run from provisioning VM. Requires curl.
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — Suspicious HTTP User-Agent Test"
start_attack "0.7-http-ua" "Suspicious HTTP User-Agent"

require_tool curl

step "Sending HTTP request with curl User-Agent"
run_cmd "curl -A 'curl/7.68.0' -o /dev/null -s -w '%{http_code}' http://$DC01/ 2>&1 || true"

step "Sending HTTP request with wget User-Agent"
run_cmd "curl -A 'Wget/1.21' -o /dev/null -s -w '%{http_code}' http://$DC01/ 2>&1 || true"

step "Sending HTTP request with python User-Agent"
run_cmd "curl -A 'Python-urllib/3.9' -o /dev/null -s -w '%{http_code}' http://$DC01/ 2>&1 || true"

step "Sending HTTP request with powershell User-Agent"
run_cmd "curl -A 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041' -o /dev/null -s -w '%{http_code}' http://$DC01/ 2>&1 || true"

echo ""
ok "Suspicious UA test complete — check Suricata eve.json for ET:2000041"
result 0 "Suspicious HTTP User-Agent test finished"

