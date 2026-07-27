# CAMPAIGNS v2 — Phase 0 — Reconnaissance

> **Campaign v2** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA.md`](../CAMPAIGNS-METADATA.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v2.md`](../CAMPAIGNS_v2.md) · **Topology:** [`CAMPAIGNS.md`](../CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v2.md`](../CAMPAIGNS_v2.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

## Phase 0 - Reconnaissance — From Zero Credentials


### Step 0 — Full Port/Service Scan (All VMs)

```bash
nmap -Pn -sV -sC -p- --min-rate 5000 -T4 192.168.77.10,11,12,22,23,40,50,51,55
```

**Results (9 hosts up, 411s scan):**

- **dc01** (.10) — DC cadre.local: 22,53,80,88,135,139,389,445,464,593,636,3268,3269,3389,5985,9389. SMB signing **required**.
- **dc02** (.11) — DC child.cadre.local: same DC ports. SMB signing **required**.
- **dc03** (.12) — DC range.local: same DC ports. SMB signing **required**.
- **mbr01** (.22) — MSSQL 2022, IIS, HTTPS, RDP, WinRM. SMB signing **not required** (relay candidate).
- **mbr02** (.23) — SCCM 8530/8531, IIS, HTTPS, RDP, WinRM. SMB signing **not required** (relay candidate).
- **linux01** (.40) — MSSQL Linux, NFS, SSH, Python HTTP.
**Key findings:**

- 3 MSSQL instances: mbr01 (Windows), linux01 (Linux), mbr02 (SCCM)
- SCCM on mbr02: ports 8530/8531 (HTTP/HTTPS WSUS)
- SMB signing **not required** on mbr01/mbr02 — NTLM relay possible
- SMB signing **required** on all 3 DCs — NTLM relay blocked
- SSH on all Windows VMs (OpenSSH for Windows)
- WinRM (5985) on all DCs and member servers
- NFS on linux01 (2049)

### Step 0.5 — Unauthenticated Reconnaissance (Limited on Server 2025)

**Flow correction (2026-06-24):** NetExec commands that need `intern_blue` credentials belong in Phase 1+, not here. Step 0.5 is **unauthenticated** recon only.

**Server 2025 blocks most unauthenticated enumeration:**
- ❌ Null session (SAMR) — blocked
- ❌ Anonymous LDAP bind — blocked
- ⚠️ Guest SMB session — usually disabled
- ✅ Kerberos user enum (no creds needed) — see Phase 1 Step 1
- ✅ NTLM session-less checks — limited but useful for signing state

**Unauthenticated NetExec commands that DO work:**

```bash
# Relay candidate list (NO AUTH — just outputs hosts that allow NTLM relay)
nxc smb 192.168.77.0/24 --gen-relay-list /tmp/relay_list.txt

# Signing state check (NO AUTH — just reports signing_required: True/False per host)
nxc smb 192.168.77.0/24
# Output: per-host signing state — identifies relay targets (mbr01/mbr02 have signing NOT required)

# Guest session attempt (may be blocked on Server 2025 — try anyway)
nxc smb 192.168.77.10 -u 'guest' -p '' --shares
# Expected on Server 2025: STATUS_LOGON_FAILURE or access denied

# RID cycling with guest (often blocked — try anyway)
nxc smb 192.168.77.10 -u 'guest' -p '' --rid-brute 10000
# Expected on Server 2025: likely 0 users enumerated
```

**What CAN run unauthenticated in Phase 0 (not NetExec):**
- **Step 0** — nmap port/service scan (already in CAMPAIGNS.md)
- **Step 1** — RPC anonymous enum (blocked on Server 2025 — historical)
- **Step 2** — DNS zone transfers, public records
- **Step 3** — ADWS enumeration (port 9389 — may still work unauth in some configs)
- **Step 4** — DNS enumeration via adidnsdump
- **Step 5** — SAMR enumeration (blocked on Server 2025)
- **Step 6** — Honeypot detection via lastLogon (LDAP query — needs creds OR anonymous)
- **Step 7** — ADeleg GUI recon (Windows GUI tool — runs as authenticated user)

**Phase 1 Step 1** — Kerberos user enum via `kerbrute` (no creds needed — Kerberos AS-REQ with no pre-auth)

**See new post-credential NetExec stages:**
- **Phase 1 Step 3** — NetExec Authenticated Recon (First Credential: `intern_blue`)
- **Phase 2 Step 3** — NetExec Authenticated Recon (Service Account: `svc_mssql`)
- **Phase 3.5 Step A** — NetExec Authenticated Recon (Admin/SYSTEM)

### Step 1 — Anonymous Enumeration (Server 2025 blocks this)

```bash
# rpcclient — anonymous RPC
rpcclient -U '' -N 192.168.77.11 -c 'enumdomusers'
# Result: NT_STATUS_ACCESS_DENIED

# enum4linux — anonymous LDAP/SMB
enum4linux -a 192.168.77.11
# Result: NT_STATUS_ACCESS_DENIED

enum4linux -a 192.168.77.10
# Result: NT_STATUS_ACCESS_DENIED
```

**Finding:** Server 2025 blocks all anonymous enumeration by default. Both DCs (child.cadre.local and cadre.local) reject anonymous sessions. This is a hardening improvement over older Windows Server versions — GOAD (Server 2016/2019) allowed anonymous user listing.

### Step 2 — Kerberos User Enumeration (no creds needed)

Even with anonymous blocked, Kerberos port 88 reveals valid users. The KDC responds differently to valid vs invalid usernames in AS-REQ packets — no authentication required.

```bash
printf '%s\n' \
  'administrator, guest, krbtgt, vagrant,' \
  'intern_blue, analyst_t1, analyst_t2, analyst_t3, analyst_cloud,' \
  'svc_mssql, svc_elastic, mgr_incident, lead_detection, dir_operations,' \
  'eng_agentic, eng_cloud, intern_intel, hunter_dfir, analyst_dfir,' \
  'lead_engineering, ops_redcell, chief_command' \
  > /tmp/users.txt

# Enumerate child.cadre.local (DC02)
nmap -Pn -p 88 --script=krb5-enum-users \
  --script-args='krb5-enum-users.realm=child.cadre.local,userdb=/tmp/users.txt' \
  192.168.77.11

# Enumerate cadre.local (DC01)
nmap -Pn -p 88 --script=krb5-enum-users \
  --script-args='krb5-enum-users.realm=cadre.local,userdb=/tmp/users.txt' \
  192.168.77.10
```

**Results — 20 valid users found across both domains:**


| Domain            | DC                   | Users Found                                                                                                                            |
| ----------------- | -------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| child.cadre.local | dc02 (192.168.77.11) | vagrant, svc_mssql, lead_detection, administrator, analyst_t3, intern_blue, mgr_incident, analyst_t2, dir_operations, analyst_t1       |
| cadre.local       | dc01 (192.168.77.10) | analyst_cloud, administrator, lead_engineering, vagrant, hunter_dfir, eng_cloud, chief_command, analyst_dfir, ops_redcell, eng_agentic |


**Key finding:** `analyst_cloud` is in the **root domain** (cadre.local), not the child domain. This was never discovered by BloodHound because BH was only run against child.cadre.local.

### Step 3 — ADWS Enumeration (SOAP port 9389) ⏳

**Source:** iPurple.team (2025-08-12)
**MITRE:** T1018 (Remote System Discovery)

Active Directory Web Services (ADWS) runs on all DCs on port 9389. Provides SOAP-based enumeration as alternative to LDAP. Server 2025 blocks anonymous LDAP — but ADWS may behave differently.

```bash
# Test ADWS connectivity from Kali
nmap -Pn -p 9389 192.168.77.10,11,12

# Enumerate via ADWS (requires creds — test with intern_blue)
# SOAPHound or adws-enum tools
```

**Test:** Can ADWS enumerate users/groups when LDAP anonymous is blocked? If yes, this is a viable Phase 0 recon vector.

**Detection:** Zeek conn.log — connections to port 9389 from non-domain hosts.

### Step 4 — DNS Enumeration via adidnsdump ⏳

**Source:** dirkjanm.io (2019)
**MITRE:** T1590.002 (Gather Victim Network Information: DNS)
**Tool:** adidnsdump ([https://github.com/dirkjanm/adidnsdump](https://github.com/dirkjanm/adidnsdump))

AD-integrated DNS allows any authenticated user to query all records by default. adidnsdump enumerates the AD DNS zone, including records the querying user has no explicit read rights to.

```bash
# From Kali with intern_blue creds
adidnsdump -u cadre.local\\intern_blue -p '1nt3rn_Blu3!' dc01.cadre.local

# Compare output with BloodHound computer list
# Check for unpublicized records (Azure/Entra endpoints, Cloud Sync, etc.)
```

**Test:** Can we discover hosts not visible in BloodHound? Cloud Sync endpoints? Internal service records?

**Detection:** Zeek dns.log — bulk DNS queries from single source to authoritative AD DNS.

### Step 5 — SAMR Enumeration (LDAP-Free Account Discovery) ⏳

**Source:** CYPFER Offensive Practice (2026-06-15)
**MITRE:** T1087.002 (Account Discovery: Domain Account)

LDAP enumeration is heavily monitored in mature environments. SAMR (MS-SAMR protocol over port 445) returns the same account data through the same RPC pipe that backup agents, inventory tools, and management consoles use daily — traffic blends into baseline.

**Tool:** `sam_honeypot_enum.c` (CYPFER) or Impacket's `samrdump.py`

```bash
# From Kali — enumerate users via SAMR (no LDAP bind)
python3 samrdump.py cadre.local/intern_blue:'1nt3rn_Blu3!'@192.168.77.10

# Returns: samAccountName + lastLogon for every user
# Also works for machine accounts (dollar sign)
```

**What SAMR returns:**

- `samAccountName` — username
- `lastLogon` — last authentication timestamp (FILETIME)
- `logonCount` — total logon count
- `passwordLastSet` — when password was last changed
- `accountExpires` — expiration date

**Test:** Does SAMR enumeration generate fewer alerts than LDAP enumeration? Compare Zeek/Suricata output for both approaches.

**Detection:** Zeek `dce_rpc.log` — SAMR RPC calls from non-management hosts. Low confidence alone — needs correlation with other indicators.

### Step 6 — Honeypot Detection via lastLogon ⏳

**Source:** CYPFER Offensive Practice (2026-06-15)
**MITRE:** T1087.002 (Account Discovery: Domain Account)

Honeytoken accounts are built to detect interaction — attractive names (`svc_backup_adm`, `sql_da`), elevated group memberships, but **never authenticated**. The `lastLogon` attribute exposes them:

- `lastLogon = 0` (or `12/31/1600` in tools) = never authenticated = **honeypot**
- Real privileged accounts always have authentication history
- Machine accounts (`$`) with `lastLogon = 0` are impossible — domain join requires authentication
- Check across multiple DCs — `lastLogon` is not replicated

**Detection technique:**

```bash
# Enumerate via SAMR, filter for lastLogon = 0
python3 samrdump.py cadre.local/intern_blue:'1nt3rn_Blu3!'@192.168.77.10 | grep "Last Logon: 0"

# Or via LDAP (noisier):
ldapsearch -x -H ldap://dc01.cadre.local -b "DC=cadre,DC=local" "(&(lastLogon=0)(!(objectClass=computer)))" sAMAccountName
```

**Behavioral correlation:**


| Attribute       | Real Account     | Honeypot              |
| --------------- | ---------------- | --------------------- |
| lastLogon       | Recent timestamp | 0 or 12/31/1600       |
| logonCount      | `> 0`            | 0                     |
| passwordLastSet | Recent           | Never or old default  |
| groupMembership | Used in practice | Attractive but unused |


**Test:** Deploy honeytoken accounts in CADRE (Phase 5 defense exercise). Can we detect them via lastLogon before interacting?

**Detection (defensive):** Monitor LDAP queries targeting honeytoken accounts. ANY interaction = high-confidence alert. Deploy via plan1.7 EX-22.

---

### Step 7 — ADeleg GUI Recon (optional)

Optional Windows GUI ACL/ADCS scan — full steps in **[CAMPAIGNS-RUNBOOK-0-addeleg.md](CAMPAIGNS-RUNBOOK-0-addeleg.md)** (kept separate so this runbook previews reliably in Cursor).

---

## Navigation

Next: [`CAMPAIGNS-RUNBOOK-1.md`](CAMPAIGNS-RUNBOOK-1.md) →
