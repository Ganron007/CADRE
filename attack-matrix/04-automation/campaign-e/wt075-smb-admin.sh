#!/bin/bash
# CADRE — WT075 — SMB Admin Share Access
# Triggers: ET:2000012 (ET SMB Admin Share Access)
# Run from provisioning VM. Requires smbclient.
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — SMB Admin Share Access Test"
start_attack "0.7-smb-admin" "SMB Admin Share Access"

require_tool smbclient

step "Accessing C$ admin share on DC01 with valid credentials"
run_cmd "smbclient -U 'CADRE/chief_command%C0mm@nd_Ch1ef!' //$DC01/C$ -c 'ls' 2>&1 || true"

step "Accessing ADMIN$ share on DC01"
run_cmd "smbclient -U 'CADRE/chief_command%C0mm@nd_Ch1ef!' //$DC01/ADMIN\$ -c 'ls' 2>&1 || true"

echo ""
ok "SMB admin share test complete — check Suricata eve.json for ET:2000012"
result 0 "SMB admin share test finished"

