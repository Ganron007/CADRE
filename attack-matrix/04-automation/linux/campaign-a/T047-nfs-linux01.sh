#!/usr/bin/env bash
# T047 — NFS krb5p mount on linux01
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
echo "=== T047 NFS krb5p ==="
REMOTE=$(cat <<'EOF'
set -euo pipefail
echo "=== WT047: NFS Kerberos Mount ==="
echo "C0mm@nd_Ch1ef!" | kinit chief_command@CADRE.LOCAL 2>&1 || true
klist 2>&1 | head -8 || true
sudo mkdir -p /mnt/cadre-nfs
sudo umount /mnt/cadre-nfs 2>/dev/null || true
if sudo mount -t nfs4 -o sec=krb5p linux01.cadre.local:/exports/secure-share /mnt/cadre-nfs 2>&1; then
  mount | grep cadre-nfs && echo "MOUNT_OK" && sudo ls -la /mnt/cadre-nfs || true
else
  sudo mount -t nfs4 -o sec=krb5p localhost:/exports/secure-share /mnt/cadre-nfs 2>&1 || echo "MOUNT_FAIL"
  mount | grep cadre-nfs && echo "MOUNT_OK" || echo "MOUNT_FAIL"
fi
if mount | grep -q cadre-nfs; then echo "T047_OK"; else echo "T047_FAIL: NFS krb5p not mounted"; exit 1; fi
EOF
)
bash "${LIB}/linux01-exec.sh" "${REMOTE}"
echo "T047 complete"
