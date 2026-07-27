#!/bin/bash
# CADRE — WT080 — Long Connection Beacon
# Triggers: cadre-conn-beacon.zeek (byte/duration threshold alerts)
# Run from provisioning VM. Requires nc (netcat) or python.
# Note: cadre-conn-beacon.zeek fires when connections exceed byte or duration thresholds.
# This creates a long-lived TCP connection to simulate C2 beacon.
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — Long-Duration Connection Test"
start_attack "0.7-long-conn" "Long-Duration Connection / Beacon"

step "Starting a 300-second (5 min) TCP connection to simulate C2 beacon"
step "This will run in the background and generate Zeek conn.log entries"
run_cmd "python3 -c \"
import socket, time
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(300)
    s.connect(('192.168.77.50', 443))
    print('Connected to ELK on port 443, holding for 300s...')
    for i in range(30):
        s.send(b'beacon-payload-' + str(i).encode())
        time.sleep(10)
    s.close()
    print('Connection closed after 300s')
except Exception as e:
    print(f'Connection attempt: {e}')
\""

echo ""
ok "Long-connection test complete — check Zeek notice.log for cadre-conn-beacon"
ok "Also check Zeek conn.log for long-duration connection entries"
result 0 "Long-duration connection test finished"

