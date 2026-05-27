# CRTP — Certified Red Team Professional (Altered Security)

## Target Audience

Security professionals pursuing Altered Security's CRTP certification. Candidates should have basic AD knowledge and some penetration testing experience.

## Exam Format

| Detail | Value |
|--------|-------|
| Duration | 24 hours practical |
| Objective | Compromise `cadre.local` root domain |
| Passing | Report with screenshots demonstrating full chain |
| Retake | 1 free retake included |

## Focus Areas

- Kerberos attacks (AS-REP roasting, Kerberoasting, Golden/Silver Tickets)
- ACL abuse (AdminSDHolder, RBCD, Shadow Credentials)
- Delegation (Unconstrained, Constrained, Resource-Based)
- DCSync
- Password spraying & brute force
- SMB/CIFS enumeration

## Prerequisite Knowledge

- Windows Active Directory fundamentals (domains, trusts, OUs)
- Basic networking (TCP/IP, DNS, SMB)
- Comfortable with command-line tools (PowerShell, impacket, mimikatz)
- Understanding of Kerberos authentication flow

## Walkthrough Sequence (15 total)

Complete in this order for progressive difficulty:

| #  | WT ID  | Title | Difficulty |
|----|--------|-------|------------|
| 1  | WT#010 | AS-REP Roasting | Easy |
| 2  | WT#009 | Kerberoasting | Easy |
| 3  | WT#002 | LLMNR/NBT-NS Poisoning | Easy |
| 4  | WT#003 | SMB Relay | Easy |
| 5  | WT#011 | Password Spraying | Easy |
| 6  | WT#004 | IPv6 DNS Takeover (mitm6) | Medium |
| 7  | WT#007 | DCSync | Medium |
| 8  | WT#013 | Unconstrained Delegation | Medium |
| 9  | WT#014 | Constrained Delegation | Medium |
| 10 | WT#015 | Resource-Based Constrained Delegation (RBCD) | Medium |
| 11 | WT#016 | ACL Abuse — AdminSDHolder | Medium |
| 12 | WT#017 | ACL Abuse — GenericWrite/GenericAll | Hard |
| 13 | WT#021 | Golden Ticket | Hard |
| 14 | WT#031 | Silver Ticket | Hard |
| 15 | WT#028 | Shadow Credentials | Hard |

## Estimated Time

| Phase | Duration |
|-------|----------|
| Walkthroughs (learning) | 15–20 hours |
| Practice / lab repetition | 10–15 hours |
| **Total** | **2–3 weeks at ~2h/day** |

## Coverage: ~90%

CRTP is almost entirely on-prem AD compromise — CADRE covers all major attack types tested. Minor gaps:
- Manual ACL enumeration without BloodHound (CADRE uses BH by default)
- Some older relay variants (SMB->LDAP relay variants)
- Report writing format specifics (candidate's own documentation)

## What CADRE Adds Beyond CRTP Scope

| Feature | Benefit |
|---------|---------|
| Multi-domain forest (`cadre.local` + `child.cadre.local`) | Prepares for CRTE cross-trust attacks |
| Linux AD member (`lnx01`) | Linux-based attack paths not in CRTP |
| MSSQL on `mbr03` | Database-linked attacks, lateral movement via SQL |
| Sysmon + DFIR telemetry | Understand what defenders see — offensive ops tradecraft |
| BloodHound CE pre-deployed | Instant ACE path analysis |
| `certipy` + PKI templates | ADCS attack foundations (bridge to CESP-ADCS) |
