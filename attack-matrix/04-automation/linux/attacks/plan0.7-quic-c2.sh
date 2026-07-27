#!/bin/bash
# CADRE — Plan 0.7: QUIC C2 (UDP/443) Test
# Triggers: cadre-quic-c2.zeek (UDP/443 duration + byte threshold)
# Run from provisioning VM. Requires nc (netcat) or python.
# Note: cadre-quic-c2.zeek fires on UDP/443 connections exceeding byte/duration thresholds.
# Zeek 8.0.8 has no QUIC event handlers — this uses heuristic UDP/443 detection.
# This generates UDP traffic on port 443 to simulate QUIC C2.
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "Plan 0.7 — QUIC C2 (UDP/443) Test"
start_attack "0.7-quic-c2" "QUIC C2 Simulation"

step "Sending UDP packets on port 443 to ELK (simulate QUIC C2 beacon)"
run_cmd "python3 -c \"
import socket, time
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    for i in range(30):
        msg = b'QUIC-beacon-' + str(i).encode() + b'-x' * 50
        s.sendto(msg, ('192.168.77.50', 443))
        time.sleep(5)
    s.close()
    print(f'Sent 30 UDP/443 packets over 150s')
except Exception as e:
    print(f'UDP send attempt: {e}')
\""

echo ""
ok "QUIC C2 test complete — check Zeek notice.log for cadre-quic-c2"
ok "Zeek 8.0.8 has no QUIC event handlers — rule uses UDP/443 heuristic"
result 0 "QUIC C2 test finished"
