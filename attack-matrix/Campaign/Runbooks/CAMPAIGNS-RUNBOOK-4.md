# CAMPAIGNS v3 — Phase 4 — Discovery (BloodHound)

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA.md`](../CAMPAIGNS-METADATA.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`CAMPAIGNS.md`](../CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Phase 4 — Discovery (BloodHound as analyst_cloud)


Phase 3 gave us `analyst_cloud`'s token on mbr01 via file delivery. Now we run BloodHound from this domain-joined context to map the full attack surface.

**Why from mbr01 and not Kali?** SharpHound has different collection methods:

- **From Kali** (any domain user): `-c Group,ACL,Trust` — LDAP-only data (users, groups, ACLs, trusts). No session data.
- **From domain-joined machine** (analyst_cloud): `-c All` — everything above plus local session data, local group memberships, logged-on users, GPO mappings.

Session data reveals attack paths invisible from LDAP alone (e.g., a user who's local admin on multiple machines).

#### Step 1 — Transfer SharpHound to mbr01

```powershell
# From ws01 (initial beachhead), copy SharpHound to mbr01 via SMB (T1570).
# This mirrors the CRTP method: xcopy / Copy-Item C:\AD\Tools\<tool> \\target\C$\... then winrs.
$pass = ConvertTo-SecureString 'T13r_An@lyst!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('child.cadre.local\analyst_t1', $pass)
New-Item -ItemType Directory -Path '\\mbr01.child.cadre.local\C$\Tools' -Force -Credential $cred | Out-Null
Copy-Item -Path 'C:\Tools\ADTools\SharpHound.exe' -Destination '\\mbr01.child.cadre.local\C$\Tools\SharpHound.exe' -Force -Credential $cred
```

#### Step 2 — Run SharpHound as analyst_cloud

```bash
SharpHound.exe -c All -d child.cadre.local --outputdirectory C:\Users\analyst_cloud\Documents
```

#### Step 3 — BloodHound analysis

Load the zip into BloodHound CE and run Cypher queries:

```cypher
// All ACE edges from the credential chain so far
MATCH p=(u:User {name:"SVC_MSSQL@CHILD.CADRE.LOCAL"})-[r]->(target) RETURN p

// All ForceChangePassword paths (any domain)
MATCH p=(u:User)-[r:ForceChangePassword]->(t:User) RETURN p

// All GenericAll/GenericWrite edges
MATCH p=(u:User)-[r:GenericAll|GenericWrite]->(t) RETURN p

// Machines with unconstrained delegation
MATCH (c:Computer {unconstraineddelegation:true}) RETURN c

// ADCS vulnerable templates
MATCH (ct:CertTemplate) WHERE ct.requiresmanagerapproval=false RETURN ct
```

**Key findings that define the rest of the campaign:**


| Finding                                                     | Leads to                                                      | Why                                                                       |
| ----------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `mbr01$` has `TrustedForDelegation = true`                  | **Phase 5** — Coerce dc02$ to auth → capture TGT              | Coercion forces the DC to auth; unconstrained delegation captures its TGT |
| ACE#7: `hunter_dfir` → `chief_command`: ForceChangePassword | **Branch A** — Direct DA escalation in cadre.local            | Fastest path to root domain DA                                            |
| ACE#3/4/5/1: Various ACL paths                              | **Branch A** — WriteDacl, GenericWrite, GPO abuse             | Multiple independent routes to DA                                         |
| AD CS templates with ESC vulnerabilities                    | **Branch B** — Certificate-based DA                           | ESC1-14 deployed on dc01                                                  |
| `svc_sccm` has SCCM Full Admin + SPN                        | **Phase 8 / Branch C** — Cross-forest Kerberoast → SCCM chain | Requires range.local access to exploit                                    |
| MSSQL linked server to linux01                              | **Branch D** — Linux post-exploit                             | SQL-on-Linux pivot path                                                   |




---

## Study references (read before this phase)

### Phase 4 — Discovery (read BEFORE testing)

#### 📖 SharpHound Detection — iPurple.team (Tier 2)

**Why read:** When we run SharpHound in Phase 4, we want to understand what we're triggering in the defender's logs. Detection engineers study SharpHound to write better rules; attackers study it to evade them.

**Source:** [SharpHound Detection — iPurple.team](https://ipurple.team/2025/06/sharphound-detection.html)

**Key concepts to internalize:**

- SharpHound's `Stealth` collector uses LDAP `DirSync` control (avoiding `searchrequest` event 1644)
- Default `SMB` session enumeration triggers `Microsoft-Windows-Security-Auditing` 5145 events (network share access)
- `Microsoft-Windows-Security-Auditing` 4662 events fire for every object SharpHound touches (high volume)
- `LocalGroup` collection via `NetLocalGroupGetMembers` triggers 4798/4799 events

**Action item:** Read this BEFORE Phase 4. If we're running SharpHound and want our own rules to fire, we need to know what to look for. Cross-reference with the existing cadre-* SharpHound detection rules (if any).

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-3.5.md`](CAMPAIGNS-RUNBOOK-3.5.md) · Next: [`CAMPAIGNS-RUNBOOK-5.md`](CAMPAIGNS-RUNBOOK-5.md) →
