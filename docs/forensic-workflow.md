# Attack → Telemetry → Investigation → Export → Reset

**CADRE** (Cloud · Agentic · DFIR · Red-team · Environment) is an instrumented hybrid identity attack lab. Every attack against the substrate produces ground-truth telemetry across multiple data sources. You investigate that telemetry — manually or via the agentic pipeline — then export a structured evidence bundle and reset to a clean state. Repeat with the next attack.

> This is the core differentiator: not just a vulnerable lab, but a **telemetry reference library generator** that builds your forensic knowledge attack by attack.

---

## The Cycle

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                    │
│   1. REVERT to clean baseline (vmrun snapshot)                     │
│        ↓                                                          │
│   2. RUN ATTACK from attack VM (walkthrough #002-062, cert-aligned)        │
│        ↓                                                          │
│   3. OBSERVE telemetry land in real-time:                          │
│      • Windows Security Events (4769, 4688, 4662, 5145...)        │
│      • Sysmon (process, network, file, registry, DNS)             │
│      • PowerShell Script Block / Module logs                      │
│      • Elastic Defend EDR alerts (detect mode)                    │
│      • Zeek protocol logs (kerberos, smb, dns, http, ssl)         │
│      • Suricata IDS alerts (ET Open ruleset)                      │
│      • Arkime full PCAP (searchable web UI)                       │
│      • Velociraptor live artifacts                                 │
│      • Entra/Azure cloud logs (Plan 11)                           │
│        ↓                                                          │
│   4. INVESTIGATE — choose your path:                               │
│      a) Red-team operator: "what does my attack look like?"       │
│      b) DFIR practitioner: "reconstruct the kill chain"           │
│      c) Agentic pipeline: "AI-assisted multi-agent investigation" │
│        ↓                                                          │
│   5. EXPORT — structured evidence bundle (DFIR-Nexus schema)       │
│        ↓                                                          │
│   6. RESET — revert all VMs to clean baseline                      │
│        ↓                                                          │
│   7. REPEAT — next attack, next cert technique, growing library    │
│                                                                    │
└──────────────────────────────────────────────────────────────────┘
```

Each iteration builds your personal **attack telemetry reference library** — a structured archive of what each technique looks like across every data source. After 60 iterations, you have forensic reference material for 8 certification paths.

---

## Architecture — Data Flow

```
┌───────────────────────────────────────────────────────────────────────────┐
│                         CADRE Substrate                                     │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐     │
  │  │  Attack VM — attacker workstation (user-managed Kali)                │     │
  │  │  Runs: impacket, certipy, BloodHound, SharpSCCM, Azure attack tools      │     │
  │  └──────────────┬───────────────────────────────────────────────────┘     │
│                 │ attacks                                                 │
│                 ▼                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐     │
│  │  5x Windows Server 2025 + linux01 — target substrate              │     │
│  │  Generates:                                                       │     │
│  │  • Windows Event Logs (Security, System, Application)             │     │
│  │  • Sysmon (EID 1-25, Olaf Hartong sysmon-modular config)         │     │
│  │  • PowerShell Script Block + Module + Transcription               │     │
│  │  • Elastic Defend alerts (kernel-level, detect mode)              │     │
│  │  • Filesystem artifacts (MFT, Prefetch, Amcache, Registry)        │     │
│  │  • Linux audit (auditd ≥45 rules, MSSQL audit, SSSD, podman,      │     │
  │    osquery — active on CADRE-Linux policy)                          │     │
│  └──────────────────────────────────────────────────────────────────┘     │
│                 │ collected by                                            │
│                 ▼                                                         │
│  ┌────────────────────────────┐ ┌────────────────────────┐ ┌──────────┐  │
│  │  ELK (.50)                 │ │  Monitor (.55)          │ │  VR (.51)│  │
│  │  Elasticsearch 9.x         │ │  Zeek (20+ protocols)   │ │  Veloci- │  │
│  │  Kibana                    │ │  Suricata (ET Open)     │ │  raptor  │  │
│  │  Fleet Server              │ │  Arkime (full PCAP)     │ │  server  │  │
│  │  Elastic Agent on all VMs  │ │  tcpdump (rotation)     │ │          │  │
│  │                            │ │  SiLK (offline flows)   │ │          │  │
│  │  Indices:                  │ │  Promiscuous NIC        │ │  Clients │  │
│  │  logs-system.security-*   │ │                         │ │  on all  │  │
│  │  logs-windows.sysmon-*     │ │  Indices (via Fleet):   │ │  Windows │  │
│  │  logs-windows.powershell-* │ │  logs-zeek.*-*            │ │  + Linux │  │
│  │  logs-endpoint.events-*    │ │  logs-suricata-*        │ │          │  │
│  │  logs-endpoint.alerts-*    │ │                         │ │  Hunts:  │  │
│  │  logs-entra.signin-*       │ │  Arkime local ES:       │ │  process │  │
│  │  logs-entra.audit-*        │ │  PCAP session index     │ │  creds   │  │
│  │  logs-azure.activity-*     │ │                         │ │  network │  │
│  └────────────────────────────┘ └────────────────────────┘ │  FS/MFT  │  │
│                                                             │  registry│  │
│                                                             │  EVTX    │  │
│                                                             └──────────┘  │
└───────────────────────────────────────────────────────────────────────────┘
```

---

## Data Sources

| Source | What It Captures | Where It Lands |
|--------|-----------------|----------------|
| **Windows Security Events** | 4688 (process, with cmdline), 4768/4769 (Kerberos), 4624 (logon), 4662 (DS access), 5145 (share), 4720 (user creation), 49 subcategories — all configured by `ansible/roles/security/files/cadre-dfir-monitoring.ps1` | `logs-system.security-*` |
| **Sysmon** | EID 1 (process), 3 (network), 7 (module), 8 (RemoteThread), 10 (ProcessAccess), 11 (FileCreate), 12-14 (Registry), 15 (FileStream), 22 (DNS), 25 (ProcessTampering) | `logs-windows.sysmon_operational-*` |
| **PowerShell** | Script Block Logging, Module Logging (all modules), Transcription with InvocationHeader | `logs-windows.powershell-*` |
| **Elastic Defend** | Kernel-level process, file, registry, network events. Detect mode — alerts without blocking. | `logs-endpoint.events-*`, `logs-endpoint.alerts-*` |
| **Zeek** | conn, dns, http, smb, smb_files, smb_mapping, kerberos, ssl, dhcp, ntp, ftp, ssh, snmp, syslog, weird, notice, x509 | `logs-zeek.*-*` |
| **Suricata** | ET Open ruleset — network threat detection alerts | `logs-suricata-*` |
| **Arkime** | Full PCAP capture + web UI. Session metadata indexed in local ES. Wireshark-style packet inspection in browser. | Arkime viewer at `https://192.168.77.55:8005` |
| **tcpdump** | Raw hourly PCAP rotation (1GB max, 24h retention) for offline analysis | `/opt/pcap/` on monitor VM |
| **SiLK** | CERT/SEI flow analysis — `rwfilter`, `rwcount`, `rwstats` on exported PCAPs | On-demand during export |
| **Velociraptor** | Live filesystem, process list, registry, MFT, USN, prefetch, amcache, EVTX export, memory (WinPMEM) | VR server at `https://192.168.77.51:8889` |
| **Linux auditd** (linux01, ≥45 immutable rules) | execve, /etc/{shadow,passwd,sudoers}, krb5/mssql keytab reads, SSSD cache + secrets, realmd join/leave, mount syscall, container escape syscalls (`setns`/`unshare`/`pivot_root`), kernel modules, SUID changes, PAM/NSS hijack, cron + systemd persistence | `logs-auditd.log-*` |
| **MSSQL Linux audit** | Failed/successful logins, role changes, xp_cmdshell, impersonation, backup/restore (server audit specification) | `logs-mssql.audit-*` |
| **SSSD debug** (linux01) | AD authentication chain, Kerberos child errors, PAM stack | `logs-sssd-*` |
| **Podman events** (linux01) | Container create/start/exec, privileged flag, `--pid=host`, bind mounts | `logs-podman-*` |
| **osquery scheduled pack** (linux01) *(active on CADRE-Linux policy)* | SUID inventory diff, listening ports, kernel modules, authorized_keys, in-memory exec | `logs-osquery_manager.result-*` |
| **Entra/Azure** (Plan 11) | Sign-in logs, audit logs, PIM events, Azure Activity, RBAC changes | `logs-entra.*`, `logs-azure.*` |

---

## Three Investigation Paths

### Path A — Red-Team Operator (telemetry literacy)

You ran the attack. Now learn what it looks like to a defender.

```
After running Kerberoasting from attack VM:
  → Kibana Discover: search logs-system.security-* for event.code:4769
    See: TicketEncryptionType=0x17 (RC4), ServiceName=HTTP/cadre-portal
  → Kibana Discover: search logs-zeek.*-* for event.dataset:zeek.kerberos
    See: request_type=TGS, cipher=rc4-hmac
  → Suricata: check logs-suricata-* for Kerberoast rule triggers
  → Arkime: filter sessions by "protocols == kerberos"
    Click through → see raw TGS-REQ/TGS-REP packets
  → Velociraptor: browse dc01 → Windows.EventLogs.Security
    See: same 4769 events with full context

Outcome: you now know exactly which data sources catch Kerberoasting,
what fields to query, and what artifacts a defender would correlate.
```

### Path B — DFIR Practitioner (forensic methodology)

Someone attacked the lab. Reconstruct the incident from telemetry alone.

```
After an attack runs (you may not know what it was):
  → Velociraptor: trigger "cadre-full-breach" hunt → all 6 clients respond
    Collect: process list, network state, registry SAM, prefetch, MFT, EVTX
  → Hayabusa: run against exported EVTX → CSV timeline of all alerts
  → Plaso/Timesketch: build super-timeline from EVTX + MFT + prefetch
  → Kibana: correlate Sysmon process tree with Zeek network connections
  → Arkime: deep-dive into specific suspicious sessions (full packet decode)
  → PEAK hypothesis: "attacker used credential access technique"
    Test via: VQL query for process accessing lsass.exe + 4769 with RC4

Outcome: practice forensic methodology (DFIR) against ground-truth scenarios.
```

### Path C — Agentic Investigator (AI-assisted, Plan 7)

The LangGraph multi-agent pipeline investigates the same evidence autonomously.

```
After an attack runs:
  → Plan 2 exporter produces DFIR-Nexus-compatible evidence bundle
  → Plan 7 pipeline ingests the bundle:
    ├── Timeline agent (Hayabusa CSV + Windows Events)
    ├── Endpoint agent (Velociraptor — natural-language queries)
    ├── Network agent (Zeek + Suricata + Arkime sessions)
    ├── Alert agent (Elastic Defend alerts — clusters related alerts)
    ├── Cloud agent (Entra sign-in + audit logs)
    └── Synthesis agent (cross-correlates all findings)
  → Synthesis writes draft finding to DFIR-Nexus via record_finding
  → Confidence gate: high confidence → auto-approve; low → human gate
  → Multi-LLM router picks model (Claude / OpenCode / Codex / CrofAI)
  → Approved finding persisted in case

Outcome: prove AI-assisted investigation works on real telemetry.
```

---

## Evidence Export Structure

After each attack, export produces a structured archive:

```
exports/T002-kerberoasting-2026-05-17T14-00-00Z/
├── 00-manifest.json                    # DFIR-Nexus evidence_register schema
├── 01-attack-info/
│   ├── attack.sh                       # Exact commands executed
│   ├── technique.json                  # MITRE ATT&CK metadata
│   └── notes.md                        # Operator observations
├── 02-windows-events/
│   ├── dc01-security.evtx             # Raw EVTX
│   ├── dc01-sysmon.evtx
│   └── elastic-query-result.json       # Same via Elasticsearch
├── 03-elastic-defend/
│   └── alerts.json                     # EDR alerts
├── 04-zeek/
│   ├── conn.log, dns.log, kerberos.log, smb_files.log, http.log
├── 05-suricata/
│   └── eve.json                        # IDS alerts
├── 06-pcap/
│   ├── arkime-session-export.json
│   └── cadre-20260517-140000.pcap.gz
├── 06b-silk/
│   ├── flows-all.rw, top-talkers.csv, port-scan-analysis.csv
├── 07-velociraptor/
│   ├── process-list.csv, registry-sam.json, prefetch.zip
├── 08-hayabusa/
│   └── hayabusa-timeline.csv
├── 10-cloud/
│   ├── entra-signin.json, entra-audit.json, azure-activity.json
└── 11-summary/
    ├── timeline.csv                    # Merged from all sources
    └── correlation-summary.md
```

Export command:
```bash
python docs/internal/tools/export-attack/export.py --attack T002 --start "2026-05-17T14:00:00Z" --end "2026-05-17T14:05:00Z"
```

---

## Snapshot & Reset

After full deployment (Plan 0 + all extensions), take a snapshot of every VM:

```powershell
python docs/internal/tools/snapshot/snapshot.py take clean-baseline --all
```

Revert after every attack cycle:
```powershell
python docs/internal/tools/snapshot/snapshot.py revert clean-baseline --all
```

### Automated Cycle (Plan 3)

```bash
python docs/internal/tools/snapshot/cycle.py --attack T002-kerberoasting
```

Steps: revert → health-check (Fleet, Zeek, Suricata, VR, DNS) → attack → wait 60s → VR hunt → export → validate against catalog → revert → report pass/fail.

---

## Velociraptor — Pre-Built Hunt Collections

| Hunt | Artifacts | Use After |
|------|-----------|-----------|
| `cadre-process-tree` | Pslist, TaskScheduler, Services | Any process attack |
| `cadre-credential-access` | AMCache, Prefetch, NTUser registry | Credential dumping |
| `cadre-network-state` | Netstat, DNS cache, ARP | Lateral movement |
| `cadre-fs-timeline` | MFT, USN journal | Persistence / file drops |
| `cadre-registry-snapshot` | SAM, SECURITY, SYSTEM hives | Privilege escalation |
| `cadre-event-logs` | All .evtx exported | Input for Hayabusa |
| `cadre-adcs-snapshot` | CA database, templates | ADCS attacks (ESC1-15) |
| `cadre-sccm-snapshot` | SCCM WMI, NAA policy | SCCM attacks |
| `cadre-linux-triage` | Pslist, network, SUID, keytabs | Linux attacks |
| `cadre-full-breach` | All above combined | One-shot comprehensive |

---

## Cloud Telemetry (Plan 11)

When a tenant is configured, `docs/internal/tools/cloud-ingester/` pulls logs every 5 minutes:

| Source | Elastic Index |
|--------|---------------|
| Entra Sign-in Logs | `logs-entra.signin-*` |
| Entra Audit Logs | `logs-entra.audit-*` |
| PIM Events | `logs-entra.pim-*` |
| M365 Unified Audit Log | `logs-m365.ual-*` |
| Azure Activity Log | `logs-azure.activity-*` |
| Azure RBAC Changes | `logs-azure.rbac-*` |

**Offline mode:** Recorded fixtures replay cloud telemetry without a tenant.

---

## Service Access

| Service | URL | Credentials |
|---------|-----|-------------|
| Kibana | `http://192.168.77.50:5601` | `elastic` / auto-generated |
| Elasticsearch | `http://192.168.77.50:9200` | `elastic` / same |
| Arkime Viewer | `https://192.168.77.55:8005` | `admin` / `arkime` |
| Velociraptor | `https://192.168.77.51:8889` | `admin` / `VelociraptorDefault!` |
| VR MCP (Plan 7) | `http://192.168.77.51:8002` | API key |

---

## Summary

CADRE's workflow is a cycle, not a one-shot deployment. Each iteration:
1. Teaches you a new attack technique (8 cert paths, 60 walkthroughs)
2. Shows you what that attack looks like across every telemetry source
3. Lets you investigate — manually (DFIR) or via AI (agentic pipeline)
4. Produces a structured evidence bundle for your reference library
5. Resets cleanly for the next iteration

After 60 iterations you have: a personal attack telemetry library, DFIR tool experience (Velociraptor, Hayabusa, Plaso, KAPE, Volatility), detection rules you wrote from observed artifacts, evidence that AI can investigate the same incidents, and cloud + hybrid identity attack experience. No other open-source lab provides this complete closed loop.
