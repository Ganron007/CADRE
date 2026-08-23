# CADRE — Attack Matrix

107+ attacks across the v3 campaign (main spine Phases 0.5–8 + 4 branches + E/F/G streams). Each attack is a step-by-step technique against the CADRE lab substrate that produces observable telemetry.

> **🚀 START HERE → [`Campaign/CAMPAIGNS_v3.md`](Campaign/CAMPAIGNS_v3.md)** — current v3 campaign narrative. Per-attack reference: [`Campaign/CAMPAIGNS-METADATA-v2.md`](Campaign/CAMPAIGNS-METADATA-v2.md). Runbooks: [`Campaign/Runbooks/CAMPAIGNS-RUNBOOK-README.md`](Campaign/Runbooks/CAMPAIGNS-RUNBOOK-README.md).
>
> **Per-attack reference:** [`Campaign/CAMPAIGNS-METADATA-v2.md`](Campaign/CAMPAIGNS-METADATA-v2.md). Maintainer validation ledgers (`CAMPAIGNS-VALIDATION-REPORT.md`, coverage audit) are local-only — see [`Campaign/README.md`](Campaign/README.md).
>
> **⛔ Hard rules (operator-locked 2026-07-31):** RULE 1 — all attacks run from `ws01` via direct SSH (`cadre-ws01-key`); provisioning (`.60`) is config-only, never an attack origin. RULE 2 — no scheduled tasks to run commands (persistence-only). See the metadata header for the full text.
>
> **🔬 DFIR parallel track → [`Campaign/DFIR-Nexus-Pioneer-workflow.md`](Campaign/DFIR-Nexus-Pioneer-workflow.md)** — link each campaign exercise to DFIR-Nexus cases and Plan 1 telemetry (`tracker.md`).

```
CADRE
├── C — Cloud       ── 09-cloud/ (Azure attack scenarios, Azure RM, hybrid chains)
├── A — Agentic     ── 06-telemetry-catalog/ (Plan 7 RAG corpus)
├── D — DFIR        ── 07-detection-rules/ + 08-hunting/ (Sigma → Elastic + VQL)
├── R — Red-team    ── 01-walkthroughs/ + 04-automation/ (107 attacks, scripted)
└── E — Environment ── 02-diagrams/ (lab architecture) + Campaign/diagrams/ + Campaign/attackpath/
```

## Directory Structure

| Folder | Contents | Count Target | Plan |
|--------|----------|--------------|------|
| **`Campaign/`** | **v3 narrative (`CAMPAIGNS_v3.md`)** + metadata-v2, validation report, coverage audit, runbooks, study-guide, diagrams, attackpath, artifacts, DFIR bridge | — | Content |
| `01-walkthroughs/` | Step-by-step attack writeups (markdown) | 100 files | Content |
| `02-diagrams/` | Lab architecture + trust topology (SVG/Mermaid) | ~3 | Content |
| `04-automation/` | Reproducible attack scripts (bash + PowerShell) | ~90 scripts | Content |
| `Campaign/study-guide/` | Phase deep-dives + attack theory | 13 files | Content |
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

1. **Open the v3 narrative** [`Campaign/CAMPAIGNS_v3.md`](Campaign/CAMPAIGNS_v3.md) — read the phase story, then run commands live from `ws01`
2. **Check per-attack status** in [`Campaign/CAMPAIGNS-METADATA-v2.md`](Campaign/CAMPAIGNS-METADATA-v2.md) (WT#, playbook, ACE#, telemetry, RedStrike intent)
3. **Run from ws01 only (Rule 1)** — tools staged via `scp` `localhost → ws01`, executed by direct SSH (`cadre-ws01-key`). No provisioning bridge
4. When a phase references a WT# (e.g., WT#009), flip to `01-walkthroughs/` for the tool reference
5. Run automation scripts from `04-automation/` for repeatable execution
6. Observe telemetry in Kibana / Zeek / Velociraptor (see `docs/forensic-workflow.md`)
7. **Optional:** Run the Pioneer loop — export evidence → DFIR-Nexus case (see [`Campaign/DFIR-Nexus-Pioneer-workflow.md`](Campaign/DFIR-Nexus-Pioneer-workflow.md))
8. Revert to clean baseline → next phase

## Status

| Folder | Status | Files |
|--------|--------|:-----:|
| `Campaign/` | **v3 narrative + metadata-v2 + runbooks + study-guide + diagrams + attackpath** | — |
| `Campaign/CAMPAIGNS_v3.md` | Current campaign narrative | 1 |
| `Campaign/CAMPAIGNS-METADATA-v2.md` | Per-attack reference (107+) | 1 |
| 01-walkthroughs | Walkthrough reference cards | 63 (+37 pending) |
| 02-diagrams | Lab architecture Mermaid | 2 |
| 04-automation | Core AD + Campaign E/G/H scripts | 91 |
| `Campaign/study-guide` | Deep-dive attack reference (Phase 0-2 complete) | 12 |
| 06-telemetry-catalog | Empty — Phase 1 fills this | — |
| 07-detection-rules | Empty — Plan 5 | — |
| 08-hunting | Empty — Plan 6 | — |
| 09-cloud | Empty — Plan 11 | — |
