# CADRE — Certification Coverage Matrix

Cross-reference of 75 campaign WT#s × 8 certifications. ✅ covered, ❌ not covered, — not applicable.

> **Status notes applied 2026-06-03 per campaign restructure:**
> - ~~WT028~~ ❌ Invalid (null session) — marked ❌ for all certs
> - ~~WT031~~ ⏳ Pending relocation — marked ❌ for all certs until reinserted
> - ~~WT018-020~~ ❌ Non-functional on Server 2025 — marked ❌ for all certs

| WT# | Title | CRTP | CRTE | CESP-ADCS | HTB CAPE | OSCP+ | WKL-OADOC | CARTP | CARTE |
|-----|-------|------|------|-----------|----------|-------|-----------|-------|-------|
| 002 | Kerberoasting (AES) | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| 003 | AS-REP Roasting | ✅ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| 004 | Unconstrained Delegation | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 005 | Constrained Delegation (w/ proto) | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 006 | Constrained Delegation (w/o proto) | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 007 | RBCD | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 008 | Shadow Credentials | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 009 | DCSync | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ |
| 010 | Golden Ticket | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| 011 | Silver Ticket | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| 012 | Diamond Ticket (Server 2025) | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 013 | WriteDacl Abuse | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 014 | GenericWrite Abuse | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 015 | ForceChangePassword | ✅ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| 016 | GenericAll on OU | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 017 | PrinterBug (SpoolSample) | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 018 | ~~PetitPotam (EFS)~~ ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 019 | ~~DFSCoerce~~ ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 020 | ~~ShadowCoerce~~ ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 021 | NTLM Relay → LDAP | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 022 | NTLM Relay → SMB | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| 023 | GPO Abuse | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 024 | gMSA Password Extraction | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 025 | AdminSDHolder Persistence | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 026 | dMSA / BadSuccessor | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 027 | SPN Jacking (CVE-2026-25177) | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 028 | ~~Null Session Enumeration~~ ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 029 | CertPotato (DCOM) | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| 030 | WSUS Abuse | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| 031 | ~~Password Spray~~ ⏳ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 032 | Token Impersonation | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| 033 | Cross-Forest Kerberoast | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 034 | SCCM NAA Extraction | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ |
| 035 | SCCM PXE Boot Abuse | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ |
| 036 | SCCM Client Push Relay | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ |
| 037 | SCCM CMPivot Abuse | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ |
| 038 | SCCM App Deployment | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ |
| 039 | SCCM Site Takeover | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ |
| 040 | MSSQL Linked Server Hop | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| 041 | MSSQL xp_cmdshell | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| 042 | MSSQL CLR Assembly | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 043 | MSSQL Impersonation | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| 044 | MSSQL-on-Linux Lateral | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 045 | SSSD Ticket Extraction | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 046 | Linux Keytab Abuse | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 047 | NFS Kerberos Mount Abuse | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 048 | Podman Container Escape | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 049 | Virtual Smart Card Enrollment | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| 050 | ESC1 — Enrollee Supplies Subject | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 051 | ESC2 — Any Purpose EKU | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 052 | ESC3 — Certificate Request Agent | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 053 | ESC4 — Writable Template ACL | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 054 | ESC6 — EDITF_ATTRIBUTESUBJECTALTNAME2 | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 055 | ESC7 — CA Manager Approve | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 056 | ESC8 — Web Enrollment Relay | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 057 | ESC9 — No Security Extension | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 058 | ESC10 — Weak Certificate Binding | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 059 | ESC11 — RPC Enrollment Relay | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 060 | ESC13 — Issuance Policy Group Map | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 061 | ESC14 — Explicit Cert Mapping | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 062 | ESC15 — EKUwu (v1 Template) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

## Coverage Summary

| Cert | ✅ Count | Coverage Quality | Primary Focus |
|------|:--------:|------------------|---------------|
| **CRTP** | 9 | Good — core Kerberos, delegation, DCSync, basic ACL all covered. CRTP's LLMNR/SMB relay not in CADRE (Server 2025 hardened). | Foundational AD attacks |
| **CRTE** | 22 | Strong — most advanced AD techniques covered. Cross-forest, ADCS, gMSA, dMSA, GPO, AdminSDHolder all present. | Advanced AD + cross-forest |
| **CESP-ADCS** | 10 | Moderate — ESC1-14 deployed, but Pass-the-Cert/UnPAC-the-Hash not built. | ADCS certificate abuse |
| **HTB CAPE** | 48 | Excellent — broadest coverage in CADRE. Full AD + MSSQL + Linux + SCCM + ADCS. WT018-020 (coercion non-functional) are the main gap. | Full-spectrum AD |
| **OSCP+** | 11 | Good — all core AD techniques for OSCP+ covered. LLMNR/SMB relay not in CADRE (Server 2025). | AD fundamentals |
| **WKL-OADOC** | 9 | Partial — SCCM, WSUS, CertPotato, ADCS covered. DPAPI, CredGuard, LSA bypass not built. | Niche enterprise techniques |
| **CARTP** | 1 | Minimal (by design) — only on-prem foundations (DCSync). Cloud/hybrid attacks deferred to Plan 11. | Cloud prerequisite |
| **CARTE** | 0 | None — all cloud attacks deferred to Plan 11. | Cloud |

> Percentages intentionally omitted — each cert tests a different subset of techniques. Counts are ✅ from the matrix above. The 59 core AD attacks already cover most foundational techniques. Missing items are either non-AD (cloud, web) or deliberately excluded (coercion variants not functional on Server 2025).
