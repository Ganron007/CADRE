#!/bin/bash
# CADRE — WT074 — TLS 1.0 Connection
# Triggers: SID:1000010 (CADRE TLS 1.0), ET:2000031 (ET TLS 1.0)
# Run from provisioning VM. Requires curl with --tlsv1.0 support.
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — TLS 1.0 Connection Test"
start_attack "0.7-tls-v1" "TLS 1.0 Connection"

require_tool curl

step "Attempting TLS 1.0 connections to various endpoints"
# Use --insecure since lab certs are self-signed; --tlsv1.0 forces TLS 1.0
run_cmd "curl -k --tlsv1.0 --max-time 5 https://$DC01/ 2>&1 || true"
run_cmd "curl -k --tlsv1.0 --max-time 5 https://$DC02/ 2>&1 || true"
run_cmd "curl -k --tlsv1.0 --max-time 5 https://$MBR01/ 2>&1 || true"

echo ""
ok "TLS 1.0 test complete — check Suricata eve.json for SID:1000010 and ET:2000031"
result 0 "TLS 1.0 test finished"

