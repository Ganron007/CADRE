#!/bin/bash
# Wait for all core VMs to come back up + verify WinRM/SSH reachable
NXC=/tmp/nxc-venv/bin/nxc
declare -a VMS=(
  "192.168.77.10|DC01|vagrant|vagrant"
  "192.168.77.11|DC02|vagrant|vagrant"
  "192.168.77.12|DC03|vagrant|vagrant"
  "192.168.77.22|MBR01|child\\analyst_t1|T13r_An@lyst!"
  "192.168.77.23|MBR02|range\\svc_naa|N@A_s3rv1c3!"
  "192.168.77.62|WS01|child\\analyst_t1|T13r_An@lyst!"
)
for vm in "${VMS[@]}"; do
  IFS='|' read -r ip name user pass <<< "$vm"
  echo "=== WAIT $name ($ip) ==="
  ok=0
  for i in $(seq 1 30); do
    out=$($NXC winrm "$ip" -u "$user" -p "$pass" -X 'echo UP' 2>&1)
    if echo "$out" | grep -qE 'UP'; then
      echo "UP after ${i} tries"
      ok=1; break
    fi
    sleep 10
  done
  if [ $ok -ne 1 ]; then echo "FAILED to come up"; fi
done
echo "=== linux01 ping ==="
ping -c 1 -W 2 192.168.77.40 >/dev/null 2>&1 && echo "linux01 UP" || echo "linux01 DOWN"
echo "=== ALL-CHECKED ==="
