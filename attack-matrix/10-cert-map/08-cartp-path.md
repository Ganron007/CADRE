# CARTP Path — Certified Azure Red Team Professional (Altered Security)

**Focus:** Azure AD / Entra ID attacks — PHS, PTA, Cloud Sync, EntraGoat scenarios, hybrid identity abuse.

**CADRE coverage:** ~40% (foundational on-prem AD attacks that are prerequisites for hybrid cloud attacks).

---

## About CARTP

| Field | Detail |
|-------|--------|
| **Provider** | Altered Security |
| **Format** | Self-paced lab manual + 48-hr exam |
| **Lab** | Azure tenant + on-prem AD hybrid environment |
| **Exam** | 48-hour practical: compromise an Azure AD / Entra ID tenant using hybrid and cloud attack paths |
| **Prerequisites** | CRTP-level on-prem AD knowledge strongly recommended |
| **URL** | https://www.alteredsecurity.com/azure-lab |

## CADRE-CARTP Coverage

CADRE's current coverage is limited to **on-prem foundational techniques** that build knowledge needed for hybrid cloud attacks:

| Category | Covered in CADRE | Missing (Plan 11) |
|----------|-----------------|-------------------|
| On-prem AD fundamentals | ✅ DCSync, Kerberos, Password Spray, ACL abuse | — |
| Cloud Sync / PHS | ✅ Cloud Sync agent on dc01 | ❌ Walkthroughs C01-C09 |
| Entra ID app abuse | ❌ | ❌ EntraGoat 6 scenarios |
| Azure RM escalation | ❌ | ❌ Azure RM attacks (A01-A04) |
| Hybrid chains | ❌ | ❌ H01-H04 hybrid chains |
| PIM / Conditional Access | ❌ | ❌ PIM abuse, CA bypass |

---

## Prerequisite Walkthroughs

These on-prem CADRE walkthroughs build the foundational AD knowledge that CARTP assumes (starting from DCSync/hybrid path):

### Phase 1 — AD Fundamentals (Mandatory)

| WT# | Title | Why for CARTP |
|-----|-------|---------------|
| 009 | DCSync | **Critical.** DCSync is the foundation of PHS — understanding how krbtgt/account hashes are extracted directly maps to understanding how Password Hash Sync sends hashes to the cloud. |
| 010 | Golden Ticket | Core Kerberos persistence. Cloud Sync agents authenticate as the on-prem DC — understanding Kerberos ticket forgery helps understand cloud sync trust models. |
| 011 | Silver Ticket | Service-level Kerberos abuse. Cloud services use similar service principal authentication models. |
| 031 | Password Spray | **Critical.** Password spraying works universally — on-prem AD, Entra ID, and across hybrid boundaries. |
| 003 | AS-REP Roasting | Kerberos pre-auth attacks — fundamental Kerberos concept needed for understanding cloud Kerberos variants. |

**Estimated time:** ~2 hr

### Phase 2 — Credential Harvesting (Recommended)

| WT# | Title | Why for CARTP |
|-----|-------|---------------|
| 002 | AES Kerberoasting | Service account credential extraction — Cloud Sync agents run as service accounts with SPNs. |
| 015 | ForceChangePassword | ACL-based password reset — hybrid ACL chains (on-prem → cloud) use similar techniques. |

> **Note:** WT028 (null session) ❌ Invalid on Server 2025. WT031 (password spray) ⏳ Pending relocation. Password spray remains a valid technique for CARTP target — CADRE will reinsert when a user list source is available.

**Estimated time:** ~1 hr 30 min

### Phase 3 — Delegation (Helpful Context)

| WT# | Title | Why for CARTP |
|-----|-------|---------------|
| 004 | Unconstrained Delegation | Delegation concepts translate to cloud service principals and OAuth delegation. |
| 007 | RBCD | Resource-based trust models — cloud hybrid trust relationships use similar patterns. |
| 008 | Shadow Credentials | Certificate-based authentication in AD — directly relates to Entra ID Certificate-Based Authentication. |

**Estimated time:** ~1 hr 30 min

---

## CARTP Attack Surface (Plan 11 — Not Yet in CADRE)

### C01-C09 — EntraGoat Scenarios

| WT# | Scenario | Technique |
|-----|----------|-----------|
| C01 | Service Principal Abuse | App.ReadWrite.All → create SP → assign Global Admin |
| C02 | Mail Read | App with Mail.Read → access all mailboxes |
| C03 | Role Management Abuse | RoleManagement.ReadWrite.Directory → self-assign Global Admin |
| C04 | SP Credential Add | Add credentials to existing SP → authenticate as SP |
| C05 | CBA Forge | Certificate-Based Authentication → forge cert → auth as Global Admin |
| C06 | Legacy Auth Bypass | Conditional Access bypass via legacy protocols |

### H01-H04 — Hybrid Chains

| WT# | Chain | Steps |
|-----|-------|-------|
| H01 | ADCS → Cloud | ESC1 cert → enroll with SAN → CBA → Entra Global Admin |
| H02 | Cloud → On-prem | Compromise cloud SP → Cloud Sync write-back → on-prem DC compromise |
| H03 | On-prem → Cloud | Kerberoast → crack → PHS login to cloud |
| H04 | CA Bypass → On-prem | Cloud Conditional Access bypass → steal token → set RBCD on-prem |

### A01-A04 — Azure RM Attacks

| WT# | Attack | Target |
|-----|--------|--------|
| A01 | RBAC Escalation | Reader → Contributor via automation runbook |
| A02 | PIM Abuse | Eligible Global Admin → activate without MFA |
| A03 | B2B Guest Escalation | Guest user in partner tenant → escalate via B2B invite |
| A04 | Azure Arc Bridge | Cloud → on-prem via Azure Arc agent |

---

## Hybrid Components Already in CADRE

These components are deployed in the CADRE lab and ready for Cloud Sync walkthroughs:

| Component | Host | Status |
|-----------|------|--------|
| Cloud Sync agent | dc01 | ✅ Installed |
| PHS (Password Hash Sync) | dc01 | ✅ Enabled |
| Sync scope OUs | Cloud, Agentic, Command | ✅ Configured |
| SyncJacking misconfig | dc01 | ✅ Write-back permissions |
| Entra ID tenant | — | ❌ Requires user-provided tenant |

**To use CADRE for CARTP preparation:**
1. Complete prerequisite walkthroughs (Phases 1-3 above)
2. Provision your own Azure tenant with Entra ID P2
3. Install Cloud Sync agent pointing to your tenant (manual step)
4. Follow CARTP lab manual for the Entra ID attack scenarios

---

## Coverage Summary

| Area | CADRE Walkthroughs | CARTP Relevance |
|------|-------------------|-----------------|
| On-prem AD fundamentals | WT#003, 009, 010, 011, 031 | Direct — foundation |
| Credential harvesting | WT#002, 013-016, 024, 026 | Direct — service accounts |
| Delegation | WT#004-008 | Conceptual — trust models |
| ADCS | WT#050-062 | Direct — hybrid cert attacks (H01) |
| Cloud Sync (Plan 11) | C01-C09 | **Missing** — ~40% of exam |
| Azure RM (Plan 11) | A01-A04 | **Missing** — ~25% of exam |
| Hybrid chains (Plan 11) | H01-H04 | **Missing** — ~35% of exam |

**Overall CADRE readiness for CARTP:** ~40% (excludes cloud-only attacks)

**Best CADRE alternative:** Use CADRE for on-prem foundation + Altered Security CARTP official lab for cloud attacks.

---

## CARTP Exam Tips

| Tip | Detail |
|-----|--------|
| **Know your on-prem** | CARTP assumes you can enumerate AD and extract hashes. Practice WT#009 DCSync until it's muscle memory. |
| **Certificate abuse is key** | Many cloud → on-prem chains involve certificate authentication. Complete CADRE ADCS walkthroughs (ESC1, ESC6, ESC8) before exam. |
| **Graph API enumeration** | Learn Microsoft Graph API endpoints — much of the exam involves Graph API reconnaissance similar to how BloodHound works for on-prem. |
| **Cloud Sync architecture** | Understand exactly how Cloud Sync / Entra Connect stores credentials. The sync engine uses a SQL CE database on the sync server that contains password hashes. |
| **Conditional Access** | Practice bypassing Conditional Access via legacy protocols, trusted locations, and device compliance spoofing. |
