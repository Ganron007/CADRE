# CADRE — Gap Analysis

What CADRE doesn't cover and why. Each gap includes: what's missing, why it's missing, alternative path, and when it might be added.

---

## Core Gaps

### ESC15 (EKUwu) — v1 Template Exploit

| Field | Detail |
|-------|--------|
| **What** | Exploitation of Server 2025 v1 schema certificate templates using Application Policy instead of EKU — tools miss the distinction |
| **Why missing** | Server 2025 CA requires v2 schema for templates. v1 templates cannot be created or published on a Server 2025 CA. |
| **Alternative** | ESC6 (EDITF_ATTRIBUTESUBJECTALTNAME2) covers the same attack surface — SAN injection works on any template without needing v1 schema. |
| **When added** | Not planned — blocked by CA OS version. If a pre-2025 CA or standalone CA is added, ESC15 becomes viable. |

---


### Cloud Attacks (Entra ID / Azure RM / Hybrid Chains)

| Field | Detail |
|-------|--------|
| **What** | C01-C09 (EntraGoat scenarios), H01-H04 (hybrid chains), A01-A04 (Azure RM) — all deferred to Plan 11 |
| **Why missing** | Requires an Azure tenant, Entra ID P2 licensing, and Cloud Sync agent configuration. These are environment dependencies, not code gaps. CADRE's Cloud Sync agent on dc01 is pre-installed but the walkthroughs are not written. |
| **Alternative** | Use Altered Security CARTP/CARTE official labs for Azure attack practice. EntraGoat scenarios can be run in a separate Azure tenant. |
| **When added** | Plan 11 — estimated post Plan 0 completion. Phase 9 in `docs/internal/next-phase-suggestions.md`. |

---

### Federation Attacks (WS-Fed, ADFS)

| Field | Detail |
|-------|--------|
| **What** | Active Directory Federation Services token signing cert extraction, Golden SAML, WS-Fed poisoning, ADFS relay |
| **Why missing** | No ADFS/ADFS-Proxy VM in the lab. CADRE uses Cloud Sync (PHS), not federation. |
| **Alternative** | Practice on Altered Security's official labs or stand up a separate ADFS lab. |
| **When added** | Not planned. Federation requires additional infrastructure (ADFS server, web application proxy) that adds significant VM count. |

---

### Exchange Attacks

| Field | Detail |
|-------|--------|
| **What** | ProxyShell, ProxyLogon, mail-enabled AD abuse, Exchange ACL attacks |
| **Why missing** | No Exchange Server VM. Exchange is a heavy, complex deployment that conflicts with CADRE's lightweight 10-VM target. |
| **Alternative** | HTB Pro Labs (e.g., "Cascade", "Early Access"), official Exchange attack labs, or THM Exchange rooms. |
| **When added** | Not planned. Exchange would add 2-3 VMs (Exchange CAS + Mailbox). Considered out of scope for Plan 0. |

---

### Advanced C2 Frameworks

| Field | Detail |
|-------|--------|
| **What** | Sliver, Covenant, Havoc, Brute Ratel, Cobalt Strike — full C2 operations |
| **Why missing** | C2 frameworks are user-managed. CADRE provides the target substrate — users bring their own attacker host (Kali/Parrot, **user-managed — CADRE does not ship one**) with tools like Impacket, certipy, etc. |
| **Alternative** | Run Sliver/Havoc from your user-managed attacker host, or any C2 that supports SOCKS proxying into the `192.168.77.0/24` network. |
| **When added** | Not planned at the walkthrough level. A separate "C2 integration" guide could be written as a community extension. |

---

## ADCS ESC Attacks (Broken — CA Service Stopped)

| Field | Detail |
|-------|--------|
| **What** | All ESC attacks except ESC10. CA service (`CertSvc`) is stopped or in an inconsistent state, preventing template enrollment. |
| **Why missing** | The ADCS CA configuration on dc01 requires the CA service to be running and the templates to be published. Current lab state has the CA service stopped after SCCM deployment modifications. |
| **Alternative** | ESC10 (Weak Certificate Binding) works without CA service — it's a registry-only change on the KDC. For other ESC attacks, restart `CertSvc` on dc01 and verify templates are published via `certutil -catemplates`. |
| **When added** | Fix is in progress — CA service restart will be added to the Ansible deployment so templates are published on every provision. |

---

### WT#029 — CertPotato (DCOM → Certificate)

| Field | Detail |
|-------|--------|
| **What** | Abuse IIS AppPool identity to enroll a certificate via DCOM and Kerberos delegation |
| **Why missing** | Requires IIS AppPool running on mbr01 with a specific DCOM configuration that is not part of the current IIS/ADCS setup. |
| **Alternative** | Use certipy for ADCS attacks instead. The CertPotato technique is primarily useful when you have code execution as a service account but no interactive session. |
| **When added** | When IIS is deployed on mbr01 (currently deferred in lab configuration). |

---

### WT#046 — Linux Keytab Abuse

| Field | Detail |
|-------|--------|
| **What** | Extract Kerberos keytab from `/var/opt/mssql/secrets/mssql.keytab` on linux01 and use the keys to forge tickets |
| **Why missing** | The MSSQL keytab is not auto-generated during linux01 provisioning. The `ktpass` command on the DC targets an account that may not exist or has mismatched SPN registration. |
| **Alternative** | Generate the keytab manually: `ktpass -princ MSSQLSvc/linux01.cadre.local@CADRE.LOCAL -mapuser linux01$ -crypto AES256-SHA1 -pass +randpass -out mssql.keytab`, then SCP to linux01. |
| **When added** | When linux01 provisioning includes automated keytab generation via Ansible. |

---

## Difficulty-to-Add Gaps

### Pass-the-Cert & UnPAC-the-Hash

| Field | Detail |
|-------|--------|
| **What** | Authenticate using a certificate via Schannel/LDAPS (Pass-the-Cert) or derive NTLM hash from PKINIT (UnPAC-the-Hash) |
| **Why missing** | These techniques require specific tooling (pass-the-cert, PKINITtools) and are ADCS-adjacent. They are portable to CADRE but not yet built. |
| **Alternative** | Practice on CESP-ADCS official lab or the GOAD ADCS lab. |
| **When added** | Post-Plan 0, as CESP-ADCS portable gap additions. |

### Code Signing / WDAC Bypass

| Field | Detail |
|-------|--------|
| **What** | Sign malware with a stolen code-signing certificate to bypass Windows Defender Application Control |
| **Why missing** | Requires a code-signing template on the CA plus a WDAC/Device Guard policy in enforcement mode — both add complexity. |
| **Alternative** | Practice on CESP-ADCS official lab. |
| **When added** | Post-Plan 0, as CESP-ADCS portable gap additions. |

### EFS Abuse

| Field | Detail |
|-------|--------|
| **What** | Encrypted File System recovery — recover EFS-protected files using stolen certificates |
| **Why missing** | Requires EFS-certificate templates and encrypted files on the lab — niche technique with limited applicability. |
| **Alternative** | Practice on CESP-ADCS official lab. |
| **When added** | Post-Plan 0, low priority. |

### PAM Trust Abuse

| Field | Detail |
|-------|--------|
| **What** | Privileged Access Management trust — bastion forest attacks (CRTE-specific) |
| **Why missing** | Requires a dedicated bastion.local forest with PAM trust configured. CADRE does not have the 4+ VMs needed for bastion forest + MIM components. |
| **Alternative** | Available in CRTE official lab (bastion.local with 4 VMs). |
| **When added** | Not planned for CADRE. |

### AppLocker / WDAC Bypass (Evasion)

| Field | Detail |
|-------|--------|
| **What** | Application whitelist bypass techniques — PowerShell CLM, trusted folder, XSL transform, custom assemblies |
| **Why missing** | OSEP content. Moved to a separate project (2026-05-16). CADRE intentionally disables these controls so AD attack tools work without evasion. |
| **Alternative** | Practice on OSEP official lab or the planned separate evasion-lab repo. |
| **When added** | Not planned for CADRE — separate project. |

### OSEP — All Evasion Topics

| Field | Detail |
|-------|--------|
| **What** | AMSI bypass, process injection, shellcode runners, DNS tunneling, Domain Fronting, HTML smuggling |
| **Why missing** | OSEP was explicitly moved out of CADRE scope (2026-05-16). These techniques are Windows-internals / malware development and do not require Active Directory. |
| **Alternative** | PEN-300 (OSEP) official courseware or the planned separate evasion-lab repo. |
| **When added** | Not planned for CADRE — separate project. |

---

## Summary Table

| Gap | Category | Alternative Path | Planned? |
|-----|----------|-----------------|----------|
| ESC15 (v1 schema) | Core | ESC6 covers attack surface | No |
| Cloud attacks (Plan 11) | Core | CARTP/CARTE official labs | Yes — Plan 11 |
| Federation / ADFS | Core | Altered Security labs | No |
| Exchange attacks | Core | HTB Pro Labs / THM | No |
| C2 frameworks | Core | User-managed on kali VM | No |
| ADCS ESC (CA stopped) | Operational | Restart CertSvc, verify templates | Yes — fix in progress |
| CertPotato (WT#029) | Operational | IIS required on mbr01 | Conditional |
| Keytab abuse (WT#046) | Operational | Manual keytab generation | Yes — Ansible fix |
| Pass-the-Cert / UnPAC | Portable gap | CESP-ADCS official lab | Post-Plan 0 |
| Code Signing / WDAC | Portable gap | CESP-ADCS official lab | Post-Plan 0 |
| EFS Abuse | Portable gap | CESP-ADCS official lab | Post-Plan 0 |
| PAM Trust | External lab | CRTE official lab | No |
| AppLocker / WDAC Bypass | External lab | OSEP / evasion-lab repo | No — separate project |
| OSEP (all evasion) | External lab | OSEP official courseware | No — separate project |
