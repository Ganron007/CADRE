# CADRE v3 — Architecture Review & Enterprise Redesign Draft

> **Status:** Draft for operator review.  
> **Purpose:** Assess why the v3 campaign has so many non-working items, decide what an enterprise-grade attack chain looks like, and propose a redesign that RedStrike / C2Stack can actually use.  
> **Scope:** Campaign v3, `CAMPAIGNS-METADATA-v2.md`, `CAMPAIGNS-VALIDATION-REPORT.md`, `CADRE-Attack-Surface-Coverage-Audit.md`, Vagrantfile, Ansible playbooks. VMs not running; review is document-based.  

---

## 1. Executive Summary

**The core campaign design is sound.** The main spine works end-to-end: `ws01 → mbr01 (GodPotato) → T102 (dc02$ TGT) → DCSync → Golden Ticket`. Branches A, B, C, and D are largely verified. The lab is not broken.

**What is broken is the packaging.** The 119-item campaign is really three different products jammed together:

1. A real, connected, multi-hop enterprise attack chain (~25 items: spine + core branches A-D).
2. A broad technique catalog and reference library (~70+ items: 3.5 extras, 9 coercion primitives, E/F/G, post-DA cluster, supply chain).
3. Future research placeholders (~20+ items: Onelogon, Skipjack, CVE-2026-41089, ESC8/ESC11, etc.).

The failures are concentrated in (2) and (3). Many are not playbook bugs but **Server 2025 incompatibilities** or **missing attack surfaces**. The campaign document treats all 119 as if they are live campaign steps, which creates the appearance that "everything is failing."

**The enterprise-grade fix is to separate the campaign from the catalog, fix the surface playbooks, and build a deterministic green-path graph that RedStrike and C2Stack can target.**

---

## 2. What Works (the Green Core)

These are the items that chain together and are verified:

| Phase | Attack | Status | Why It Matters |
|---|---|---|---|
| 0.5 | H-01, H-02, H-04, H-05, H-06 | VERIFIED | Realistic initial-access beachhead on ws01. |
| 0 | Kerberos user enum, AS-REP check | VERIFIED | Foundation for no-cred recon. |
| 1 | AS-REP roast `intern_blue` | VERIFIED | First credential. |
| 2 | Kerberoast via ACE#18 bridge | VERIFIED | `svc_mssql` creds. |
| 3 | SQL xp_cmdshell + GodPotato | VERIFIED | SYSTEM on mbr01. |
| 3.5 | Winlogon cred extraction, LSASS dump, DPAPI | VERIFIED | `analyst_cloud` creds, tickets, masterkeys. |
| 4 | BloodHound | VERIFIED | Attack-path discovery. |
| 5 | T102 unconstrained delegation capture | VERIFIED | `dc02$` TGT → Phase 6. |
| 6 | DCSync | VERIFIED | child krbtgt captured. |
| 7 | Golden / Silver Ticket | VERIFIED | root-domain TGT. |
| 8 | Cross-forest, SCCM | VERIFIED | `svc_sccm` / NAA. |
| A | ACL abuse (10 items) | VERIFIED | DA alternative paths. |
| B | ESC1/2/3/4/7/9, UnPAC | VERIFIED | ADCS takeover. |
| C | CMPivot, app deploy, script-as-SYSTEM | VERIFIED | SCCM takeover as SYSTEM. |
| D | Linux pivot (WT044-048) | VERIFIED | Linux post-ex. |

This is approximately **25 connected attacks** that form a legitimate assume-breach-to-forest-takeover chain. It is the real product.

---

## 3. Why the Other Items Are Failing

The non-working items cluster into five buckets, not random bugs.

### 3.1 Server 2025 Hardening Kills Classic Primitives

This is the largest bucket. The lab uses Windows Server 2025, and many 2020-2023 red-team techniques no longer work. These are not playbook misconfigurations.

| Item | Failure | Cause |
|---|---|---|
| WT028 null session / SAMR anonymous | REJECTED | Anonymous SAMR blocked by default on Server 2025. |
| WT018 PetitPotam / MS-EFSR | NON-FUNCTIONAL | `\PIPE\efsrpc` hardened. |
| WT019 DFSCoerce | NON-FUNCTIONAL | No dial-out; Suricata cannot see SMB-pipe DCE-RPC. |
| WT020 ShadowCoerce | NON-FUNCTIONAL | File Server VSS Agent not installed. |
| 3.5I token impersonation | REJECTED | Server 2025 session isolation. |
| comsvcs `MiniDump` of LSASS | PARTIAL | 64-76KB stubs only. |
| mimikatz `sekurlsa::logonpasswords` | PARTIAL | Cannot parse Server 2025 LSASS. |
| Rubeus diamond ticket | PARTIAL | 2.2.0 PAC parser fails on Server 2025 KDC. |
| H-03 .chm execution | PLATFORM-BLOCKED | Modern `hh.exe` ActiveX sandbox. |
| WMI permanent event subscriptions | PARTIAL | `WITHIN` rejected; delivery does not reach consumer. |

Recommendation: Stop treating these as campaign failures. Move them to a `platform-blocked-techniques.md` reference list. They remain useful for teaching "why this no longer works" and for detection engineering, but they are not executable campaign steps.

### 3.2 Missing Attack Surfaces in Playbooks

These are genuine gaps: the campaign lists attacks for which the playbooks do not create the target surface.

| Item | Missing Surface | Where It Should Live |
|---|---|---|
| 3.5G Nemesis DPAPI | Tool not installed | `06-member-services.yml` |
| 3.5K WerFault LSASS dump | `DumpFolder` registry / keys not configured | `04-vulnerabilities.yml` or `06-member-services.yml` |
| 3.5L / WT100 LAPS | LAPS not deployed | `04-vulnerabilities.yml` (only partial surface) |
| 3.5M AAD Connect DPAPI | `ADSync` service not on DC | `15-cloud-sync.yml` (currently only provisioning agent) |
| WT103 DPAPI-NG | No protected blob staged | `05-ad-attack-surface.yml` or `04-vulnerabilities.yml` |
| WT104 DLL hijacking | No target app + writable dir | `06-member-services.yml` or new `04-vulnerabilities.yml` task |
| WT107 LSA SSP | No SSP DLL built/staged | `06-member-services.yml` |
| WT108 DCOMIllusionist | Tool not on ws01 | `06-member-services.yml` staging |
| GPP stored password | `Groups.xml` with cpassword not in SYSVOL | `02-ad-objects.yml` |

Recommendation: For each, either fix the playbook to create the surface or remove the attack from the executable campaign and move it to the deferred catalog.

### 3.3 Manual-Only Surfaces (Operational Fragility)

Two major branches cannot be reproduced from playbooks alone:

- **Branch B ADCS**: templates configured via `adcs-configuration-guide.md` and a snapshot, not a playbook.
- **Branch C SCCM**: manually deployed on `mbr02` and snapshotted.

This means the lab is not reproducible from scratch. Rebuild requires manual work or snapshot restore.

Recommendation: Either fully automate these or explicitly document them as "Tier 3 / manual setup required."

### 3.4 Methodology Rejections (Correctly Excluded)

Some items fail because the campaign rules correctly reject them:

- **3.5B scheduled task as `analyst_cloud`**: rejected by Rule 2 (not a one-time execution wrapper).
- **WT028 null session**: correctly not configured on Server 2025.

These are not bugs. They are the rules doing their job.

### 3.5 Tool Version Issues (Fixable)

A smaller category solved by updated builds or documented workarounds:

- **Rubeus 2.2.0** cannot forge Server 2025 PAC.
- **mimikatz 2.2.0** cannot parse Server 2025 LSASS (use procdump + Rubeus).
- **SharpDPAPI 1.12.0** build failed; the 2026-02-02 build works.

Recommendation: Add a `tools-compatibility.md` guide and pin known-good builds. Do not treat these as architecture problems.

---

## 4. The Structural Design Problem

The campaign document treats all 119 items as if they are steps in a single campaign. They are not. The result is a confusing narrative where a learner cannot tell what is a required chain step, what is a branch, what is a reference technique, and what is a future research item.

### Proposed separation

| Bucket | Count | What It Is | How to Present It |
|---|---|---|---|
| **Enterprise Campaign** | ~25 | The connected chain + Branches A-D | `CAMPAIGNS_v3.md` main spine. RedStrike graph nodes. |
| **Technique Catalog** | ~70 | E/F/G, 3.5 extras, 9 coercion primitives, supply chain | Separate `CADRE-Technique-Catalog.md`. Reference, not a path. |
| **Research Backlog** | ~24 | ESC8/ESC11, Onelogon, Skipjack, CVEs, dMSA deep-dive | `Campaign_suggestions.md` or `docs/internal/research-backlog.md`. |

This separation alone would make the campaign feel coherent and enterprise-grade.

---

## 5. What Is Missing for Enterprise-Grade Use

### 5.1 Deterministic Reproducibility

Every attack surface in the enterprise campaign must come from a playbook, not a manual step or snapshot. ADCS and SCCM are the biggest gaps.

### 5.2 A Clean State Machine

RedStrike needs a graph where each node has:
- Required pre-state.
- One primary attack.
- Known-good fallbacks.
- Post-state.
- List of excluded / deferred items with reason codes.

The current metadata mixes verified, unverified, and rejected items without this structure.

### 5.3 Telemetry as a First-Class Output

The campaign validates attack execution. It does not validate that each attack produces the expected telemetry. Plan 1 is the missing half. Without it, the lab is red-team-only, not purple-team.

### 5.4 Tiered Lab Distribution

An 11-VM, 119-attack lab is not adoptable. Enterprise-grade labs ship in tiers:

- **Tier 1 (4-5 VMs)**: connected spine + Branch A/B.
- **Tier 2 (+2-3 VMs)**: child domain, cross-forest, SCCM, Linux.
- **Tier 3 (full 11 VMs)**: research catalog + full telemetry.

### 5.5 Clear Exclusion List

The campaign needs a documented, approved list of "not in scope because platform / missing surface / deferred." This prevents every failed attack from feeling like a regression.

### 5.6 C2 Integration Readiness

C2Stack and RedStrike LLM mode should only target the verified green set. Targeting the full 119 is why they fail. The LLM cannot reliably choose among unverified items.

---

## 6. Recommended Redesign

### 6.1 Tier 1 — The Enterprise Campaign (publishable, 4-5 VMs)

This is the lab others should adopt. It covers a realistic assume-breach-to-DA/EA chain without the advanced branches.

| Tier 1 VMs | Role | RAM |
|---|---|---|
| dc01 | root DC `cadre.local` + CA + DNS | 4GB |
| mbr01 | MSSQL 2022 + IIS + unconstrained delegation | 4GB |
| ws01 | Win11 beachhead + MDE | 4-6GB |
| sensor-host | ELK + Zeek + Suricata + Velociraptor + Ansible (containers) | 8-10GB |

| Optional for Tier 1.5 | Add dc02 for child domain | 4GB |

**Covers:** Phases 0.5–7, Branch A (ACL abuse), Branch B (ADCS), all telemetry.
**Excludes:** Cross-forest (dc03), SCCM (mbr02), Linux pivot (linux01).

### 6.2 Tier 2 — Extended Enterprise (7-8 VMs)

Add the remaining connected branches.

| Added VMs | Role | RAM |
|---|---|---|
| dc02 | `child.cadre.local` DC (child→parent escalation) | 4GB |
| dc03 | `range.local` DC (cross-forest) | 4GB |
| mbr02 | SCCM site server | 8GB |
| linux01-lxc | AD-joined Linux pivot (LXC on sensor-host) | shared |

### 6.3 Tier 3 — Full Research Lab (11 VMs)

The current 11-VM build. Use this only for Plan 1 telemetry catalog, DFIR-Nexus evidence generation, and research backlogs.

---

## 7. Phased Implementation Plan

### Phase 1 — Separate Campaign from Catalog (1-2 days)

1. Define the **Enterprise Campaign** as the 25 connected items in the green core.
2. Move E/F/G, post-DA extras, 3.5 technique list, 9 coercion primitives, and supply chain to a **Technique Catalog**.
3. Move Server-2025-blocked and future CVE items to a **Research Backlog** with reason codes.
4. Update `Runbooks/CAMPAIGNS-RUNBOOK-README.md` to point to the three tiers.

### Phase 2 — Fix Playbook Surfaces (1-2 weeks)

For each missing surface in Section 3.2, decide:

- **FIX**: add playbook task to create the surface, or
- **EXCLUDE**: move the attack to the catalog/backlog.

Priority order:
1. Post-DA cluster tools (Nemesis, LAPS, AAD Connect, SSP, DLL-hijack app).
2. 3.5 extras (WerFault, DCOMIllusionist).
3. GPP `Groups.xml` in SYSVOL.
4. DPAPI-NG protected blob or remove WT103.

### Phase 3 — Automate or Quarantine Manual Surfaces (1-2 weeks)

1. **ADCS templates**: either automate via `08-adcs-verify.yml` or mark Branch B as "Tier 3 / snapshot required."
2. **SCCM**: either automate `mbr02` deploy or mark Branch C as "Tier 3 / snapshot required."

### Phase 4 — Stabilize Green Path for RedStrike (1 week)

1. Build a `campaign_state.json` / RedStrike ledger with only the verified green items.
2. Add explicit fallback per node (e.g., if T102 fails, attempt WT007 RBCD).
3. Mark all excluded items with reason codes so the LLM cannot select them.

### Phase 5 — Plan 1 Telemetry Catalog (2-4 weeks)

1. Fix `plan1-orchestrator.sh` bugs: wrong `source.ip` filter, counts-only export, overlapping batch windows.
2. Use per-phase batching with snapshot restore and full event export.
3. Build `docs/internal/plan01-telemetry-catalog/phase1-source-matrix/tracker.md` from the exports.

### Phase 6 — C2Stack Integration (after Phase 5)

1. Only now integrate Havoc/Sliver/Meridian/Adaptix/Mythic as the callback layer.
2. C2 should deliver payloads for the green campaign; telemetry validation should be complete.

---

## 8. Appendices

### Appendix A — Recommended Enterprise Campaign (25 attacks)

These are the items that should form the executable RedStrike graph:

| Phase | ID | Attack | RedStrike Intent / State Key |
|---|---|---|---|
| 0.5 | H-01 | Malicious LNK | `c2_session.analyst_t1` |
| 0.5 | H-02 | Malicious MSI | `c2_session.analyst_t1` |
| 0.5 | H-04 | HTML smuggling | `c2_session.analyst_t1` |
| 0.5 | H-05 | AutoIt3 | `c2_session.analyst_t1` |
| 0.5 | H-06 | Malicious EXE | `c2_session.analyst_t1` |
| 0 | P0-Step1 | Kerberos user enum | `recon.users` |
| 0 | P0-Step2 | AS-REP roastable check | `recon.asrep_target` |
| 1 | WT003 | AS-REP roast | `creds.intern_blue.password` |
| 2 | WT002 | Kerberoast via ACE#18 | `creds.svc_mssql.password` |
| 3 | WT041/043 | SQL xp_cmdshell + GodPotato | `creds.mbr01.system` |
| 3.5 | 3.5A | Winlogon plaintext | `creds.analyst_cloud.password` |
| 3.5 | 3.5F | LSASS/SAM dump | `creds.tickets` |
| 3.5 | 3.5K | LSASS via procdump | `creds.tickets` |
| 4 | WT004 | BloodHound | `recon.bloodhound` |
| 5 | WT017 | PrinterBug coercion | `coerce.dc02` |
| 5 | T102 | Unconstrained delegation capture | `creds.dc02_machine.ticket` |
| 5 | WT007 | RBCD fallback | `creds.mbr01.system` |
| 6 | WT009 | DCSync child | `creds.child_krbtgt.nt_hash` |
| 7 | WT010 | Golden Ticket | `creds.cadre_ea.ticket` |
| 7 | WT011 | Silver Ticket | `creds.silver.ticket` |
| 8 | WT033 | Cross-forest Kerberoast | `creds.svc_sccm.password` |
| 8 | WT034 | SCCM NAA | `creds.svc_naa.password` |
| A | WT015 | ForceChangePassword | `creds.chief_command.password` |
| B | WT050 | ESC1 | `creds.administrator.nt_hash` |
| B | WT053 | UnPAC-the-Hash | `creds.administrator.nt_hash` |
| D | WT044-048 | Linux pivot | `creds.mssql_linux01.password` |

### Appendix B — Move to Technique Catalog / Reference Library

- E stream (WT069-081 + E-10)
- F stream (F-01..F-13)
- Phase 3.5 non-core extras (3.5B, 3.5D non-drop, 3.5G if used as reference, 3.5H, 3.5I, 3.5J, 3.5L, 3.5M, 3.5N)
- Phase 5 coercion catalog (WT018, WT019, WT020, WT021, WT022, WT094, WT095, WT096)
- Post-DA non-chain items (WT100, WT102, WT103, WT104, WT107, WT108, WT109)
- Branch G CVE exercises

### Appendix C — Platform-Blocked / Research Backlog

- WT028 null session / SAMR anonymous
- WT018 PetitPotam
- WT019 DFSCoerce
- WT020 ShadowCoerce
- H-03 .chm execution
- 3.5I token impersonation
- Rubeus diamond ticket on Server 2025
- WT095 Onelogon
- Skipjack
- CVE-2026-41089
- ESC8 / ESC11 (relay family; no SMB-authenticated coerce on Server 2025)

---

## 9. Open Questions for Review

1. Do you accept collapsing the Enterprise Campaign to ~25 items and moving the rest to catalogs/backlogs?
2. Should the child domain be required for Tier 1, or should it be Tier 1.5 / Tier 2?
3. Should ADCS and SCCM remain manual/snapshot, or should we invest in full playbook automation?
4. Do you want to proceed with the sensor-host consolidation (elk + monitor + vr on one VM) for Tier 1?
5. Should C2Stack integration be explicitly gated behind completion of Plan 1 telemetry catalog?

---

*Draft prepared for review. Do not commit until approved.*
