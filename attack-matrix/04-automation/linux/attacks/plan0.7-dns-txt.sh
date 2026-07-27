#!/bin/bash
# CADRE — Plan 0.7: DNS TXT Record Query Test
# Triggers: SID:1000026 (CADRE DNS TXT), ET:2000020 (ET DNS TXT)
# Run from linux01 (domain-joined) — provisioning VM cannot reach DC DNS.
# Requires: dig, ssh access to linux01@192.168.77.40
LINUX01="192.168.77.40"
DC01="192.168.77.10"
DC02="192.168.77.11"

echo "=== Running TXT query attack on linux01 ($LINUX01) ==="

ssh -o StrictHostKeyChecking=no "vagrant@$LINUX01" "
for domain in google.com example.com github.com outlook.com yahoo.com cloudflare.com amazon.com microsoft.com facebook.com twitter.com; do
    dig @$DC01 TXT \$domain +short &
done
wait
echo '--- Standard TXT done ---'
for sub in exfil data beacon c2 tunnel; do
    dig @$DC02 TXT \$sub.evil-domain.tk +short &
done
wait
" 2>/dev/null

echo "TXT query simulation complete — check Suricata eve.json"
