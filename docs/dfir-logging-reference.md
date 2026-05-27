# CADRE — DFIR Logging Reference

<!-- AUDIENCE: PUBLIC -->

Single-page reference for every telemetry source CADRE produces — Windows audit, Sysmon,
PowerShell, NTLM, operational channels, Linux auditd, MSSQL audit, SSSD, podman, osquery,
Zeek, Suricata, cloud, and Velociraptor.

For *how* the data flows through the pipeline see [`architecture.md`](architecture.md)
and [`forensic-workflow.md`](forensic-workflow.md). For *how to verify* a source is
producing data see [`testing-recommendations.md`](testing-recommendations.md).

**Source of truth for Windows audit:** the entire Windows half of this document mirrors
what `ansible/roles/security/files/cadre-dfir-monitoring.ps1` configures (now deployed via `11-security-baseline.yml`). If the script
changes, this page must be updated in the same commit.

---

## 1 · Quick Index — All Data Sources

| # | Source | Host | Elastic index | Section |
|---|--------|------|---------------|---------|
| 1 | Windows Security Events (audit subcategories) | 5× Server 2025 | `logs-system.security-*` | [§2](#2-windows-advanced-audit-subcategories) |
| 2 | Windows operational channels | 5× Server 2025 | `logs-windows.*` (per channel) | [§3](#3-windows-operational-channels) |
| 3 | PowerShell ScriptBlock / Module / Transcription | 5× Server 2025 | `logs-windows.powershell-*` | [§4](#4-powershell-logging) |
| 4 | NTLM auditing | 5× Server 2025 | `logs-windows.ntlm-*` (custom) | [§5](#5-ntlm-auditing) |
| 5 | Sysmon (sysmon-modular) | 5× Server 2025 | `logs-windows.sysmon_operational-*` | [§6](#6-sysmon-event-ids) |
| 6 | Elastic Defend (kernel EDR, DETECT mode) | 5× Server 2025 + linux01 | `logs-endpoint.events-*`, `logs-endpoint.alerts-*` | [§7](#7-elastic-defend) |
| 7 | Linux auditd | linux01 | `logs-auditd.log-*` | [§8](#8-linux-auditd-rules) |
| 8 | MSSQL Server Audit (Linux) | linux01 | `logs-mssql.audit-*` | [§9](#9-mssql-server-audit-linux) |
| 9 | SSSD debug | linux01 | `logs-sssd-*` (custom_logs) | [§10](#10-sssd-debug-logs) |
| 10 | Podman events | linux01 | `logs-podman-*` (custom_logs) | [§11](#11-podman-events) |
| 11 | osquery scheduled pack | linux01 | `logs-osquery_manager.result-*` | [§12](#12-osquery-scheduled-pack) |
| 12 | Zeek protocol logs | monitor | `logs-zeek.*-*` (per protocol) | [§13](#13-zeek-protocol-logs) |
| 13 | Suricata IDS alerts | monitor | `logs-suricata-*` | [§14](#14-suricata) |
| 14 | Arkime full PCAP | monitor | Arkime local ES | [§15](#15-arkime--tcpdump--silk) |
| 15 | tcpdump rotation / SiLK flows | monitor | filesystem | [§15](#15-arkime--tcpdump--silk) |
| 16 | Entra ID + Azure (Plan 11) | cloud → elk | `logs-entra.*`, `logs-azure.*`, `logs-m365.*` | [§16](#16-cloud--entra--azure--m365) |
| 17 | Velociraptor artifacts | vr → on demand | VR server | [§17](#17-velociraptor-artifacts) |

---

## 2 · Windows Advanced Audit Subcategories

All 5 Windows Server 2025 VMs run `auditpol /set /subcategory:"<name>" /success:enable /failure:enable`
for every entry below. Persisted by `SCENoApplyLegacyAuditPolicy=1` so subcategory policy
survives GPO refresh.

All events land in `logs-system.security-*` via Elastic Agent's `windows` integration.

### 2.1 — Account Logon

| Subcategory | EIDs | What it catches |
|-------------|------|-----------------|
| Credential Validation | 4774, 4776 | NTLM credential validation by a DC; classic password-spray / pass-the-hash signal |
| Kerberos Authentication Service | 4768, 4771, 4772 | AS-REQ / AS-REP — TGT issuance · 4768 with TicketEncryptionType=0x17 = RC4 anomaly |
| Kerberos Service Ticket Operations | 4769, 4770 | TGS-REQ / TGS-REP — service-ticket issuance · core Kerberoasting signal |
| Other Account Logon Events | 4649, 4778, 4779, 4800-4803 | Workstation lock/unlock, session reconnect |

### 2.2 — Logon / Logoff

| Subcategory | EIDs | What it catches |
|-------------|------|-----------------|
| Logon | 4624, 4625, 4648 | Successful + failed logon · 4648 = explicit logon (`runas`, scheduled task) |
| Logoff | 4634, 4647 | Session end |
| Special Logon | 4672, 4964 | Privileged group membership at logon (Admins, Backup Operators, etc.) |
| Account Lockout | 4740 | Lockout — brute-force signal |
| Other Logon/Logoff Events | 4649, 4778-4779, 5378 | Various session events |
| Group Membership | 4627 | Full token group membership at logon — critical for privilege inheritance |

### 2.3 — Account Management

| Subcategory | EIDs | What it catches |
|-------------|------|-----------------|
| User Account Management | 4720-4738, 4781 | User created / modified / deleted / pwd-reset · 4720 = new user |
| Computer Account Management | 4741-4743 | Computer object created / modified |
| Security Group Management | 4727-4737, 4754-4758 | Security group changes — including DA / EA membership |
| Distribution Group Management | 4744-4753 | Distribution group changes |
| Application Group Management | 4783-4793 | App-specific group changes |
| Other Account Management Events | 4782, 4793 | Password policy changes, password-hash access (DCSync precursor) |

### 2.4 — Detailed Tracking

| Subcategory | EIDs | What it catches |
|-------------|------|-----------------|
| Process Creation | 4688 | Every new process — **with command line** (`ProcessCreationIncludeCmdLine_Enabled=1`) |
| Process Termination | 4689 | Process exit |
| DPAPI Activity | 4692-4695 | DPAPI backup-key access — credential-theft signal |
| RPC Events | 5712 | RPC call attempts |
| Plug and Play Events | 6416, 6419-6423 | USB / removable device insertion |
| Token Right Adjusted Events | 4703 | `AdjustTokenPrivileges` — privilege-enabling tools (mimikatz, etc.) |

### 2.5 — Directory Service

| Subcategory | EIDs | What it catches |
|-------------|------|-----------------|
| Directory Service Access | 4662 | Object access in AD · core for ACL-abuse / DCSync detection |
| Directory Service Changes | 5136-5141 | AD object created / modified / deleted with attribute diffs |
| Directory Service Replication | 4932, 4933 | Replication start / end |
| Detailed Directory Service Replication | 4928-4931 | **DCShadow visibility** — replication-source changes |

### 2.6 — Object Access

| Subcategory | EIDs | What it catches |
|-------------|------|-----------------|
| File Share | 5140 | Share access (`\\server\share`) |
| Detailed File Share | 5145 | Per-file access inside shares — full path + access mask |
| File System | 4656, 4663, 4660, 4670 | File / directory access (where SACL is set) |
| Kernel Object | 4656, 4663 | Kernel-object access (mutex, semaphore — driver injection) |
| Registry | 4656, 4657, 4663 | Registry value change (where SACL is set) — persistence detection |
| SAM | 4661 | SAM database read — DCSync / hash-dump signal |
| Removable Storage | 4663 | File access on removable media |
| Certification Services | 4886-4888, 4890, 4896, 4898 | **ADCS template enrollment / CA operations** — ESC1-15 detection |
| Handle Manipulation | 4658, 4690 | Handle close / duplicate — process-injection signal |
| Other Object Access Events | 4985, 5051 | Transaction state changes, COM activation, scheduled-task object |

### 2.7 — Policy Change

| Subcategory | EIDs | What it catches |
|-------------|------|-----------------|
| Audit Policy Change | 4719, 4902, 4904-4912 | Audit policy modifications — defender-tampering signal |
| Authentication Policy Change | 4706-4716, 4865-4867 | Trust + auth policy changes |
| Authorization Policy Change | 4703-4705, 4670 | Permission / privilege assignments |
| MPSSVC Rule-Level Policy Change | 4944-4958 | Windows Firewall rule changes |
| Filtering Platform Policy Change | 5440-5479 | WFP changes (Defender, third-party FW) |
| Other Policy Change Events | 4670, 4909, 4910 | Group Policy + Trust changes |

### 2.8 — Privilege Use

| Subcategory | EIDs | What it catches |
|-------------|------|-----------------|
| Sensitive Privilege Use | 4673, 4674, 4985 | Use of sensitive privileges (`SeDebugPrivilege`, `SeTcbPrivilege`) |
| Non Sensitive Privilege Use | 4673, 4674 | Other privilege usage |

### 2.9 — System

| Subcategory | EIDs | What it catches |
|-------------|------|-----------------|
| Security State Change | 4608, 4616, 4621 | System boot, time change, audit log cleared |
| Security System Extension | 4610, 4611, 4614, 4622, 4697 | Authentication packages, security drivers, **new services** |
| System Integrity | 4612, 4615, 4618, 4816, 5038, 5056-5061 | Buffer overflow detection, RPC integrity |
| IPsec Driver | 4960-4965 | IPsec driver events |
| Other System Events | 5024-5034, 5827, 5828 | Service / SCM events |

> **Not enabled by default** (very noisy on a busy DC — would burn 1 GB Security log in
> minutes): *Filtering Platform Connection* (EID 5156). Uncomment the relevant line in
> `cadre-dfir-monitoring.ps1` if you want flow-style network telemetry without Sysmon.

---

## 3 · Windows Operational Channels

All channels enabled (`wevtutil sl <channel> /e:true`) and resized to **256 MB**
(`/ms:268435456`). Channels marked **(2025)** are Server 2025-only — they are silently
skipped on 2022.

Each channel ships to Elastic as `logs-windows.<channel-slug>-*` via the relevant
Elastic Agent integration.

### 3.1 — Lateral Movement / Remote Access

| Channel | Key EIDs | Catches |
|---------|----------|---------|
| `Microsoft-Windows-TerminalServices-LocalSessionManager/Operational` | 21, 24, 25 | RDP session lifecycle (start / disconnect / reconnect) |
| `Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational` | 1149 | RDP authentication success (source IP + user) |
| `Microsoft-Windows-WinRM/Operational` | 91, 142, 161, 169 | PSRemoting / WinRM session activity |
| `Microsoft-Windows-PowerShell/Operational` | 4103, 4104 | Destination channel for ScriptBlock + Module logging (see [§4](#4-powershell-logging)) |
| `Microsoft-Windows-SmbClient/Security` | 31001 | SMB client authentication events |
| `Microsoft-Windows-SMBServer/Audit` | 3000 | **SMBv1 usage detection** — Eternal-Blue-era signal |
| `Microsoft-Windows-SMBServer/Operational` | 1006, 1010, 1011 | SMB server lifecycle |

### 3.2 — Persistence / Execution

| Channel | Key EIDs | Catches |
|---------|----------|---------|
| `Microsoft-Windows-TaskScheduler/Operational` | 106, 140, 141, 200, 201 | Task create / update / delete / start / stop |
| `Microsoft-Windows-WMI-Activity/Operational` | 5857-5861 | WMI permanent event consumers, suspicious queries (`Win32_Process Create`) |

### 3.3 — Network / Staging

| Channel | Key EIDs | Catches |
|---------|----------|---------|
| `Microsoft-Windows-DNS-Client/Operational` | 3008, 3010, 3018 | DNS query telemetry — host-level DNS without Sysmon EID 22 |
| `Microsoft-Windows-Bits-Client/Operational` | 3, 4, 59, 60 | BITS jobs — LOLBin exfil + stage |

### 3.4 — Coercion / Exploitation

| Channel | Key EIDs | Catches |
|---------|----------|---------|
| `Microsoft-Windows-PrintService/Operational` | 307, 805 | **PrintNightmare / PrinterBug** — print job + driver-install events |
| `Microsoft-Windows-PrintService/Admin` | 19, 808 | Print spooler errors, driver load failures |
| `Microsoft-Windows-NTLM/Operational` | 8001-8004 | NTLM auditing — see [§5](#5-ntlm-auditing) |

### 3.5 — Code Execution Context

| Channel | Key EIDs | Catches |
|---------|----------|---------|
| `Microsoft-Windows-CodeIntegrity/Operational` | 3001-3004, 3023 | Driver / binary integrity check failures |
| `Microsoft-Windows-AppLocker/EXE and DLL` | 8002, 8003, 8004 | EXE / DLL allow / block / audit (if AppLocker policy applied) |
| `Microsoft-Windows-AppLocker/MSI and Script` | 8005, 8006, 8007 | MSI / script allow / block / audit |
| `Microsoft-Windows-AppLocker/Packaged app-Execution` | 8020, 8021, 8022 | Modern-app activation |

### 3.6 — ADCS (only on CA host)

| Channel | Key EIDs | Catches |
|---------|----------|---------|
| `Microsoft-Windows-CertificationAuthority-CertSvc/Operational` | 1, 13, 22, 100 | CA service start / template enrollment / certificate issuance |

### 3.7 — AMSI

| Channel | Key EIDs | Catches |
|---------|----------|---------|
| `Microsoft-Windows-AMSI/Operational` | 1101, 1102 | **Script content BEFORE deobfuscation** — sees raw payload regardless of obfuscation |

### 3.8 — Defender (telemetry only — does not change blocking)

| Channel | Key EIDs | Catches |
|---------|----------|---------|
| `Microsoft-Windows-Windows Defender/Operational` | 1116, 1117, 5007 | Defender detect / block / configuration change |

### 3.9 — Server 2025 Additions

| Channel | Key EIDs | Catches |
|---------|----------|---------|
| `Microsoft-Windows-Kerberos/Operational` **(2025)** | varies | Kerberos errors, RC4 rejections, AES enforcement failures — **CVE-2026-20833 surface** |
| `Microsoft-Windows-Kerberos-Key-Distribution-Center/Operational` **(2025)** | varies | KDC-side ticket issuance / rejection — golden / silver ticket forensics |
| `Microsoft-Windows-LDAP-Client/Debug` **(2025)** | varies | **LDAP signing failures — NTLM relay detection** |
| `Microsoft-Windows-Security-Mitigations/UserMode` **(2025)** | varies | Exploit protection events (ASR, DEP, ASLR, CFG) |
| `Microsoft-Windows-Credential-Guard/Operational` **(2025)** | varies | Credential Guard state events (when enabled — dc03 only by default) |

---

## 4 · PowerShell Logging

Three modes enabled by `cadre-dfir-monitoring.ps1`. All land in `logs-windows.powershell-*`.

| Mode | Registry | EID | What it catches |
|------|----------|-----|-----------------|
| **ScriptBlock Logging** | `HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging \ EnableScriptBlockLogging=1` | 4104 | Full script body **post-deobfuscation** — sees the raw code regardless of `[char]+`, base64, compression |
| **Module Logging** | `HKLM:\…\PowerShell\ModuleLogging \ EnableModuleLogging=1` + `ModuleNames \ * = *` | 4103 | Pipeline parameter + return value capture for **all modules** (the `*` wildcard is what most configs miss) |
| **Transcription** | `HKLM:\…\PowerShell\Transcription \ EnableTranscripting=1`, `EnableInvocationHeader=1`, `OutputDirectory=C:\PSTranscripts` | n/a | Full session record to disk — UTF-16 transcripts at `C:\PSTranscripts\` |

### What each EID looks like

| EID | When | Useful fields |
|-----|------|---------------|
| 4103 | Pipeline executed | `ContextInfo.Severity`, `ContextInfo.HostName`, `Payload` (parameters + return values) |
| 4104 | Script block compiled | `ScriptBlockText` (the full code), `Path`, `ScriptBlockId` |

---

## 5 · NTLM Auditing

| Registry | Value | Purpose |
|----------|-------|---------|
| `HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0 \ RestrictSendingNTLMTraffic` | 1 | Audit outbound NTLM — does NOT block (mode 1 = audit) |
| `HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0 \ AuditReceivingNTLMTraffic` | 2 | Audit inbound NTLM — receives all NTLM auth attempts |
| `HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters \ AuditNTLMInDomain` | 7 | DC-side: audit all NTLM auth into the domain |

Events land in `Microsoft-Windows-NTLM/Operational`:

| EID | Catches |
|-----|---------|
| 8001 | Outgoing NTLM authentication |
| 8002 | Incoming NTLM authentication |
| 8003 | NTLM block due to RestrictSendingNTLMTraffic = 2 (not enabled in CADRE — we audit only) |
| 8004 | DC-side NTLM authentication acceptance |

---

## 6 · Sysmon Event IDs

Installed via `security/tasks/sysmon.yml` using Olaf Hartong's
[sysmon-modular](https://github.com/olafhartong/sysmon-modular) config. Ships to
`logs-windows.sysmon_operational-*`. Channel sized to 1 GB.

| EID | Name | Catches |
|-----|------|---------|
| 1 | ProcessCreate | Every new process — full cmdline, parent, hash, image-loaded user · MITRE T1059 etc. |
| 2 | FileCreateTime | File-create-time changes (timestomping) |
| 3 | NetworkConnect | Outbound network connection — by process |
| 4 | SysmonStateChange | Sysmon service state change — tampering signal |
| 5 | ProcessTerminate | Process exit |
| 6 | DriverLoad | Driver load — kernel-mode persistence / BYOVD signal |
| 7 | ImageLoad | DLL load — DLL-hijack signal |
| 8 | CreateRemoteThread | `CreateRemoteThread` API — process injection |
| 9 | RawAccessRead | Raw disk read — credential-dump / hidden-file access |
| 10 | ProcessAccess | One process opening a handle on another — `lsass.exe` access |
| 11 | FileCreate | File create / overwrite — drops, ransomware |
| 12 | RegistryEvent (key) | Registry key create / delete |
| 13 | RegistryEvent (value) | Registry value set — persistence (Run keys, Services) |
| 14 | RegistryEvent (rename) | Registry key rename |
| 15 | FileCreateStreamHash | Alternate Data Stream creation — phishing-attachment-via-NTFS-ADS |
| 17 | PipeEvent (create) | Named-pipe creation — common in C2 / privesc |
| 18 | PipeEvent (connect) | Named-pipe connection |
| 19-21 | WmiEvent | WMI filter / consumer / binding — persistence |
| 22 | DnsQuery | DNS query by process — host-level DNS telemetry |
| 23 | FileDelete | File deletion — anti-forensics |
| 24 | ClipboardChange | Clipboard write |
| 25 | ProcessTampering | Process image tampering — process hollowing / doppelganging |
| 26 | FileDeleteDetected | File delete detected (logged-only mode) |

---

## 7 · Elastic Defend

Kernel-level EDR via Fleet integration. **DETECT mode only** — never blocks; CADRE's
purpose is telemetry capture, blocking the attack defeats the workflow.

| Index | Catches |
|-------|---------|
| `logs-endpoint.events.process-*` | All process events (kernel-level, complements Sysmon EID 1) |
| `logs-endpoint.events.file-*` | All file events |
| `logs-endpoint.events.network-*` | All network events |
| `logs-endpoint.events.registry-*` | All registry events |
| `logs-endpoint.events.library-*` | Library load events |
| `logs-endpoint.alerts-*` | EDR alerts (malware, ransomware, memory protection, behavior protection — detect signals only) |

Detection policy in the Fleet integration (set in elk-fleet playbook):

```yaml
windows:
  malware:             { mode: detect }
  ransomware:          { mode: detect }
  memory_protection:   { mode: detect }
  behavior_protection: { mode: detect }
linux:
  malware:             { mode: detect }
  behavior_protection: { mode: detect }
```

---

## 8 · Linux auditd Rules

Configured via `07-linux-config.yml` (auditd rules imported from spec in
[`monitoring-dfir-specifications.md`](internal/monitoring-dfir-specifications.md) §2.6
— *internal-only spec, gitignored*; same content also lives in
[`architecture.md`](architecture.md) Linux Telemetry Baseline). Rules drop into
`/etc/audit/rules.d/cadre.rules`, ≥45 rules total, finalized with `-e 2` (immutable
until reboot).

All auditd events ship to `logs-auditd.log-*` via Elastic Agent's `auditd` integration.
Group by `auditd.log.key`.

| Key | Rule shape | Catches |
|-----|------------|---------|
| `proc_exec` | `-a always,exit -S execve` | Every process execution (Linux 4688 / Sysmon EID 1 equivalent) with full argv |
| `cred_access` | `-w /etc/shadow -p rwa` etc. | Read/write/attr of `/etc/shadow`, `gshadow`, `passwd`, `group`, `sudoers`, `sudoers.d/` |
| `kerberos_config` | `-w /etc/krb5.conf -p wa` | Kerberos client config tampering — KDC redirection / realm hijack |
| `keytab_access` | `-w /etc/krb5.keytab -p rwa` | Read of host keytab — **silver / golden ticket precursor** |
| `mssql_keytab` | `-w /var/opt/mssql/secrets/mssql.keytab -p rwa` | Read of MSSQL service-principal keytab — SPN ticket forgery |
| `sssd_config` | `-w /etc/sssd/ -p wa` | SSSD configuration tampering |
| `sssd_cache` | `-w /var/lib/sss/db/ -p rwa` | **Offline domain-credential extraction** — sssd cache decryptable with master key |
| `sssd_secrets` | `-w /var/lib/sss/secrets/ -p rwa` | SSSD secret-store access |
| `realmd_exec` | `-w /usr/sbin/realm -p x` / `adcli -p x` | `realm join` / `realm leave` — domain re-join to attacker DC |
| `ssh_config` | `-w /etc/ssh/sshd_config -p wa` | SSH config tampering |
| `ssh_keys` | `-w /root/.ssh/ -p rwa` | Root SSH key access |
| `home_dir_writes` | `-w /home/ -p wa` | Catches `authorized_keys` drops in user homes |
| `pam_config` | `-w /etc/pam.d/ -p wa` | **Backdoor PAM module install** |
| `nss_config` | `-w /etc/nsswitch.conf -p wa` | nsswitch hijack (DNS-free MITM) |
| `nfs_config` | `-w /etc/exports -p wa` / `idmapd.conf` | NFS export changes — backdoor export, anon access |
| `nfs_exec` | `-w /sbin/exportfs -p x` | `exportfs` invocation |
| `mount_syscall` | `-S mount` | Every mount syscall — captures `sec=krb5p` mounts |
| `podman_socket` | `-w /var/run/podman/podman.sock -p rwa` | Container API access |
| `container_config` | `-w /etc/containers/ -p wa` | Container engine config changes |
| `podman_exec` | `-w /usr/bin/podman -p x` | `podman` invocations |
| `runc_exec` | `-w /usr/bin/runc -p x` | `runc` invocations — lower-level container runtime |
| `container_escape` | `-S setns` / `-S unshare` / `-S pivot_root` | **Container-escape syscalls** — namespace traversal |
| `preload_hijack` | `-w /etc/ld.so.preload -p wa` / `ld.so.conf.d/` | LD_PRELOAD rootkit install |
| `kernel_module` | `-S init_module` / `finit_module` / `delete_module` | Kernel module load / unload — **rootkit detection** |
| `suid_change` | `-S chmod -F a1&04000` etc. | SUID / SGID bit changes — GTFOBins persistence |
| `persistence_cron` | `-w /etc/cron.d/`, `cron.daily/`, `cron.hourly/`, `/var/spool/cron/` | New cron entries |
| `persistence_systemd` | `-w /etc/systemd/system/` / `/lib/systemd/system/` | New systemd unit |
| `persistence_profile` | `-w /etc/profile.d/` / `/etc/bash.bashrc` | Shell-init persistence |

Default rotation: 200 MB × 20 logs = 4 GB total. Adjusted in `/etc/audit/auditd.conf`.

---

## 9 · MSSQL Server Audit (Linux)

Configured via `mssql-conf` + T-SQL on linux01. Audit object `CADRE_Audit` writes
`.sqlaudit` binary files to `/var/opt/mssql/audit/` (256 MB rotation). Decoded by
Elastic Agent's `mssql` integration → `logs-mssql.audit-*`.

| Audit group | Catches |
|-------------|---------|
| `FAILED_LOGIN_GROUP` | Brute-force / password spray against MSSQL |
| `SUCCESSFUL_LOGIN_GROUP` | All successful logins (sa, AD-mapped, app accounts) |
| `SERVER_ROLE_MEMBER_CHANGE_GROUP` | `sysadmin` / `securityadmin` / `dbcreator` etc. membership changes |
| `DATABASE_ROLE_MEMBER_CHANGE_GROUP` | `db_owner` / `db_securityadmin` etc. changes |
| `SERVER_PERMISSION_CHANGE_GROUP` | GRANT / REVOKE at server scope |
| `DATABASE_PERMISSION_CHANGE_GROUP` | GRANT / REVOKE at database scope |
| `SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP` | Object-level GRANT / REVOKE |
| `BACKUP_RESTORE_GROUP` | BACKUP DATABASE / RESTORE — data-exfil signal |
| `DBCC_GROUP` | DBCC invocations — diagnostic + tampering |
| `SERVER_PRINCIPAL_IMPERSONATION_GROUP` | `EXECUTE AS LOGIN = …` — **MSSQL impersonation chain** |

Standalone MSSQL **errorlog** (`/var/opt/mssql/log/errorlog`) → `logs-mssql.errorlog-*`
catches connection errors, xp_cmdshell hits, CLR loads, login failures.

---

## 10 · SSSD Debug Logs

`debug_level = 5` (high verbosity) configured in `/etc/sssd/conf.d/99-cadre-debug.conf`
for `[sssd]`, `[domain/cadre.local]`, `[pam]`. Logs at `/var/log/sssd/*.log` shipped to
`logs-sssd-*` via Elastic Agent's `custom_logs` integration (dataset `sssd.log`).

| File | Catches |
|------|---------|
| `sssd_cadre.local.log` | Domain-side activity — LDAP queries, AD lookups, Kerberos refresh |
| `sssd_pam.log` | PAM auth flow — what `pam_sss.so` saw, why it allowed / denied |
| `krb5_child.log` | Kerberos child process — every `kinit`, every TGT request, ticket cache state |
| `ldap_child.log` | LDAP child — anonymous binds, simple binds, sasl binds |

---

## 11 · Podman Events

`podman events --format=json` streamed by `podman-events-log.service` systemd unit to
`/var/log/podman-events.log`. Shipped to `logs-podman-*` via Elastic Agent's
`custom_logs` integration (dataset `podman.events`).

| event.action | Catches |
|--------------|---------|
| `create` | Container created — including image name, mounts, privileges |
| `start` | Container started |
| `init` | Initial process launched |
| `exec` | `podman exec` invoked on a running container — **shell-into-container signal** |
| `attach` | `podman attach` |
| `kill` | Container forcefully killed |
| `die` | Container exited |
| `mount` | Volume mount |
| `pull` | Image pulled — supply-chain signal |
| `import` / `load` | Image imported from tarball |

Watch for `--privileged`, `--pid=host`, bind mounts to `/`, `/proc`, `/var/run/docker.sock`
in the JSON payload.

---

## 12 · osquery Scheduled Pack (Deferred — Plan 0.5)

**Not currently deployed.** The Fleet `osquery_manager` integration was removed from
the CADRE-All policy — the stock Elastic policy blocks osqueryd enrollment. A fix
is tracked for Plan 0.5.

Once resolved, the pack runs on linux01 and results ship to `logs-osquery_manager.result-*`:

| Query | Interval | Catches |
|-------|----------|---------|
| `SELECT * FROM suid_bin` | 5 min | New SUID binary appears (diff vs baseline) |
| `SELECT pid, name, path, cmdline, uid, parent FROM processes WHERE on_disk = 0` | 5 min | **In-memory exec** (process image deleted but running) — fileless malware |
| `SELECT * FROM listening_ports WHERE address NOT IN ('127.0.0.1','::1')` | 5 min | New network-listening service |
| `SELECT * FROM kernel_modules` | 5 min | Loaded kernel modules (rootkit diff) |
| `SELECT * FROM users WHERE shell NOT IN ('usr/sbin/nologin','bin/false')` | 5 min | Login-capable user accounts |
| `SELECT * FROM authorized_keys` | 5 min | Per-user authorized_keys drops |
| `SELECT * FROM deb_packages` | 30 min | Installed apt packages (supply chain) |
| `SELECT * FROM last WHERE time > (strftime('%s','now') - 1800)` | 30 min | Recent logins |

---

## 13 · Zeek Protocol Logs

Monitor VM, promiscuous NIC sees all vmnet2 traffic. Zeek emits JSON logs at
`/opt/zeek/logs/current/`, shipped to `logs-zeek.*-*` per protocol.

| Log | Protocol | Key fields |
|-----|----------|------------|
| `conn.log` | All TCP/UDP/ICMP | `id.orig_h`, `id.resp_h`, `id.resp_p`, `service`, `duration`, `orig_bytes`, `resp_bytes` |
| `dns.log` | DNS | `query`, `qtype_name`, `answers`, `rcode_name` |
| `http.log` | HTTP | `host`, `uri`, `method`, `user_agent`, `status_code`, `referrer` |
| `smb_cmd.log` | SMB | `command`, `status`, `rtt` |
| `smb_files.log` | SMB | File read/write on a share |
| `smb_mapping.log` | SMB | Share enumeration / mapping |
| `kerberos.log` | Kerberos | `client`, `service`, `request_type` (AS/TGS), `success`, `error.msg` (`KDC_ERR_ETYPE_NOSUPP` on a TGS = **Kerberoasting signal** — KDC rejecting the encryption downgrade) |
| `ssl.log` | TLS | `version`, `cipher`, `server_name` (SNI), `subject`, `issuer` |
| `x509.log` | X.509 | Certificate details — paired with `ssl.log` |
| `dhcp.log` | DHCP | Lease, MAC ↔ IP |
| `ntp.log` | NTP | NTP request/response |
| `ftp.log` | FTP | Commands, credentials in clear |
| `ssh.log` | SSH | `client`, `server`, `auth_success`, `auth_attempts` |
| `notice.log` | Zeek alerts | Built-in Zeek detections (scan, weak SSL, etc.) |
| `weird.log` | Anomaly | Protocol anomalies — possible evasion |

---

## 14 · Suricata

Same monitor VM, parallel to Zeek. Ruleset: Emerging Threats Open. Alerts at
`/var/log/suricata/eve.json` → `logs-suricata-*`.

| event_type | Catches |
|------------|---------|
| `alert` | IDS rule fired (sid + signature + classification) |
| `flow` | Flow record (similar to Zeek conn.log) |
| `http` | HTTP request/response |
| `dns` | DNS |
| `tls` | TLS handshake |
| `fileinfo` | File transferred (when ruleset has file extraction) |
| `anomaly` | Protocol anomaly |

Useful rule categories already in ET Open: `ET HUNTING`, `ET INFO`, `ET POLICY`,
`ET EXPLOIT`, `ET MALWARE`, `ET WEB_CLIENT`.

---

## 15 · Arkime / tcpdump / SiLK

Local to monitor VM — these do not ship to central Elastic; they are queried in place
or pulled into evidence bundles on demand.

| Tool | Storage | Use |
|------|---------|-----|
| **Arkime** | local Elasticsearch on monitor + PCAP at `/opt/arkime/raw/` | Searchable web UI at `https://192.168.77.55:8005` — Wireshark-in-browser, session metadata + full packet decode |
| **tcpdump** | `/opt/pcap/manual/capture-*.pcap` | On-demand manual capture — raw evidence preservation |
| **SiLK** | on-demand, fed from tcpdump PCAPs | Netflow-style aggregation — `rwfilter`, `rwcount`, `rwstats` for top talkers / port-scan analysis |

---

## 16 · Cloud — Entra / Azure / M365

Pulled every 5 minutes by `docs/internal/tools/cloud-ingester/cloud_ingester.py` (systemd timer on
elk VM) using Microsoft Graph + Azure ARM APIs. Plan 11.

| Source | API | Index | Catches |
|--------|-----|-------|---------|
| Entra Sign-in Logs | Graph `auditLogs/signIns` | `logs-entra.signin-*` | All interactive + non-interactive sign-ins, MFA challenges, CA results, risk levels |
| Entra Audit Logs | Graph `auditLogs/directoryAudits` | `logs-entra.audit-*` | Directory changes — user / group / app / role updates |
| Entra PIM Events | Graph `roleManagement/directory/roleAssignmentScheduleInstances` | `logs-entra.pim-*` | PIM activation / approval / extension |
| M365 Unified Audit Log | Office 365 Management Activity API | `logs-m365.ual-*` | Cross-workload audit (Exchange, SharePoint, OneDrive, Teams, AAD) |
| Azure Activity Log | ARM `Microsoft.Insights/eventtypes/management/values` | `logs-azure.activity-*` | Control-plane operations — VM start/stop, RG create, RBAC assignment |
| Azure RBAC Changes | ARM `Microsoft.Authorization/roleAssignments` | `logs-azure.rbac-*` | Role assignment / removal — Owner / Contributor changes |

**Offline mode:** `docs/internal/tools/cloud-ingester/fixtures/` holds recorded Graph + ARM responses
that replay without a tenant. Same indices, same fields.

---

## 17 · Velociraptor Artifacts

On-demand forensic collection from Windows + Linux clients. Live, point-in-time —
not streamed. Triggered via VR web GUI, API, or MCP endpoint (Plan 7 agentic).

### Built-in artifacts heavily used

| Artifact | Platform | Catches |
|----------|----------|---------|
| `Windows.System.Pslist` | Windows | Live process list |
| `Windows.EventLogs.EvtxHunter` | Windows | EVTX query + extraction |
| `Windows.Forensics.Prefetch` | Windows | Prefetch parsing — execution evidence |
| `Windows.Forensics.Amcache` | Windows | Amcache — installed app evidence |
| `Windows.Forensics.Usn` | Windows | USN journal — recent file activity |
| `Windows.NTFS.MFT` | Windows | MFT extraction |
| `Windows.Registry.NTUser` | Windows | Per-user NTUSER.DAT extraction |
| `Windows.Registry.Sam` | Windows | SAM hive extraction |
| `Windows.Memory.Acquisition` | Windows | WinPMEM memory dump |
| `Linux.Sys.Pslist` | Linux | Live process list |
| `Linux.Sys.BashHistory` | Linux | Per-user `.bash_history` |
| `Linux.Sys.LastUserLogin` | Linux | wtmp / btmp parsing |
| `Linux.Sys.AuditLogs` | Linux | Pull `/var/log/audit/audit.log*` |
| `Linux.Network.NetstatEnriched` | Linux | Listening + established sockets enriched with proc |
| `Linux.Detection.IncludeRootkitKeywords` | Linux | String-based rootkit-keyword scan |

### Custom CADRE artifacts

| Artifact | Catches |
|----------|---------|
| `CADRE.Linux.KeytabFingerprints` | Run `klist -ke` against every `*.keytab` on linux01 → SPN + KVNO + enctype fingerprint inventory (krb5.keytab + mssql.keytab) |
| `CADRE.Linux.PodmanInventory` | Image list + running containers + mount table + privileges + namespaces |
| `CADRE.Linux.SSSDCache` | `sssd-cache.db` metadata extraction (without decrypting secrets) |
| `CADRE.Windows.AdcsTemplates` | Dump all ADCS template ACLs + flags (ESC-template inventory) |
| `CADRE.Windows.SccmPolicy` | NAA policy + client-push config + boot-image variables |

### Pre-built hunts (ship with the velociraptor extension)

| Hunt | Artifacts | After |
|------|-----------|-------|
| `cadre-process-tree` | Pslist + TaskScheduler + Services | Any process-based attack |
| `cadre-credential-access` | AMCache + Prefetch + NTUser registry | Credential dumping |
| `cadre-network-state` | Netstat + DNS cache + ARP | Lateral movement |
| `cadre-fs-timeline` | MFT + USN | Persistence / file drops |
| `cadre-registry-snapshot` | SAM + SECURITY + SYSTEM hives | Privilege escalation |
| `cadre-event-logs` | All `.evtx` exported | Hayabusa input |
| `cadre-adcs-snapshot` | `CADRE.Windows.AdcsTemplates` + CA database | ADCS attacks |
| `cadre-sccm-snapshot` | `CADRE.Windows.SccmPolicy` + SCCM WMI | SCCM attacks |
| `cadre-linux-triage` | `Linux.Sys.AuditLogs` + `BashHistory` + `LastUserLogin` + `NetstatEnriched` + `IncludeRootkitKeywords` + `CADRE.Linux.KeytabFingerprints` + `CADRE.Linux.PodmanInventory` + `CADRE.Linux.SSSDCache` | Linux attacks |
| `cadre-full-breach` | Union of all above | Comprehensive |

---

## 18 · Elastic Indices — Cheat Sheet

| Index pattern | Source | Default policy |
|---------------|--------|----------------|
| `logs-system.security-*` | Windows audit | CADRE-All |
| `logs-windows.sysmon_operational-*` | Sysmon | CADRE-All |
| `logs-windows.powershell-*` | PS 4103/4104 | CADRE-All |
| `logs-windows.<channel>-*` | per-channel ops | CADRE-All |
| `logs-endpoint.events.*` | Elastic Defend events | CADRE-All |
| `logs-endpoint.alerts-*` | Elastic Defend alerts | CADRE-All |
| `logs-auditd.log-*` | Linux auditd | CADRE-Linux |
| `logs-mssql.audit-*`, `logs-mssql.errorlog-*` | MSSQL on linux01 | CADRE-Linux |
| `logs-sssd-*` | SSSD debug | CADRE-Linux |
| `logs-podman-*` | podman events | CADRE-Linux |
| `logs-osquery_manager.result-*` | osquery scheduled pack (SUID + recent-login) | CADRE-Linux |
| `logs-system.auth-*`, `logs-system.syslog-*` | rsyslog | CADRE-Linux |
| `logs-zeek.*-*` | Zeek protocol logs | CADRE-Monitor |
| `logs-suricata-*` | Suricata alerts | CADRE-Monitor |
| `logs-entra.*` | Entra ID | cloud-ingester (Plan 11) |
| `logs-azure.*` | Azure ARM | cloud-ingester (Plan 11) |
| `logs-m365.*` | M365 UAL | cloud-ingester (Plan 11) |
| `logs-ti_*` | Threat Intel feeds | Fleet (AbuseCh + OTX integrations) |
| `.alerts-security.alerts-*` | Elastic Security detection alerts | Detection engine |

---

## 19 · Sample Queries (KQL — Discover + Detection Rules)

Pin these in Kibana saved searches as starting points.

```kql
# Kerberoasting — AES TGS request (WT#002; RC4 non-viable on Server 2025)
event.code:4769 AND winlog.event_data.TicketEncryptionType:"0x12"

# AS-REP roasting — pre-auth disabled accounts
event.code:4768 AND winlog.event_data.PreAuthType:"0"

# DCSync — directory replication right access by non-DC
event.code:4662 AND winlog.event_data.Properties:"*1131f6aa-9c07-11d1-f79f-00c04fc2dcd2*"

# Process with command-line containing common LOLBins
event.code:4688 AND process.command_line:(*mimikatz* OR *rubeus* OR *certify* OR *certipy*)

# AMSI raw payload visibility (pre-deobfuscation)
event.dataset:"windows.amsi" AND event.code:(1101 OR 1102)

# Linux keytab read by non-root
data_stream.dataset:"auditd.log" AND auditd.log.key:("mssql_keytab" OR "keytab_access") AND user.id:!"0"

# Container escape attempt
data_stream.dataset:"auditd.log" AND auditd.log.key:"container_escape"

# Kernel module load
data_stream.dataset:"auditd.log" AND auditd.log.key:"kernel_module"

# MSSQL failed-login burst on linux01 (L09)
data_stream.dataset:"microsoft_sqlserver.log" AND message:"Login failed"

# Entra sign-in with risk
data_stream.dataset:"entra.signin" AND azure.signinlogs.properties.risk_level_during_signin:("high" OR "medium")

# Azure RBAC Owner / Contributor assignment
data_stream.dataset:"azure.activity" AND azure.activitylogs.operation_name:"MICROSOFT.AUTHORIZATION/ROLEASSIGNMENTS/WRITE"
```

---

## 20 · Provenance

This document mirrors the configuration applied by:

- `ansible/roles/security/files/cadre-dfir-monitoring.ps1` (Windows audit, PS, NTLM, channels, log sizes) — deployed via `11-security-baseline.yml`
- `ansible/roles/security/tasks/sysmon.yml` (Sysmon install with sysmon-modular config) — deployed via `11-security-baseline.yml`
- `07-linux-config.yml` (Linux auditd rules, SSSD debug, MSSQL audit, podman-events-log)
- `12-elk-fleet.yml` (Fleet policies CADRE-All + CADRE-Monitor, integrations, detection rules, dashboard)
- `13-net-monitor.yml` (Zeek + Suricata + Arkime + tcpdump + SiLK)
- `14-velociraptor.yml` (server + clients + 10 hunts + 5 custom CADRE artifacts + MCP)
- `docs/internal/tools/cloud-ingester/` (Plan 11 Entra + Azure + M365 ingest)

If any of those change, update this reference in the same commit. The leak-audit and
maintenance checklists for documentation discipline are covered in
[`DOCS.md`](../DOCS.md).

---

*Replaces the legacy `ADOPT_DFIR_Logging_Reference.xlsx` (now deletable). Markdown is
the source of truth — diff-friendly, version-controlled, GitHub-renderable, searchable.*
