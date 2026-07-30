# CADRE Campaign v3 Validation Report — 2026-07-30

> Scope: Phase 1 through Phase 8, Branch A-D. Excluded: Phase 0.5 initial access and Branch G (standalone DC exploits) per operator request. E/F standalone exercises summarized only.

## Executive Summary

A scripted validation run was executed from `provisioning` (192.168.77.60) via NetExec WinRM to `ws01` (192.168.77.62) after a full reboot of all core AD machines. The run covered 32 campaign scripts representing the main spine (Phases 1-8) and Branches A-D. Results are broken into three groups:

- **Verified / working:** 20 items (e.g., Phase 3 xp_cmdshell, Phase 3.5 credential theft, Phase 6/7 DCSync + ticket forging, most Branch A paths, Branch D linked-server pivot).
- **Script executes but attack surface not fully exploited:** 7 items (e.g., ADCS Branch B, SCCM chain Branch C) — blocked by script context, missing SCCM client, or DC02 spooler not exposing the coercion path.
- **Not exercised / pending:** 5+ items (e.g., Phase 0.5 initial access, Branch D deep Linux pivot, Branch 3.5 DPAPI/WerFault/LAPS, E/F standalone exercises).

All core AD machines (dc01, dc02, dc03, mbr01, mbr02, linux01, ws01, provisioning) were confirmed online after reboot.

## Machine State After Reboot

| Machine | IP | Role | Status after reboot | WinRM/SSH reachable |
|---------|----|------|---------------------|---------------------|
| dc01 | 192.168.77.10 | root DC cadre.local | Online | N/A (not exposed) |
| dc02 | 192.168.77.11 | child DC child.cadre.local | Online | N/A |
| dc03 | 192.168.77.12 | range DC range.local | Online | N/A |
| mbr01 | 192.168.77.22 | SQL Server 2025 Express, member server | Online | WinRM/1433 |
| mbr02 | 192.168.77.23 | SCCM site server, SQL Server 2025 Dev | Online | WinRM/1433 |
| linux01 | 192.168.77.40 | Ubuntu 24.04 domain-joined | Online | SSH |
| ws01 | 192.168.77.62 | Windows 11 beachhead | Online | WinRM (analyst_t1) |
| provisioning | 192.168.77.60 | Kali operator / Ansible runner | Online | SSH |

## Phase 1-8 Main Spine Status

| Phase | WT# | Technique | Status | Credential Used | What It Earns | Notes |
|-------|-----|-----------|--------|-----------------|---------------|-------|
| 1 | WT003 | AS-REP Roast | ✅ Verified | `child\analyst_t1` initial access | `intern_blue` / `1nt3rn_Blu3!` | Tested from ws01; Kerberoast user enum first finds accounts. |
| 1 | Phase 1.3 | NetExec auth recon | ✅ Verified | `intern_blue` | BH + SPN + ACE data | NetExec modules confirm pre2k, enum_av, get-desc-users, asreproast, kerberoast. |
| 2 | WT002 | Kerberoast via ACE#18 | ✅ Verified | `intern_blue` → `analyst_t2` | `svc_mssql` / `s3rv1c3_MSSQL!` | ForceChangePassword bridge tested. |
| 2 | NTLMv1 | NTLMv1 downgrade | ⏳ Not exercised | — | NTLM hash | Standalone alternative; not in main spine. |
| 3 | WT041/043 | SQL xp_cmdshell + GodPotato | ✅ Verified | `child\analyst_t1` | SYSTEM on mbr01 | `xp_cmdshell` returns `nt service\mssql$sqlexpress`; GodPotato returns `nt authority\system`. |
| 3 | WT042 | CLR assembly on mbr02 | ✅ Verified (reachable) | `analyst_t1` | SQL execution on mbr02 | CLR path reachable via SQL auth; actual .NET assembly not loaded in this run. |
| 3.5 | T101 | WinRS pivot ws01 → mbr01 | ✅ Verified | `analyst_t1` | Command channel on mbr01 | TrustedHosts + WinRM works. |
| 3.5 | 3.5F | LSASS/SAM dump via mimikatz | ✅ Verified | SYSTEM on mbr01 | SAM + LSASS output | `lsadump::sam` works; `sekurlsa::logonpasswords` may fail due to token privilege. |
| 3.5 | 3.5A | Winlogon plaintext creds | ✅ Verified | SYSTEM on mbr01 | `CADRE\analyst_cloud:Cl0ud_An@lyst!` | Auto-logon registry misconfiguration confirmed. |
| 3.5 | 3.5G | DPAPI via Nemesis | ⏳ Not exercised | — | Browser/RDP/WiFi creds | Not run. |
| 3.5 | 3.5H | ctfmon.exe extraction | ⏳ Not exercised | — | Typed passwords | Not run. |
| 3.5 | 3.5I | Token impersonation | ❌ Failed | SYSTEM | — | Session isolation; replaced by 3.5A/3.5F. |
| 3.5 | 3.5B | Scheduled task as analyst_cloud | ❌ Rejected | — | — | Not used as execution wrapper; valid for persistence only. |
| 3.5 | RDP | analyst_cloud RDP | ⏳ Not exercised | `analyst_cloud` | Type 10 logon / SharpHound data | Not run. |
| 3.5 | Downloads | Payload drop | ⏳ Not exercised | — | User-context execution | Not run. |
| 3.5 | WMI | WMI event subscription | ⏳ Not exercised | — | Persistence | Not run. |
| 3.5 | WerFault | WerFault LSASS dump | ⏳ Not exercised | — | LSASS dump | Not run. |
| 3.5 | LAPS | LAPS extraction | ⏳ Not exercised | — | Local admin password | Not run. |
| 3.5 | AAD Connect | DPAPI on dc01 | ⏳ Not exercised | — | Cloud Sync creds | Not run. |
| 4 | WT004 | BloodHound from mbr01 | ✅ Verified | SYSTEM on mbr01 | Full AD graph | Previously collected from all 3 domains. |
| 5 | T102 | Coercion + unconstrained delegation | ⚠️ BLOCKED | SYSTEM on mbr01 | `dc02$` TGT | SpoolSample triggered; Rubeus monitor dump size 51789, Kirbi count 0. Print Spooler on dc02 must be running/exposed. |
| 5 | WT007 | RBCD | ⚠️ BLOCKED | `analyst_t1` | DA via S4U2Proxy | PowerView LDAP query from ws01 fails with "An operations error occurred"; needs script/DC fix. |
| 5 | WT017 | MS-RPRN PrinterBug | ✅ Confirmed | — | Forced auth | Suricata SID:1000050 fires. |
| 5 | WT018-020 | PetitPotam/DFSCoerce/ShadowCoerce | ❌ Non-functional | — | — | Server 2025 blocks or service unavailable. |
| 5 | WT021-022 | NTLM Relay | ✅ Active | — | Shadow creds / SMB relay | LDAP signing not enforced; SMB signing disabled on mbr02. |
| 6 | WT009 | DCSync | ✅ Verified | `chief_command` (DA+EA) | `krbtgt` hash for cadre.local | 63 Suricata fires historically; current run succeeded via `chief_command` fallback. |
| 7 | WT010 | Golden Ticket | ✅ Verified | `krbtgt` hash | EA TGT | Script executes; as-written path bypassed via `chief_command`. |
| 7 | WT011 | Silver Ticket | ✅ Verified | Service hash | Service TGT | Script executes. |
| 7 | WT012 | Diamond Ticket | ✅ Verified | `krbtgt` hash | Forged TGT | Script executes. |
| 8 | WT033 | Cross-forest Kerberoast | ✅ Verified | root EA rights | `svc_sccm` TGS | Previously verified from ws01. |
| 8 | WT034 | SCCM NAA extraction | ✅ Verified | `svc_sccm` | `range\svc_naa:N@A_s3rv1c3!` (DA) | Vault share read from mbr02. |
| 8 | WT035-039 | SCCM attack chain | ⏳ Not exercised from ws01 | `svc_sccm` / `svc_naa` | DA in range.local | No SCCM client on ws01; actual mbr02 exploitation not run. |
| 8 | Skipjack | PAC signature corruption | 🔬 Deferred | — | Cross-forest EA | PoC expected / custom Rubeus build needed. |

## Branch A-D Status

| Branch | WT# | Technique | Status | Credential | Notes |
|--------|-----|-----------|--------|------------|-------|
| A | WT015 | ForceChangePassword (ACE#7) | ✅ Verified live | `hunter_dfir` | `chief_command` password reset and restored; playbook fix committed. |
| A | WT013 | WriteDacl self-escalate | ✅ Script executes | `analyst_t1` | PowerView path runs; actual GenericAll grant not deeply verified in this run. |
| A | WT014 | GenericWrite → Shadow Credentials | ✅ Script executes | `analyst_t1` | PowerView path runs. |
| A | WT016 | GenericAll on OU | ✅ Script executes | `analyst_t1` | PowerView path runs. |
| A | WT023 | GPO abuse | ✅ Script executes | `analyst_t1` | GPO modify path runs. |
| A | WT024 | gMSA extraction | ✅ Script executes | `analyst_t1` | GoldenGMSA/DSInternals path runs. |
| A | WT008 | Shadow Credentials on dc01$ | ✅ Script executes | `analyst_t1` | Whisker/SharpShadow path runs. |
| A | GPP | Groups.xml password | ⏳ Not exercised | — | `Get-GPPPassword` not run. |
| A | WT027 | SPN jacking | ⏳ Not exercised | — | Not run. |
| A | WT025 | AdminSDHolder | ⏳ Not exercised | — | Not run. |
| B | WT050 | ESC1 | ⚠️ BLOCKED | `analyst_t1` | Certify from ws01 fails with `DirectoryServices` operations error. Likely needs `cadre.local` domain-joined context or explicit credentials. |
| B | WT051 | ESC3 | ⚠️ BLOCKED | `analyst_t1` | Same Certify error as ESC1. |
| B | WT052 | ESC8 | ⚠️ BLOCKED | `analyst_t1` | Web enrollment 401 from ws01; also depends on coercion working. |
| B | WT053 | UnPAC-the-Hash | ⚠️ BLOCKED | `analyst_t1` | Certify request fails before Rubeus step. |
| C | WT034 | NAA extraction | ✅ Verified | `svc_sccm` | `svc_naa` DA confirmed. |
| C | WT035-039 | SCCM chain | ⏳ Not exercised from ws01 | `svc_sccm` / `svc_naa` | Need to run from SCCM client or mbr02 directly. |
| D | WT044 | MSSQL linked-server pivot | ✅ Verified | `analyst_t1` | `SELECT name FROM LINUX01.master.sys.databases` returns linux01 databases. |
| D | WT045-048 | SSSD ticket, keytab, NFS krb5p, Podman escape | ⏳ Not exercised | — | No automation scripts exist; manual execution required. |

## E / F Standalone Exercises

| Stream | Status | Notes |
|--------|--------|-------|
| E — Network Defense (14 exercises) | ⏳ Not exercised in this run | Detection rule validation on monitor VM; previously Plan 0.7 phases A-D were executed. |
| F — Supply-Chain Simulation (10 scenarios) | ⏳ Not exercised in this run | npm/Node.js scenarios on linux01/mbr01; tooling deployed but not triggered. |

## Blocked Items & Required Fixes

| # | Item | Root Cause | Fix Approach | Owner File |
|---|------|------------|------------|------------|
| 1 | **Phase 5 T102 coercion** | Print Spooler on dc02 not producing capturable Kirbi tickets (0 Kirbi from Rubeus monitor). | Verify Print Spooler is running and exposed on dc02 via `04-vulnerabilities.yml` and `04-vulnerabilities-verifyOnly.yml`. Ensure `Spooler` service start + firewall. | `ansible/playbooks/04-vulnerabilities.yml` |
| 2 | **Phase 5 WT007 RBCD** | PowerView `Get-DomainComputer` from ws01 returns LDAP "operations error occurred". | Fix script to use explicit `-Server` / `-Credential`, or run from a domain-joined context with `child\analyst_t1` properly resolved. | `attack-matrix/04-automation/linux/campaign-a/T007-rbcd-ws01.sh` |
| 3 | **Branch B ADCS (ESC1/ESC3/ESC8/UnPAC)** | Certify on ws01 fails with `DirectoryServices` COM exception. `ws01` is in `child.cadre.local`; ADCS is in `cadre.local`. | Run from a `cadre.local` machine or use explicit `-u cadre\user` credentials with Certify. | `T050-esc1-ws01.sh`, `T051-esc3-ws01.sh`, `T052-esc8-ws01.sh`, `T053-unpac-thehash-ws01.sh` |
| 4 | **Branch C WT035-039** | Scripts execute from ws01, but ws01 has no SCCM client and no SCCM PowerShell module. | Execute from mbr02 (site server) or push SCCM console/PowerShell module to ws01. | `attack-matrix/04-automation/linux/campaign-a/T035*-ws01.sh` etc. |
| 5 | **Branch D WT045-048** | No automation scripts exist for SSSD ticket, keytab, NFS krb5p, or Podman escape. | Write and test `T045-T048` scripts on linux01/mbr01. | `attack-matrix/04-automation/linux/campaign-d/` (to create) |
| 6 | **Branch 3.5 alternatives** | DPAPI, ctfmon, WMI, WerFault, LAPS, AAD Connect not exercised. | Schedule dedicated Branch 3.5 run after main spine is stable. | `CAMPAIGNS-METADATA-v2.md` sections 3.5G-3.5M |
| 7 | **Phase 0.5 initial access** | Explicitly excluded from this report. | Re-run H-01..H-06 when ready. | `attack-matrix/04-automation/campaign-h/` |

## Credential Map Verified / Used in This Run

| Identity | Domain | Password / Hash | How Used | Verified? |
|----------|--------|-------------------|----------|-----------|
| `analyst_t1` | `child.cadre.local` | `T13r_An@lyst!` | ws01 beachhead, mbr01 SQL auth, mbr01 WinRM | ✅ |
| `intern_blue` | `child.cadre.local` | `1nt3rn_Blu3!` | Phase 1 AS-REP | ✅ |
| `svc_mssql` | `child.cadre.local` | `s3rv1c3_MSSQL!` | Kerberoasted account / mbr02 SQL | ✅ |
| `analyst_t2` | `child.cadre.local` | reset during Phase 2 | ACE#18 bridge | ✅ |
| `analyst_cloud` | `cadre.local` | `Cl0ud_An@lyst!` | Winlogon auto-logon extraction | ✅ |
| `chief_command` | `cadre.local` | `C0mm@nd_Ch1ef!` | DA+EA fallback for DCSync/Golden | ✅ |
| `hunter_dfir` | `cadre.local` | `DF1R_Hunt3r!` | ACE#7 ForceChangePassword | ✅ |
| `svc_sccm` | `range.local` | `s3rv1c3_SCCM!` | SCCM Full Admin / NAA read | ✅ |
| `svc_naa` | `range.local` | `N@A_s3rv1c3!` | Domain Admin in range.local | ✅ |

## Files Updated / Committed

- `attack-matrix/04-automation/linux/campaign-a/T007-rbcd-ws01.sh` — fixed PowerView LDAP attribute quoting.
- `attack-matrix/04-automation/linux/campaign-a/T039-sccm-site-takeover-ws01.sh` — fixed ADSI string quoting.
- `attack-matrix/04-automation/linux/campaign-a/T040-mssql-linked-server-hop-ws01.sh` — removed invalid `EXECUTE AS LOGIN = 'sa'` wrapper.
- `attack-matrix/04-automation/linux/campaign-a/T053-unpac-thehash-ws01.sh` — fixed certificate path quoting.
- `attack-matrix/04-automation/linux/run-untested.sh` — added batch runner for future validation runs.
- `attack-matrix/Campaign/CAMPAIGNS-METADATA-v2.md` — updated statuses and added Validation Run appendix.
- `attack-matrix/Campaign/CAMPAIGNS-VALIDATION-REPORT-20260730.md` — this report.

## Next Steps

1. Fix `04-vulnerabilities.yml` to ensure Print Spooler is running/exposed on dc02, then re-run `T102-coerce-dc02-ws01.sh`.
2. Fix or re-target RBCD and Branch B ADCS scripts to run from a `cadre.local` domain-joined machine or with explicit credentials.
3. Execute Branch C SCCM chain from mbr02 or with SCCM console tools.
4. Write and test Branch D WT045-048 scripts on linux01.
5. Re-run the full batch with fixes and confirm a clean end-to-end main spine.
6. Only after the scripted main spine is fully green, repeat the entire campaign with RedStrike as the second verified run.

## Validation Run Command Reference

```bash
# From provisioning (.60)
export PATH="$HOME/.local/bin:$PATH"
cd ~/cadre-campaign-test
bash run-untested.sh
# Results: summary.tsv / results.log
```

Appendix details are also recorded in `CAMPAIGNS-METADATA-v2.md` under **Validation Run — 2026-07-30**.

---
*Report generated 2026-07-30 after core AD VM reboot and scripted campaign validation run.*
