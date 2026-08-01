#!/bin/bash
# Branch D WT047: NFS krb5p mount from pivot (mssql-linux01)
export KRB5CCNAME=/tmp/krb5cc_pivot
echo 'MS5QL_K3yt@b_P@ss!' | kinit mssql-linux01@CADRE.LOCAL 2>&1
echo "=== klist ==="
klist 2>&1 | head -6
echo "=== mount krb5p ==="
sudo mkdir -p /mnt/cadre-nfs
sudo env KRB5CCNAME=/tmp/krb5cc_pivot mount -t nfs4 -o sec=krb5p localhost:/exports/secure-share /mnt/cadre-nfs 2>&1 && echo MOUNT_OK || echo MOUNT_FAIL
mount | grep cadre-nfs 2>&1
if mountpoint -q /mnt/cadre-nfs 2>/dev/null; then
  echo "=== secure-share content ==="
  sudo ls -la /mnt/cadre-nfs 2>&1
  echo "=== write test (krb5p rw) ==="
  sudo touch /mnt/cadre-nfs/pivot-write-test 2>&1 && echo WRITE_OK || echo WRITE_FAIL
  sudo ls -la /mnt/cadre-nfs 2>&1
  echo "=== unmount ==="
  sudo umount /mnt/cadre-nfs 2>&1 && echo UNMOUNT_OK
fi
echo "=== WT047_DONE ==="
