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

## Walkthrough Sequence (25 total)

Complete in this order for progressive difficulty:

| #  | WT ID  | Title | Difficulty |
|----|--------|-------|------------|
| 1  | WT#002 | LLMNR/NBT-NS Poisoning | Easy |
| 2  | WT#003 | SMB Relay | Easy |
| 3  | WT#009 | Kerberoasting | Easy |
| 4  | WT#004 | IPv6 DNS Takeover (mitm6) | Medium |
| 5  | WT#007 | DCSync | Medium |
| 6  | WT#013 | Unconstrained Delegation | Medium |
| 7  | WT#017 | ACL Abuse — GenericWrite/GenericAll | Medium |
| 8  | WT#018 | Coercion — Printer Bug (MS-RPRN) | Medium |
| 9  | WT#019 | Coercion — PetitPotam (MS-EFSRPC) | Medium |
| 10 | WT#020 | Coercion — ShadowCoerce | Medium |
| 11 | WT#021 | Golden Ticket | Medium |
| 12 | WT#022 | SMB to LDAP Relay | Medium |
| 13 | WT#032 | Linux Kerberos Attacks | Hard |
| 14 | WT#040 | SCCM Client Push Installation | Hard |
| 15 | WT#041 | SCCM NAA Credential Theft | Hard |
| 16 | WT#042 | SCCM Policy Abuse | Hard |
| 17 | WT#043 | SCCM Application Deployment | Hard |
| 18 | WT#044 | MSSQL Linked Servers | Hard |
| 19 | WT#045 | MSSQL Trust Abuse | Hard |
| 20 | WT#047 | Named Pipe Coercion | Hard |
| 21 | WT#048 | WSUS Exploitation | Hard |
| 22 | WT#033 | ESC8 — NTLM Relay to CA | Hard |
| 23 | WT#008 | SIDHistory Abuse | Hard |

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
| Linux AD member (`lnx01`) with SSSD + Kerberos | Linux attack path practice (WT#032) |
| MSSQL on `mbr03` with linked servers | Database lateral movement chain (WT#044, 045) |
| Multiple coercion primitives (PrinterBug, PetitPotam, ShadowCoerce) | Full coercion-to-relay practice |
| SCCM infrastructure on `mbr04` | Enterprise SCCM attack chain |
| 3-domain forest with external trust | Multi-forest scenarios mirroring CAPE sets |
