# CADRE — Attack Matrix

60 walkthroughs across 8 certifications. Each walkthrough is a verified, step-by-step attack against the CADRE lab substrate that produces observable telemetry.

> **🚀 START HERE → [`CAMPAIGNS.md`](CAMPAIGNS.md)** — 5 attack campaigns that chain techniques together organically. Each campaign teaches the *process* of attacking AD: enumerate → find weakness → exploit → pivot. Isolated walkthroughs are technical reference cards; campaigns are the real attack story.

```
CADRE
├── C — Cloud       ── 09-cloud/ (Azure attack scenarios, Azure RM, hybrid chains)
├── A — Agentic     ── 06-telemetry-catalog/ (Plan 7 RAG corpus)
├── D — DFIR        ── 07-detection-rules/ + 08-hunting/ (Sigma → Elastic + VQL)
├── R — Red-team    ── 01-walkthroughs/ + 04-automation/ (60 attacks, scripted)
└── E — Environment ── 02-diagrams/ + 03-attackpath/ (architecture + flow)
```

## Directory Structure

| Folder | Contents | Count Target | Plan |
|--------|----------|--------------|------|
| `01-walkthroughs/` | Step-by-step attack writeups (markdown) | 60 files | Content |
| `02-diagrams/` | Architecture + trust topology (SVG/Mermaid) | ~10 | Content |
| `03-attackpath/` | Sequenced kill-chain flow visualization | 1 SVG + 1 MD | Content |
| `04-automation/` | Reproducible attack scripts (bash + PowerShell) | ~60 scripts | Content |
| `05-study-guide/` | Per-certification learning paths + technique matrix | 13 files | Content |
| `06-telemetry-catalog/` | Sigma YAML per attack — expected artifacts | 60 YAML | Plan 1 |
| `07-detection-rules/` | Elastic TOML detection rules — Windows (Kerberos/ADCS/SCCM/2026 CVEs/lateral) + 15 Linux rules (L01-L15) for keytab/SSSD/realmd/container-escape/MSSQL audit — see Linux Telemetry Baseline in [`docs/architecture.md`](../docs/architecture.md) | 30+ TOML | Plan 5 |
| `08-hunting/` | PEAK/TaHiTI hypothesis templates + VQL hunts | ~30 files | Plan 6 |
| `09-cloud/` | Azure attack scenario wrappers + Azure RM + hybrid chains | ~20 files | Plan 11 |

## Walkthrough Numbering

| Range | Category | Cert Alignment |
|-------|----------|---------------|
| 002-033 | On-prem AD (Kerberos, delegation, ACL, coercion, DCSync, tickets) | CRTP, CRTE, OSCP+, CAPE |
| 034-049 | SCCM + Linux + Modern (Misconfiguration-Manager, MSSQL, NFS, Podman, 2026 CVEs) | WKL, CAPE |
| 050-062 | ADCS ESC1-15 (13 practiceable — ESC15 excluded Server 2025 limitation) | CESP-ADCS |
| C01-C09 | Cloud Entra (Azure scenarios + Cloud Sync) | CARTP |
| H01-H04 | Hybrid chains (on-prem ↔ cloud bidirectional) | CARTP |
| A01-A04 | Azure RM (subscription, PIM, multi-tenant, Arc) | CARTE |

## How to Use

1. **Start with [`CAMPAIGNS.md`](CAMPAIGNS.md)** — pick a campaign matching your starting position
2. Follow each phase — every command is runnable against the live CADRE lab
3. When a phase references a WT# (e.g., WT#009), flip to `01-walkthroughs/` for the tool reference
4. Run automation scripts from `04-automation/` for repeatable execution
5. Observe telemetry in Kibana / Zeek / Velociraptor (see `docs/forensic-workflow.md`)
6. Revert to clean baseline → next campaign

## Status

| Folder | Status | Files |
|--------|--------|:-----:|
| — | `CAMPAIGNS.md` — 5 campaigns, 60 WT# covered | ✅ |
| 01-walkthroughs | 60 walkthrough reference cards | 63 |
| 02-diagrams | Mermaid attack flow + architecture | 3 |
| 03-attackpath | Full attack path map (712 lines) | 2 |
| 04-automation | 59 Linux bash scripts + libs | 63 |
| 05-study-guide | 14 files across 8 certs | 14 |
| 06-telemetry-catalog | Empty — Plan 1 | — |
| 07-detection-rules | Empty — Plan 5 | — |
| 08-hunting | Empty — Plan 6 | — |
| 09-cloud | Empty — Plan 11 | — |
