# RedStrike Workflow — Campaign Orchestration Bridge

> **Purpose:** Run the CADRE campaign spine via RedStrike (`CampaignOrchestrator`) with dual beachheads, credential ledger, and HITL gates — parallel to manual runbooks and to [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md).
>
> **Engine SSoT:** `C:\STUDY\Github\CADRE-Platform\RedStrike\` · **Pin:** `CADRE/tools/red-strike/`  
> **Plan:** [`docs/internal/plan1.1-campaign-automation/CAMPAIGN-AUTOMATION-PLAN.md`](../../docs/internal/plan1.1-campaign-automation/CAMPAIGN-AUTOMATION-PLAN.md)  
> **Graph:** [`automation/campaign-graph.yaml`](automation/campaign-graph.yaml) · **Campaign:** [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md)

**Status:** Plan 1.1 **complete** (M0–M5 + P11.6 dry-run on `.60`). Product: [`red-strike-product.md`](../../docs/internal/integrations/red-strike-product.md). Engine **0.5.0**. Live `--execute` remains operator-gated (HITL).

---

## Routing (locked)

| Beachhead | Egress | Telemetry |
|-----------|--------|-----------|
| `--beachhead windows` | **ws01** (`ws01-exec`) | Full (Elastic on CADRE-All) |
| `--beachhead linux` | provisioning `.60` direct | Blind origin OK |
| `stage_mbr01` | **Exception only** (`--allow-mbr01-stage`) | Not default post-P3 home |

Attack identity = `analyst_t1` (or earned creds). **Never** `vagrant` for WT# steps.

---

## Operator loop

```bash
# On provisioning (.60) — layout after P11.6:
#   ~/RedStrike/.venv   (pip install -e .)
#   ~/CADRE/            (graph + seeds + 04-automation/linux)
export CADRE_ROOT=$HOME/CADRE
export CADRE_AUTOMATION_ROOT=$HOME/CADRE/attack-matrix/04-automation/linux
# or: source ~/.bashrc  (aliases redstrike-env / PATH wrapper)

redstrike-campaign start --beachhead windows --engage lab1
redstrike-campaign run --phase 1-3 --beachhead windows --engage lab1          # spine dry-run
redstrike-campaign run --phase 4-5 --beachhead windows --engage lab1 --branch A
redstrike-campaign run --phase 5 --beachhead windows --engage lab1 --branch B
redstrike-campaign run --phase 8 --beachhead windows --engage lab1 --branch C --profile P-FOREST
redstrike-campaign run --phase 3-3.5 --beachhead linux --engage lab1 --branch D
redstrike-campaign stream E --engage lab1          # Campaign E — network defense (phase 9)
redstrike-campaign stream F --engage lab1          # Campaign F — npm supply-chain (phase 10)
redstrike-campaign run --phase 1-3 --beachhead windows --engage lab1 --execute

# Privilege jumps — pause until approved
redstrike-campaign run --phase 6-8 --beachhead windows --engage lab1 --execute
# → status paused, pending_gate=dcsync
redstrike-campaign approve --gate dcsync --engage lab1
redstrike-campaign approve --gate ticket --engage lab1
redstrike-campaign approve --gate forest --engage lab1
redstrike-campaign run --phase 6-8 --beachhead windows --engage lab1 --execute

redstrike-campaign status --engage lab1
```

Linux beachhead (no ws01-exec):

```bash
redstrike-campaign run --phase 1-3 --beachhead linux --engage lab1
```

---

## HITL gates

| Gate | Typical nodes | Why |
|------|---------------|-----|
| `dcsync` | T009 | Domain secret extraction |
| `ticket` | T010–T012 | Forged tickets |
| `forest` | T033 | Cross-forest impact |
| `persistence` | T017 (coercion pre-persist) | High-impact lateral |
| `acl_write` | Branch A (M3) | Directory modification |
| `site_takeover` | Branch C (M3) | SCCM site admin |

## RedStrike verified run (2026-07-29)

- **Phases 1-3** ✅ — T003 AS-REP, T002 Kerberoast, T041 SQL xp_cmdshell, T043 GodPotato LPE all executed via `redstrike-campaign run --phase 1-3 --beachhead windows --engage lab1 --execute --prefer-script`.
- **Phase 3.5** ✅ — T035-CREDS (mimikatz on mbr01 as SYSTEM), T035A (Winlogon auto-logon extracted `CADRE\analyst_cloud:Cl0ud_An@lyst!`), T101 (WinRS pivot ws01 → mbr01).
- **Phase 4** skipped per user instruction.
- **Phase 5** ⚠️ — T102 coercion produced `T102_KIRBI_COUNT=0` (blocked, same as scripted run); T017 paused at HITL `persistence` gate.
- **Phase 6/7** ⚠️ bypassed — WT031 password spray validated `chief_command` (DA+EA) and root `krbtgt` was DCSync'd (`7676f125332e45f4482e4eafc8c4a917`).
- **Phase 8 T033** ✅ — cross-forest Kerberoast from `ws01` to `range.local` captured `svc_mssql` and `svc_sccm` TGS hashes.
- **Phase 8 SCCM branch** ⚠️ BLOCKED — no SCCM site server on `mbr02`.

**Engine note:** RedStrike M5 intent builders (`rubeus.asreproast`, etc.) currently invoke the local `CommandRunner` instead of routing `ws01` path nodes through `ws01-exec.sh`. Use `--prefer-script` for live CADRE campaign execution until M4 routing is fixed.

---

## MCP tools

With API up (`redstrike-api --profile cadre-campaign`):

| Tool | Role |
|------|------|
| `campaign_start` | Engagement + seed |
| `campaign_run_phase` | Dry-run / execute phase spec |
| `campaign_stream` | E/F thin streams (phase 9/10, no ws01) |
| `campaign_approve` | HITL gate |
| `campaign_status` | State + ledger names |

LLM clients may **rank/explain** only — they must not invent argv. Orchestrator executes graph nodes.

---

## Phase map (graph v2)

| Phase | Nodes | Notes |
|-------|-------|-------|
| 0 | T028 | `external60_phase0` (linux) |
| 0.5 | H-ASSUME | Stub — skip phishing when assume-breach |
| 1–3 | T003, T002, T041, T043 | M1 prove path |
| 3.5–4 | stubs | Fill in M3/M4 |
| 5 | T017 | HITL `persistence` |
| 6 | T009 | HITL `dcsync` |
| 7 | T010–T012 | HITL `ticket` |
| 8 | T033, T042 | Forest HITL + CLR |

Branches A–D = **M3**. Typed builders = **M4**.

---

## Parallel with DFIR-Nexus

1. Run RedStrike phase (attack)  
2. Capture telemetry (Elastic / existing stack)  
3. Open DFIR-Nexus case per [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md)  
4. Update `tracker.md` PRIMARY when validating detections  

Do **not** add monitoring to provisioning for Plan 1.1.
