# CADRE — Course Comparison

Technique-by-technique cross-cert mapping. For full detail, see `docs/internal/course-comparison.md`.

---

## Course Profiles

### CRTP — Certified Red Team Professional (Altered Security)

| Field | Detail |
|-------|--------|
| **Target** | Red teamers new to AD attacks |
| **Format** | Self-paced lab manual + 48-hr exam |
| **Lab** | ~15 VMs, 5 domains, Server 2022 |
| **Focus** | Foundational: Kerberos attacks, delegation, DCSync, basic ACL |
| **CADRE WT** | 001, 003, 004, 009, 010, 011, 012, 013, 015, 050 (ESC1) |
| **Coverage** | ~93% of CRTP techniques covered in CADRE |

### CRTE — Certified Red Team Expert (Altered Security)

| Field | Detail |
|-------|--------|
| **Target** | Experienced red teamers |
| **Format** | Self-paced lab manual + 48-hr exam |
| **Lab** | ~20 VMs, 8 domains, Server 2025 with hardened security |
| **Focus** | Advanced: gMSA, dMSA, cross-forest, ADCS, GPO abuse, AdminSDHolder |
| **CADRE WT** | 001-033 (all on-prem), 050-053, 055, 062 |
| **Coverage** | ~95% of CRTE techniques covered in CADRE |

### CESP-ADCS — Certified Enterprise Security Professional — ADCS (Altered Security)

| Field | Detail |
|-------|--------|
| **Target** | AD CS specialists |
| **Format** | Self-paced lab manual + 48-hr exam |
| **Lab** | ~12 VMs, 3 forests, ADCS-focused |
| **Focus** | ESC1-15, certificate theft, Pass-the-Cert, UnPAC-the-Hash, Golden Cert |
| **CADRE WT** | 008 (Shadow Credentials), 013-014 (ACL), 018-021 (THEFT), 050-062 (ESC) |
| **Coverage** | ~43% — ADCS template attacks covered, but Pass-the-Cert/UnPAC/Code Signing/EFS not yet built |

### HTB CAPE — Certified AD Pentesting Expert (Hack The Box)

| Field | Detail |
|-------|--------|
| **Target** | Practical AD pentesters |
| **Format** | 15 PDF modules + 48-hr exam |
| **Lab** | ~10 VMs, 1 forest, Server 2022 |
| **Focus** | Full-spectrum AD: all Kerberos, delegation, ACL, coercion, MSSQL, Linux, SCCM |
| **CADRE WT** | 001-048 (almost all on-prem + MSSQL + Linux + SCCM) |
| **Coverage** | ~88% — broadest coverage in CADRE |

### OSCP+ — Offensive Security Certified Professional Plus (OffSec)

| Field | Detail |
|-------|--------|
| **Target** | Entry-level penetration testers |
| **Format** | PEN-200 course + 24-hr exam |
| **Lab** | ~6 VMs, 1 domain, Server 2022 |
| **Focus** | AD fundamentals plus non-AD attack techniques |
| **CADRE WT** | 003, 009, 015, 022, 028, 031, 032, 040, 041, 043 |
| **Coverage** | ~93% — AD portion covered; non-AD content (web, Linux privesc) not in CADRE |

### WKL-OADOC — Offensive AD Operations Certification (WhiteKnight Labs)

| Field | Detail |
|-------|--------|
| **Target** | Advanced Windows operators |
| **Format** | Online course + practical exam |
| **Lab** | Dedicated WKL lab environment |
| **Focus** | CertPotato, WSUS, SCCM, VSC — niche Windows-internal attacks |
| **CADRE WT** | 029, 030, 034-039, 049 |
| **Coverage** | ~13% — niche techniques; SCCM + WSUS coverage is strong |

### CARTP — Certified Azure Red Team Professional (Altered Security)

| Field | Detail |
|-------|--------|
| **Target** | Red teamers moving to cloud |
| **Format** | Self-paced + 48-hr exam |
| **Lab** | Azure tenant + on-prem hybrid |
| **Focus** | Entra ID/ Azure AD attacks: PHS, PTA, Cloud Sync, EntraGoat scenarios |
| **CADRE WT** | 009 (DCSync — foundation for PHS), 031 (Password spray), KERB foundational |
| **Coverage** | ~40% on foundational on-prem; cloud attacks deferred to Plan 11 |

### CARTE — Certified Azure Red Team Expert (Altered Security)

| Field | Detail |
|-------|--------|
| **Target** | Experienced Azure red teamers |
| **Format** | Self-paced + 48-hr exam |
| **Lab** | Multi-tenant Azure environment |
| **Focus** | Azure RM, Privileged Identity Management, cross-tenant, Azure Arc |
| **CADRE WT** | None yet — all cloud attacks deferred to Plan 11 |
| **Coverage** | ~0% currently |

---

## Comparison Table

| Aspect | CRTP | CRTE | CESP-ADCS | HTB CAPE | OSCP+ | WKL-OADOC | CARTP | CARTE |
|--------|------|------|-----------|----------|-------|-----------|-------|-------|
| **Provider** | Altered Security | Altered Security | Altered Security | HTB Academy | OffSec | WKL | Altered Security | Altered Security |
| **Level** | Intermediate | Advanced | Expert | Intermediate | Entry | Advanced | Intermediate | Expert |
| **On-prem AD** | Core focus | Core focus | Secondary | Core focus | Partial | Core focus | Foundation | None |
| **Cloud** | None | Hybrid only | ADCS only | None | None | None | Core focus | Core focus |
| **ADCS** | ESC1 only | ESC1-3, 8-10 | All ESC1-15 | ESC1-11 | None | None | None | None |
| **SCCM** | None | None | None | Covered | None | Covered | None | None |
| **Linux AD** | None | None | None | Covered | None | None | None | None |
| **Exam Style** | Lab manual simulation | Lab manual simulation | Manual + practical | Practical CTF | Proctored | Practical | Manual + Azure | Manual + Azure |
| **CADRE Coverage** | ~93% | ~95% | ~43% | ~88% | ~93% | ~13% | ~40% | ~0% |

## Key Takeaways

1. **HTB CAPE** benefits most from CADRE (broadest technique overlap at 88%)
2. **CRTE** is the best-fit cert for the full on-prem CADRE attack surface (95% coverage)
3. **CESP-ADCS** has the biggest portable gap — Pass-the-Cert, UnPAC, Code Signing, EFS are not yet implemented
4. **CARTP/CARTE** coverage will expand when Plan 11 (cloud/hybrid) walkthroughs are built
5. **WKL-OADOC** has niche overlap — CADRE covers SCCM + WSUS well, but WKL's unique techniques (AppLocker bypass, WDAC) are OSEP-scope
