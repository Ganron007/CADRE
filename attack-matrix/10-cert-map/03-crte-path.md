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

Complete CRTP path first (WT#003, 002, 041, 009, 004, 007, 010, 015, 013, 014, 016),
then continue with:

| #  | WT ID  | Title | Difficulty |
|----|--------|-------|------------|
| 1  | WT#021 | NTLM Relay to LDAP | Medium |
| 2  | WT#033 | Cross-Forest Kerberoast | Medium |
| 3  | WT#010 | Golden Ticket + SID History (EA escalation) | Medium |
| 4  | WT#044 | MSSQL-on-Linux Lateral (linked server) | Medium |
| 5  | WT#050 | ADCS ESC1 — Misconfigured Certificate Templates | Hard |
| 6  | WT#051 | ADCS ESC2 — Any-Purpose EKU | Hard |
| 7  | WT#052 | ADCS ESC3 — Certificate Request Agent | Hard |
| 8  | WT#053 | ADCS ESC4 — Writable Template ACL | Hard |
| 9  | WT#057 | ADCS ESC8 — NTLM Relay to CA Web Enrollment | Hard |
| 10 | WT#036 | SCCM Client Push Relay | Hard |
| 11 | WT#034 | SCCM NAA Credential Extraction | Hard |
| 12 | WT#038 | SCCM Application Deployment | Hard |

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
| ADCS CA on `dc01.cadre.local` | PKI attack training (ESC1–ESC14) |
| SCCM site server on `mbr02.range.local` | Full SCCM attack chain |
| MSSQL on `mbr01` with linked servers to mbr02 + linux01 | Database lateral movement practice |
| Linux AD integration (`linux01.cadre.local`) | Realistic heterogeneous environment |
