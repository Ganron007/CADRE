# CADRE — Extensions

Extensions are detachable telemetry stacks deployed on dedicated VMs. They provide the **D (DFIR)** pillar of CADRE — without them, attacks produce no captured telemetry.

Extension playbooks are self-contained in `ansible/playbooks/` (files 12-elk-fleet.yml, 13-net-monitor.yml, 14-velociraptor.yml). When you run `cadre.py install -e {name}`, the extension VM is created and its playbook is executed. Extension VMs are **not** part of the core 7-VM `vagrant up` — they are deployed on demand.

```bash
python cadre.py install --install-extension elk-fleet       # Creates elk VM .50 + playbook
python cadre.py install --install-extension net-monitor     # Creates monitor VM .55 + playbook
python cadre.py install --install-extension velociraptor    # Creates vr VM .51 + playbook
```

Deploy all three for full telemetry coverage. Order matters: **elk-fleet first** (Fleet Server must be running before agents enroll).

---

## ELK-Fleet

**VM:** elk (192.168.77.50) · Ubuntu 24.04 · 4 vCPU · 12 GB RAM

Provides the central SIEM: log storage, search, alerting, and agent management for all Windows + Linux VMs in the substrate.

### Components

| Component | Purpose | Access |
|-----------|---------|--------|
| Elasticsearch 9.x | Log storage + search index | `http://192.168.77.50:9200` |
| Kibana 9.x | Search, visualization, dashboards | `http://192.168.77.50:5601` |
| Fleet Server 9.x | Agent enrollment + policy management | `https://192.168.77.50:8220` |
| Elastic Defend | Kernel-level EDR (DETECT mode only — never blocks) | Via Fleet integration |
| GeoIP pipeline | IP geolocation enrichment on all `logs-*` | Auto-configured |
| Threat Intel | AbuseCh + AlienVault OTX indicator feeds | `logs-ti_*` indices |

### Fleet Policies

Two policies separate host and network telemetry:

| Policy | Assigned To | Integrations |
|--------|------------|--------------|
| **CADRE-All** | dc01, dc02, dc03, mbr01, mbr02 | Windows Events, Sysmon, PowerShell, Elastic Defend (detect), System |
| **CADRE-Linux** | linux01 | auditd, osquery (SUID + recent-login packs), MSSQL (errorlog + audit), Sysmon Linux, custom_logs (sssd `/var/log/sssd/*` + podman `/var/log/podman-events.log`), System |
| **CADRE-Monitor** | monitor VM | Zeek, Suricata, System |

The CADRE-Linux policy instruments the full AD-joined substrate (SSSD + Kerberos keytab + MSSQL-on-Linux + NFS-krb5 + Podman). See the Linux Telemetry Baseline section in [`architecture.md`](architecture.md) for the source/index map and the 15 seed detection rules (L01-L15).

### Telemetry Collected

| Data Source | Method | Elastic Index |
|-------------|--------|---------------|
| Windows Security Events (46+ subcats) | Elastic Agent → Fleet | `logs-system.security-*` |
| Sysmon (Olaf Hartong sysmon-modular) | Elastic Agent → Fleet | `logs-windows.sysmon_operational-*` |
| PowerShell Script Block + Module | Elastic Agent → Fleet | `logs-windows.powershell-*` |
| Elastic Defend kernel events | Elastic Agent → Fleet | `logs-endpoint.events-*` |
| Elastic Defend alerts | Elastic Agent → Fleet | `logs-endpoint.alerts-*` |
| Linux auditd (linux01, ≥45 immutable rules) | Elastic Agent → Fleet | `logs-auditd.log-*` |
| MSSQL Linux audit (linux01) | Elastic Agent `mssql` → Fleet | `logs-mssql.audit-*` |
| SSSD debug logs (linux01) | Elastic Agent custom_logs → Fleet | `logs-sssd-*` |
| Podman events (linux01) | Elastic Agent custom_logs → Fleet | `logs-podman-*` |
| osquery scheduled pack (linux01) | Configured on CADRE-Linux Fleet policy | `logs-osquery_manager-*` |
| Zeek protocol logs (via monitor) | Elastic Agent → Fleet | `logs-zeek.*-*` |
| Suricata alerts (via monitor) | Elastic Agent → Fleet | `logs-suricata-*` |
| Entra/Azure cloud logs (Plan 11) | cloud-ingester → Elasticsearch | `logs-entra.*`, `logs-azure.*` |

### Pre-configured Content

| Type | Count | Purpose |
|------|-------|---------|
| Seed detection rules | 7+ | Kerberoast, AS-REP, DCSync, Sysmon suspicious process, ADCS template change, NTLM relay, Zeek Kerberoast |
| Saved searches | 29 | Authentication, process activity, ADCS, lateral movement, cloud |
| Dashboard | 1 | "CADRE Attack Telemetry" — event volume, Kerberos errors, process tree, Zeek map, Suricata alerts |
| Threat Intel feeds | 2 | AbuseCh (URLhaus/MalwareBazaar/ThreatFox) + OTX |

### Credentials

| Service | URL | Login |
|---------|-----|-------|
| Kibana | `http://192.168.77.50:5601` | `elastic` / auto-generated (stored at `/usr/share/elasticsearch/credentials` on elk VM) |
| Elasticsearch | `http://192.168.77.50:9200` | same |

---

## Net-Monitor

**VM:** monitor (192.168.77.55) · Ubuntu 24.04 · 4 vCPU · 8 GB RAM

Provides network-level telemetry: protocol analysis, IDS alerting, full packet capture, and offline flow analysis. Uses a **promiscuous second NIC** to capture ALL inter-VM traffic.

### Components

| Component | Purpose | Access |
|-----------|---------|--------|
| **Zeek** | Application-layer protocol logs (20+ protocols: conn, dns, http, smb, kerberos, ssl, dhcp, ntp, ftp, ssh) | JSON logs at `/opt/zeek/logs/current/` → shipped to central ES via Fleet |
| **Suricata** | IDS with Emerging Threats Open ruleset — network threat detection | `eve.json` at `/var/log/suricata/` → shipped to central ES via Fleet |
| **Arkime** | Full PCAP capture + searchable web UI (Wireshark in browser) | `https://192.168.77.55:8005` |
| **tcpdump** | Manual on-demand PCAP capture | `/opt/pcap/manual/capture-*.pcap` |
| **SiLK** | CERT/SEI offline flow analysis (`rwfilter`, `rwcount`, `rwstats`) | On-demand during export |

### Promiscuous NIC

The monitor VM has a second NIC with `allowPromiscuous = TRUE` in the VMX config. This NIC sees all traffic on vmnet2 without IP spoofing or ARP poisoning. Zeek, Suricata, Arkime, and tcpdump all capture from this interface (`eth1`).

### How Network Tools Complement Each Other

| Tool | Always-On | Granularity | Use Case |
|------|-----------|-------------|----------|
| Zeek | Yes | Session-level JSON logs | Daily analysis — correlate with Windows events in Kibana |
| Suricata | Yes | Signature-based alerts | Threat detection — "did an ET rule fire?" |
| Arkime | Yes | Full packet + metadata | Live inspection during attack — "show me the TGS-REP bytes" |
| tcpdump | Yes (rotated) | Raw packets | Evidence preservation — offline Wireshark deep-dive |
| SiLK | On-demand | Netflow-like aggregates | Post-attack — "top talkers, port scan patterns" |

### Credentials

| Service | URL | Login |
|---------|-----|-------|
| Arkime Viewer | `https://192.168.77.55:8005` | `admin` / `arkime` |

---

## Velociraptor

**VM:** vr (192.168.77.51) · Ubuntu 24.04 · 2 vCPU · 2 GB RAM

Provides on-demand forensic artifact collection from all Windows + Linux VMs. Also exposes an MCP (Model Context Protocol) endpoint for Plan 7's agentic pipeline to issue natural-language queries.

### Components

| Component | Purpose | Access |
|-----------|---------|--------|
| **Velociraptor server** | Hunt management, artifact collection, web GUI | `https://192.168.77.51:8889` |
| **Windows clients (MSI)** | Agent on dc01, dc02, dc03, mbr01, mbr02 — live forensics | Auto-enrolled via config |
| **Linux client** | Agent on linux01 — Linux forensics | Auto-enrolled via config |
| **MCP server (Python)** | Natural-language endpoint queries for Plan 7 agents | `http://192.168.77.51:8002` |

### Pre-Built Hunt Collections

Ready-to-use artifact bundles for each investigation scenario:

| Hunt | Artifacts | Triggers After |
|------|-----------|----------------|
| `cadre-process-tree` | Pslist, TaskScheduler, Services | Any process-based attack |
| `cadre-credential-access` | AMCache, Prefetch, NTUser registry | Credential dumping |
| `cadre-network-state` | Netstat, DNS cache, ARP table | Lateral movement |
| `cadre-fs-timeline` | MFT, USN journal | File drops, persistence |
| `cadre-registry-snapshot` | SAM, SECURITY, SYSTEM hives | Privilege escalation |
| `cadre-event-logs` | All .evtx files exported | Input for Hayabusa / Chainsaw |
| `cadre-adcs-snapshot` | CA database, template config | ADCS attacks (ESC1-15) |
| `cadre-sccm-snapshot` | SCCM WMI classes, NAA policy | SCCM attacks |
| `cadre-linux-triage` | Pslist, NetstatEnriched, suid_bin, krb5/mssql keytab fingerprints (`CADRE.Linux.KeytabFingerprints`), bash history, wtmp/btmp, last 24 h auditd logs, SSSD cache metadata, podman inventory, rootkit-keyword scan | Linux attacks (Kerberos, MSSQL, NFS-krb5, container escape) |
| `cadre-full-breach` | Union of all above | Comprehensive post-attack |

### MCP Endpoint (Plan 7)

The MCP server translates natural-language queries from LangGraph agents into VQL:

```
Agent: "Show me all processes on dc01 that accessed lsass.exe in the last 5 minutes"
  → MCP translates to VQL
  → Executes against dc01 client
  → Returns structured result to agent
```

### Credentials

| Service | URL | Login |
|---------|-----|-------|
| Velociraptor GUI | `https://192.168.77.51:8889` | `admin` / `VelociraptorDefault!` |
| MCP endpoint | `http://192.168.77.51:8002` | API key (in `/etc/velociraptor/mcp.env`) |

---

## MISP (Optional — not currently deployable via cadre.py)

**Note:** MISP is not currently in `EXT_PLAYBOOKS`. Manual VM setup required. Planned for a future release.

**VM:** misp (192.168.77.52) · Ubuntu 24.04 · 2 vCPU · 2 GB RAM

IOC curation platform. **Only deploy if** Elastic's built-in Threat Intel (AbuseCh + OTX) is insufficient for your use case. Scenarios where MISP adds value:

- Curated sector ISAC feeds (FS-ISAC, H-ISAC)
- Custom IOC taxonomies and galaxies
- STIX 2.x export to other tools
- Long-term IOC correlation across investigation campaigns

MISP → Elastic via Fleet Threat Intel integration. Indices: `logs-ti_misp.*`.

---

## C2Stack (Optional)

**Sibling project integration.** Not a CADRE VM — connects to the external `C2Stack` project (Mythic/Sliver/Havoc in a lean 4-VM configuration).

Provides:
- Real C2 implant traffic flowing through CADRE's telemetry stack
- Realistic adversary emulation (beyond one-shot attack scripts)
- Beacon callbacks visible in Zeek/Suricata/Arkime
- EDR detection of C2 frameworks in Elastic Defend alerts

When C2Stack is connected, Plan 10 walkthroughs deliver C2 implants via SCCM client push (the most realistic 2026 IR vector).

---

## Deployment Order

```
1. python cadre.py install                           # Base lab (7 core VMs + AD + vulns)
2. python cadre.py install -e elk-fleet              # SIEM + agents (Fleet must be first)
3. python cadre.py install -e net-monitor            # Network telemetry (agent enrolls into Fleet)
4. python cadre.py install -e velociraptor           # DFIR forensics
```

After all extensions are deployed, take the `clean-baseline` snapshot:
```bash
python docs/internal/tools/snapshot/snapshot.py take clean-baseline --all
```
