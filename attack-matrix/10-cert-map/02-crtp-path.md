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

Complete in this order for progressive difficulty. WT numbers are CADRE's — CRTP focuses on the attack technique, not the lab numbering.

| #  | WT ID  | Title | Difficulty |
|----|--------|-------|------------|
| 1  | WT#003 | AS-REP Roasting | Easy |
| 2  | WT#002 | AES Kerberoasting | Easy |
| 3  | WT#041 | MSSQL xp_cmdshell | Easy |
| 4  | WT#022 | NTLM Relay to SMB | Easy |
| 5  | WT#009 | DCSync | Medium |
| 6  | WT#004 | Unconstrained Delegation | Medium |
| 7  | WT#005 | Constrained Delegation (w/ PT) | Medium |
| 8  | WT#006 | Constrained Delegation (w/o PT) | Medium |
| 9  | WT#007 | Resource-Based Constrained Delegation (RBCD) | Medium |
| 10 | WT#021 | NTLM Relay to LDAP | Medium |
| 11 | WT#015 | ACL — ForceChangePassword | Medium |
| 12 | WT#013 | ACL — WriteDacl | Hard |
| 13 | WT#014 | ACL — GenericWrite | Hard |
| 14 | WT#016 | ACL — GenericAll on OU | Hard |
| 15 | WT#010 | Golden Ticket | Hard |

> **Notes:** WT028 (null session) ❌ Invalid on Server 2025. WT031 (password spray) ⏳ Pending relocation. LLMNR/NBT-NS and IPv6 poisoning are not deployed in CADRE — CRTP focuses on authenticated attacks.

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
