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
| 1  | WT#003 | AS-REP Roasting | Easy |
| 2  | WT#002 | AES Kerberoasting | Easy |
| 3  | WT#041 | MSSQL xp_cmdshell | Easy |
| 4  | WT#007 | RBCD | Medium |
| 5  | WT#022 | NTLM Relay to SMB | Medium |
| 6  | WT#009 | DCSync | Medium |
| 7  | WT#010 | Golden Ticket + SID History | Medium |
| 8  | WT#015 | ACL — ForceChangePassword | Medium |
| 9  | WT#036 | SCCM Client Push Relay | Medium |
| 10 | WT#034 | SCCM NAA Credential Extraction | Medium |
| 11 | WT#030 | WSUS Abuse | Hard |
| 12 | WT#038 | SCCM Application Deployment | Hard |

> **Notes:** WT028 (null session) ❌ Invalid on Server 2025. WT031 (password spray) ⏳ Pending relocation — valid technique but needs user list. LLMNR/NBT-NS poisoning not deployed in CADRE (Server 2025 disables by default).

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
| AS-REP + Kerberoast with no extra tools | Core OSCP+ Kerberos attack practice |
| SMB signing disabled on mbr01 + mbr02 | NTLM relay practice (common OSCP+ path) |
| Multiple delegation types deployed (unconstrained, constrained, RBCD) | All delegation types seen in OSCP+ |
| BloodHound CE data collected | Rapid path identification (same tool used in exam) |
| SCCM deployed on mbr02.range.local | Newer OSCP+ sets include SCCM attack paths |
| ForceChangePassword ACL (hunter_dfir → chief_command) | Direct ACL abuse path to DA — common OSCP+ pattern |
