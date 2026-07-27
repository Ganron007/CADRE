# Phase 0 — Reconnaissance (From Zero Credentials)

> **Campaign position:** Before any credentials. Attacker starts on Kali (192.168.77.60) with no knowledge of the environment.
> **Goal:** Discover hosts, services, domains, and valid usernames without authentication.

---

## Step 0 — Full Port/Service Scan

### What It Does

A comprehensive TCP port scan across all 9 lab VMs identifies every listening service. This is the first action any attacker takes — you can't attack what you can't see. The scan uses `-Pn` (skip host discovery, treat all hosts as up), `-sV` (version detection), `-sC` (default scripts), `-p-` (all 65535 ports), and `--min-rate 5000` (speed optimization).

The scan reveals the entire attack surface: 3 domain controllers, 2 member servers, 1 Linux domain member, and 3 defense/monitoring VMs. Key findings shape every subsequent attack decision.

### Step-by-Step

```bash
nmap -Pn -sV -sC -p- --min-rate 5000 -T4 192.168.77.10,11,12,22,23,40,50,51,55
```

### Key Findings

| VM | IP | Critical Services | Attack Implications |
|----|----|--------------------|---------------------|
| dc01 | .10 | DNS, Kerberos, LDAP, LDAPS, ADWS | Root DC — target for forest trust escalation |
| dc02 | .11 | DNS, Kerberos, LDAP, LDAPS, ADWS | Child DC — primary Kerberoast/AS-REP target |
| dc03 | .12 | DNS, Kerberos, LDAP, LDAPS, ADWS | External forest — cross-forest attack target |
| mbr01 | .22 | **MSSQL (1433)**, IIS, HTTPS | SQL xp_cmdshell execution target |
| mbr02 | .23 | **SCCM (8530/8531)**, IIS | SCCM NAA extraction target |
| linux01 | .40 | **MSSQL (1433)**, NFS, SSH | Linux pivot — SSSD tickets, Podman escape |

**Critical observations:**
- **SMB signing NOT required** on mbr01/mbr02 → NTLM relay possible (Phase 5)
- **3 MSSQL instances** → SQL attack surface across Windows and Linux
- **SCCM on mbr02** → Network Access Account extraction possible
- **NFS on linux01** → Kerberos mount attacks possible
- **WinRM (5985) on all DCs** → remote management if credentials obtained

### Detection

Network-level scans generate connection noise but no specific alert. Zeek `conn.log` captures the scan traffic. Suricata may fire on scan patterns (port sweep rules). For CADRE, this is expected reconnaissance — no specific detection rule needed.

### Sources

- Nmap: https://nmap.org/book/man.html
- MITRE: T1046 (Network Service Discovery)

---

## Step 1 — Anonymous Enumeration (Blocked on Server 2025)

### What It Does

Anonymous enumeration attempts to list domain users, groups, and shares without authentication. On older Windows Server versions (2016, 2019), tools like `rpcclient`, `enum4linux`, and `ldapsearch` could enumerate domain objects with null sessions. **Server 2025 blocks this by default.**

This is a hardening improvement. GOAD (which uses Server 2016/2019) allows anonymous enumeration — CADRE's Server 2025 deployment does not. The attacker must find an alternative path to user discovery.

### Step-by-Step

```bash
# rpcclient — anonymous RPC (blocked)
rpcclient -U '' -N 192.168.77.11 -c 'enumdomusers'
# Result: NT_STATUS_ACCESS_DENIED

# enum4linux — anonymous LDAP/SMB (blocked)
enum4linux -a 192.168.77.11
# Result: NT_STATUS_ACCESS_DENIED
```

### Why It's Blocked

Server 2025 sets `RestrictAnonymousSAM = 1` and `RestrictAnonymous = 1` by default on domain controllers. These registry values prevent:
- Anonymous SAM enumeration via SMB/RPC
- Anonymous LDAP queries for user/group objects
- Null session establishment

### Detection

Anonymous enumeration attempts generate Windows Security event 4625 (failed logon, Logon Type 3, anonymous) and may trigger LDAP error logs. For CADRE, this is noise — the attempts fail, but the pattern is detectable.

### Sources

- Microsoft: https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/restrict-anonymous-access-to-named-pipes-and-shares
- MITRE: T1087 (Account Discovery)

---

## Step 2 — Kerberos User Enumeration (No Creds Needed)

### What It Does

Even with anonymous enumeration blocked, Kerberos port 88 reveals valid usernames. The KDC responds differently to valid vs invalid usernames in AS-REQ packets:
- **Valid user:** KDC responds with `KDC_ERR_PREAUTH_REQUIRED` (error 25) — "you need pre-auth"
- **Invalid user:** KDC responds with `KDC_ERR_C_PRINCIPAL_UNKNOWN` (error 6) — "user doesn't exist"

This difference is a well-known Kerberos information disclosure. Tools like `nmap --script=krb5-enum-users` and `kerbrute` exploit this to enumerate valid usernames without any credentials.

### Step-by-Step

```bash
# Create user list from known naming conventions
cat > /tmp/users.txt << 'EOF'
administrator, guest, krbtgt, vagrant,
intern_blue, analyst_t1, analyst_t2, analyst_t3, analyst_cloud,
svc_mssql, svc_elastic, mgr_incident, lead_detection, dir_operations,
eng_agentic, eng_cloud, intern_intel, hunter_dfir, analyst_dfir,
lead_engineering, ops_redcell, chief_command
EOF

# Enumerate child.cadre.local (DC02)
nmap -Pn -p 88 --script=krb5-enum-users \
  --script-args='krb5-enum-users.realm=child.cadre.local,userdb=/tmp/users.txt' \
  192.168.77.11

# Enumerate cadre.local (DC01)
nmap -Pn -p 88 --script=krb5-enum-users \
  --script-args='krb5-enum-users.realm=cadre.local,userdb=/tmp/users.txt' \
  192.168.77.10
```

### Results

**20 valid users found across both domains:**

| Domain | DC | Users Found |
|--------|-----|-------------|
| child.cadre.local | dc02 (.11) | vagrant, svc_mssql, lead_detection, administrator, analyst_t3, intern_blue, mgr_incident, analyst_t2, dir_operations, analyst_t1 |
| cadre.local | dc01 (.10) | analyst_cloud, administrator, lead_engineering, vagrant, hunter_dfir, eng_cloud, chief_command, analyst_dfir, ops_redcell, eng_agentic |

**Key finding:** `analyst_cloud` is in the **root domain** (cadre.local), not the child domain. BloodHound was only run against child.cadre.local — this user was never discovered by BH. This matters for Phase 3.5 (credential theft from analyst_cloud's session on mbr01).

### Why It Matters

1. **User enumeration without credentials** — Server 2025 blocks anonymous LDAP/RPC but Kerberos still leaks usernames
2. **Naming convention discovery** — `analyst_*`, `svc_*`, `intern_*`, `lead_*`, `mgr_*`, `dir_*`, `eng_*` patterns reveal organizational structure
3. **Cross-domain discovery** — Reveals users in both child.cadre.local and cadre.local
4. **Targets for AS-REP roast** — Users with `DONT_REQUIRE_PREAUTH` can be identified after enumeration (Phase 1)

### Detection

**Windows Security:**
- Event 4768 (Kerberos Authentication Service Request) — one per username tested
- Pattern: burst of 4768 events from same source IP, different TargetUserName values
- PreAuthType = 0 (no pre-auth attempted — this is a probe, not auth)

**Zeek:**
- `kerberos.log` — AS-REQ with `client` field varying across many usernames
- `conn.log` — burst of connections to port 88 from single source

**Suricata:**
- SID:1000015 (`cadre-ad.rules`) — Kerberos AS-REQ burst detection

**Key detection signal:** High volume of AS-REQ from a single source IP to port 88 with varying usernames. Normal clients authenticate as one user — enumeration probes test many.

### Sources

- MITRE: T1087.002 (Account Discovery: Domain Account)
- SpecterOps: https://www.specterops.io/blog/kerberos-user-enumeration
- Tool: kerbrute — https://github.com/ropnop/kerbrute
- Nmap script: krb5-enum-users

---

## Step 3 — MSSQLHound (SQL-Level BloodHound Collection)

### What It Does

MSSQLHound is a Go tool that collects SQL Server attack paths for BloodHound visualization. It connects to MSSQL instances, enumerates logins, roles, impersonation grants, linked servers, and sysadmin members — then exports nodes and edges for BloodHound import.

Unlike BloodHound (which queries AD via LDAP), MSSQLHound queries the SQL Server itself. It reveals attack paths that BloodHound misses: IMPERSONATE chains, linked server pivots, xp_cmdshell access, and CLR/OLE automation capabilities.

### Step-by-Step

```bash
# From provisioning (Kali) — run MSSQLHound against mbr01
./mssqlhound -u svc_mssql -p 's3rv1c3_MSSQL!' -d child.cadre.local -t 192.168.77.22
```

### Key Findings from CADRE

- **CVE-2025-49758 VULNERABLE** — MSSQL 16.0.1000.6 needs 16.0.1145.1
- **21 principals** collected across 3 databases
- **IMPERSONATE chain:** analyst_t1 → sa (sysadmin)
- **Linked servers:** MBR02 (RPC OUT), LINUX01 (RPC OUT)
- **Output:** 67 nodes, 168 edges → `mssql-bloodhound-20260606.zip`

### Detection

SQL Server audit logs capture the enumeration queries. MSSQLHound issues standard T-SQL queries (`SELECT * FROM sys.server_principals`, `SELECT * FROM sys.server_permissions`) — these are the same queries a DBA would run. Detection focuses on the source (non-DBA account running enumeration) rather than the queries themselves.

### Sources

- Tool: https://github.com/ly4k/MSSQLHound
- CVE-2025-49758: MSSQL privilege escalation via SQL Agent

---

## What This Phase Earns

| Output | Value |
|--------|-------|
| Host inventory | 9 VMs with IPs, ports, services |
| Domain structure | 3 domains: cadre.local (root), child.cadre.local (child), range.local (external) |
| User list | 20 valid usernames across 2 domains |
| Attack surface | MSSQL (3 instances), SCCM, NFS, WinRM, SMB relay targets |
| Key insight | analyst_cloud is in cadre.local (root domain), not child |
| SQL attack paths | IMPersonate chain, linked servers, CVE-2025-49758 |
