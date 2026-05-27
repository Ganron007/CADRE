# CADRE — External Learning Resources

Curated external resources for AD security testing, organized by category.

---

## Courses & Certifications

### Altered Security

| Course | Cert | Focus | URL |
|--------|------|-------|-----|
| CRTP | Certified Red Team Professional | Foundational AD attacks | https://www.alteredsecurity.com/red-team-lab |
| CRTE | Certified Red Team Expert | Advanced AD with hardened Server 2025 | https://www.alteredsecurity.com/adult-security |
| CESP-ADCS | Cert Enterprise Security Pro — ADCS | ADCS ESC1-15 + certificate attacks | https://www.alteredsecurity.com/cesp |
| CARTP | Certified Azure Red Team Professional | Entra ID / Azure AD attacks | https://www.alteredsecurity.com/azure-lab |
| CARTE | Certified Azure Red Team Expert | Advanced Azure RM / PIM / cross-tenant | https://www.alteredsecurity.com/azure-adult-security |

**Key takeaway:** Altered Security courses are the closest match to CADRE's attack surface. CRTE lab is the only non-CADRE environment that covers Server 2025 AD attacks with Credential Guard, LAPS, WDAC, and PAM trusts.

### Hack The Box

| Course | Cert | Focus |
|--------|------|-------|
| HTB CAPE (Certified AD Pentesting Expert) | CAPE | Full-spectrum AD: Kerberos, delegation, ACL, MSSQL, SCCM, Linux AD |

- **URL:** https://academy.hackthebox.com/
- **Key takeaway:** CAPE is CADRE's broadest cert match (42 walkthroughs overlap). The 15-module PDF series covers AD from enumeration through advanced ADCS.

### Offensive Security

| Course | Cert | Focus |
|--------|------|-------|
| PEN-200 | OSCP+ | AD fundamentals + non-AD pentesting |
| PEN-300 | OSEP | Evasion and defense bypass (separate project) |

- **URL:** https://www.offsec.com/courses/
- **Key takeaway:** OSCP+ AD portion is well-covered by CADRE. OSEP evasion content is not in CADRE scope.

### WhiteKnight Labs

| Course | Cert | Focus |
|--------|------|-------|
| OADOC | Offensive AD Operations Cert | CertPotato, WSUS, SCCM, VSC |

- **URL:** https://whitenightlabs.com/
- **Key takeaway:** Niche Windows-internal attacks. CADRE covers SCCM and WSUS well.

---

## YouTube Channels

| Channel | Focus | URL |
|---------|-------|-----|
| **IAmJakoby** | PowerShell red teaming, AD attack automation | https://youtube.com/@IAmJakoby |
| **John Hammond** | Malware analysis, CTF walkthroughs, AD attacks | https://youtube.com/@JohnHammond010 |
| **Altered Security** | Official course previews, technique demonstrations | https://youtube.com/@AlteredSecurity |
| **SpecterOps** | BloodHound, AD attack research, ADCS deep dives | https://youtube.com/@SpecterOps |
| **The Cyber Mentor** | AD pentesting fundamentals, HTB walkthroughs | https://youtube.com/@TCMSecurityAcademy |
| **13Cubed** | DFIR, detection engineering, Elastic/Splunk | https://youtube.com/@13Cubed |
| **HackerSploit** | AD post-exploitation, C2 frameworks | https://youtube.com/@HackerSploit |
| **SANS DFIR** | Digital forensics and incident response | https://youtube.com/@SANSDFIR |

---

## Books

| Title | Author | Focus |
|-------|--------|-------|
| Active Directory Security Assessment | Rod Trent | Full AD security audit methodology |
| Active Directory Kerberos Attacks | Jake Hounsell | Deep dive into Kerberos exploitation |
| Abusing Active Directory | Nikhil Mittal (am0nsec) | CRTP/CRTE technique compendium |
| The Hacker Playbook 3 | Peter Kim | Practical AD pentesting workflows |
| Red Team Field Manual (RTFM) | Ben Clark | Quick-reference for AD commands |
| Purple Team Field Manual | Mike Torr | AD detection + attack reference |
| Windows Internals Part 1 & 2 | Pavel Yosifovich et al. | Deep Windows internals for evasion |
| Active Directory Cookbook | Brian Svidergol | AD administration and automation |
| Attacking Network Protocols | James Forshaw | Protocol-level exploitation (coercion, relay) |
| Real-World Bug Hunting | Peter Yaworski | Web/AD vulnerability discovery patterns |

---

## HTB Machines for AD Practice

| Machine | Difficulty | Techniques |
|---------|-----------|------------|
| **Forest** | Easy | AS-REP Roasting, Kerberoasting, DCSync |
| **Sauna** | Easy | AS-REP Roasting, Kerberoasting, ACL abuse |
| **Scrambled** | Easy | DNS ADIDNS, constrained delegation |
| **Blackfield** | Medium | AS-REP Roasting, Kerberoasting, DCSync |
| **Active** | Medium | GPP password, Kerberoasting |
| **Cascade** | Medium | LDAP enumeration, DPAPI |
| **Resolute** | Medium | Password spray, delegation abuse |
| **Sizzle** | Hard | ADCS, certificate abuse |
| **Forest** | Medium | Delegation, ACL abuse, cross-forest |
| **APT** | Hard | Multi-forest, cross-domain attacks |

**Recommended HTB Pro Labs:**
- **Rastalabs:** AD attack chains with multiple forests
- **Offshore:** Multi-layer AD with pivoting
- **Dante:** Beginner-friendly AD attack progression
- **Cascade:** AD with Exchange component

---

## TryHackMe Rooms

| Room | Focus |
|------|-------|
| **Active Directory Basics** | AD fundamental concepts |
| **Breaching Active Directory** | Initial access techniques |
| **Enumerating AD** | PowerView, BloodHound, LDAP |
| **Lateral Movement** | WMI, WinRM, PsExec, DCOM |
| **AD Persistence** | Golden/Silver tickets, SID History |
| **Kerberos Attacks** | Kerberoasting, AS-REP, delegation |
| **AD CS Abuse** | ESC1, ESC8, certificate attacks |
| **VulnNet Internal** | Full AD attack chain walkthrough |

**Track:** "AD Attack Path" series (7 rooms) covers enumeration through domain escalation.

---

## Community Labs

| Lab | VMs | Description | URL |
|-----|-----|-------------|-----|
| **GOAD (Game of Active Directory)** | ~7-10 | Community AD lab with multiple attack paths | https://github.com/Orange-Cyberdefense/GOAD |
| **BadBlood** | ~5 | Automated vulnerable AD lab generator | https://github.com/davidprowe/BadBlood |
| **PurpleCloud** | ~15 | AD + Azure hybrid lab for purple teaming | https://github.com/iknowjason/PurpleCloud |
| **Vulnerable AD (vulnad)** | ~4 | Lightweight AD lab for beginners | https://github.com/WazeHell/vulnerable-ad |
| **ADAttackSimulation** | ~3 | Simulated AD attacks for detection testing | https://github.com/splunk/ADAttackSimulation |

**Note:** These labs use Server 2016/2019/2022 — they do not cover Server 2025-specific attacks (dMSA, Diamond Ticket, AES-only Kerberos).

---

## Tool Repositories

| Tool | Purpose | URL |
|------|---------|-----|
| **BloodHound** | AD attack path visualization | https://github.com/BloodHoundAD/BloodHound |
| **BloodHound CE** | Community Edition (Web UI) | https://github.com/SpecterOps/BloodHound |
| **Impacket** | AD protocol exploitation framework | https://github.com/fortra/impacket |
| **Certipy** | ADCS exploitation | https://github.com/ly4k/Certipy |
| **Coercer** | Auto-coercion framework | https://github.com/p0dalirius/Coercer |
| **PowerView** | AD enumeration (PowerShell) | https://github.com/PowerShellMafia/PowerSploit |
| **ADModule** | Microsoft's AD PowerShell module | Built into RSAT tools |
| **NetExec (nxc)** | Network execution (CrackMapExec fork) | https://github.com/Pennyw0rth/NetExec |
| **PKINITtools** | Kerberos PKINIT abuse | https://github.com/dirkjanm/PKINITtools |
| **Misconfiguration-Manager** | SCCM abuse toolkit | https://github.com/subat0mik/Misconfiguration-Manager |

---

## Conferences & Research

| Conference | Relevant Tracks | URL |
|-----------|----------------|-----|
| **SpecterOps CON** | AD attacks, BloodHound, ADCS | https://specterops.io |
| **Wild West Hackin' Fest** | Red teaming, AD exploitation | https://wildwesthackinfest.com |
| **DEF CON AD Village** | AD security research | https://ad.evilcorp.org |
| **Troopers** | AD security, Kerberos, LDAP | https://www.troopers.de |
| **Blue Team Con** | AD detection, DFIR | https://blueteamcon.com |

**Must-read AD research papers:**
- "Kerberos Attacks" by Sean Metcalf (Pyrotech)
- "ADCS Attack Paths" by Will Schroeder and Lee Christensen (SpecterOps — Certified Pre-Owned)
- "SCCM Misconfiguration-Manager" by Matt Nelson and Chris Thompson
- "Coercion and Relay" by Dirk-jan Mollema (PetitPotam, DFSCoerce)
