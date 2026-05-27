# OSCP+ — AD Portion (Offensive Security)

## Target Audience

OSCP+ candidates who want to maximize AD-related points (~40% of exam). Assumes general penetration testing ability; this path covers only the AD-specific skills tested.

## Exam Format

| Detail | Value |
|--------|-------|
| Duration | 24 hours practical |
| Objective | 3-machine AD set + individual standalone boxes |
| AD Weight | ~40% of total exam points |
| Passing | 70+ points (AD set is critical) |
| Environment | Single AD domain with typical misconfigurations |

## Focus Areas

- Core AD reconnaissance and enumeration
- SMB relay and LLMNR/NBT-NS poisoning
- Kerberos attacks (AS-REP roasting, Kerberoasting)
- DCSync
- ACL abuse (basic)
- AD delegation attacks
- Privilege escalation within domain

## Prerequisite Knowledge

- General penetration testing methodology
- Basic networking (ports, services, protocols)
- Comfortable with Linux command line
- No prior AD experience strictly required, but helpful

## Walkthrough Sequence (12 total)

Complete in this order for progressive difficulty:

| #  | WT ID  | Title | Difficulty |
|----|--------|-------|------------|
| 1  | WT#003 | SMB Relay | Easy |
| 2  | WT#009 | Kerberoasting | Easy |
| 3  | WT#010 | AS-REP Roasting | Easy |
| 4  | WT#015 | Resource-Based Constrained Delegation (RBCD) | Medium |
| 5  | WT#022 | SMB to LDAP Relay | Medium |
| 6  | WT#028 | Shadow Credentials | Medium |
| 7  | WT#031 | Silver Ticket | Medium |
| 8  | WT#032 | Linux Kerberos Attacks | Medium |
| 9  | WT#040 | SCCM Client Push Installation | Medium |
| 10 | WT#041 | SCCM NAA Credential Theft | Medium |
| 11 | WT#042 | SCCM Policy Abuse | Hard |
| 12 | WT#043 | SCCM Application Deployment | Hard |

## Estimated Time

| Phase | Duration |
|-------|----------|
| Core AD walkthroughs (1–8) | 10–15 hours |
| Advanced/WT#040-043 | 5–8 hours |
| Practice / AD set repetition | 5–10 hours |
| **Total** | **1–2 weeks additional AD study (on top of OSCP+ prep)** |

## Coverage: ~90% of OSCP+ AD Objectives

CADRE covers the vast majority of AD attack types tested in OSCP+. Minor gaps:
- OSCP+ may use non-standard tooling (no mimikatz restriction — CADRE uses full toolset)
- Exam environment uses a single small domain (CADRE has 3-domain forest — more complex)
- Some OSCP+ AD sets include custom misconfigurations not in standard playbooks

## CADRE-Specific Advantages for OSCP+ AD

| Feature | Benefit |
|---------|---------|
| LLMNR/NBT-NS poisoning enabled | Practice the #1 initial access vector for OSCP AD sets |
| SMB relay misconfigured on member hosts | Reliable relay practice (common OSCP+ exam path) |
| Multiple delegation types deployed | RBCD, constrained, unconstrained — all seen in OSCP+ |
| BloodHound CE pre-loaded | Rapid path identification (same tool used in exam) |
| SCCM deployed | Newer OSCP+ sets include SCCM attack paths |
| Linux AD member | Covers Linux-integrated AD scenarios appearing in OSCP+ |
