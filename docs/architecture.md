# CADRE — Architecture

```
CADRE
├── C — Cloud       ── Entra + Azure + Azure attack scenarios + Azure RM
├── A — Agentic     ── LangGraph + DFIR-Nexus + multi-LLM + Velociraptor MCP
├── D — DFIR        ── Elastic SIEM + Velociraptor + Plaso + Hayabusa + Timesketch
├── R — Red-team    ── 60+ red-team attack surfaces · multi-domain AD + cloud
└── E — Environment ── Server 2025 + Linux AD · 7 core VMs + 3 extensions
```

---

## Network Topology

All VMs on VMware Workstation Pro vmnet2 host-only network: `192.168.77.0/24`.

```
vmnet2 host-only · 192.168.77.0/24 · isolated
─────────────────────────────────────────────────────────────────────────────

  On-Prem AD Substrate
  ┌─────────────────────────────────────────────────────────────────────┐
  │                                                                     │
  │  cadre.local (forest root)     child.cadre.local     range.local    │
  │  ├── dc01 (.10)               ├── dc02 (.11)        ├── dc03 (.12) │
  │  │   Server 2025              │   Server 2025       │   Server 2025│
  │  │   ADCS CA (ESC1-15)        │                     │   AES-only   │
  │  │   Cloud Sync agent         │                     │   dMSA       │
  │  │   2c · 4 GB                │   2c · 3 GB         │   2c · 3 GB  │
  │  │                            │                     │              │
│  ├── mbr01 (.22)              │                     ├── mbr02 (.23)│
│  │   Server 2025              │                     │   Server 2025│
│  │   MSSQL + IIS              │  │   SQL + WSUS + VSC + SCCM│
│  │   Unconstrained deleg      │                     │              │
│  │   2c · 4 GB                │                     │   4c · 8 GB  │
  │  │                            │                     │              │
  │  └── linux01 (.40)            │                     │              │
  │      Ubuntu 24.04             │                     │              │
  │      AD-joined (SSSD)         │                     │              │
  │      MSSQL-on-Linux           │                     │              │
  │      NFS-over-Kerberos        │                     │              │
  │      Podman                   │                     │              │
  │      2c · 2 GB                │                     │              │
  └─────────────────────────────────────────────────────────────────────┘

  Telemetry + Ansible Stack
  ┌─────────────────────────────────────────────────────────────────────┐
  │  provisioning (.60)                                                 │
  │  Ubuntu 24.04 · Ansible runner · 2c · 2 GB                         │
  │                                                                     │
  │  Monitor VM (.55) — Zeek + Suricata + Arkime + SiLK (promiscuous)  │
  │  elk VM (.50) — ES + Kibana + Fleet Server + detection rules       │
  │  vr VM (.51) — Velociraptor server + client (self-enrolled)        │
  │                                                                     │
  │  Attack VM — user-managed (Kali or any attack host)                   │
  └─────────────────────────────────────────────────────────────────────┘

  Cloud Plane (External — Microsoft tenant)
  ┌─────────────────────────────────────────────────────────────────────┐
  │  M365 dev tenant (free)              Azure free trial               │
  │  ├── Entra ID (Azure attack scenarios)  ├── Subscription RBAC         │
  │  ├── Cloud Sync target (← dc01)     ├── PIM eligibility            │
  │  ├── SyncJacking + CBA              ├── Cross-tenant B2B           │
  │  └── Golden SAML                    └── Azure Arc → dc01           │
  │                                                                     │
  │  Logs: Graph API → cloud-ingester (elk VM) → Elastic indices        │
  └─────────────────────────────────────────────────────────────────────┘
```

---

## VM Specifications

| VM | OS | IP | vCPU | RAM | Domain | Role |
|----|----|----|------|-----|--------|------|
| dc01 | Server 2025 | .10 | 2 | 4 GB | cadre.local | Forest root DC + ADCS CA + Cloud Sync |
| dc02 | Server 2025 | .11 | 2 | 3 GB | child.cadre.local | Child DC |
| dc03 | Server 2025 | .12 | 2 | 3 GB | range.local | External forest DC (AES-only, dMSA) |
| mbr01 | Server 2025 | .22 | 2 | 4 GB | child.cadre.local | MSSQL + IIS + unconstrained delegation |
| mbr02 | Server 2025 | .23 | 4 | 8 GB | range.local | SQL + WSUS + VSC + SCCM (site CAD) |
| linux01 | Ubuntu 24.04 | .40 | 2 | 2 GB | cadre.local | AD-joined Linux + MSSQL + NFS-krb5 + Podman |
| elk | Ubuntu 24.04 | .50 | 4 | 12 GB | — | Elasticsearch + Kibana + Fleet Server |
| vr | Ubuntu 24.04 | .51 | 2 | 2 GB | — | Velociraptor server + MCP (port 8002) |
| monitor | Ubuntu 24.04 | .55 | 4 | 8 GB | — | Zeek + Suricata + Arkime + tcpdump + SiLK |
| provisioning | Ubuntu 24.04 | .60 | 2 | 2 GB | — | Ansible runner (deploy-only) |

**Total: 26 vCPU, 48 GB RAM, ~150 GB disk.**

---

## Trust Topology

```
cadre.local ◄──── parent-child ────► child.cadre.local
     │
     └──── bidirectional forest trust ────► range.local
```

| Trust | Type | Direction | SID Filtering |
|-------|------|-----------|---------------|
| cadre.local ↔ child.cadre.local | Parent-Child | Bidirectional | Disabled (same forest) |
| cadre.local ↔ range.local | Forest | Bidirectional | Enabled (default) |

---

## Data Flow — Telemetry Pipeline

```
Walkthrough execution → VMs generate artifacts
                            │
               ┌───────────┼──────────────────┐
               ▼           ▼                  ▼
          Host telemetry   Network         Forensic data
          (Elastic Agent)  (monitor NIC)   (Velociraptor)
               │           │                  │
               ▼           ▼                  ▼
          Fleet Server     Zeek/Suricata    VR server (.51)
          (elk .50)        JSON → Fleet     gRPC + TLS
               │           │                  │
               ▼           ▼                  │
          ┌─── Elasticsearch 9.x (elk .50) ─────┐
          │ logs-system.security-*              │
          │ logs-windows.sysmon_operational-*   │
          │ logs-windows.powershell-*           │
          │ logs-endpoint.events-* / alerts-*   │
          │ logs-zeek.*-*                       │
          │ logs-suricata-*                     │
          │ logs-entra.* / logs-azure.* (Plan11)│
          └─────────────────────────────────────┘
               │
               └──────────────┬──────────────────┘
                              ▼
                     Plan 2 Exporter (multi-source query)
                              │
                              ▼
                     Evidence Bundle (DFIR-Nexus)
                              │
                   ┌──────────┼──────────┐
                   ▼          ▼          ▼
               Manual     Detection    Plan 7
               DFIR       engineering  Agentic
               (Journey   (Sigma →     LangGraph
                B)        TOML)        pipeline
```

---

## Windows Telemetry Baseline

All 5 Windows VMs (dc01/dc02/dc03/mbr01/mbr02) are configured by a single script at deploy time:
**`ansible/roles/security/files/cadre-dfir-monitoring.ps1`** — idempotent, pure-telemetry (no hardening).
It is the source of truth for every Windows audit knob CADRE relies on:

| Block | What it does |
|-------|--------------|
| 49 advanced audit subcategories | Success + Failure on Account Logon, Logon/Logoff, Account Mgmt, Detailed Tracking (incl. Process Creation/Termination, DPAPI, Token Adjust), DS Access + Replication (DCShadow visibility), Object Access (File Share, Registry, SAM, ADCS), Policy Change, Privilege Use, System |
| 4688 cmdline | `ProcessCreationIncludeCmdLine_Enabled=1` |
| PowerShell deep visibility | ScriptBlock 4104 + Module 4103 (`ModuleNames=*`) + Transcription with InvocationHeader → `C:\PSTranscripts` |
| NTLM in/out auditing | Events 8001-8004 in `NTLM/Operational` |
| 26 operational channels | Enabled + resized 256 MB: RDP, WinRM, PowerShell/Operational, SMB, TaskScheduler, WMI, DNS-Client, BITS, PrintService, NTLM, CodeIntegrity, AppLocker, ADCS, AMSI, Defender, **plus Server 2025: Kerberos, KDC, LDAP-Client, Security-Mitigations, Credential-Guard** |
| Core log sizes | Security 1 GB, Sysmon 1 GB, System/App/PS 512 MB |
| Policy persistence | `SCENoApplyLegacyAuditPolicy=1` (subcategory policy survives GPO refresh) |

Sysmon (Olaf Hartong's sysmon-modular config) installs separately via `security/tasks/sysmon.yml`
after the script has pre-sized the Sysmon channel.

## Linux Telemetry Baseline (linux01 — AD-joined substrate)

linux01 is a full AD member (SSSD + Kerberos keytab + realmd-joined to cadre.local) running
MSSQL-on-Linux with `network.kerberoskeytabfile`, NFS with `sec=krb5p` exports, and a
privileged Podman container with `--pid=host`. ADOPT had no Linux AD coverage at all —
this is greenfield instrumentation — the first open-source lab to instrument an AD-joined Linux substrate at this depth.

| Layer | Source | Index | Catches |
|-------|--------|-------|---------|
| Kernel auditd (`/etc/audit/rules.d/cadre.rules`, immutable, ≥45 rules) | `/var/log/audit/audit.log` | `logs-auditd.log-*` | execve, keytab reads, sssd cache access, realmd join/leave, mount syscalls, container escape (`setns`/`unshare`/`pivot_root`), kernel modules, SUID changes, cron/systemd persistence, PAM/NSS hijack |
| SSSD debug | `/var/log/sssd/*.log` (`debug_level=5`) | `logs-sssd-*` | AD authentication chain, Kerberos child errors, PAM stack |
| MSSQL Server Audit | `/var/opt/mssql/audit/*.sqlaudit` | `logs-mssql.audit.linux-*` | Failed/successful logins, role changes, impersonation, backup/restore |
| Podman events | `/var/log/podman-events.log` (`podman events --format=json`) | `logs-podman-*` | container lifecycle, privileged/`--pid=host` flags, bind mounts, exec |
| System / auth | `/var/log/auth.log`, `/var/log/syslog` | `logs-system.auth-*`, `logs-system.syslog-*` | sudo, sshd, rpc.gssd (NFS Kerberos GSS context), systemd |
| osquery (`osquery_manager` Fleet integration) | scheduled pack on CADRE-Linux policy | `logs-osquery_manager.result-*` | SUID inventory diff, listening ports, kernel modules, authorized_keys, in-memory exec |
| Velociraptor Linux artifacts | live | VR server | bash history, wtmp/btmp, pslist, netstat, rootkit keywords, podman inventory, SSSD cache, keytab fingerprints |

All Linux telemetry sources are deployed via `07-linux-config.yml`. osquery packs are configured on the CADRE-Linux Fleet policy. See [`dfir-logging-reference.md`](dfir-logging-reference.md) for full provenance.

---

## Full Architecture Diagram

![CADRE Architecture](img/cadre-architecture.png)

Assets:
- [`docs/img/cadre-architecture.png`](img/cadre-architecture.png) — 1920×1080 PNG (rendered, ready to use)
- [`docs/img/cadre-architecture-4k.png`](img/cadre-architecture-4k.png) — 3840×2160 PNG (high-DPI / 4K wallpaper)
- [`docs/img/cadre-architecture.svg`](img/cadre-architecture.svg) — vector source (edit / re-export at any size)
- [`docs/img/README.md`](img/README.md) — wallpaper installation guide (Windows + Linux)

---

## Detection Coverage

| Category | Data Source | Elastic Index |
|----------|-----------|---------------|
| Process creation | Sysmon EID 1 + Windows 4688 | `logs-windows.sysmon_operational-*`, `logs-system.security-*` |
| Network connections | Sysmon EID 3 + Zeek conn.log | `logs-windows.sysmon_operational-*`, `logs-zeek.*-*` |
| Authentication | Kerberos 4768/4769, NTLM 4624 | `logs-system.security-*` |
| Kerberos protocol | Zeek kerberos.log | `logs-zeek.*-*` |
| DNS queries | Sysmon EID 22 + Zeek dns.log | `logs-windows.sysmon_operational-*`, `logs-zeek.*-*` |
| File system | Sysmon EID 11/15 | `logs-windows.sysmon_operational-*` |
| Registry | Sysmon EID 12-14 | `logs-windows.sysmon_operational-*` |
| SMB/shares | Zeek smb.log + Windows 5145 | `logs-zeek.*-*`, `logs-system.security-*` |
| HTTP | Zeek http.log | `logs-zeek.*-*` |
| Threat detection | Suricata ET Open + Elastic Defend | `logs-suricata-*`, `logs-endpoint.alerts-*` |
| Full PCAP | Arkime | Local ES on monitor + viewer at :8005 |
| PowerShell | Script Block + Module | `logs-windows.powershell-*` |
| Cloud identity | Entra Sign-in + Audit (Plan 11) | `logs-entra.*` |
| Azure management | Activity + RBAC (Plan 11) | `logs-azure.*` |

---

## Service Access

| Service | URL | Credentials |
|---------|-----|-------------|
| Kibana | `http://192.168.77.50:5601` | `elastic` / auto-generated |
| Elasticsearch | `http://192.168.77.50:9200` | `elastic` / same |
| Fleet Server | `https://192.168.77.50:8220` | Self-signed TLS |
| Arkime Viewer | `https://192.168.77.55:8005` | `admin` / `arkime` |
| Velociraptor GUI | `https://192.168.77.51:8889` | `admin` / `VelociraptorDefault!` |
| Velociraptor MCP | `http://192.168.77.51:8002` | API key (see deployment.md) |

---

## Internal Mapping

Certification-to-attack coverage comparison is maintained internally (maintainers only). It is kept internal to avoid implying public endorsement or direct equivalency.

---

## Attack Surface Summary

- **AD Primitives:** Kerberoasting (AES), AS-REP, all delegation types, DCSync, Golden/Silver/Diamond Ticket, ACL abuse chains, Shadow Credentials, SPN Jacking, AdminSDHolder, gMSA extraction, dMSA/BadSuccessor
- **ADCS:** ESC1-15 (14/15 practiceable), full template + CA + RPC attack matrix
- **SCCM:** Site CAD on mbr02 — NAA/PXE/push/CRED-2/svc_sccm admin misconfigs
- **MSSQL:** Linked servers (Windows + Linux), CLR, impersonation, xp_cmdshell
- **Linux AD:** SSSD ticket extraction, keytab abuse, NFS-over-Kerberos, Podman container escape
- **Coercion:** DFSCoerce, ShadowCoerce, PetitPotam, PrinterBug
- **Cloud:** Azure attack scenarios, Cloud Sync/SyncJacking, Azure RM (subscription escalation, PIM, multi-tenant, Azure Arc), hybrid chains H1-H4
- **2026 CVEs:** CVE-2026-25177 (SPN Unicode), CVE-2026-20833 (RC4 deprecation), CVE-2025-53779 (BadSuccessor), SyncJacking
