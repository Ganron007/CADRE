# CADRE — Attack Matrix

100 attacks across 5 streams. Each attack is a verified, step-by-step technique against the CADRE lab substrate that produces observable telemetry.

> **🚀 START HERE → [`Campaign/Runbooks/CAMPAIGNS-RUNBOOK-README.md`](Campaign/Runbooks/CAMPAIGNS-RUNBOOK-README.md)** — campaign v2 per-phase runbooks (full narrative + commands). Index: [`Campaign/CAMPAIGNS.md`](Campaign/CAMPAIGNS.md). Full reference: [`Campaign/CAMPAIGNS_v2.md`](Campaign/CAMPAIGNS_v2.md).
>
> **🔬 DFIR parallel track → [`Campaign/DFIR-Nexus-Pioneer-workflow.md`](Campaign/DFIR-Nexus-Pioneer-workflow.md)** — link each campaign exercise to DFIR-Nexus cases and Plan 1 telemetry (`tracker.md`).

```
CADRE
├── C — Cloud       ── 09-cloud/ (Azure attack scenarios, Azure RM, hybrid chains)
├── A — Agentic     ── 06-telemetry-catalog/ (Plan 7 RAG corpus)
├── D — DFIR        ── 07-detection-rules/ + 08-hunting/ (Sigma → Elastic + VQL)
├── R — Red-team    ── 01-walkthroughs/ + 04-automation/ (100 attacks, scripted)
└── E — Environment ── 02-diagrams/ (lab architecture) + Campaign/diagrams/ + Campaign/attackpath/
```

## Directory Structure

| Folder | Contents | Count Target | Plan |
|--------|----------|--------------|------|
| **`Campaign/`** | v2 index, CAMPAIGNS_v2, metadata, runbooks, study-guide, diagrams, attackpath, artifacts, DFIR bridge | — | Content |
| `01-walkthroughs/` | Step-by-step attack writeups (markdown) | 100 files | Content |
| `02-diagrams/` | Lab architecture + trust topology (SVG/Mermaid) | ~3 | Content |
| `04-automation/` | Reproducible attack scripts (bash + PowerShell) | ~90 scripts | Content |
| `10-cert-map/` | Per-certification learning paths + technique matrix | 13 files | Content |
| `06-telemetry-catalog/` | Sigma YAML per attack — expected artifacts | 100 YAML | Plan 1 |
| `07-detection-rules/` | Elastic TOML detection rules — Windows (Kerberos/ADCS/SCCM/2026 CVEs/lateral) + Linux rules (keytab/SSSD/realmd/container-escape/MSSQL audit) | 30+ TOML | Plan 5 |
| `08-hunting/` | PEAK/TaHiTI hypothesis templates + VQL hunts | ~30 files | Plan 6 |
| `09-cloud/` | Azure attack scenario wrappers + Azure RM + hybrid chains | ~20 files | Plan 11 |

## Walkthrough Numbering

| Range | Count | Category | Cert Alignment |
|:-----:|:-----:|----------|---------------|
| WT000 | 1 | Network scanning & setup | — |
| WT002–WT033 | 32 | On-prem AD (Kerberos, delegation, ACL, coercion, DCSync, tickets) | CRTP, CRTE, OSCP+, CAPE |
| WT034–WT049 | 16 | SCCM + Linux + Modern (Misconfiguration-Manager, MSSQL, NFS, Podman, 2026 CVEs) | WKL, CAPE |
| WT050–WT062 | 13 | ADCS ESC1-15 (13 practiceable — ESC15 excluded Server 2025) | CESP-ADCS |
| WT063–WT068 | 6 | Initial access (file-based delivery — LNK, MSI, CHM, HTML, AutoIt3, EXE) | — |
| WT069–WT081 | 13 | Network defense exercises (DNS, TLS, HTTP, SSH, beacon) | — |
| WT082–WT093 | 12 | Post-exploitation (LSASS dump, lateral alt, persistence, collection, impact) | — |
| WT094–WT103 | 10 | Supply-chain (npm threat emulation) | — |
| C01–C09 | 9 | Cloud Entra (Azure scenarios + Cloud Sync) | CARTP |
| H01–H04 | 4 | Hybrid chains (on-prem ↔ cloud bidirectional) | CARTP |
| A01–A04 | 4 | Azure RM (subscription, PIM, multi-tenant, Arc) | CARTE |

## How to Use

1. **Open your phase runbook** from [`Campaign/Runbooks/CAMPAIGNS-RUNBOOK-README.md`](Campaign/Runbooks/CAMPAIGNS-RUNBOOK-README.md) — read theory, then run commands live
2. Follow each phase — every command is runnable against the live CADRE lab
3. When a phase references a WT# (e.g., WT#009), flip to `01-walkthroughs/` for the tool reference
4. Run automation scripts from `04-automation/` for repeatable execution
5. Observe telemetry in Kibana / Zeek / Velociraptor (see `docs/forensic-workflow.md`)
6. **Optional:** Run the Pioneer loop — export evidence → DFIR-Nexus case (see [`Campaign/DFIR-Nexus-Pioneer-workflow.md`](Campaign/DFIR-Nexus-Pioneer-workflow.md))
7. Revert to clean baseline → next phase

## Status

| Folder | Status | Files |
|--------|--------|:-----:|
| `Campaign/` | v2 index + CAMPAIGNS_v2 + runbooks + study-guide + diagrams + attackpath | — |
| 01-walkthroughs | Walkthrough reference cards | 63 (+37 pending) |
| 02-diagrams | Lab architecture Mermaid | 2 |
| 04-automation | Core AD + Campaign E/G/H scripts | 91 |
| `Campaign/study-guide` | Deep-dive attack reference (Phase 0-2 complete) | 12 |
| 10-cert-map | Per-certification study guides | 14 |
| 06-telemetry-catalog | Empty — Phase 1 fills this | — |
| 07-detection-rules | Empty — Plan 5 | — |
| 08-hunting | Empty — Plan 6 | — |
| 09-cloud | Empty — Plan 11 | — |
