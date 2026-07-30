# CADRE Campaign v3 Master Validation Report — 2026-07-30

> Scope: every attack, branch, and standalone exercise in Campaign v3.
> Excluded from execution: Phase 0.5 / H-01..H-06 (initial access) per operator request, but they are listed.
> Legend: ✅ verified / 📝 script corrected pending re-test / ⏳ not exercised / ⚠️ blocked / ❌ non-functional or rejected / 🔬 deferred.

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
| 003 | AS-REP Roast (WT003) | ws01 | child\analyst_t1 / T13r_An@lyst! | ✅ Verified | Earns intern_blue / 1nt3rn_Blu3! | No |

## Phase 2

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 002 | Kerberoast via ACE#18 bridge (WT002) | ws01 | intern_blue / 1nt3rn_Blu3! | ✅ Verified | ForceChangePassword analyst_t2 -> getTGT -> Kerberoast svc_mssql | No |

## Phase 2 Alt

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| NTLMv1 | NTLMv1 rainbow-table downgrade | Kali / provisioning | Coerced NTLMv1 responder | ⏳ Not tested | SpecterOps Into The Rainbow; not in main spine | Optional |

## Phase 3

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 041/043 | SQL xp_cmdshell + GodPotato (WT041/WT043) | ws01 -> mbr01 | child\analyst_t1 / T13r_An@lyst! | ✅ Verified | Returns nt service\mssql$sqlexpress then nt authority\system via GodPotato | No |
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
| 3.5B | Scheduled Task as analyst_cloud (3.5B) | mbr01 | analyst_cloud | ❌ Rejected for attack chain | Persistence only, not execution wrapper | No |
| 3.5C | RDP interactive session as analyst_cloud (3.5C) | ws01 -> mbr01 | analyst_cloud / Cl0ud_An@lyst! | ⏳ Not exercised | Type 10 logon + SharpHound data | Yes |
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
| 007 | RBCD standalone (WT007) | ws01 | child\analyst_t1 / T13r_An@lyst! | ⚠️ BLOCKED | PowerView LDAP query fails with operations error from ws01; script now needs redesign or proper domain context | Yes - fix script and run as child user against dc02, or use DA credential |

## Phase 5 Coercion

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 017 | MS-RPRN PrinterBug coercion (WT017) | ws01 -> SYSTEM on mbr01 | SYSTEM | ✅ Confirmed | Suricata SID:1000050 fires; dc02$ auth captured | No |
| 018 | MS-EFSR PetitPotam (WT018) | ws01 | SYSTEM | ❌ Non-functional | \PIPE\efsrpc blocked on Server 2025 | No |
| 019 | MS-DFSNM DFSCoerce (WT019) | ws01 | SYSTEM | ❌ Non-functional | SMB-pipe DCE-RPC not detectable by Suricata 8.0.5 | No |
| 020 | MS-FSRVP ShadowCoerce (WT020) | ws01 | SYSTEM | ❌ Non-functional | Service not available on Server 2025 | No |
| 021 | NTLM relay to LDAP / ESC8 (WT021) | Kali / provisioning | Coerced dc02$ or other account | ✅ Active | LDAP signing not enforced; SMB signing disabled on mbr02 | No |
| 022 | NTLM relay to ADCS / shadow credentials (WT022) | Kali / provisioning | Coerced account | ✅ Active | SMB signing disabled; relay to web enrollment | No |
| 094 | UnCanny Coerce (WT094) | ws01 | local user | 🔬 Deferred | Requires Developer Mode | After Developer Mode decision |
| 095 | Onelogon Zero-Channel (WT095) | Kali -> DC | DC machine account NTLMv2 | 🔬 Deferred | PoC expected post-WOOT 2026 | After PoC release |
| 096 | coerce_plus consolidated check (WT096) | provisioning | SYSTEM context | ⏳ Not tested | NetExec module; can be used once spooler enabled on dc02 | Yes |

## Phase 5 T102

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| T102 | Unconstrained delegation capture dc02$ TGT (T102) | SYSTEM on mbr01 | SYSTEM | ⏳ Trigger verified / capture pending | SpoolSample trigger verified against dc02; Rubeus capture did not return Kirbi markers. Playbook updated with dc02 Spooler + RPC/SMB firewall prerequisites; re-test capture after verify-only run | Yes - re-run T102 after 04-vulnerabilities-verifyOnly.yml confirms dc02 spooler/RPC surface |

## Phase 6

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 009 | DCSync (WT009) | ws01 or Kali | chief_command / C0mm@nd_Ch1ef! (DA fallback) | ✅ Verified | Original as-written path (dc02$ TGT) blocked; fallback via chief_command DA works | No - main path; optional: verify via dc02$ TGT once T102 fixed |

## Phase 7

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 010 | Golden Ticket (WT010) | ws01 | krbtgt hash (child.cadre.local) or chief_command fallback | ✅ Script executes | Script runs; as-written krbtgt hash path bypassed via chief_command DA | Yes - verify full Golden Ticket with extracted krbtgt |
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
| 035 | SCCM PXE Boot abuse (WT035) | mbr02 | svc_sccm / svc_naa | ⏳ Not exercised from ws01 | No SCCM client on ws01; must run from mbr02 or SCCM client | Yes - run from mbr02/site system |
| 036 | SCCM Client Push install (WT036) | mbr02 | svc_sccm / svc_naa | ⏳ Not exercised from ws01 | No SCCM client on ws01 | Yes - run from mbr02/site system |
| 037 | SCCM CMPivot (WT037) | mbr02 | svc_sccm / svc_naa | ⏳ Not exercised from ws01 | No SCCM client on ws01 | Yes - run from mbr02/site system |
| 038 | SCCM Application Deployment (WT038) | mbr02 | svc_sccm / svc_naa | ⏳ Not exercised from ws01 | No SCCM client on ws01 | Yes - run from mbr02/site system |
| 039 | SCCM Site Takeover (WT039) | mbr02 | svc_sccm / svc_naa | ⏳ Not exercised from ws01 | No SCCM client on ws01; ADSI path fixed in script | Yes - run from mbr02/site system |

## Phase 8 Alt

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| Skipjack | Skipjack PAC signature corruption | ws01 | child domain user | 🔬 Deferred | Needs custom Rubeus /skipjack_forge.py; SID filtering OFF verified | After PoC |

## Branch A

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 015 | ACL ForceChangePassword ACE#7 (WT015) | ws01 | hunter_dfir / DF1R_Hunt3r! | ✅ Verified live | hunter_dfir -> chief_command: ForceChangePassword; playbook fix committed | No |
| 013 | ACL WriteDacl self-escalate (WT013) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA) | 📝 Script corrected, pending re-test | Previously used analyst_t1; now uses chief_command to grant hunter_dfir GenericAll on Command-Cadre group | Yes - run after T015 |
| 014 | ACL GenericWrite -> Shadow Credentials (WT014) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA) | 📝 Script corrected, pending re-test | Previously used analyst_t1; now uses chief_command to grant hunter_dfir GenericWrite on analyst_cloud | Yes - run after T015 |
| 016 | ACL GenericAll on OU (WT016) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA) | 📝 Script corrected, pending re-test | Previously used analyst_t1; now uses chief_command to grant hunter_dfir GenericAll on OU=Command | Yes - run after T015 |
| 008 | Shadow Credentials on dc01$ (WT008) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA) | 📝 Script corrected, pending re-test | Previously used analyst_t1; now uses chief_command to add KeyCredential to dc01$ | Yes - run after T015 |
| 023 | GPO Abuse (WT023) | ws01 | analyst_cloud / Cl0ud_An@lyst! (ACE#1) | 📝 Script corrected, pending re-test | Uses analyst_cloud extracted from mbr01 Winlogon; enumerates GPOs and links | Yes |
| 024 | gMSA Extraction (WT024) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA) | 📝 Script corrected, pending re-test | Previously used analyst_t1; now uses chief_command with GoldenGMSA | Yes - run after T015 |
| GPP | GPP Stored Password (Groups.xml) | Kali / provisioning | Any domain user | ⏳ Not exercised | Get-GPPPassword not run | Yes |
| 027 | SPN Jacking CVE-2026-25177 (WT027) | ws01 | DA or writeSPN rights | ⏳ Not exercised | Abuse writeSPN/validateSPN to Kerberoast target | Yes |
| 025 | AdminSDHolder persistence (WT025) | ws01 | DA | ⏳ Not exercised | Modify AdminSDHolder template | Yes |

## Branch B

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 050 | ADCS ESC1 (WT050) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA+EA) | 📝 Script corrected, pending re-test | Previously used analyst_t1 and failed DirectoryServices error; now uses chief_command@cadre.local | Yes - run after T015 |
| 051 | ADCS ESC3 (WT051) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA+EA) | 📝 Script corrected, pending re-test | Enrollment Agent abuse; now uses chief_command | Yes - run after T015 |
| 052 | ADCS ESC8 / NTLM relay web enrollment (WT052) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA+EA) | 📝 Script corrected, pending re-test | Web enrollment reachable check; now uses chief_command | Yes - run after T015 |
| 053 | UnPAC-the-Hash (WT053) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA+EA) | 📝 Script corrected, pending re-test | Certify request then Rubeus /unpac-thehash; now uses chief_command | Yes - run after T015 |

## Branch D

| ID | Attack | Source Machine | Credential | Status | Notes | Re-test Needed |
|------|--------|----------------|------------|--------|-------|----------------|
| 044 | MSSQL Linked Server Recon (WT044) | ws01 -> mbr01 | child\analyst_t1 / T13r_An@lyst! | ✅ Verified | OPENQUERY to LINUX01.master.sys.databases returns linux01 databases | No |
| 045 | SSSD Ticket Extraction (WT045) | linux01 | linux01 local access or SSH key | ⏳ Not exercised | Extract Kerberos tickets from SSSD cache | Yes |
| 046 | MSSQL Keytab Extraction (WT046) | linux01 | linux01 root or mssql service | ⏳ Not exercised | Extract keytab used by MSSQL service | Yes |
| 047 | NFS Kerberos Mount (WT047) | linux01 | Valid domain Kerberos ticket | ⏳ Not exercised | Mount NFS export with sec=krb5p | Yes |
| 048 | Podman Container Escape (WT048) | linux01 | Privileged container or misconfig | ⏳ Not exercised | Podman privileged escape | Yes |

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
| `dc02$` | `child.cadre.local` | TGT | Phase 6 DCSync | Phase 5 coercion + Rubeus monitor (BLOCKED) |
| `child\krbtgt` | `child.cadre.local` | hash | Phase 7 Golden Ticket | Phase 6 DCSync (fallback used) |
| `root EA` | `cadre.local` | TGT | Phase 8 cross-forest | Phase 7 Golden Ticket + ExtraSids (fallback via chief_command) |
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

1. **Enable Print Spooler on dc02** (`04-vulnerabilities.yml`) and re-run T102 coercion.
2. **Re-run all Branch A scripts after T015** using `hunter_dfir` and `chief_command`.
3. **Re-run all Branch B ADCS scripts** using `chief_command@cadre.local`.
4. **Run Branch C SCCM chain from mbr02** (WT035-039).
5. **Write and run Branch D scripts** (WT045-048).
6. **Run Branch G CVE-2026-41089** from Kali against dc02 with snapshot.
7. **Run E exercises** on monitor VM once elk/monitor are online.
8. **Run F supply-chain scenarios** on linux01/mbr01/npm registry.

---
*Generated from CAMPAIGNS-METADATA-v2.md and 2026-07-30 validation run.*
