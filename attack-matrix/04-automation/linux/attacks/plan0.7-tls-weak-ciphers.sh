#!/bin/bash
# CADRE — Plan 0.7: Weak Cipher Suite Negotiation Test
# Triggers: cadre-tls-fingerprint.zeek (13 suspicious cipher suites)
# Note: Suricata doesn't have matching rules for weak ciphers — Zeek only.
# Run from provisioning VM. Requires curl with --ciphers option.
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — Weak Cipher Suite Test"
start_attack "0.7-tls-weak-cipher" "Weak Cipher Suite Negotiation"

require_tool curl

step "Negotiating RC4 cipher suites (RC4-SHA)"
run_cmd "curl -k --ciphers RC4-SHA --max-time 5 https://$DC01/ 2>&1 || true"

step "Negotiating DES-CBC3-SHA cipher suite"
run_cmd "curl -k --ciphers DES-CBC3-SHA --max-time 5 https://$DC01/ 2>&1 || true"

step "Negotiating EXP cipher suite (export-grade)"
run_cmd "curl -k --ciphers EXP-RC4-MD5 --max-time 5 https://$DC01/ 2>&1 || true"

step "Negotiating NULL cipher suite (no encryption)"
run_cmd "curl -k --ciphers NULL --max-time 5 https://$DC01/ 2>&1 || true"

step "Negotiating aECDH / anon DH cipher suite"
run_cmd "curl -k --ciphers ADH-AES256-SHA --max-time 5 https://$DC01/ 2>&1 || true"

echo ""
ok "Weak cipher test complete — check Zeek notice.log for cadre-tls-fingerprint"
result 0 "Weak cipher suite test finished"
