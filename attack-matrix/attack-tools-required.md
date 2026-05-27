# Attack Tools Required — Master Reference

**Purpose:** Lists every tool required to execute the 63 CADRE Plan 0 walkthroughs.  
**Convention:** CADRE does NOT deploy a Kali VM or any attack machine. Users bring their own tools from Kali, Parrot, Windows, or any platform.  
**How to use:** Before attempting any walkthrough, ensure the listed tools are available. New tools added in future plans go here.

---

## Tool Inventory

| Tool | Min Version | Required For WT# | Install Method |
|------|:-----------:|:----------------:|----------------|
| **impacket** | 0.12.x | 1, 2, 3, 9, 10, 11, 12, 21, 22, 33, 34, 40, 41, 42, 43, 44, 45 | `pipx install impacket` |
| **certipy-ad** | 4.8.x | 8, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62 | `pipx install certipy-ad` |
| **bloodhound-python** | latest | All AD recon | `pip install bloodhound` |
| **bloodyAD** | latest | 7, 8, 13, 14, 15, 16, 23, 24, 25, 26, 27 | `pipx install bloodyAD` |
| **netexec** (nxc) | latest | 28, 31 | `pipx install netexec` |
| **coercer** | latest | 17, 18, 19, 20 | `pipx install coercer` |
| **petitpotam** | latest | 18 | `pipx install petitpotam` |
| **kerbrute** | 1.0.3 | 31 | Download from GitHub releases |
| **SharpSCCM** | latest | 35, 36, 37, 38, 39 | Download from GitHub releases (Windows binary) |
| **Rubeus** | 2.0.0 | 4, 5, 6, 10, 11, 12 | Download from GitHub releases (Windows binary) |
| **Certify** | 1.0.0 | 50, 51, 52, 53, 54, 58, 61, 62 | Download from GitHub releases (Windows binary) |
| **mitm6** | latest | 21, 22 | `pipx install mitm6` |
| **xFreeRDP** / **impacket-psexec** | latest | 34 | apt / pipx |
| **adidnsdump** | latest | 27 | `pipx install adidnsdump` |

---

## Walkthrough → Tool Mapping

### On-Prem AD (WT#1-34)

| WT# | Attack | Primary Tool | Secondary Tool |
|:---:|--------|--------------|----------------|
| 2 | Kerberoasting (AES) | `impacket-GetUserSPNs` | bloodhound-python |
| 3 | AS-REP Roasting | `impacket-GetNPUsers` | kerbrute |
| 4 | Unconstrained Delegation | Rubeus | impacket |
| 5 | Constrained Delegation (prototrans) | Rubeus | impacket |
| 6 | Constrained Delegation (no prototrans) | Rubeus | impacket |
| 7 | RBCD | bloodyAD | impacket |
| 8 | Shadow Credentials | certipy-ad | bloodyAD |
| 9 | DCSync | `impacket-secretsdump` | — |
| 10 | Golden Ticket | `impacket-ticketer` | Rubeus |
| 11 | Silver Ticket | `impacket-ticketer` | Rubeus |
| 12 | Diamond Ticket | Rubeus | impacket |
| 13 | ACL WriteDacl | bloodyAD | bloodhound-python |
| 14 | ACL GenericWrite | bloodyAD | bloodhound-python |
| 15 | ForceChangePassword | bloodyAD | impacket |
| 16 | GenericAll on OU | bloodyAD | bloodhound-python |
| 17 | PrinterBug (SpoolSample) | coercer | impacket |
| 18 | PetitPotam | coercer / petitpotam | impacket |
| 19 | DFSCoerce | coercer | impacket |
| 20 | ShadowCoerce | coercer | impacket |
| 21 | NTLM relay to LDAP | `impacket-ntlmrelayx` | mitm6 |
| 22 | NTLM relay to SMB | `impacket-ntlmrelayx` | mitm6 |
| 23 | GPO abuse | bloodyAD | impacket |
| 24 | gMSA extraction | bloodyAD | gMSADumper |
| 25 | AdminSDHolder | bloodyAD | — |
| 26 | dMSA BadSuccessor | bloodyAD | — |
| 27 | SPN Jacking (CVE-2026-25177) | bloodhound-python | adidnsdump |
| 28 | Null session | netexec (nxc) | enum4linux |
| 29 | CertPotato | CertPotato.exe | — |
| 30 | WSUS abuse | SharpWSUS | — |
| 31 | Password spray | netexec (nxc) | kerbrute |
| 32 | Token impersonation | metasploit (incognito) | — |
| 33 | Cross-forest Kerberoast | `impacket-GetUserSPNs` | — |
| 34 | Restricted Admin RDP | `impacket-psexec` | xFreeRDP |

### SCCM + SQL + Linux (WT#35-50)

| WT# | Attack | Primary Tool | Secondary Tool |
|:---:|--------|--------------|----------------|
| 35 | SCCM NAA extraction | SharpSCCM | — |
| 36 | SCCM PXE boot abuse | SharpSCCM | PXEThief |
| 37 | SCCM client push relay | SharpSCCM | impacket-ntlmrelayx |
| 38 | SCCM CMPivot abuse | SharpSCCM | — |
| 39 | SCCM app deployment | SharpSCCM | — |
| 40 | SQL linked server hop | `impacket-mssqlclient` | — |
| 41 | SQL xp_cmdshell | `impacket-mssqlclient` | — |
| 42 | SQL CLR assembly | `impacket-mssqlclient` | — |
| 43 | SQL impersonation | `impacket-mssqlclient` | — |
| 44-45 | SQL-on-Linux lateral | `impacket-mssqlclient` | — |
| 46 | SSSD ticket extraction | Manual (klist, ccache files) | — |
| 47 | Keytab abuse | klist | — |
| 48 | NFS Kerberos mount | mount + kinit | — |
| 49 | Podman container escape | podman | — |
| 50 | VSC enrollment | certipy-ad | — |

### ADCS ESC (WT#51-62)

| WT# | Attack | Primary Tool | Secondary Tool |
|:---:|--------|--------------|----------------|
| 51 | ESC1 | certipy-ad | Certify |
| 52 | ESC2 | certipy-ad | Certify |
| 53 | ESC3 | certipy-ad | Certify |
| 54 | ESC4 | certipy-ad | bloodyAD |
| 55 | ESC6 | certipy-ad | — |
| 56 | ESC7 | certipy-ad | — |
| 57 | ESC8 | certipy-ad | impacket-ntlmrelayx |
| 58 | ESC9 | certipy-ad | — |
| 59 | ESC10 | certipy-ad | — |
| 60 | ESC11 | certipy-ad | impacket-ntlmrelayx |
| 61 | ESC13 | certipy-ad | — |
| 62 | ESC14 | certipy-ad | — |

---

## Tool Categories

| Category | Tools | Purpose |
|----------|-------|---------|
| **AD Enumeration** | bloodhound-python, netexec, adidnsdump | Reconnaissance |
| **Kerberos** | impacket, Rubeus, kerbrute | Kerberoast, AS-REP, delegation, tickets |
| **AD CS** | certipy-ad, Certify | All 12 ESC attacks |
| **ACL Abuse** | bloodyAD, impacket | WriteDacl, GenericWrite, ForceChangePassword |
| **Relay & Coercion** | impacket-ntlmrelayx, coercer, petitpotam, mitm6 | PrinterBug, PetitPotam, DFS/ShadowCoerce |
| **SCCM** | SharpSCCM, SharpWSUS | Misconfiguration-Manager attacks |
| **SQL** | impacket-mssqlclient | xp_cmdshell, CLR, linked servers |
| **Cloud** | EntraGoat | Hybrid/cloud attack scenarios (Plan 11) |

---

## Installation Quick Reference

```bash
# Core AD tools (pipx)
pipx install impacket certipy-ad bloodyAD netexec coercer petitpotam mitm6 adidnsdump

# BloodHound requires neo4j database
apt install bloodhound neo4j

# Windows binaries — download to any Windows VM or transfer to Kali:
# https://github.com/GhostPack/Rubeus/releases
# https://github.com/GhostPack/Certify/releases
# https://github.com/Mayyhem/SharpSCCM/releases
# https://github.com/ropnop/kerbrute/releases

# Python packages (pip fallback if pipx unavailable)
pip install impacket certipy-ad bloodyAD netexec coercer mitm6
```
