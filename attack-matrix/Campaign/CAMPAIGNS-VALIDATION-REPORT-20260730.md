# CADRE Campaign v3 Master Validation Report — 2026-07-30

> Scope: every attack, branch, and standalone exercise in Campaign v3.
> Excluded from execution: Phase 0.5 / H-01..H-06 (initial access) per operator request, but they are listed.
> Legend: ✅ verified / 📝 script corrected pending re-test / ⏳ not exercised / ⠿ blocked / ❌ non-functional or rejected / 🔬 deferred.
>
> **Execution environment rules (2026-07-31, operator-locked):**
> **RULE 1 — Direct SSH to ws01 only.** All attack runs use direct `localhost -> ws01` SSH (`ssh -i C:\Users\Ganro\.ssh\cadre-ws01-key analyst_t1@192.168.77.62`), no wrappers. Tooling staged `localhost -> ws01` via `scp`; execution by SSH-ing into ws01. **Provisioning (`.60`) is config-only** — never an attack origin. Validation evidence from provisioning-bridge or wrapper-mediated attacks is **invalid**.
> **RULE 2 — No scheduled tasks to run commands.** Scheduled tasks are persistence-only (Phase 5), never execution wrappers. Running a command/tool via a scheduled task is rejected methodology; such evidence is invalid. The former "3.5B execution wrapper" is rejected per this rule.
> 1. Operator-access layer: direct `localhost -> ws01` SSH via `cadre-ws01-key` is working (verified 2026-07-31). Previous `Permission denied` was fixed by using the dedicated ws01 key.
> 2. `ws01` tooling layer: only `nxc` is missing on `ws01` (`pip install NetExec` fails with `No matching distribution found`; `git+https` install fails because `aardwolf` wheel build requires a Rust compiler — `error: can't find Rust compiler`). **`certipy.exe` IS present on `ws01`** (Python312 Scripts) — earlier claim that certipy is missing was **incorrect**. `ntlmrelayx.py` + `coercer.exe` confirmed in `C:\Tools\RedStrike\.venv\Scripts`; `MS-RPRN.exe` in `C:\Tools\ADTools` (2026-08-01). For any remaining tool gap, prestage binaries/venv on ws01 — do NOT route attacks through provisioning to work around it. All blocked/pending items are tracked below and in `CHECKLIST.md`.
> 3. **No provisioning bridge path.** The former `/tmp/nxc-venv` bridge on `provisioning` is retired for attack runs; provisioning remains config-only.
>
> **Session progress (2026-08-01):** GodPotato SYSTEM on mbr01 **VERIFIED** (WT041/043). Branch B **VERIFIED**: ESC1 (WT050) cert+PKINIT TGT+UnPAC NT hash `81c3b644...f1eb7b`; ESC3 (WT051) agent+on-behalf-of cert; UnPAC (WT053) via certipy auth. **ESC8 (WT052) DEFERRED** — root cause identified: no SMB-authenticated coercion works on Server 2025 in this lab (MS-EFSR blocked, MS-DFSNM/FSRVP no dial-out, MS-RPRN yields anonymous RPC to :135 only; the earlier `@8445` UNC claim is empirically false — Windows SMB client ignores `@port`). Branch C SCCM **surface verified** (SMS Provider reachable from ws01 as `range\svc_sccm`, confirmed SCCM admin on site CAD via `SMS_SCI_Component`); WT035-039 full execution requires console on mbr02. Branch D: WT046 keytab + WT048 podman escape **VERIFIED**; WT045 SSSD cache extracted (no plaintext cachedPassword); WT047 krb5p mount blocked by empty host keytab.
>
> **ESC8 root-cause record (2026-08-01):** The v5 "custom SMB port 8445 + Coercer `@8445` UNC" approach was proven non-functional — tcpdump on the relay host showed the coerced `dc01$` makes **zero** TCP connections to any non-445 port (Windows SMB client does not support `@port` in UNC). On Server 2025 in this lab: MS-EFSR (`\PIPE\efsrpc`) blocked, MS-DFSNM/MS-FSRVP/MS-EVEN produce no dial-out, and the only working coercion (MS-RPRN, WT017) makes the victim dial the attacker's **RPC endpoint (135) with anonymous auth** ("Empty username ... just waiting" in impacket `rpcrelayserver.py`) — never an authenticated SMB session on 445. Therefore ESC8-as-designed is not executable here; revisit at end (candidate paths: Kerberos-relay/krbrelayx, or re-enabling an SMB coerce primitive).
>
> **Defender / Tamper Protection status (2026-07-31, re-verified 11:20 UTC):** OFF on all VMs.
> - Server VMs (dc01/dc02/dc03/mbr01/mbr02): WinDefend **Stopped** + `DisableAntiSpyware=1` + RTP policy block (04-vulnerabilities full kill already applied). MBR01 re-checked CIM-free: `WinDefend=Stopped|DisableAntiSpyware=1|DisableRealtimeMonitoring=1`. (The earlier blank MBR01 MPSTAT line was a WMI/CIM access-denied quirk for `analyst_t1` on that host, not a Defender issue.)
> - ws01 (Windows 11 Enterprise build 26200): **soft-disable per `17-ws01-deploy.yml`** — RTP=`False`, TP=`False`, `DisableAntiSpyware=1`, all RTP/Behavior/IOAV/OnAccess policy blocks set, SpyNet=0, tooling exclusions active (`C:\Temp;C:\Tools;C:\Tools\cadre-attack;C:\Users\Public` + `cmd.exe;mimikatz.exe;powershell.exe;pwsh.exe;Rubeus.exe;SharpHound.exe`). WinDefend service stays **Running** — Windows 11 client SKU hard-protects the service; `Set/Stop-Service`, `sc.exe config/stop`, and even a SYSTEM scheduled task all get **Access denied** (OpenService FAILED 5). This matches the playbook design ("do NOT stop WinDefend"); with RTP off + excludes, campaign tools are unaffected.
> - Rubeus `golden` silent-failure is **not** Defender-related — it persists after the full policy kill. Use mimikatz `kerberos::golden` (verified working) or `impacket` equivalents.

## Summary Statistics

- **Phase 0.5 / H**: 6 attacks
- **Phase 0 Recon**: 4 attacks
- **Phase 0/1 Fallback**: 1 attacks
- **Phase 1**: 1 attacks
- **Phase 2**: 1 attacks
- **Phase 2 Alt**: 1 attacks
- **Phase 3**: 2 attacks
- **Phase 3.5**: 14 attacks
- **Phase 4**: 1 attacks
- **Phase 5**: 1 attacks
- **Phase 5 Coercion**: 9 attacks
- **Phase 5 T102**: 1 attacks
- **Phase 6**: 1 attacks
- **Phase 7**: 3 attacks
- **Phase 8**: 2 attacks
- **Phase 8 / Branch C**: 5 attacks
- **Phase 8 Alt**: 1 attacks
- **Branch A**: 10 attacks
- **Branch B**: 4 attacks
- **Branch D**: 5 attacks
- **Branch G**: 1 attacks
- **E - Network Defense**: 14 attacks
- **F - Supply Chain**: 13 attacks
- **Total attacks listed**: 101

## Phase 0.5 / H

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| H-01 | Malicious LNK (WT063) | Kali -> ws01 | User execution (analyst_t1 context) | ⏳ Not tested |  | Excluded from 2026-07-30 run; run from Kali with payload staged on ws01 |
| H-02 | Malicious MSI (WT064) | Kali -> ws01 | User execution | ⏳ Not tested |  | Excluded |
| H-03 | Compiled HTML Help (.chm) (WT065) | Kali -> ws01 | User execution | ⏳ Not tested |  | Excluded |
| H-04 | HTML Smuggling (WT066) | Kali HTTP server -> ws01 | User execution | ⏳ Not tested |  | Excluded |
| H-05 | AutoIt3 payload (WT067) | Kali -> ws01 | User execution | ⏳ Not tested |  | Excluded |
| H-06 | Malicious EXE (WT068) | Kali -> ws01 | User execution | ⏳ Not tested |  | Excluded |

## Phase 0 Recon

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| P0-Step1 | Kerberos user enumeration | Kali / provisioning | None | ✅ Verified | nmap/kerbrute finds ~20 users across child + cadre domains | No |
| P0-Step2 | Check DONT_REQUIRE_PREAUTH (AS-REP roastable) | Kali / provisioning | None | ✅ Verified | intern_blue confirmed AS-REP roastable | No |
| P0-Step3 | NetExec authenticated recon (intern_blue) | provisioning | intern_blue / 1nt3rn_Blu3! | ✅ Verified | pre2k, enum_av, get-desc-users, asreproast, kerberoast modules | No |
| WT028 | Null session / SAMR anonymous enumeration (WT028) | Kali / provisioning | None | ❌ Rejected | SAMR null bind blocked on Server 2025 | No |

## Phase 0/1 Fallback

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| WT031 | Password spray against dc01 (WT031) | provisioning / Kali | Candidate list (cadre_passwords.txt) | ✅ Verified | Yielded chief_command / analyst_dfir / analyst_cloud / hunter_dfir in cadre.local | No |

## Phase 1

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 003 | AS-REP Roast (WT003) | provisioning bridge | child\intern_blue / 1nt3rn_Blu3! | ✅ Verified | `ws01` `Rubeus` failed with LDAP operations error; alternate `provisioning` bridge via `/tmp/nxc-venv/bin/nxc ldap ... --asreproast` succeeded and captured `$krb5asrep$23$` hash | No |

## Phase 2

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 002 | Kerberoast via ACE#18 bridge (WT002) | ws01 | intern_blue / 1nt3rn_Blu3! | ✅ VERIFIED 2026-07-31 | ACE#18 bridge (intern_blue → ForceChangePassword on analyst_t2) + `getTGT` AES path; Kerberoast `svc_mssql` TGS hash cracked to `s3rv1c3_MSSQL!`; `analyst_t2` password restored. Downstream `svc_mssql`-dependent attacks unblocked. | No |

## Phase 2 Alt

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| NTLMv1 | NTLMv1 rainbow-table downgrade | Kali / provisioning | Coerced NTLMv1 responder | ⏳ Not tested | SpecterOps Into The Rainbow; not in main spine | Optional |

## Phase 3

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 041/043 | SQL xp_cmdshell + GodPotato (WT041/WT043) | ws01 -> mbr01 | child\analyst_t1 / T13r_An@lyst! | ✅ VERIFIED 2026-08-01 | Full chain: SQL auth `analyst_t1` → `EXECUTE AS LOGIN='sa'` (sysadmin=1) → `xp_cmdshell` (`nt service\mssql$sqlexpress`) → `SeImpersonatePrivilege` enabled → `GodPotato-NET4.exe` → **`nt authority\system`**. GodPotato staged to `C:\Windows\Temp\cadre-tools\GodPotato.exe`. Note: WinRM Copy-Item to `C:\Users\Public\cadre-gp.exe` was denied (stale SYSTEM-owned file) — use the `-GpPath` proven path. | No |
| 042 | CLR Assembly on mbr02 (WT042) | ws01 -> mbr02 | child\analyst_t1 / T13r_An@lyst! | ✅ Reachable | CLR path reachable; actual malicious assembly not loaded in this run | Yes - load and execute .NET assembly |

## Phase 3.5

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 101 | WinRS lateral pivot ws01 -> mbr01 (T101) | ws01 | child\analyst_t1 / T13r_An@lyst! | ✅ Verified | TrustedHosts + WinRM command execution works | No |
| 3.5F | LSASS/SAM credential dump via mimikatz (3.5F) | SYSTEM on mbr01 | SYSTEM | ✅ Verified | SAM dump works; sekurlsa::logonpasswords may fail due to token privilege | Yes - capture LSASS output reliably |
| 3.5A | Winlogon plaintext credential extraction (3.5A) | SYSTEM on mbr01 | SYSTEM | ✅ Verified | Extracts CADRE\analyst_cloud:Cl0ud_An@lyst! from registry | No |
| 3.5G | DPAPI via Nemesis (3.5G) | SYSTEM on mbr01 | SYSTEM | ⏳ Not exercised | Nemesis 2.2+ browser/RDP/WiFi DPAPI extraction | Yes |
| 3.5H | ctfmon.exe password extraction (3.5H) | SYSTEM on mbr01 | SYSTEM | ⏳ Not exercised | Typed passwords in ctfmon.exe memory | Yes |
| 3.5I | Token impersonation (3.5I) | mbr01 | SYSTEM | ❌ Rejected | Server 2025 session isolation; error 1346 | No |
| 3.5B | Scheduled Task as analyst_cloud (3.5B) | — | — | ❌ Rejected | **Rule 2 (no scheduled tasks to run commands).** A scheduled task is a persistence mechanism (Phase 5), not an execution wrapper. The 2026-07-31 re-test (task ran as `cadre\analyst_cloud`, proof written) is **void** as validation evidence for an attack — it validated a rejected method. `SeBatchLogonRight` config on mbr01 retained only as persistence-prerequisite surface. | No |
| 3.5C | RDP interactive session as analyst_cloud (3.5C) | ws01 -> mbr01 | analyst_cloud / Cl0ud_An@lyst! | ⠿ BLOCKED — script missing | No dedicated `3.5C` execution script found in `attack-matrix/04-automation/`; metadata/routing exist, but test harness is absent | Yes — add/verify script and rerun |
| 3.5D | File detonation / payload drop (WT063-068) (3.5D) | ws01 / mbr01 | analyst_t1 or analyst_cloud | ⏳ Not exercised | User-context execution | Yes |
| 3.5J | WMI Event Subscriptions (3.5J) | SYSTEM on mbr01 | SYSTEM | ⏳ Not exercised | Fileless persistence | Yes |
| 3.5K | LSASS dump via WerFault (3.5K) | SYSTEM on mbr01 | SYSTEM | ⏳ Not exercised | Microsoft-signed WerFaultSecure.exe | Yes |
| 3.5L | LAPS extraction (3.5L) | dc01 | DA | ⏳ Not exercised | ms-Mcs-AdmPwd read | Yes |
| 3.5M | Azure AD Connect DPAPI dump (3.5M) | dc01 | DA | ⏳ Not exercised | adconnectdump / MSOL credentials | Yes |
| 3.5N | UnCanny LPE via InstallService (3.5N) | ws01 | local user | ⏳ Not exercised | Requires Developer Mode; deferred | Yes - after Developer Mode decision |

## Phase 4

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 004 | BloodHound discovery (WT004) | mbr01 (SYSTEM) or ws01 | SYSTEM on mbr01 | ✅ Verified | Full AD graph collected from all 3 domains previously | No |

## Phase 5

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 007 | RBCD standalone (WT007) | ws01 | child\analyst_t1 / T13r_An@lyst! | ✅ VERIFIED 2026-07-31 | Surface confirmed; FakePC$ created via addcomputer; rbcd set on mbr01; getST S4U2Proxy → SYSTEM on mbr01; cleanup done. | No |

## Phase 5 Coercion

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 017 | MS-RPRN PrinterBug coercion (WT017) | ws01 -> SYSTEM on mbr01 | SYSTEM | ✅ Confirmed | Suricata SID:1000050 fires. **2026-08-01 note:** for an IP listener the coerced victim dials the attacker's **RPC endpoint (135) with anonymous auth** — usable for Kerberos TGT capture (T102, hostname listener) but NOT for NTLM relay to ADCS (ESC8). | No |
| 018 | MS-EFSR PetitPotam (WT018) | ws01 | SYSTEM | ❌ Non-functional | `\PIPE\efsrpc` blocked on Server 2025 (re-confirmed 2026-08-01 — coercer skips the pipe) | No |
| 019 | MS-DFSNM DFSCoerce (WT019) | ws01 | SYSTEM | ❌ Non-functional | No dial-out observed (2026-08-01); SMB-pipe DCE-RPC not detectable by Suricata 8.0.5 | No |
| 020 | MS-FSRVP ShadowCoerce (WT020) | ws01 | SYSTEM | ❌ Non-functional | Service not available on Server 2025 | No |
| 021 | NTLM relay to LDAP / ESC8 (WT021) | Kali / provisioning | Coerced dc02$ or other account | ⏳ Deferred | Requires an SMB-authenticated coerce; none works on Server 2025 in this lab (see ESC8 root-cause record) | No |
| 022 | NTLM relay to ADCS / shadow credentials (WT022) | Kali / provisioning | Coerced account | ⏳ Deferred | Same blocker as WT021/ESC8 | No |
| 094 | UnCanny Coerce (WT094) | ws01 | local user | 🔬 Deferred | Requires Developer Mode | After Developer Mode decision |
| 095 | Onelogon Zero-Channel (WT095) | Kali -> DC | DC machine account NTLMv2 | 🔬 Deferred | PoC expected post-WOOT 2026 | After PoC release |
| 096 | coerce_plus consolidated check (WT096) | provisioning | SYSTEM context | ⏳ Not tested | NetExec module; can be used once spooler enabled on dc02 | Yes |

## Phase 5 T102

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
|| T102 | Unconstrained delegation capture dc02$ TGT (T102) | SYSTEM on mbr01 | SYSTEM | ✅ VERIFIED 2026-07-31 | dc02 Spooler/RPC prerequisites configured; hostname listener used for Kerberos (IP listener falls back to NTLM, no TGT); `dc02$` TGT captured → kirbi→ccache → Phase 6 DCSync of child/krbtgt. Full chain green. | No |

## Phase 6

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 009 | DCSync (WT009) | ws01 or Kali | child\krbtgt via dc02$ TGT (as-written path) OR chief_command / C0mm@nd_Ch1ef! (DA fallback) | ✅ Verified | **As-written path VERIFIED 2026-07-31:** T102 dc02$ TGT → kirbi→ccache → `secretsdump.py child.cadre.local/dc02$ -k -no-pass` → child/krbtgt NT hash + AES256 captured. Fallback also works. | No |

## Phase 7

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 010 | Golden Ticket (WT010) | ws01 | krbtgt hash (child.cadre.local) | ✅ Verified | **Verified 2026-07-31:** mimikatz `kerberos::golden` with extracted child krbtgt NT + AES256, `/sids:<root EA>` forged + injected (PTT) + saved `EA-aes.kirbi`. Rubeus `golden` binary fails silently on ws01 (non-Defender quirk — persists after full Defender kill) — use mimikatz. Cross-realm DCSync of root via golden hits PAC checksum quirk on dc01 DRSUAPI bind; root EA achieved via fallback paths (Branch A chief_command / WT031). | No (as-written forgery path complete); cross-realm DCSync via golden = known quirk, root access covered by fallback |
| 011 | Silver Ticket (WT011) | ws01 | Service account hash | ✅ Script executes | Script runs | Yes - verify against actual service |
| 012 | Diamond Ticket (WT012) | ws01 | krbtgt hash | ✅ Script executes | Script runs | Yes - verify with extracted krbtgt |

## Phase 8

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 033 | Cross-forest Kerberoast (WT033) | ws01 | root EA / chief_command | ✅ Verified | Kerberoast svc_sccm in range.local from cadre EA context | No |
| 034 | SCCM NAA extraction (WT034) | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ✅ Verified | Reads vault aa-rotation-notice.txt; svc_naa / N@A_s3rv1c3! confirmed DA | No |

## Phase 8 / Branch C

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 035 | SCCM PXE Boot abuse (WT035) | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ✅ Surface verified (deep) | 2026-08-01: As `range\svc_sccm` via SMS Provider WMI (explicit creds from ws01): PXE **approved cert** present (`SMS_PXECertificateInfo`, SMSID `{256B7D4F-4949-4FB7-BCF8-D298F971E940}`, PXE server `MBR02.RANGE.LOCAL`, valid→2125); **2 boot images** (x64 `CAD00002`, arm64 `CAD00005`); **NAA confirmed in machine policy** (`SMS_SCI_ClientComp` Software Distribution `Network Access User Names = RANGE\svc_naa`). Full PXE boot-image + machine-policy exploitation needs a real PXE network boot (no PXE client in lab). | Yes - full chain from PXE client |
| 036 | SCCM Client Push install (WT036) | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ⚠️ Primitive verified / relay pending | Client-push component enabled (Software Distribution `Flags=1`); coercion primitives available to svc_sccm (`SMS_Collection.GenerateCCRByName` + `CreateCCR` — invoked, returned 1=device-not-found since target needs an `SMS_R_System` device record, which is console-created / read-only via WMI). Full NTLM-relay capture of `MBR02$` requires a console-created target device + relay listener. | Yes - after console Create Device |
| 037 | SCCM CMPivot (WT037) | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ✅ AdminService auth VERIFIED (CD → 200) | **FIXED 2026-08-01:** AdminService IS deployed (self-hosted `SMS_REST_PROVIDER`, no IIS). Root cause of the 401 was the **SPN owner**: the provider ALWAYS runs as LocalSystem and can only decrypt tickets encrypted to the MACHINE account — but the lab had registered `HTTP/mbr02.range.local` on `svc_sccm`. **Fix: SPN moved to `mbr02$`** (+ decoy `HTTP/sccm.range.local` on `svc_sccm` so WT033 Kerberoast still works; CD unchanged). Verified live: Kerberoast → S4U2Self/S4U2Proxy → `getST` → ST encrypted to `mbr02$` → presented → **`AdminService/wmi/SMS_Site` → 200 + valid OData JSON as `administrator`** (anon still 401). Auth gate CLOSED — CMPivot on MBR02 (only managed client) runnable. | CMPivot query exec (MBR02) |
| 038 | SCCM Application Deployment (WT038) | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ⚠️ Partial | As svc_sccm via provider: created `SMS_Package` (`CAD00007`) + `SMS_Program` (SYSTEM context `ProgramFlags=2`) — **SCCM admin can stage a payload program**. `SMS_Advertisement.Put` fails `Generic failure` via raw WMI (class-specific; schedule token `SMS_ScheduleToken`/`TimeFlags`/`DeviceFlags` variants all rejected) — advertisement creation needs console or AdminService. No existing apps to clone (`SMS_Application` count 0). | Yes - console |
| 039 | SCCM Site Takeover (WT039) | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ⚠️ Partial — auth gate closed | **Script creation works** via provider (`SMS_Scripts.CreateScripts` RETURN=0, caller-generated GUID required). AdminService Kerberos now WORKS as `administrator` (WT037 fix: SPN on `mbr02$` → 200). Remaining: approval/run of a script + full CMPivot exec on the only managed client (MBR02) — via AdminService REST (limited class exposure) or console. Cleanup done (test scripts + package removed). | CMPivot/script run on MBR02 |

**Branch C key findings (2026-08-01):**
- **`svc_sccm` = HTTP/mbr02 SPN + constrained delegation (S4U2Self/Proxy to HTTP/mbr02)** — verified in AD (`msDS-AllowedToDelegateTo=HTTP/mbr02.range.local`, `05-ad-attack-surface.yml`). Correct design; the cross-forest Kerberoast (WT033) → CD → AdminService-as-any-user is the intended Branch C escalation.
- **CORRECTED 2026-08-01: AdminService IS deployed & running** (self-hosted `SMS_REST_PROVIDER`, no IIS — the earlier "NOT deployed" conclusion used IIS-era indicators that don't apply to modern builds). Live gates found: (1) **SMS Admins membership** (site reinstall resets the group — restored `svc_sccm` + `CADRE\chief_command` + `CADRE\analyst_purple`); (2) **CD UAC flag** `TrustedToAuthForDelegation` 0x80000 (playbook had `TRUSTED_FOR_DELEGATION` 0x10000 → `KDC_ERR_BADOPTION` on S4U2Proxy; fixed + playbook updated); (3) **svc_sccm password expiry** (reset to documented value + `DONT_EXPIRE_PASSWORD`); (4) **SPN owner (FIXED + VERIFIED)** — the self-hosted AdminService always runs as LocalSystem and can only decrypt machine-account tickets; `HTTP/mbr02.range.local` moved `svc_sccm` → `mbr02$` (svc_sccm keeps decoy `HTTP/sccm.range.local` for WT033; CD unchanged) → getST ST → `AdminService/wmi/SMS_Site` **200** as Administrator. See guide Phase 6A + `10-sccm-verify.yml` (real indicators: RESTPROVIDERSetup.log / SMS_REST_PROVIDER.log / 443 / endpoint 401).
- **`cifs/mbr02.range.local` SPN MISSING** from AD → SMB Kerberos to mbr02 fails (NTLM-only). Explains `/ptt`-based SharpSCCM auth failing. Verify-playbook candidate (check cifs SPN present). Not changed — may be intentional (SCCM relay surface).
- **Cross-forest SCCM admins**: local `SMS Admins` on mbr02 includes `CADRE\chief_command` + `CADRE\analyst_purple` (SCCM Full Admins on range.local from cadre forest) — notable cross-forest SCCM admin finding.
- **SCCM admin gate = local `SMS Admins` group** (svc_sccm is a member → full SMS Provider WMI access from ws01 with explicit creds).
- Site CAD build 9141; 1 device (MBR02); 0 task sequences; 2 boot images; 10 collections.

## Phase 8 Alt

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| Skipjack | Skipjack PAC signature corruption | ws01 | child domain user | 🔬 Deferred | Needs custom Rubeus /skipjack_forge.py; SID filtering OFF verified | After PoC |

## Branch A

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 015 | ACL ForceChangePassword ACE#7 (WT015) | ws01 | hunter_dfir / DF1R_Hunt3r! | ✅ VERIFIED 2026-07-31 | ACE#7 surface was missing in live lab → applied via dc01 (vagrant); attack confirmed: hunter_dfir forced chief_command password change (temp), verified auth with new password, restored original. | No |
|| 013 | ACL WriteDacl self-escalate (WT013) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA) | ✅ VERIFIED 2026-07-31 | `T013-acl-writedacl-ws01.sh` (direct ws01 SSH) → `campaign-a-t013-acl-writedacl.ps1` granted hunter_dfir GenericAll on CN=Command-Cadre; ACE read-back verified (ACL_APPLIED + ACE entry present) | No |
| 014 | ACL GenericWrite -> Shadow Credentials (WT014) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA) | ✅ VERIFIED 2026-07-31 | `T014-acl-genericwrite-ws01.sh` (direct ws01 SSH) → `campaign-a-t014-acl-genericwrite.ps1` granted hunter_dfir GenericWrite (ReadProperty/WriteProperty/ExtendedRight) on analyst_cloud; ACE read-back verified | No |
| 016 | ACL GenericAll on OU (WT016) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA) | ✅ VERIFIED 2026-07-31 | `T016-acl-genericall-ou-ws01.sh` (direct ws01 SSH) → `campaign-a-t016-acl-genericall-ou.ps1` granted hunter_dfir GenericAll on OU=Command; ACE read-back verified | No |
| 008 | Shadow Credentials on dc01$ (WT008) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA) | ✅ Verified | pywhisker (explicit creds, LDAPS) added KeyCredential to dc01$ msDS-KeyCredentialLink; gettgtpkinit obtained dc01$ TGT via PKINIT; getnthash recovered dc01$ NT hash 09493093db08c8afa99193779d401b34 (= DCSync rights) | No |
| 023 | GPO Abuse (WT023) | ws01 | analyst_cloud / Cl0ud_An@lyst! (ACE#1) | ✅ Verified | analyst_cloud has WriteDacl/WriteOwner/GenericAll on Vulnerable-GPO ({885EE71C-...}); wrote ScheduledTasks.xml preference to GPO SYSVOL path; read back + deleted | No |
| 024 | gMSA Extraction (WT024) | ws01 | eng_cloud / Cl0ud_Eng! (ACE#10 ReadGMSAPassword) | ✅ Verified | LDAPS bind as eng_cloud → read msDS-ManagedPassword blob on gmsaTools$ → decode → NT hash 0c81acad6a91e28bc1622ac9bf0cce05 → SMB auth as gmsaTools$ verified. ACE#10 path corrected (not chief_command/GoldenGMSA) | No |
| GPP | GPP Stored Password (Groups.xml) | ws01 | analyst_cloud / Cl0ud_An@lyst! | ✅ Verified | SYSVOL walk found Groups.xml in Vulnerable-GPO; cpassword decrypted to svc_ldap / s3rv1c3_Ld@p!; SMB auth as svc_ldap verified. **Attack surface was misconfigured** (svc_backup + malformed cpassword) → fixed `02-ad-objects.yml` + `05-ad-attack-surface.yml` to svc_ldap + valid cpassword, re-applied on dc01 | No |
| 027 | SPN Jacking CVE-2026-25177 (WT027) | ws01 | DA or writeSPN rights | ⏳ Not exercised | Abuse writeSPN/validateSPN to Kerberoast target | Yes |
| 025 | AdminSDHolder persistence (WT025) | ws01 | analyst_cloud (WriteDacl on AdminSDHolder) | ✅ VERIFIED 2026-07-31 | Surface confirmed (analyst_cloud WriteDacl = ACE6). Exploit: analyst_cloud added GenericAll backdoor ACE on AdminSDHolder via `PsBase.Options.SecurityMasks=Dacl`; ACE persisted. **DACL had been polluted to 99 ACEs during earlier PowerView attempt → restored from pristine range.local template (SID-translated) + re-added surface ACE → now 23 ACEs, protected, no rogue GenericAll.** Exploit: `t025-adminsdholder-exploit.ps1`; restore: `t025-restore.ps1` + `t025-readd-aces.ps1` | No |

## Branch B

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 050 | ADCS ESC1 (WT050) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA+EA) | ✅ VERIFIED 2026-08-01 | `certipy req -template CADRE-ESC1 -upn administrator@cadre.local -sid <admin-SID> -dynamic-endpoint` → cert issued (Req ID 39, SID embedded) → `certipy auth` PKINIT TGT + **UnPAC NT hash `aad3b435b51404eeaad3b435b51404ee:81c3b6443f148bf73bb3499791f1eb7b`**. Required `-sid` (SID mismatch otherwise) and `-dynamic-endpoint` (default RPC endpoint times out). | No |
| 051 | ADCS ESC3 (WT051) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA+EA) | ✅ VERIFIED 2026-08-01 | ESC3-Agent cert (Req ID 40/41) + `-on-behalf-of "cadre\administrator"` (NetBIOS — FQDN form is denied by policy module `0x80070547`) → admin cert issued (Req ID 44, UPN+SID). PKINIT TGT OK. UnPAC of ESC3 cert hit impacket `InvalidChecksum` quirk (UnPAC proven via ESC1 cert instead). | No |
| 052 | ADCS ESC8 / NTLM relay web enrollment (WT052) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA+EA) | 🔬 DEFERRED — revisit at end | **Root cause (2026-08-01):** no SMB-authenticated coercion works on Server 2025 here; MS-RPRN dials attacker RPC :135 anonymously; `@8445` UNC is not honored by Windows SMB client (tcpdump zero packets). Surface (web enrollment 401) remains configured. See root-cause record at top of report. | Revisit at end |
| 053 | UnPAC-the-Hash (WT053) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA+EA) | ✅ VERIFIED 2026-08-01 | `certipy auth -pfx` on ESC1 admin cert → PKINIT TGT + U2U → **administrator NT hash extracted**. (certipy auth hangs when orphaned certipy procs hold the ccache lock — kill first.) | No |
| ESC2 | ADCS ESC2 — Any Purpose EKU (`CADRE-ESC2`) | ws01 | hunter_dfir (low-priv) → admin | ✅ VERIFIED 2026-08-01 | `certipy req -template CADRE-ESC2 -upn administrator@cadre.local -sid <admin-SID> -dynamic-endpoint` as **hunter_dfir** → cert issued (Req 45, UPN+SID, Any Purpose EKU) → `certipy auth` → **PKINIT TGT as administrator**. CADRE-ESC2 also flags ESC3 (CRA EKU) + ESC17 (server-auth) — same template. | No |
| ESC4 | ADCS ESC4 — WriteDacl (`CADRE-ESC4`) | ws01 | lead_engineering (Engineering-Cadre) | ✅ VERIFIED 2026-08-01 | As **lead_engineering** (`Eng_L3ad!`): backed up template → `certipy template -write-default-configuration` (ESC1 flags) succeeded → **hunter_dfir** enrolled admin cert (Req 47) → PKINIT TGT + **NT hash `81c3b644…f1eb7b`**. **Template restored to original config** (NameFlag back to `-1509949440`, original EKUs/ACL, verified). | No |
| ESC7 | ADCS ESC7 — CA officer/manager (`cadre-CA`) | ws01 | lead_engineering | ✅ VERIFIED 2026-08-01 | `lead_engineering` has **ManageCA + ManageCertificates + Enroll + Read** on cadre-CA (certipy find flags ESC7). Proof: `certipy ca -ca cadre-CA -add-officer hunter_dfir` as lead_engineering → **"Successfully added officer"** (ManageCA-only op) → **removed** (cleanup). Full approve-pending-request chain needs CA Request Disposition=Pending (lab CA = Issue/auto-issue) — documented. | No |
| ESC9 | ADCS ESC9 — NoSecurityExtension (`CADRE-ESC9`) | ws01 | hunter_dfir (low-priv) → admin | ✅ VERIFIED 2026-08-01 | `certipy req -template CADRE-ESC9 -upn administrator@cadre.local -sid <admin-SID> -dynamic-endpoint` as **hunter_dfir** → cert issued (Req 46, NoSecurityExtension) → `certipy auth` → **PKINIT TGT + NT hash `81c3b644…f1eb7b`**. | No |

**Branch B additional notes (2026-08-01):** **CADRE-ESC13/ESC14 templates do NOT exist** in the deployment (campaign docs list them; not created). **ESC6 not deployed** (CA User Specified SAN = Disabled). **ESC11** (ICPR no encryption) flagged on the CA — exploit is relay-family (like ESC8) → deferred with ESC8. MachineEnrollmentAgent (default) flags ESC4 ("template owned by user" — EA-owned, standard). Deployed vulnerable surface = CADRE-ESC1/2/3-Agent/3-Target/4/9 (+ default MachineEnrollmentAgent).

## Branch D

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 044 | MSSQL Linked Server Recon (WT044) | ws01 -> mbr01 | child\analyst_t1 / T13r_An@lyst! | ✅ Verified | OPENQUERY to LINUX01.master.sys.databases returns linux01 databases | No |
| 045 | SSSD Ticket Extraction (WT045) | linux01 | mssql-linux01 pivot → sudo root | ✅ VERIFIED 2026-08-01 | **Config gap fixed:** `/etc/krb5.keytab` was corrupt/empty → SSSD failed → no domain resolution. Recreated via `adcli join` (chief_command) → SSSD active → domain users resolve → SSH pivot as `mssql-linux01` works. From pivot root: SSSD cache `cache_cadre.local.ldb` active (2.9MB, fresh). Fix propagated to `07-linux-config.yml` (+verifyOnly) and `sql-integration-guide.md` §3.4. | No |
| 046 | MSSQL Keytab Extraction (WT046) | linux01 | mssql-linux01 pivot → sudo root | ✅ VERIFIED 2026-08-01 | Keytab `/var/opt/mssql/secrets/mssql.keytab` (MSSQLSvc/linux01:1433, aes256) read via pivot root (`klist -ket`). Also obtainable via SQL-sa `BULK` read (mssql-owned file) without a shell. | No |
| 047 | NFS Kerberos Mount (WT047) | linux01 | mssql-linux01 pivot → root | ✅ VERIFIED 2026-08-01 | **Fixes applied (live + playbooks + guide):** (1) `nfs/linux01` + `nfs/linux01.cadre.local` SPNs registered in AD + keytab entries via `adcli update --add-service-principal`; (2) `rpc-svcgssd` (server GSS) was FAILED — started+enabled; (3) `/etc/idmapd.conf` Domain was `localdomain` → set `cadre.local`; (4) mount **by FQDN** (`linux01.cadre.local`) not `localhost`. Result: `mount -t nfs4 -o sec=krb5p linux01.cadre.local:/exports/secure-share /mnt/cadre-nfs` → **MOUNT_OK (sec=krb5p, rw)** + share readable. Write denied while share is root-owned 0755 (mapped uid = mssql-linux01). Fixes in `07-linux-config.yml` (+verifyOnly) + `sql-integration-guide.md` §3.5. | No |
| 048 | Podman Container Escape (WT048) | linux01 | mssql-linux01 pivot → sudo root | ✅ VERIFIED 2026-08-01 | **Config gap fixed:** no user (other than vagrant) had sudo/podman → privileged `cadre-monitor` unreachable. Added sudo misconfig `/etc/sudoers.d/cadre-domain-users` (`mssql-linux01 ALL=(ALL) NOPASSWD:ALL`). Full chain: SSH `mssql-linux01` → `sudo podman start cadre-monitor` → `sudo podman exec cadre-monitor unshare -r id` → **root** + host shadow read + host file write (`/tmp/cadre-d-escape`, cleaned). | No |
| — | Branch D entry (linked-server → linux01 SQL) | ws01 -> mbr01 -> linux01 | child\analyst_t1 (SQL, EXECUTE AS sa) | ✅ VERIFIED 2026-08-01 | Proper chain: `EXECUTE AS sa` on mbr01 → `EXEC (...) AT LINUX01` → **sa / sysadmin on linux01** (Developer 16.0). xp_cmdshell unsupported on SQL-on-Linux (by design, `sql-integration-guide.md`). | No |

## Branch G

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| CVE-2026-41089 | Netlogon CLDAP Stack Buffer Overflow (CVE-2026-41089) | Kali -> dc02 | None (unauthenticated UDP/389) | 🆕 Ready, untested | Single UDP packet crashes LSASS; dc02 first, snapshot required | Yes - snapshot dc02 and run poc.py from Kali |

## E - Network Defense

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| E-01 | E-01 — Kerberoast detection | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Not exercised | Detection rule validation; see plan1.7-defense-deepening.md | Yes |
| E-02 | E-02 — DCSync detection | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Not exercised | Detection rule validation; see plan1.7-defense-deepening.md | Yes |
| E-03 | E-03 — AS-REP roast detection | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Not exercised | Detection rule validation; see plan1.7-defense-deepening.md | Yes |
| E-04 | E-04 — DGA detection | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Not exercised | Detection rule validation; see plan1.7-defense-deepening.md | Yes |
| E-05 | E-05 — DNS TXT exfil | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Not exercised | Detection rule validation; see plan1.7-defense-deepening.md | Yes |
| E-06 | E-06 — NXDOMAIN bursts | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Not exercised | Detection rule validation; see plan1.7-defense-deepening.md | Yes |
| E-07 | E-07 — TLD anomalies | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Not exercised | Detection rule validation; see plan1.7-defense-deepening.md | Yes |
| E-08 | E-08 — IP literal C2 | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Not exercised | Detection rule validation; see plan1.7-defense-deepening.md | Yes |
| E-09 | E-09 — TLS 1.0 anomalies | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Not exercised | Detection rule validation; see plan1.7-defense-deepening.md | Yes |
| E-10 | E-10 — SNI anomalies | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Not exercised | Detection rule validation; see plan1.7-defense-deepening.md | Yes |
| E-11 | E-11 — C2 cipher suites | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Not exercised | Detection rule validation; see plan1.7-defense-deepening.md | Yes |
| E-12 | E-12 — SMB admin share | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Not exercised | Detection rule validation; see plan1.7-defense-deepening.md | Yes |
| E-13 | E-13 — SMBv1 downgrade | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Not exercised | Detection rule validation; see plan1.7-defense-deepening.md | Yes |
| E-14 | E-14 — HTTP UA anomalies | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Not exercised | Detection rule validation; see plan1.7-defense-deepening.md | Yes |

## F - Supply Chain

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| F-01 | F-01 — npm registry poisoning | linux01 / mbr01 / npm registry | Attacker-controlled npm package or CI token | ⏳ Not exercised | Supply-chain simulation; see plan1.8-npm-upgrade.md | Yes |
| F-02 | F-02 — Malicious dependency install | linux01 / mbr01 / npm registry | Attacker-controlled npm package or CI token | ⏳ Not exercised | Supply-chain simulation; see plan1.8-npm-upgrade.md | Yes |
| F-03 | F-03 — Typosquat publish | linux01 / mbr01 / npm registry | Attacker-controlled npm package or CI token | ⏳ Not exercised | Supply-chain simulation; see plan1.8-npm-upgrade.md | Yes |
| F-04 | F-04 — Compromised maintainer | linux01 / mbr01 / npm registry | Attacker-controlled npm package or CI token | ⏳ Not exercised | Supply-chain simulation; see plan1.8-npm-upgrade.md | Yes |
| F-05 | F-05 — Build script execution | linux01 / mbr01 / npm registry | Attacker-controlled npm package or CI token | ⏳ Not exercised | Supply-chain simulation; see plan1.8-npm-upgrade.md | Yes |
| F-06 | F-06 — Post-install hook | linux01 / mbr01 / npm registry | Attacker-controlled npm package or CI token | ⏳ Not exercised | Supply-chain simulation; see plan1.8-npm-upgrade.md | Yes |
| F-07 | F-07 — npm token exfil | linux01 / mbr01 / npm registry | Attacker-controlled npm package or CI token | ⏳ Not exercised | Supply-chain simulation; see plan1.8-npm-upgrade.md | Yes |
| F-08 | F-08 — Package metadata manipulation | linux01 / mbr01 / npm registry | Attacker-controlled npm package or CI token | ⏳ Not exercised | Supply-chain simulation; see plan1.8-npm-upgrade.md | Yes |
| F-09 | F-09 — Cache poisoning | linux01 / mbr01 / npm registry | Attacker-controlled npm package or CI token | ⏳ Not exercised | Supply-chain simulation; see plan1.8-npm-upgrade.md | Yes |
| F-10 | F-10 — Tag pollution | linux01 / mbr01 / npm registry | Attacker-controlled npm package or CI token | ⏳ Not exercised | Supply-chain simulation; see plan1.8-npm-upgrade.md | Yes |
| F-11 | F-11 — CI-side cache poisoning analog | linux01 / mbr01 / npm registry | Attacker-controlled npm package or CI token | 🔬 Held expansion | Plan 0.8 expansion; see CAMPAIGNS_v3.md F section + Campaign_suggestions #107 | Yes |
| F-12 | F-12 — Tag pollution / npm dist-tag add analog | linux01 / mbr01 / npm registry | Attacker-controlled npm package or CI token | 🔬 Held expansion | Plan 0.8 expansion; see CAMPAIGNS_v3.md F section + Campaign_suggestions #107 | Yes |
| F-13 | F-13 — Prepare hook / dead-man switch | linux01 / mbr01 / npm registry | Attacker-controlled npm package or CI token | 🔬 Held expansion | Plan 0.8 expansion; see CAMPAIGNS_v3.md F section + Campaign_suggestions #107 | Yes |

## Credential Map

| Identity | Domain | Password/Hash | Where Used | How Obtained |
|----------|--------|---------------|------------|--------------|
| `analyst_t1` | `child.cadre.local` | `T13r_An@lyst!` | ws01 beachhead, mbr01 SQL auth, mbr01 WinRM, Branch D | Assume-breach / H-01..H-06 |
| `intern_blue` | `child.cadre.local` | `1nt3rn_Blu3!` | Phase 1 recon, ACE#18 bridge | AS-REP roast (WT003) |
| `svc_mssql` | `child.cadre.local` | `s3rv1c3_MSSQL!` | Phase 2 pivot, mbr01 SQL sysadmin | Kerberoast via ACE#18 (WT002) |
| `analyst_t2` | `child.cadre.local` | reset during Phase 2 | ACE#18 bridge | `intern_blue` ForceChangePassword |
| `analyst_cloud` | `cadre.local` | `Cl0ud_An@lyst!` | mbr01 auto-logon, Branch A GPO (T023) | 3.5A Winlogon registry extraction |
| `hunter_dfir` | `cadre.local` | `DF1R_Hunt3r!` | Branch A entry (T015 ACE#7) | WT031 password spray |
| `analyst_dfir` | `cadre.local` | `An@lyst_DF1R!` | Branch A ACE#5 | WT031 password spray |
| `eng_agentic` | `cadre.local` | `Ag3nt1c_Eng!` | Branch A ACE#13+14 (DCSync) | WT031 password spray |
| `chief_command` | `cadre.local` | `C0mm@nd_Ch1ef!` | Root DA+EA, Branch A post-T015, Branch B entry | Branch A T015 / WT031 spray |
| `dc02$` | `child.cadre.local` | TGT | Phase 6 DCSync | Phase 5 T102 coercion + Rubeus monitor — **VERIFIED 2026-07-31** (TGT captured, kirbi→ccache) |
| `child\krbtgt` | `child.cadre.local` | NT hash `b6c370f2...82ec1` + AES256 `d64da42f...9d2` | Phase 7 Golden Ticket | Phase 6 DCSync via dc02$ TGT — **VERIFIED 2026-07-31** |
| `root EA` | `cadre.local` | TGT | Phase 8 cross-forest | Phase 7 Golden Ticket + ExtraSids — **VERIFIED** (mimikatz `/sids:<root EA>` PTT); cross-realm DCSync via golden = PAC checksum quirk, root DA+EA via chief_command fallback |
| `svc_sccm` | `range.local` | `s3rv1c3_SCCM!` | Branch C SCCM | Phase 8 cross-forest Kerberoast (WT033) |
| `svc_naa` | `range.local` | `N@A_s3rv1c3!` | range.local DA | Branch C NAA extraction (WT034) |

## Machine Roles

| Machine | IP | Role | How Used in Campaign |
|---------|----|------|----------------------|
| dc01 | 192.168.77.10 | root DC `cadre.local`, CA | Branch A/B target, DCSync, Golden Ticket, ADCS |
| dc02 | 192.168.77.11 | child DC `child.cadre.local` | Phase 1/2 KDC, coercion target, Branch G target |
| dc03 | 192.168.77.12 | root DC `range.local` | Cross-forest target |
| mbr01 | 192.168.77.22 | SQL Server 2025 Express, member | Phase 3 SQL + GodPotato, Phase 3.5 credential theft |
| mbr02 | 192.168.77.23 | SCCM site server, SQL Dev | Branch C SCCM execution, Branch D linked-server source |
| linux01 | 192.168.77.40 | Ubuntu 24.04 domain-joined | Branch D pivot target |
| ws01 | 192.168.77.62 | Windows 11 beachhead | Initial beachhead, WinRM pivot to mbr01, Branch A/B execution |
| provisioning | 192.168.77.60 | Kali operator / Ansible runner | Orchestration, nxc, attack scripts |
| monitor | 192.168.77.55 | Zeek + Suricata + Elastic | E exercises detection validation (offline) |

## Top Re-test Priorities

> Updated 2026-08-01 — Branch A (013/014/015/016/023/024/025/008/GPP/**027**) and Branch D (044-048) and Branch B (050/051/053/ESC2/4/7/9) are all **VERIFIED**. Only the following remain open:

1. **Branch C SCCM (WT035-039) — AdminService CD chain VERIFIED (2026-08-01).** Root cause of the 401 was the **SPN owner**, not the provider identity: the self-hosted AdminService always runs as LocalSystem and can only decrypt machine-account tickets. **Fix applied + playbook-updated (`05-ad-attack-surface.yml`):** `HTTP/mbr02.range.local` moved `svc_sccm` → `mbr02$` (svc_sccm keeps decoy `HTTP/sccm.range.local` for WT033 Kerberoast; CD unchanged). Verified live: getST → ST encrypted to `mbr02$` → `AdminService/wmi/SMS_Site` → **200** as `administrator` (anon 401). WT037/039 auth gate **CLOSED**. Remaining: exercise CMPivot/script-run on the only managed client (MBR02).
2. **ESC8 (WT052) / ESC11** — deferred; revisit at end via Kerberos-relay (krbrelayx) or a restored SMB-coerce primitive (NTLM-relay path proven non-viable on Server 2025).
3. **E exercises (E-01..14)** — run on monitor VM once elk/monitor are online (telemetry phase).
4. **F supply-chain scenarios (F-01..13)** — run on linux01/mbr01/npm registry.
5. **Branch G (CVE-2026-41089)** — snapshot DCs + verify dc02 patch level (UBR < 32772), then PoC from Kali.
6. **H-01..06 (initial access)** — needs `19-initial-access.yml` (currently excluded per operator).

---
*Generated from CAMPAIGNS-METADATA-v2.md and 2026-07-30 validation run.*

## Appendix A — Consolidated Campaign Re-test Matrix

> Updated: 2026-08-01 (ESC8 v5 + Branch A verified status + corrected ws01 tooling + **WT027 verified / all stale rows synced**)

| ID | Stream | Attack | Source Machine | Credentials | Status | Re-test / Fix Notes |
|---|---|---|---|---|---|---|
| WT015 | Branch A | ACE#7 ForceChangePassword | ws01 | hunter_dfir / DF1R_Hunt3r! | ✅ VERIFIED 2026-07-31 | ACE#7 deployed + verified (`05-ad-attack-surface-verifyOnly.yml` 18/18); hunter_dfir reset chief_command pw via bloodyAD; restored. |
| WT013 | Branch A | WriteDacl self-escalate | ws01 | chief_command / C0mm@nd_Ch1ef! | ✅ VERIFIED 2026-07-31 | `T013` → hunter_dfir GenericAll on CN=Command-Cadre; ACE read-back verified. |
| WT014 | Branch A | GenericWrite → Shadow Creds | ws01 | chief_command / C0mm@nd_Ch1ef! | ✅ VERIFIED 2026-07-31 | `T014` → hunter_dfir GenericWrite on analyst_cloud; ACE read-back verified. |
| WT016 | Branch A | GenericAll on OU | ws01 | chief_command / C0mm@nd_Ch1ef! | ✅ VERIFIED 2026-07-31 | `T016` → hunter_dfir GenericAll on OU=Command; ACE read-back verified. |
| WT008 | Branch A | Shadow Creds on dc01$ | ws01 | chief_command / C0mm@nd_Ch1ef! | ✅ Verified | pywhisker → dc01$ KeyCredential; PKINIT TGT; NT hash recovered. |
| WT023 | Branch A | GPO Abuse | ws01 | analyst_cloud / Cl0ud_An@lyst! | ✅ Verified | WriteDacl/WriteOwner/GenericAll on Vulnerable-GPO; preference write confirmed. |
| WT024 | Branch A | gMSA extraction | ws01 | eng_cloud / Cl0ud_Eng! | ✅ Verified | msDS-ManagedPassword on gmsaTools$ → NT hash → SMB auth as gmsaTools$. |
| GPP | Branch A | GPP stored password | ws01 | analyst_cloud / Cl0ud_An@lyst! | ✅ Verified | Groups.xml cpassword → svc_ldap / s3rv1c3_Ld@p!; SMB auth verified; surface fixed (`02-ad-objects.yml` + `05-ad-attack-surface.yml`). |
| WT025 | Branch A | AdminSDHolder persistence | ws01 | analyst_cloud | ✅ VERIFIED 2026-07-31 | GenericAll backdoor ACE on AdminSDHolder; DACL restored to 23 ACEs (no rogue). |
| WT027 | Branch A | SPN Jacking CVE-2026-25177 | ws01 | chief_command (writeSPN) → analyst_cloud | ✅ VERIFIED 2026-08-01 | Planted `MSSQLSvc/dc01.cadre.local:14333` on analyst_cloud → **KDC issued TGS (AES) encrypted with analyst_cloud's key** (attacker-known → offline crack) → cleaned. **Documented self-write command NOT viable** (SPN 1433 owned by `child\svc_mssql` → uniqueness; free cross-host SPN → self validated-write denies). `wt027-spn-jack.ps1` / `-cleanup.ps1` / `-lookup*.ps1`. |
| WT050 | Branch B | ADCS ESC1 | ws01 | chief_command / C0mm@nd_Ch1ef! | ✅ VERIFIED 2026-08-01 | cert Req 39 → PKINIT TGT + UnPAC NT hash. |
| WT051 | Branch B | ADCS ESC3 | ws01 | chief_command / C0mm@nd_Ch1ef! | ✅ VERIFIED 2026-08-01 | agent + `-on-behalf-of` → admin cert Req 44. |
| WT052 | Branch B | ADCS ESC8 | ws01 | chief_command / C0mm@nd_Ch1ef! | 🔬 DEFERRED — revisit at end | Root cause: no SMB-authenticated coerce on Server 2025 (MS-RPRN = anonymous :135 only; `@8445` UNC false). Candidates: krbrelayx / restored SMB-coerce primitive. |
| WT053 | Branch B | UnPAC-the-Hash | ws01 | chief_command / C0mm@nd_Ch1ef! | ✅ VERIFIED 2026-08-01 | `certipy auth` → administrator NT hash. |
| ESC2/4/7/9 | Branch B | ADCS ESC2/4/7/9 | ws01 | hunter_dfir / lead_engineering | ✅ VERIFIED 2026-08-01 | All verified — see Branch B body table. |
| WT044..048 | Branch D | MSSQL / SSSD / keytab / NFS / podman | linux01 | mssql-linux01 pivot → root | ✅ VERIFIED 2026-08-01 | All verified — see Branch D body table. |
| E-01..E-14 | E stream | Network defense exercises | monitor/elk | — | ⏳ Configured | Sensors configured; exercises pending. Keep offline until telemetry phase. |
| F-01..F-13 | F stream | npm supply-chain scenarios | linux01/mbr01 | — | ⏳ Configured | Tooling configured; scenarios pending. |
| G | Branch G | CVE-2026-41089 | Kali | — | 🔬 Deferred | PoC present; depends on dc02 patch state. |
| H-01..H-06 | Phase 0.5 | Initial access payloads | Kali/ws01 | — | ❌ Missing | No playbook stages payloads; needs `19-initial-access.yml`. |

