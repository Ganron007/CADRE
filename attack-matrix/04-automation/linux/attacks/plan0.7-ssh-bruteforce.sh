#!/bin/bash
# CADRE — Plan 0.7: SSH Brute Force Test
# Triggers: ET:2000060 (ET SSH Brute Force Attempt, threshold 5/60s)
# Run from provisioning VM. Requires sshpass or ssh with attempts.
# NOTE: BatchMode removed — SSH must complete handshake for Suricata to see traffic.

source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — SSH Brute Force Test"
start_attack "0.7-ssh-brute" "SSH Brute Force"

step "Sending 10 failed SSH login attempts to linux01 (must exceed 5/60s threshold)"
# Use expect to handle password prompt — ssh sends wrong password, server rejects
for pass in wrong1 wrong2 wrong3 wrong4 wrong5 wrong6 wrong7 wrong8 wrong9 wrong10; do
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL \
        -o ConnectTimeout=3 -o NumberOfPasswordPrompts=1 \
        "vagrant@$LINUX01" "exit" <<< "$pass" 2>/dev/null &
done
wait

echo ""
ok "SSH brute force test complete — check Suricata eve.json for ET:2000060"
result 0 "SSH brute force test finished"
