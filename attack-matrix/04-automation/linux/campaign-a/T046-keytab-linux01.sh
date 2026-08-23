#!/usr/bin/env bash
# T046 — MSSQL/host keytab extraction on linux01
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
echo "=== T046 keytab on linux01 ==="
REMOTE=$(cat <<'EOF'
set -euo pipefail
echo "=== WT046: Keytab Extraction ==="
sudo ls -la /etc/krb5.keytab 2>/dev/null && sudo klist -k /etc/krb5.keytab 2>/dev/null | head -10 || echo "no /etc/krb5.keytab"
sudo ls -la /var/opt/mssql/secrets/ 2>/dev/null || echo "no mssql secrets"
sudo klist -k /var/opt/mssql/secrets/mssql.keytab 2>/dev/null | head -10 || true
if sudo test -f /etc/krb5.keytab || sudo test -f /var/opt/mssql/secrets/mssql.keytab; then echo "T046_OK"; else echo "T046_FAIL: no keytab"; exit 1; fi
EOF
)
bash "${LIB}/linux01-exec.sh" "${REMOTE}"
echo "T046 complete"
