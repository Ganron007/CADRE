# Campaign

Unified attack campaign **v3** — per-phase runbooks, metadata, research, and supporting reference. Follow [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md) (ws01 Phase 0.5 beachhead).

## Core documents

| File | Purpose |
|------|---------|
| [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md) | **Current campaign** — full narrative (search / print); start spine at Phase 0.5 / ws01 |
| [`LAB-PROFILES.md`](LAB-PROFILES.md) | **Modular VM sets** — which VMs to run per phase (save RAM; P-FULL = worst case) |
| [`CAMPAIGNS.md`](CAMPAIGNS.md) | Older index — topology / coverage (prefer v3 + runbooks) |
| [`CAMPAIGNS_v2.md`](CAMPAIGNS_v2.md) | Archived monolithic v2 reference |
| [`CAMPAIGNS-METADATA.md`](CAMPAIGNS-METADATA.md) | Per-attack playbook refs, ACE#s, telemetry (index) |
| [`CAMPAIGNS-METADATA-mechanics.md`](CAMPAIGNS-METADATA-mechanics.md) | Command-level mechanics, NetExec modules, telemetry deep-dives |
| [`Campaign_suggestions.md`](Campaign_suggestions.md) | Research backlog summary table (index) |
| [`Campaign_suggestions-detail.md`](Campaign_suggestions-detail.md) | Per-item write-ups and test plans |
| [`ATTACK-MAP.md`](ATTACK-MAP.md) | Visual mindmap of AD attack surface |
| [`attack-tools-required.md`](attack-tools-required.md) | Tools needed per WT# |
| [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md) | Parallel attack + DFIR-Nexus case workflow |
| [`Feedback_loop.txt`](Feedback_loop.txt) | Campaign_suggestions assessment notes |
| [`CAMPAIGNS_v1_archived.md`](CAMPAIGNS_v1_archived.md) | Archived 60-attack campaign (v1) |

## Folders

| Folder | Purpose |
|--------|---------|
| [`Runbooks/`](Runbooks/) | **Primary path** — full phase narrative + commands (learn + execute) |
| [`study-guide/`](study-guide/) | Deep-dive reference per campaign phase |
| [`diagrams/`](diagrams/) | Campaign attack-flow diagrams |
| [`attackpath/`](attackpath/) | Sequenced kill-chain visualization |
| [`artifacts/`](artifacts/) | Campaign capture artifacts (BH zip, nmap, etc.) |

## Quick start

1. **Power the right VMs** — [`LAB-PROFILES.md`](LAB-PROFILES.md) (Phase 0.5 → **P-BEACH**: Kali + ws01 + dc02).
2. **Open** [`Runbooks/CAMPAIGNS-RUNBOOK-README.md`](Runbooks/CAMPAIGNS-RUNBOOK-README.md) and pick your phase (v3 next: **0.5 / Runbook H**).
3. **Read + execute** — each runbook has theory, prerequisites, detection notes, and commands (`CAMPAIGNS_v3.md` for full search).
4. **Update** [`CAMPAIGNS-METADATA.md`](CAMPAIGNS-METADATA.md) after each verified attack.
5. **DFIR** — log evidence via [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md).

Walkthroughs (`01-walkthroughs/`) and automation scripts (`04-automation/`) remain under `attack-matrix/` — WT reference cards linked from the campaign.
