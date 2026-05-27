#!/bin/bash
# CADRE — WT#047 NFS Kerberos Mount
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#047 — NFS Kerberos Mount"
start_attack "047" "NFS Kerberos Mount"

require_env LINUX01 "LINUX01"

# A sec=krb5p mount REQUIRES a valid Kerberos ticket for the mounting principal.
# Without a TGT the mount fails with a GSS/"incorrect mount option" error.
step "Ensure a Kerberos ticket exists (krb5p prerequisite)"
run_cmd "klist 2>/dev/null | grep -q krbtgt || kinit ${ATTACK_USER}@${NETBIOS_ROOT}.LOCAL"
run_cmd "klist"

step "Mount NFS export with Kerberos privacy (krb5p)"
run_cmd "sudo mkdir -p /mnt/cadre-nfs && sudo mount -t nfs4 -o sec=krb5p localhost:/exports/secure-share /mnt/cadre-nfs"

step "Verify mount + list protected content"
run_cmd "mount | grep cadre-nfs && ls -la /mnt/cadre-nfs"

result $? "NFS Kerberos Mount completed"
