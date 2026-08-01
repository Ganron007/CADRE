# Campaign

Unified attack campaign **v3** — per-phase runbooks, metadata, research, and supporting reference. Follow [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md) (ws01 Phase 0.5 beachhead).

## Core documents

| File | Purpose |
|------|---------|
| [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md) | **Current campaign** — full narrative (search / print); start spine at Phase 0.5 / ws01 |
| [`CAMPAIGNS-METADATA-v2.md`](CAMPAIGNS-METADATA-v2.md) | Per-attack playbook refs, ACE#s, telemetry (index) |
| [`CAMPAIGNS-VALIDATION-REPORT-20260730.md`](CAMPAIGNS-VALIDATION-REPORT-20260730.md) | Live validation report (Branches B/C/D verified) |
| [`CADRE-Attack-Surface-Coverage-Audit-20260730.md`](CADRE-Attack-Surface-Coverage-Audit-20260730.md) | Attack-surface coverage audit (6-doc sync set) |
| [`LAB-PROFILES.md`](LAB-PROFILES.md) | **Modular VM sets** — which VMs to run per phase (save RAM; P-FULL = worst case) |
| [`Campaign_suggestions.md`](Campaign_suggestions.md) | Research backlog summary table (index) |
| [`ATTACK-MAP.md`](ATTACK-MAP.md) | Visual mindmap of AD attack surface |
| [`attack-tools-required.md`](attack-tools-required.md) | Tools needed per WT# |
| [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md) | Parallel attack + DFIR-Nexus case workflow |
| [`Red-Strike-workflow.md`](Red-Strike-workflow.md) | RedStrike CampaignOrchestrator workflow (Plan 1.1) |
| [`archive/`](archive/) | Archived versions — CAMPAIGNS.md (v2 index), CAMPAIGNS_v2.md, CAMPAIGNS_v1_archived.md, CAMPAIGNS-METADATA.md, CAMPAIGNS-METADATA-mechanics.md, Campaign_suggestions-detail.md, Feedback_loop.txt, `_preview*` |

## Folders

| Folder | Purpose |
|--------|---------|
| [`Runbooks/`](Runbooks/) | **Primary path** — full phase narrative + commands (learn + execute) |
| [`study-guide/`](study-guide/) | Deep-dive reference per campaign phase |
| [`diagrams/`](diagrams/) | Campaign attack-flow diagrams |
| [`attackpath/`](attackpath/) | Sequenced kill-chain visualization |
| [`artifacts/`](artifacts/) | Attack evidence captures (nmap, BH zip, t025-* ACE dumps) |
| [`automation/`](automation/) | Campaign automation scripts (incl. `patch-validation-report.py`) |
| [`archive/`](archive/) | Archived/old doc versions (pre-v3) |
| [`artifacts/`](artifacts/) | Campaign capture artifacts (BH zip, nmap, etc.) |

## Quick start

1. **Power the right VMs** — [`LAB-PROFILES.md`](LAB-PROFILES.md) (Phase 0.5 → **P-BEACH**: Kali + ws01 + dc02).
2. **Open** [`Runbooks/CAMPAIGNS-RUNBOOK-README.md`](Runbooks/CAMPAIGNS-RUNBOOK-README.md) and pick your phase (v3 next: **0.5 / Runbook H**).
3. **Read + execute** — each runbook has theory, prerequisites, detection notes, and commands (`CAMPAIGNS_v3.md` for full search).
4. **Update** [`CAMPAIGNS-METADATA-v2.md`](CAMPAIGNS-METADATA-v2.md) after each verified attack.
5. **DFIR** — log evidence via [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md).

Walkthroughs (`01-walkthroughs/`) and automation scripts (`04-automation/`) remain under `attack-matrix/` — WT reference cards linked from the campaign.
