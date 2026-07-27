# CADRE Main Lab — Canonical Checklist

**Path:** `CHECKLIST.md` (repo root)  
**Last updated:** 2026-07-26  
**Writer repo:** `C:\STUDY\Github\CADRE-Platform\CADRE\`  
**Scope:** Lab operations, **Plan 1.1 campaign automation (RedStrike)**, **campaign execution**, **Plan 1 telemetry catalog**, **log corpus for DFIR-Nexus**, integrations — **not** per-exercise study progress (`plan1.7-exercises.md` / `plan1.8-exercises.md`).

> **Execution mode (2026-07-26):** Agents/operators fulfill checklist items from **provisioning** without waiting for manual runbook study. Learning is parallel and optional. Flip `CHECKLIST.md` first; docs follow evidence.
>
> **NEXT ACTION (locked):** **Plan 1 telemetry (P1)** — ES proof → grid after automated/manual runs. **Plan 1.1 M0–M5 + P11.6 live smoke done**. Product: [`red-strike-product.md`](docs/internal/integrations/red-strike-product.md).
>
> **Naming:** `plan01-telemetry-catalog/` = **Plan 1**. `plan1.1-campaign-automation/` = **Plan 1.1**. `plan00-foundation/` = **Plan 0**. See [`docs/internal/PLANS.md`](docs/internal/PLANS.md).

**Status legend:**

| Mark | Meaning |
|------|---------|
| `[x]` | **DONE** — verified end-to-end (or explicitly shipped + accepted) |
| `[ ]` | **PENDING** — on the active to-do list |
| `[~]` | **DEFERRED** — postponed by decision |
| `[!]` | **NOT STARTED** — known work, no progress yet |
| `[?]` | **USER DECISION** — blocked on your choice |

**Companion docs (read before flipping items):**

| Doc | Role |
|-----|------|
| [`docs/internal/ACTIVE.md`](docs/internal/ACTIVE.md) | Session pointer — update at start/end |
| [`Tools/vm-access.md`](Tools/vm-access.md) | SSH to provisioning + ES query templates |
| [`attack-matrix/Campaign/LAB-PROFILES.md`](attack-matrix/Campaign/LAB-PROFILES.md) | Which VMs to power |
| [`attack-matrix/Campaign/Runbooks/CAMPAIGNS-RUNBOOK-README.md`](attack-matrix/Campaign/Runbooks/CAMPAIGNS-RUNBOOK-README.md) | Phase runbook index |
| [`docs/internal/plan1.1-campaign-automation/README.md`](docs/internal/plan1.1-campaign-automation/README.md) | **Plan 1.1** — RedStrike campaign automation (**next**) |
| [`docs/internal/plan01-telemetry-catalog/phase1-source-matrix/README.md`](docs/internal/plan01-telemetry-catalog/phase1-source-matrix/README.md) | Plan 1 telemetry pipeline |
| [`attack-matrix/Campaign/DFIR-Nexus-Pioneer-workflow.md`](attack-matrix/Campaign/DFIR-Nexus-Pioneer-workflow.md) | Attack ↔ DFIR bridge |
| [`DFIR-Nexus/Docs/internal/LEARN-TEST-SHOWCASE-PUBLISH.md`](../DFIR-Nexus/Docs/internal/LEARN-TEST-SHOWCASE-PUBLISH.md) | DFIR golden path (CADRE = evidence source) |
| [`Praxis/docs/internal/LEARN-TEST-SHOWCASE-PUBLISH.md`](../Praxis/docs/internal/LEARN-TEST-SHOWCASE-PUBLISH.md) | Praxis golden path (parallel; code scan, not log ingest) |
| [`docs/internal/PLANS.md`](docs/internal/PLANS.md) | **Plan order + naming** (`plan01-*` = Plan 1) |
| [`tools/README.md`](tools/README.md) | In-tree integrations — gated by plan stage |

**Workflow (each session):**

1. Update **this file first** when an item changes status.  
2. Propagate to the **Owned by** doc (`tracker.md`, runbook, metadata, integration 1-pager).  
3. Append one line to [`docs/internal/ACTIVE.md`](docs/internal/ACTIVE.md) handoff log.

**Item ID format:**

| Prefix | Area |
|--------|------|
| **A.** | Lab access, SSH, profiles, VM health |
| **C.** | Campaign v3 execution (attack spine + branches + E/F/G/H) |
| **P11.** | Plan 1.1 — RedStrike campaign automation (**DONE** 2026-07-26) |
| **P1.** | Plan 1 — telemetry source matrix + rules + Sigma catalog |
| **P17.** | Plan 1.7 — defense engineering deploy (rules + infra) |
| **P18.** | Plan 1.8 — offensive upgrades deploy (with verified attacks) |
| **L.** | **Log corpus** — CADRE exports → DFIR-Nexus / showcase |
| **D7.** | DFIR-Nexus **CADRE-integrated** (lab wiring + Pioneer loop) |
| **D7S.** | DFIR-Nexus **standalone** showcase (host / public sibling) |
| **P07.** | Plan 0.7 — network defense (monitor VM) |
| **P08.** | Plan 0.8 — npm supply-chain |
| **I.** | Integrations (Ansible, Red-Strike, RevEng bridge, Praxis touchpoints) |
| **O.** | Cross-cutting docs / hygiene |
| **N0.** | Open decisions |

**Per-attack telemetry sub-checklist** (repeat for every WT# / T#):

`[ ]` Surface check (guide or probe for SQL/ADCS/SCCM; ansible for core AD) · `[ ]` Run attack from provisioning · `[ ]` `tracker.md` raw JSON · `[ ]` `verification-table.md` · `[ ]` `source-matrix-grid.md` P/C · `[ ]` `L.*` evidence bundle (if DFIR lane active)

---

## Summary (counts)

| Area | `[x]` | `[ ]` | `[~]` | `[!]` | `[?]` | Total |
|------|------:|------:|------:|------:|------:|------:|
| A — Access & ops | 3 | 2 | 0 | 0 | 0 | 5 |
| C — Campaign v3 | 3 | 12 | 0 | 4 | 0 | 19 |
| **P11 — Campaign automation** | **8** | **0** | **0** | **0** | **0** | **8** |
| P1 — Telemetry catalog | 2 | 8 | 0 | 0 | 0 | 10 |
| P17 — Defense engineering | 0 | 6 | 0 | 0 | 0 | 6 |
| P18 — Offensive upgrades | 0 | 4 | 0 | 0 | 0 | 4 |
| L — Log corpus | 5 | 5 | 0 | 0 | 0 | 10 |
| D7 — DFIR integrated | 1 | 0 | 9 | 0 | 1 | 11 |
| D7S — DFIR standalone | 0 | 2 | 5 | 0 | 0 | 7 |
| P07 — Network defense | 3 | 1 | 1 | 0 | 0 | 5 |
| P08 — Supply chain | 1 | 2 | 1 | 0 | 0 | 4 |
| I — Integrations | 2 | 4 | 2 | 0 | 0 | 8 |
| O — Cross-cutting | 3 | 1 | 0 | 0 | 0 | 4 |
| N0 — Decisions | 1 | 0 | 0 | 0 | 2 | 3 |
| **TOTAL** | **30** | **45** | **15** | **4** | **3** | **97** |

**Top priorities — Plan 1 next (Plan 1.1 closed):**

> **Plan 1 two-phase strategy (locked 2026-07-27):**
> - **Phase 1 — Full RedStrike attack run** across the campaign: validates tool capability + campaign/attack-surface design. Live `--execute`, operator-gated per phase (HITL).
> - **Phase 2 — Telemetry capture:** once the attack run is green across the board, replay attacks deterministically and capture telemetry across all sources → grid fill → rules. Easy + fast since we control the attack.
> - VMs currently down — operator starts them when ready.

1. **P1:** Automated/manual runs → ES proof → `verification-table.md` → `source-matrix-grid.md` → bundle.  
2. **P1.6–P1.9** — Elastic rules + E2E after PRIMARY confirmed.  
3. **L.3–L.4** — Evidence bundles (DFIR later — **no D7 ingest until Plan 1 done**).  
4. **Live `--execute`** — operator-gated per phase (HITL); dry-run smoke already green on `.60`.

**Unblocked:** ws01 `.62` — WinRM/config lane + T042 + Elastic CADRE-All. OU=`WS01-MDE` rename deferred.

---

## A — Access & lab operations

| ID | Item | Status | Done | Owned by | Notes |
|----|------|--------|------|----------|-------|
| A.1 | `Tools/vm-access.md` — provisioning SSH + ES + Plan 1 workflow | [x] | 2026-07-25 | `Tools/vm-access.md` | Template mirrors RevEng `vm-access.md` |
| A.2 | SSH key `cadre-provisioning-key` in `.ssh` + icacls | [x] | 2026-07-25 | `Tools/vm-access.md` § SSH | From `.vagrant.d\insecure_private_key`; Vagrant `insert_key=false` |
| A.3 | Smoke: `ssh vagrant@192.168.77.60` + ES HTTP on `.50` | [x] | 2026-07-25 | — | `elastic` password per ansible `group_vars` |
| A.4 | Document VM dir + `vagrant global-status` in vm-access | [x] | 2026-07-25 | `Tools/vm-access.md` | `C:\Users\Ganro\VMs\CADRE`; all core+ext running except legacy `kali` VM |
| A.5 | Optional: `Host cadre-prov` in `~/.ssh/config` | [ ] | | operator | Snippet in vm-access |

---

## C — Campaign v3 execution

**Runbook:** [`CAMPAIGNS-RUNBOOK-*.md`](attack-matrix/Campaign/Runbooks/) · **Narrative:** [`CAMPAIGNS_v3.md`](attack-matrix/Campaign/CAMPAIGNS_v3.md) · **Metadata:** [`CAMPAIGNS-METADATA.md`](attack-matrix/Campaign/CAMPAIGNS-METADATA.md)

| ID | Phase / stream | Profile | Status | Attack | Tracker | Metadata | Notes |
|----|----------------|---------|--------|--------|---------|----------|-------|
| C.0 | Phase 0 — Recon | P-CHILD | [ ] | [ ] | [ ] | [ ] | Unauth recon, Kerberos enum, NetExec modules |
| C.0.5 | Phase 0.5 — ws01 beachhead | **P-BEACH** | [ ] | [ ] | [ ] | [ ] | H-01..H-06; **ws01 live** (CADRE-All + soft Defender) — attack path pending |
| C.1 | Phase 1 — AS-REP | P-CHILD | [x] | [x] | [x] | [~] | WT003/T003; re-verified 2026-07-25 |
| C.2 | Phase 2 — Kerberoast | P-CHILD | [x] | [x] | [x] | [~] | WT002; re-verified + bundle 2026-07-25 |
| C.3 | Phase 3 — SQL → GodPotato | P-CHILD | [x] | [x] | [~] | [~] | Needs **mbr01** up |
| C.3.5 | Phase 3.5 — Credential access | P-CREDS | [ ] | [ ] | [ ] | [ ] | Active per runbook README |
| C.4 | Phase 4 — BH / delegation | P-DELEG | [ ] | [ ] | [ ] | [ ] | |
| C.5 | Phase 5 — Persistence / coercion | P-DELEG | [ ] | [ ] | [ ] | [ ] | |
| C.6 | Phase 6 — DCSync | P-DELEG | [ ] | [ ] | [ ] | [ ] | |
| C.7 | Phase 7 — Golden / alt persistence | P-FOREST | [ ] | [ ] | [ ] | [ ] | |
| C.8 | Phase 8 — Cross-forest | P-FOREST | [ ] | [ ] | [ ] | [ ] | |
| C.A | Branch A — ACL abuse | P-DELEG | [!] | [ ] | [ ] | [ ] | |
| C.B | Branch B — ADCS | P-DELEG | [!] | [ ] | [ ] | [ ] | |
| C.C | Branch C — SCCM | P-FOREST | [!] | [ ] | [ ] | [ ] | |
| C.D | Branch D — Linux pivot | P-LINUX | [!] | [ ] | [ ] | [ ] | |
| C.E | Stream E — Network defense (14) | P-PURPLE | [ ] | [ ] | [ ] | [ ] | Plan 0.7 overlap |
| C.F | Stream F — Supply chain (10) | P-CHILD + linux01 | [ ] | [ ] | [ ] | [ ] | Plan 0.8 |
| C.G | Stream G — Pre-auth DC CVE lab | snapshot | [~] | [ ] | [ ] | [ ] | Deferred per campaign |
| C.H | H-01..H-06 placeholders | P-BEACH | [ ] | [ ] | [ ] | [ ] | In `tracker.md`; ws01 reachable — execute when ready |

**Campaign hygiene (each phase complete):**

| ID | Item | Status | Owned by |
|----|------|--------|----------|
| C.X1 | Runbook + `CAMPAIGNS_v3.md` section kept in sync | [ ] | Runbooks |
| C.X2 | `python tools/split-campaign-runbooks.py --check` after bulk v2 edits | [~] | v3 manual sync |
| C.X3 | `Campaign_suggestions.md` reviewed before next phase | [ ] | Research backlog |

---

## P11 — Plan 1.1 campaign automation (RedStrike) — **NEXT**

**Plan:** [`docs/internal/plan1.1-campaign-automation/`](docs/internal/plan1.1-campaign-automation/) · **Sister:** [`RedStrike/CAMPAIGN-AUTOMATION-PLAN.md`](../RedStrike/CAMPAIGN-AUTOMATION-PLAN.md) · **Routing:** [`WS01-ROUTING.md`](attack-matrix/04-automation/linux/lib/WS01-ROUTING.md)

> Plan 1.1 **complete** (M0–M5 + P11.6). Automates spine + Branches A–D/G + E/F streams under provisioning→ws01 rules so Plan 1 telemetry can scale.

| ID | Item | Status | Done | Owned by | Notes |
|----|------|--------|------|----------|-------|
| P11.0 | Plan docs committed (CADRE plan1.1 + RedStrike mirror) | [x] | 2026-07-25 | `plan1.1-campaign-automation/` · `RedStrike/CAMPAIGN-AUTOMATION-PLAN.md` | Registered in `PLANS.md` |
| P11.0a | **M0** — lab beachhead + playbooks + live verify | [x] | 2026-07-25 | `17-ws01-deploy.yml` · `12-elk-fleet.yml` · `WS01-ROUTING.md` · `CAMPAIGNS_v3.md` | Live: WinRM, T042, `analyst_t1` Admin, Elastic **CADRE-All**, soft Defender, **no MDE**; CADRE-WS01 policy removed |
| P11.1 | **M1** — BeachheadRouter + CredentialLedger + `cadre-campaign` + Phases 1–3 graph | [x] | 2026-07-25 | `RedStrike\` → sync `tools/red-strike/` | dry-run + 10 unit tests; graph at `Campaign/automation/campaign-graph.yaml` |
| P11.2 | **M2** — Full spine Phase 0.5–8 + HITL gates + MCP `campaign_*` | [x] | 2026-07-25 | `RedStrike\` + `Red-Strike-workflow.md` | Gates: dcsync/ticket/forest/persistence; API `/campaign/*` |
| P11.3 | **M3** — Branches A–D + UnPAC + SCCM 35–39 + SQL AI + G | [x] | 2026-07-25 | graph v3 + `--branch` + `lab-profiles.yaml` | Seeds/graph = CADRE glue; engine generic |
| P11.4 | **M4** — Typed intents (Rubeus/mimikatz/SQL/bloodyAD/Certipy) | [x] | 2026-07-25 | `cadre_strike/builders/` + `intent:` | MCP `build_intent`; `--prefer-script` harness |
| P11.5 | **M5** — E/F thin stream runners | [x] | 2026-07-26 | `RedStrike\` + `linux/campaign-e|f/` + graph v5 | `stream E|F`; path `external60_phase0`; **0.5.0** |
| P11.6 | Install RedStrike on provisioning + smoke `redstrike-campaign` Phases 1–3 | [x] | 2026-07-26 | `.60` `~/RedStrike` + `~/CADRE` | venv 0.5.0; dry-run OK: P1–3 win/linux + stream E/F |

**Do next:** **Plan 1** telemetry. Deferred: OU=`WS01-MDE` migrate; residual route-ID strip; live `--execute` per phase.

---

## P1 — Plan 1 telemetry catalog

**Pipeline:** fill grid → write rules → E2E → Sigma YAML. **Dir:** [`docs/internal/plan01-telemetry-catalog/phase1-source-matrix/`](docs/internal/plan01-telemetry-catalog/phase1-source-matrix/)

**Two-phase approach (2026-07-27):** Phase 1 = full RedStrike campaign run (tool + campaign validation); Phase 2 = deterministic replay → telemetry capture → grid. VMs down until operator starts.

| ID | Item | Status | Done | Owned by | Notes |
|----|------|--------|------|----------|-------|
| P1.0 | **Phase 1 — full RedStrike attack run** (validate tool + campaign) | [ ] | | `redstrike-campaign` on `.60` | Live `--execute`, HITL per phase; VMs down — waiting on operator |
| P1.1 | Field dictionary populated (`elastic-field-dictionary/`) | [x] | 2026-06+ | `elastic-field-dictionary/` | roadmapv2 §2.2 stale — dirs exist |
| P1.2 | `source-matrix-grid.md` framework + T002/T003 partial | [x] | partial | `source-matrix-grid.md` | ~98% rows still blank |
| P1.3 | **Grid fill — Campaign A** (12 attacks) | [~] | 2026-07-25 | `source-matrix-grid.md` + `verification-table.md` | ✅ T002/T003/T031/T041/T043; ⛔ T028; 🔧 T042; 5 cred-gated |
| P1.4 | **Grid fill — Campaign B–D + ADCS + coercion** (59) | [ ] | | same | Batched by profile |
| P1.5 | **Grid fill — E + F + G + H** (41) | [~] | 2026-07-25 | same | E: 10✅ + 5 blocked/deferred; F/G/H ⏳ |
| P1.6 | **P0a** — Install pre-built Elastic SIEM rules | [ ] | | `state01.md` | Blocked on grid for priority attacks |
| P1.7 | **P0c** — Custom `cadre-*` gap rules (~34) | [ ] | | `07-detection-rules/` | After PRIMARY assignment |
| P1.8 | **P0c-EDR** — `cadre-e*` endpoint rules | [ ] | | plan01 / elk Fleet | Basic license — events only |
| P1.9 | **P0b** — Full 100-attack E2E | [ ] | | `verification-table.md` | After P0a+P0c |
| P1.10 | **Sigma catalog** — `attack-matrix/06-telemetry-catalog/` | [ ] | | `06-telemetry-catalog/` | **2/110** (T002, T003 YAML exist) |

**Grid fill progress (manual — update when batch completes):**

| Stream | Attacks | Grid filled | Tracker filled |
|--------|--------:|------------:|---------------:|
| Campaign A | 12 | 7 | 6 |
| Campaign B | 10 | 0 | 0 |
| Campaign C | 13 | 0 | 0 |
| Campaign D | 5 | 0 | 0 |
| ADCS ESC | 13 | 0 | 0 |
| Coercion | 6 | 0 | 0 |
| E — Net def | 23 | 15 | 10 |
| F — npm | 10 | 0 | 0 |
| G — MITRE gap | 11 | 0 | 0 |
| H — Initial access | 6 | 0 | 0 (placeholders) |
| **Total** | **~110** | **21** | **6+** |

---

## P17 — Plan 1.7 defense engineering (deploy with Plan 1)

**Folder:** [`docs/internal/plan1.7-defense-engineering/`](docs/internal/plan1.7-defense-engineering/) · **Specs:** [`plan01-upgrades/plan1.7-defense-deepening.md`](docs/internal/plan01-upgrades/plan1.7-defense-deepening.md) · **Exercises:** [`plan01-upgrades/plan1.7-exercises.md`](docs/internal/plan01-upgrades/plan1.7-exercises.md)

| ID | Item | Status | Owned by | Notes |
|----|------|--------|----------|-------|
| P17.1 | Map plan1.7 § sections → Fleet rule deploy batches | [ ] | `plan1.7-defense-deepening.md` | After P1 PRIMARY per attack |
| P17.2 | Deploy Linux Sigma rules (§15 — 7 rules) to `extensions/elk-fleet/` | [ ] | `07-linux-config.yml` + Fleet | Sysmon for Linux prerequisite |
| P17.3 | Deploy Suricata SIDs from plan1.7 (1000104–1000108, etc.) | [ ] | `13-net-monitor.yml` | Cross-ref verification-table |
| P17.4 | Elastic KQL `cadre-*` gap rules from plan1.7 §11–§17 | [ ] | P1.7 + P1 P0c | Same rules as P1.7 — deploy via P0c track |
| P17.5 | EX-60 SO-CRATES on monitor (optional cross-cut) | [ ] | roadmapv2 Plan 9 | P07.5 overlap |
| P17.6 | Exercise library EX-01..60 — track separately from CHECKLIST | [~] | `plan1.7-exercises.md` | Study path; not deployment gate |

---

## P18 — Plan 1.8 offensive upgrades (deploy with verified attacks)

**Folder:** [`docs/internal/plan1.8-offensive-upgrades/`](docs/internal/plan1.8-offensive-upgrades/) · **Specs:** [`plan01-upgrades/plan1.8-offensive-upgrades.md`](docs/internal/plan01-upgrades/plan1.8-offensive-upgrades.md)

| ID | Item | Status | Owned by | Notes |
|----|------|--------|----------|-------|
| P18.1 | Map plan1.8 §10 Plan 11 techniques → campaign phase gates | [ ] | `plan1.8-offensive-upgrades.md` | Deploy only after spine phase verified |
| P18.2 | npm supply-chain scenarios F-11..F-13 (held from §10) | [~] | P08 + plan1.8 | After F-01..F-10 |
| P18.3 | Linux offensive EX-OFF-32..37 — ansible/linux01 when Phase D active | [ ] | `07-linux-config.yml` | Pairs with P17 Linux rules |
| P18.4 | Exercise library EX-OFF-01..37 — study track only | [~] | `plan1.8-exercises.md` | Not CHECKLIST deployment gate |

---

## L — Log corpus (CADRE → DFIR-Nexus / showcase)

> **Core idea:** CADRE lab generates **real telemetry** during Plan 1 runs. Export structured bundles on provisioning; DFIR ingest (**D7***) deferred until Plan 1 complete.

**Target layout (gitignored runtime; manifest in repo):**

```text
~/cadre-evidence/                    # on host or provisioning
  <CASE-ID>-<phase>-<YYYYMMDD>/
    manifest.json                      # attack id, T0/T1, VMs, queries used
    elastic/                           # ES _search exports (WinSec, Sysmon, Endpt, Zeek, Suri)
    zeek/                              # optional raw logs from monitor
    suricata/                          # eve.json slice
    evtx/                              # optional host exports (VR / manual)
    notes.txt                          # operator notes
```

| ID | Item | Status | Owned by | Notes |
|----|------|--------|----------|-------|
| L.1 | Adopt bundle directory + `manifest.json` schema (minimal) | [x] | `Tools/cadre-es-export.sh` | 2026-07-25 |
| L.2 | ES export script on provisioning (`cadre-es-export.sh`) | [x] | `/home/vagrant/cadre-es-export.sh` | 15m lookback |
| L.3 | **Bundle: T003 AS-REP** (2026-07-25 run) | [x] | `~/cadre-evidence/CADRE-T003-ASREP-20260725/` | WinSec 6 / Zeek 7 / Suri 62 |
| L.4 | **Bundle: T002 Kerberoast** | [x] | `~/cadre-evidence/CADRE-T002-KERB-20260725/` | WinSec 6 / Zeek 7 / Suri 62 |
| L.5 | **Bundle: Phase 3.5** (first cred technique) | [ ] | same | Tie to `DFIR-Nexus-Pioneer-workflow.md` |
| L.6 | **Bundle: H-01** (ws01 initial access) | [ ] | same | Sysmon + Elastic Defend events (CADRE-All) |
| L.7 | Zeek raw log pull from monitor `.55` (optional) | [ ] | Ansible / SSH | Complement ES `logs-zeek.*` |
| L.8 | Suricata EVE pull from monitor (optional) | [ ] | same | Index: `logs-suricata.eve-*` |
| L.9 | Index of bundles in `docs/internal/evidence-catalog.md` | [x] | `evidence-catalog.md` | 2026-07-25 |
| L.10 | Retention policy (size / PII / no cracked hashes in git) | [ ] | `O.4` | Gitignore `cadre-evidence/` on operator machine |

---

## D7 — DFIR-Nexus integrated (CADRE lab) — **DEFERRED until Plan 1 complete**

> **Plan order:** Plan 7 waits. Bundles accumulate under **`L.*`** on provisioning; ingest wiring after **P1.9**.

**Tool:** [`tools/dfir-nexus/`](tools/dfir-nexus/) · **Workflow:** [`attack-matrix/Campaign/DFIR-Nexus-Pioneer-workflow.md`](attack-matrix/Campaign/DFIR-Nexus-Pioneer-workflow.md)

| ID | Item | Status | Done | Owned by | Notes |
|----|------|--------|------|----------|-------|
| D7.1 | DFIR-Nexus E.0 feature complete (in-tree) | [x] | 2026-06-22 | `tools/dfir-nexus/docs/E0-CONSTELLATION.md` | 96 MCP tools era; counts may drift in public sibling |
| D7.2 | Pioneer smoke case (synthetic) per workflow doc | [~] | | Pioneer workflow §10-min | Deferred |
| D7.3 | Ingest **L.3** bundle → case `CADRE-T003-ASREP` | [~] | | DFIR-Nexus + `L.3` | Deferred — bundle ready on `.60` |
| D7.4 | Ingest **L.4** bundle → case `CADRE-T002-KERB` | [~] | | same | Deferred |
| D7.5 | Phase 3.5 exercise → Portal approve path | [~] | | Pioneer workflow | Deferred |
| D7.6 | Push ingest from provisioning (`push` server + token) | [~] | | `dfir_nexus.push` | Deferred |
| D7.7 | Ansible playbook on provisioning VM | [~] | | `docs/internal/integrations/dfir-nexus.md` | Deferred |
| D7.8 | Velociraptor MCP live on `.51` during 3.5 | [~] | | VR extension VM | Deferred |
| D7.9 | LangGraph 6-agent graph on provisioning | [~] | | Plan 7 | Post wiring |
| D7.10 | RevEng bridge (publish_to_cadre) | [~] | | RevEng CHECKLIST V3.18 | Sister repo |
| D7.11 | Public sibling `DFIR-Nexus/` revamp sync | [?] | | `DFIR-Nexus/REVAMP-SESSION.md` | In-tree vs public release |

---

## D7S — DFIR-Nexus standalone showcase — **DEFERRED until Plan 1 log corpus ready**

> Use **`L.*` bundles** on host when you test standalone; full showcase path after P1 grid + exports.

**Playbook:** [`DFIR-Nexus/Docs/internal/LEARN-TEST-SHOWCASE-PUBLISH.md`](../DFIR-Nexus/Docs/internal/LEARN-TEST-SHOWCASE-PUBLISH.md)

| ID | Item | Status | Owned by | Notes |
|----|------|--------|----------|-------|
| D7S.1 | Phase 0 setup: `pip install -e ".[all]"`, password, portal | [~] | DFIR LEARN doc | User can run anytime on host |
| D7S.2 | **Golden case `CV-SHOWCASE-01`** with CADRE-exported EVTX/Zeek | [~] | L.3+ | Deferred — L.3/L.4 exist on `.60` |
| D7S.3 | Feature lanes 1–7 (case, ingest, Windows tools, portal, TI, detection, advanced) | [~] | DFIR LEARN § Phase 2 | Deferred |
| D7S.4 | Tamper test on registered evidence | [~] | DFIR LEARN § Phase 1 step 11 | Deferred |
| D7S.5 | Showcase pack: recording + 5 screenshots + sanitized fixture | [~] | DFIR LEARN § Phase 4 | Deferred |
| D7S.6 | Beta tag + README honesty (tool counts) | [ ] | `DFIR-Nexus/README.md` | Public repo hygiene |
| D7S.7 | pytest + CI green on public repo | [ ] | `.github/workflows/` | |

---

## P07 — Plan 0.7 network defense (monitor `.55`)

| ID | Item | Status | Notes |
|----|------|--------|-------|
| P07.1 | Zeek scripts + Suricata rules deployed | [x] | 7 Zeek + 34 Suricata; see AGENTS.md |
| P07.2 | Attack testing batches A–D documented | [x] | AGENTS.md learnings |
| P07.3 | Re-run WT003/WT002 Suricata baseline on current stack | [x] | `logs-suricata.eve-*` in ES (2026-07-25) |
| P07.4 | Deploy plan1.7 §14+ detection candidates (UnCanny, etc.) | [~] | Held deferred |
| P07.5 | SO-CRATES deploy on monitor (EX-60) | [ ] | roadmapv2 Plan 9 cross-cut |

---

## P08 — Plan 0.8 npm supply-chain

| ID | Item | Status | Notes |
|----|------|--------|-------|
| P08.1 | linux01 + mbr01 npm stack deployed | [x] | `16-supplychain.yml` |
| P08.2 | Run F-01..F-10 scenarios + tracker rows | [ ] | Manual per install guide |
| P08.3 | F-11..F-13 expansion (held) | [~] | Session 11 items |

---

## I — Integrations

| ID | Item | Status | Notes |
|----|------|--------|-------|
| I.1 | RedStrike campaign mode on provisioning | [x] | 2026-07-26 | **Done via P11.6** — `~/RedStrike` + dry-run smoke |
| I.2 | CADRE-RevEng v3 bridge to DFIR-Nexus | [~] | V3.18 decision |
| I.3 | Praxis: optional scan of CADRE ansible/tools (dogfood) | [ ] | Praxis LEARN Phase 1 Target A = Praxis repo; CADRE is separate |
| I.4 | Praxis ↔ CADRE log story documented (DFIR consumes logs; Praxis scans code) | [ ] | `O.3` |
| I.5 | Plan 2 exporter `tools/export-attack/` (8 collectors) | [!] | Unblocks automated `L.*` |
| I.6 | Plan 3 snapshot `tools/snapshot/cycle.py` | [!] | Post exporter |
| I.7 | ws01 Fleet **CADRE-All** (Elastic Defend detect/telemetry; no MDE) | [x] | 2026-07-25 — CADRE-WS01 policy removed; enroll via `17-ws01-deploy` / `12-elk-fleet` |

---

## O — Cross-cutting

| ID | Item | Status | Notes |
|----|------|--------|----------|
| O.1 | `CHECKLIST.md` created (this file) | [x] | 2026-07-25 |
| O.2 | `ACTIVE.md` points to CHECKLIST | [x] | 2026-07-25 | ACTIVE read-first + cold-start table |
| O.3 | `ecosystem-organization.md` — add CADRE main CHECKLIST row | [ ] | Sister pattern |
| O.4 | `.gitignore` / policy for `cadre-evidence/` exports | [ ] | |
| O.5 | Refresh `roadmapv2.md` Plan 1 § (field dict exists) | [x] | `roadmapv2.md` | 2026-07-25 |

---

## N0 — Open decisions

| ID | Question | Status | Notes |
|----|----------|--------|-------|
| N0.1 | DFIR-Nexus: in-tree incubator vs public `DFIR-Nexus/` as writer | [?] | D7.11 |
| N0.2 | ws01 EDR model | [x] | **Decided 2026-07-25:** Elastic CADRE-All only; soft host Defender; no MDE. OU/GPO migrate later |
| N0.3 | Evidence bundles: host path vs provisioning-only storage | [?] | L.1 |

---

## Quick session template

Copy into ACTIVE handoff or lab journal:

```text
Session: YYYY-MM-DD
Profile powered: P-____
CHECKLIST flipped:
  - [ID] description
Attacks run: WT### / T###
Tracker/grid updated: Y/N
Bundle created: L.# path
DFIR case: name / ingest Y/N
Next: 
```
