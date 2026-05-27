#!/bin/bash
# CADRE — WT#036 SCCM Client Push Relay
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#036 — SCCM Client Push Relay"
start_attack "036" "SCCM Client Push Relay"

require_env SCCM_SERVER "SCCM_SERVER"

step "Run SharpSCCM + ntlmrelayx from Windows attack host"
echo "WT#036 requires sharpSCCM + ntlmrelayx — see walkthrough doc"

result 0 "SCCM Client Push Relay (Windows-only — see walkthrough)"
