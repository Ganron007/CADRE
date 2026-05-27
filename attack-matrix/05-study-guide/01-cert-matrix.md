# CADRE — Certification Coverage Matrix

Cross-reference of all 62 walkthroughs × 8 certifications. ✅ covered, ❌ not covered, — not applicable.

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
| 018 | PetitPotam (EFS) | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 019 | DFSCoerce | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 020 | ShadowCoerce | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 021 | NTLM Relay → LDAP | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 022 | NTLM Relay → SMB | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| 023 | GPO Abuse | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 024 | gMSA Password Extraction | ❌ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 025 | AdminSDHolder Persistence | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 026 | dMSA / BadSuccessor | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| 027 | SPN Jacking (CVE-2026-25177) | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| 028 | Null Session Enumeration | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| 029 | CertPotato (DCOM) | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| 030 | WSUS Abuse | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| 031 | Password Spray | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ |
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

| Cert | Walkthroughs Covered | Coverage % | Primary Focus |
|------|---------------------|-----------|---------------|
| **CRTP** | ~15 | ~24% | Foundational AD attacks (delegation, DCSync, tickets, basic ACL) |
| **CRTE** | ~20 | ~32% | Full AD attack chain incl. advanced ACL, gMSA, cross-forest, ADCS |
| **CESP-ADCS** | ~14 | ~23% | ADCS ESC1-15, certificate theft, Shadow Credentials |
| **HTB CAPE** | ~42 | ~68% | Broadest coverage — AD + MSSQL + Linux + SCCM + ADCS |
| **OSCP+** | ~12 | ~19% | AD fundamentals — Kerberos, DCSync, password spray, basic ACL |
| **WKL-OADOC** | ~8 | ~13% | CertPotato, WSUS, SCCM, VSC — niche Windows attack techniques |
| **CARTP** | ~3 | ~5% | Foundational on-prem (DCSync, password spray, Kerberos) — cloud deferred |
| **CARTE** | ~0 | ~0% | All cloud attacks deferred to Plan 11 |
