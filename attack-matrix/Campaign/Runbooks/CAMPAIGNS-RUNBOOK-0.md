# CAMPAIGNS v3 — Phase 0 — Reconnaissance

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA.md`](../CAMPAIGNS-METADATA.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`CAMPAIGNS.md`](../CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

## Phase 0 - Reconnaissance — From Zero Credentials


### Step 0 — Full Port/Service Scan (All VMs)

```bash
nmap -Pn -sV -sC -p- --min-rate 5000 -T4 192.168.77.10,11,12,22,23,40,50,51,55
```

**Results (9 hosts up, 411s scan):**


| VM                        | IP  | Open Ports                                                       | Key Services                                                                    |
| ------------------------- | --- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| dc01 (cadre.local)        | .10 | 22,53,80,88,135,139,389,445,464,593,636,3268,3269,3389,5985,9389 | DC: DNS, Kerberos, LDAP, LDAPS, SMB, RDP, WinRM, ADWS. **SMB signing required** |
| dc02 (child.cadre.local)  | .11 | 22,53,88,135,139,389,445,464,593,636,3268,3269,3389,5985,9389    | DC: DNS, Kerberos, LDAP, LDAPS, SMB, RDP, WinRM, ADWS. **SMB signing required** |
| dc03 (range.local)        | .12 | 22,53,88,135,139,389,445,464,593,636,3268,3269,3389,5985,9389    | DC: DNS, Kerberos, LDAP, LDAPS, SMB, RDP, WinRM, ADWS. **SMB signing required** |
| mbr01 (child.cadre.local) | .22 | 22,80,135,443,445,1433,3389,5985                                 | **MSSQL 2022** (1433), IIS, HTTPS, RDP, WinRM. **SMB signing NOT required**     |
| mbr02 (range.local)       | .23 | 22,80,135,139,443,445,3389,5040,5985,8530,8531                   | **SCCM** (8530/8531), IIS, HTTPS, RDP, WinRM. **SMB signing NOT required**      |
| linux01 (cadre.local)     | .40 | 22,111,1433,2049,8080                                            | **MSSQL Linux** (1433), NFS, SSH, Python HTTP                                   |


**Key findings:**

- 3 MSSQL instances: mbr01 (Windows), linux01 (Linux), mbr02 (SCCM)
- SCCM on mbr02: ports 8530/8531 (HTTP/HTTPS WSUS)
- SMB signing **not required** on mbr01/mbr02 — NTLM relay possible
- SMB signing **required** on all 3 DCs — NTLM relay blocked
- SSH on all Windows VMs (OpenSSH for Windows)
- WinRM (5985) on all DCs and member servers
- NFS on linux01 (2049)

### Step 0.5 — Unauthenticated Reconnaissance (Limited on Server 2025)

> ⚠️ **Flow correction (2026-06-24 session 10):** NetExec commands that require credentials (`intern_blue:1nt3rn_Blu3!`) do NOT belong at this stage — we don't have those credentials yet. They are now distributed across the appropriate post-credential-gain stages (see Phase 1.3, 2.3, 3.5A). Step 0.5 is now strictly **unauthenticated** recon.

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
| logonCount      | > 0              | 0                     |
| passwordLastSet | Recent           | Never or old default  |
| groupMembership | Used in practice | Attractive but unused |


**Test:** Deploy honeytoken accounts in CADRE (Phase 5 defense exercise). Can we detect them via lastLogon before interacting?

**Detection (defensive):** Monitor LDAP queries targeting honeytoken accounts. ANY interaction = high-confidence alert. Deploy via plan1.7 EX-22.

---

### Step 7 — ADeleg GUI Recon (Alternative to BloodHound) 🆕

**Tool:** [ADeleg](https://github.com/trimarc/ADeleg) (Windows GUI, single `.exe`). Source material at `CADRE-Courses/How to Find Insecure Active Directory Permissions with ADeleg/Episode 173_*.txt` (21,554 bytes).

**Why this exists:** Per the ADeleg podcast Episode 173:
> "adelec is an active directory delegation management tool ... it gets you almost the same amount of information that bloodhound gets you but with like a third of the hassle — you don't have to set up bloodhound, you don't have to run the sharp pound collector in your environment and trigger all your edr alerts, you don't have to set up docker to like set up the bloodhound ui and node for neoj"

**Differentiators from BloodHound (Phase 4):**
- ✅ **No SharpHound collector** — avoids EDR alerts
- ✅ **No Docker / Neo4j** setup
- ✅ **No LDAP bind required** for full enumeration
- ✅ **Pure Windows GUI** — drop executable, click Connect
- ✅ **Direct View by Trustee** — maps directly to attacker perspective
- ⚠️ **Trade-off:** no graph visualization, no Cypher queries, no path-finding

**Workflow:**
```powershell
# 1. Copy ADeleg.exe to a domain-joined Windows VM (mbr01, mbr02, or any DC)
Copy-Item .\ADeleg.exe \\mbr01\C$\Tools\

# 2. RDP to mbr01, double-click ADeleg.exe
# 3. Click "Connect" — auto-authenticates as current user
# 4. View → Index View By → Trustees (reorganizes UI)
# 5. Select unsafe group on left (e.g., "Authenticated Users")
# 6. Review resources on right with "Allow" type + flagged permissions
# 7. For ADCS: View by → Resources → Certificate Templates → check ESC1-8 markers
```

**"Unsafe users/groups" to check first (per article):**
- everyone
- authenticated users
- domain users
- domain computers
- domain join account (often over-permissioned — "i commonly see over permissioned")

**"Unsafe permissions" flagged:**
- GenericAll / Full Control
- WriteAllProperties / WriteProperty
- WriteDacl / WriteOwner
- ForceChangePassword / ResetPassword
- Delete / CreateChild / DeleteChild
- AllExtendedRights (ADCS abuse)
- Apply-Group-Policy (GPO abuse)

**Maps to:**
- **Branch A (ACL Abuse)** — visualizes the 14 ACEs from `05-ad-attack-surface.yml` BEFORE exploitation. Confirms playbook deployment worked.
- **Branch B (ADCS)** — visual scan of ESC1-17 templates from `08-adcs-deploy.yml` BEFORE `certipy find`. Identifies:
  - ESC4 (vulnerable template ACLs — WriteOwner/WriteDacl on cert template)
  - ESC1 (enrollee supplies subject + auth EKU)
  - ESC2 (any purpose EKU)
  - ESC3 (enrollment agent EKU)
- **Phase 5 (Delegation)** — surfaces unconstrained + constrained + RBCD delegation paths
- **Phase 4 (BloodHound)** — pre-recon verification (faster, lower-noise)

**When to use ADeleg vs BloodHound:**
| Use case | Tool |
|---|---|
| Quick triage, no setup, avoid EDR | ADeleg |
| Deep path-finding, complex queries | BloodHound |
| ADCS misconfig discovery | Both (ADeleg first, then `certipy find`) |
| Reports with screenshots | ADeleg (clean GUI) |
| Reports with path graphs | BloodHound (only option) |

**CADRE-specific notes:**
- Run ADeleg from mbr01 (domain-joined, less critical than DCs)
- Visualizes the 14 ACEs from `05-ad-attack-surface.yml`:
  - ACE#13-14 (eng_agentic → DC: GetChanges + All) — DCSync
  - ACE#18 (intern_blue → analyst_t2: ForceChangePassword) — Phase 2 path
  - ACE#20 (dir_operations → mbr01$: GenericWrite) — RBCD path
  - ACE#23 (analyst_osint → svc_naa: GenericAll) — Phase 8 path
  - + 10 more
- Surfaces ADCS ESC1-17 templates from `08-adcs-deploy.yml`:
  - ESC1-Template (vulnerable ESC1)
  - ESC2-Template
  - ESC3-Template
  - ESC4-Template (vulnerable ACLs)
- All 3 DCs (dc01, dc02, dc03) have over-permissioned defaults that ADeleg will surface

**Detection (when defender monitors ADeleg recon):**
- **WinSec 4662** (DS Object Access) — high volume of ACL reads in short period from one source
- **WinSec 4624 Type 3** — auth from ADeleg source
- **Zeek LDAP queries** — bulk `searchRequest` with `(objectClass=*)` from single source IP
- **Sysmon EID 1** — `ADeleg.exe` process creation (process name visible)
- **Suricata new SID (propose 1000102):** Bulk LDAP queries from single source IP, large ACL-read pattern
- **Elastic KQL:** `event.code:4662 AND winlog.event_data.SubjectUserName:*` with cardinality > 100 in 60s window

**Cross-references:**
- Phase 4 (BloodHound) — pre-BloodHound scan
- Branch A (ACL Abuse — 14 ACEs) — visual confirmation
- Branch B (ADCS ESC1-17) — visual scan of vulnerable templates
- See Campaign_suggestions.md #99 (full entry with reasoning + alternative analysis)

---

## Phase 0.5 - Initial Access — Phishing & File Execution on ws01

The campaign now begins with a realistic initial-access vector against the domain-joined workstation `ws01` (`192.168.77.62`), a Windows 11 Enterprise machine running Microsoft Defender for Endpoint P2. The target user is `child.cadre.local\analyst_t1`, a Tier-1 analyst who uses Edge/Chrome and receives email or Teams messages from the lab environment.

**Scenario:** The attacker sends a spearphishing link or attachment to `analyst_t1`. The payload masquerades as a report, update, or internal tool. The user opens it on `ws01`, executes the embedded payload, and the attacker gains a C2 session as `analyst_t1`.

**Outcome:** A low-privileged beachhead on `ws01` as `child.cadre.local\analyst_t1`. From this session the attacker can run Phase 0 reconnaissance tools from a domain-joined Windows host, discover `intern_blue` (DONT_REQUIRE_PREAUTH), and transition into Phase 1 (AS-REP roast).

### H-01 — Malicious LNK

| Field | Value |
| --- | --- |
| **Target** | `ws01` (`192.168.77.62`) — `analyst_t1` desktop / Downloads |
| **Vector** | `.lnk` shortcut with a crafted `Target` field pointing to `cmd.exe /c` or `powershell.exe` that downloads and runs a second-stage payload from the Kali server (`192.168.77.60`) |
| **Expected telemetry** | Sysmon EID 1 (`powershell.exe` or `cmd.exe` child of `explorer.exe`), EID 11 (payload write to `%TEMP%`), EID 3 (HTTP egress to `192.168.77.60`), WinSec 4688, MDE `Suspicious LNK file` or `A malicious file was observed` alert, browser download artifact (`%USERPROFILE%\Downloads\*.lnk`), MOTW zone identifier on the LNK |
| **Outcome** | User-context C2 on `ws01` |

### H-02 — MSI Installer

| Field | Value |
| --- | --- |
| **Target** | `ws01` — `analyst_t1` |
| **Vector** | Weaponized `.msi` installer built with WiX; runs an embedded custom action that launches a reverse shell or downloads a payload |
| **Expected telemetry** | Sysmon EID 1 (`msiexec.exe` / `msiserver` with `/i`, child `cmd.exe`/`powershell.exe`), EID 11/12, EID 3, WinSec 4688, MDE alert for `msiexec` network activity, MOTW on `.msi` |
| **Outcome** | User-context C2 on `ws01` |

### H-03 — Compiled HTML Help (.chm)

| Field | Value |
| --- | --- |
| **Target** | `ws01` — `analyst_t1` |
| **Vector** | `.chm` file using `Shortcut` or `object` tags to invoke `cmd.exe` / `powershell.exe` from the HTML Help viewer (`hh.exe`) |
| **Expected telemetry** | Sysmon EID 1 (`hh.exe` spawning `cmd.exe`/`powershell.exe`), EID 11, EID 3, WinSec 4688, MDE `Suspicious HTML Help Execution`, MOTW on `.chm` |
| **Outcome** | User-context C2 on `ws01` |

### H-04 — HTML Smuggling

| Field | Value |
| --- | --- |
| **Target** | `ws01` — `analyst_t1` browser (Edge/Chrome) |
| **Vector** | Malicious HTML page or email attachment that uses JavaScript to assemble a blob/zip/exe payload client-side and trigger a download, bypassing simple attachment filters |
| **Expected telemetry** | Browser download history, Sysmon EID 11 (payload write to Downloads), EID 1 (payload execution), EID 3, MDE `HTML smuggling` or `Suspicious download`, MOTW zone identifier on downloaded file |
| **Outcome** | User-context C2 on `ws01` |

### H-05 — AutoIt3

| Field | Value |
| --- | --- |
| **Target** | `ws01` — `analyst_t1` |
| **Vector** | Compiled AutoIt3 script or `.au3` payload wrapped in an executable that launches a reverse shell or runs a second-stage download |
| **Expected telemetry** | Sysmon EID 1 (`AutoIt3.exe` or compiled AutoIt payload with network child), EID 11, EID 3, WinSec 4688, MDE `Suspicious AutoIt execution`, MOTW on dropped file |
| **Outcome** | User-context C2 on `ws01` |

### H-06 — Malicious EXE

| Field | Value |
| --- | --- |
| **Target** | `ws01` — `analyst_t1` |
| **Vector** | Executable payload (e.g., a custom C2 stager, signed or unsigned) delivered as a fake software update or document viewer |
| **Expected telemetry** | Sysmon EID 1 (unknown `.exe` child of `explorer.exe`), EID 11/12, EID 3, EID 7 (network DLL), WinSec 4688, MDE `Suspicious process` / `Malware detected`, browser download artifact, MOTW |
| **Outcome** | User-context C2 on `ws01` |

### Phase 0.5 → Phase 1 Transition

From the C2 session on `ws01` as `analyst_t1`, the attacker performs lightweight domain reconnaissance (e.g., `net user /domain`, `Get-ADUser -Filter *` via PowerShell, or `kerbrute userenum` from a dropped binary). This reveals the `intern_blue` account in `child.cadre.local` with `DONT_REQUIRE_PREAUTH`. The attacker then pivots the execution to Phase 1 — AS-REP roasting `intern_blue` from the internal beachhead (or from the Kali attacker station once network routing is established).

---

---

## Navigation

Next: [`CAMPAIGNS-RUNBOOK-1.md`](CAMPAIGNS-RUNBOOK-1.md) →
