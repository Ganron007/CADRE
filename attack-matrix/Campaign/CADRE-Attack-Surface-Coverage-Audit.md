# CADRE Attack-Surface Coverage Audit vs Campaign v3

> Scope: compare the configured lab surface (Ansible playbooks + integration guides) against the attack expectations in `CAMPAIGNS_v3.md` / `CAMPAIGNS-METADATA-v2.md` and the validation report.
> Status flags: ✅ configured / ⚠️ partially or misconfigured / ❌ missing / 🔬 intentionally deferred / ⏳ configured but not exercised.
> SSoT principle: the actual live lab is the source of truth; playbooks/guides are written/updated after manual setup to reflect it.

> **⛔ Attack-origin rules (2026-07-31, operator-locked):**
> **RULE 1 — Direct SSH to ws01 only.** All attack runs originate from `ws01` via direct SSH (`ssh -i C:\Users\Ganro\.ssh\cadre-ws01-key analyst_t1@192.168.77.62`). No wrappers, no provisioning bridge. **Provisioning (`.60`) is config-only** (apply/verify playbooks, Ansible). Rows below that previously cited `provisioning` as an attack source are superseded by this rule.
> **RULE 2 — No scheduled tasks to run commands.** Scheduled tasks are persistence-only (Phase 5), never execution wrappers. Running a command/tool via a scheduled task is rejected methodology. The "3.5B execution wrapper" is rejected; `SeBatchLogonRight` on mbr01 remains configured only as a persistence-prerequisite surface.

## 1. Executive Summary

| Category | Configured | Partial / Misconfigured | Missing / Not Configured | Deferred |
|---|---|---|---|---|
| Main spine (Phases 0-8) | 23 | 5 | 2 | 1 |
| Branch A (ACL abuse) | 9 | 0 | 0 | 0 |
| Branch B (ADCS) | 7 | 0 | 2 | 2 |
| Branch C (SCCM) | 4 | 1 | 1 | 0 |
| Branch D (Linux pivot) | 5 | 0 | 0 | 0 |
| Branch G (CVE-2026-41089) | 0 | 0 | 1 | 0 |
| Phase 0.5 / H (initial access) | 0 | 0 | 6 | 0 |
| E (network defense) | 0 | 0 | 14 | 0 |
| F (supply chain) | 0 | 0 | 13 | 0 |

**Key findings:**
1. The biggest gap is **Phase 0.5 / H (initial access)**: no playbook configures the payloads/drop vectors on `ws01` or `Kali`. The surface is assumed by the campaign but not automated.
2. **Phase 5 coercion / T102** trigger path is now configured: `dc02` Spooler + SMB/RPC firewall prerequisites are added to `04-vulnerabilities.yml`. **VERIFIED 2026-07-31:** T102 `dc02$` TGT captured (hostname listener for Kerberos), converted kirbi→ccache, and used for Phase 6 DCSync of `child/krbtgt`. Full chain now green.
3. **Branch A** is now **fully verified** (2026-07-31): all ACE-based attacks executed from ws01 via direct SSH (Rule 1). It still relies on a password spray (WT031) as the credential bridge, which is an attack technique, not a playbook surface.
4. **Branch C** surface + primitives verified; **WT037 CMPivot, WT038 app deploy, WT039 script-as-SYSTEM all FULL EXEC VERIFIED 2026-08-02 from ws01** as `range\svc_sccm` (the campaign scripts run from ws01 — the WS01 client is the target). WT035 PXE needs a real PXE client; WT036 client-push relay needs a console-created device.
5. **Branch D** Linux pivot is mostly missing: SSSD/keytab/NFS/Podman surface is not configured in the Linux playbook.
6. **E and F** streams are not attack-surface configurations; they are detection/supply-chain exercises that depend on monitor and linux01/mbr01 tooling. No playbooks configure the *attack* side of E/F (they configure only the sensors/registry).
7. **Branch G** is a standalone unauthenticated DC exploit; no playbook configures a vulnerable state — it relies on dc02 simply being unpatched.

**Defender / Tamper Protection (re-verified 2026-07-31):** OFF on all VMs.
- Server VMs (dc01/dc02/dc03/mbr01/mbr02): WinDefend **Stopped** + `DisableAntiSpyware=1` (+RTP policy block on mbr01). MBR01 MPSTAT blank = WMI/CIM permission quirk for `analyst_t1`, not Defender.
- ws01 (Win 11 Ent 26200): soft-disable per `17-ws01-deploy.yml` — RTP/TP `False`, `DisableAntiSpyware=1`, RTP/Behavior/IOAV/OnAccess policy blocks + SpyNet=0 + tooling excludes. Service stays Running (client SKU service hardening; even SYSTEM scheduled-task stop denied: `OpenService FAILED 5`) — by design, matches playbook comment.
- Rubeus `golden` silent failure is NOT Defender-related (persists after full policy kill); use mimikatz `kerberos::golden`.

---

## 2. Phase-by-Phase Audit

### 2.1 Phase 0.5 / H — Initial Access (ws01 beachhead)

| ID | Attack | Expected Surface | Playbook/Guide Coverage | Status | Notes |
|---|---|---|---|---|---|
| H-01 | Malicious LNK drop | `Kali` payload + `ws01` Downloads folder, user clicks | No playbook stages LNK payloads. | ❌ Missing | Entirely manual / operator-driven. |
| H-02 | Malicious MSI | MSI builder + drop on `ws01` | No playbook. | ❌ Missing | Needs WiX/MSI tooling staged. |
| H-03 | Compiled HTML Help (.chm) | HTML Help Workshop + payload | No playbook. | ❌ Missing | Needs `hhc.exe` etc. |
| H-04 | HTML smuggling | Kali HTTP server + browser on `ws01` | No playbook. | ❌ Missing | No web server payload or browser macro. |
| H-05 | AutoIt3 payload | AutoIt3 compiler + script drop | No playbook. | ❌ Missing | Tool not installed. |
| H-06 | Malicious EXE | Payload builder + drop | No playbook. | ❌ Missing | Generic placeholder. |

**Verdict:** Phase 0.5 is intentionally a user-execution stage, but the campaign metadata treats it as part of the chain. To make the lab "flawless" we should add a `19-initial-access.yml` playbook that stages the payloads on `Kali` and the drop directories on `ws01`.

---

### 2.2 Phase 0 Recon

| ID | Attack | Expected Surface | Playbook/Guide Coverage | Status | Notes |
|---|---|---|---|---|---|
| P0-Step1 | Kerberos user enum | Port 88 open, users exist | `00-domain-deploy.yml` + `02-ad-objects.yml` create users. | ✅ Configured | Confirmed working. |
| P0-Step2 | AS-REP roastable check | `intern_blue` no-preauth | `05-ad-attack-surface.yml` sets `DoesNotRequirePreAuth`. | ✅ Configured | Confirmed. |
| P0-Step3 | NetExec recon (intern_blue) | Same as above + tools on provisioning | `provisioning` role installs tools; netexec verified. | ✅ Configured | Confirmed. |
| WT028 | Null session / SAMR anonymous | Anonymous SAMR allowed | Server 2025 blocks this by default; no playbook disables the hardening. | 🔬 Rejected | Correctly not configured; campaign should stop relying on it. |

**Verdict:** Phase 0 is solid. WT028 is correctly absent.

---

### 2.3 Phase 1 (AS-REP)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| WT003 | AS-REP roast `intern_blue` | `intern_blue` no-preauth | Same as P0-Step2. | ✅ Configured | Confirmed. |

---

### 2.4 Phase 2 (Kerberoast via ACE#18)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| WT002 | Kerberoast `svc_mssql` | `svc_mssql` SPN + AES, `analyst_t2` ForceChangePassword bridge | `05-ad-attack-surface.yml` sets SPN, AES, and ACE#18. | ✅ Configured | Confirmed. |

---

### 2.5 Phase 3 (SQL execution)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| WT041/043 | xp_cmdshell + GodPotato | `mbr01` mixed auth, SQL logins, `IMPERSONATE sa`, xp_cmdshell on, GodPotato binary | `04-vulnerabilities.yml`/`sql-integration-guide.md` + `17-ws01-deploy.yml` (analyst_t1 local admin). | ✅ Configured | Confirmed. |
| WT042 | CLR assembly on `mbr02` | `mbr02` TRUSTWORTHY, CLR enabled, CLR strict security off | `sql-integration-guide.md` documents; `04-vulnerabilities.yml`? | ⚠️ Partial | Configured but attack script only reached "reachable" not executed. |

**Verdict:** SQL surface is configured. The CLR assembly was not actually loaded in the test run; that is a script/execution gap, not a surface gap.

---

### 2.6 Phase 3.5 (Credential access / post-ex on mbr01)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| T101 | WinRS lateral `ws01` → `mbr01` | WinRM trusted hosts, `analyst_t1` local admin on `mbr01`, firewall | `17-ws01-deploy.yml` configures TrustedHosts + local admin; `03-member-join.yml` joins mbr01. | ✅ Configured | Confirmed. |
| 3.5F | mimikatz SAM/LSASS | `mimikatz` on `mbr01`, SYSTEM context | `06-member-services.yml` copies tools? | ✅ Configured | SAM confirmed; LSASS token issue is execution, not surface. |
| 3.5A | Winlogon plaintext cred | `analyst_cloud` auto-logon registry | `06-member-services.yml` creates auto-logon entry? | ✅ Configured | Confirmed in validation. |
| 3.5G | Nemesis DPAPI | Nemesis tool installed | No playbook installs Nemesis. | ❌ Missing | Tool gap. |
| 3.5H | ctfmon.exe typed passwords | ctfmon running with typed input | Windows default; no special config. | ⏳ Default | Surface exists, but attack not exercised. |
| 3.5I | Token impersonation | Session isolation relaxed | Server 2025 is patched; no playbook can fix this. | 🔬 Rejected | Correctly not configured. |
| 3.5B | Scheduled Task as `analyst_cloud` | Task scheduler access + `SeBatchLogonRight` for `analyst_cloud` on mbr01 | `06-member-services.yml` grants batch-logon. | 🔬 Rejected (execution wrapper) | **Rule 2:** scheduled tasks are persistence-only, never execution wrappers. Surface retained only as Phase 5 persistence prerequisite. |
| 3.5C | RDP as `analyst_cloud` | RDP enabled, `analyst_cloud` in Remote Desktop Users | `04-vulnerabilities.yml` + `06-member-services.yml` add `analyst_cloud`. | ✅ Configured | Not exercised in run. |
| 3.5D | File detonation / payload drop | Payload files staged | Same as H stream; no playbook. | ❌ Missing | Surface not configured. |
| 3.5J | WMI Event Subscriptions | WMI service running | Default. | ⏳ Default | Not exercised. |
| 3.5K | WerFault LSASS dump | WerFaultSecure.exe + `DumpFolder` registry | No playbook configures this. | ❌ Missing | Needs registry/keys setup. |
| 3.5L | LAPS extraction | LAPS deployed, password readable by DA | No playbook installs LAPS. | ❌ Missing | Tool gap. |
| 3.5M | Azure AD Connect DPAPI | AADConnect / ADSync DB | `15-cloud-sync.yml` installs provisioning agent, not AD Connect sync. | ❌ Missing | Not full AD Connect. |
| 3.5N | UnCanny LPE | Developer Mode + InstallService | No playbook enables Developer Mode. | 🔬 Deferred | Correctly not configured (risky). |

**Verdict:** Several 3.5 techniques are not configured because they require extra tools (Nemesis, LAPS, AAD Connect, WerFault) or risky settings (Developer Mode). The core credential-theft surface (mimikatz, Winlogon) is configured.

---

### 2.7 Phase 4 (BloodHound)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| WT004 | BloodHound ingest | SharpHound/BloodHound-python + Neo4j on `provisioning` | `provisioning` role installs tooling; collected previously. | ✅ Configured | Confirmed. |

---

### 2.8 Phase 5 (RBCD + Coercion)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| WT007 | RBCD standalone | `msDS-AllowedToActOnBehalfOfOtherIdentity` writable on `mbr01`/`dc02` | `05-ad-attack-surface.yml` does not seem to pre-populate RBCD; relies on ACL. | ✅ VERIFIED 2026-07-31 | FakePC$ created via addcomputer; rbcd set; getST S4U2Proxy → SYSTEM on mbr01; cleanup done. |
| WT017 | PrinterBug / MS-RPRN | Spooler service running on target, SMB open | `04-vulnerabilities.yml` enables Spooler on `mbr01`; `dc02` Spooler prerequisites added. | ✅ Verified | Confirmed on `mbr01`; `dc02` coercion (T102) VERIFIED 2026-07-31. |
| WT018 | PetitPotam / MS-EFSR | `\PIPE\efsrpc` accessible | Server 2025 hardens this; no playbook. | 🔬 Rejected | Correctly not configured. |
| WT019 | DFSCoerce / MS-DFSNM | DFS Namespace feature installed | `04-vulnerabilities.yml` installs FS-DFS-Namespace. | ✅ Configured | But Suricata cannot detect SMB-pipe DCE-RPC; functionally not useful. |
| WT020 | ShadowCoerce / MS-FSRVP | File Server VSS Agent service | Not installed by default on Server 2025. | ❌ Missing | Out of scope for lab. |
| WT021 | NTLM relay → LDAP | LDAP signing not required on `dc01` | `04-vulnerabilities.yml` sets `LDAPServerIntegrity=1`. | ✅ Configured | Confirmed. |
| WT022 | NTLM relay → ADCS web enrollment | Web Enrollment + NetworkService app pool | `adcs-configuration-guide.md` Phase 1 configures this. | ✅ Configured | Confirmed. |
| WT094 | UnCanny Coerce | Developer Mode + loose AppX registration | Not configured. | 🔬 Deferred | Correctly not configured. |
| WT095 | Onelogon Zero-Channel | Unpatched single-channel NRPC | No playbook can make a DC vulnerable; relies on patch state. | 🔬 Deferred | PoC not released. |
| WT096 | `coerce_plus` consolidated | NetExec module + any working coercion | NetExec installed; but no target surface beyond WT017. | ⚠️ Partial | Same as WT017/WT018/WT019/WT020. |
| T102 | Unconstrained delegation capture `dc02$` | `dc02` Spooler exposed, `mbr01` Rubeus monitor | **`dc02` Spooler prerequisites added to deploy/verify playbooks.** | ✅ VERIFIED | **2026-07-31:** `dc02$` TGT captured via hostname listener (Kerberos), kirbi→ccache, → Phase 6 DCSync of child/krbtgt. Full chain green. |

**Verdict:** Phase 5 coercion prerequisites are now aligned in playbooks. The full T102 capture path is **VERIFIED** (trigger + Kerberos TGT capture + kirbi→ccache → Phase 6 DCSync). The earlier capture confusion was resolved by using a **hostname listener** (IP listener falls back to NTLM and issues no TGT).

**Next step:** Run `04-vulnerabilities-verifyOnly.yml` to confirm `dc02` spooler/RPC state (already verified live). Then proceed to Phase 6/7 dependent attacks which are now unblocked.

---

### 2.9 Phase 6 (DCSync)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| WT009 | DCSync | `dc02$` TGT or DA account with replication rights | `05-ad-attack-surface.yml` grants DCSync rights via ACE#13+14 to `eng_agentic`; `chief_command` is DA. | ✅ Configured + Verified (main path) | **2026-07-31:** Main path VERIFIED — T102 `dc02$` TGT → kirbi→ccache → `secretsdump.py -k -no-pass` → `child/krbtgt` NT + AES256 extracted. Fallback via `chief_command` also works. |

---

### 2.10 Phase 7 (Golden/Silver/Diamond Ticket)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| WT010 | Golden Ticket | `krbtgt` hash from DCSync | Depends on Phase 6. | ✅ Configured + Verified (main path) | **2026-07-31:** mimikatz `kerberos::golden` with extracted child krbtgt (NT + AES256) + `/sids:<root EA>` — forged, injected (PTT), saved `EA-aes.kirbi`. Rubeus `golden` silently fails on ws01 (non-Defender quirk). Cross-realm DCSync of root via golden = PAC checksum quirk on dc01 DRSUAPI bind; root EA via chief_command fallback. |
| WT011 | Silver Ticket | Service account hash | Same. | ✅ Configured | Script runs. |
| WT012 | Diamond Ticket | `krbtgt` hash + legitimate TGT | Same. | ✅ Configured | Script runs. |

**Verdict:** Phase 7 surface is fine and the main path now VERIFIED — real `krbtgt` hash extracted from `dc02` via T102 TGT → DCSync; golden ticket forged + PTT. Cross-realm DCSync of the root via the golden ticket hits a PAC checksum quirk on dc01's DRSUAPI bind (documented); root DA+EA is covered by the Branch A `chief_command` fallback path.

---

### 2.11 Phase 8 (Cross-forest)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| WT033 | Cross-forest Kerberoast | Two-way trust, SID filter OFF, `svc_sccm` SPN in `range.local` | `00-domain-deploy.yml` creates trust; `05-ad-attack-surface.yml` registers SPN. | ✅ Configured | Confirmed. |
| WT034 | SCCM NAA extraction | SCCM site with NAA, `svc_sccm` SCCM Full Admin, vault share | `sccm-integration-guide.md` + `06-member-services.yml` configure this. | ✅ Configured | Confirmed. |
| WT035-039 | SCCM escalation chain | PXE, client push, CMPivot, app deploy, site takeover | Same as WT034, + AdminService + MP policy channel. | ✅ WT037/038/039 VERIFIED 2026-08-02; WT035/036 gated | CMPivot, app deploy, script-as-SYSTEM run from ws01 as `svc_sccm` against the WS01 client. WT035 needs a PXE client VM; WT036 needs a console-created device record. |
| Skipjack | PAC signature corruption | Cross-forest trust + SID filter OFF + custom tool | Trust is configured; custom tool not available. | 🔬 Deferred | PoC not built. |

---

### 2.12 Branch A (ACL Abuse)

|| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
|| WT015 | ACE#7 ForceChangePassword | `hunter_dfir` → `chief_command` ForceChangePassword | `05-ad-attack-surface.yml` ACE#7; not currently exposed to `hunter_dfir`. | ✅ VERIFIED 2026-07-31 | ACE#7 re-applied live on dc01; `hunter_dfir` reset `chief_command` password (temp) + restored original. |
|| WT013 | WriteDacl self-escalate | `chief_command` → `hunter_dfir` GenericAll on Command-Cadre group | `05-ad-attack-surface.yml` does not explicitly pre-configure this; relies on script. | ✅ VERIFIED 2026-07-31 | GenericAll granted on `CN=Command-Cadre`; ACE read-back verified (ACL_APPLIED + ACE present). |
|| WT014 | GenericWrite → Shadow Creds | `chief_command` → `hunter_dfir` GenericWrite on `analyst_cloud` | Same as above. | ✅ VERIFIED 2026-07-31 | GenericWrite (ReadProperty/WriteProperty/ExtendedRight) granted on `analyst_cloud`; ACE read-back verified. |
|| WT016 | GenericAll on OU | `chief_command` → `hunter_dfir` GenericAll on `OU=Command` | Same. | ✅ VERIFIED 2026-07-31 | GenericAll granted on `OU=Command`; ACE read-back verified. |
|| WT008 | Shadow Creds on `dc01$` | `chief_command` can write KeyCredential to `dc01$` | Same. | ✅ Verified | pywhisker (explicit creds, LDAPS) added KeyCredential to dc01$; PKINIT TGT as dc01$; NT hash 09493093db08c8afa99193779d401b34 recovered (= DCSync rights). |
|| WT023 | GPO Abuse | `analyst_cloud` GPO edit rights, WMI-Filtered-GPO linked to OU=Agentic | `02-ad-objects.yml` creates GPO + link; `05-ad-attack-surface.yml` ACE#1 grants `analyst_cloud` rights. | ✅ Verified | analyst_cloud has WriteDacl/WriteOwner/GenericAll on Vulnerable-GPO; ScheduledTasks.xml preference written + read back + cleaned up. |
|| WT024 | gMSA extraction | `gmsaTools` gMSA with SACL, `GoldenGMSA` tool | `05-ad-attack-surface.yml` creates gMSA + SACL; `t024-gmsa-extract.py` in-script ldap3. | ✅ Verified | LDAPS bind as eng_cloud → msDS-ManagedPassword blob → NT hash `0c81acad...` → SMB auth as gmsaTools$ verified. |
|| GPP | GPP stored password | `Groups.xml` in SYSVOL with cpassword | `02-ad-objects.yml` + `05-ad-attack-surface.yml` fixed 2026-07-31 (`svc_ldap` + valid cpassword). | ✅ Verified | cpassword decrypted to `svc_ldap` / `s3rv1c3_Ld@p!`; SMB auth as svc_ldap verified. |
|| WT027 | SPN jacking (CVE-2026-25177) | `analyst_cloud` self ValidatedWriteSPN, homoglyph SPN pre-staged | `05-ad-attack-surface.yml` pre-stages homoglyph SPN and self ACE. | ✅ Configured | Not exercised. |
|| WT025 | AdminSDHolder persistence | DA modifies AdminSDHolder template | `analyst_cloud` WriteDacl on AdminSDHolder (ACE6). | ✅ VERIFIED 2026-07-31 | Backdoor GenericAll ACE added + persisted; DACL restored to pristine 23 ACEs (was polluted to 99). Exploit `t025-adminsdholder-exploit.ps1`; restore `t025-restore.ps1` + `t025-readd-aces.ps1`. |

**Verdict:** Branch A is now fully verified end-to-end (2026-07-31). All ACE-based attacks (WT015/013/014/016/008/023/024/GPP/WT025) were executed from ws01 via direct SSH (Rule 1). Only WT027 (SPN jacking) remains: surface configured, not exercised.

---

### 2.13 Branch B (ADCS)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|------------|
| WT050 | ESC1 | `CADRE-ESC1` template: enrollee supplies subject, ClientAuth, Domain Users Enroll | `adcs-configuration-guide.md` Phase 2. | ✅ VERIFIED 2026-08-01 | Req 39 + `-sid` + `-dynamic-endpoint` → PKINIT TGT + UnPAC NT hash `81c3b644…f1eb7b`. |
| ESC2 | Any Purpose EKU | `CADRE-ESC2`: Any Purpose EKU + Supply Subject (also flags ESC3+ESC17) | Same. | ✅ VERIFIED 2026-08-01 | Req 45 as low-priv `hunter_dfir` → PKINIT TGT as administrator. |
| WT051 | ESC3 | `CADRE-ESC3-Agent` + `CADRE-ESC3-Target` templates | Same. | ✅ VERIFIED 2026-08-01 | Agent cert + `-on-behalf-of "cadre\administrator"` (NetBIOS) → admin cert Req 44. |
| ESC4 | WriteDacl | `CADRE-ESC4`: Engineering-Cadre (lead_engineering) WriteDacl/Full Control | Same. | ✅ VERIFIED 2026-08-01 | `certipy template -write-default-configuration` as lead_engineering → Req 47 → NT hash; **template restored** (NameFlag verified). |
| ESC7 | CA officer/manager | cadre-CA: lead_engineering ManageCa + ManageCertificates + Enroll + Read | `05-ad-attack-surface.yml` sets CA ACLs. | ✅ VERIFIED 2026-08-01 | `certipy ca -add-officer hunter_dfir` succeeded (ManageCA) + removed. |
| ESC8 | NTLM relay to web enrollment | Web Enrollment + NetworkService app pool | `adcs-configuration-guide.md` Phase 1. | 🔬 DEFERRED | Surface configured; **no SMB-authenticated coerce on Server 2025** (root cause documented 2026-08-01). Revisit at end. |
| WT053 | UnPAC-the-Hash | Cert + EKU + `certipy auth` | Same templates + tools. | ✅ VERIFIED 2026-08-01 | PKINIT TGT + U2U → administrator NT hash. |
| ESC9 | NoSecurityExtension | `CADRE-ESC9`: `NO_SECURITY_EXTENSION` + EnrolleeSuppliesSubject | Same. | ✅ VERIFIED 2026-08-01 | Req 46 as `hunter_dfir` → PKINIT TGT + UnPAC NT hash. |
| ESC11 | ICPR no encryption | cadre-CA: Enforce Encryption for Requests = Disabled | CA-level. | 🔬 Deferred | Relay family — deferred with ESC8. |
| ESC6 | User Specified SAN | CA `EDITF_ATTRIBUTESUBJECTALTNAME2` | Not set (User Specified SAN = Disabled). | ❌ Not deployed | Campaign docs list ESC6; CA flag NOT enabled. |
| ESC13 | Issuance Policy → group | `CADRE-ESC13` template | Template does NOT exist. | ❌ Not deployed | Campaign docs list it; never created. |
| ESC14 | altSecurityIdentities | `CADRE-ESC14` template | Template does NOT exist. | ❌ Not deployed | Campaign docs list it; never created. |

**Verdict:** Branch B live surface (fresh `certipy find -vulnerable` 2026-08-01) = CA cadre-CA (ESC7/ESC8/ESC11) + templates CADRE-ESC1/2/3-Agent/3-Target/4/9. **ESC1/ESC2/ESC3/ESC4/ESC7/ESC9 + UnPAC all VERIFIED 2026-08-01** (low-priv hunter_dfir enrollments → PKINIT admin; lead_engineering ESC4/ESC7; ESC4 template restored). ESC8/ESC11 deferred (no SMB coerce / relay family). ESC6 not enabled; ESC13/14 templates absent. Recurring flags: `-sid`, `-dynamic-endpoint`, NetBIOS `-on-behalf-of`, kill certipy procs before `certipy auth`.

---

### 2.14 Branch C (SCCM)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| WT034 | SCCM NAA extraction | NAA configured on site CAD; `vault` bait share | `sccm-integration-guide.md` Phase 7 (manual console). | ✅ VERIFIED | Bait file read as `svc_sccm` → `RANGE\svc_naa` (DA); NAA confirmed in provider (`SMS_SCI_ClientComp` `Network Access User Names`). |
| WT035 | SCCM PXE Boot abuse | PXE enabled w/o password + boot images | Same (console). | ✅ Surface verified 2026-08-01 | Approved PXE cert (`{256B7D4F-…}`, MBR02) + 2 boot images (x64/arm64) readable by `svc_sccm`; full exploit needs a real PXE client. |
| WT036 | SCCM Client Push install | Auto client push enabled | Same. | ⚠️ Primitive verified | Component enabled; `GenerateCCRByName`/`CreateCCR` available; relay needs console-created target device record. |
| WT037 | SCCM CMPivot | AdminService (`/AdminService`, self-hosted REST provider) | **VERIFIED 2026-08-02** | ✅ FULL EXEC | `RunCMPivot` on WS01 (16777220) via AdminService as `svc_sccm` (NTLM) returned live data (`DeviceID:"C:", FileSystem:"NTFS", FreeSpace:153601, SystemName:"WS01"`). Enablers: BGB fast channel restored (bgbisapi.msi → TCP 10123) + svc_sccm Full Admin via DB Takeover-1 grant. |
| WT038 | SCCM Application Deployment | SCCM admin can create + deploy apps | AdminService + MP policy channel (guide Phase 6C). | ✅ **FULL EXEC VERIFIED 2026-08-02** | App 16777510 + DT 16777511 + assignment 16777217 via AdminService; MP web handlers repaired (`mp.msi REINSTALL` — were empty → 500) → client policy delivered → payload ran **as SYSTEM** on WS01 (`wt038-system.txt` = `nt authority\system` + `wt038-marker.txt`). |
| WT039 | SCCM Site Takeover | SCCM admin → client/system exec | **VERIFIED 2026-08-02** | ✅ FULL EXEC | Script created via `/AdminService/wmi/SMS_Scripts.CreateScripts/`, approved via DB (`Scripts` table ApprovalState=3 — author self-approval → 500), run via `RunScript` on WS01 → `ScriptOutput: "nt authority\\system"` + on-disk markers on WS01. |

**Key findings (2026-08-01):** SCCM admin gate = local `SMS Admins` group (svc_sccm + **cross-forest `CADRE\chief_command`/`analyst_purple`**). **SPN owner FIXED:** `HTTP/mbr02.range.local` moved to `mbr02$` (AdminService runs as LocalSystem → machine-account tickets only); svc_sccm keeps decoy `HTTP/sccm.range.local` (WT033 Kerberoast) + `msDS-AllowedToDelegateTo=HTTP/mbr02.range.local` CD (unchanged). AdminService IS deployed (self-hosted). **WT037/039 auth gate VERIFIED CLOSED (2026-08-01):** getST → ST encrypted to `mbr02$` → `AdminService/wmi/SMS_Site` **200** as Administrator (anon 401). **`cifs/mbr02.range.local` SPN MISSING** → SMB Kerberos to mbr02 broken (NTLM-only; verify-playbook candidate). Site CAD build 9141; 1 device (MBR02); 0 task sequences; 2 boot images.

**Verdict:** Branch C surface + primitives verified 2026-08-01; **WT037 CMPivot + WT039 script-as-SYSTEM FULL EXEC VERIFIED 2026-08-02** (live data + `nt authority\system` on WS01 from ws01 as `svc_sccm`). Enablers: BGB fast channel (bgbisapi.msi → TCP 10123), svc_sccm Full Admin via DB Takeover-1 grant, script approval via DB. Recipes in `docs/sccm-integration-guide.md` Phase 6B. WT038 app creation + deployment via AdminService now works (app 16777510 / DT 16777511 / assignment 16777217 / policy body); **client delivery root-caused to broken MP web handlers** (empty `SMS_MP`/`ServiceData\System` → `/SMS_MP/.sms_aut` 500) — `mp.msi` REINSTALL repair (guide Phase 6C + 6C.4). Remaining: WT035 PXE (needs real PXE client), WT036 client-push relay (needs console-created device), WT038 delivery (MP repair completing).

---

### 2.15 Branch D (Linux Pivot)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| WT044 | MSSQL linked server recon | `mbr01` linked server to `LINUX01`, `analyst_t1` IMPERSONATE | `sql-integration-guide.md` configures linked server. | ✅ VERIFIED | OPENQUERY to LINUX01.master.sys.databases returns linux01 databases. |
| WT045 | SSSD ticket extraction | SSSD cache + valid session on `linux01` | `07-linux-config.yml` (keytab ensure task added 2026-08-01). | ✅ VERIFIED 2026-08-01 | Keytab recreated (was corrupt → sssd dead); SSSD cache active/fresh; `getent passwd mssql-linux01` resolves. |
| WT046 | MSSQL keytab extraction | `mssql.keytab` on `linux01` | `sql-integration-guide.md` creates keytab. | ✅ VERIFIED 2026-08-01 | Keytab readable from pivot root. |
| WT047 | NFS Kerberos mount | NFS server with `sec=krb5p` export on `linux01` | `07-linux-config.yml` NFS section (svcgssd/idmapd/nfs-principal tasks added 2026-08-01). | ✅ VERIFIED 2026-08-01 | Fixed svcgssd + idmapd Domain + nfs SPNs; **mount by FQDN with `sec=krb5p` + read OK** (write denied — root-owned 0755 dir). |
| WT048 | Podman container escape | Podman + privileged/misconfigured container | `07-linux-config.yml` (sudo misconfig task added 2026-08-01) + podman on linux01. | ✅ VERIFIED 2026-08-01 | `sudo podman exec cadre-monitor unshare -r id` → **root** + host read/write. |

**Verdict:** Branch D fully verified 2026-08-01 (WT044-048). Config fixes propagated to `07-linux-config.yml`/`-verifyOnly.yml` + `sql-integration-guide.md` §3.4/§3.5.

---

### 2.16 Branch G (CVE-2026-41089)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| CVE-2026-41089 | Netlogon CLDAP overflow | `dc02` unpatched, UDP/389 reachable, PoC on `Kali` | No playbook deliberately keeps `dc02` vulnerable; PoC is in `docs/internal/references/sources/cve-2026-41089/`. | ❌ Missing (by design) | The lab is either vulnerable or not based on patch level. No playbook should force vulnerability. |

**Verdict:** Branch G is intentionally a "test if still vulnerable" item. It should not be a playbook target; it should be a validation-only check.

---

### 2.17 E Stream — Network Defense

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| E-01..E-14 | Detection rule validation | Zeek + Suricata + Elastic on `monitor` | `13-net-monitor.yml` + `12-elk-fleet.yml` configure sensors. | ✅ Sensors configured | The *attack* side is not a surface; it is the same attacks replayed for detection. |

**Verdict:** E stream is not an attack-surface gap. It is a telemetry/execution gap. The sensors are configured but the exercises have not been run.

---

### 2.18 F Stream — Supply Chain

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| F-01..F-13 | npm supply-chain scenarios | npm registry, mock sink, `auditd`, Node.js on `linux01`/`mbr01` | `16-supplychain.yml` installs Node.js + mock sink + auditd. | ✅ Tools configured | The actual malicious package scenarios are not automated. |

**Verdict:** F stream tools are configured but the attack scenarios themselves (publish typosquat, malicious dependency, etc.) are not playbook-defined.

---

## 3. Cross-Cutting Infrastructure Gaps

### 3.1 Credentials / Password Spray (WT031)

- **Campaign status:** WT031 password spray verified against `dc01` and yielded `chief_command`, `hunter_dfir`, `analyst_dfir`, `analyst_cloud`, `eng_agentic`.
- **Playbook coverage:** No playbook creates the `cadre_passwords.txt` wordlist or validates that these accounts share weak passwords. The spray is purely an attack technique.
- **Audit flag:** This is not a surface gap, but it is a **lab design assumption** that should be documented: the root-domain accounts are intentionally weak/sprayable so that the campaign can bridge Branch A/B. If the live lab passwords differ, Branch A/B scripts fail. The validation report already caught this.

### 3.2 Print Spooler on dc02 (T102 / Phase 6/7 main path)

- **Issue:** `04-vulnerabilities.yml` enables `Spooler` on Windows hosts generally, but the validation run shows `dc02$` coercion did not produce tickets and `Spooler` was "not running/exposed" on `dc02`.
- **RESOLVED (2026-08-01):** Spooler service confirmed **enabled on all 3 DCs** (dc01/dc02/dc03) via `nxc smb -M spooler` — all report "Spooler service enabled". The earlier "not running/exposed on dc02" issue is closed; the `04-vulnerabilities.yml` Spooler + SMB/RPC firewall prerequisites are in place.
- **Related:** T102 `dc02$` TGT capture VERIFIED 2026-07-31 (hostname listener for Kerberos, kirbi→ccache → Phase 6 DCSync).

### 3.3 ADCS Templates (Branch B)

- **Issue:** ADCS templates are configured via manual guide, not playbook. The verify playbook (`08-adcs-verify.yml`) checks them.
- **Risk:** If the lab is rebuilt from scratch, ADCS attack surface is lost unless the manual steps are repeated or the snapshot is restored.
- **Audit flag:** This is a known accepted limitation (Server 2025 + PSPKI automation failure). The snapshot `adcs-templates-done` is the mitigation. Not a flaw in the live lab, but a fragility.

### 3.4 SCCM (Branch C)

- **Issue:** SCCM is manually deployed on `mbr02`. The verify playbook (`10-sccm-verify.yml`) checks key components.
- **Risk:** Same as ADCS — rebuild requires manual work.
- **Audit flag:** Known accepted limitation. Snapshot `sccm-done` is the mitigation.

### 3.5 Linux Surfaces (Branch D)

- **Issue:** `07-linux-config.yml` joins `linux01` to the domain, installs SQL Server, and sets up the keytab, but does **not** configure SSSD as an attackable cache, NFS server, or Podman.
- **Fix:** Add Linux playbook sections (or a new `07-linux-attack-surface.yml`) to:
  - Enable SSSD and cache a Kerberos ticket for a domain user.
  - Install/configure NFS server with `sec=krb5p` export.
  - Install Podman and deploy a privileged container with a misconfigured volume/capability.

### 3.6 Initial Access (Phase 0.5 / H)

- **Issue:** No playbook configures the initial access vectors. The campaign assumes the operator will stage them.
- **Fix:** Add `19-initial-access.yml` that:
  - Stages a malicious LNK/MSI/CHM/HTML/AutoIt/EXE payload on `Kali`.
  - Drops a payload into `ws01` `C:\Users\analyst_t1\Downloads\` or similar.
  - Optionally creates a fake phishing email/document.
  This is not a vulnerability surface, but it is a campaign dependency that should be automated for reproducibility.

### 3.7 E/F Stream Attack Scenarios

- **Issue:** Tools are installed, but the actual attack scenarios are not playbook-defined.
- **Fix:**
  - E: Add `tools/plan1-verify-campaign-e.sh` replay attacks and confirm Suricata/Zeek/Elastic fires. (Already partially exists.)
  - F: Add `16-supplychain.yml` scenario definitions or a separate `16-supplychain-scenarios.yml` that actually publishes malicious npm packages to the mock registry.

---

## 4. Prioritized Fix List

| Priority | Item | Action | Playbook/Guide |
|---|---|---|---|
| **P0** | `dc02` Spooler not running/exposed | **RESOLVED 2026-08-01** — Spooler confirmed enabled on all 3 DCs (`nxc smb -M spooler`); T102 TGT capture chain VERIFIED 2026-07-31. | `04-vulnerabilities.yml` |
| **P0** | Branch A/B credential bridge | Ensure `chief_command` / `hunter_dfir` passwords are in the sprayable set; document in `lab-seed-creds.json`. | `02-ad-objects.yml` + docs |
| **P1** | Branch D Linux surfaces | Add SSSD ticket cache, NFS `sec=krb5p`, Podman privileged container to `linux01`. | `07-linux-config.yml` or new `07-linux-attack-surface.yml` |
| **P1** | Phase 0.5 / H initial access | Stage payloads on `Kali` and `ws01` drop directory. | New `19-initial-access.yml` |
| **P1** | 3.5 missing tools | Install Nemesis, LAPS, configure WerFault dump keys, deploy AAD Connect sync (not just provisioning agent). | `06-member-services.yml`, `07-linux-config.yml`, `15-cloud-sync.yml` |
| **P2** | GPP / AdminSDHolder | Add `Groups.xml` with cpassword to SYSVOL; configure AdminSDHolder writable ACL. | `02-ad-objects.yml` + `05-ad-attack-surface.yml` |
| **P2** | F stream scenarios | Automate malicious npm package scenarios against mock registry. | `16-supplychain.yml` |
| **P2** | E stream replay | Run each Phase 0-8 attack while monitor is online and confirm rule fires. | `tools/plan1-verify-campaign-e.sh` |
| **P3** | ADCS/SCCM fragility | Keep snapshots; optionally invest in ldifde/CLI automation for ADCS templates. | `adcs-configuration-guide.md`, `sccm-integration-guide.md` |

---

## 5. Items That Are Correctly NOT Configured

These are either rejected by modern defaults (Server 2025) or intentionally deferred for safety:

- **WT028** null session / SAMR anonymous — blocked by Server 2025.
- **WT018** PetitPotam / MS-EFSR — hardened on Server 2025.
- **WT020** ShadowCoerce / MS-FSRVP — not a default service.
- **3.5I** Token impersonation — Server 2025 session isolation.
- **3.5N** UnCanny LPE — requires Developer Mode, intentionally deferred.
- **WT094** UnCanny Coerce — same as above.
- **WT095** Onelogon — PoC not available; cannot force vulnerability.
- **Skipjack** — custom tool not built; cannot force vulnerability.
- **CVE-2026-41089** — depends on patch state; should not be forced vulnerable.

---

## 6. Recommendation

The lab is **close to complete** for the main Windows AD spine and the core ADCS/SCCM branches. As of 2026-08-01:

1. **Branch D (Linux pivot) is COMPLETE** (WT044-048 verified; config fixes propagated to playbooks + guide).
2. **Branch B is nearly complete** — ESC1/2/3/4/7/9 + UnPAC verified; **ESC8 (WT052) + ESC11 deferred** (no SMB-authenticated coerce on Server 2025 — root cause documented; revisit at end with Kerberos-relay candidates).
3. **Branch C (SCCM)** surface + primitives verified; full exec gated on **AdminService deployment** (`sccm-integration-guide.md` Phase 6A + `10-sccm-verify.yml` checks added; user to configure).
4. **Automate Phase 0.5 / H** initial access staging.
5. **Add missing 3.5 tools** (Nemesis, LAPS, WerFault, AAD Connect) if those techniques are required.
6. **Run E/F stream scenarios** as exercises, not surface configuration.

Once the AdminService is deployed and the ESC8/11 revisit lands, the campaign can be re-run cleanly from Phase 0 through Phase 8 with the designed credential flow, and the validation report can move many `⏳`/`⚠️` items to `✅`.

---

*Generated 2026-07-30 from playbook/guide review vs CAMPAIGNS-VALIDATION-REPORT.md.*
## Appendix A — Consolidated Campaign Re-test Matrix

> Updated: 2026-08-02 (Branch A all verified; Branch B ESC1/2/3/4/7/9+UnPAC verified, ESC8/11 deferred; Branch D WT044-048 verified; **Branch C WT037 CMPivot + WT039 script-as-SYSTEM FULL EXEC VERIFIED 2026-08-02**, WT038 app+deployment via AdminService, delivery pending MP repair; spooler resolved; WT002/WT007 verified)

| ID | Stream | Attack | Source Machine | Credentials | Status | Re-test / Fix Notes |
|---|---|---|---|---|---|---|
| WT015 | Branch A | ACE#7 ForceChangePassword | ws01 | hunter_dfir / DF1R_Hunt3r! | ✅ VERIFIED 2026-07-31 | ACE#7 re-applied; password reset + restore verified; 18/18 verify PASS. |
| WT013 | Branch A | WriteDacl self-escalate | ws01 | chief_command / C0mm@nd_Ch1ef! | ✅ VERIFIED 2026-07-31 | GenericAll on CN=Command-Cadre; ACE read-back verified. |
| WT014 | Branch A | GenericWrite → Shadow Creds | ws01 | chief_command / C0mm@nd_Ch1ef! | ✅ VERIFIED 2026-07-31 | GenericWrite on analyst_cloud; ACE read-back verified. |
| WT016 | Branch A | GenericAll on OU | ws01 | chief_command / C0mm@nd_Ch1ef! | ✅ VERIFIED 2026-07-31 | GenericAll on OU=Command; ACE read-back verified. |
| WT008 | Branch A | Shadow Creds on dc01$ | ws01 | chief_command / C0mm@nd_Ch1ef! | ✅ Verified | pywhisker → dc01$ KeyCredential; PKINIT TGT; NT hash recovered. |
| WT023 | Branch A | GPO Abuse | ws01 | analyst_cloud / Cl0ud_An@lyst! | ✅ Verified | WriteDacl/WriteOwner/GenericAll on Vulnerable-GPO; preference write confirmed. |
| WT024 | Branch A | gMSA extraction | ws01 | eng_cloud / Cl0ud_Eng! | ✅ Verified | ACE#10 LDAPS bind → blob decode → NT hash → SMB auth OK. |
| GPP | Branch A | GPP stored password | ws01 | analyst_cloud / Cl0ud_An@lyst! | ✅ Verified | Groups.xml cpassword → svc_ldap / s3rv1c3_Ld@p!; SMB auth verified. |
| WT025 | Branch A | AdminSDHolder persistence | ws01 | analyst_cloud / Cl0ud_An@lyst! | ✅ VERIFIED 2026-07-31 | Backdoor ACE persisted; DACL restored to pristine 23 ACEs. |
| WT050 | Branch B | ADCS ESC1 | ws01 | chief_command / C0mm@nd_Ch1ef! | ✅ VERIFIED 2026-08-01 | Req 39 + `-sid` + `-dynamic-endpoint` → PKINIT + UnPAC NT hash. |
| WT051 | Branch B | ADCS ESC3 | ws01 | chief_command / C0mm@nd_Ch1ef! | ✅ VERIFIED 2026-08-01 | Agent + `-on-behalf-of` → admin cert Req 44. |
| WT052 | Branch B | ADCS ESC8 | ws01 | chief_command / C0mm@nd_Ch1ef! | 🔬 DEFERRED | No SMB-authenticated coerce on Server 2025 (root cause documented). Revisit at end. |
| WT053 | Branch B | UnPAC-the-Hash | ws01 | chief_command / C0mm@nd_Ch1ef! | ✅ VERIFIED 2026-08-01 | PKINIT + U2U → NT hash `81c3b644…f1eb7b`. |
| ESC2 | Branch B | Any Purpose EKU (CADRE-ESC2) | ws01 | hunter_dfir → admin | ✅ VERIFIED 2026-08-01 | Req 45 → PKINIT TGT as administrator. |
| ESC4 | Branch B | WriteDacl (CADRE-ESC4) | ws01 | lead_engineering | ✅ VERIFIED 2026-08-01 | Template modify → Req 47 → NT hash; **template restored**. |
| ESC7 | Branch B | CA officer (cadre-CA) | ws01 | lead_engineering | ✅ VERIFIED 2026-08-01 | `certipy ca -add-officer` (ManageCA) + removed. |
| ESC9 | Branch B | NoSecurityExtension (CADRE-ESC9) | ws01 | hunter_dfir → admin | ✅ VERIFIED 2026-08-01 | Req 46 → PKINIT + UnPAC NT hash. |

| WT003 | Phase 1 | AS-REP Roast | ws01 (direct SSH) | intern_blue / 1nt3rn_Blu3! | ✅ Verified | Via `ws01` direct SSH as `analyst_t1` — per attack-origin rule. | No |
| WT002 | Phase 2 | Kerberoast via ACE#18 | ws01 (direct SSH) | intern_blue / 1nt3rn_Blu3! | ✅ VERIFIED 2026-07-31 | ACE#18 bridge + getTGT AES path; `svc_mssql` TGS cracked to `s3rv1c3_MSSQL!`; analyst_t2 pw restored. | No |
| WT041/043 | Phase 3 | SQL xp_cmdshell + GodPotato | ws01 -> mbr01 | analyst_t1 / T13r_An@lyst! | ✅ VERIFIED 2026-08-01 | SQL auth → xp_cmdshell (mssql$sqlexpress) → GodPotato-NET4 → **SYSTEM on mbr01**; Winlogon creds extracted (T035A). |
| 3.5A | Phase 3.5 | Winlogon plaintext extraction | SYSTEM on mbr01 | SYSTEM | ✅ Verified | T035A extracted `analyst_cloud:Cl0ud_An@lyst!` from Winlogon registry as SYSTEM. |
| 3.5C | Phase 3.5 | RDP interactive session | ws01 -> mbr01 | analyst_cloud / Cl0ud_An@lyst! | ⠿ Blocked | No dedicated execution script found in `attack-matrix/04-automation/` | Yes — add/verify script |
| WT044 | Branch D | MSSQL linked server recon | linux01 | analyst_t1 / T13r_An@lyst! | ✅ VERIFIED | OPENQUERY → linux01 databases. |
| WT045 | Branch D | SSSD ticket extraction | linux01 | mssql-linux01 pivot | ✅ VERIFIED 2026-08-01 | Keytab recreated; SSSD cache active. |
| WT046 | Branch D | MSSQL keytab extraction | linux01 | mssql-linux01 pivot → root | ✅ VERIFIED 2026-08-01 | Keytab readable from pivot root. |
| WT047 | Branch D | NFS Kerberos mount | linux01 | mssql-linux01 + TGT | ✅ VERIFIED 2026-08-01 | krb5p mount + read (svcgssd/idmapd/SPN fixed). |
| WT048 | Branch D | Podman container escape | linux01 | mssql-linux01 → sudo root | ✅ VERIFIED 2026-08-01 | `unshare -r id` → root + host read/write. |
| WT034 | Branch C | SCCM NAA extraction | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ✅ Verified | Vault bait → `RANGE\svc_naa` (DA); confirmed in provider. |
| WT035 | Branch C | SCCM PXE Boot | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ✅ Surface verified 2026-08-01 | PXE cert + 2 boot images + NAA-in-policy; full exploit needs PXE client. |
| WT036 | Branch C | SCCM Client Push | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ⚠️ Primitive verified | Component enabled + CCR methods; relay needs console target. |
| WT037 | Branch C | SCCM CMPivot | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ✅ FULL EXEC VERIFIED 2026-08-02 | `RunCMPivot` (LogicalDisk) → live WS01 data via AdminService as svc_sccm (enablers: BGB fast channel + Takeover-1 DB grant). |
| WT038 | Branch C | SCCM App Deploy | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ✅ FULL EXEC VERIFIED 2026-08-02 | App (CI 16777510) + DT (16777511) + assignment (16777217) via AdminService; delivery blocker = empty MP web handlers (`SMS_MP`/`ServiceData\System` → `/SMS_MP/.sms_aut` 500) — fixed via `mp.msi REINSTALL=ALL` → health 200 → client policy delivered → payload ran as SYSTEM on WS01 (`nt authority\system` + marker). |
| WT039 | Branch C | SCCM Site Takeover | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ✅ FULL EXEC VERIFIED 2026-08-02 | Script create (`SMS_Scripts.CreateScripts`) → DB approve (`Scripts` table) → `RunScript` → `ScriptOutput: "nt authority\\system"` + on-disk markers on WS01. |
| E-01..E-14 | E stream | Network defense exercises | monitor/elk | — | ⏳ Configured | Sensors configured; exercises pending. Keep offline until telemetry phase. |
| F-01..F-13 | F stream | npm supply-chain scenarios | linux01/mbr01 | — | ⏳ Configured | Tooling configured; scenarios pending. |
| G | Branch G | CVE-2026-41089 | Kali | — | 🔬 Deferred | PoC present; depends on dc02 patch state. |
| H-01..H-06 | Phase 0.5 | Initial access payloads | Kali/ws01 | — | ❌ Missing | No playbook stages payloads; needs `19-initial-access.yml`. |

