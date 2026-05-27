# CRTE — Certified Red Team Expert (Altered Security)

## Target Audience

Penetration testers who already hold CRTP or equivalent experience. Requires comfort with on-prem AD compromise across multiple forests.

## Exam Format

| Detail | Value |
|--------|-------|
| Duration | 48 hours practical |
| Objective | Compromise multi-forest environment (cross-trust attacks) |
| Passing | Report with full attack chain + screenshots |
| Retake | 1 free retake included |

## Focus Areas

- Cross-forest trust attacks
- Forest trust abuse (SID filtering, SIDHistory)
- ADCS attacks (ESC1–ESC8, ESC10)
- SCCM/mecm exploitation
- Advanced delegation chains
- MSSQL database links for lateral movement
- Cross-domain Kerberos attacks

## Prerequisite Knowledge

- CRTP-level skills (Kerberos, ACL abuse, delegation, DCSync)
- Multi-domain trust relationships and SIDHistory concepts
- PKI / ADCS fundamentals
- MSSQL basic administration and queries
- PowerShell remoting and WMI

## Walkthrough Sequence (20 total)

Complete CRTP path first (WT#002, 003, 004, 007, 009, 010, 011, 013, 014, 015, 016, 017, 021, 028, 031),
then continue with:

| #  | WT ID  | Title | Difficulty |
|----|--------|-------|------------|
| 1  | WT#005 | SMB to LDAP Relay (cross-domain) | Medium |
| 2  | WT#006 | Cross-Forest Trust Attack | Medium |
| 3  | WT#008 | SIDHistory Abuse | Medium |
| 4  | WT#012 | MSSQL Database Links | Medium |
| 5  | WT#023 | ESC1 — Misconfigured Certificate Templates | Hard |
| 6  | WT#024 | ESC2 — Any-Purpose Template | Hard |
| 7  | WT#025 | ESC3 — Enrollment Agent | Hard |
| 8  | WT#026 | ESC4 — ACL on Template | Hard |
| 9  | WT#033 | ESC8 — NTLM Relay to CA | Hard |
| 10 | WT#040 | SCCM Client Push Installation | Hard |
| 11 | WT#041 | SCCM NAA Credential Theft | Hard |
| 12 | WT#043 | SCCM Application Deployment | Hard |

## Estimated Time

| Phase | Duration |
|-------|----------|
| CRTP refresher (15 WTs) | 10–15 hours |
| CRTE-specific walkthroughs (12 WTs) | 20–25 hours |
| Multi-forest practice / exam simulation | 15–20 hours |
| **Total** | **4–6 weeks at ~2h/day** |

## Coverage: ~85%

CADRE covers the majority of CRTE attack surface. Gaps:
- Some advanced cross-forest trust scenarios (selective authentication bypass variants)
- SCCM/WSUS attacks limited to what's deployed in lab
- No Azure AD Connect hybrid attacks (handled by CARTE path)

## CADRE-Specific Advantages for CRTE

| Feature | Benefit |
|---------|---------|
| 3-domain forest (`cadre.local` + `child.cadre.local` + `range.local`) | Real multi-forest exam simulation |
| ADCS CA on `mbr02` | PKI attack training (ESC1–ESC8, ESC10) |
| SCCM site server on `mbr04` | Full SCCM attack chain |
| MSSQL on `mbr03` with db links | Database lateral movement practice |
| Linux AD integration | Realistic heterogeneous environment |
