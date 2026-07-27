# CAPE — Certified AD Pentesting Expert (Hack The Box)

## Target Audience

Experienced penetration testers pursuing HTB's CAPE certification. Requires broad offensive AD skills including Linux-integrated environments.

## Exam Format

| Detail | Value |
|--------|-------|
| Duration | 7 days practical |
| Objective | Compromise multiple AD sets with increasing complexity |
| Passing | Report with methodology for each set |
| Format | Multiple interconnected AD environments |

## Focus Areas

- Full-spectrum AD attacks (coercion, relay, Kerberos, ACL)
- Linux AD member attacks (SSSD, Kerberos on Linux)
- MSSQL database-linked attacks
- Cross-forest and cross-domain attacks
- Coercion-based authentication relay chains
- Named pipe and printer bug coercion

## Prerequisite Knowledge

- CRTP-level on-prem AD skills
- Linux command-line proficiency (Kerberos tools, impacket, responder)
- MSSQL enumeration and querying
- Understanding of SMB, LDAP, HTTP relay chains
- Familiarity with BloodHound / BloodHound CE

## Walkthrough Sequence (23 total)

Complete in this order for progressive difficulty:

| #  | WT ID  | Title | Difficulty |
|----|--------|-------|------------|
| 1  | WT#003 | AS-REP Roasting | Easy |
| 2  | WT#002 | AES Kerberoasting | Easy |
| 3  | WT#041 | MSSQL xp_cmdshell | Easy |
| 4  | WT#009 | DCSync | Medium |
| 5  | WT#004 | Unconstrained Delegation | Medium |
| 6  | WT#007 | RBCD | Medium |
| 7  | WT#008 | Shadow Credentials | Medium |
| 8  | WT#017 | PrinterBug Coercion (MS-RPRN) ✅ | Medium |
| 9  | WT#021 | NTLM Relay to LDAP | Medium |
| 10 | WT#022 | NTLM Relay to SMB | Medium |
| 11 | WT#015 | ACL — ForceChangePassword | Medium |
| 12 | WT#033 | Cross-Forest Kerberoast | Medium |
| 13 | WT#048 | Podman Container Escape (Linux) | Hard |
| 14 | WT#045 | SSSD Ticket Extraction (Linux) | Hard |
| 15 | WT#046 | MSSQL Keytab Abuse (Linux) | Hard |
| 16 | WT#044 | MSSQL-on-Linux Lateral (linked server) | Hard |
| 17 | WT#047 | NFS Kerberos Mount Abuse | Hard |
| 18 | WT#036 | SCCM Client Push Relay | Hard |
| 19 | WT#034 | SCCM NAA Credential Extraction | Hard |
| 20 | WT#038 | SCCM Application Deployment | Hard |
| 21 | WT#030 | WSUS Abuse | Hard |
| 22 | WT#057 | ADCS ESC8 — NTLM Relay to CA | Hard |
| 23 | WT#010 | Golden Ticket + SID History (EA escalation) | Hard |

> **Notes:** WT018 (PetitPotam) ❌, WT019 (DFSCoerce) ❌, WT020 (ShadowCoerce) ❌ — non-functional on Server 2025. Use WT017 (PrinterBug) for confirmed coercion detection.

## Estimated Time

| Phase | Duration |
|-------|----------|
| Core AD walkthroughs (1–13) | 15–20 hours |
| Advanced post-exploitation (14–23) | 20–25 hours |
| Exam simulation / set practice | 15–20 hours |
| **Total** | **4–6 weeks at ~2h/day** |

## Coverage: ~80%

CADRE covers most CAPE techniques. Gaps:
- Some Linux-specific AD attack variants (Kerberos on Linux constrained delegation)
- CAPE's `pindicator`-style pivoting scenarios not replicated
- No Azure AD hybrid component (covered in CARTE path)
- Some custom HTB exam tooling (not replicated in CADRE)

## CADRE-Specific Advantages for CAPE

| Feature | Benefit |
|---------|---------|
| Linux AD member (`linux01.cadre.local`) with SSSD + Podman + NFS | Linux attack path practice (WT#044-048) |
| MSSQL on `mbr01` with linked servers to mbr02 + linux01 | Database lateral movement chain (WT#044) |
| Confirmed coercion primitive — PrinterBug (WT#017) | Reliable coercion-to-relay practice (12 fires verified) |
| SCCM infrastructure on `mbr02.range.local` | Enterprise SCCM attack chain |
| 3-domain forest with external trust | Multi-forest scenarios mirroring CAPE sets |
