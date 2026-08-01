# Campaign Suggestions — SpecterOps Blog Cross-Reference

**Purpose:** Map research articles to specific campaign phases. Test each technique before integrating into CAMPAIGNS_v3.md.

**Status:** Planning — test before deploy.

**DFIR parallel track:** [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md) — links each campaign exercise to DFIR-Nexus ingest, cases, and `tracker.md` (Phase 3.5 active).

**Legend:** ✅ = adopted into CAMPAIGNS_v3.md | ⏳ = pending test | 🔬 = research only | ⏭️ = skip

---

## Summary — All Items at a Glance

✅ = adopted into CAMPAIGNS_v3.md | ⏳ = pending | 🔬 = research only | ⏭️ = skip

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
| **Phase 3 + plan1.7** | Defender Exclusion via PowerShell (T1562.001) — KQL patterns + AI-vs-human finding — Detect FYI 2026-06-24 | ⏳ |
| **Phase 3 + plan1.7** | AMSI Bypass Techniques — Gray Hat Hacking 6th Ed | ⏳ |
| **Phase 7 + plan1.7** | DCShadow Attack (DRS replication) — Applied Incident Response + Practical-Red-Teaming | ⏳ |
| **Phase 1/2/7** | Rubeus/Kerberoast/AS-REP playbook cross-validation — Practical-Red-Teaming + Gray Hat Hacking 6th Ed | ⏳ |
| **Study Ref** | Practical AI Security (2025) — CADRE-Strike LLM Security | ⏳ |
| **Study Ref** | Cyber Threat Hunting — methodology for plan1.7 | ⏳ |
| **Study Ref** | Practical Threat Detection Engineering — plan1.7 Sigma rules | ⏳ |
| **Study Ref** | Windows Internals Part 1, 7th Ed — LSASS/AD internals | ⏳ |
| **Research** | MSSQL + SCCM CVEs | 🔬 |
| **Reference** | How We Think about Red Teading | — |
| | Attack Paths Don't Stop at IdP | — |
| | dirkjanm.io — AD/Azure Research Blog | — |
| **Skip** | Don't Jump the Turnstile | ⏭️ |

**Counts:** ✅ Adopted: 24 | ⏳ Pending: 59 | 🔬 Research: 4 | ⏭️ Skip: 1 | Reference: 2 | 🆕 New: 12 | **Total: 102**

---

---

## Full item write-ups (separate file)

Per-item sources, test plans, and integration notes are in **[archive/Campaign_suggestions-detail.md](archive/Campaign_suggestions-detail.md)** (~3.9k lines). Keep this index open for the summary table; open the detail file when researching a specific item.

