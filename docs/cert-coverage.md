# CADRE — Certification Coverage

<!-- AUDIENCE: PUBLIC -->

CADRE is designed against **8 industry certifications** for offensive AD + cloud + DFIR.
This page shows honestly how much of each cert syllabus is practiceable in the lab today
versus after the full 11-plan roadmap lands.

> **TL;DR — after a successful Plan 0 deploy:** all 6 on-prem certs (CRTP, CRTE,
> CESP-ADCS, HTB CAPE, OSCP+ AD, WKL OADOC) are immediately practiceable at **85-95%**
> syllabus coverage. The 2 cloud certs (CARTP, CARTE) unlock as Plan 11 builds out.

---

## Summary — Coverage at a Glance

| Cert | Vendor | After Plan 0 | After full roadmap (Plans 0-11) | Walkthroughs |
|------|--------|-------------:|-------------------------------:|-------------:|
| **CRTP** — Certified Red Team Professional | Altered Security | **92%** | 95% | 12 |
| **CRTE** — Certified Red Team Expert | Altered Security | **94%** | 97% | 20 |
| **CESP-ADCS** — Certified Enterprise Security Pro · ADCS | Altered Security | **87%** | 87% | 13 |
| **HTB CAPE** — Certified AD Pentesting Expert | Hack The Box | **90%** | 92% | 25 |
| **OSCP+** (AD portion only) | Offensive Security | **85%** | 88% | 12 |
| **WKL OADOC** — Offensive AD Operations Certification | WhiteKnight Labs | **93%** | 95% | 16 |
| **CARTP** — Certified Azure Red Team Professional | Altered Security | **5%** (agent staged) | **90%** | 13 |
| **CARTE** — Certified Azure Red Team Expert | Altered Security | **0%** | **80%** | 8 |
| **Weighted average across all 8 certs** | — | **~70%** | **~91%** | **~119** |

Coverage percentages are honest estimates against published cert outlines. They're not
endorsed by the cert vendors — CADRE is an unaffiliated practice substrate.

---

## How to Read This Page

For each cert below:
- **Syllabus topic** — what the official cert exam covers
- **CADRE walkthrough(s)** — which numbered walkthrough(s) exercise it
- **Status** — ✅ ready post-deploy / ⚠️ partial / ❌ not yet (plan it's blocked on)

Walkthrough IDs map to `attack-matrix/01-walkthroughs/` (Plan 0 ships the configured
attack surface; walkthrough writeups fill in as the deployed lab is validated).

---

## 1 · CRTP — Certified Red Team Professional (Altered Security)

**Target: 92% post-deploy · 95% with detection content (Plan 5)**

| # | Syllabus topic | Walkthrough(s) | Status |
|---|----------------|----------------|--------|
| 1 | Domain enumeration (BloodHound + PowerView) | All — attack toolchain ready (user-managed Kali) | ✅ |
| 2 | Local privesc on workstations | (host setup) | ✅ |
| 3 | Kerberoasting | 002 (AES) | ✅ |
| 4 | AS-REP roasting | 003 | ✅ |
| 5 | ACL abuse (ForceChangePassword) | 015 | ✅ |
| 6 | ACL abuse (GenericAll, GenericWrite) | 014, 016 | ✅ |
| 7 | Unconstrained delegation | 004 | ✅ |
| 8 | DCSync | 009 | ✅ |
| 9 | Golden / Silver ticket | 010, 011 | ✅ |
| 10 | Cross-domain attacks (parent ↔ child) | 033 | ✅ |
| 11 | Persistence (DCSync rights, AdminSDHolder) | 025 | ✅ |
| 12 | Trust enumeration | (built-in dual-forest topology) | ✅ |
| 13 | LSASS dumping / Mimikatz | (Credential Guard + LSA Protection OFF by design) | ✅ |

**Not directly covered:** AV/AMSI bypass tradecraft (deferred — substrate has Defender off; learners use raw payloads).

---

## 2 · CRTE — Certified Red Team Expert (Altered Security)

**Target: 94% post-deploy · 97% with Plan 5 detection content**

| # | Syllabus topic | Walkthrough(s) | Status |
|---|----------------|----------------|--------|
| 1 | All CRTP topics | (see above) | ✅ |
| 2 | Constrained delegation (with + without protocol transition) | 005, 006 | ✅ |
| 3 | RBCD (Resource-Based Constrained Delegation) | 007 | ✅ |
| 4 | Shadow Credentials (msDS-KeyCredentialLink) | 008 | ✅ |
| 5 | gMSA password extraction | 024 | ✅ |
| 6 | GPO abuse | 023 | ✅ |
| 7 | NTLM relay (LDAP + SMB) | 021, 022 | ✅ |
| 8 | Coercion (PrinterBug, PetitPotam, DFSCoerce, ShadowCoerce) | 017, 018, 019, 020 | ✅ |
| 9 | Diamond ticket | 012 | ✅ |
| 10 | Cross-forest attacks (forest trust) | 033 | ✅ |
| 11 | dMSA / BadSuccessor (CVE-2025-53779) | 026 | ✅ |
| 12 | SOAPHound (modern BloodHound collector) | (attack toolchain — user-managed Kali) | ✅ |
| 13 | SPN Unicode Jacking (CVE-2026-25177) | 027 | ✅ |

**Not directly covered:** Certain niche tradecraft items (laps password extraction; tooling-specific demos). All cert techniques have a CADRE equivalent.

---

## 3 · CESP-ADCS — Certified Enterprise Security Pro · ADCS

**Target: 80% post-deploy (12 of 15 ESC scenarios — ESC5/ESC12/ESC15 out of scope)**

| ESC | Description | Walkthrough | Status |
|-----|-------------|-------------|--------|
| ESC1 | Enrollee Supplies Subject | 050 | ✅ |
| ESC2 | Any Purpose EKU | 051 | ✅ |
| ESC3 | Certificate Request Agent | 052 | ✅ |
| ESC4 | Writable Template ACL | 053 | ✅ |
| ESC5 | Vulnerable PKI AD Object Access Control | — | ❌ (out of scope — too environment-specific) |
| ESC6 | EDITF_ATTRIBUTESUBJECTALTNAME2 | 054 | ✅ |
| ESC7 | CA Manager Approve | 055 | ✅ |
| ESC8 | Web Enrollment Relay | 056 | ✅ |
| ESC9 | No Security Extension | 057 | ✅ |
| ESC10 | Weak Certificate Binding | 058 | ✅ |
| ESC11 | RPC Enrollment Relay | 059 | ✅ |
| ESC12 | YubiHSM Storage | — | ❌ (N/A — requires physical HSM) |
| ESC13 | Issuance Policy Group Map | 060 | ✅ |
| ESC14 | Explicit Cert Mapping | 061 | ✅ |
| ESC15 | EKUwu (v1 Template) | 062 | ❌ (excluded — Server 2025 KDC rejects v1-schema templates) |

**Coverage: 12/15 = 80%** — ESC5 (environment-specific), ESC12 (physical HSM), and ESC15 (Server 2025 v1-schema rejection) are out of scope. Implemented: ESC1-4, 6-11, 13-14.

---

## 4 · HTB CAPE — Certified AD Pentesting Expert

**Target: 90% post-deploy · cross-platform (Windows + Linux + ADCS)**

| # | Syllabus topic | Walkthrough(s) | Status |
|---|----------------|----------------|--------|
| 1 | Full CRTP + CRTE coverage | (see above) | ✅ |
| 2 | NTLM coercion chains | 017-020 | ✅ |
| 3 | ADCS attack chains | 050-062 | ✅ (14/15) |
| 4 | MSSQL on Windows (linked servers, CLR, xp_cmdshell, impersonation) | 040-043 | ✅ |
| 5 | MSSQL on Linux lateral movement | 044 | ✅ |
| 6 | Linux + AD integration (SSSD, Kerberos) | 045, 046 | ✅ |
| 7 | NFS over Kerberos | 047 | ✅ |
| 8 | Container escape (Podman/Docker) | 048 | ✅ |
| 9 | RBCD chains | 007 | ✅ |
| 10 | Shadow Credentials chains | 008 | ✅ |
| 11 | Token impersonation | 032 | ✅ |

**Not directly covered:** ~10% advanced/obscure tradecraft.

---

## 5 · OSCP+ — AD portion only (Offensive Security)

**Target: 85% post-deploy of the AD-specific exam content**

| # | Syllabus topic (AD portion) | Walkthrough(s) | Status |
|---|------------------------------|----------------|--------|
| 1 | Domain enumeration | (attack toolchain — user-managed Kali) | ✅ |
| 2 | Kerberoasting | 002 (AES) | ✅ |
| 3 | AS-REP roasting | 003 | ✅ |
| 4 | DCSync | 009 | ✅ |
| 5 | Pass-the-Hash | (Mimikatz workflow) | ✅ |
| 6 | NTLM relay → SMB | 022 | ✅ |
| 7 | MSSQL xp_cmdshell | 041 | ✅ |
| 8 | MSSQL impersonation | 043 | ✅ |
| 9 | Password spray | 031 | ✅ |
| 10 | Token impersonation | 032 | ✅ |
| 11 | ACL abuse (ForceChangePassword) | 015 | ✅ |
| 12 | Null session enumeration | 028 | ✅ |
| 13 | AV/AMSI bypass awareness | (Defender off by design; raw payloads work) | ⚠️ |
| 14 | Logging/EDR awareness | After Plan 5 (DaC) | ❌ |

**Note:** OSCP+ heavily emphasizes report writing — that's on you. CADRE provides the
attack surface and the telemetry to write good reports against.

---

## 6 · WKL OADOC — Offensive AD Operations Certification (WhiteKnight Labs)

**Target: 93% — SCCM deployed on mbr02**

| # | Syllabus topic | Walkthrough(s) | Status |
|---|----------------|----------------|--------|
| 1 | SCCM site server takeover | 039 | ✅ |
| 2 | NAA credential extraction | 034 | ✅ |
| 3 | PXE boot abuse + media password | 035 | ✅ |
| 4 | Client push relay | 036 | ✅ |
| 5 | CMPivot RCE | 037 | ✅ |
| 6 | Application deployment abuse | 038 | ✅ |
| 7 | Misconfiguration-Manager full matrix (CRED/RECON/EXEC/ELEVATE/TAKEOVER/COERCE) | 034-039 | ✅ |
| 8 | Virtual Smart Card enrollment | 049 | ✅ |
| 9 | WSUS update abuse | 030 | ✅ |
| 10 | CertPotato (DCOM) | 029 | ✅ |
| 11 | ADCS misconfigurations | 050-062 | ✅ |
| 12 | Coercion chains into SCCM | 017-022 | ✅ |

**Not directly covered:** ~7% advanced enterprise-deployment specifics (Intune/JAMF cross-platform — out of scope).

---

## 7 · CARTP — Certified Azure Red Team Professional (Altered Security)

**Target: 90% with Plan 11a + 11b + 11d** · currently 5% (Cloud Sync agent staged on dc01)

| # | Syllabus topic | Walkthrough(s) | Status | Blocked on |
|---|----------------|----------------|--------|------------|
| 1 | Entra ID enumeration | (attack toolchain has AzureHound, ROADtools — user-managed Kali) | ⚠️ tooling ready | Plan 11e |
| 2 | Azure Scenario 1 — SP ReadWrite.All | C01 | ❌ | Plan 11b |
| 3 | Azure Scenario 2 — Mail.Read abuse | C02 | ❌ | Plan 11b |
| 4 | Azure Scenario 3 — Role self-assign | C03 | ❌ | Plan 11b |
| 5 | Azure Scenario 4 — SP owner add cred | C04 | ❌ | Plan 11b |
| 6 | Azure Scenario 5 — CBA forge | C05 | ❌ | Plan 11b |
| 7 | Azure Scenario 6 — Conditional Access bypass | C06 | ❌ | Plan 11b |
| 8 | Cloud Sync PHS extraction | C07 | ❌ | Plan 11a |
| 9 | SyncJacking | C08 | ❌ | Plan 11a |
| 10 | Golden SAML | C09 | ❌ | Plan 11a |
| 11 | Hybrid chain — ADCS → CBA → Cloud Admin | H01 | ❌ | Plan 11d |
| 12 | Hybrid chain — Cloud SP → Sync write-back → On-prem | H02 | ❌ | Plan 11d |
| 13 | Hybrid chain — Kerberoast → PHS → Cloud | H03 | ❌ | Plan 11d |
| 14 | Hybrid chain — Cloud CA bypass → Token → RBCD | H04 | ❌ | Plan 11d |

**Note:** CARTP uses a real Microsoft 365 tenant. CADRE supports two modes:
- **Live tenant** — free Microsoft 365 developer tenant + Azure free trial (cost: $0)
- **Offline replay** — recorded Graph API fixtures replay the same attacks without a tenant

---

## 8 · CARTE — Certified Azure Red Team Expert (Altered Security)

**Target: 80% with Plan 11f** · currently 0%

| # | Syllabus topic | Walkthrough | Status | Blocked on |
|---|----------------|-------------|--------|------------|
| 1 | Azure RM subscription escalation | A01 | ❌ | Plan 11f |
| 2 | PIM eligibility abuse | A02 | ❌ | Plan 11f |
| 3 | Cross-tenant B2B guest abuse | A03 | ❌ | Plan 11f |
| 4 | Azure Arc → on-prem control | A04 | ❌ | Plan 11f |
| 5 | Managed Identity abuse | (folded into A01-A02) | ❌ | Plan 11f |
| 6 | Key Vault access via PIM | (folded into A02) | ❌ | Plan 11f |
| 7 | RBAC custom role chains | (folded into A01) | ❌ | Plan 11f |
| 8 | Stratus Red Team cloud TTPs | (sibling project) | ❌ | Plan 10 |

**Note:** CARTE is significantly more involved than CARTP. CADRE will deliver the
Azure RM attack surface; you supply the Azure free-trial subscription.

---

## What CADRE *Doesn't* Cover (deliberate scope choices)

| Topic | Why not |
|-------|---------|
| OSEP / evasion / malware development | Different specialty — separate sibling project, doesn't need AD |
| Web app pentesting (OSWA, PortSwigger) | Out of AD scope |
| Reverse engineering (GREM, OSEE) | Out of AD scope |
| Mobile pentesting | Out of scope |
| Wireless pentesting | Out of scope |
| Caldera as primary emulation | Optional; C2Stack (Plan 10) preferred |
| Exchange-specific attacks | Needs Exchange server — not in the 7-core + 3-extension VM set |
| Sentinel as SIEM | Elastic is the telemetry sink; Sentinel is paid + cloud-only |

---

## How to Start

1. Pick your target cert from the table at the top of this page
2. Deploy CADRE — [`docs/deployment.md`](deployment.md)
3. Find your cert path: [`attack-matrix/05-study-guide/`](../attack-matrix/05-study-guide/README.md)
4. Run walkthroughs in the listed order
5. Observe telemetry: [`docs/forensic-workflow.md`](forensic-workflow.md)
6. After each attack, look up what landed in which index: [`docs/dfir-logging-reference.md`](dfir-logging-reference.md)

---

## Honesty Statement

CADRE is **unaffiliated** with any cert vendor. Coverage percentages are the project
team's honest estimates against published exam outlines, and may differ from official
syllabus changes. CADRE is a **practice substrate** — passing a cert still requires
deliberate study with the vendor's official materials.

*All cert names are trademarks of their respective vendors. CADRE only references them
for educational alignment.*
