# Campaign

Unified attack campaign **v3** — per-phase runbooks, metadata, research, and supporting reference. Follow [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md) (ws01 Phase 0.5 beachhead).

## Core documents (published)

| File | Purpose |
|------|---------|
| [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md) | **Current campaign** — full narrative (search / print); start spine at Phase 0.5 / ws01 |
| [`CAMPAIGNS-METADATA-v2.md`](CAMPAIGNS-METADATA-v2.md) | Per-attack playbook refs, ACE#s, telemetry (index) |
| [`CAMPAIGNv3-ATTACK-FLOW.md`](CAMPAIGNv3-ATTACK-FLOW.md) | Attack-flow diagram (moved out of v3 for lightness) |
| [`LAB-PROFILES.md`](LAB-PROFILES.md) | **Modular VM sets** — which VMs to run per phase (save RAM; P-FULL = worst case) |
| [`Campaign_suggestions.md`](Campaign_suggestions.md) | Research backlog summary table (index) |
| [`ATTACK-MAP.md`](ATTACK-MAP.md) | Visual mindmap of AD attack surface |
| [`attack-tools-required.md`](attack-tools-required.md) | Tools needed per WT# |
| [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md) | Parallel attack + DFIR-Nexus case workflow |
| [`Red-Strike-workflow.md`](Red-Strike-workflow.md) | RedStrike CampaignOrchestrator workflow (Plan 1.1) |

## Folders

| Folder | Purpose |
|--------|---------|
| [`Runbooks/`](Runbooks/) | **Primary path** — full phase narrative + commands (learn + execute) |
| [`study-guide/`](study-guide/) | Deep-dive reference per campaign phase |
| [`diagrams/`](diagrams/) | Campaign attack-flow diagrams |
| [`attackpath/`](attackpath/) | Sequenced kill-chain visualization |
| [`automation/`](automation/) | Campaign graph, scope, seeds (`lab-seed-creds.example.json`) |

## Maintainer-local (not in the published tree)

These paths stay on disk for lab work but are **gitignored** — validation ledgers, pre-v3 archives, live evidence captures, and the filled RedStrike seed file:

- `CAMPAIGNS-VALIDATION-REPORT.md`, `REDSTRIKE-VALIDATION-REPORT.md`, `CADRE-Attack-Surface-Coverage-Audit.md`
- `archive/` (v1/v2 monoliths, old metadata, HTML previews)
- `artifacts/` (nmap, BloodHound zips, ACE dumps)
- `automation/lab-seed-creds.json` (copy from `lab-seed-creds.example.json` after deploy)

Internal planning (`docs/internal/`, `AGENTS.md`) uses the same policy — see [`DOCS.md`](../../DOCS.md).

## Quick start

1. **Power the right VMs** — [`LAB-PROFILES.md`](LAB-PROFILES.md) (Phase 0.5 → **P-BEACH**: Kali + ws01 + dc02).
2. **Open** [`Runbooks/CAMPAIGNS-RUNBOOK-README.md`](Runbooks/CAMPAIGNS-RUNBOOK-README.md) and pick your phase (v3 next: **0.5 / Runbook H**).
3. **Read + execute** — each runbook has theory, prerequisites, detection notes, and commands (`CAMPAIGNS_v3.md` for full search).
4. **Update** [`CAMPAIGNS-METADATA-v2.md`](CAMPAIGNS-METADATA-v2.md) after each verified attack.
5. **DFIR** — log evidence via [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md).

Walkthroughs (`01-walkthroughs/`) and automation scripts (`04-automation/`) remain under `attack-matrix/` — WT reference cards linked from the campaign.
