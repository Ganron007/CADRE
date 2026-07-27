#!/bin/bash
# CADRE — Plan 0.7: SMBv1 Usage Test
# Triggers: ET:2000010 (ET SMBv1 Usage)
# Run from provisioning VM. Requires smbclient with NT1/SMB1 protocol support.
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — SMBv1 Usage Test"
start_attack "0.7-smb-v1" "SMBv1 Usage"

require_tool smbclient

step "Connecting to DC01 with SMB1/NT1 protocol"
run_cmd "smbclient -U 'CADRE/chief_command%C0mm@nd_Ch1ef!' //$DC01/C$ --option='client min protocol=NT1' --option='client max protocol=NT1' -c 'ls' 2>&1 || true"

echo ""
ok "SMBv1 test complete — check Suricata eve.json for ET:2000010"
result 0 "SMBv1 usage test finished"
