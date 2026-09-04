#!/usr/bin/env bash
# start-h-server.sh — restart the Campaign H HTTP delivery server on provisioning :8081
#
# Usage (from provisioning VM):
#   bash ~/start-h-server.sh
#
# Usage (from host, via SSH):
#   ssh -i C:\Users\Ganro\.ssh\cadre-provisioning-key vagrant@192.168.77.60 \
#     "bash -s" < tools/start-h-server.sh
#
# What this does:
#   1. Kill any stale python3 http.server on :8081
#   2. Start python3 -m http.server 8081 from ~/www (nohup, logs to ~/www-server.log)
#   3. Verify :8081 responds with HTTP 200 on payload.exe
#
# Prerequisites:
#   - ~/www/ must contain the H artifacts (run ansible-playbook 19-initial-access.yml first)
#   - python3 must be installed

set -euo pipefail

WEBROOT="${HOME}/www"
PORT=8081
LOG="${HOME}/www-server.log"

echo "[*] Campaign H HTTP delivery server restart"
echo "[*] Webroot: ${WEBROOT}"
echo "[*] Port:    ${PORT}"
echo "[*] Log:     ${LOG}"

if [ ! -d "${WEBROOT}" ]; then
  echo "[!] ~/www does not exist. Run: ansible-playbook 19-initial-access.yml"
  exit 1
fi

echo "[*] Killing any stale http.server on :${PORT}..."
pkill -f "http.server ${PORT}" 2>/dev/null || true
sleep 1

echo "[*] Starting python3 http.server on :${PORT}..."
cd "${WEBROOT}"
nohup python3 -m http.server ${PORT} --bind 0.0.0.0 > "${LOG}" 2>&1 &
SERVER_PID=$!
echo "[*] Server PID: ${SERVER_PID}"

echo "[*] Waiting for :${PORT} to accept connections..."
for i in $(seq 1 10); do
  if curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:${PORT}/payload.exe" 2>/dev/null | grep -q "200"; then
    echo "[+] :${PORT} is serving (HTTP 200 on payload.exe)"
    break
  fi
  sleep 1
done

echo "[*] Verifying all 6 artifacts return HTTP 200..."
ARTIFACTS=("payload.exe" "Invoice.lnk" "H-02-evil.msi" "H-03-evil.chm" "H-04-smuggle.html" "AutoIt3.exe")
ALL_OK=true
for art in "${ARTIFACTS[@]}"; do
  CODE=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:${PORT}/${art}" 2>/dev/null || echo "000")
  if [ "${CODE}" = "200" ]; then
    echo "  [+] ${art} → 200"
  else
    echo "  [!] ${art} → ${CODE}"
    ALL_OK=false
  fi
done

if [ "${ALL_OK}" = "true" ]; then
  echo "[+] All artifacts served. Delivery URL: http://192.168.77.60:${PORT}/<file>"
else
  echo "[!] Some artifacts missing. Check ~/www/ contents."
  ls -la "${WEBROOT}"
  exit 1
fi
