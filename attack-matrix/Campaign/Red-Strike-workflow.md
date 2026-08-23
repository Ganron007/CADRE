# RedStrike Workflow — Campaign Orchestration Bridge

> **Purpose:** Run the CADRE campaign spine via the **CADRE-integrated RedStrike pin** (`CampaignOrchestrator`) with dual beachheads, credential ledger, and HITL gates — parallel to manual runbooks and to [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md).
>
> **Plan 01 engine (required):** `CADRE/tools/red-strike/` — install and run **this** copy for campaign runs.
> **Upstream product:** sister `RedStrike\` / [github.com/Ganron007/RedStrike](https://github.com/Ganron007/RedStrike) — features land there first. **Always** adopt standalone HEAD into this pin and provisioning (`tools/sync-redstrike-pin.ps1 -PushKali`). Do not run Plan 01 from a standalone clone.
> **Standalone practice:** a standalone RedStrike install may still target CADRE VMs with operator-owned graph/scope; that is **not** the integrated campaign path.
> **Plan:** `CAMPAIGN-AUTOMATION-PLAN.md` (local maintainers)
> **Graph:** [`automation/campaign-graph.yaml`](automation/campaign-graph.yaml) · **Campaign:** [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md)

**Status:** Plan 1.1 **complete**. Pin tracks standalone RedStrike **0.6.0** (`d39922e` + CADRE overlay, always-sync 2026-08-20). Graph **v9** lives in this CADRE tree only. Dual operator modes: **provisioning** (hybrid) + **ws01** (native). **CADRE assessment uses the pin only** — not a standalone clone.

---

## DFIR full graph (current)

Fresh DFIR telemetry uses **graph v9, all 90 nodes**, from provisioning (hybrid `ws01-exec` + Kali-only paths). This **is** the collection case (ws01 + linux01 on-box + Velociraptor across the lab). It is not a 30-node spine.

**Live order (locked):** soft-reboot every running CADRE VM + WS01 → wait healthy → wipe logs → `--execute`. **No snapshots.** Dry-run does **not** fire attacks and is **not** between wipe and execute.

| Do | Do not |
|----|--------|
| `tools/dfir-full-live.ps1` (reboot + wipe; add `-Execute` only to start attacks) | Treat the retired 30-node spine dry-run as this case |
| `tools/lab-vm-reboot.ps1` then `tools/lab-log-reset.ps1` | `--execute` on dirty logs or without a post-reboot wipe |
| Pin venv `$HOME/CADRE/tools/red-strike/.venv` on **provisioning** | `~/RedStrike` standalone venv |
| `--operator provisioning` | Pin on this Windows laptop (defaults to `local-ws01`) |
| Phased beachheads in `redstrike-dfir-full.sh` (`--profile P-DFIR --prefer-script`) | Native `--operator ws01` until the pin is installed on ws01 (it is not) |
| `--execute` only after `DFIR_FULL_READY=YES` **and** reboot+wipe | Claim “say go” from docs or a second check-pass |

HITL gates: **off** for CADRE-integrated (`--ungated` + `CADRE_ROOT`). LLM/API live path is the same flag: `redstrike-api --ungated --scope attack-matrix/Campaign/automation/scope.cadre.example.yaml`. Empty scope cannot run. Standalone product (no `--ungated`) still pauses on HITL and defaults to read-only API. Stubs still skip: T100, T103, T104, T107, T108, T-SQL-AI, WT093. Seed `krbtgt` hashes stay null until T009 actually dumps them.

**ws01 vs Kali:** Windows AD/SCCM/ACL/ADCS/Post-DA nodes originate on **ws01** (`analyst_t1`, `ws01-exec`). Provisioning simulates Kali **only** where the graph path is not ws01: T028, H-01..H-06 (Rule 4), T031, E/F, and linux01 T045–T048.

```powershell
# Prelude only (no attacks): graceful reboot + wait + log wipe
.\tools\dfir-full-live.ps1

# Live DFIR full graph — same prelude, then --execute
.\tools\dfir-full-live.ps1 -Execute
```

```bash
# On provisioning, after the pin venv exists
export CADRE_ROOT=$HOME/CADRE
bash "$CADRE_ROOT/attack-matrix/04-automation/linux/redstrike-dfir-full.sh"
```

---

## Install the pin (Plan 01)

**Always-sync** from the Windows CADRE tree (copies sister HEAD → pin + overlay → pytest → provisioning):

```powershell
.\tools\sync-redstrike-pin.ps1 -PushKali
```

Manual install (only if the script is unavailable). Graph, seeds, and attack scripts stay in CADRE — only the engine is this pin.

```bash
cd "$HOME/CADRE/tools/red-strike"   # Windows: C:\STUDY\Github\CADRE-Platform\CADRE\tools\red-strike
python3 -m venv .venv
source .venv/bin/activate           # Windows: .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -e ".[dev,mcp]"
redstrike check
```

Then set CADRE glue (never commit API keys, SSH private keys, or seed passwords):

```bash
export CADRE_ROOT=$HOME/CADRE
export CADRE_AUTOMATION_ROOT=$HOME/CADRE/attack-matrix/04-automation/linux
export PATH="$HOME/CADRE/tools/red-strike/.venv/bin:$PATH"
# export REDSTRIKE_SEED=...          # local seed JSON
# export REDSTRIKE_WS01_SSH_KEY=...  # local private key path
```

`redstrike check` core must be `ok` before a campaign dry-run. Live `--execute` also needs operator tools on PATH (`nxc`, Certipy, bloodyAD) — `redstrike check --execute-ready`.

After sister RedStrike moves, re-run `.\tools\sync-redstrike-pin.ps1 -PushKali`. Do not wait for a Plan 01 feature request. `~/RedStrike` on provisioning is an overlay of the pin, not a second source of truth.

---

## Dual operator modes (simulate both)

| Mode | Flag | Where process runs | Attack egress | Use when |
|------|------|--------------------|---------------|----------|
| **Hybrid** | `--operator provisioning` | Kali / provisioning `.60` | SSH / `ws01-exec` → ws01 | Full graph incl. H, E, F, Branch D linux01 |
| **Native** | `--operator ws01` | Domain-joined **ws01** | Local tools (`local-ws01`) — no SSH wrap | Rule 1–strict spine / A / B / C |

Defaults: win32 → `ws01`; Linux → `provisioning`. Override with `REDSTRIKE_OPERATOR`.

```bash
# Hybrid (current) — on provisioning
redstrike-campaign start --beachhead windows --operator provisioning --engage lab-hybrid
bash ~/CADRE/attack-matrix/04-automation/linux/redstrike-dfir-full.sh
```

```powershell
# Native — on ws01 (RedStrike installed there)
$env:CADRE_ROOT = "C:\path\to\CADRE"   # or clone/sync
redstrike-campaign start --beachhead windows --operator ws01 --engage lab-native
.\attack-matrix\04-automation\windows\redstrike-campaign-v3-ws01-native.ps1 -DryRun
# then: -Execute  (CADRE_ROOT set → no HITL pause)
```

**Beachhead** still selects attack identity / path preference (`windows`→ws01 path, `linux`→`.60` direct). **Operator** selects where the orchestrator itself runs.

---

## Routing (locked)

| Beachhead | Egress (operator=provisioning) | Egress (operator=ws01) | Telemetry |
|-----------|--------------------------------|------------------------|-----------|
| `--beachhead windows` | **ws01** (`ws01-exec` / SSH intents) | **local-ws01** | Full (Elastic on CADRE-All) |
| `--beachhead linux` | provisioning `.60` direct | N/A for native spine | Blind origin OK |
| `stage_mbr01` | **Exception only** (`--allow-mbr01-stage`) | same | Not default post-P3 home |

Attack identity = `analyst_t1` (or earned creds). **Never** `vagrant` for WT# steps.

---

## Operator loop

```bash
# Plan 01 — on provisioning: use the CADRE pin, not ~/RedStrike
#   python3 -m venv ~/CADRE/tools/red-strike/.venv
#   source ~/CADRE/tools/red-strike/.venv/bin/activate
#   pip install -e ~/CADRE/tools/red-strike
export CADRE_ROOT=$HOME/CADRE
export CADRE_AUTOMATION_ROOT=$HOME/CADRE/attack-matrix/04-automation/linux
export PATH="$HOME/CADRE/tools/red-strike/.venv/bin:$PATH"
# Seed and SSH key stay on the operator host (never commit). Example:
#   export REDSTRIKE_SEED=$HOME/CADRE/attack-matrix/Campaign/automation/lab-seed-creds.json
#   export REDSTRIKE_WS01_SSH_KEY=$HOME/.ssh/<your-ws01-key>

redstrike-campaign start --beachhead windows --operator provisioning --engage lab1
redstrike-campaign run --phase 1-3 --beachhead windows --operator provisioning --engage lab1          # spine dry-run
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

Harnesses:

| Harness | Mode |
|---------|------|
| `04-automation/linux/redstrike-dfir-full.sh` | `--operator provisioning` (90-node DFIR; dry-run default) |
| `04-automation/windows/redstrike-campaign-v3-ws01-native.ps1` | `--operator ws01` |
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
- **Phase 3.5** ✅ — T035-CREDS (mimikatz on mbr01 as SYSTEM), T035A (Winlogon auto-logon for `CADRE\analyst_cloud`; password not published here), T101 (WinRS pivot ws01 → mbr01).
- **Phase 4** skipped per user instruction.
- **Phase 5** ⚠️ — T102 coercion produced `T102_KIRBI_COUNT=0` (blocked, same as scripted run); T017 paused at HITL `persistence` gate.
- **Phase 6/7** ⚠️ bypassed — WT031 password spray validated `chief_command` (DA+EA) and root `krbtgt` was DCSync'd (NT hash captured; not published here).
- **Phase 8 T033** ✅ — cross-forest Kerberoast from `ws01` to `range.local` captured `svc_mssql` and `svc_sccm` TGS hashes.
- **Phase 8 SCCM branch** ⚠️ BLOCKED — no SCCM site server on `mbr02`.

**Engine note (2026-08-03):** **0.5.1** routes typed intents on `path: ws01` through OpenSSH → PowerShell (`ws01_transport.py`). Bash harness scripts (`mechanism: ws01-exec`) still run locally on provisioning and call `ws01-exec.sh` themselves. Use `--prefer-script` when graph nodes point at verified `campaign-a/*.sh` wrappers. Ensure `PATH` includes `/usr/bin` when invoking `redstrike-campaign` from minimal SSH sessions (or rely on 0.5.1 `resolve_executable` fallback).

---

## Graph v9 + full harness (2026-08-03)

**Graph:** `automation/campaign-graph.yaml` **v9** — 90 nodes. Wired scripts for H-01..H-06, Post-DA T097–099/T105/T106/T109, T035C, Branch D T044–T048 (linux01-exec), UnPAC, ESC2/4/7/9, T031 spray. **Stubs only (deferred):** T100, T103, T104, T107, T108, T-SQL-AI, WT093.

**Harness:** `04-automation/linux/redstrike-dfir-full.sh` schedules spine + A (4–5) + B + C + D + G + H + E/F + sql-ai (pin PATH, dry-run default; `--execute` after reboot+wipe). `redstrike-campaign-v3-full-run.sh` forwards here.

```bash
export CADRE_ROOT=$HOME/CADRE
export CADRE_AUTOMATION_ROOT=$HOME/CADRE/attack-matrix/04-automation/linux
export REDSTRIKE_SEED=$HOME/CADRE/attack-matrix/Campaign/automation/lab-seed-creds.json
export REDSTRIKE_WS01_SSH_KEY=$HOME/.ssh/<your-ws01-key>
export PATH=/usr/bin:/bin:$HOME/CADRE/tools/red-strike/.venv/bin:$PATH
bash ~/CADRE/attack-matrix/04-automation/linux/redstrike-dfir-full.sh
```

The 2026-08-03 live pass used a standalone `~/RedStrike` venv. **Plan 01 now uses the pin** (`CADRE/tools/red-strike/`). Keep `REDSTRIKE_WS01_*` and seed paths in the environment; do not commit keys.

**Seed:** includes `chief_command`, `hunter_dfir`, `lead_engineering`, `analyst_cloud` for gated nodes.

---

## RedStrike Campaign v3 full run (2026-08-03 — pre-v9 baseline)

**Engagement:** `camp-v3-20260803` · **Host:** provisioning `192.168.77.60` · **Log:** `~/redstrike-runs/camp-v3-20260803-20260803T064441Z.log`  
**Harness:** `attack-matrix/04-automation/linux/redstrike-campaign-v3-full-run.sh` (historical name; now forwards to `redstrike-dfir-full.sh`)  
**Flags:** `--execute --prefer-script --no-stop-on-hitl` (all gates pre-approved for automation pass)

```bash
export CADRE_ROOT=$HOME/CADRE
export CADRE_AUTOMATION_ROOT=$HOME/CADRE/attack-matrix/04-automation/linux
export REDSTRIKE_WS01_SSH_KEY=$HOME/.ssh/<your-ws01-key>
export PATH=/usr/bin:/bin:$HOME/CADRE/tools/red-strike/.venv/bin:$PATH
bash ~/CADRE/attack-matrix/04-automation/linux/redstrike-dfir-full.sh
```

| Result | Nodes |
|--------|--------|
| **OK** | Spine P1–3: T003, T002, T041; P3.5–4: T035-CREDS, T035A, T101, T004-MBR01-BH, T004-BH; P5–8: T017, T009, T010, T011, T033, T042; Branch A: T023, T008, T024; Branch B: T050, T051, **T056** (ESC8 surface); Branch C: T034–T039; Stream E: WT069–WT081; Stream F: F01–F10 |
| **FAIL** | T043 (GodPotato/LPE), T102-COERCE-DC02, T012 (diamond ticket); Branch D: T045, T047, T048 |
| **SKIP (stub)** | H-ASSUME, H-01..H-06, T097–T109, T100, T103, T104, T107, T108, T109, T-UNPAC, WT093 |

**ESC8 / krbrelayx (WT052 / graph T056):** krbrelayx HTTP listener verified on ws01; full Kerberos-relay chain **not achieved** (no coerce → krb HTTP). RedStrike **T056** runs `T052-esc8-ws01.sh` — web-enrollment surface check only → **OK** after ledger seed sync (`chief_command` in `lab-seed-creds.json`).

**Known FAIL class (same as manual spine):** T102 coercion (KIRBI capture), T012 obfuscated Rubeus diamond, Branch D linux01 scripts (env/creds), T043 GodPotato path.

**Final state:** `status: complete`, `pending_gate: null`. Maintainer validation ledgers (`REDSTRIKE-VALIDATION-REPORT.md`, gitignored) hold run history. **Next:** Plan 1 telemetry (operator review).

## MCP tools

With API up (`redstrike-api --profile campaign`):

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
