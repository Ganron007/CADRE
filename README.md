# CADRE

<p align="center">
  <img src="docs/img/cadre-logo-godfather.svg" alt="CADRE Logo" width="620">
</p>

<p align="center">
  <strong>Cloud, Agentic, DFIR, and Red-Team Environment</strong>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-purple.svg" alt="License: MIT"></a>
  <img src="https://img.shields.io/badge/Status-Plan%200%20Deployed-success.svg" alt="Status: Deployed">
  <img src="https://img.shields.io/badge/Platform-VMware%20%2F%20Windows%20Server%202025-blue.svg" alt="Platform: VMware / WinServer2025">
</p>

| Pillar | Dimension | Focus & Core Stack |
| :--- | :--- | :--- |
| <img src="https://img.shields.io/badge/C--Cloud-0078d4?style=flat-for-the-badge&logo=microsoftazure&logoColor=white" alt="Cloud"> | **Hybrid Cloud Identity** | Microsoft Entra ID (Free Tenant) • Azure Resource Manager (ARM) • Hybrid attack scenarios bridging On-Prem and Cloud |
| <img src="https://img.shields.io/badge/A--Agentic-343a40?style=flat-for-the-badge&logo=openai&logoColor=white" alt="Agentic"> | **Autonomous Investigation** | LangGraph Multi-Agent Workflows • DFIR-Nexus Evidence Schema • Local LLMs & RAG Routing • Velociraptor MCP |
| <img src="https://img.shields.io/badge/D--DFIR-5c0d12?style=flat-for-the-badge&logo=elastic&logoColor=white" alt="DFIR"> | **Forensics & Telemetry** | Elastic SIEM (Host Telemetry) • Velociraptor (Live Hunts) • Zeek & Suricata (Network Flows) • Plaso, Hayabusa & Timesketch |
| <img src="https://img.shields.io/badge/R--Red_Team-ef4444?style=flat-for-the-badge&logo=target&logoColor=white" alt="Red-Team"> | **Offensive Emulation** | 60+ scripted attack surfaces spanning 8 industry certifications (CRTP/E, CAPE, ADCS, OADOC, CARTP/E) |
| <img src="https://img.shields.io/badge/E--Environment-14532d?style=flat-for-the-badge&logo=virtualbox&logoColor=white" alt="Environment"> | **Active Substrate** | Server 2025 (3 DCs, 2 members) • Ubuntu 24.04 Linux AD • 7 core VMs + 3 extensions (ELK, Net-Monitor, VR) |

The first open-source lab combining red-team practice, agentic AI investigation, DFIR tooling, cloud identity (Azure/Entra), and 8 industry certifications in a single instrumented substrate. Every attack produces ground-truth telemetry. Investigate manually or via multi-agent AI pipeline. Export structured evidence. Reset. Repeat.

MIT licensed. $0 baseline cost.

---

## Quickstart

```powershell
python cadre.py check                              # Pre-flight (RAM, disk, Vagrant, VMware)
python cadre.py install                            # Deploy 7 core VMs + AD + vulnerabilities
python cadre.py install -e elk-fleet               # SIEM + EDR + Fleet agents
python cadre.py install -e net-monitor             # Zeek + Suricata + Arkime + PCAP
python cadre.py install -e velociraptor            # DFIR server + clients
```

Full guide: [docs/deployment.md](docs/deployment.md)

---

## Core Capabilities

1. **Red-team practice** — 60 walkthroughs across 8 certifications against live multi-domain AD + Azure
2. **Telemetry knowledge via offense** — every attack produces artifacts across Sysmon, Elastic Defend, Zeek, Suricata, Arkime, Velociraptor
3. **DFIR investigation** — Velociraptor VQL hunts, Hayabusa timelines, Plaso, KAPE, Volatility 3
4. **Agentic AI investigation** — LangGraph multi-agent pipeline (6 agents) + DFIR-Nexus + multi-LLM router
5. **Cloud + hybrid identity** — Azure attack scenarios, Azure RM (CARTE), hybrid chains bridging on-prem and cloud
6. **C2 practice** — C2Stack integration (Mythic/Sliver/Havoc)

---

## Architecture & Data Flow

- **7 core VMs + 3 extensions** on vmnet2 `192.168.77.0/24` (isolated host-only)
- **5x Server 2025** — 3 DCs (2 forests + child) + 2 members (MSSQL/IIS + WSUS/VSC)
- **Linux AD member** — Ubuntu 24.04 domain-joined (SSSD, MSSQL-on-Linux, NFS-krb5, Podman) — fully instrumented with auditd (≥45 immutable rules), MSSQL audit, SSSD debug, podman events, osquery, Velociraptor Linux client. First open-source lab to do this.
- **Elastic 9.x + Fleet** — host telemetry. Windows baseline configured by `cadre-dfir-monitoring.ps1` (49 audit subcats + PowerShell deep visibility + NTLM auditing + 26 operational channels incl. Server 2025-only Kerberos/KDC/LDAP-Client/Credential-Guard). Sysmon (Olaf Hartong sysmon-modular). EDR detect-mode.
- **Zeek + Suricata + Arkime** — network telemetry (promiscuous NIC, full PCAP)
- **Velociraptor** — endpoint DFIR (Windows + Linux clients)

<p align="center">
  <img src="docs/img/cadre-architecture-dark.png" alt="CADRE Architecture" width="100%">
</p>

Full topology: [docs/architecture.md](docs/architecture.md)

---

## 8 Certifications Attack Coverage

| Cert | Focus |
|------|-------|
| CRTP | AD pentesting fundamentals |
| CRTE | AD expert (cross-forest, delegation, dMSA) |
| CESP-ADCS | Certificate Services ESC1-15 |
| HTB CAPE | AD + coercion + Linux cross-platform |
| OSCP+ | Offensive Security AD portion |
| WKL OADOC | SCCM Misconfiguration-Manager + Virtual Smart Cards |
| CARTP | Azure Red Team Professional (Azure scenarios + Cloud Sync) |
| CARTE | Azure Red Team Expert (Azure RM + PIM + multi-tenant + Arc) |

---

## Project Structure & Documentation

Full doc index: [`DOCS.md`](DOCS.md) — start there to find the right page for what you're doing.

| Doc | What |
|-----|------|
| [Deployment Guide](docs/deployment.md) | Step-by-step: prerequisites → 4 stages → verification |
| [Architecture](docs/architecture.md) | Topology, VMs, data flow, detection coverage |
| [Extensions](docs/extensions.md) | ELK-Fleet, Net-Monitor, Velociraptor, MISP, C2Stack |
| [Forensic Workflow](docs/forensic-workflow.md) | Attack → Telemetry → Investigate → Export → Reset cycle |
| [Testing](docs/testing-recommendations.md) | 83-check verification recipe |
| [DFIR Logging Reference](docs/dfir-logging-reference.md) | Every channel / EID / auditd key / Elastic index in one page |
| [Cert Coverage](docs/cert-coverage.md) | Honest % coverage for all 8 certifications (post-deploy + roadmap completion) |
| [Goals / Roadmap](docs/goals.md) | 11-plan roadmap with status |

---

## Current Status & Roadmap

**Plan 0 — Deployed.** All infrastructure, attack surface, and telemetry stack deployed and verified. 124/127 static structure checks pass (the 3 non-passing check for user-provided installer media — SCCM/SQL, gitignored, not shipped). All 60 attacks configured (WT#002-062 — numbering starts at WT#002). Cloud identity (Plan 11) and agentic pipeline (Plan 7) remain.

### Next Step
**Plan 1 — Telemetry Catalog.** 60 Sigma YAML files mapping every attack to expected artifacts across Sysmon, Elastic, Zeek, and Velociraptor.

---

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.

> Copyright (c) 2026 CADRE Platform contributors.
