# CADRE — Learning Path (75 Walkthroughs)

Recommended sequence through all 75 CADRE walkthroughs, organized by skill progression. Start at Tier 1 regardless of certification target.

---

## Tier 1 — Initial Access (Easy, No Creds Needed / Assumed Breach)

**Overview:** Start with a low-priv domain credential. These techniques identify users, harvest credentials, and establish execution context.

| WT# | Title | Difficulty | Est. Time |
|-----|-------|-----------|-----------|
| 003 | AS-REP Roasting | Easy | 20 min |
| 002 | AES Kerberoasting (via ACE#18 bridge) | Easy | 30 min |

**Total time:** ~50 min

> ~~WT028 (Null Session) ❌ Invalid — SAMR null bind blocked on Server 2025.~~
> ~~WT031 (Password Spray) ⏳ Pending relocation — valid technique awaiting reinsertion.~~

---

## Tier 2 — Credential Harvesting (Easy, Low-Priv Required)

**Overview:** With a low-priv domain account, extract service account credentials, abuse Kerberos, and escalate to domain admin.

### Sub-tier 2a — Kerberoasting & SPN Attacks

| WT# | Title | Difficulty | Est. Time |
|-----|-------|-----------|-----------|
| 002 | AES Kerberoast | Easy | 20 min |
| 033 | Cross-Forest Kerberoast | Easy | 25 min |
| 027 | SPN Jacking (CVE-2026-25177) | Easy | 20 min |

### Sub-tier 2b — Post-DA Persistence (Requires DA)

| WT# | Title | Difficulty | Est. Time |
|-----|-------|-----------|-----------|
| 009 | DCSync | Medium | 15 min |
| 010 | Golden Ticket | Medium | 20 min |
| 011 | Silver Ticket | Medium | 20 min |
| 012 | Diamond Ticket (Server 2025) | Medium | 25 min |

**Total time:** ~2 hr 25 min

---

## Tier 3 — Delegation & ACL Abuse (Medium, Low-Priv Required)

**Overview:** Abuse Kerberos delegation misconfigurations and AD ACLs to escalate privileges without needing domain admin credentials upfront.

### Sub-tier 3a — Delegation Attacks

| WT# | Title | Difficulty | Est. Time |
|-----|-------|-----------|-----------|
| 004 | Unconstrained Delegation | Medium | 30 min |
| 005 | Constrained Delegation (w/ protocol transition) | Medium | 30 min |
| 006 | Constrained Delegation (w/o protocol transition) | Medium | 25 min |
| 007 | Resource-Based Constrained Delegation (RBCD) | Medium | 35 min |
| 008 | Shadow Credentials | Medium | 30 min |

### Sub-tier 3b — ACL Abuse

| WT# | Title | Difficulty | Est. Time |
|-----|-------|-----------|-----------|
| 013 | WriteDacl Abuse | Medium | 25 min |
| 014 | GenericWrite Abuse | Medium | 20 min |
| 015 | ForceChangePassword | Medium | 15 min |
| 016 | GenericAll on OU | Medium | 25 min |

### Sub-tier 3c — Managed Service Accounts

| WT# | Title | Difficulty | Est. Time |
|-----|-------|-----------|-----------|
| 024 | gMSA Password Extraction | Medium | 20 min |
| 026 | dMSA BadSuccessor | Medium | 30 min |

**Total time:** ~5 hr 5 min

---

## Tier 4 — Coercion & Relay (Medium, Low-Priv Required)

**Overview:** Coerce domain controllers or member servers to authenticate to an attacker-controlled relay, then forward those credentials to escalate.

### Sub-tier 4a — Coercion

| WT# | Title | Difficulty | Est. Time |
|-----|-------|-----------|-----------|
| 017 | PrinterBug (SpoolSample) | Medium | 20 min |
| 018 | PetitPotam (EFS) | Medium | 20 min |
| 019 | DFSCoerce | Medium | 20 min |
| 020 | ShadowCoerce | Medium | 20 min |

### Sub-tier 4b — NTLM Relay

| WT# | Title | Difficulty | Est. Time |
|-----|-------|-----------|-----------|
| 021 | NTLM Relay → LDAP (Shadow Credentials/RBCD) | Hard | 35 min |
| 022 | NTLM Relay → SMB | Hard | 30 min |

**Total time:** ~2 hr 25 min

---

## Tier 5 — Post-Exploitation (Hard, DA Required)

**Overview:** Once you have domain admin, these attacks establish persistence, evade detection, and abuse enterprise management systems.

| WT# | Title | Difficulty | Est. Time |
|-----|-------|-----------|-----------|
| 023 | GPO Abuse | Hard | 30 min |
| 025 | AdminSDHolder Persistence | Hard | 25 min |
| 032 | Token Impersonation | Hard | 30 min |

**Total time:** ~1 hr 25 min

---

## Tier 6 — MSSQL Attacks (Medium, Code Execution)

**Overview:** Abuse misconfigured SQL Server instances for lateral movement and code execution across Windows and Linux.

| WT# | Title | Difficulty | Est. Time |
|-----|-------|-----------|-----------|
| 040 | MSSQL Linked Server Hop | Medium | 25 min |
| 041 | MSSQL xp_cmdshell | Medium | 15 min |
| 042 | MSSQL CLR Assembly | Hard | 35 min |
| 043 | MSSQL Impersonation | Medium | 20 min |
| 044 | MSSQL-on-Linux Lateral | Medium | 25 min |

**Total time:** ~2 hr 0 min

---

## Tier 7 — Linux AD Attacks (Medium-Hard, linux01 Access)

**Overview:** Attack techniques against Linux domain members — extract Kerberos tickets, abuse NFS mounts, and escape containers.

| WT# | Title | Difficulty | Est. Time |
|-----|-------|-----------|-----------|
| 045 | SSSD Ticket Extraction | Medium | 25 min |
| 047 | NFS Kerberos Mount Abuse | Medium | 30 min |
| 048 | Podman Container Escape | Hard | 40 min |

**Total time:** ~1 hr 35 min

---

## Tier 8 — SCCM Attacks (Medium-Hard, mbr02 Access)

**Overview:** Abuse Microsoft Configuration Manager (SCCM) misconfigurations for credential theft and privilege escalation.

| WT# | Title | Difficulty | Est. Time |
|-----|-------|-----------|-----------|
| 034 | NAA Credential Extraction | Medium | 20 min |
| 035 | PXE Boot Abuse | Medium | 25 min |
| 036 | Client Push Relay | Hard | 35 min |
| 037 | CMPivot Abuse | Medium | 20 min |
| 038 | Application Deployment | Medium | 25 min |
| 039 | Site Takeover | Hard | 30 min |

**Note:** WT#037-039 require SCCM Console access (cannot be fully automated via WinRM/WMI).

**Total time:** ~2 hr 35 min

---

## Tier 9 — ADCS ESC (Hard, Low-Priv Required)

**Overview:** Active Directory Certificate Services attack chain — exploit misconfigured certificate templates and CA settings to escalate to domain admin.

| WT# | Title | Difficulty | Est. Time |
|-----|-------|-----------|-----------|
| 050 | ESC1 — Enrollee Supplies Subject | Hard | 25 min |
| 051 | ESC2 — Any Purpose EKU | Hard | 20 min |
| 052 | ESC3 — Certificate Request Agent | Hard | 25 min |
| 053 | ESC4 — Writable Template ACL | Hard | 30 min |
| 054 | ESC6 — EDITF_ATTRIBUTESUBJECTALTNAME2 | Hard | 20 min |
| 055 | ESC7 — CA Manager Approve | Hard | 25 min |
| 056 | ESC8 — Web Enrollment Relay | Hard | 30 min |
| 057 | ESC9 — No Security Extension | Hard | 25 min |
| 058 | ESC10 — Weak Certificate Binding | Hard | 20 min |
| 059 | ESC11 — RPC Enrollment Relay | Hard | 30 min |
| 060 | ESC13 — Issuance Policy Group Map | Hard | 25 min |
| 061 | ESC14 — Explicit Cert Mapping | Hard | 30 min |
| 062 | ESC15 — EKUwu (v1 Template, broken) | Hard | — |

**Status:** ESC10 is the only fully working ADCS attack in the current lab. Other ESC attacks require CA service restart (blocked by current lab state). ESC15 excluded (Server 2025 v1 schema limitation, covered by ESC6).

**Total time (when working):** ~5 hr 25 min

---

## Summary

| Tier | Focus Area | Walkthroughs | Est. Total Time |
|------|-----------|-------------|-----------------|
| 1 | Recon & Enum | 028, 031, 003 | 1 hr 10 min |
| 2 | Credential Harvesting | 002, 033, 027, 009, 010, 011, 012 | 2 hr 25 min |
| 3 | Delegation & ACL Abuse | 004-008, 013-016, 024, 026 | 5 hr 5 min |
| 4 | Coercion & Relay | 017-022 | 2 hr 25 min |
| 5 | Post-Exploitation | 023, 025, 032 | 1 hr 25 min |
| 6 | MSSQL Attacks | 040-044 | 2 hr 0 min |
| 7 | Linux AD Attacks | 045, 047, 048 | 1 hr 35 min |
| 8 | SCCM Attacks | 034-039 | 2 hr 35 min |
| 9 | ADCS ESC | 050-062 | 5 hr 25 min |
| **All** | **Full AD Assessment** | **62 WT** | **~24 hr** |
