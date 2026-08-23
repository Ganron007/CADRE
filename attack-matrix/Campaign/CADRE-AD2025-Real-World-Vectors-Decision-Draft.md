# CADRE — AD 2025 Real-World Vectors Decision Draft

> **Status:** Draft for operator review.  
> **Purpose:** Decide which attack vectors to add, keep, or remove from the v3 campaign to keep it real-world practical, not a certification-course catalog of patched techniques.  
> **Scope:** Main spine (Phases 0.5-8) and Branches A-D. SCCM/ADCS/SQL remain manual/snapshot surfaces for now and are tracked as separate branches.  

---

## 1. Decision Principles

1. **Real-world practical** means an attack still works on a default-hardened Windows Server 2025/Windows 11 Enterprise environment, or against a common modern misconfiguration.
2. **Reproducible** means the attack surface is created by an Ansible playbook or a documented, deterministic guide, not a one-time manual tweak.
3. **Repeatable** means a second operator can follow the runbook and get the same marker/credential/output without tool-version magic.
4. **No certification traps:** Remove or demote techniques that only exist because old courses taught them (PetitPotam, null session, GPP cpassword in modern orgs).
5. **No futureware:** Do not add research PoCs that depend on unreleased tools or unpatched CVEs unless they are clearly quarantined in the research backlog.

---

## 2. Keep — Core of the Real-World AD 2025 Campaign

These are the techniques that are practical today and should stay in the executable campaign.

| Technique | Why It Is Still Practical in 2025 |
|---|---|
| AS-REP roasting | Accounts with no pre-auth still exist in real orgs. |
| Kerberoasting | Service accounts with weak/AES passwords are a top-5 finding. |
| RBCD / S4U2Proxy | Misconfigured delegation is common and not patched away. |
| Unconstrained delegation capture | Still exploitable when an admin stages a listener on a trusted machine. |
| Shadow credentials / pyWhisker | The modern "no-logon-logs" privilege escalation; no patch available. |
| ADCS ESC1/ESC3/ESC4/ESC7/ESC9 + UnPAC | ADCS misconfiguration is the dominant on-prem AD attack surface today. |
| DCSync / Golden Ticket / Silver Ticket | Fundamentals of AD post-exploitation; still work with the right rights. |
| SQL linked servers / xp_cmdshell / CLR | MSSQL misconfiguration remains a common pivot. |
| DPAPI masterkeys + backup keys | Cloud and password vault material is everywhere on endpoints. |
| gMSA / dMSA / KDS root key abuse | Server 2025-specific and newly relevant. |
| SCCM AdminService / CMPivot / RunScript | SCCM is effectively "the new domain admin" in many environments. |
| BloodHound / AD discovery | Cannot do AD offense without it. |
| LAPS v2 extraction | If LAPS is deployed, extracting it is a realistic post-DA task. |
| AAD Connect / ADSync DPAPI | Hybrid orgs still run this; the service account is a high-value target. |
| ACL / DACL abuse (ForceChangePassword, WriteDacl, GenericAll, GPO) | Always present in real AD; the bread and butter of escalation. |
| Cross-forest trust abuse | Multi-forest environments still get this wrong. |
| NTLM relay to LDAP / ADCS (when signing not enforced) | Real, but increasingly rare; keep as conditional/branch only. |

These are already the majority of the current spine and Branches A-D. The campaign does not need more vectors — it needs these to be bulletproof.

---

## 3. Add — Modern Vectors Worth Adding Before Azure Hybrid

These are concrete, currently practical additions that fit the existing campaign without requiring Azure/Entra infrastructure.

### 3.1 Initial Access (Branch H)

Campaign H already has good vectors, but it should be modernized with the current dominant delivery methods:

| New Vector | Why | Prerequisite | Suggested WT# |
|---|---|---|---|
| ISO/IMG mount + LNK | Bypasses MOTW/Zone.Identifier if user mounts the image. | ws01 must mount .iso | H-07 |
| OneNote attachment abuse | HTML/JavaScript runs inside OneNote; common 2024-2025 vector. | OneNote for Desktop installed | H-08 |
| ClickOnce `.application` | Trusted Windows deployment path; no code-signing warning if trusted. | .NET Framework / ClickOnce runtime | H-09 |
| Excel 4.0 / VBA / XLL | Still common in phishing; works without macros if .xll is used. | Office installed | H-10 |
| Edge WebView2 packaged app | Signed-looking app that runs code; growing abuse. | .NET + WebView2 runtime | H-11 |
| ISO + Windows Search `.search-ms` | Recent vector using search connectors; no user click on payload. | Search connector file | H-12 |

**Decision:** Add these to `Campaign_suggestions.md` and test each on ws01 against MDE P2. Only promote to `CAMPAIGNS_v3.md` after the drop/execution side is verified under the actual lab MDE policy.

### 3.2 Credential Access (Phase 3.5 / Post-DA)

| New Vector | Why | Prerequisite |
|---|---|---|
| VSS shadow copy + `SeBackupPrivilege` for `ntds.dit` | Realistic alternative to DCSync when the account has backup rights but not replication rights. | Account with `SeBackupPrivilege` on a DC. |
| `ntds.dit` extraction via VSS | Offline hash extraction; does not require DCSync rights. | VSS service enabled, `SeBackup` or backup admin. |
| LAPS v2 (Entra LAPS) extraction | Modern LAPS; different schema (`msLAPS-Password`) and can be cloud-linked. | LAPS v2 deployed on endpoints. |
| AAD Connect / ADSync DPAPI | Hybrid identity abuse; extracts cloud-to-sync credentials. | AD Connect sync on a domain-joined server (not just provisioning agent). |

### 3.3 Privilege Escalation / Lateral Movement

| New Vector | Why | Prerequisite |
|---|---|---|
| dMSA / BadSuccessor as a proper campaign step | Server 2025-specific; should not be a post-DA catalog item. | Already verified for WT099; integrate after Phase 7 or as Branch A extension. |
| `KrbRelayUp` / `KrbRelay` LPE | LPE via Kerberos relay on the local machine; works on patched systems. | Tool staging, test on ws01/mbr01. |
| `RunasCs` / UAC bypass alternative (negative test under MDE) | Avoids DLL hijacking patterns; tests MDE behavioral detections. | Already have UACME in suggestions. |

---

## 4. Remove / Demote — Certification-Trap or Patched Vectors

These should be removed from the executable campaign and moved to a reference catalog or historical teaching doc. They either no longer work on Server 2025 or are so rare in modern environments that teaching them is misleading.

| Vector | Reason | Disposition |
|---|---|---|
| Null session / SAMR anonymous enumeration | Default blocked on Server 2025; rare in real orgs since 2000+ hardening. | Remove from campaign; keep as "hardening validation" reference. |
| PetitPotam (MS-EFSR) | Patched/hardened on Server 2025; not realistic to teach. | Move to `platform-blocked-techniques.md`. |
| DFSCoerce | No dial-out on Server 2025; poor visibility. | Move to catalog with note. |
| ShadowCoerce | FSRVP not installed by default. | Move to catalog. |
| LLMNR / NBT-NS / NetBIOS spoofing | Not in current list; do not add. Hardened on modern networks. | Skip. |
| GPP `cpassword` | Rare in modern orgs; requires deliberately staging a legacy 2012-era SYSVOL. | Demote to historical reference only. |
| Scheduled tasks as one-time execution wrappers | Correctly rejected by Rule 2; not real-world. | Keep rejected; do not re-test. |
| Token impersonation (3.5I) | Server 2025 session isolation blocks it. | Remove from campaign. |
| Diamond Ticket (main spine) | Tool-brittle on Server 2025; keep as optional reference. | Move to catalog. |
| Onelogon / Skipjack / CVE-2026-41089 | Research PoCs; not stable enough for learning. | Keep in `Campaign_suggestions.md` as research. |
| PetitPotam-based NTLM relay to ADCS (ESC8) | Depends on PetitPotam; remove from main campaign. | Mark `ESC8` as research; keep `WT021-022` LDAP/SMB relay as conditional. |

---

## 5. SCCM / ADCS / SQL — Manual Setup, Branch Status

These are complex surfaces that agents cannot reliably deploy from playbooks. They should remain **manual setup + snapshot** and be treated as separate branches within the main campaign, not as part of the Tier 1 executable chain.

| Branch | Setup | Attack Surface | How to Track |
|---|---|---|---|
| **Branch B — ADCS** | Manual `adcs-configuration-guide.md` + snapshot | ESC1/2/3/4/7/9, UnPAC | Separate runbook; snapshot `adcs-templates-done` required. |
| **Branch C — SCCM** | Manual `sccm-integration-guide.md` + snapshot | AdminService, CMPivot, RunScript, NAA | Separate runbook; snapshot `sccm-done` required. |
| **Phase 3 SQL** | Playbook (`04-vulnerabilities.yml`) but needs xp_cmdshell, CLR, IMPERSONATE | xp_cmdshell, SQL impersonation, GodPotato | Mostly playbook-driven; keep in main spine. |

**Decision:** Update `CAMPAIGNS_v3.md` and `Runbooks/CAMPAIGNS-RUNBOOK-README.md` to explicitly mark Branch B and C as "manual setup / snapshot required." Do not let RedStrike attempt these unless the operator confirms the snapshot is restored.

---

## 6. Implementation Priority (Before Azure Hybrid)

### P0 — Make the existing green spine bulletproof
1. Confirm every main-spine attack can be verified manually by a second operator.
2. Create the operator verification checklist.
3. Fix or remove the missing playbook surfaces (LAPS, AAD Connect, WerFault, Nemesis, SSP, DLL-hijack app).

### P1 — Modernize Branch H
1. Add the six new initial-access vectors to `Campaign_suggestions.md`.
2. Test each under ws01 MDE P2; promote only the ones that execute with real markers.

### P2 — Promote dMSA and LAPS v2
1. Integrate `BadSuccessor` / dMSA into the main narrative (not Post-DA catalog).
2. Deploy LAPS v2 properly or remove `WT100` / `3.5L` entirely.

### P3 — Add VSS / `SeBackup` alternative to DCSync
1. Create a `SeBackupPrivilege` surface on a member or DC.
2. Add VSS shadow-copy extraction as a fallback to DCSync.

### P4 — Azure Hybrid (Plan 11)
1. Only after the on-prem campaign is stable.
2. AAD Connect DPAPI can start before full Azure if AD Connect sync is deployed on-prem.

---

## 7. Open Questions for Review

1. Should the new Branch H vectors be added to `Campaign_suggestions.md` now, or tested first?
2. Do you want to deploy LAPS v2, or remove LAPS from the campaign entirely?
3. Should AAD Connect sync be deployed on `dc01` or a dedicated member server?
4. Should dMSA / BadSuccessor become a main-spine step after Phase 7, or stay as a branch?
5. Is `SeBackupPrivilege` + VSS `ntds.dit` extraction worth a full runbook, or just a reference note?

---

*Draft prepared for review. Do not commit until approved.*
