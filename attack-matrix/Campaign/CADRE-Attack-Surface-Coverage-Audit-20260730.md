# CADRE Attack-Surface Coverage Audit vs Campaign v3

> Scope: compare the configured lab surface (Ansible playbooks + integration guides) against the attack expectations in `CAMPAIGNS_v3.md` / `CAMPAIGNS-METADATA-v2.md` and the validation report.
> Status flags: ✅ configured / ⚠️ partially or misconfigured / ❌ missing / 🔬 intentionally deferred / ⏳ configured but not exercised.
> SSoT principle: the actual live lab is the source of truth; playbooks/guides are written/updated after manual setup to reflect it.

## 1. Executive Summary

| Category | Configured | Partial / Misconfigured | Missing / Not Configured | Deferred |
|---|---|---|---|---|
| Main spine (Phases 0-8) | 23 | 5 | 2 | 1 |
| Branch A (ACL abuse) | 4 | 5 | 1 | 0 |
| Branch B (ADCS) | 4 | 0 | 0 | 0 |
| Branch C (SCCM) | 2 | 0 | 3 | 0 |
| Branch D (Linux pivot) | 1 | 0 | 4 | 0 |
| Branch G (CVE-2026-41089) | 0 | 0 | 1 | 0 |
| Phase 0.5 / H (initial access) | 0 | 0 | 6 | 0 |
| E (network defense) | 0 | 0 | 14 | 0 |
| F (supply chain) | 0 | 0 | 13 | 0 |

**Key findings:**
1. The biggest gap is **Phase 0.5 / H (initial access)**: no playbook configures the payloads/drop vectors on `ws01` or `Kali`. The surface is assumed by the campaign but not automated.
2. **Phase 5 coercion / T102** trigger path is now configured: `dc02` Spooler + SMB/RPC firewall prerequisites are added to `04-vulnerabilities.yml`. Live test showed trigger works, but Rubeus capture still returned 0 Kirbi markers for `DC02$`; treat as **trigger verified / capture pending**.
3. **Branch A** has a credential-design issue now fixed in scripts/docs, but relies on a password spray (WT031) that is not configured as an official playbook path.
4. **Branch C** after WT034 is configured but WT035-039 require running from `mbr02` itself; the campaign scripts currently run from `ws01` and are not exercised.
5. **Branch D** Linux pivot is mostly missing: SSSD/keytab/NFS/Podman surface is not configured in the Linux playbook.
6. **E and F** streams are not attack-surface configurations; they are detection/supply-chain exercises that depend on monitor and linux01/mbr01 tooling. No playbooks configure the *attack* side of E/F (they configure only the sensors/registry).
7. **Branch G** is a standalone unauthenticated DC exploit; no playbook configures a vulnerable state — it relies on dc02 simply being unpatched.

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
| 3.5B | Scheduled Task as `analyst_cloud` | Task scheduler access | Default; but campaign rejected as execution wrapper. | ⏳ Default | Not a surface gap. |
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
| WT007 | RBCD standalone | `msDS-AllowedToActOnBehalfOfOtherIdentity` writable on `mbr01`/`dc02` | `05-ad-attack-surface.yml` does not seem to pre-populate RBCD; relies on ACL. | ⚠️ Partial | Script blocked from `ws01` due to LDAP context; surface may exist but attack path is brittle. |
| WT017 | PrinterBug / MS-RPRN | Spooler service running on target, SMB open | `04-vulnerabilities.yml` enables Spooler on `mbr01`; `dc02` Spooler not running/exposed. | ⚠️ Partial | Confirmed from `mbr01` target, but `dc02` coercion (T102) fails. |
| WT018 | PetitPotam / MS-EFSR | `\PIPE\efsrpc` accessible | Server 2025 hardens this; no playbook. | 🔬 Rejected | Correctly not configured. |
| WT019 | DFSCoerce / MS-DFSNM | DFS Namespace feature installed | `04-vulnerabilities.yml` installs FS-DFS-Namespace. | ✅ Configured | But Suricata cannot detect SMB-pipe DCE-RPC; functionally not useful. |
| WT020 | ShadowCoerce / MS-FSRVP | File Server VSS Agent service | Not installed by default on Server 2025. | ❌ Missing | Out of scope for lab. |
| WT021 | NTLM relay → LDAP | LDAP signing not required on `dc01` | `04-vulnerabilities.yml` sets `LDAPServerIntegrity=1`. | ✅ Configured | Confirmed. |
| WT022 | NTLM relay → ADCS web enrollment | Web Enrollment + NetworkService app pool | `adcs-configuration-guide.md` Phase 1 configures this. | ✅ Configured | Confirmed. |
| WT094 | UnCanny Coerce | Developer Mode + loose AppX registration | Not configured. | 🔬 Deferred | Correctly not configured. |
| WT095 | Onelogon Zero-Channel | Unpatched single-channel NRPC | No playbook can make a DC vulnerable; relies on patch state. | 🔬 Deferred | PoC not released. |
| WT096 | `coerce_plus` consolidated | NetExec module + any working coercion | NetExec installed; but no target surface beyond WT017. | ⚠️ Partial | Same as WT017/WT018/WT019/WT020. |
| T102 | Unconstrained delegation capture `dc02$` | `dc02` Spooler exposed, `mbr01` Rubeus monitor | **`dc02` Spooler prerequisites added to deploy/verify playbooks.** | ⏳ Trigger verified / capture pending | Trigger works; Rubeus capture still returns 0 Kirbi for `DC02$`. Re-test after fresh verify-only run. |

**Verdict:** Phase 5 coercion prerequisites are now aligned in playbooks. Live testing shows the trigger path works, but ticket capture is still unconfirmed. The remaining gap is likely the Rubeus capture method/format on `mbr01`, not `dc02` exposure.

**Next step:** Run `04-vulnerabilities-verifyOnly.yml` to confirm `dc02` spooler/RPC state, then re-test T102 capture path before treating it as fully verified.

---

### 2.9 Phase 6 (DCSync)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| WT009 | DCSync | `dc02$` TGT or DA account with replication rights | `05-ad-attack-surface.yml` grants DCSync rights via ACE#13+14 to `eng_agentic`; `chief_command` is DA. | ✅ Configured | Confirmed via `chief_command` fallback. Main path via `dc02$` TGT blocked by T102. |

---

### 2.10 Phase 7 (Golden/Silver/Diamond Ticket)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| WT010 | Golden Ticket | `krbtgt` hash from DCSync | Depends on Phase 6. | ✅ Configured (fallback) | Script runs with `chief_command` fallback. |
| WT011 | Silver Ticket | Service account hash | Same. | ✅ Configured | Script runs. |
| WT012 | Diamond Ticket | `krbtgt` hash + legitimate TGT | Same. | ✅ Configured | Script runs. |

**Verdict:** Phase 7 surface is fine; the dependency is Phase 6 producing the real `krbtgt` hash from `dc02`.

---

### 2.11 Phase 8 (Cross-forest)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| WT033 | Cross-forest Kerberoast | Two-way trust, SID filter OFF, `svc_sccm` SPN in `range.local` | `00-domain-deploy.yml` creates trust; `05-ad-attack-surface.yml` registers SPN. | ✅ Configured | Confirmed. |
| WT034 | SCCM NAA extraction | SCCM site with NAA, `svc_sccm` SCCM Full Admin, vault share | `sccm-integration-guide.md` + `06-member-services.yml` configure this. | ✅ Configured | Confirmed. |
| WT035-039 | SCCM escalation chain | PXE, client push, CMPivot, app deploy, site takeover | Same as WT034, but execution surface requires running from `mbr02`. | ⚠️ Partial | Surface configured; scripts need to run from `mbr02` not `ws01`. |
| Skipjack | PAC signature corruption | Cross-forest trust + SID filter OFF + custom tool | Trust is configured; custom tool not available. | 🔬 Deferred | PoC not built. |

---

### 2.12 Branch A (ACL Abuse)

|| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
|| WT015 | ACE#7 ForceChangePassword | `hunter_dfir` → `chief_command` ForceChangePassword | `05-ad-attack-surface.yml` ACE#7; not currently exposed to `hunter_dfir`. | ⠿ Blocked | Surface exists in design, but retest shows missing ACE exposure; rerun after ACE#7 verify-only pass. |
|| WT013 | WriteDacl self-escalate | `chief_command` → `hunter_dfir` GenericAll on Command-Cadre group | `05-ad-attack-surface.yml` does not explicitly pre-configure this; relies on script. | ⚠️ Partial | Script corrected; re-test pending. |
|| WT014 | GenericWrite → Shadow Creds | `chief_command` → `hunter_dfir` GenericWrite on `analyst_cloud` | Same as above. | ⚠️ Partial | Script corrected; re-test pending. |
|| WT016 | GenericAll on OU | `chief_command` → `hunter_dfir` GenericAll on `OU=Command` | Same. | ⚠️ Partial | Script corrected; re-test pending. |
|| WT008 | Shadow Creds on `dc01$` | `chief_command` can write KeyCredential to `dc01$` | Same. | ⚠️ Partial | Script corrected; re-test pending. |
|| WT023 | GPO Abuse | `analyst_cloud` GPO edit rights, WMI-Filtered-GPO linked to OU=Agentic | `02-ad-objects.yml` creates GPO + link; `05-ad-attack-surface.yml` ACE#1 grants `analyst_cloud` rights. | ✅ Configured | Script corrected; re-test pending. |
|| WT024 | gMSA extraction | `gmsaTools` gMSA with SACL, `GoldenGMSA` tool | `05-ad-attack-surface.yml` creates gMSA + SACL; `06-member-services.yml` copies GoldenGMSA? | ✅ Configured | Script corrected; re-test pending. |
|| GPP | GPP stored password | `Groups.xml` in SYSVOL with cpassword | No playbook creates this. | ❌ Missing | Surface not configured. |
|| WT027 | SPN jacking (CVE-2026-25177) | `analyst_cloud` self ValidatedWriteSPN, homoglyph SPN pre-staged | `05-ad-attack-surface.yml` pre-stages homoglyph SPN and self ACE. | ✅ Configured | Not exercised. |
|| WT025 | AdminSDHolder persistence | DA modifies AdminSDHolder template | No playbook pre-configures writable AdminSDHolder for a non-DA. | ❌ Missing | Requires a very specific ACL setup not in playbooks. |

**Verdict:** Branch A now has one confirmed blocker (`WT015`) from retest evidence. Other ACE-based attacks are scripted and await rerun after ACE exposure or alternate routing is validated. Current operator SSH path is also blocked: local `ssh-agent` is unavailable (`Error connecting to agent: No such file or directory`; service Stopped/Disabled) and direct `localhost -> ws01` SSH returns `Permission denied (publickey,keyboard-interactive)`; rerun requires ACE#7 verify-only pass **and** working SSH access to `ws01`.

---

### 2.13 Branch B (ADCS)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|------------|
| WT050 | ESC1 | `CADRE-ESC1` template: enrollee supplies subject, ClientAuth, Domain Users Enroll | `adcs-configuration-guide.md` Phase 2. | ✅ Configured | Script corrected to use `chief_command`. |
| WT051 | ESC3 | `CADRE-ESC3-Agent` + `CADRE-ESC3-Target` templates | Same. | ✅ Configured | Script corrected. |
| WT052 | ESC8 / NTLM relay to web enrollment | Web Enrollment + NetworkService app pool | Same. | ✅ Configured | Script corrected. |
| WT053 | UnPAC-the-Hash | Cert + `EFS` EKU + `Certify.exe` + `Rubeus` | Same templates + tools. | ✅ Configured | Script corrected. |

**Verdict:** Branch B surface is fully configured. Only the credential context and script execution were issues.

---

### 2.14 Branch D (Linux Pivot)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| WT044 | MSSQL linked server recon | `mbr01` linked server to `LINUX01`, `analyst_t1` IMPERSONATE | `sql-integration-guide.md` configures linked server. | ✅ Configured | Confirmed. |
| WT045 | SSSD ticket extraction | SSSD cache + valid session on `linux01` | `07-linux-config.yml` joins domain but does not expose SSSD cache for extraction. | ❌ Missing | No playbook configures SSSD as an attack target. |
| WT046 | MSSQL keytab extraction | `mssql.keytab` on `linux01` | `sql-integration-guide.md` creates keytab. | ✅ Configured | Confirmed configured, but extraction script not exercised. |
| WT047 | NFS Kerberos mount | NFS server with `sec=krb5p` export on `linux01` | No NFS server configured in Linux playbooks. | ❌ Missing | Surface not configured. |
| WT048 | Podman container escape | Podman + privileged/misconfigured container | No playbook deploys containers on `linux01`. | ❌ Missing | Surface not configured. |

**Verdict:** Branch D Linux surfaces are configured in playbooks. The remaining gaps are extraction/execution coverage, not missing lab surface.

---

### 2.15 Branch G (CVE-2026-41089)

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| CVE-2026-41089 | Netlogon CLDAP overflow | `dc02` unpatched, UDP/389 reachable, PoC on `Kali` | No playbook deliberately keeps `dc02` vulnerable; PoC is in `docs/internal/references/sources/cve-2026-41089/`. | ❌ Missing (by design) | The lab is either vulnerable or not based on patch level. No playbook should force vulnerability. |

**Verdict:** Branch G is intentionally a "test if still vulnerable" item. It should not be a playbook target; it should be a validation-only check.

---

### 2.16 E Stream — Network Defense

| ID | Attack | Expected Surface | Coverage | Status | Notes |
|---|---|---|---|---|---|
| E-01..E-14 | Detection rule validation | Zeek + Suricata + Elastic on `monitor` | `13-net-monitor.yml` + `12-elk-fleet.yml` configure sensors. | ✅ Sensors configured | The *attack* side is not a surface; it is the same attacks replayed for detection. |

**Verdict:** E stream is not an attack-surface gap. It is a telemetry/execution gap. The sensors are configured but the exercises have not been run.

---

### 2.17 F Stream — Supply Chain

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
- **Possible causes:**
  1. The playbook task does not target `dc02` explicitly (it targets a group that excludes DCs).
  2. Server 2025 security baseline / post-install hardening stops Spooler on DCs.
  3. The task is idempotent and `Spooler` was already disabled.
- **Fix:** Add an explicit `dc02` play in `04-vulnerabilities.yml` (and matching verify) that sets Spooler to Auto/Running and opens the necessary RPC ports. This is required for the canonical Phase 5→6→7 chain.

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
| **P0** | `dc02` Spooler not running/exposed | Add explicit task to enable Spooler Auto/Running on `dc02`; verify with `04-vulnerabilities-verifyOnly.yml`. | `04-vulnerabilities.yml` |
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

The lab is **close to complete** for the main Windows AD spine and the core ADCS/SCCM branches. The biggest remaining work is:

1. **Fix `dc02` Spooler** so the canonical Phase 5→6→7 chain works without `chief_command` fallback.
2. **Complete Branch D** Linux surfaces.
3. **Automate Phase 0.5 / H** initial access staging.
4. **Add missing 3.5 tools** (Nemesis, LAPS, WerFault, AAD Connect) if those techniques are required for the campaign.
5. **Run E/F stream scenarios** as exercises, not surface configuration.

Once P0 items are fixed, the campaign can be re-run cleanly from Phase 0 through Phase 8 with the designed credential flow, and the validation report can move many `⏳`/`⚠️` items to `✅`.

---

*Generated 2026-07-30 from playbook/guide review vs CAMPAIGNS-VALIDATION-REPORT-20260730.md.*
## Appendix A — Consolidated Campaign Re-test Matrix

> Updated: 2026-07-31

| ID | Stream | Attack | Source Machine | Credentials | Status | Re-test / Fix Notes |
|---|---|---|---|---|---|---|
| WT015 | Branch A | ACE#7 ForceChangePassword | ws01 | hunter_dfir / DF1R_Hunt3r! | ⠿ Blocked | Missing ACE exposure; rerun after `05-ad-attack-surface.yml` ACE#7 verify-only pass. |
| WT013 | Branch A | WriteDacl self-escalate | ws01 | chief_command / C0mm@nd_Ch1ef! | ⠿ Scripted | Script present; awaiting retest after ACE/routing fixes. |
| WT014 | Branch A | GenericWrite → Shadow Creds | ws01 | chief_command / C0mm@nd_Ch1ef! | ⠿ Scripted | Script present; awaiting retest after ACE/routing fixes. |
| WT016 | Branch A | GenericAll on OU | ws01 | chief_command / C0mm@nd_Ch1ef! | ⠿ Scripted | Script present; awaiting retest after ACE/routing fixes. |
| WT008 | Branch A | Shadow Creds on dc01$ | ws01 | chief_command / C0mm@nd_Ch1ef! | ⠿ Scripted | Script present; awaiting retest after ACE/routing fixes. |
| WT023 | Branch A | GPO Abuse | ws01 | analyst_cloud / ... | ⠿ Scripted | Script present; awaiting retest. |
| WT024 | Branch A | gMSA extraction | ws01 | analyst_cloud / ... | ⠿ Scripted | Script present; awaiting retest. |
| GPP | Branch A | GPP stored password | ws01 | analyst_cloud / ... | ❌ Missing | No playbook config; add `19-initial-access.yml` or gap-fix task. |
| WT025 | Branch A | AdminSDHolder persistence | ws01 | chief_command / C0mm@nd_Ch1ef! | ❌ Missing | Missing AD surface; needs dedicated playbook/ACL work. |
| WT050 | Branch B | ADCS ESC1 | ws01 | chief_command / C0mm@nd_Ch1ef! | ⠿ Scripted | Script present; awaiting retest. |
| WT051 | Branch B | ADCS ESC3 | ws01 | chief_command / C0mm@nd_Ch1ef! | ⠿ Scripted | Script present; awaiting retest. |
| WT052 | Branch B | ADCS ESC8 | ws01 | analyst_cloud / ... | ⠿ Scripted | Script present; awaiting retest. |
| WT053 | Branch B | UnPAC-the-Hash | ws01 | chief_command / C0mm@nd_Ch1ef! | ⠿ Scripted | Script present; awaiting retest. |
| WT044 | Branch D | MSSQL linked server recon | linux01 | analyst_t1 / ... | ✅ Configured | Confirmed configured; extraction exercise pending. |
| WT045 | Branch D | SSSD ticket extraction | linux01 | analyst_t1 / ... | ❌ Missing | No playbook exposes SSSD cache for extraction. |
| WT046 | Branch D | MSSQL keytab extraction | linux01 | analyst_t1 / ... | ⠿ Scripted | Configured; extraction script not exercised. |
| WT047 | Branch D | NFS Kerberos mount | linux01 | analyst_t1 / ... | ❌ Missing | No NFS server export configured. |
| WT048 | Branch D | Podman container escape | linux01 | analyst_t1 / ... | ❌ Missing | No container surface deployed. |
| E-01..E-14 | E stream | Network defense exercises | monitor/elk | — | ⏳ Configured | Sensors configured; exercises pending. Keep offline until telemetry phase. |
| F-01..F-13 | F stream | npm supply-chain scenarios | linux01/mbr01 | — | ⏳ Configured | Tooling configured; scenarios pending. |
| G | Branch G | CVE-2026-41089 | Kali | — | 🔬 Deferred | PoC present; depends on dc02 patch state. |
| H-01..H-06 | Phase 0.5 | Initial access payloads | Kali/ws01 | — | ❌ Missing | No playbook stages payloads; needs `19-initial-access.yml`. |

