# Changelog

All notable changes to CADRE are documented here. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added (2026-07-25 — Plan 1.1 Campaign Automation + CHECKLIST next action)

> **Scope:** Establish **Plan 1.1** (RedStrike-driven campaign automation) as the next execution track ahead of / with Plan 1 telemetry, so attack runs can scale instead of staying hand-driven. Docs + checklist only — RedStrike M1 code not started.

**What was done:**
- Created [`docs/internal/plan1.1-campaign-automation/`](docs/internal/plan1.1-campaign-automation/) — `README.md` router + `CAMPAIGN-AUTOMATION-PLAN.md` (mirror of RedStrike plan: M1–M5, ws01 routing, HITL gates, Branches A–D/G).
- Updated [`docs/internal/PLANS.md`](docs/internal/PLANS.md) — Plan **1.1** in naming table, folder table, and execution order (1.1 before/with Plan 1).
- Updated root [`CHECKLIST.md`](CHECKLIST.md) — new **P11.*** section (P11.0 docs done; P11.1–P11.6 pending); top priorities lead with Plan 1.1; `I.1` redirected to P11; companion-doc + NEXT ACTION banner.
- Updated [`docs/internal/ACTIVE.md`](docs/internal/ACTIVE.md) — next action = CHECKLIST **P11.1** (RedStrike M1).
- Sister repo: `RedStrike/CAMPAIGN-AUTOMATION-PLAN.md` + `ROADMAP.md` link + `RedStrike/CHANGELOG.md` entry (committed/pushed separately).

**Why:** Plan 1 telemetry catalog cannot move fast without repeatable attack automation. Plan 1.1 is the orchestrator; Plan 1 remains the catalog.

**Next:** Implement RedStrike **M1** (writer: `RedStrike/`) — Ws01Router + CredentialLedger + Phases 1–3.

### Changed (2026-07-16 — README & Logo Tagline Refactoring for CADRE-RevAI / RevEng)

> **Scope:** Refactored the public README.md and modified the tagline text inside the vector logo for the `CADRE-RevAI` repository, and merged/refactored the parent `CADRE-RevEng` README.md to ensure technical honesty and layout consistency.

**What was done:**
- Refactored `CADRE-RevAI/README.md` to follow the "Pragmatic Hybrid" design: clarified the deterministic stage-based pipeline architecture ("Deterministic Skeleton, Cognitive LLM Union"), cataloged internal scripts, and separated core versus experimental features (such as Z3 symbolic deobfuscation and bottom-up call-graph function recovery).
- Refactored and merged the parent `CADRE-RevEng/README.md` using `README2.md` as the source of truth, establishing an honest, clear layout describing active status tiers (v2 SQL-first, v3 UI hooks) and future v5 agentic planning.
- Updated the tagline text inside `CADRE-RevAI/assets/revai-logo.svg` from "Autonomous Malware Decompilation & Deobfuscation" to "LLM-Assisted Reverse Engineering & Signature Generation" for technical accuracy.
- Cleaned absolute `file://` local paths inside the workspace READMEs to use proper repository-relative paths for public-release compatibility.

### Changed (2026-07-13 — README & Image Asset Update for Public Release)

> **Scope:** Updated CADRE README.md and generated public-release ready image assets from vector sources.

**What was done:**
- Generated `cadre-architecture-dark.png` from `cadre-architecture-dark.svg` using headless Microsoft Edge.
- Generated `cadre-logo-godfather.png` from `cadre-logo-godfather.svg` using headless Microsoft Edge.
- Updated `README.md` to display the Godfather logo at the top, along with project status badges (License, Status, Platform) matching other sister repos.
- Updated the architecture diagram in the README to reference the new dark mode PNG (`docs/img/cadre-architecture-dark.png`) to align with the visual identity.
- Refactored README sections to match standard project formats (`Core Capabilities`, `Architecture & Data Flow`, `Project Structure & Documentation`, `Current Status & Roadmap`).

### Added (2026-07-04 — RevEng ↔ DFIR-Nexus integration plan)

> **Scope:** Joint integration plan between **CADRE-RevEng v2.0/v3** and **DFIR-Nexus v1.0.0 E.0 Constellation**. Both tools were built independently; this plan bridges them.

**Plan structure:**
- **3-layer model:** RAG search (per-corpus best-fit model, shared reranker) → LLM judge (router-agnostic, shared metadata) → output push (RevEng sample run → DFIR-Nexus case)
- **Q1 finding:** Don't rewire DFIR-Nexus. Keep bge-base-en-v1.5 (768d) for its short structured text corpus. Use bge-m3 (1024d) for RevEng's malware jargon corpus. No re-index required.
- **Q2 solution:** 5-step implementation plan
  1. RevEng → DFIR-Nexus output push (~50 LOC each side, uses existing E.0.1 push/server.py)
  2. RevEng evidence → DFIR-Nexus RAG adapter (~30 LOC, new `load_reveng_bundle()`)
  3. RevEng hashes → DFIR-Nexus TI cache (~100 LOC, new `reveng_provider.py`)
  4. Ollama embedder in DFIR-Nexus (bge-m3 indexing, ~50 LOC)
  5. RevEng in DFIR-Nexus langgraph agent graph (~150 LOC)
- **Work order:** 1 → 2 → 4 → 3 → 5
- **Hard blocker:** **V3.18** (DFIR-Nexus sharing decision — PR upstream vs local fork vs shared module). User decision required.

**Docs written (mirrors):**
- **RevEng side:** `CADRE-RevEng/Tools/integrations/dfir-nexus/PLAN.md` (full Q1+Q2 + 5-step plan + CHECKLIST refs)
- **DFIR-Nexus side:** `CADRE/tools/dfir-nexus/docs/integrations/REVENG-INTEGRATION.md` (mirror, RevEng-specific only)
- **Updated:**
  - `docs/internal/ACTIVE.md` — sister project context row + new handoff log entry
  - `docs/internal/registry.md` — already accurate; flagged as "bridge v3 (formally planned, not deferred)"

**CHECKLIST cross-references** (from `CADRE-RevEng/CHECKLIST.md`): V3.18 (sharing decision), V3.20 (GGUF source), V3.29 (Ollama wire-in), O.5 (CADRE bridge cluster), O.6 (case provisioning), O.7 (Ansible playbook).

**Next:** Wait for V3.18 user decision. Once decided, start with Step 1 (push pipeline) — smallest, highest impact, no model changes.

---

### Added (2026-06-30 — CADRE-RevEng v2.0 COMPLETE + MTA 2025/2026 real-world sample source)

> **Scope:** Finalized `CADRE-RevEng` v2.0 lab on `.41` (Linux) and `.42` (Windows). Verified T4 pipeline end-to-end on a real malware-traffic-analysis.net sample. Staged MTA 2025/2026 as the primary real-world sample corpus. Deferred v3 work (RAG, Z3, angr/CFF GhidraScript, CADRE main bridge).

**T4 pipeline verified on real MTA sample:**
- **SHA-256:** `353ddce78d58aef2083ca0ac271af93659cf0039b0b29d0d169fc015bd3610bc`
- **Source:** MTA 2026-04-16 Lumma Stealer + SectopRAT infection
- **Tool chain:** `intake.py` → `quick_scan_v2.py` → `deep_dive.py` → `yara_gen.py` → `publish_report.py`
- **Result:** verdict `malicious`, family `Lumma Stealer`, score 95, agreement `llm_and_v1_agree`

**MTA 2025/2026 staged on `.41`:**
- 85 posts, 112 ZIPs downloaded, 65 extraction dirs, ~17 GB extracted
- Routing manifest counts: 130 executables, 71 pcaps, 16 documents, 40 scripts, 376 IOC text files, 30 images, 65 archives
- Routed to:
  - `/opt/samples/mta-routing/corpus/` — 9.2 GB RevEng analysis corpus
  - `/opt/samples/mta-routing/dfir/` — 2.9 GB bridge-ready DFIR topics

**Tools updated:**
- `CADRE-RevEng/Tools/v2-deploy/stage_mta_traffic.py` — rewritten with subcommands `emit-manifest`, `stage-zips`, `classify-artifacts`, `route-to-cadre`. Parses per-post pages, auto-derives password `infected_YYYYMMDD`, uses `7z` for AES extraction with long-path and bad-unicode handling.
- `CADRE-RevEng/Tools/v2-deploy/stage_case_study.py` — `--hunt-open-sources` queries MalwareBazaar, Hybrid Analysis, Triage, OTX, VirusTotal. Confirmed free-tier API keys verify hashes but **cannot download** latest APT samples.

**Vendor case-study cleanup:**
- Active: MLTBackdoor, OceanLotus, GoFlateLoader, MustangPanda, SaassyCode + SHEET#CREEP workbook-only
- Removed: Miasma, GopherRAT-FBISE

**Constraints locked:**
- Lab interface only: `.41` = `192.168.77.41`, `.42` = `192.168.77.42`
- API keys in `/opt/secrets/cadre.env` (chmod 600): DeepSeek, ABUSECH, HA, TRIAGE, OTX, VT

**Deferred to v3:**
- CADRE main bridge (`publish_to_cadre.py` / `intake-from-cadre.py`)
- RAG layer, Z3 verification, angr/CFF GhidraScript
- Design docs: `CADRE-RevEng/Tools/v2-deploy/MTA-CADRE-SHARING.md` and `plan_v2-CADRE-integration.md`

**Files updated (RevEng repo):**
- `Tools/v2-deploy/verification-log-v2.md` — 2026-06-30 session + MTA pipeline result
- `Tools/v2-deploy/STAGING-PLAYBOOK.md` — 2025/2026 MTA scope + local routing
- `Tools/v2-deploy/_progress.md` — MTA noted as working alternative sample source
- `Tools/v2-deploy/MTA-CADRE-SHARING.md` — new design doc; bridge marked v3

**Cross-references:**
- `CADRE-RevEng/Tools/v2-deploy/plan_v2.md`
- `CADRE-RevEng/Tools/v2-deploy/plan_v2-CADRE-integration.md`
- `docs/internal/roadmapv2.md` §Plan 0.9
- `docs/internal/registry.md` CADRE-RevEng row

---

### Changed (2026-06-29 — Red-Strike in-tree relocation)

- **Red-Strike:** Agentic offense tool relocated from deprecated `CADRE-Strike/` sister repo to `tools/red-strike/` (same in-tree pattern as DFIR-Nexus). Integration doc: `docs/internal/integrations/red-strike.md`. Cursor rule: `.cursor/rules/red-strike.mdc`.
- **Registry / ACTIVE / workspace:** `CADRE-Strike` removed from sister list; `CADRE-DarkAI` added. `CADRE-ALL.code-workspace` updated.
- **Deprecated:** `CADRE-Strike/` retained as redirect stub only; `cadre-strike.md` integration doc removed (superseded by `red-strike.md`).

### Fixed (2026-06-27 — CADRE-Platform folder migration repair)

- **Filesystem:** Merged accidental nested `CADRE/CADRE/` into repo root — restored `lab/`, `tools/` (regen-config, campaign scripts, dfir-nexus), `docs/internal/plan01-upgrades/`, `_canonical/`, `process/`, `references/sources`, `tests/`. Removed nested folder and old `Github\CADRE\NUL` stub (replaced with README pointer).
- **Docs:** Updated `registry.md`, `ACTIVE.md`, `ecosystem-organization.md` (Option B executed), `DOC-MAP.md` (ACTIVE + registry entries). Path sweep across platform to `C:\STUDY\Github\CADRE-Platform\`.
- **Workspace:** Canonical entry `CADRE-Platform\CADRE-ALL.code-workspace` + `CADRE-Platform\README.md`.

### Added (2026-06-25 — AMSI Bypass Detection Engineering [Session 16])

> **Source:** [One Bool. Six Shells. AMSI's Design Problem](https://bl4ckarch.github.io/posts/One-Bool.-Six-Shells.-AMSI%27s-Design-Problem/) by bl4ckarch, 2026-06-25. Per user direction: "you can update these 2 and remove from Todo" — apply the bl4ckarch research to plan1.7 §16 + Campaign_suggestions Item #109.

**What changed:**
- **plan1.7-defense-deepening.md §16 AMSI Bypass Detection Engineering added (~12 KB)** — 5 Sigma rules + Elastic KQL `cadre-010-amsi-bypass` + memory forensics + 6 architectural findings + root cause mitigations. See plan1.7 §16 for full content.
- **AMSИ bypass AD-specific tracking** — kept in `docs/internal/plan01-upgrades/ad-evasion-gap-analysis.md` reference doc (sister project integration; per user: "AMSI goes int this if you thin its rlevant to AD only" — AMSI IS AD-specific since PowerShell bypass is core to AD attack chains).

**Removed (session 16 — partial revert):**
- **Campaign_suggestions.md Item #109 (AMSI Bypass) FULLY REMOVED** — per user direction (2026-06-25):
  - "Remove AMSI from campaign_suggestions entirely as it has nothing to do with campaign (we disabled defender - no relevance now)"
  - "remove any mistaken defense work from this doc as well"
  - Routing clarified: AD-specific evasion goes in `ad-evasion-gap-analysis.md` (held for future cross-project integration); defensive detection goes in plan1.7 (already in §16)
  - 6 places removed: Phase mapping table, Testing Checklist table, Tier 3 Summary table, Cross-Reference Index (with replacement marker "Item REMOVED"), source-style entry, full mechanics section
- **Item count:** 102 → 101 items (1 removed)
- **Numbering:** Item #109 retired. Next Item = #110 (DCShadow), #111 (Rubeus cross-validation), #112-115 (study refs) — no renumbering needed, gap is intentional.

**Files updated (2 total):**

1. **`docs/internal/plan01-upgrades/plan1.7-defense-deepening.md`** — §16 AMSI Bypass Detection Engineering added (~12 KB):
   - §16.1 Why the previous 3 Gray Hat techniques failed (live-tested)
   - §16.2 The 6 new confirmed techniques (all reverse-shell verified)
   - §16.3 Architectural findings (6 null-pointer guards, PS 7 two-path, initonly inconsistency on `s_amsiNotifyFailed`, Defender RVA 0x8160 watch, JIT heap + vtable + InternalScan/InternalNotify unmonitored, Event 4104 NOT suppressed by any bypass)
   - §16.4 5 Sigma rules + 1 Elastic KQL (`cadre-010-amsi-bypass`) + Sysmon EID 10/8 additions
   - §16.5 Memory forensics (post-bypass state via CLR profiling API + native patch detection for `InternalScan`/`InternalNotify`)
   - §16.6 Architectural mitigations (Constrained Language Mode + AppLocker, kernel-mode AMSI consumer, HVCI)
   - §16.7 Cross-references — what was updated this session
   - §16.8 Action items (6 — most held for Sprint 1 + Plan 9)

2. **`attack-matrix/Campaign/Campaign_suggestions.md`** — Item #109 FULLY REMOVED (6 places cleaned).

**Routing clarification (locked in this session):**
- **plan1.7 / plan1.8** = CADRE project upgrades (plan1.7 defense, plan1.8 offense). Outside core campaign. Practical exercises for skill building.
- **plan1.7-exercises / plan1.8-exercises** = practice library (EX-01..60 plan1.7, EX-OFF-01..37 plan1.8).
- **Campaign_suggestions / CAMPAIGNS_v2 / CAMPAIGNS-METADATA / Runbooks** = core campaign plan00 + plan01 validation. Testing deployed environment end-to-end. Offensive attack primitives only.
- **ad-evasion-gap-analysis.md** = AD-specific evasion (held, sister project integration). AD-only techniques tracked here.
- **Defensive (plan1.7)** = detection rules, hardening, monitoring, deception.
- **Offensive (plan1.8)** = attack techniques for skill building.
- **Offensive (Campaign)** = attack primitives tested against deployed lab.

**Cross-references:**
- plan1.7-defense-deepening.md §16 (NEW — defensive detection)
- ad-evasion-gap-analysis.md (FUTURE — AD-specific evasion, sister project integration)
- Held for Sprint 1: add EX-61 to plan1.7-exercises.md + write T109-amsi-bypass.yml Sigma YAML + deploy to Kibana
- Held: test in lab (requires re-enabling Defender per roadmapv2 decision)
- Related: Item #108 (Defender Exclusion via PowerShell, T1562.001 — complementary runtime disable)

### Changed (2026-06-25 — Campaign v2 + full-content runbooks + coverage audit [Session 17])

> **Per user direction:** Runbooks carry **all campaign details** (theory, prerequisites, detection, tables) — not commands-only. Learn from explanation + live testing. Main campaign is **v2** (`CAMPAIGNS_v1_archived.md` remains archived v1).

**File model (`attack-matrix/Campaign/`):**

| File | Role |
|------|------|
| `CAMPAIGNS.md` | **v2 index** — topology, attack flow, runbook table, coverage summary |
| `CAMPAIGNS_v2.md` | Full monolithic reference (~3,074 lines) for search/print |
| `CAMPAIGNS_v1_archived.md` | Archived v1 (60-attack campaign) |
| `Runbooks/CAMPAIGNS-RUNBOOK-*.md` | **Primary lab path** — full phase narrative + commands (18 files) |
| `Runbooks/CAMPAIGNS-RUNBOOK-README.md` | Runbook index + editing rules |

**Runbooks (18):** Phase 0–8, Branch 3.5, branches A–D, E/F/G. Each includes narrative + commands. Study refs appended to phases 3.5, 4, 6, 8 (incl. Study Reference Library preamble on 3.5). Branch A includes `## Branches` intro; E includes `## Exercises` intro; Phase 1 includes `## Main Spine` header; Phase 3 includes Alternative Execution + LOLBAS subsections.

**Tools:**
- `tools/split-campaign-runbooks.py` — heading-anchored regen from `CAMPAIGNS_v2.md` → runbooks + index
- `python tools/split-campaign-runbooks.py --check` — coverage audit (all campaign body lines assigned to a runbook or index)

**Coverage audit fix:** First split used stale hardcoded line numbers → Phase 0 opening truncated, Phase 8 study refs cut short (missing Forshaw refs + “How to use this section”), Branches/Exercises section headers missing. Rebuilt with markdown heading anchors; `--check` reports **OK: full campaign body covered**.

**Editing workflow (going forward):** Update **runbook + matching `CAMPAIGNS_v2.md` section together**. Run `--check` after bulk regen from v2 only (regen overwrites runbooks). Sync rule documented in runbook headers and `CAMPAIGNS_v2.md` how-to block.

**Also updated:** `Campaign/README.md`, `attack-matrix/README.md`, `AGENTS.md`, runbook headers (sync rule).

### Changed (2026-06-25 — Campaign folder restructure + per-phase runbooks [Session 16])

> **Per user direction:** Consolidate all campaign docs under `attack-matrix/Campaign/`. Superseded by Session 17: runbooks are full narrative + commands, not commands-only; `CAMPAIGNS.md` is v2 index, `CAMPAIGNS_v2.md` is full reference.

**New layout (`attack-matrix/Campaign/`):**

| Path | Purpose |
|------|---------|
| `CAMPAIGNS.md` | v2 index — topology, runbook table, coverage (see Session 17) |
| `CAMPAIGNS_v2.md` | Full monolithic narrative (Session 17) |
| `CAMPAIGNS-METADATA.md` | Per-attack playbook refs, ACE#s, telemetry |
| `Campaign_suggestions.md` | Research backlog → promote when verified |
| `ATTACK-MAP.md` | Visual AD attack-surface mindmap |
| `attack-tools-required.md` | Tools per WT# |
| `DFIR-Nexus-Pioneer-workflow.md` | Parallel attack + DFIR-Nexus case bridge |
| `Feedback_loop.txt` | Campaign_suggestions assessment notes |
| `CAMPAIGNS_v1_archived.md` | Archived 60-attack campaign |
| `README.md` | Folder index |
| `Runbooks/` | 18 full-content runbooks (Phase 0–8, 3.5, branches, E/F/G) — see Session 17 |
| `study-guide/` | Phase deep-dives (was `05-study-guide/`) |
| `diagrams/attack-flow.md` | Campaign flow Mermaid (was `02-diagrams/attack-flow.md`) |
| `attackpath/` | 100-attack kill-chain map (was `03-attackpath/`) |
| `artifacts/` | Campaign captures (BH zip, nmap scan, etc.) |

**Runbooks created (18 files):** Phase 0–8, Branch 3.5, branches A–D, exercises E/F/G. Index: `Runbooks/CAMPAIGNS-RUNBOOK-README.md`. Phase 0 active for lab execution.

**Cross-link updates:** `attack-matrix/README.md`, `prerequisites.md`, `01-walkthroughs/README.md`, `02-diagrams/README.md`, `03-attackpath` → `Campaign/attackpath`, `DFIR-Nexus-Pioneer-workflow` paths, walkthrough WT028/WT031, `Campaign/CAMPAIGNS.md` header (runbook links use `Runbooks/` prefix).

**Still under `attack-matrix/` (not moved):** `01-walkthroughs/` (WT reference cards), `04-automation/` (scripts), `02-diagrams/cadre-architecture-reference.md` (lab topology), `06-telemetry-catalog/` through `10-cert-map/`.

**Path migration (for historical changelog entries):** `attack-matrix/CAMPAIGNS.md` → `attack-matrix/Campaign/CAMPAIGNS.md` (same for `-METADATA`, `Campaign_suggestions`, `DFIR-Nexus-Pioneer-workflow`).

### Added (2026-06-25 — EX-60 SO-CRATES cross-cutting tool + Plan 9 reference [Session 15])

> **Source:** [SO-CRATES](https://github.com/dougburks/so-crates) by Doug Burks (Security Onion creator). Standalone web app for **PCAP + log + binary analysis** with Suricata + Zircolite (Sigma) + YARA baked in. Same engine as [securityonion.net/pcap](https://securityonion.net/pcap). Air-gapped capable. Per user direction (2026-06-25): "b" (low effort, high signal — add EX-60 + Plan 9 reference).

**What SO-CRATES is (and isn't):**
- ✅ **Per-file analyst UI** for PCAP + log + binary with Suricata + Zircolite (Sigma) + YARA + Sankey + aggregation tables
- ✅ Bakes in **Zircolite** (Sigma rule engine for log files) — currently missing from our stack
- ✅ Bakes in **YARA** binary scanning — currently missing
- ✅ Air-gapped deployment — works offline with baked-in rules
- ❌ Does NOT replace Elastic Stack (long-term telemetry store)
- ❌ Does NOT replace Arkime viewer (already on monitor VM, continuous PCAP)
- ❌ Does NOT replace our Suricata deployment (already on monitor VM, fed to Elastic)

**Files updated (3 total — focused scope per user "b"):**

1. **`docs/internal/plan01-upgrades/plan1.7-exercises.md`** (EX-60 + cross-cutting tool section):
   - **EX-60 added**: "PCAP + Log Analysis with SO-CRATES (Cross-Cutting Analyst Tool)"
     - 7-step plan: deploy + analyze EX-47 PCAP + analyze sample log + validate plan1.7 Sigma rules pre-deployment + PCAP validation workflow + cross-check with deployed Suricata + use as Plan 2 design reference
   - **Source table updated**: +SO-CRATES (cross-cutting) row
   - **Total: 59 → 60 exercises**
   - **Cross-Cutting Tool section** (~2 KB): SO-CRATES description, what it adds, what it doesn't replace, tools to install

2. **`docs/internal/roadmapv2.md`** (Plan 9 reference):
   - **Plan 9 section** updated: added "Cross-cutting analyst tool (NEW session 15)" line referencing SO-CRATES
   - **Per-plan table**: plan1.7 = 60 ex (was 59)
   - **File references table**: SO-CRATES source path added (`CADRE-Courses/so-crates/`)
   - **Footer**: session 15 entry added

3. **`AGENTS.md`** — session 15 entry added (this entry, mirrored to CHANGELOG)

**Status legend:** SO-CRATES is now in scope as a **cross-cutting analyst tool** for Plan 9 (PCAP/log analysis) + plan1.7 EX-47 (PCAP validation) + plan1.7 §10 (PCAP workflow) + Plan 2 design reference. No active deployment in this session — just reference + EX-60 spec.

**Cross-references:**
- `docs/internal/plan01-upgrades/plan1.7-exercises.md` "Cross-Cutting Tool: SO-CRATES" section + EX-60
- `docs/internal/roadmapv2.md` Plan 9 line + per-plan table + file references
- Held for next session: actual deployment of SO-CRATES Docker container on monitor VM

### Added (2026-06-25 — Roadmapv2 + 13Cubed Linux Forensics Integration + Items EX-49..59 / EX-OFF-32..37 [Session 14])

> **Scope:** Per user direction (2026-06-25): *"save roadmapv2 first and then proceed to review this one as well, i want linux forensics as well into this somehow ... C:\STUDY\Github\CADRE-Platform\CADRE-Courses\13Cubed ... this if anything new, goes into plan1.7 exercises and other places as necessary and update the roadmapv2 in the end. lastly update changelog and agents.md"*

**Roadmapv2 saved (new file):**
- **`docs/internal/roadmapv2.md`** (new, ~333 lines, 8 sections) — supersedes `roadmap.md` as the "where are we" + "what to do next" doc. Sections: (1) State of the Lab, (2) Why we're slow, (3) 2-sprint plan (9 sessions to v1.0), (4) After Sprint 2, (5) Critical decisions, (6) Out-of-scope for v1.0, (7) 13Cubed Course Library, (8) Per-plan quick reference, (9) Key file references.
- **Sprint 1 (sessions 14-17):** Deploy Plan 1.7 detection rules + run plan1.7/1.8 exercises + batch-write Sigma YAMLs (round 1).
- **Sprint 2 (sessions 18-22):** Lab testing + Plan 2 exporter + Plan 3 cycle script + Plan 5 CI + Sigma YAMLs round 2+3.
- **v1.0 ship = 9 total sessions from now.**

**13Cubed Linux Forensics Integration:**

**Source:** `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\13Cubed\` — three courses by ForensicJason:
- **Investigating Linux Devices** (44 topics, 11 sections) — primary value for CADRE linux01
- **Investigating Windows Endpoints** (32 topics, 10 sections) — cross-validation
- **Investigating Windows Memory** (48 topics, 10 sections) — Plan 9 cross-reference

**Files updated (4 total):**

1. **`docs/internal/plan01-upgrades/plan1.7-exercises.md`** (+Category H, ~15 KB):
   - **EX-49 to EX-59** added (11 new Linux forensics exercises):
     - EX-49: Sysmon for Linux Configuration and Analysis
     - EX-50: Linux Persistence via init.d and systemd Services
     - EX-51: Linux systemd Timers and Cron Job Forensics
     - EX-52: Linux SSH Key Forensics and Backdoor Detection
     - EX-53: Linux Timestomping Detection (Anti-Forensics)
     - EX-54: Linux File System Forensics with The Sleuth Kit (TSK) fls + mactime
     - EX-55: Linux Persistence via SSH Keys + Cron + systemd (Offensive + Defensive chain)
     - EX-56: Linux Super-Timeline with Plaso/Log2Timeline
     - EX-57: Linux Memory Forensics with Volatility 3
     - EX-58: Linux Live Response with UAC (Unix-like Artifacts Collector)
     - EX-59: Compromised Linux System Analysis — Full Scenario Walkthrough
   - Total: **48 → 59 exercises** (+11)
   - New source: **13Cubed Linux** (added to "Exercise Count by Source" table)

2. **`docs/internal/plan01-upgrades/plan1.8-exercises.md`** (+Category I, ~11 KB):
   - **EX-OFF-32 to EX-OFF-37** added (6 new Linux offensive exercises):
     - EX-OFF-32: Linux Persistence via systemd Service (T1543.002)
     - EX-OFF-33: Linux SSH Authorized Keys Backdoor (T1098.004)
     - EX-OFF-34: Linux Timestomping Anti-Forensics (T1070.006)
     - EX-OFF-35: Linux File System Recovery (defender skill)
     - EX-OFF-36: Linux Memory Forensics (AVML + Volatility 3)
     - EX-OFF-37: WSL Persistence — Cross-OS Attack Chain
   - Total: **31 → 37 exercises** (+6)

3. **`docs/internal/plan01-upgrades/plan1.7-defense-deepening.md`** (+§15, ~12 KB):
   - **§15 13Cubed Linux Forensics Integration** added
   - 11 sections covering 13Cubed course library, critical new tools (Sysmon for Linux, AVML, UAC, Plaso, TSK, debugfs, WSL2), Sysmon for Linux deployment plan, AVML+UAC as Plan 9 stack, 7 Linux Sigma rules to port, 3 Suricata SID proposals, action items for 07-linux-config.yml + extension rules

4. **`docs/internal/roadmapv2.md`** (new file, ~333 lines, 8 sections) — see "Roadmapv2 saved" above
   - Per-plan table updated: 1.7 = 59 ex, 1.8 = 37 ex
   - New section 7: 13Cubed Course Library with full Linux course mapping
   - File references table updated with 13Cubed source paths

5. **`AGENTS.md`** — session 14 entry added (this entry, mirrored to CHANGELOG)

**Critical new tools from 13Cubed (not in our existing toolset):**
- **Sysmon for Linux** (Microsoft eBPF port) — fills "process + network + file" gap that auditd doesn't unify
- **AVML** (Microsoft Rust tool) — Linux memory acquisition, no kernel deps
- **UAC** (Thiago Canoza-Lar) — modern live-response collection tool
- **Plaso/Log2Timeline** + **Timesketch** — Linux super-timeline
- **The Sleuth Kit (TSK)** — Linux MFT equivalent (fls, icat, istat, mactime)
- **debugfs** — ext2/3/4 inode + timestomp detection

**CADRE applicability:**
- **Plan 9 (Memory/Disk Forensics)** — primary beneficiary. UAC + AVML + TSK + Plaso + Volatility 3 = complete Linux evidence collection + analysis pipeline.
- **Plan 1.7 EX-49..59** — 11 new Linux forensics detection exercises for linux01.
- **Plan 1.8 EX-OFF-32..37** — 6 new Linux offensive primitives (systemd persistence, SSH backdoor, timestomping, memory forensics, WSL cross-OS).
- **Branch D (Linux Pivot)** in CAMPAIGNS.md — 13Cubed references should be added to study guide (held for next session).
- **Plan 11 (Cloud)** — WSL2 forensics relevant for hybrid Windows+Linux attack surface.
- **plan0.7** (already deployed) — add Sysmon for Linux alongside auditd on linux01.

**Status legend:** 13Cubed Linux content now fills the **Linux DFIR gap** that SANS courses (FOR500/508/608) cover only briefly. Direct fit for Plan 9 + linux01 lab VM.

**Cross-references:**
- `docs/internal/plan01-upgrades/plan1.7-exercises.md` Category H
- `docs/internal/plan01-upgrades/plan1.8-exercises.md` Category I
- `docs/internal/plan01-upgrades/plan1.7-defense-deepening.md` §15
- `docs/internal/roadmapv2.md` §7 + §8
- Held for next session: update `07-linux-config.yml` to add Sysmon for Linux, deploy 7 Linux Sigma rules, add 3 Suricata SIDs

### Added (2026-06-25 — ebooks Survey + Items #109-115 [Session 13])

> **Survey scope:** All 75 .txt files in `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\ebooks\` surveyed via term-frequency analysis for AD attack vocabulary + DFIR/detection keywords. Per user direction (2026-06-25): "look only at the txt files for now... propose your suggestions here."

**Survey findings:**
- 11 books identified as **Tier 1+2 high-value new content** (not duplicates of existing sources)
- 3 concrete techniques extracted as Items #109-111 (AMSI Bypass, DCShadow, Rubeus cross-validation)
- 4 study reference books added as Items #112-115 (Practical AI Security, Cyber Threat Hunting, Practical Threat Detection Engineering, Windows Internals Part 1)
- Tier 3 + skip list documented (programming/theory/compliance/wrong-domain)

**3 new attack items:**
- **#109 AMSI Bypass Techniques** (Gray Hat Hacking 6th Ed) — Phase 3 attack primitive before mimikatz/Rubeus. 3 techniques (amsiInitFailed flag, AmsiScanBuffer patching, forced error). Detection: WinSec 4104 + Sigma `win_amsi_bypass.yml`.
- **#110 DCShadow Attack** (Applied Incident Response + Practical-Red-Teaming) — Phase 7 alternative persistence (inverse of DCSync). Push fake SID history/SPN/group via DRS replication. Detection: WinSec 4662 from non-DC + Zeek DCE-RPC drsuapi.
- **#111 Rubeus/Kerberoast/AS-REP cross-validation** (Practical-Red-Teaming + Gray Hat Hacking 6th Ed) — Verify existing Phase 1/2/7 commands against book recommendations. Check for missing flags (`/rc4opsec`, `/authexp`, `/tgtdeleg`).

**4 study reference items:**
- **#112 Practical AI Security (2025)** — LLM security for CADRE-Strike (prompt injection, RAG poisoning)
- **#113 Cyber Threat Hunting** — hypothesis-driven hunting methodology for plan1.7
- **#114 Practical Threat Detection Engineering** — Sigma rule writing methodology
- **#115 Windows Internals Part 1, 7th Ed** — LSASS/UAC/Kerberos/Credential Guard internals

**Files updated (4 total):**
- **`attack-matrix/Campaign_suggestions.md`**: New top-level section "CADRE-Courses/ebooks Survey (2026-06-25)" with full survey methodology + Tier 3/skip list + Tier 1+2 book lists + 3 new items #109-111 + 4 study reference items #112-115. All 5 summary tables updated (Summary, Phase Mapping, Testing Checklist, Tier 3 Summary, Cross-Reference Index). Counts: 98 → 102 items (24 ✅ / 59 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 12 🆕). Tier 3: 33 → 40. Last updated footer added.
- **`attack-matrix/CAMPAIGNS.md`**: New "📖 ebooks/ Survey (2026-06-25)" section in Study Reference Library (after Practical Purple Teaming). 11 book entries with chapter-to-phase mappings + recommended reading order + action items.
- **`attack-matrix/CAMPAIGNS-METADATA.md`**: 3 new Mechanics stubs (#109-111) inserted after Item #108 stub. Full 8-part templates each (AMSI bypass 3 techniques + WinSec 4104 detection; DCShadow Mimikatz commands + WinSec 4662 detection; Rubeus flag cross-validation). Plus new "Reference Books — CADRE-Courses/ebooks/ Survey" section with 11 study-reference stubs (chapter-to-phase tables for each book + reproduction checklist + cross-references).
- **`AGENTS.md`**: This entry.

**Survey findings — duplicates to skip:**
- `Active Directory Pentesting Mind Map.txt` (5 KB, EMPTY — extraction failed)
- `Rana-Khalil-Lab-Setup.txt` (NOT AD — PortSwigger Web Security Academy setup guide)
- `mdmz_book.txt` (0 AD matches)
- `Practical Malware Analysis.txt` (CONFIRMED DUPLICATE of NoStarchPress_extract)
- SANS DFPS posters (FOR500/508/509/572/578) — already in `CADRE-Courses/sans/pdf_extract/`

**Survey findings — 2025+ publications flagged:**
- **Practical AI Security (2025)** — Tier 2 above; fills CADRE-Strike LLM security gap
- **SANS-2025-Detection-Response-Survey** — industry AI/ML adoption trends, useful for DFIR-Nexus positioning context (NOT techniques)

**Cross-references:** Item #100-101 (NoStarchPress books — same study reference pattern), Item #107 (GitHub Actions supply-chain — overlaps with Practical AI Security prompt injection), Item #108 (Defender exclusion — alternative AMSI bypass approach), plan1.7 §16/§17 (held), Track C (Sigma), Track H (CADRE-Strike).

### Added (2026-06-24 — Item #108: Defender Exclusion via PowerShell (T1562.001) [Session 12])

> **Source:** [Testing AI Threat Hunting against Real-World KQL: A Side-by-Side Test](https://detect.fyi/testing-ai-threat-hunting-against-real-world-kql-a-side-by-side-test-4cdda76a5772) by Alex Teixeira, *Detect FYI* publication, 2026-06-24.

**Why this matters for CADRE:**
- **Phase 3 (Execution) — real attack primitive:** `Add-MpPreference -ExclusionPath "C:\Users\target\AppData\Local\Temp" -ExclusionProcess "mimikatz.exe"` before running mimikatz/AMSI bypass. Maps to MITRE **T1562.001** Impair Defenses: Disable or Modify Tools. We disable Defender via `04-vulnerabilities.yml` for the lab, but real-world attackers do this dynamically.
- **plan1.7 §17 (Detection Engineering) — KQL→Elastic KQL port:** Article's 15-line human KQL query is a clean, complete reference. Patterns port to Elastic: `arg_max(Timestamp, *)` → `top_hits`, `dcount(DeviceId)` → `cardinality`, `parse_json(AdditionalFields)["X"]` → `JsonProperty(winlog.event_data.X)`, `search in (T1, T2) "term"` → `(T1:term OR T2:term)`.
- **AI meta-finding (CRITICAL for CADRE-Strike + DFIR-Nexus):** LLMs miss 75% of real matches (Claude 9/12 false-negatives; ChatGPT didn't even compile). "Use AI to review and improve human queries — not generate from scratch." Validates our Atomic Red Team (#106) cross-validation strategy.
- **Track C (Sigma) candidate:** `win_defender_folder_exclusion.yml` rule from human-improved query.
- **External reference #125** (held) — useful as a realistic AI failure case study in plan1.7 §1.

**Attack primitive (T1562.001):**
```powershell
Add-MpPreference -ExclusionPath "C:\Users\target\AppData\Local\Temp"
Add-MpPreference -ExclusionProcess "mimikatz.exe"
Add-MpPreference -ExclusionExtension ".exe"
```

**Detections (translatable to Elastic KQL — held for plan1.7 §17):**
- WinSec 5001 — Defender configuration change
- WinSec 4688 + Sysmon EID 1 — `powershell.exe` + `*MpPreference*ExclusionPath*`
- Sysmon EID 13 — Registry modification at `HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths`
- Elastic KQL `cadre-009` candidate: `process.command_line:*MpPreference*ExclusionPath* and process.name:"powershell.exe"`
- Sigma rule candidate: `win_defender_folder_exclusion.yml`

**Files updated (4 total — focused scope per user direction "yes add item #108"):**
- **`attack-matrix/Campaign_suggestions.md`**: New Item #108 added with full source info, attack primitive, MITRE mapping, CADRE applicability (Phase 3 + plan1.7 + Track C + Track H), test plan, defenses, KQL→Elastic KQL pattern table, AI meta-finding. All 5 summary tables updated (Summary, Phase Mapping, Testing Checklist, Tier 3 Summary, Cross-Reference Index). Counts: 97 → 98 items (24 ✅ / 55 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 12 🆕). Tier 3: 32 → 33. Last updated footer added.
- **`attack-matrix/CAMPAIGNS-METADATA.md`**: New "Mechanics: Item #108 — Defender Exclusion via PowerShell (T1562.001) [STUB — UNTESTED]" section inserted between Phase 3 and Phase 3.5 Mechanics. Full 8-part template: why it works (COM interface + admin context), attack workflow (5 steps + cleanup + GPO persistence), KQL hunt query (15-line reference), KQL→Elastic KQL port, Sigma rule, success/failure modes, CADRE-specific notes, telemetry fingerprint, detection engineering, KQL pattern table, pitfalls, reproduction checklists (Phase 3 + plan1.7), AI-vs-Human meta-finding, cross-references.
- **`attack-matrix/CAMPAIGNS.md`**: Inline note added in Phase 3 Execution section, right after the GodPotato SYSTEM achievement. Note describes T1562.001 as an "Optional Precursor" for Phase 3 — held for alternative execution cycle, NOT in main spine. Mentions current lab has Defender fully disabled per `04-vulnerabilities.yml`; realistic test requires re-enabling Defender.
- **`AGENTS.md`**: This entry.

**Status:** ⏳ Held — Phase 3 alternative execution cycle + plan1.7 §16/§17 deployment.

**Cross-references:** Item #106 (Atomic Red Team T1562.001), Item #101 (Practical Purple Teaming Ch 6), plan1.7 §16/§17, Track C (Sigma), Track H (CADRE-Strike — HITL validation), External reference #125 (held).

### Added (2026-06-24 — Item #107: GitHub Actions Supply-Chain Attack Patterns [Session 11])

> **Source:** [GMO Flatt Security Blog Part 1](https://blog.flatt.tech/entry/2026-github-actions-security-part1) by Sato (@Nick_nick310), 2026-06-24.

**Why this matters for CADRE:**
- **Plan 0.8 expansion:** F-11 (cache poisoning) + F-12 (tag pollution analog via `npm dist-tag`) extend the existing F-01 to F-10 npm supply-chain scenarios. Adds CI-side attack patterns to our Plan 0.8 chain.
- **CADRE-Strike defensive guardrails (Track H):** The cline incident uses `anthropics/claude-code-action` — the same tool class we'll integrate for CADRE-Strike. Article provides concrete defense checklist (restrict `allowed_non_write_users`, scope `--allowedTools`, minimize workflow `permissions`, commit-hash pinning).

**3 attack patterns documented (MITRE T1195.001):**
1. **Vulnerable trigger injection** — `pull_request_target` + `actions/checkout@${{ github.event.pull_request.head.sha }}` + `npm install` = preinstall RCE. Real-world: Ultralytics (Dec 2024), nx (Aug 2025).
2. **Tag pollution** — move `@v1` to malicious commit. **Imposter Commits** (reference fork commit hash as parent repo commit) — trivy (Feb 2026), tj-actions/changed-files (Mar 2025).
3. **AI agent over-permission** — `allowed_non_write_users: "*"` + bare `Bash` in `--allowedTools` + Issue title prompt injection = arbitrary `npm install`. Real-world: cline (Feb 2026) → `cline@2.3.0` malicious publish.

**Files updated (4 total — focused scope per user direction "Do it"):**
- **`attack-matrix/Campaign_suggestions.md`**: New Item #107 added with full source info, 3 attack chains, MITRE mapping, CADRE applicability (Plan 0.8 + Track H), test plan, defenses. All 5 summary tables updated (Phase Mapping, Testing Checklist, Tier 3 Summary, Cross-Reference Index). Counts: 96 → 97 items (24 ✅ / 54 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 12 🆕). Tier 3: 26 → 32. Last updated footer added.
- **`attack-matrix/CAMPAIGNS-METADATA.md`**: New "Mechanics: Item #107 — GitHub Actions Supply-Chain Attack Patterns [STUB — UNTESTED]" section inserted between Phase 8 and Branch A. Full 8-part template: why it works (3 attack chains), attack workflow (vulnerable workflow YAML + tag manipulation commands + cline vulnerable config + Plan 0.8 analogs + CADRE-Strike hardened config), success/failure modes, CADRE-specific notes (no GitHub Actions in lab, applies to Plan 0.8 + Track H), telemetry fingerprint, detection engineering (held for plan1.7 §17), pitfalls, Wireshark field reference, reproduction checklists (Plan 0.8 + Track H), cross-references.
- **`attack-matrix/CAMPAIGNS.md`**: Added F-11 (cache poisoning) + F-12 (tag pollution analog) rows to F section table with held status. Added inline note explaining the Flatt Security source + CADRE applicability (Plan 0.8 + CADRE-Strike guardrails).
- **`AGENTS.md`**: This entry.

**NOT in main spine:** Item #107 is NOT applicable to AD lab Phase 0-8 (no GitHub Actions in our VMs). Belongs to Plan 0.8 (Supply-Chain) and Track H (CADRE-Strike).

**Status:** ⏳ Held — Plan 0.8 expansion or Track H integration. No immediate test plan.

**Cross-references:** Plan 0.8 (`docs/internal/npm-supplychain-installation-guide.md`), Track H (Campaign_suggestions.md §"Track H"), plan1.7 §17 (detection rules held), external-references.md #124+ (held).

### Fixed (2026-06-24 — CAMPAIGNS.md Flow Correction: NetExec Commands Repositioned to Right Stages [Session 10])

> ⚠️ **Per user feedback (2026-06-24):** "campaign is like the story we simulate a real world attack in the order typically seen in real world... at every stage and at every credentials gains."

**Problem:** Previous CAMPAIGNS.md Phase 0 Step 0.5 contained 11+ NetExec commands that required credentials (`intern_blue:1nt3rn_Blu3!`), but at Phase 0 we don't have those credentials yet. AS-REP Roast is what gives us intern_blue. The commands broke the campaign flow.

**Fix applied:**
1. **CAMPAIGNS.md Step 0.5** — Stripped to **unauthenticated commands only** (nxc `--gen-relay-list`, signing state check, guest attempts marked as Server 2025 blocked). Added clear note about what CAN run without creds and where the auth-recon commands moved.
2. **CAMPAIGNS.md Phase 1 Step 3** — **NEW** — NetExec Authenticated Recon with `intern_blue` (first credential). Multiple tools: NetExec primary, bloodyAD alternative, ADeleg GUI for visual verification, impacket for deeper queries. Includes `nxc -M pre2k/enum_av/get-desc-users/find-delegation/admin-count`, `--asreproast --kdcHost`, `--kerberoasting --kdcHost`.
3. **CAMPAIGNS.md Phase 2 Step 3** — **NEW** — NetExec Authenticated Recon with `svc_mssql` (service account). Multiple tools: NetExec (MSSQL unlocked), bloodyAD for ACL analysis, Certipy v5.1.0 for ADCS, impacket-mssqlclient for SQL-specific recon. Includes `nxc -M adcs`, `--find-delegation`, full AS-REP + Kerberoast.
4. **CAMPAIGNS.md Phase 3.5 Step A** — **NEW** — NetExec Authenticated Recon with admin/SYSTEM (post-GodPotato on mbr01). Multiple tools: NetExec (16+ dump modules), lsassy v3.1.16, DonPAPI v2.0+, manual mimikatz, secretsdump.py, SharpHound. Includes `--sam --lsa --ntds --dpapi`, `-M winscp`, `--laps`.

**CAMPAIGNS-METADATA.md updated:**
- Step 0.5b Mechanics section now includes "FLOW CORRECTION" notice explaining what was moved
- New Mechanics stubs for Phase 1 Step 3, Phase 2 Step 3, Phase 3.5 Step A — each with primary NetExec + 3-4 alternative tools, CADRE-specific notes, detection, cross-references
- Step 0.5 unauth table added showing what works on Server 2025 vs what's blocked

**Quality principle (per user 2026-06-24):** "duplicates/alternative tool usage and alternative techniques all need to be well designed within our campaign. If the campaign isnt good, the whole project becomes worthless."
- Each new auth-recon stage shows **multiple tool options** (NetExec primary, 3-4 alternatives)
- Alternative techniques documented per stage (e.g., bloodyAD vs impacket vs ADeleg)
- SANS course tools referenced where relevant (KAPE, Velociraptor, Plaso for DFIR side)
- Real-world attacker perspective: enumeration at every credential gain, not just at the start

**Files updated:** CAMPAIGNS.md (3 new sections + Step 0.5 trimmed), CAMPAIGNS-METADATA.md (3 new Mechanics stubs + flow correction notice), this CHANGELOG entry, AGENTS.md session entry.

**Workflow note (2026-06-24 session 10):** Per user direction, fixed the credential flow issue. Each new auth-recon stage shows 3-5 alternative tools/techniques per the "use all the best tools at all stages" principle.

### Added (2026-06-24 — 5 Concrete Techniques Extracted from Reference Books [Items #102-106])

- **Source:** Per user workflow principle (2026-06-24): *"books are reference material, but specific attack techniques IN them should be extracted as new items in Campaign_suggestions, with phase mapping. Only move to CAMPAIGNS.md Mechanics when verified."*
- **Item #102 — dsHeuristics abuse** (Phase 0/1 Recon) — Forest-level attribute that controls AD behavior. Some flags weaken security (fAllowAnonNSPIUpdates, fDisableListContents). Detect modifications as early-warning signal.
- **Item #103 — UAC bit exploitation beyond DONT_REQ_PREAUTH** (Phase 0/1/5 Recon) — Enumerate all 20+ UAC flags (TRUSTED_FOR_DELEGATION 0x80000, TRUSTED_TO_AUTH_FOR_DELEGATION 0x40000, DONT_EXPIRE_PASSWORD 0x10000, etc.). Many flags are unenumerated in current campaign.
- **Item #104 — ms-DS-Machine-Account-Quota check** (Phase 5 RBCD pre-flight) — Default quota = 10 (enables WT007 RBCD). Quota = 0 blocks RBCD from low-priv user. Pre-flight check before attempting RBCD saves time.
- **Item #105 — SACL/audit policy manipulation for detection evasion** (Phase 5+ red team perspective) — Defenders DETECT these manipulations via WinSec 4907/4719. Adds new Elastic KQL (proposed cadre-008) and Suricata SID (proposed 1000104).
- **Item #106 — Atomic Red Team as validation framework** (Cross-cutting) — 1000+ pre-built MITRE ATT&CK tests for cross-validation of manual CAMPAIGNS.md attacks. Run `Invoke-AtomicTest T1003.001,T1558.003,...` per phase to validate detection coverage.
- **CAMPAIGNS.md updated:** Inline cross-references added in Study Reference Library entries for Windows Security Internals + Practical Purple Teaming — listing the 5 extracted items (#102-106) with their book chapter sources.
- **CAMPAIGNS-METADATA.md updated:** New "Mechanics: Techniques Extracted from Reference Books (#102-106) [STUB — UNTESTED]" section with full 8-part template Mechanics stubs for each item (why/attack commands/expect/failures/CADRE notes/telemetry/detection/pitfalls + reproduction checklist + cross-references). All marked [STUB — UNTESTED] for verification.
- **Campaign_suggestions.md updated:** 5 new items added (#102-106) with phase mapping, MITRE IDs, attack commands, detection rules, cross-references. Summary table, Phase Mapping, Testing Checklist, Tier 3 Summary, Cross-Reference Index, counts (91 → 96), footer all updated.
- **Workflow note (2026-06-24 session 9):** Per user direction, extracted 5 concrete techniques from the 2 reference books (#100-101 added in session 8) and added them as new items to Campaign_suggestions + Mechanics stubs to CAMPAIGNS-METADATA.md. NOT added to main CAMPAIGNS.md attack flow yet (waiting for verification per user workflow). Cross-references added in Study Reference Library entries.

### Added (2026-06-24 — NoStarchPress Reference Library Survey [Items #100-101])

- **Survey scope:** All 49 directories in `CADRE-Courses/NoStarchPress_extract/` surveyed via term-frequency analysis. Two books have high direct value to CADRE campaign; rest are lower priority or duplicative.
- **Item #100 — Windows Security Internals (Forshaw, 2023):** Located at `CADRE-Courses/NoStarchPress_extract/WindowsSecurityInternals_11172023/` (1.3MB .txt, 19.6MB .html). 600 AD-relevant matches. Maps to:
  - **Chapter 14 (Kerberos)** — Phase 1 (AS-REP), Phase 2 (Kerberoast), Phase 7 (Golden Ticket), Skipjack #97, Onelogon #76, Zerologon Alternative #65
  - **Chapter 11 (Active Directory)** — Phase 0/4/8, Branch A (14 ACEs), Branch B (ADCS CA ACLs)
  - Chapter 4 (Access Tokens) — Phase 3.5 LSASS + token impersonation
  - Chapters 5-8 (Security Descriptors) — Branch A + plan1.7 (AccessMask decoding)
  - Chapter 9 (Security Auditing) — plan1.7 (SACL audit policy)
- **Item #101 — Practical Purple Teaming (Petrey):** Located at `CADRE-Courses/NoStarchPress_extract/Practical_Purple_Teaming-0642572230173/` (725KB .txt, 770KB .html). 255 AD-relevant matches. Maps to:
  - **Chapter 6 (Collecting Telemetry)** — plan1.7 detection engineering (Suricata + Zeek + Sysmon + WinSec + EDR correlation)
  - **Chapter 8 (Atomic Red Team)** — 1000+ pre-built attack tests for cross-validation of our manual CAMPAIGNS.md commands
  - Chapter 9 (Caldera AD Recon) — Track B Caldera integration
  - Chapter 10 (Mythic C2) — Plan 10 (C2+Emulation), Loki integration
  - **Chapter 11 (Reporting + Tracking)** — `tracker.md` workflow + DFIR-Nexus case reports
  - Chapter 12 (Purple Teaming Function) — DFIR-Nexus organizational model
- **CAMPAIGNS.md updated:** New "📖 Windows Security Internals (Forshaw, 2023)" and "📖 Practical Purple Teaming (Petrey)" entries added to Study Reference Library section (just after CVE-2020-0665 Forest Trust entry). Both with chapter → CADRE phase mapping.
- **CAMPAIGNS-METADATA.md updated:** New "Reference Books — Windows Security Internals + Practical Purple Teaming [STUDY]" section after ADeleg. Full chapter mapping tables for both books + recommended reading order + CADRE-specific notes + cross-references. **Status: study reference, not new attack Mechanics.**
- **Campaign_suggestions.md updated:** New top-level section "NoStarchPress Reference Library Survey (2026-06-24)" + Item #100 (Windows Security Internals) + Item #101 (Practical Purple Teaming). All 5 tables (summary, Phase Mapping, Testing Checklist, Tier 3 Summary, Cross-Reference Index) + counts (89 → 91) + footer updated.
- **Lower-value books deprioritized (per survey):**
  - Pentesting Azure Applications (74 matches) — for Plan 11 Entra ID (held)
  - EvadingEDR (85 matches) — CADRE doesn't run EDR
  - Red Team Engineering (53 matches) — for Plan 10
  - Ethical Hacking (135 matches) — general reference
  - Black Hat Python (5 matches) — not AD-focused
  - Gray Hat C# (0 matches) — not relevant
  - Foundations of Information Security (3 matches) — basics
- **CADRE applicability (HIGH):** Both books fill reference gaps we have:
  - Windows Security Internals — directly supports our Onelogon #76 / Skipjack #97 / Zerologon #65 research via deep Kerberos protocol coverage
  - Practical Purple Teaming — directly supports our plan1.7 detection engineering + DFIR-Nexus integration + tracker.md workflow
- **Workflow note (2026-06-24 session 8):** Per user direction, scope was 3 campaign docs + CHANGELOG/AGENTS. Books added as Study Reference Library entries (not new attack Mechanics — no Mechanics section for books). Full integration held until post-campaign.

### Added (2026-06-24 — ADeleg: Windows GUI Tool for ACL/ADCS Recon [Episode 173])

- **Source:** ADeleg podcast Episode 173 + course material at `CADRE-Courses/How to Find Insecure Active Directory Permissions with ADeleg/Episode 173_*.txt` (21,554 bytes). ADeleg = Windows GUI tool for AD delegated permission enumeration. https://github.com/trimarc/ADeleg
- **Why ADeleg:** Per the podcast: *"adelec is an active directory delegation management tool ... it gets you almost the same amount of information that bloodhound gets you but with like a third of the hassle — you don't have to set up bloodhound, you don't have to run the sharp pound collector in your environment and trigger all your edr alerts, you don't have to set up docker to like set up the bloodhound ui and node for neoj"*
- **Differentiators from BloodHound:**
  - No SharpHound collector (avoids EDR alerts)
  - No Docker/Neo4j setup (pure Windows GUI)
  - No LDAP bind required for full enumeration
  - Direct View by Trustee (attacker perspective)
  - ADCS ESC1-8 template misconfiguration flagging
- **Key concepts from article:**
  - **"Unsafe users/groups"** to check first: everyone, authenticated users, domain users, domain computers, domain join account (often over-permissioned)
  - **"Unsafe permissions"** flagged: GenericAll, WriteDacl, WriteOwner, ForceChangePassword, ResetPassword, Delete, AllExtendedRights, Apply-Group-Policy
- **CAMPAIGNS.md updated (3 sections):**
  - **Phase 0 Step 7 — ADeleg GUI Recon (Alternative to BloodHound)** — full Mechanics section with workflow, what to expect (success/failure), CADRE-specific notes (visualize 14 ACEs from `05-ad-attack-surface.yml`, ESC1-17 templates from `08-adcs-deploy.yml`), detection (WinSec 4662 bulk, Zeek LDAP, Suricata SID:1000102 proposed)
  - **Branch A (ACL Abuse)** — added ADeleg pre-BloodHound tip with rationale
  - **Branch B (ADCS)** — added ADeleg pre-Certipy tip with rationale
- **CAMPAIGNS-METADATA.md updated:** New "Mechanics: Phase 0 Step 7 — ADeleg GUI Recon [STUB — UNTESTED]" section after Step 0.5b. Full 8-part template: why it works (no EDR/no Docker), attack workflow (powershell commands), success/failure modes, CADRE-specific notes (14 ACEs + ESC1-17 templates), telemetry fingerprint (WinSec 4662 bulk + Sysmon EID 1 ADeleg.exe + Zeek LDAP + Suricata SID:1000102), detection engineering (proposed Suricata SID + Elastic KQL cadre-007), common pitfalls, Wireshark field reference, reproduction checklist, ADeleg vs BloodHound decision matrix.
- **Campaign_suggestions.md updated:** New top-level section "ADeleg — Windows GUI Tool for ACL/ADCS Recon (Episode 173, 2026-06-24)" + Item #99 added with full details on workflow, CADRE mapping table, detection, cross-references. Summary table, Phase Mapping table, Testing Checklist, Tier 3 Summary, Cross-Reference Index, counts (88 → 89), footer all updated.
- **CADRE applicability (HIGH):**
  - Visualizes the 14 ACEs from `05-ad-attack-surface.yml` — fast deployment verification
  - Visualizes ADCS ESC1-17 templates from `08-adcs-deploy.yml` — pre-Certipy triage
  - Surfaces domain join account over-permission (real-world common pattern per article)
  - No EDR triggers (vs SharpHound) — useful in hardened environments
- **Cross-references:** Phase 4 BloodHound (alternative when EDR blocks SharpHound), Branch A ACL Abuse (visual confirmation), Branch B ADCS (pre-Certipy scan), Campaign_suggestions.md #99.
- **Workflow note (2026-06-24 session 7):** Per user direction, scope was 3 campaign docs + CHANGELOG/AGENTS. ADeleg integrates into Phase 0 + Branch A + Branch B as alternative recon tool. Detection engineering for new SID:1000102 held for plan1.7 §17.

### Tracked (2026-06-24 — CADRE-Strike Agentic Offense Automation [Defer to Campaign Complete])

- **Project reviewed:** `C:\STUDY\Github\CADRE-Platform\CADRE-Strike\` (separate repo, MIT, ~30 files / ~10K LOC MVP 0.1). CADRE = **Contextual Active Directory Reasoning Engine**. Parallel agentic offense layer for the campaign — drives existing campaign tooling (NetExec, bloodyAD, Certipy, Coercer, Impacket) via LLM agents.
- **Differentiators from "command-pass-through" wrappers (HexStrike AI, etc.):**
  - **Intent-level operations** (`enumerate_domain_users`, `find_delegation`, `find_asrep_roastable`, etc.) — semantic ops an LLM agent can reason about
  - **Typed command builders** with `shell=False`
  - **Scope policy enforcement** before every action: target IP/CIDR + domain allowlist + engagement mode + high-risk gate
  - **Pydantic-typed evidence records** with MITRE mapping, automatic secret redaction, confidence scoring
  - **Read-only by default**: no spraying, dumping, persistence in MVP
  - **Dual interface**: HTTP API (`cadre-api` on :8890) + MCP server (`cadre-mcp`) for AI agent integration
- **Roadmap (from CADRE-Strike/ROADMAP.md):**
  - 0.1 (current): Read-only API + MCP + NetExec builder + evidence model
  - 0.2: BloodHound JSON + ranked attack-path graph + MITRE mapping
  - 0.3: Validation mode (explicit approval for high-risk)
  - 0.4: Web dashboard + report generation
- **CADRE mapping (when integration starts):** 10+ tools map to CAMPAIGNS.md attacks. `enumerate_domain_users` → Phase 0, `find_asrep_roastable` → Phase 1, `find_kerberoastable` → Phase 2, `enumerate_adcs` → Branch B, `find_delegation_paths` → Phase 5, etc.
- **Status:** 📋 **Tracked — deferred integration until campaign Phase 1-8 verified** (per user 2026-06-24: "optional approach parallel to campaign we are verifying. For now we keep this recorded somewhere in campaign-suggestions.md/changelog/agents.md so we can comeback to it once the compaign testing is complete.").
- **Documentation path:** Will create `attack-matrix/CADRE-Strike-workflow.md` (parallel to `attack-matrix/DFIR-Nexus-Pioneer-workflow.md`) when integration starts.
- **Companion pattern:** DFIR-Nexus (`tools/dfir-nexus/`) is the proven agentic DFIR side. CADRE-Strike is the agentic offense side. Both pair with manual campaign via `tracker.md`.
- **LLM integration point:** Codex Security (or equivalent) as the LLM reasoning layer that picks next tool → MCP server dispatches → evidence captured.
- **Files updated:** Campaign_suggestions.md (Track H in Parallel Tracks + summary table row + footer note). AGENTS.md (tracked in workflow context). CHANGELOG.md (this entry).

### Added (2026-06-24 — NetExec `coerce_plus` + 6 new modules + `--kdcHost` flag [Hacking Articles AI+HexStrike Analysis])

- **Source:** https://www.hackingarticles.in/ai-powered-active-directory-pentesting-with-claude-hexstrike-ai-netexec/ (June 21, 2026). Article walks through HexStrike AI + Claude Desktop driving NetExec end-to-end. **Key value for CADRE**: comprehensive NetExec command reference + 6 modules not previously documented.
- **`--kdcHost` flag** (CRITICAL): Fixes "KDC routing quirk" when running AS-REP roast or Kerberoast against multi-DC environments (we have 3 DCs). Without it, AS-REQ may be sent to unreachable DC and fail silently.
- **`-M coerce_plus`** (consolidated coercion check): Single command checks PetitPotam, PrinterBug, DFSCoerce, MSEven, MS-RPRN. Replaces running 5 individual coercion checks (WT017-020). Added to CAMPAIGNS.md as **WT096** in Phase 5 Alternative Coercion Techniques.
- **6 new modules documented:**
  - `-M pre2k` — Pre-Windows 2000 computer account abuse check (Phase 0 recon)
  - `-M enum_av` — AV/EDR enumeration (pre-attack OPSEC, Phase 0)
  - `-M get-desc-users` — User description field enumeration (Phase 0, cheap password leak check)
  - `-M winscp` — WinSCP saved session decryption (Phase 3.5 creds)
  - `-M rdp -o ACTION=enable/disable` — RDP enablement (operational primitive)
  - `--dpapi` — Built-in DPAPI loot (Phase 3.5, alternative to DonPAPI module)
- **DCSync detection enhancement:** Property GUID `1131f6aa-9c07-11d1-f79f-00c04fc2dcd2` = DS-Replication-Get-Changes. Alert when 4662 references this GUID + subject account is NOT a domain controller → canonical DCSync detection. Added Elastic KQL.
- **CAMPAIGNS.md updated (5 changes):**
  - **Step 0.5 (NetExec Quick-Recon)** — added 3 new modules (`-M pre2k`, `-M enum_av`, `-M get-desc-users`) + `--kdcHost` flag examples for AS-REP/Kerberoast
  - **Phase 1 Step 2 (AS-REP Roast)** — added `--kdcHost` alternative nxc command
  - **Phase 2 (Kerberoast)** — added `--kdcHost` alternative nxc command
  - **Phase 5 (Alternative Coercion Techniques table)** — added new WT096 row for `coerce_plus` + full Mechanics section
  - **Phase 6 Study Reference (DCSync Detection)** — added property GUID signature + Elastic KQL
- **CAMPAIGNS-METADATA.md updated:**
  - New "Mechanics: Phase 0 Step 0.5b — NetExec `--kdcHost` flag + 6 new modules [STUB — UNTESTED]" section with detailed stub for each of the 8 items (kdcHost + 6 modules + DCSync GUID).
- **Campaign_suggestions.md updated:**
  - New top-level section "NetExec New Modules (Hacking Articles AI+HexStrike Analysis, 2026-06-24)" after Skipjack
  - Item #98 added with full details on `--kdcHost`, `coerce_plus`, and 5 new modules
  - Summary table, Phase Mapping, Testing Checklist, Tier 3 Summary, Cross-Reference Index, counts (87 → 88), footer updated
- **CADRE applicability:**
  - **CRITICAL** — `--kdcHost` flag fixes silent failure of existing Phase 1/2 commands
  - **`coerce_plus`** consolidates 5 individual coercion checks (Phase 5 pre-flight)
  - **3 new recon modules** add Phase 0 coverage (pre2k, enum_av, get-desc-users)
  - **3 new post-ex modules** add Phase 3.5 coverage (winscp, dpapi, rdp)
  - **DCSync GUID** adds high-fidelity detection signal (Phase 6)
- **Cross-references:** All additions complement existing #90 NetExec entry. Detection engineering for new modules → plan1.7 §17.
- **Workflow note (2026-06-24 session 5):** Per user direction, scope was 3 campaign docs + CHANGELOG/AGENTS. All updates integrated directly into CAMPAIGNS.md (no deferral) since the new commands work with existing tooling. Detection engineering rules held for plan1.7 §17.

### Added (2026-06-24 — Skipjack: Cross-Forest Trust Downgrade via Invalid PAC Signature)

- **Research source:** https://blog.ghostwolflab.com/redteam/786/ — "PAC 签名无效引发的域信任降级攻击" (Domain Trust Downgrade Attack Caused by Invalid PAC Signatures), Ghost Wolf Lab, 2026-06-23.
- **Attack name:** **Skipjack** (skip the PAC signature check, jack the downgrade logic).
- **Vulnerability mechanism:** Kerberos **PAC (Privilege Attribute Certificate)** is signed with two signatures (service + KDC). When signature verification **fails**, Windows DCs have a **downgrade fallback** (legacy compatibility): look up user in local AD + rebuild token from AD groups. In **cross-forest trust scenarios where SID filtering is disabled**, an attacker can:
  1. Get TGT in Forest A
  2. Modify PAC to inject Forest B's Domain Admins SID (`S-1-5-21-<B>-519`)
  3. **Delete or corrupt PAC signatures** (so verification fails)
  4. Submit forged TGT to Forest B's DC
  5. DC signature verification fails → enters downgrade mode
  6. Downgrade mode rebuilds token BUT keeps forged SIDs (SID filter OFF)
  7. **Attacker becomes Domain Admin in Forest B**
- **CADRE applicability: HIGH** — all pre-conditions met:
  - 2 forests (cadre.local, range.local) with cross-forest trust
  - **SID Filter OFF** (verified per `01-core-ad.yml:50`, Server 2025 forest trust default)
  - Attacker controls user in one forest (`intern_blue` in child.cadre.local)
  - Target forest (cadre.local) — Enterprise Admins SID available for injection
- **Skipjack vs current Phase 8 (Golden Ticket):**
  | Method | Mechanism | Requires krbtgt? | Detection surface |
  |---|---|---|---|
  | Golden Ticket (current Phase 8) | Forge TGT with krbtgt hash + SID history | ✅ Yes (DCSync first) | Anomalous ticket encryption, no AS-REQ |
  | **Skipjack (new)** | Modify legitimate TGT + corrupt signatures + inject SID | ❌ **No** | Legitimate AS-REQ + 4826 PAC verification failed |
- **CAMPAIGNS.md updated:** New "Skipjack — Cross-Forest Trust Downgrade via PAC Signature Corruption (Phase 8 alt)" section in Phase 8 with full vulnerability mechanism, CADRE applicability (HIGH), Skipjack vs Golden Ticket comparison table, test plan with `Rubeus.exe asktgt /user:intern_blue /password:'1nt3rn_Blu3!' /domain:child.cadre.local /injectSID:S-1-5-21-<cadre.local-domain>-519 /corruptSignature`, detection (WinSec 4826, 4769, Zeek kerberos.log, Suricata SID:1000101), defense (SID filter, KdcValidatePac=1, ESAE).
- **CAMPAIGNS-METADATA.md updated:** New "Mechanics: Skipjack — Cross-Forest Trust Downgrade via PAC Signature Corruption [STUB — PENDING CUSTOM TOOL]" section after Phase 8 Mechanics. Status ⏳ PENDING. Full 8-part template: why it works (downgrade fallback mechanism), attack commands (predicted — gated on custom tool), success/failure modes, CADRE-specific notes (test target dc01.cadre.local), telemetry fingerprint (WinSec 4826 + cross-forest), detection engineering (proposed Suricata SID:1000101 + Elastic KQL + KdcValidatePac Group Policy), common pitfalls (no /corruptSignature in standard Rubeus), Wireshark field reference, reproduction checklist.
- **Campaign_suggestions.md updated:** Item #97 (next available) added as new top-level section "Skipjack — Cross-Forest Trust Downgrade via Invalid PAC Signature (GhostWolfLab, 2026-06-23)" after Onelogon section. Vulnerability mechanism explained, full pre-conditions table (all met on CADRE), testing plan, detection rules, defense recommendations, cross-references to items #66 (SID Filtering study ref) + #67 (CVE-2020-0665) + #76 (Onelogon). Summary table, Phase Mapping table, Testing Checklist row, Tier 3 Summary, Cross-Reference Index, counts (86 → 87), footer updated.
- **Detection engineering candidates (plan1.7 §16 to be added separately):**
  - Suricata SID:1000101 (new) — cross-realm TGS-REQ with corrupted PAC auth-data
  - Elastic KQL — WinSec 4826 (PAC verification failed) correlation
  - Zeek notice — kerberos.log inter-realm TGT with corrupted auth-data
- **Defense recommendations:**
  - Enable SID filtering on all cross-forest trusts (CRITICAL — closes the attack entirely)
  - Force PAC validation: Group Policy → `HKLM\System\CurrentControlSet\Services\Kdc\Parameters\KdcValidatePac = 1`
  - Monitor WinSec 4826 events (rare in healthy environment — should alert on any)
  - ESAE (Enhanced Security Admin Environment) for high-priv accounts
- **Cross-references:** Item #66 Forest Trust SID Filtering (root cause fix), Item #67 CVE-2020-0665 Trust Bypass, Item #76 Onelogon (different vuln class but similar outcome), Phase 8 current (Golden Ticket method).
- **Workflow note (2026-06-24 session 4):** Per user direction, scope was analyze + 3 campaign docs + CHANGELOG/AGENTS. No PoC exists (blog provides pseudocode only). Custom Rubeus build or `skipjack_forge.py` implementation required to test. Detection rules held for plan1.7 §16 (paired with Onelogon).

### Added (2026-06-24 — CVE-2026-41089 PoC Integration [CVSS 9.8 CRITICAL])

- **PoC cloned from https://github.com/0xABCD01/CVE-2026-41089** (0xABCD01, 171 stars, 60 forks, MIT license). 4 files, 18 KB total (`poc.py` is 299 lines, Python 3.8+, no third-party deps).
- **Vulnerability:** Windows Netlogon Remote Code Execution via CLDAP Stack Buffer Overflow. `NlGetLocalPingResponse` allocates a 528-byte stack buffer; `NetpLogonPutUnicodeString` receives max length in **bytes** but treats it as **WCHAR count** → strings occupy 2x expected space. CLDAP "User" field (130 wchars = 260 bytes on wire) + other strings overflow the buffer → LSASS crash → DC reboot in ~60s. CWE-121.
- **Attack vector:** UDP 389 (CLDAP), pre-authentication, **zero credentials required**, single crafted UDP packet. **Most impactful standalone exercise available for the campaign.**
- **Affected systems (CADRE DCs presumed vulnerable):**
  - Server 2012 / 2012 R2: ESU-only patches
  - Server 2016: 10.0.14393.9140
  - Server 2019: 10.0.17763.8755
  - Server 2022: 10.0.20348.5074
  - Server 2022 23H2: 10.0.25398.2330
  - **Server 2025: 10.0.26100.32772** (CADRE all-3-DCs)
- **CAMPAIGNS.md updated:** New "G — Pre-Auth DC Exploits (Standalone)" section after F-Supply-Chain. Full entry for CVE-2026-41089 with: vulnerability mechanism, affected systems table, pre-test checklist (snapshot + patch level check), 3-phase test plan (`python3 poc.py <target_ip> <domain_name> -l 130`), expected behavior for vulnerable vs patched, telemetry fingerprint, detection rules to build (proposed Suricata SID:1000100 for oversized CLDAP User attribute), post-test cleanup (`Reset-ComputerMachinePassword`), mitigation strategies.
- **CAMPAIGNS-METADATA.md updated:** New "Mechanics: G-1 — CVE-2026-41089 Netlogon CLDAP Stack Buffer Overflow" section after WT095 Onelogon. Status 🆕 READY — UNTESTED. Full 8-part template: why it works (vulnerable call path), attack commands (Phase 1/2/3), success/failure modes, CADRE-specific notes (test target = dc02 FIRST), telemetry fingerprint (WinSec 1000, 5805, Zeek udp.log, Suricata SID:1000100), detection engineering (Suricata rule + Zeek cadre-cldap.zeek + Elastic KQL), common pitfalls (snapshot, target, patch level, UDP block), Wireshark field reference, 12-item reproduction checklist.
- **Campaign_suggestions.md updated:** Item #33 promoted from ⏳ Pending to 🆕 READY. Full entry rewritten with PoC source (0xABCD01), vulnerability mechanism, affected systems table (with build numbers), pre-test snapshot requirement, 3-phase test plan from Kali, detection rules, mitigation, cross-references to #65 Zerologon Alternative (superseded) and #76 Onelogon Zero-Channel (also exploits Netlogon). Summary table, Phase Mapping, Testing Checklist, Tier 3 Summary, Cross-Reference Index, counts, and footer updated. New 🆕 count: 4 → 5.
- **Pre-test checklist (CRITICAL — don't crash a production DC):**
  - [ ] Snapshot dc01, dc02, dc03 before testing (VMware `vmrun.exe snapshot`)
  - [ ] Verify DC patch level: `Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name CurrentBuild, UBR` (need UBR < 32772 on Server 2025)
  - [ ] Test target = **dc02 FIRST** (child DC, less critical than dc01)
  - [ ] UDP/389 reachable from Kali (`nmap -sU -p 389 <dc_ip>`)
  - [ ] Notify team DC will be down ~60 seconds
- **Detection engineering candidates (plan1.7 §17 to be added separately):**
  - Suricata SID:1000100 (new) — oversized CLDAP User attribute
  - Zeek `cadre-cldap.zeek` (new script) — flag oversized search filter attributes
  - Elastic KQL — WinSec 1000 with netlogon.dll SourceName
- **Cross-references:** Item #65 Zerologon Alternative (superseded), Item #76 Onelogon Zero-Channel (different Netlogon vuln class — single-channel NRPC bypass vs CLDAP stack overflow), Plan 1.7 detection engineering.
- **Why standalone (not main campaign):** Unauthenticated DC compromise would short-circuit the entire credential chain (Phases 1-3 become unnecessary). CADRE's main campaign demonstrates misconfiguration-based attacks, not CVE exploits. But CVE-2026-41089 is valuable as a standalone exercise: tests detection of Netlogon exploitation, shows what happens when a critical CVE hits.

### Added (2026-06-24 — Modern AD Attack Tool Landscape Update + NetExec/Bark Research)

- **Comprehensive AD attack tool research:** `docs/internal/references/ad-tools-landscape-2026-06-24.md` (~30 KB, 10 sections, 60+ tool inventory). Full tool audit per AD attack lifecycle phase.
- **NetExec confirmed (v1.5.1, Feb 23 2026):** Replaces CrackMapExec (abandoned Sep 2023). 10 protocols (SMB/LDAP/MSSQL/WinRM/WMI/SSH/RDP/FTP/NFS/VNC), 16+ dump modules, native Windows binary. https://github.com/Pennyw0rth/NetExec
- **Bark definitively identified as BARK (BloodHound Attack Research Kit):** https://github.com/BloodHoundAD/BARK by Andy Robbins / SpecterOps. PowerShell, **Azure/Entra ID ONLY** — no on-prem AD functionality. User's "azure only" memory was correct. 80+ functions for token management, Entra enumeration, AzureRM enumeration, Intune enumeration, abuse functions. Companion to bloodyAD (same author CravateRouge). Maps to Plan 11 only.
- **7 new items added to Campaign_suggestions.md (#90-96):**
  - **#90 NetExec (nxc)** — CrackMapExec replacement, cross-cutting Phases 0-5
  - **#91 bloodyAD v2.5.4** — already adopted (update version note for dMSA + ACL helpers)
  - **#92 Certipy v5.1.0** — already adopted (update version note for ESC17 + golden cert)
  - **#93 DonPAPI v2.0+** — Remote DPAPI credential harvesting (12+ collectors)
  - **#94 lsassy v3.1.16** — Remote LSASS dump (15+ methods)
  - **#95 KrbRelay + KrbRelayUp** — LPE via Kerberos relay (no-CVE)
  - **#96 BARK** — Azure/Entra ID abuse validation (Plan 11 only)
- **CAMPAIGNS.md updated (5 changes):**
  - **Lab topology diagram** — Kali tool list updated: added `nxc`, `lsassy`, `DonPAPI` to existing `impacket · certipy · bloodyAD · coercer`
  - **Phase 0 Step 0.5 — NetExec Quick-Recon** (new) — 10-protocol recon section with example commands
  - **Phase 3.5 3.5F-alt — Remote LSASS Dump via lsassy** (new) — alternative to manual procdump + schtasks
  - **Phase 3.5 3.5F-dpapi — Remote DPAPI Harvesting via DonPAPI** (new) — DPAPI remote collection
  - **Phase 3.5 3.5N — BARK bridge to Plan 11** (new) — Azure/Entra ID validation framework reference after 3.5M adconnectdump
- **CAMPAIGNS-METADATA.md updated (4 new Mechanics sections):**
  - **Phase 0 Step 0.5 — NetExec Quick-Recon** [READY — UNTESTED] — 8-part Mechanics section
  - **Phase 3.5 3.5F-alt — lsassy v3.1.16** [STUB — UNTESTED] — 8-part Mechanics section
  - **Phase 3.5 3.5F-dpapi — DonPAPI v2.0+** [STUB — UNTESTED] — 8-part Mechanics section
  - **Phase 3.5 3.5P — KrbRelayUp LPE** [STUB — UNTESTED] — 8-part Mechanics section
- **Recommended update order (per research):**
  1. **Phase 0** — `nxc smb/ldap/mssql` quick-recon (low risk, high value)
  2. **Phase 3.5** — `lsassy` + `donpapi` modules via NetExec (medium value, no infra change)
  3. **Phase 2** — `bloodyAD` for ACL abuse (already in CADRE, update version)
  4. **Phase 5 Branch B** — `Certipy` (already in CADRE, update version for ESC17)
  5. **Phase 5 Branch 3.5** — `KrbRelayUp` + `Whisker` for LPE + Shadow Creds
  6. **Phase 1** — `nxc winrm/ssh/ftp/vnc` modules for protocol coverage
  7. **Phase 5 Coercion** — Migrate to `Coercer`; await Onelogon (Aug 2026) PoC
  8. **Plan 1.7 (Defense)** — Run `Locksmith` + `certipy find` as defender view after each Phase 5 attack
- **Confirmed deprecated/absorbed tools (do NOT use):**
  - `crackmapexec` (CME) — abandoned Sep 2023, use `nxc` (NetExec)
  - `Certify.exe` — archived 2021, use `Certipy` (Certipy-ad)
  - `aclpwn.py` (0x9c5a) — repo returns 404, absorbed into bloodyAD + Certipy + Impacket
  - `pyWhisker` (Dirk-jan) — no separate repo, absorbed into `Certipy shadow auto` (Linux) and `Whisker` (elad shamir, Windows)
- **Recommended new external references (15 items #123-137):** NetExec wiki + repo, BARK, bloodyAD, Certipy, DonPAPI, lsassy, KrbRelay, KrbRelayUp, Locksmith, Whisker, minikerberos, SharpView, kerbrute. (external-references.md update held per user scope.)
- **Counts updated:** 77 → 86 items (24 ✅ / 51 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 4 🆕). Tier 3 total: 19 → 26.

### Added (2026-06-24 — Onelogon: Single-Channel NRPC Authentication Bypass [WOOT 2026])

- **Paper analyzed:** "Onelogon: An Authentication Bypass for Windows Active Directory via Single-Channel Netlogon" — Alexandru-Vlad Pădurean, WOOT 2026 (Workshop on Offensive Technologies, Aug 1-3 2026). Same author as `krbrelayx`. Paper text at `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\woot2026-onelogon\woot2026-onelogon.txt` (923 lines).
- **Vulnerability:** MS-NRPC's single-channel variant (over SMB/445 via `\PIPE\netlogon`) was **not covered by the post-Zerologon hardening** (CVE-2020-1472 patch + SpecterOps "Renaissance of NTLM Relay Attacks" 2025 mitigations). The hardening was only added to multi-channel NRPC (DC-to-DC replication). Single-channel NRPC still accepts pre-Zerologon non-secure-RPC calls, exposing two attacks:
  - **Section 5.2 Zero-Channel:** Call `NetrServerPasswordSet2` against target DC machine account → set DC machine password to attacker-known value → DCSync → KRBTGT → full domain takeover in 1 RPC call.
  - **Section 5.1 AES-CBC8 Downgrade:** Compute hash of ANY password (machine, KRBTGT, user) offline via RFC 4753 weak DES challenge-response.
- **Author tested on:** Windows Server 2022 (latest patches). Server 2025 not explicitly tested but the single-channel path is unchanged since 2016 — hardening is what changed, and it doesn't cover this path. **All 3 CADRE DCs (dc01/dc02/dc03) are presumed vulnerable.**
- **CAMPAIGNS-METADATA.md updated:** New "Mechanics: WT095 — Onelogon Zero-Channel" stub section after "Mechanics: WT018-020 — Non-functional Coercion". Status: ⏳ PENDING — gated on author PoC release post-WOOT 2026. Includes predicted attack interface, expected telemetry, detection engineering candidates (Suricata SID:1000098, Zeek `cadre-nrpc.zeek`, Elastic cadre-006), and reproduction checklist.
- **CAMPAIGNS.md updated:** New "095 — Onelogon Zero-Channel" entry in Phase 5 "Alternative Coercion Techniques" table (after WT094 UnCanny). New full Mechanics section in Phase 5 detailing attack chain, 5 downstream routes (DCSync / AES-CBC8 direct / RBCD / ADCS ESC1 / Phase 8 SID history), detection rules (Suricata SID:1000098, WinSec 4662 WriteProperty on DC unicodePwd, Zeek named-pipe netlogon notice), and critical cleanup step (`Reset-ComputerMachinePassword` to avoid breaking AD replication).
- **Campaign_suggestions.md updated:** New top-level section "Onelogon — Single-Channel NRPC Authentication Bypass (WOOT 2026, 2026-06-24)" added before "Next Actions / Parallel Tracks". Items #76 (Onelogon Zero-Channel, Phase 5 → 7 shortcut) and #77 (Onelogon AES-CBC8 Downgrade, Phase 3.5 → 7) fill the #76-77 reserved gap from the 2026-06-23 numbering audit. **Supersedes item #65 (Zerologon Alternative "patched on Server 2025")** — single-channel NRPC bypass proves Zerologon-class attacks are still viable in 2026. Counts: 75 → 77 items (22 ✅ / 48 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref). Updated summary table, Phase Mapping table, Testing Checklist rows, Tier 3 Summary table, Cross-Reference Index, and footer.
- **Detection engineering candidates (plan1.7 §16 to be added separately):**
  - Suricata SID:1000098 — single-channel NRPC anomaly (`\PIPE\netlogon` over SMB/445 from non-DC source)
  - Zeek `cadre-nrpc.zeek` (new script) — named-pipe `netlogon` from non-DC + `NetrServerPasswordSet2` (opnum 6) DCE-RPC notice
  - Elastic cadre-006 — WinSec 4662 WriteProperty on `CN=DC0*` machine account `unicodePwd`
  - Suricata SID:1000099 — AES-CBC8 cipher in NRPC (weak crypto detection)
- **Pre-test verification (do BEFORE author PoC release):** Snapshot dc01/dc02/dc03, confirm SMB/445 reachable, confirm `DC01$`/`DC02$`/`DC03$` machine account names via Phase 0 Kerberos enum, verify WT017 PrinterBug still works (12 Suricata SID:1000050 fires baseline), prepare `Reset-ComputerMachinePassword` cleanup script.
- **Cleanup CRITICAL:** After attack, run `Reset-ComputerMachinePassword` on dc01 to re-establish proper machine password. Without this, AD replication breaks across the forest.
- **Why this matters for CADRE:** Single RPC call = full domain admin on patched Server 2022/2025. Most impactful AD authentication bypass since Zerologon (CVE-2020-1472). Maps directly to existing Phase 5 WT017 PrinterBug coercion primitive (already working). Provides alternative entry path to Phase 6/7 (DCSync → Golden Ticket) without needing Kerberos ticket forgery or RBCD setup.
- **Cross-references:** Replaces/supersedes item #65 (Zerologon Alternative). Complements WT017 (MS-RPRN coercion — supplies auth prerequisite). Provides shortcut for Phase 6 (DCSync) and Phase 7 (Golden Ticket). Bypasses Phase 5 unconstrained delegation entirely. Phase 8 impact: with SID Filter OFF (verified in `01-core-ad.yml:50`), compromise of any DC = Enterprise Admin.

### DFIR-Nexus v1.0.0 E.0 "Constellation" — Production Platform COMPLETE

**Release:** E.0 Constellation closes the assessment roadmap (A.0 → E.0). Lab/CADRE-integrated use is ready; internet-facing production requires the hardening checklist in `E0-CONSTELLATION.md`.

| Metric | Value |
|---|---|
| **MCP tools** | 96 (+4: `case_push_token`, `case_export`, `integration_notify`, `case_knowledge_graph`) |
| **Unit tests** | 475 |
| **Smoke steps** | 72 (all pass) |
| **Modules** | 18 (+ `push/`) |

**E.0.1 Push ingest** — `push/` module: per-case bearer tokens, `dfir-nexus push-server`, MCP `case_push_token`; global token cross-case rejected.

**E.0.2 Browser extension** — MV3 scaffold at `tools/dfir-nexus-extension/`; [`tools/dfir-nexus/docs/EXTENSION.md`](tools/dfir-nexus/docs/EXTENSION.md).

**E.0.3 Integrations** — env-only webhooks (SSRF-safe), `integration_notify` MCP, exporter stubs.

**E.0.4 Export parity** — CSV, DOCX, ZIP, snapshot, IOC blocklist, SVG; `case_export` + `case_knowledge_graph` MCP.

**Docs:** [`tools/dfir-nexus/docs/E0-CONSTELLATION.md`](tools/dfir-nexus/docs/E0-CONSTELLATION.md); registry + integration 1-pager updated.

**Next:** CADRE platform wiring (Ansible on `provisioning`, live SSH connectors, end-to-end lab telemetry).

### DFIR-Nexus — Production hardening (D.0 post-review + low-priority)

- **VQL policy** — catalog allowlist + escaping; ad-hoc VQL blocked unless `DFIR_NEXUS_VR_ALLOW_ADHOC_VQL=1`
- **MCP path sandbox** — `paths.py`; ingest/sigma/export roots via `DFIR_NEXUS_DATA_ROOTS`
- **Audit secret** — `DFIR_NEXUS_AUDIT_SECRET` for HMAC chain
- **Gateway** — bearer required on non-loopback bind
- **Portal** — password default-on; per-IP rate limits (`DFIR_NEXUS_PORTAL_RATE_LIMIT`)
- **HITL** — password-gated cases force DRAFT on unsigned APPROVED findings
- **TI/triage/detection** — URL encoding, merge verdicts, indexer tactics, sigma ZIP safety
- **Tests:** `test_hardening.py`, `test_hardening_lp.py`, push security in `test_push.py`

### DFIR-Nexus D.0.3 "Stellar" — MITRE Navigator + threat actors + RBA COMPLETE

**Scope:** MITRE Navigator v4.5 layers, seed threat-actor profiles, rule-based RBA scoring, LangGraph AlertAgent enrichment.

| Tool | Purpose |
|:-----|:--------|
| `mitre_navigator_layer` | Observed techniques layer (v4.5 upgrade) |
| `mitre_navigator_coverage_layer` | Detection coverage heatmap |
| `mitre_navigator_gap_layer` | Gap analysis layer |
| `mitre_navigator_actor_layer` | Single-actor overlay |
| `mitre_list_actors`, `mitre_get_actor` | Actor catalog |
| `mitre_match_actors` | Technique → actor overlap |
| `mitre_rba_score` | 0–100 risk score + tier |

- **MCP tools:** 92 (+7 MITRE/RBA); **module:** `tools/dfir-nexus/src/dfir_nexus/mitre/`
- **Gateway:** +4 MITRE tools on in-process backend (47 total)
- **Tests:** 448 pytest + 68 smoke
- **Docs:** [`tools/dfir-nexus/docs/D0-STELLAR.md`](tools/dfir-nexus/docs/D0-STELLAR.md)

**D.0 Stellar release complete.** Superseded by v1.0.0 E.0 Constellation (see above).

### DFIR-Nexus D.0.2 "Stellar" — Velociraptor framework COMPLETE

**Scope:** CADRE vr VM (192.168.77.51) — hunt catalog, orchestration, LangGraph EndpointAgent, 9 MCP tools.

| Tool | Purpose |
|:-----|:--------|
| `vr_health`, `vrun_health` | CADRE VR connectivity |
| `vr_list_clients`, `vr_list_hunts`, `vr_list_artifacts`, `vr_get_hunt` | Catalog |
| `vr_run_hunt`, `vr_collect_artifact`, `vql_query`, `vql_collect_artifact` | Collection |

- **MCP tools:** 85 (+10 VR, incl. `vrun_health` + `vql_collect_artifact` aliases); **module:** `tools/dfir-nexus/src/dfir_nexus/vr/`
- **Tests:** 439 pytest + 64 smoke
- **Docs:** [`tools/dfir-nexus/docs/D0-STELLAR.md`](tools/dfir-nexus/docs/D0-STELLAR.md)

### DFIR-Nexus D.0.1 "Stellar" — TI providers COMPLETE

**Policy:** **Core loop** uses only **abuse.ch** (incl. URLhaus) and **self-hosted MISP**. Commercial or API-key feeds stay **optional** — never in `ti_fanout` or default `ti_lookup`; call explicit `ti_otx` / `ti_shodan` / … tools or pass `providers=[...]`. LLM providers unchanged.

| Tier | Tools |
|:-----|:------|
| **Core** | `ti_list_providers`, `ti_lookup`, `ti_fanout`, `ti_threatfox`, `ti_malware_bazaar`, `ti_urlhaus`, `ti_yaraify`, `ti_misp` |
| **Optional** | `ti_otx`, `ti_shodan`, `ti_virustotal`, `ti_abuseipdb`, `ti_crowdstrike` |

- **MCP tools:** 75 (+13 TI); **gateway:** +10 TI tools on in-process backend
- **LangGraph:** NetworkAgent + `ti/enrich.py` (core-only IOC enrichment)
- **CrowdStrike:** OAuth2 client-credentials live path (Falcon Intel API)
- **Unconfigured providers:** clear env-var hints (no blind HTTP 401)
- **Ingest:** optional offline export parsers (OTX, VirusTotal, AbuseIPDB JSON)
- **Tests:** 431 pytest + 60 smoke steps
- **Docs:** [`tools/dfir-nexus/docs/D0-STELLAR.md`](tools/dfir-nexus/docs/D0-STELLAR.md)

**Next:** D.0.2 VR framework, D.0.3 MITRE/actors/RBA.

### DFIR-Nexus C.0 "Voyager" COMPLETE (2026-06-05)

**C.0 fully closed** — production RAG, Windows triage, and analysis bonus on top of B.0 Pathfinder (v0.7.0):

| Slice | Shipped |
|:------|:--------|
| **C.0.1 Forensic RAG** | `rag_search`, `rag_list_sources`, `rag_stats`; production index via `dfir-nexus data download-rag` (~22K records) |
| **C.0.2 Windows triage** | 13 `triage_*` tools; production `known_good.db` + `context.db` via `dfir-nexus data download-triage` (~2.7M paths) |
| **C.0.3 Analysis bonus** | `artifact_deobfuscate`, `llm_anonymize`, `llm_restore`, `case_evidence_graph`, `case_graph_context`, `ez_tool_run` |
| **Volatility 3 importer** | 33rd source — `ingest_from_source` with `volatility` on JSON/JSONL memory exports |

- **MCP tools:** 62 (was 40 at B.0)
- **Importers:** 33 (was 32 at B.0)
- **Tests:** 420 pytest + 57 smoke steps
- **Docs:** [`tools/dfir-nexus/docs/C0-VOYAGER.md`](tools/dfir-nexus/docs/C0-VOYAGER.md), [`DATA.md`](tools/dfir-nexus/docs/DATA.md), updated README/ARCHITECTURE/STUDY-GUIDE
- **Distribution:** Multi-GB RAG/triage DBs **not** in git — CLI download with `DFIR_NEXUS_*_RELEASE_REPO` pointing to your org's release bundle
- **Policy:** DFIR-Nexus docs and code contain **no upstream repo references** — features are native to `tools/dfir-nexus/`

**Next:** D.0 Stellar (TI providers + full VR framework). CADRE Ansible wiring on provisioning remains separate.

### DFIR-Nexus B.0 "Pathfinder" COMPLETE — hardening slices (2026-06-05)

**B.0 fully closed** — production-grade foundation on top of A.0 Pioneer (v0.6.0). Initial release plus final thin slices:

| Slice | Shipped |
|:------|:--------|
| **B.0.1 DRAFT/HITL** | Password-gated approve/reject, PBKDF2 HMAC signing, 3-attempt lockout |
| **B.0.2 LangGraph** | 6 agents in `langgraph/agents/*.py`, parallel graph, HITL interrupt |
| **B.0.3 HTTP gateway** | `dfir-nexus gateway` — in-process + HTTP + **stdio** backends, lazy connect, **idle reaper** (60s) |
| **B.0.4 Examiner Portal** | `dfir-nexus portal` — 8-tab SPA, **in-browser approve/reject**, live timeline/evidence/hosts APIs |
| **B.0.5 Forensics + detection** | Plaso importer (32nd source), Velociraptor MCP (`vql_query`, `vql_collect_artifact`, `vrun_health`), `create_velociraptor_client()` (HTTP vs mock via `DFIR_NEXUS_VR_USE_MOCK`), SigmaHQ download (`detection_sigma_install`), MITRE Navigator layer, Sigma translation (`sigma_translate` kql/spl, `sigma_translate_kql`, `sigma_translate_spl`) |

- **MCP tools:** 40 (was 35 at v0.6.0)
- **Tests:** 364 pytest + 52 smoke steps
- **Docs:** [`tools/dfir-nexus/docs/B0-PATHFINDER.md`](tools/dfir-nexus/docs/B0-PATHFINDER.md), [`SUMMARY.md`](tools/dfir-nexus/docs/SUMMARY.md), [`ARCHITECTURE.md`](tools/dfir-nexus/docs/ARCHITECTURE.md)
- **CADRE bridge:** [`attack-matrix/DFIR-Nexus-Pioneer-workflow.md`](attack-matrix/DFIR-Nexus-Pioneer-workflow.md) — gateway/portal alongside Pioneer loop; Phase 3.5 active

**Superseded by C.0 Voyager (see above).** CADRE Ansible wiring on provisioning remains separate.

### DFIR-Nexus v0.6.0 — FEATURE COMPLETE (2026-06-20)

**DFIR-Nexus** — our agentic super DFIR tool — is now **feature-complete**. All 6 phases shipped in a single day (2026-06-20). Local git initialized at `C:\STUDY\Github\CADRE-Platform\CADRE\tools\dfir-nexus\` (commit `5b37837` on `master`, no push per user instruction).

**Predecessor features** (detection, ingest, case, RAG, triage) were ported into DFIR-Nexus during A.0–C.0. Historical assessment docs live in `docs/internal/integrations/`.

| Metric | v0.6.0 |
|---|---|
| **MCP tools** | 30 |
| **Artifact importers** | 31 (network/SIEM/DF/Linux/cloud/TI/generic) |
| **Modules** | 7 (llm, detection, ingest, analysis, case, polish, integration) |
| **Unit tests** | 311 (across 12 test files) — all pass |
| **Smoke test steps** | 42 — all pass |
| **Hayabusa-style rules** | 12 (inline in EVTX importer) |
| **Sigma templates** | 12 (T1003.001/.002, T1053.005, T1543.003, T1547.001, T1546.013, T1070.001, T1110, T1021.002, T1021.001, T1059.001, T1136.001) |
| **VQL hunt templates** | 27 (T1110, T1078, T1059.005/.007, T1053.005, T1136, T1098, T1071.001/.004, T1041, T1486, T1490, + more) |
| **vhir CLI subcommands** | 6 (ingest, search, analyze, case, nsrl, sigma) |
| **Case export formats** | 4 (JSON, Markdown, HTML, STIX 2.0) |
| **LLM providers** | 4 built-in (OpenAI, Anthropic OpenAI-compat, Ollama, LiteLLM) — any service implementing the OpenAI-compat standard works |

**Per-phase breakdown (added 2026-06-20):**

- **Phase 1 (Detection + LLM Layer)** — Sigma indexer, MITRE coverage, OpenAI-compat router with 4 providers
- **Phase 2 v1 (10 importers)** — Suricata, Zeek, Elastic, Splunk, Hayabusa, Velociraptor, MISP, OTX, JSONL, CSV
- **Phase 2 v2 (21 more importers)** — EVTX, KAPE, Prefetch, Wireshark, TheHive, VirusTotal, AbuseIPDB, ThreatFox, CloudTrail, Azure, auditd, syslog, auth.log, bash_history, Windows Registry, Scheduled Tasks, Services, AmCache, WMI Subscriptions, LNK, Browser History
- **Phase 3 (Analysis)** — CorrelationEngine, DetectionBridge, TimelineBuilder, VQLHuntGenerator (27 templates), BeaconDetector, SummaryGenerator, FullAnalysis
- **Phase 4a (Case Platform)** — Case + Finding + Evidence + HMAC audit chain + SQLite persistent store + 9 MCP tools
- **Phase 4b (Windows Parsers)** — Registry, Scheduled Tasks, Services, AmCache, WMI Subscriptions (5 parsers)
- **Phase 4c (Tier 3 Parsers + Hayabusa)** — Hayabusa-style ruleset (12 rules), LNK files, Browser History (Chrome/Edge/Firefox)
- **Phase 5 (Polish)** — NSRLDatabase (O(1) lookups, NSRLFile.txt + CSV), SigmaRuleGenerator (12 templates), vhir-style CLI (6 subcommands)
- **Phase 6 (Integration)** — VQLRunner (long-running polling, Mock+HTTP clients), CaseExporter (4 formats), VisionAnalyzer (LLM-powered image analysis with IoC extraction)

**Provider rename (breaking change):**
- `OpenAIProvider` → `OpenAICompatProvider`
- `AnthropicProvider` → `AnthropicCompatProvider` (uses Anthropic's OpenAI-compat endpoint, NOT native SDK)
- `OllamaProvider` → `OllamaCompatProvider`
- `LiteLLMProvider` → `LiteLLMCompatProvider`
- **Why:** Make the OpenAI-compatible API standard explicit. Any service implementing this standard works.

**Documentation shipped (all in `tools/dfir-nexus/docs/`):**
- `SUMMARY.md` — top-level feature summary (read this first)
- `ARCHITECTURE.md` — system design
- `PROVIDERS.md` — every supported LLM provider + config examples
- `PHASE1.md` through `PHASE6.md` — per-phase implementation details

**Doc updates across the parent CADRE repo:**
- `docs/internal/integrations/dfir-nexus.md` — updated 1-pager (v0.6.0 stats, ✅ status, local git info)
- `docs/internal/integrations/dfir-nexus-improvement-plan.md` — retrofitted to show ✅ on all shipped features
- `docs/internal/registry.md` — DFIR-Nexus row: 🔨 Building → ✅ v0.6.0 FEATURE COMPLETE
- `AGENTS.md` — Mini-Projects table + session entry updated

**Next: CADRE platform wiring** (held until CADRE plan01 testing completes per user instruction):
- Ansible playbook to install DFIR-Nexus on `provisioning` VM
- Live SSH connectors to pull Elastic/Suricata/Zeek output
- End-to-end real-data analysis: point DFIR-Nexus at CADRE lab telemetry from Phase 1-3 attack runs
- v0.7 backlog: 5 deferred features (OpenSearch indexer, push ingest webhook, Notion/IRIS export, rule translation, case template library)

### DFIR-Nexus Improvement Plan Archived (2026-06-22)

Per user 2026-06-22 — `dfir-nexus-improvement-plan.md` archived to avoid overlap with the active release roadmap.

**What was archived:**
- `docs/internal/integrations/dfir-nexus-improvement-plan.md` → `docs/internal/integrations/archive/dfir-nexus-improvement-plan-archived-2026-06-22.md`

**Why archived:**
- The improvement-plan.md was the original 30-feature plan captured on 2026-06-20, before the source-project assessment was completed.
- After the assessment (2026-06-22), `dfir-nexus-source-assessment-3-roadmap.md` became the authoritative forward-looking roadmap (A.0 "Pioneer" → E.0 "Constellation").
- Both docs covered the same features (DRAFT/HITL, Gateway, Portal, RAG, Windows baseline, etc.) — overlapping and confusing.

**What replaces it:**
- **1-pager** (`dfir-nexus.md`) — what DFIR-Nexus IS, status, design principle v3, stats
- **Release roadmap** (`dfir-nexus-source-assessment-3-roadmap.md`) — A.0 "Pioneer" → E.0 "Constellation" with detailed implementation plans

**Other docs updated** to point to roadmap instead of improvement-plan:
- `docs/internal/registry.md` — row updated to reference roadmap
- `AGENTS.md` — Mini-Projects table + session entry updated

### DFIR-Nexus SANS Plan vs plan1.7 Distinction Clarified (2026-06-22)

Per user 2026-06-22 — "this also has some of the sans exercises but from other courses to - for main cadre. lets not overlap them with our DFIR-Nexus."

Two separate SANS-touching documents in CADRE, with different purposes:

| Document | Purpose | Audience | SANS Courses | Output |
|---|---|---|---|---|
| **`plan1.7-defense-deepening.md`** + **`plan1.7-exercises.md`** | SANS-derived **defensive exercises** for CADRE lab users. Each exercise (EX-01 to EX-48) is a hands-on lab the user runs on the CADRE lab to **learn the tools manually**. | **CADRE lab user / student** | SEC503, FOR572, SEC511, FOR508, FOR500, FOR608, FOR578, SEC530 (8 courses, **network + architecture focus**) | 48 hands-on exercises covering tcpdump, Wireshark, Zeek, SiLK, RITA, Sysmon, Autoruns, AppLocker, KAPE, Prefetch, Registry, MFT, Memory, Timeline, Velociraptor, YARA, Sigma, Scapy, DoH, MITRE ATT&CK Navigator, STIG, SpiderFoot, ASF Triage |
| **`dfir-nexus-sans-tools-integration.md`** | SANS tools integrated as **importers/parsers/runners INTO DFIR-Nexus** (our MCP tool). Maps each tool to a specific DFIR-Nexus release module + function. | **DFIR-Nexus developers** | FOR500, FOR508, FOR608 (3 courses, **forensic focus**) | 250+ tools → 7 DFIR-Nexus modules |

**No overlap in purpose, only in tool names.** Each FOR500/FOR508/FOR608 tool that has a plan1.7 exercise is cross-referenced in the SANS tools integration plan with the `plan1.7 ref` column. Rule of thumb:
- **plan1.7** = "how to manually run this tool" (CADRE lab user)
- **DFIR-Nexus SANS plan** = "how DFIR-Nexus programmatically runs, parses output, and integrates with the agent graph" (DFIR-Nexus developer)

DFIR-Nexus does NOT cover the network/architecture courses (SEC503, FOR572, SEC511, FOR578, SEC530) — those are plan1.7's domain.

The SANS tools integration plan was updated to add a "Distinction from CADRE Plan 1.7" section with cross-references to plan1.7 exercises (EX-01 to EX-48).



**Release naming scheme changed** to avoid overlap with CADRE Plan 0.7/0.8/0.9/1.0:

| New name | Was | Theme | Status |
|---|---|---|---|
| **A.0 "Pioneer"** | v0.6.0 | FEATURE COMPLETE baseline | ✅ current |
| **B.0 "Pathfinder"** | v0.7 | LangGraph + DRAFT/HITL + Gateway + Portal + Plaso + Velociraptor MCP | planned |
| **C.0 "Voyager"** | v0.8 | RAG + Windows baseline + Volatility 3 + SANS FOR508/500 tools | planned |
| **D.0 "Stellar"** | v0.9 | TI providers + MITRE Navigator + threat actors | planned |
| **E.0 "Constellation"** | v1.0 | Production platform | planned |

**Letter prefixes (A, B, C, D, E) are unique to DFIR-Nexus — no conflict with CADRE Plans.**

**SANS Tools Integration Plan** — separate document at `docs/internal/integrations/dfir-nexus-sans-tools-integration.md`. Maps 250+ unique tools from SANS FOR500 + FOR508 + FOR608 to DFIR-Nexus releases:

- **FOR500** (Windows Forensics, 77 tools) — Eric Zimmerman EZ suite (18 tools), Volatility 2/3, MemProcFS, WinPMEM, AVML, Hindsight, OneDriveExplorer, MFCMAPI, RabbitHole, TSK/fls/mactime, 42 artifact types, 30+ MITRE techniques, 35+ Event IDs, 30+ persistence mechanisms
- **FOR508** (Advanced IR + Threat Hunting, 100+ tools) — KAPE, Plaso, Velociraptor, HollowsHunter, Memory Baseliner, Hiber2Bin, Bulk Extractor, all EZ tools + advanced parsers, MFT/USN/LogFile carving
- **FOR608** (Enterprise IR + Threat Hunting, 100+ tools) — Velociraptor (25+ artifacts, VQL templates), CyLR, Elastic Stack, KQL/sigmac, YARA, Sysmon (23 IDs), Plaso, Timesketch, AWS CloudTrail, M365 UAL, macOS/mac_apt, Docker, Aurora IR

**Total: 250+ unique tools → 100+ artifact types → 100+ MITRE techniques.**

**Estimated integration effort: ~30 weeks across B.0 → E.0 releases.**

**Comprehensive gap analysis** of DFIR-Nexus v0.6.0 against the 3 source projects it integrates. Evidence-first deep code inspection — every tool count verified via direct file inspection (not docs).

**Vision clarified (per user 2026-06-22):** DFIR-Nexus is the **massive DFIR section of CADRE** — a **comprehensive, industry-leading DFIR solution** that serves **standalone + agentic + CADRE-integrated** modes. It borrows the best of 3 predecessor projects + our forensic tooling (KAPE, Plaso, Hayabusa, Timesketch, WinPMEM, AVML, Volatility 3, Velociraptor MCP). **DFIR-mcp is the original predecessor** (per user); Security-Detections-MCP was assessed; DFIR-Companion was added third. We aim for **95%+ parity** with the union of source features, not a minimal subset.

**Source projects inventoried:**
- **DFIR-mcp suite (AppliedIR)** — **the original predecessor** (per user 2026-06-22). 83-100 MCP tools across 8-9 backends (3 local repos + 1 described), 11 packages in sift-mcp monorepo, 31 forensic catalog binaries, 22K RAG records, 2.6M Windows baseline records, 14 playbooks, 3,848 test functions, 28 CLI commands, 8-tab Examiner Portal with challenge-response auth, DRAFT/HITL approval with PBKDF2-derived HMAC signing (600K iterations), Bubblewrap sandbox, **LangGraph multi-agent pipeline** (Plan 7 spine).
- **Security-Detections-MCP** (michaelhaag) — **assessed**. 81 MCP tools, 8,200+ indexed rules from 6 sources, 172 MITRE actors, 488 techniques × 2,374 procedures, 10K+ extracted patterns, LangGraph agent pipeline (12 nodes), Cursor subagents (14), Claude skills (18).
- **DFIR-Companion** (hasamba) — **added third**. 230+ HTTP routes, 26 built-in importers + 1 IRIS reverse import + 1 declarative engine, 6 AI providers, 15 overridable prompts, 13 TI providers, 12 output formats (MD/HTML/DOCX/CSV/JSON/JSONL/STIX 2.1/Navigator/Asset-graph SVG/Swimlane SVG/blocklist/snapshot), 6 hunt-query platforms, browser extension with 6 console adapters, 9 3rd-party integrations, 208 test files.

**Key finding:** DFIR-Nexus is at **~28% feature parity** with the union of source projects (51 of 181 source features DONE). Goal: reach ~95% by v1.0.

**Coverage by layer:**

| Layer | DONE | Total | % |
|---|---|---|---|
| Detection engineering | 2 | 19 | 10.5% |
| Ingest / Importers | 31 | 50 | 62.0% |
| Case management / Audit chain | 4 | 20 | 20.0% |
| Forensic tool execution | 0 | 9 | OUT OF SCOPE |
| Windows baseline validation | 0 | 9 | 0% |
| Forensic RAG | 0 | 7 | 0% |
| Velociraptor integration | 2 | 15 | 13.3% |
| Analysis | 7 | 17 | 41.2% |
| Output / Reports | 4 | 14 | 28.6% |
| Push / Webhook | 0 | 11 | 0% |
| HTTP gateway | 1 | 10 | 10% |
| **LangGraph agentic pipeline** | 0 | 12 | 0% (NEW) |

**Design principle v2 (corrected per user 2026-06-22):**
- DFIR-Nexus is **BOTH a tool AND an agentic framework** (not "tool not agent framework")
- LangGraph multi-agent pipeline + Velociraptor MCP + multi-LLM router are all in scope (v0.7)
- Forensic tools (KAPE, Plaso, Hayabusa, Timesketch, WinPMEM, AVML, Volatility 3) are integrated, not deferred to "specialized use only"
- Industry practices (Sigma → SPL/KQL, MITRE Navigator, RBA, threat actor profiles) are core, not optional
- **Borrow all that's relevant to core DFIR work** — comprehensive, not minimal

**3 structural gaps preventing DFIR-Nexus from being production-grade (v0.7 priorities):**
1. No DRAFT / HITL approval workflow (Valhuntir's signature feature)
2. No HTTP gateway aggregation layer (sift-gateway)
3. No browser-based Examiner Portal (case-dashboard SPA)

**6 important feature gaps:**
4. No LangGraph multi-agent pipeline (Plan 7 spine) — **NEW, was incorrectly skipped**
5. No on-the-fly Sigma → SPL/KQL rule translation
6. No RAG knowledge base (22K records)
7. No Windows baseline validation (2.6M records)
8. No OpenCTI / YETI integration
9. No push-ingest webhook (`POST /cases/:id/push`)

**DFIR-Nexus strengths over predecessors:**
- **STIX 2.0 export** (Valhuntir has none)
- **VQL hunt generation** as a first-class module
- **Single-process deployment** vs Valhuntir's 3+ sub-processes
- **31 importers in one unified registry** vs DFIR-Companion's 26+ separate import files
- **AI vision** for screenshot/image analysis (Valhuntir has none)
- **OpenAI-compat standard across 16+ LLM services**

**Roadmap to ~95% parity (corrected to comprehensive):**
- **v0.7** (14 weeks, ~14K lines) — **LangGraph pipeline** + Velociraptor MCP server + DRAFT/HITL + Gateway + Portal + Plaso + Sigma download
- **v0.8** (8 weeks, ~7K lines) — Volatility 3 + RAG + Windows baseline + GraphRAG + deobfuscation
- **v0.9** (6 weeks, ~4K lines) — TI providers (OpenCTI/YETI/etc.) + Velociraptor framework + MITRE Navigator + threat actors
- **v1.0** (8 weeks, ~6.5K lines) — Push ingest + 3rd-party integrations (MISP/IRIS/Timesketch/Notion/ClickUp) + DOCX/CSV/SVG outputs

**Documents created:**
- `docs/internal/integrations/dfir-nexus-source-assessment.md` (Part 1: Inventory + Design Principle v2)
- `docs/internal/integrations/dfir-nexus-source-assessment-2-mapping.md` (Part 2: Gap mapping)
- `docs/internal/integrations/dfir-nexus-source-assessment-3-roadmap.md` (Part 3: Roadmap + Skip list, v0.7 expanded to include LangGraph)
- `docs/internal/integrations/dfir-nexus-codebase-review.md` (code-level verification of assessment)
- `tools/dfir-nexus/docs/STUDY-GUIDE.md` (NEW — full how-to-use guide)

### Added (2026-06-20 — DFIR-Nexus Phase 6: Integration — FEATURE COMPLETE)

- **Phase 6 — Final phase. DFIR-Nexus is now feature-complete.**
- **Velociraptor monitoring** (`dfir_nexus.integration.vql_runner`):
  - `VQLRunner` — long-running VQL query runner with configurable interval
  - `MonitorConfig` — endpoint URL, API key, retry/timeout settings
  - `MockVelociraptorClient` — for testing (synthetic results)
  - `HTTPVelociraptorClient` — placeholder for real Velociraptor gRPC/REST
  - Result handler callback for chaining to ingest pipeline
- **Case export** (`dfir_nexus.integration.case_export`):
  - `export_to_json()` — full structured case export
  - `export_to_markdown()` — human-readable report
  - `export_to_html()` — styled HTML with severity coloring
  - `export_to_stix()` — STIX 2.0 bundle with case as custom object + IoCs as indicators
  - `CaseExporter` — orchestrator with file-write support
- **AI vision** (`dfir_nexus.integration.vision`):
  - `VisionAnalyzer` — LLM-powered image analysis via OpenAI-compatible vision API
  - Base64 image encoding for vision-capable LLMs (gpt-4o, claude-3.5-sonnet, etc.)
  - IoC extraction (IPv4, SHA-256, URLs, domains, registry keys, MITRE techniques, GUIDs, BTC, IPFS)
  - JSON response parsing with plain-text fallback
  - Graceful failure when LLM not configured
- **25 new tests** in `test_integration.py` — all pass
- **Smoke test extended to 42 steps** (was 38) — all pass
- **Total unit tests: 311.** **Total smoke test steps: 42.** **Total MCP tools: 30.** **Total importers: 31.** **Case export formats: 4.**
- **`docs/PHASE6.md`** (NEW) — last phase documentation
- **DFIR-Nexus is now feature-complete** (Phases 1-6 done). Next: CADRE platform wiring.

### Added (2026-06-20 — DFIR-Nexus Phase 5: Polish)

- **NSRL hash DB lookup** (`dfir_nexus.polish.nsrl`):
  - `NSRLDatabase` — in-memory hash set with O(1) lookups by MD5/SHA-1/SHA-256
  - `load_from_csv()` and `load_from_nsrlfile()` for both CSV and NSRLFile.txt formats
  - `bulk_check()` and `annotate_artifacts_with_nsrl()` for batch operations
  - Singleton `get_nsrl_db()` / `reset_nsrl_db()`

- **Sigma rule auto-generator** (`dfir_nexus.polish.sigma_generator`):
  - 12 built-in Sigma templates: T1003.001, T1003.002, T1053.005, T1543.003, T1547.001, T1546.013, T1070.001, T1110, T1021.002, T1021.001, T1059.001, T1136.001
  - `SigmaRuleGenerator` with `generate_for_techniques()`, `to_yaml()`, `write_to_file()`
  - Convenience functions `generate_sigma_for_techniques()` and `generate_sigma_for_artifact()`

- **vhir-style CLI** (`dfir_nexus.polish.cli`):
  - 6 subcommands: `ingest`, `search`, `analyze`, `case`, `nsrl`, `sigma`
  - Full end-to-end forensic analysis from terminal
  - Run as: `python -m dfir_nexus.polish.cli <command>`

- **26 new tests** in `test_polish.py` (NSRL, Sigma, CLI) — all pass
- **Smoke test extended to 38 steps** (was 35) — all pass
- **Total unit tests: 286.** **Total MCP tools: 30.** **Total importers: 31.** **Sigma templates: 12.** **vhir CLI subcommands: 6.**

### Added (2026-06-20 — DFIR-Nexus Phase 4: Evidence Platform)

- **Phase 4a — Case lifecycle + HMAC audit chain + SQLite:**
  - `Case`, `Finding`, `EvidenceRecord`, `AuditEntry` dataclasses
  - `AuditChain` (HMAC-SHA256 chained hash, detects tampering)
  - `SQLiteStore` (persistent DB at `./data/cases.db`)
  - `CaseManager` (CRUD + auto-audit on all writes)
  - **9 new MCP tools:** `case_create`, `case_list`, `case_get`, `case_close`, `finding_record`, `evidence_register`, `evidence_register_artifact`, `case_audit_verify`, `case_audit_log`

- **Phase 4b — 5 critical Windows forensic parsers:**
  - `WindowsRegistryImporter` — Run/RunOnce, IFEO, Winlogon, AppInit_DLLs
  - `ScheduledTasksImporter` — Task Scheduler XML → T1053.005
  - `WindowsServicesImporter` — `reg query` text + services.csv → T1543.003
  - `AmCacheImporter` — Amcache.hve (with python-registry) + AmCache.csv
  - `WMISubscriptionsImporter` — MOF + CSV → T1546.013

- **Phase 4c — Hayabusa auto-detection + Tier 3 parsers:**
  - **Hayabusa-style ruleset** — 12 suspicious-event rules built into the EVTX importer, automatically tag events with MITRE techniques
  - `LNKFileImporter` — Windows shortcut files (via `lnkfile` lib)
  - `BrowserHistoryImporter` — Chrome/Edge `History` and Firefox `places.sqlite`. Auto-detects browser by table presence. Converts Chrome (1601) and Firefox (1970) epochs correctly.

- **62 new tests** across `test_case.py` (21), `test_parsers_4b.py` (21), `test_parsers_4c.py` (20)
- **Smoke test extended to 35 steps** (was 18) — all pass
- **Total MCP tools: 30** (was 21). **Total unit tests: 260.** **Total importers: 31.**
- **`docs/PHASE4.md`** (NEW) — architecture, what's implemented, what was deferred

### Changed (2026-06-20 — DFIR-Nexus Provider Rename + OpenAI-Standard Clarification)

- **Renamed provider classes** to make the OpenAI-compatible standard explicit:
  - `OpenAIProvider` → `OpenAICompatProvider`
  - `AnthropicProvider` → `AnthropicCompatProvider`
  - `OllamaProvider` → `OllamaCompatProvider`
  - `LiteLLMProvider` → `LiteLLMCompatProvider`
- **Updated all references:** `providers.py`, `router.py`, `llm/__init__.py`, `tests/test_llm_router.py`, `smoke_test.py` (if needed), README, AGENTS
- **`docs/PROVIDERS.md` created** (NEW) — explicit list of every supported provider (OpenAI, Anthropic OpenAI-compat, OpenRouter, Ollama, vLLM, LiteLLM, Groq, Together, Mistral, LocalAI, Perplexity, Cohere, Anyscale, DeepInfra, Azure OpenAI-compat, AWS Bedrock via proxy) with configuration examples
- **README updated** — clarified that DFIR-Nexus uses the **OpenAI-compatible API standard** (NOT Claude Code, NOT native Anthropic SDK). Any service implementing this standard works.
- **Why:** The old names (`OpenAIProvider`, `AnthropicProvider`) were misleading — they suggested the company's native SDKs, but actually all four providers use the same OpenAI-compatible standard. The new names make this explicit.
- **Note:** This is a **breaking API change** for any code that imports the old class names. Tests and smoke_test.py have been updated.

### Added (2026-06-20 — DFIR-Nexus Phase 3 Analysis Layer)

- **Phase 3 (Analysis Layer) — DONE** for DFIR-Nexus:
  - **6 analyzers** that integrate Phase 1 (Detection) + Phase 2 (Ingest) into a unified workflow:
    - `CorrelationEngine` — finds relationships between artifacts by shared IP/user/host/process/hash/MITRE technique/time
    - `DetectionBridge` — maps techniques observed in artifacts to existing detection rules + coverage gap analysis
    - `TimelineBuilder` — sorts + clusters events by time window into narrative timeline
    - `VQLHuntGenerator` — 13 Velociraptor VQL hunt templates for T1003.*, T1059.*, T1547.*, T1543.*, T1021.*, T1070.*, T1562.*, T1087.* + generic fallback
    - `BeaconDetector` — interval jitter + byte ratio + connection count analysis for C2 detection
    - `SummaryGenerator` — rule-based + LLM-enhanced (uses the existing LLM router)
  - **7 new MCP tools (21 total):** `analyze_correlate`, `analyze_technique_coverage`, `analyze_timeline`, `analyze_generate_hunt`, `analyze_detect_beacons`, `analyze_summarize`, `analyze_full`
  - **`analyze_full`** runs all 6 analyzers end-to-end in one MCP call
  - **24 tests** (`tests/test_analysis.py`) — correlation, bridge, timeline, hunt, beacon, summary
  - **Smoke test updated to 18 steps** — seeds a synthetic attack chain (port scan + auth + LSASS + persistence + lateral + 10 beacons) and runs all 7 analysis tools
- **Total MCP tools: 21** (8 detection + 6 ingest + 7 analysis). **Total tests: ~182** (63 + 95 + 24). **Total importers: 24.**
- **`docs/PHASE3.md`** (250 lines) — architecture, what works, what was deferred
- **The integration:** Phase 3 is the glue that makes the LLM able to drive the full pipeline — ingest, search, correlate, detect beacons, generate hunts, write exec summary — all from one MCP server.

### Added (2026-06-20 — DFIR-Nexus Phase 1 + Phase 2 Implementation)

- **`tools/dfir-nexus/`** — first two phases of DFIR-Nexus built at `C:\STUDY\Github\CADRE-Platform\CADRE\tools\dfir-nexus\`:
  - **Phase 1 (Detection Layer + LLM Router)** — 8 MCP tools, ~63 tests:
    - LLM Router with 4 providers (OpenAI / Anthropic / Ollama / LiteLLM), all using standard OpenAI-compatible API
    - Detection Searcher + Indexer (Sigma YAML parser) + MITRE Coverage (per-technique, matrix, gap analysis)
  - **Phase 2 v1 (Ingest Layer — 10 importers)** — 6 new MCP tools + ~60 tests:
    - **Network:** Suricata (eve.json), Zeek (TSV with .gz support)
    - **SIEM:** Elastic (JSONL with `_source`/signal wrapper detection), Splunk (CSV + JSONL)
    - **DF:** Hayabusa (CSV → Windows Event ID → ArtifactType mapping), Velociraptor (JSON hunt results)
    - **Threat Intel:** MISP (event JSON with Galaxy → techniques), OTX (pulse JSON with attack_ids)
    - **Generic:** JSONL and CSV catch-all importers
  - **Phase 2 v2 (Ingest Layer — 14 more importers)** — ~35 tests:
    - **Windows DF:** EVTX (raw binary, needs `python-evtx`), KAPE (BasicCollection directory walker), Prefetch (raw .pf, needs `prefetch-parser`)
    - **Linux DF:** auditd (text log), syslog (RFC 3164/5424), auth.log (sshd/sudo/su), bash_history (with reverse shell detection)
    - **Cloud:** AWS CloudTrail (eventName → severity, StopLogging → CRITICAL), Azure activity log
    - **Threat Intel:** VirusTotal v3 (last_analysis_stats → severity), AbuseIPDB (abuseConfidenceScore → severity), ThreatFox (CSV with confidence_level → severity)
    - **Case Mgmt:** TheHive (case JSON with observables → IoCs)
    - **Network:** Wireshark (JSON export with `_source.layers`, suspicious port detection)
  - **Common `Artifact` schema** — every importer yields Artifacts with timestamps, MITRE techniques, severity, host/user/IP/process/file/registry context, raw original data
  - **`ImporterRegistry` singleton** with auto-detection via `can_handle()` heuristic
  - **In-memory artifact store** with search by technique, source, severity, host, user, IP, free-text
  - **6 new MCP tools:** `ingest_list_sources`, `ingest_detect_and_parse`, `ingest_from_source`, `ingest_search`, `ingest_get_artifact`, `ingest_stats`
- **Total MCP tools: 14** (8 detection + 6 ingest). **Total tests: ~158** (63 + 60 + 35). **Total importers: 24.**
- **`smoke_test.py`** — 10-step end-to-end verification (no API key required) — includes new v2 sources (auditd, threatfox)
- **`docs/PHASE2.md`** (250 lines) — architecture diagram, what's implemented, what works, what's deferred
- **`docs/ARCHITECTURE.md`** — full system architecture (5 sections)
- **`README.md`** updated with Phase 2 features, examples, and acknowledgements
- **NOT done yet (user tasks):** git init for dfir-nexus, `pip install -e .`, run pytest, run smoke_test.py

### Added (2026-06-20 — DFIR-Nexus Improvement Plan Captured)

- **`docs/internal/integrations/dfir-nexus-improvement-plan.md` created** (18 KB) — comprehensive PR-style breakdown of:
  - **30 features to integrate** from 3 source projects (DFIR-mcp/Valhuntir, DFIR-Companion, Security-Detections-MCP)
  - **9-week implementation roadmap** in 6 phases (Detection Layer → Ingest Layer → Analysis Layer → Evidence Platform → Polish → Integration)
  - **LLM API strategy** — any OpenAI/Anthropic standard API (per user constraint), no vendor lock-in
  - **Module structure** (8 → 15+ modules)
  - **Testing strategy** (123 → ~170 tests)
  - **Credit sources** for README (Valhuntir, DFIR-Companion, Security-Detections-MCP)
  - **3 CADRE use cases** (Plan 7 spine, standalone, detection engineering)
- **`docs/internal/integrations/dfir-nexus.md` updated** — DFIR-Nexus ownership clarified (OUR TOOL, not external), references the improvement plan
- **`registry.md` updated** — DFIR-Nexus row now shows "OUR tool" with "🔨 Building" status, links to both 1-pager and improvement plan
- **`AGENTS.md` updated** — Mini-Projects section now shows DFIR-Nexus as OUR TOOL, with 3 source projects marked as "merge into Nexus"
- **DFIR-Nexus vision locked** (per user 2026-06-20):
  - OUR tool (not external, not fork)
  - Integrates best of DFIR-mcp/Valhuntir + DFIR-Companion + Security-Detections-MCP
  - Any OpenAI/Anthropic standard API
  - LLM-agnostic, MCP-standard, MIT license
  - Works as both CADRE-integrated (Plan 7 spine) AND standalone forensic tool
  - Credits sources when published

### Changed (2026-06-20 — References Folder Consolidation)

- **One folder rule enforced:** All CADRE references now live in `docs/internal/references/`. The root `references/` folder is gone; `docs/internal/reference/` (singular) never existed.
- **Final layout:**
  - `docs/internal/references/` — analysis docs (kds-root-key-attacks.md, project-nightcrawler-analysis.md)
  - `docs/internal/references/sources/` — cloned source repos (project-nightcrawler, uncanny)
- **Old paths updated:**
  - `CADRE/references/project-nightcrawler/` → `docs/internal/references/sources/project-nightcrawler/`
  - `CADRE/references/uncanny/` → `docs/internal/references/sources/uncanny/`
  - All references in `AGENTS.md` and `docs/internal/registry.md` updated to new paths
- **Path convention documented** in AGENTS.md: "External source repos live in `C:\STUDY\Github\CADRE-Platform\CADRE-Integrations\` (read-only). CADRE references them by path — no duplication. Locally cloned small references live in `docs/internal/references/sources/`. Analysis docs live in `docs/internal/references/`."

### Added (2026-06-20 — Integrations Registry + 9 1-pagers + AGENTS.md update)

**Step 1 — Registry index:**
- **`docs/internal/registry.md` created** (6 KB) — canonical index of all 12 active integrations + 2 sister projects + 3 internal references. Organized by which **Plan** consumes each. AI bootstrap directive: read this first when starting work on any Plan.

**Step 2 — Per-integration 1-pagers:**
- **`docs/internal/integrations/` directory created** with 9 thin 1-pagers (~3 KB each):
  - `dfir-nexus.md` — Plan 7 spine (97 MCP tools, HMAC audit chain, DRAFT/approval workflow)
  - `dfir-companion.md` — Plan 7/9 reference (24+ artifact importers, AI vision, features to borrow)
  - `security-detections-mcp.md` — Plan 5/7 child MCP (81 Sigma/Splunk/KQL/Sublime/CQL tools)
  - `c2stack-loki.md` — Plan 10 offensive C2 (paired C2Stack teamserver + Loki payload)
  - `npm-threat-emulation.md` — Plan 0.8 → fold into 1.8 (Shai-Hulud worm, 9 scenarios, deployed)
  - `impacket-iocs.md` — Plan 1/6/7 (97 mentions, core detection engineering reference)
  - `forest-trust-tools.md` — Plan 8 (Frida-based trust abuse toolkit, 55 mentions)
  - `ohmypcap.md` — Plan 0.7 → fold into 1.7 (Kali PCAP triage tool, 21 mentions)
  - `asftriage.md` — Plan 9 AI forensics (Claude Code/Codex CLI `.jsonl` investigator, EX-48 added)
- Each 1-pager follows standard template: Source, Source location, Plan mapping, Status, What it is, Why CADRE cares, Key commands, Integration points, Notes, Open questions

**Step 3 — AGENTS.md updated:**
- Top directive expanded to include `docs/internal/registry.md` as required first read
- New **"Mini-Projects & Integrations"** section added between Architecture and Commands
- 12 integrations + 2 sister projects summarized in a single table with Plan mapping + status
- Path convention documented: external sources in `C:\STUDY\Github\CADRE-Platform\CADRE-Integrations\` (read-only), locally cloned small refs in `CADRE/references/`

**Path strategy (per user decision):**
- External-only: source repos stay in `C:\STUDY\Github\CADRE-Platform\CADRE-Integrations\`
- No duplication into `CADRE/references/`
- CADRE references them by path through `registry.md`

**Removed from scope** (per user instruction): defending-code-reference-harness, DIGITAL-FORENSICS-CTF-LAB (moved out of CADRE-Integrations)

**Consolidation vision documented:** DFIR-Nexus = single source of truth for DFIR (absorbs DFIR-mcp + DFIR-Companion best features + Security-Detections-MCP as child MCP); C2Stack+Loki = paired offensive side

### Added (2026-06-20 — ASF Triage AI Agent Forensics Exercise)

- **EX-48 added to plan1.7-exercises.md** — "AI Agent Forensic Analysis with ASF Triage" (OALABS). 5-part exercise: setup (npm install + npm run dev), session recon, attack chain reconstruction, IoC extraction via flag system, redaction for sharing, detection engineering (Sigma rule for malicious Claude Code tool calls).
- **External reference #122 added** (OALABS ASF Triage — https://asftriage.openanalysis.net/). Client-side Vue 3 web app for investigating Claude Code + Codex CLI `.jsonl` transcripts.
- **Total exercises: 47 → 48.** Total external references: 121 → 122.
- **Why this matters for CADRE:** Every Claude Code / Codex CLI session I run on this project creates a `.jsonl` at `~/.claude/projects/...`. ASF Triage audits our own development, investigates insider-threat AI abuse scenarios, and produces detection rules. Companion to KDS Root Key attacks (#84-89) for "operator did X via AI agent" investigation workflows.
- **"Make it better" ideas documented (not yet implemented):** CADRE-specific redactor patterns (SIDs, NT hashes, gMSA blobs), suspicious-command flagging (auto-detect mimikatz/dsinternals/impacket in tool calls), MITRE ATT&CK auto-tagging, multi-agent expansion (Cursor/Copilot/Aider/Continue.dev/Windsurf/Cline), SIEM integration (export flags to Elastic index).

### Added (2026-06-20 — KDS Root Key Attacks Research: Grafnetter TROOPERS26)

- **KDS Root Key Attacks comprehensive analysis:** `docs/internal/references/kds-root-key-attacks.md` (300+ lines, 30 KB). Maps all 6 attacks from the talk to CADRE phases and explains the shared mechanism (KDS Root Key + DPAPI-NG SID Protectors).
- **6 new items added to Campaign_suggestions.md (#84-89):**
  - **#84 KDS Root Key Extraction** (post-DA prerequisite) — `Get-ADReplKdsRootKey` / `Get-ADSIKdsRootKey` / `Get-ADDBKdsRootKey`
  - **#85 Golden gMSA Attack** — offline password computation via `Get-ADDBServiceAccount`, predicts future 30 days
  - **#86 DSRM Password Extract & Set** — DC persistence via `Set-LsaPolicyInformation`, survives AD cred rotation
  - **#87 LAPS Bulk Extraction** — `Get-ADDBAccount -LapsPasswords` enhancement to 3.5L
  - **#88 Golden dMSA Attack** — Server 2025 dMSA variant of #85 (needs dMSA infra addition)
  - **#89 DPAPI-NG SID Protector Decryption** — covers BitLocker, PFX, DNSSEC, ASP.NET Core (most sub-techniques deferred — no infra)
- **Key insight documented:** All 6 attacks share a single root mechanism. KDS Root Key + DPAPI-NG SID Protectors. With DA, you can extract KDS root key via DCSync/LDAP/ntds.dit → derive ANY SID group key offline → decrypt ANY DPAPI-NG protected secret. **Zero network signature on the actual attack** — only detection is on the KDS root key dump side.
- **Testable today on CADRE (no infra changes):** #84, #85, #86, #87 — all need only Phase 6/7 DA which is already in CAMPAIGNS.md.
- **Testable after small playbook additions:** #88 (dMSA setup), #89-PFX (Branch B sub-technique).
- **Requires significant infra additions:** #89-BitLocker (re-deploy with BitLocker), #89-DNSSEC (enable), #89-ASP.NET (deploy app).
- **Detection engineering candidates for plan1.7 §15:** KDS root key 4662 events, LSA Policy modification (DSRM), gMSA auth from unexpected host, DPAPI-NG cache writes outside OS setup.
- **Per user instruction 2026-06-20: NOT added to CAMPAIGNS.md** — these are documented in Campaign_suggestions.md as research/study material. Will be moved to CAMPAIGNS.md when we reach the relevant phase (post-Phase 6/7) and decide to test.
- **Counts updated:** 40 Adopted, 38 Pending (was 32, +6 KDS items), 7 Research. Total 83 → 89.

### Added (2026-06-20 — Bookmarks Review: Tier 1 References)

- **Bookmarks file analyzed:** `C:\STUDY\Github\bookmarks.html` (3,217 bookmarks, 57 folders). Categorized by domain: github.com (721), learn.microsoft.com (198), sans.org (28), specterops.io (14), adsecurity.org (11), dirkjanm.io, synacktiv.com, etc.
- **CADRE-relevant bookmarks:** 214 across 21 topics (Kerberos, ADCS/ESC, DCSync, NTLM Relay, Coercion, Shadow Creds, RBCD, Unconstrained Delegation, Kerberoast, AS-REP, LOLBAS, LSASS/Mimikatz, Defender/EDR, LOLDriver, ADCS Hardening, Forest Trust, Entra/Azure AD, DPAPI, GPO abuse, NTLMv1, LAPS, WerFault, Supply Chain).
- **11 Tier 1 items added to external-references.md** (#110-120):
  - **#110 GPOddity** (Synacktiv) — GPO attack via NTLM relaying → Branch A Path F (WT023)
  - **#111 ADCSKiller** (grimlockx) — ADCS exploitation automation → Branch B
  - **#112 Locksmith** (jakehildreth) — ADCS misconfig checker → Branch B pre-flight
  - **#113 ColdWer** (0xsh3llf1r3) — WerFaultSecure LSASS dump BOF → Branch 3.5K
  - **#114 AADInternals** (Gerenios) — Azure AD/Office 365 PowerShell → Plan 11
  - **#115 XPN Azure AD Connect for Red Teamers** → Plan 11 P11.8
  - **#116 Practical NTLM Relaying (byt3bl33d3r)** — foundational → Branch B relay
  - **#117 Responder (lgandx)** — primary NTLM poisoner → Phase 0/5
  - **#118 PetitPotam detection (NCC Group)** → WT018 detection reference
  - **#119 Certify 2.0 (SpecterOps)** — ADCS enumeration → Branch B
  - **#120 Practice-AD-CS-Domain-Escalation (arth0sz)** — Certipy-based lab → Branch B
- **220 bookmarks saved for future batch additions** (not added individually to avoid noise).
- **External references: 109 → 120.**

### Added (2026-06-19 — UnCanny Coerce + LPE 0day + IPv4-Mapped IPv6 Phishing)

- **UnCanny repo cloned from https://github.com/0xHossam/UnCanny** (0xHossam, 2026-06-19) to `references/uncanny/UnCanny/` (1.1 MiB, source only — `lpe/lpe.c`, `lpe/plugin.c`, `poc/AppxManifest.xml`, `poc/Invoke-InstallServiceCoerce.ps1`, `poc/setup.sh`). New NTLM coercion primitive (machine account) + LPE 0day (non-admin → SYSTEM) via Windows Store InstallService loose-file AppX registration. Author: "not reliable for real red team ops because of its limitation" but the research is published for educational purposes.
- **SANS ISC diary 33090 (Xavier Mertens, 2026-06-19) processed:** eBanking phishing via IPv4-mapped IPv6 URL `hxxp://[::ffff:5511:74be]/kWC5PHA1` → `85.17.116.190` → Belfius phishing kit. New detection vector for URL parser bypass.
- **External references expanded (107 → 109):** Added #108 (UnCanny) and #109 (SANS ISC diary 33090).
- **Campaign_suggestions.md expanded (80 → 83 items):** 3 new entries — #81 UnCanny Coerce (Phase 5, ⏳), #82 UnCanny LPE (Phase 3.5, ⏳), #83 IPv4-Mapped IPv6 URL Parser Bypass (Detection Engineering, ⏳). All gated on Developer Mode check for UnCanny.
- **CAMPAIGNS.md expanded:**
  - **WT094 (UnCanny Coerce)** added to Phase 5 — "Alternative Coercion Techniques" table. New working coercion primitive alongside WT017 (PrinterBug). Pre-condition: Developer Mode on target.
  - **3.5N (UnCanny LPE)** added to Branch 3.5 — non-admin → SYSTEM via InstallService. Direct SYSTEM, no GodPotato/PrintSpoofer needed. Pre-condition: Developer Mode + Samba (impacket fails for loadable-image case).
  - Both WT094 and 3.5N added to 3.5 summary table.
- **plan1.7-defense-deepening.md expanded:** New §14 (UnCanny Coerce + LPE 0day Detection + IPv4-Mapped IPv6 Phishing) with 4 Elastic KQL rules, 3 Suricata rules (SID 1000095-1000097), 1 Zeek script, 2 Sysmon rules, PCAP analysis patterns, and detection coverage scoreboard.
- **Pending: Developer Mode check on CADRE VMs.** This is the gating factor. Run via WinRM from Kali:
  ```powershell
  Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense"
  # On dc01, mbr01, mbr02
  ```
  - If = 1 → UnCanny is directly testable
  - If = 0 → need to enable first (admin change to `00-domain-deploy.yml` — separate decision)
- **SANS ISC diary 33090 detection:** `http.request.uri` containing `[::ffff:` pattern → Suricata SID 1000096. Useful for future Phishing simulation / Campaign H.

### Changed (2026-06-19 — UnCanny + IPv4-Mapped IPv6 Deferred to Track G)

- **UnCanny + SANS ISC 33090 status changed from ⏳ Pending to 🔬 Deferred** per user decision "document only, defer test" — to be revisited during Track A (Hardened Environment Variant) or after Phase 8 completes.
- **CAMPAIGNS.md:** WT094 (UnCanny Coerce) and 3.5N (UnCanny LPE) status changed to 🔬. Test plans retained for future re-activation.
- **Campaign_suggestions.md:** 3 new items (#81, #82, #83) marked 🔬. New **Track G** added to Parallel Tracks: "UnCanny + Future Windows 0days" — covers the deferred path, the gating factor (Developer Mode), and the trigger to revisit.
- **Counts updated:** 40 Adopted, 32 Pending, 7 Research (was 4, +3 from UnCanny + IPv4-mapped IPv6), 1 Skip, 3 Reference. Total unchanged at 83.
- **Companion project:** Track G follows the same deferred pattern as Project NightCrawler (`references/project-nightcrawler/`) — both are "off-online-campaign" Windows vulnerability research that feeds detection rules, hardened variant testing, and future playbook expansion.

### Changed (2026-06-18 — Phase 0-3.5 Campaign Alignment)

- **All Phase 0-3.5 items from Campaign_suggestions.md now adopted into CAMPAIGNS.md** with detailed test steps. Per user instruction: "anything up to phase 3 need to go in campaign, nothing more until we finish them first." Confirmed adoption status of all 17 Phase 0-3.5 items (ADWS Enumeration, adidnsdump, SAMR, Honeypot, MSSQLHound, NTLMv1, WinGet, GAC Hijacking, SQL Server 2025 AI Abuse, UACME, Handle Leak, Electron App Backdooring, 8 LOLBAS, ctfmon, Offensive DPAPI, WerFault, LAPS, Azure AD Connect DPAPI).
- **NTLMv1 Rainbow Tables added to CAMPAIGNS.md Phase 2** with full test plan (SpecterOps "Into The Rainbow" reference). Includes verification of `LmCompatibilityLevel` registry setting, NTLMv1 vs NTLMv2 detection in Responder output, hashcat mode 5500, and post-test hardening.
- **Study Reference Library section added to CAMPAIGNS.md** — 6 study-ref topics now have entries so we know what to read before reaching each phase:
  - **Phase 3.5:** Windows Logon Types & Credential Storage Locations (HackTricks + Microsoft Learn)
  - **Phase 3.5:** Credential Guard Bypass Research (Wdormann / MITRE + ired.team)
  - **Phase 4:** SharpHound Detection (iPurple.team)
  - **Phase 7:** DCSync Attack and Detection (Altered Security)
  - **Phase 8:** Forest Trust SID Filtering (Dirk-jan)
  - **Phase 8:** CVE-2020-0665 — Forest Trust Privilege Escalation (Dirk-jan)
  - Each entry has: Why read, Source article, Key concepts to internalize, Action item.
- **Campaign_suggestions.md status updated** to reflect actual adopted state:
  - Summary table: 9 stale ⏳ → ✅ (SAMR, Honeypot, NTLMv1, Windows Logon Types, Credential Guard Bypass, SharpHound Detection, DCSync Attack, Forest Trust SID Filtering, CVE-2020-0665)
  - Per-item detailed sections: 13 stale ⏳ → ✅ (items 15, 19, 20, 22, 24, 27, 28, 31, 42, 49, 50, 51, 59)
  - CAMPAIGNS.md Phase Mapping table: 9 stale ⏳ → ✅
  - WT# table: 4 stale ⏳ → ✅ (24, 27, 31, 42)
  - Year/phase table: 2 stale ⏳ → ✅ (51, 59)
  - Recent Additions list: 1 stale ⏳ → ✅ (item 31)
  - **Total:** 31 Adopted → 40 Adopted, 41 Pending → 32 Pending. Total 80 unchanged.
- **Phase 5+ items NOT touched** per user instruction: items 11, 12, 14, 21, 23, 25, 26, 29, 30, 32, 33, 34-41, 43-48, 52-58 remain ⏳ for after Phase 3.5 completion.

### Added (2026-06-18 — Project NightCrawler Windows Vulnerability Analysis)

- **8 Windows vulnerability PoC repos cloned from https://git.projectnightcrawler.dev** (NightmareEclipse / "Church of Malware"). All multi-account mirrors — source code identical across `hxcker-263`, `Clozof`, `andsilvaf2024`, `recar`. Cloned to `references/project-nightcrawler/` (45.7 MiB, source-only — `RoguePlanet.exe` binary stripped, NuGet packages for MiniPlasma build retained, FsTx KTM log files for YellowKey retained).
- **Comprehensive analysis document created:** `docs/internal/references/project-nightcrawler-analysis.md` (300+ lines). Each of 8 repos analyzed with source-level walkthrough, CADRE relevance, and detection engineering recommendations.
- **MiniPlasma (HIGH impact for CADRE):** Re-discovery of CVE-2020-17103 (James Forshaw, Google Project Zero) — `cldflt!HsmOsBlockPlaceholderAccess` race condition unpatched/rolled back. Standard user → SYSTEM on ALL Windows versions via `CfAbortOperation` race + registry symlink (`HKCU\Software\Policies\Microsoft\CloudFiles\BlockedApps` → `HKU\.DEFAULT\Volatile Environment`) + WER `QueueReporting` task abuse + `wermgr.exe` replacement. Exploit does NOT require SeImpersonatePrivilege. Server 2025 confirmed vulnerable.
- **GreenPlasma (HIGH impact for CADRE, partial PoC):** CTFMON arbitrary memory section creation in SYSTEM-writable directories via `\Sessions\N\BaseNamedObjects\CTF.AsmListCache.FMPWinlogonN` symlink hijack. Affects Win 11/2022/2026 (=Server 2025). PoC partial — SYSTEM shell conversion left as CTF challenge.
- **YellowKey (MEDIUM, separate threat class):** BitLocker bypass via FsTx KTM log files planted in `System Volume Information\FsTx` + WinRE CTRL-hold trick. Affects Win 11 + Server 2022/2025. Requires physical/disk access — out of scope for online campaign but useful as threat-modeling reference.
- **Detection engineering opportunities:** `CfAbortOperation` (cldapi.dll only) is the killer single-event signature for both MiniPlasma + GreenPlasma. ETW provider `Microsoft-Windows-CldFlt` would be high-signal/low-volume. Registry symlinks via `Microsoft-Windows-Kernel-General` Event 16. Named pipe `MiniPlasmaWERPipe` is unique.
- **Campaign_suggestions.md expanded (77 → 80 items):** Added 3 research items (#78 MiniPlasma, #79 GreenPlasma, #80 YellowKey) in new "Project NightCrawler — Windows Vulnerability PoCs (2026-06-18)" section. Status: 🔬 Research only — NOT proposed for live execution on CADRE without snapshot + mbr01-only testing.
- **NOT included for live testing:** MiniPlasma execution would grant SYSTEM on mbr01/dc01/dc02/dc03/mbr02. WER `QueueReporting` task trigger + wermgr.exe replacement is invasive — could destabilize DC01 AD if run incorrectly. Recommend snapshot mbr01, run MiniPlasma there first, then iterate.

### Added (2026-06-14 — Full SANS Course Integration: 11 Courses + Exercise Docs)

- **All 11 SANS courses analyzed** from `CADRE-Courses/sans/pdf_extract/` (~300K lines): SEC503 (30K), SEC504 (31K), SEC511 (45K), SEC555 (42K), SEC583 (8K), FOR500 (4K), FOR508 (41K), FOR509 (41K), FOR572 (55K), FOR578 (27K), FOR608 (23K). Each mapped to CADRE lab relevance.
- **3 purple team courses analyzed** from `CADRE-Courses/purple/` (~81K lines): SEC565 (19K — Red Team Operations + Adversary Emulation Planning), SEC599 (30K — Purple Team Tactics + Kill Chain Defenses), SEC699 (32K — Advanced Purple Team: Automated Emulation Pipeline with Caldera + VECTR + Sigma + Elastic). SEC699 is the most impactful — teaches automated adversary emulation pipeline that directly maps to CADRE's methodology.
- **plan1.7-exercises.md created:** 45 defense exercises across 6 categories — Network Monitoring (EX-01 to EX-15), Endpoint Detection (EX-16 to EX-24), Forensics (EX-25 to EX-35), Threat Intel (EX-36 to EX-37), Security Architecture (EX-38 to EX-41), Purple Team Defense (EX-42 to EX-45). Sources: SEC503/511/530/555/583/599 + FOR572/500/508/608/578.
- **plan1.8-exercises.md created:** 31 offensive exercises across 8 categories — Recon (4), Password/Access (3), Execution/Lateral (8), Defense Evasion (3), Supply-Chain (4), Web App (3), Adversary Emulation Pipeline (4 — Caldera, VECTR, Sigma validation), Adversary Emulation Planning (2 — threat intel-driven). Sources: SEC504/565/699 + npm supply-chain.
- **plan1.7 §12 added (Additional SANS Course Integration):** Course inventory, tools to install (13 tools: Autoruns, Eric Zimmerman tools, KAPE, CyLR, Scapy, Merlin C2, YARA, passivedns, Plaso, Timesketch, Volatility, ModSecurity, MISP), exercise doc references, implementation phases (~38hr across 7 phases).
- **Key finding:** Autoruns + Eric Zimmerman tools + KAPE are the 3 most impactful missing tools. Sigma rules are the highest-priority detection gap. Velociraptor is underutilized — needs hunting workflows.
- **LOLBAS detection rules built:** 15 Elastic KQL rules from ML ground-truth dataset (500 malicious + 500 benign samples, 65+ features). Rules cover: Office→LOLBAS chain, high-entropy commands, regsvr32/mshta/certutil/bitsadmin/MSBuild/rundll32/cmstp abuse, hidden PowerShell, mimikatz indicators. Saved to `lolbin-detection-rules.md`. ~2hr deployment.
- **CYPFER honeypot detection integrated:** SAMR enumeration (LDAP-free), lastLogon = 0 honeypot detection, AD honeytoken deployment. Added to CAMPAIGNS.md Step 5-6, plan1.7 §9.5 #22, EX-22.
- **LOLBAS + GTFOBins integrated:** 8 LOLBAS execution techniques (MSBuild, mshta, regsvr32, rundll32, bitsadmin, msiexec, InstallUtil, cmstp) added to CAMPAIGNS.md Phase 3. GTFOBins techniques (python, perl, find, vim, awk, curl, env, tee) added to Branch D.

### Added (2026-06-12 — SEC503/FOR572 Complete Tool & Lab Integration)

- **plan1.7 §9 completely rewritten:** Now the master reference for SEC503 (GCIA) + FOR572 (GNFA) integration into CADRE. Full tool inventory (17 tools), 20 detection rules/exercises, 12 SANS lab → CADRE exercise mappings, 12 defensive exercise specifications, 6 tools to install on monitor VM. Covers: DNS tunneling/exfil/NXDOMAIN/passive DNS, NTLM relay/SMB signing/SMBv2/v3 forensics, TLS cert chain/JA3/self-signed, SiLK beaconing pipeline, IDS evasion detection, HTTP/2 forensics, Arkime workflow, NetworkMiner workflow, Kerberos forensics, DHCP/SMTP forensics, RITA workflow, Elastic NSM dashboards. Total ~22hr implementation.
- **12 defensive exercise specifications added (§9.8):** Each replicates a SANS lab in CADRE lab — tcpdump+Wireshark, Suricata rule writing, Zeek scripting, TLS decryption, IDS evasion, SiLK flow analysis, passive DNS, Arkime session forensics, Kerberos forensics, SMB forensics, NetworkMiner host enumeration, Elastic NSM dashboards. All use existing CADRE VMs.
- **6 tools to install on monitor VM (§9.7):** passivedns (high), NetworkMiner (medium), tcpflow (medium), ngrep (low), p0f (low), pmacct (low).
- **Updated §9.4 coverage matrix:** Now shows gaps in DNS, TLS, SMB, flow, DHCP, SMTP, passive DNS — all addressed by new sections.

### Added (2026-06-12 — Dirk-jan Mollema Research: AD + Azure/Entra ID)

- **Dirk-jan Mollema blog (https://dirkjanm.io/) analyzed (24 posts, 5 pages, 2018-2025):** Primary research authority for both on-prem AD (forest trusts, ADCS, RBCD, unconstrained delegation) and Azure/Entra ID (PRT, Cloud Kerberos Trust, Actor tokens, Intune ADCS, TAP, Federated Credentials, App Admin escalation). 16 new campaign suggestions added (Items 43-58).
- **Campaign_suggestions.md Tier 3 (Dirk-jan):** 16 new items grouped by phase — adidnsdump (#43, Phase 0), RBCD+Relay (#44, Phase 6), Unconstrained Delegation krbrelayx (#45, Phase 6 — mbr01 has unconstrained delegation), NTLM Relay to ADCS ESC8 (#46, Branch B), CVE-2019-1040 SMB-to-LDAP (#47, study ref), Zerologon alt (#48, study ref), Forest Trust SID Filtering (#49, Phase 8 study), CVE-2020-0665 Trust Bypass (#50, Phase 8 study), Azure AD Connect DPAPI Dump (#51, Phase 3.5 — Cloud Sync on dc01), Actor Tokens → Global Admin (#52, P11.1), Cloud Kerberos Trust → DA (#53, P11.2), PRT Phishing (#54, P11.3), Intune ADCS ESC1 (#55, P11.4), Temporary Access Pass Lateral (#56, P11.5), Federated Credentials Persistence (#57, P11.6), Application Admin → Global Admin (#58, P11.7). Summary table counts: 9 adopted, 49 pending, 1 research, 1 skip, 3 reference, total 63.
- **External references master index expanded:** `docs/internal/plan01-upgrades/external-references.md` — 24 new entries (#80-#103) for full Dirk-jan blog post list. Total references: 79 → 103.
- **plan1.7-defense-deepening.md §11 added (ADCS/Forest Trust/Relay Defense):** 8 detection areas — ADCS ESC8 (Suricata SID:1000070, Elastic EID 4886/4887), Forest Trust SID Filtering (Zeek cross-realm TGS with ExtraSid), CVE-2020-0665 (study ref), Unconstrained Delegation abuse (Suricata SID:1000071 + Elastic EID 4624 Type 3 Network), RBCD modification (Elastic EID 5137), NTLM Relay foundational (Suricata SID:1000072), Kerberos Relay over DNS (Suricata SID:1000073), adconnectdump (Sysmon EID 1). Implementation ~8.5hr. Pairs Phase 6/8/Branch B execution with detection.
- **plan1.8-offensive-upgrades.md §10 added (Dirk-jan Plan 11 offensive):** 8 Plan 11 offensive techniques (P11.1-P11.8) — Actor Tokens (highest impact Entra ID vuln), Cloud Kerberos Trust (hybrid chain via Cloud Sync on dc01), PRT Phishing (MFA bypass), Intune ADCS ESC1 (cloud → on-prem), Temporary Access Pass (TAP abuse), Federated Credentials Persistence, Application Admin → Global Admin (unpatched since 2019), adconnectdump (Phase 3 SYSTEM → Plan 11 bridge). Priority: **P11.8 (adconnectdump) first** — bridges Phase 3 SYSTEM to Plan 11 hybrid chain. Total ~23hr for all 8 techniques.
- **Dirk-jan is #1 reference for AD/Azure research** going forward. Future blog posts by him should be triaged into plan1.7 (defense) or plan1.8 (offense).

### Changed (2026-06-12 — SANS Network Forensics + Malware-Traffic-Analysis Workflow)

- **SANS SEC503/FOR572 analyzed for CADRE relevance:** 3 major network detection gaps identified: DNS analytics (no DNS tunneling/exfil detection), SMB forensics (no NTLM relay/named pipe detection), TLS deep inspection (no cert chain validation). 6 high-value detection rules documented in plan1.7 §9: DNS tunneling (Zeek), DNS TXT exfil (Zeek), NTLM relay (Suricata), SMB signing alerts (Suricata), TLS self-signed cert (Suricata), SiLK beaconing. ~7hr implementation.
- **Malware-traffic-analysis.net workflow proposed:** plan1.7 §10 — Download real malware PCAPs → OhMyPCAP + cadre-* rules → verify detection → build missing rules → update source matrix. 6 recommended PCAPs (Lumma, XLoader, njRAT, Remcos, GuLoader, ClickFix). Do AFTER campaign validation complete.
- **External references master index updated:** `docs/internal/plan01-upgrades/external-references.md` — 71 references total. SEC503 (#69), FOR572 (#70), malware-traffic-analysis.net (#71) added.
- **Campaign_suggestions.md lifecycle restructured:** Phase 3.5 (Credential Access) split from Phase 5 (Persistence). Summary table grouped by MITRE ATT&CK lifecycle. Phase 5 now contains only persistence techniques.

### Changed (2026-06-11 — DCOMIllusionist + CVE-2026-41089 + RTO Courses)

- **DCOMIllusionist added (Synacktiv):** Fileless DCOM lateral movement via .NET deserialization. Cross-session execution, in-memory DLL loading, NTLM relay via `--curl`. Campaign_suggestions.md #32, Phase 5. Study guide saved: `05-study-guide/ref-dcom-illusionist.md`.
- **CVE-2026-41089 Netlogon RCE added:** CERT-EU advisory (2026-06-10). Unauthenticated RCE on DCs (CVSS 9.8, actively exploited). All 3 CADRE DCs likely unpatched. Campaign_suggestions.md #33 — standalone exercise, not main campaign (would short-circuit credential chain).
- **RTO-Windows-Persistence course integrated:** 4 new persistence techniques: DLL Hijacking (#34), COM Hijacking (#35), IFEO (#36), LSA SSP/Password Filter (#37). All mapped to Phase 5 (Persistence).
- **RTO-Windows-PrivEsc course integrated:** 4 new techniques: UACME (#38, Phase 3 UAC bypass), Named Pipe Impersonation (#39, Phase 5 priv-esc), Handle Leak (#40, Phase 3 kernel privesc), Token Dance (#41, Phase 5 token persistence).
- **LAPS Extraction added (#42):** From Zero Point Security RTO 2025. Local admin password stored in AD — extract via LDAP. Phase 3.5 Credential Access.

### Changed (2026-06-10 — SQL Server 2025 AI Abuse + OhMyPCAP)

- **SQL Server 2025 AI Abuse (SpecterOps):** `sp_invoke_external_rest_endpoint` for data exfil (100MB limit), `CREATE EXTERNAL MODEL` + UNC path for NTLM SMB coercion (Microsoft won't fix), `AI_GENERATE_EMBEDDINGS` for C2 transport. Campaign_suggestions.md #31, Phase 3. mbr02 already runs SQL Server 2025 Developer Edition — no upgrade needed. Study guide saved: `05-study-guide/ref-mssql2025-ai-abuse.md`.
- **OhMyPCAP added to plan1.7 §7:** Lightweight PCAP analysis tool (Suricata + YARA). Deployment target: Kali. Reference for quick PCAP feedback without accessing full Elastic stack.
- **RPC monitoring added to plan1.7 §8:** Future enhancement — `Microsoft-Windows-RPC` ETW provider for endpoint-level RPC detection. Complements network-level Zeek/Suricata.

### Changed (2026-06-09 — iPurple.team + UnPAC-the-Hash + ETW Internals)

- **9 iPurple.team articles added to Campaign_suggestions.md:** ADWS Enumeration (#19), LSASS Dump via WerFault (#20), Cross-Session Activation (#21), SharpHound Detection (#22), BadSuccessor + Golden dMSA (#23), WinGet Proxy Execution (#24), EntryPoint Hijacking (#25), SpeechRuntime Lateral (#26), GAC Hijacking (#27), Credential Guard Bypass (#28).
- **UnPAC-the-Hash added (#29):** SpecterOps deep-dive on Kerberos U2U authentication. Extract NT hash from PKINIT TGT via U2U service ticket. Chains with ADCS ESC attacks (Branch B). Study guide saved: `05-study-guide/kerberos-u2u-unpac-the-hash.md`.
- **ETW Internals added (#30):** kernullist blog — ETW architecture, hooking, tampering, detection. Detection engineering reference for understanding how attackers blind EDR/Sysmon telemetry.
- **External references master index created:** `docs/internal/plan01-upgrades/external-references.md` — tracks all 50+ external sources referenced in CADRE.
- **4 iPurple.team study guides saved:** `05-study-guide/ref-adws-enumeration.md`, `ref-lsass-werfault.md`, `ref-cross-session-activation.md`, `ref-sharphound-detection.md`.

### Changed (2026-06-08 — Branch 3.5 Expansion: WMI Persistence + Invisible Tasks + VMware Escape Research)

- **CAMPAIGNS.md Branch 3.5 expanded with 2 new techniques:**
  - **3.5J — WMI Event Subscriptions** (T1546.003): Fileless persistence via SYSTEM on mbr01. No disk artifacts, no registry run keys, no scheduled tasks. Survives reboots. Detection requires Sysmon 19/20/21. Full commands added: filter + consumer + binding creation, verification, cleanup.
  - **3.5B enhanced — Invisible Scheduled Tasks**: Security Descriptor deletion technique added to existing Scheduled Task branch. Deleting `Security` subkey from `HKLM\...\TaskCache\Tree\<task>\Security` makes task invisible to `schtasks /query`, Task Scheduler GUI, PowerShell `Get-ScheduledTask`, and Autoruns. Task still executes on schedule. Detection: Sysmon 12/13 + raw registry enumeration under SYSTEM.
- **Branch 3.5 summary table updated** — execution order: `3.5F → 3.5A → 3.5G → 3.5H → 3.5B → 3.5C → 3.5D → 3.5E → 3.5I → 3.5J`. New rows: `3.5B†` (invisible tasks), `3.5J` (WMI subscriptions).
- **Campaign_suggestions.md updated** — Items 8 (WMI Event Subscriptions) and 10 (Invisible Scheduled Tasks) marked ✅ adopted. DLL Sideloading removed (evasion techniques covered in separate project). Phase mapping table, testing checklist, integration priority, and near-term additions all updated.
- **VMware escape research doc created** — `docs/internal/plan01-upgrades/vmware-escape-research.md`. 4 VMware escape writeups (2024-2025): Synacktiv Pwn2Own Berlin, NCC Group, Theori chain, Bug Tamer. Risk assessment table for CADRE's VMware setup. Hardening recommendations with `.vmx` settings (disable shared folders, clipboard, drag-and-drop, vmci). Phase mapping showing highest risk at Phase 3 (code exec on guest) and Branch 3.5 (SYSTEM on mbr01).
- **RAPTOR v3.0.0 reviewed** — Autonomous offensive/defensive research framework (Semgrep/CodeQL scanning + exploit generation). Not relevant to CADRE — it audits codebases for software vulnerabilities, not AD attack simulation.
- **`05-study-guide/` restructured** — Old cert-specific content moved to `10-cert-map/`. New `05-study-guide/` now holds deep-dive attack reference per campaign phase. Phase 0 (Reconnaissance), Phase 1 (Initial Access), Phase 2 (Credential Harvesting) study guides written. Remaining phases created after each phase is tested.
- **CAMPAIGNS-METADATA.md updated with Branch 3.5 entries** — 3.5F (SAM dump), 3.5A (Winlogon registry), 3.5H (ctfmon.exe), 3.5I (Token impersonation ❌), 3.5B (Scheduled Task), 3.5D (File Detonation), 3.5J (WMI Persistence) — all with full theory, prerequisites, telemetry expectations.
- **Impacket protocol-level IoCs mapped** — 73 Impacket IoCs mapped to CADRE phases in `docs/internal/plan01-upgrades/plan1.7-defense-deepening.md`. Tier 1: 9 Suricata rules + 3 Zeek scripts. Tier 2: 4 cluster models. Tier 3: 4 hunting queries.
- **npm supply-chain upgrade planned** — TanStack Shai-Hulud evolution (May 2026) analyzed. 3 new scenarios (F-11 IDE persistence, F-12 dead-man switch, F-13 prepare hook) documented in `docs/internal/plan01-upgrades/plan1.8-npm-upgrade.md`. `plan0.8-supplychain.md` restored to original location.

### Changed (2026-06-04 — Campaign Verification: Phase 1-3 End-to-End from Kali + Recon Section + SQL Auth Fix)

- **Reconnaissance section added to CAMPAIGNS.md** — Step 1: Anonymous enum (Server 2025 blocks both DCs). Step 2: Kerberos user enum via nmap on port 88 finds 20 valid users across both domains (child.cadre.local + cadre.local) with zero credentials. Key finding: `analyst_cloud` is in root domain (cadre.local), never discovered by BloodHound because BH was only run against child.cadre.local.
- **Phase 1-2 verified end-to-end from provisioning (Kali):** AS-REP roast → intern_blue → ACE#18 ForceChangePassword → analyst_t2 → Kerberoast → svc_mssql + analyst_t1 (both SPNs revealed in single hashcat run). Hashcat mode corrected from 19700 to 13100 (RC4-HMAC, verified). Wordlist changed from rockyou.txt to `cadre_passwords.txt` (7 real + 17 decoy passwords).
- **Phase 3 attack chain FIXED — SQL auth from Kali:** Campaign originally used `-windows-auth` which fails from non-domain-joined Kali. Fix: enabled mixed mode auth (registry `LoginMode=2`), enabled SA login, created SQL logins for `svc_mssql` and `analyst_t1`, granted IMPERSONATE on sa to analyst_t1 SQL login. Full chain verified: `Kali → SQL auth (analyst_t1) → IMPERSONATE sa → xp_cmdshell → GodPotato → nt authority\system`. No SSH cheat, no domain-join required.
- **Server 2025 protections documented** — LSASS PPL, VBS, Credential Guard are disabled in lab via `04-vulnerabilities.yml` (not defaults). Protection matrix table added to CAMPAIGNS.md showing what works/blocks on default Server 2025.
- **Token impersonation marked PATCHED** on Server 2025 — WTSQueryUserToken, OpenProcessToken + DuplicateTokenEx + ImpersonateLoggedOnUser all fail with error 1346. File execution (WT063-068) is the next step for analyst_cloud compromise.
- **File moved to `ansible/files/cadre_passwords.txt`** for repo storage.
- **Updates across 4 files:** `sql-integration-guide.md` (mixed mode + SQL logins), `attack-specifications.md` (SQL logins in feature table), `CAMPAIGNS.md` (Phase 3 SQL auth, recon section, hashcat fixes, token impersonation marked patched), `09-sql-wsus-verify.yml` (3 new verify tasks: mixed mode, SA enabled, SQL logins exist).
- **Lessons learned:** BH data is identical across all user collections (zero difference between intern_blue and svc_mssql). BH from non-admin users can't enumerate local admins, sessions, or RDP users on target machines. SQL Server Express mixed mode auth must be explicitly enabled via registry (`HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQLServer\LoginMode = 2`). SA account may be disabled after install — must be enabled manually.

### Changed (2026-06-03 — Single-Campaign Restructure: 8 Phases + 4 Branches; Phase 1 Narrative)

- **CAMPAIGNS.md completely restructured** from 4 separate campaigns (A-D) into a single unified campaign with 8-phase main spine + 4 branches (A: ACL Abuse, B: ADCS, C: SCCM, D: Linux Pivot). Main spine tracks the credential chain from zero to all 3 domains; branches diverge at Phase 4 (BloodHound discovery). 75 campaign attacks + 14 E exercises + 10 F supply-chain = 99 total. See `attack-matrix/CAMPAIGNS.md` and `attack-matrix/CAMPAIGNS-METADATA.md`.
- **Phase 1 narrative rewritten** with full scenario flow: Kerberos user enumeration (replaces broken null session) → discover `intern_blue` → AS-REP roast → crack hash → BloodHound recon with new credential → discover ACE#18 + SPN → reveals Phase 2. Includes "what happened" admin-mistake narrative. Remaining phases to be rewritten with same depth as we progress.
- **GOAD-style topology diagram added** to `CAMPAIGNS.md` — shows all VMs with IPs, services, misconfigs, domain trusts, and numbered attack arrows from Kali (①→⑦). Second mermaid diagram shows phase/branch flow.
- **WT028 (null session)** ❌ Invalid — SAMR null bind blocked on Server 2025. Walkthrough struck through, removed from tracker, script annotated. **WT031 (password spray)** ⏳ Pending relocation — valid technique, needs user list source. **WT018-020 (coercion variants)** ❌ Non-functional on Server 2025 — EFSR blocked, DFSNM undetectable, FSRVP unavailable.
- **CAMPAIGNS-METADATA.md created** — per-attack companion with playbook refs, ACE#s, telemetry expectations. 387 lines, 99 entries.
- **ATTACK-MAP.md updated** — attack platform changed from "Kali .41" to "provisioning .60", attack flow shows main spine + 4 branches, machine configs updated (RestrictAnonymousSAM: 1 ❌), mindmap strikes through invalid WTs, coverage summary updated.
- **`provisioning` → `Kali`** terminology adopted across CAMPAIGNS.md for user clarity.
- **All 5 supporting directories updated**: `01-walkthroughs/` (WT028/031/018-020 banners + README table), `02-diagrams/` (attack-flow.md mermaid redone + README terminology), `03-attackpath/` (quick ref, struck sections, totals), `04-automation/` (script headers annotated), `05-study-guide/` (9 files: cert paths renumbered, WT028/031 status fixed, coverage summary corrected).
- **`python-is-python3`** installed on provisioning VM to fix `impacket` script execution on Ubuntu 24.04.
- **tracker.md** — WT028/WT031 removed (empty entries deleted), WT003/WT002/WT041 commands pre-filled, campaign phase numbering aligned with new 8-phase structure.
- **`CAMPAIGNS_v2.md` → `CAMPAIGNS.md` (promoted to canonical).** The restructured 100-attack pipeline is now the single source of truth. Original 60-attack campaign preserved at `attack-matrix/CAMPAIGNS_v1_archived.md`. Header in `CAMPAIGNS.md` now opens with: "Implements `docs/internal/plan01-telemetry-catalog/phase1-source-matrix/five-stream-merge.md`."
- **All `CAMPAIGNS_v2.md` references updated to `CAMPAIGNS.md`** in: `AGENTS.md`, `CHANGELOG.md` (this file), `attack-matrix/02-diagrams/attack-flow.md`, `attack-matrix/02-diagrams/README.md`, `attack-matrix/01-walkthroughs/README.md`, `attack-matrix/prerequisites.md`, `attack-matrix/README.md` (3 occurrences).
- **`five-stream-merge.md` updated to reflect post-restructure counts**: E 13 → 14 (13 verified + WT093 ransomware), G 12 → 11 (WT093 moved out). §3 result table, §3 totals line, and §5 downstream-impact table refreshed. Intermediate "92 unified" column removed; two-column (Before/After-100) replaces the three-column table.
- **OCD AD mindmap cross-reference noted** in this session (link only — not a lab source of truth): `https://orange-cyberdefense.github.io/ocd-mindmaps/img/mindmap_ad_dark_classic_2025.03.excalidraw.svg`.

### Added (2026-06-03 — Campaign A restructured: G+H blended inline, RDP + phishing setup)
- **CAMPAIGNS.md restructured** (formerly `CAMPAIGNS_v2.md`, promoted to canonical 2026-06-03): G (11 post-exploit attacks) and H (6 initial access attacks) no longer standalone sections. G attacks blended inline into Phase 3 (WT082/083/090), Phase 5 (WT084-087), Phase 7 (WT088-089), Phase 8 (WT091-092). H attacks (WT063-068) added as alternate entry path in Phase 3 alongside primary SQL xp_cmdshell. WT093 moved to E as standalone ransomware exercise. Phase 2.5 fixed — uses ACE#18 (intern_blue → ForceChangePassword → analyst_t2 → getTGT → Kerberoast) instead of broken direct-password approach on Server 2025.
- **Phishing setup deployed on mbr01**: RDP enabled (`fDenyTSConnections=0`), firewall rule enabled, `CADRE\analyst_cloud` added to `Remote Desktop Users`, `C:\Users\analyst_cloud\Downloads\` and `C:\Tools\` created.
- **04-vulnerabilities.yml/verifyOnly**: Added RDP enable tasks (fDenyTSConnections + firewall) to `windows_servers` play + verify-only counterparts.
- **06-member-services.yml/verifyOnly**: Added new play for phishing setup (Remote Desktop Users group membership, Downloads directory, Tools directory) + verify-only checks. Fixed pre-existing unquoted bracket task names that broke YAML safe_load.
- **tracker.md**: WT003 (AS-REP) and WT002 (AES Kerberoast) already documented with raw event data from 2026-06-02 — WinSec PRIMARY (4768/4769), Suricata ET:2000002, Zeek kerberos.log, Sysmon EID 3, Endpoint Network corroboration.
- **BloodHound data collected**: All 3 domains (cadre.local, child.cadre.local, range.local) via bloodhound-python + SharpHound. 49 users, 6 computers, ~187 groups, ACL paths confirmed from playbooks.
- **Phase 0.1 implementation tracker**: Stage 1–3 documented. All 31 attack scripts written. WiX/HTML Help Workshop/SharpHound transferred to provisioning VM. Defender disable fixed on all 5 Windows VMs.

### Fixed (2026-06-02 — Windows Defender disable on Server 2025)
- **Root cause identified:** Server 2025 Tamper Protection silently overrode all previous Defender disable attempts — `DisableAntiSpyware` registry key and `Set-MpPreference` were both rejected.
- **Fix applied:** Tamper Protection disabled first (`HKLM:\...\Features\TamperProtection=0`), then WinDefend service stopped+disabled, then registry policy keys applied (DisableAntiSpyware, Real-Time Protection flags), then all MpPreference layers disabled (11 flags), then SpyNet/cloud reporting off.
- **Verified on all 5 Windows VMs:** dc01, dc02, dc03, mbr01, mbr02 — all show Tamper=0, AntiSpy=1, Service=Stopped. `Get-MpPreference` returns `0x800106ba` (expected — means Defender service is dead).
- **`04-vulnerabilities.yml`**: Updated Defender disable task with Tamper Protection fix + expanded coverage.
- **`04-vulnerabilities-verifyOnly.yml`**: Added Tamper Protection check to verify task.

### Added (2026-06-01 — Initial Access Enhancement + Campaign H Proposed)
- **Initial access gap identified + proposal created**: CADRE had no front-end simulation (all attacks assume attacker is already inside). `phase0.1/initial-access-enhancement.md` proposes 6 file-based initial access techniques (LNK, MSI, CHM, HTML Smuggling, AutoIt3, EXE) using only existing lab infra — no SMTP/email server needed. Proposed as Campaign H.
- **Pipeline scope expanded to 110 attacks across 5 workstreams**: Added Campaign G (12 MITRE gap attacks) and Campaign H (6 initial access scenarios) to the pipeline. All source-matrix docs (README, source-matrix-grid, verification-table, ATTACK-REFERENCE-MAP, four-stream-merge, telemetry-source-matrix) updated with Campaign G/H references.
- **four-stream-merge.md**: Updated from 104→110 attacks, 5 workstreams, 8 campaigns. Campaign H row added to Result table.
- **Phase 0.1 implementation tracker**: `phase0.1/implementation-plan.md` created as the Stage 1–3 deployment tracker for 31 new attacks (Campaign E 13 + G 12 + H 6). All 31 attack scripts written to `04-automation/campaign-{e,g,h}/` — 13 E scripts (WT069–WT081) for network defense, 12 G scripts (WT082–WT093) for post-exploitation, 6 H scripts (WT063–WT068) for initial access. Stage 1 (deploy) active — 25 attacks require zero infra setup, 6 need tooling staging (WiX, HTML Help Workshop, procdump, AutoIt3, test binaries).

### Changed (2026-05-31 — Three Workstreams Merged: 60 Core + Campaign E + Campaign F)

- **Pipeline restructured**: No more per-attack back-and-forth. New execution order: fill source matrix (all 92 attacks) → write ALL rules (P0a + P0c + P0c-EDR + Campaign E audit + Campaign F npm) → one comprehensive E2E → Sigma catalog.
- **`source-matrix-grid.md`**: Expanded from 59→92 attacks across 6 campaigns. Added Campaign E (23 Plan 0.7 network defense scenarios, E-01—E-23) and Campaign F (10 Plan 0.8 npm supply-chain scenarios, F-01—F-10). Deferred items marked `⏳` (E-17 TLS weak ciphers, E-18 cert chain depth, E-19 cross-subnet, E-20 QUIC C2 thresholds, E-21/22/23 SMB-pipe coercion — lab limitations documented).
- **`verification-table.md`**: Added Campaign E (23 rows — 16 verifiable + 7 deferred) and Campaign F (10 npm rows) with per-scenario columns. Banner updated to `Count X/92`. Deferred items pre-filled with `⏳`.
- **`README.md`**: Execution order restructured to unified pipeline. Added Batch 8 (Campaign E) + Batch 9 (Campaign F) to execution order. Deferred items and lab limitations documented alongside verifiable scenarios. Deliverable bumped from 60→92 attacks.
- **`telemetry-source-matrix.md`**: Grid reference updated 60→92 attacks, `⏳` added to legend, all references point to `source-matrix-grid.md` for the full grid.
- **`01-state.md`**: Restructured to 3-workstream unified pipeline. P0b status expanded from 60→92 attacks. Key decision entry added for workstream merger.
- **`AGENTS.md`**: Phase 0 section updated: 3 workstreams noted, Campaign E/F referenced.
- **Deferred scenarios (7):** E-17 (TLS weak ciphers — no RC4-capable client in OpenSSL 3.x), E-18 (cert chain >5 — lab certs 1-2 deep), E-19 (cross-subnet — single 192.168.77.x subnet), E-20 (QUIC C2 — 3600s/10MB thresholds impractical), E-21/22/23 (SMB-pipe DCE-RPC not supported by Suricata 8.0.5). Revisit if lab infrastructure changes.

### Added (2026-05-31 — Telemetry Source Matrix + Rule-Authoring Reference (P0c-0))

- **Root cause of "agent takes 20 tries to write one rule" identified + fixed:** the rule-writer guesses field names instead of pulling the live schema (e.g. `TicketEncryptionType:0x12` vs the real `winlog.event_data.TicketEncryptionType:"0x12"` — Fleet nests Windows Security under `winlog.event_data.*`/`event.code` while Sysmon/Endpoint use ECS). Fix = a **Field Dictionary built from live ES** the agent reads before writing.
- **`phase0/telemetry-source-matrix.md`** (NEW) — the rule-authoring reference. §1 Field Dictionary extraction recipe (`_cat/indices` + `_field_caps` per index → `phase0/field-dictionary/`), §2 source matrix + dedup decision rules (PRIMARY/CORROBORATING; only real overlap is Sysmon vs Endpoint.events vs 4688), §3 first-try-correct rule workflow + the 20-try failure-mode table + API contract, §4 the one-category custom-XDR model (single Elastic detection engine → `.alerts-security.alerts-*`; navigate by tags not categories; cross-source EQL `sequence` rules = the XDR showcase), §5 prior-art (OSSEM, Security-Datasets/Mordor, EVTX-ATTACK-SAMPLES, ART, Splunk Attack Range, MITRE CAR, DeTT&CT), §6 additional-attack domains mapped to existing plan stages, §7 build order. **Framework only — no field values or matrix cells from memory; live ES fills them.**
- **`phase0/source-matrix-grid.md`** (NEW) — empty 59-attack × 8-source grid (6 campaign tables) for the cheap model to fill from live verification. Only physically-impossible cells pre-marked `—` (Linux attacks in Windows columns; auditd column for AD attacks). Legend: P=PRIMARY (write rule here), C=CORROBORATING (catalog only, no rule), —=N/A.
- **Cross-reference banners added** to `source-matrix-grid.md` (DESIGN — fill before writing rules) and `verification-table.md` (PROOF — fill after, during live run) so the workflow order (field dictionary → grid PRIMARY → write rule → verification table) can't be done backwards. verification-table also gained a "count X/59 by unique T#, Quick-Confirms rows overlap campaigns — don't double-count" note.
- **P0c-EDR scoping gate defined:** a `cadre-e*` endpoint rule is justified ONLY where Endpoint.events is the sole/best source (process ancestry, per-process network, API events, DLL sideloading) — not where it re-detects a Security-log/Sysmon rule. Expected to cut the proposed ~10-15 endpoint rules to ~5-7 genuinely additive ones.

### Added (2026-05-31 — EDR Diagnosis: Root Cause Found, Playbook Fixed, P0c-EDR Proposed)

- **EDR behavioral alert silence diagnosed definitively**: Root cause is **Basic license restriction**. Elastic Defend's behavior_protection, ransomware, and memory_protection require **Platinum license** — Kibana API confirmed live policy shows `mode: off` for all three on Basic. `logs-endpoint.alerts-*` index will never be created (except possibly for malware scans). `logs-endpoint.events.*` (14 indices, ~39 MB) flows freely on any license tier.
- **Playbook fixed**: `12-elk-fleet.yml` lines 746-751 now set Platinum-only protections to `mode: off`. Malware stays `mode: detect` (manually enabled on live ELK). Comments document the license limitation. Previously declared `mode: detect` for all protections, but Elastic silently downgrades to `off`.
- **P0c-EDR proposed as new Phase 0 track**: 10-15 custom `cadre-e*` SIEM rules querying `logs-endpoint.events.process/file/network/registry/library-*` for attack patterns invisible in Windows security logs. Full spec at `plan0.7-defense-deepening.md §Phase F` — includes candidate rules (process chain, certutil file write, encoded PowerShell, download cradle, registry persistence, SMB file write, DLL load anomaly, LSA process access, schtasks, WMI), field mapping steps, and deployment via Kibana API.
- **Phase 0 restructured from 3 to 5 tracks**: New execution order: P0a → **P0c-0** (telemetry source matrix + field dictionary — NEW prerequisite) → P0c (custom gap rules ~30) → P0c-EDR (endpoint telemetry rules ~5-7 post-dedup) → P0b (full 60-attack E2E). The source matrix solves the "20 tries per rule" failure mode by providing exact field paths from live ES before any rule is written.
- **`elastic-field-dictionary/` directory created** at `phase0/elastic-field-dictionary/` — will contain `_indices.txt`, `fields-*.json`, `flat-*.txt` from live ES `_field_caps` queries. Replaces old `phase0/field-dictionary/` path name.
- **`telemetry-source-matrix.md`** — all 6 `field-dictionary` path references updated to `elastic-field-dictionary/`.
- **`00-plan.md`**: §2.1.2 P0c-0 added with dedup rules table (WinSec vs Sysmon vs Endpoint vs auditd), Sysmon/Endpoint tiebreaker, P0c-EDR gate explanation. Execution order updated from 4 to 5 tracks. Sequencing table includes P0c-0.
- **`01-state.md`**: §2.2 P0c-0 added with full task checklist (6 steps), dedup rules summary, and step-by-step execution plan.
- **`AGENTS.md`**: Phase 0 restructured to 5 tracks, P0c-0 listed as IN PROGRESS, P0c-EDR count adjusted from 10 to 5-7 (post-dedup).
- **`00-plan.md`**: §2 renamed "Four-Track Execution", §2.1.3 P0c-EDR added with rationale and candidate rules, §8.1 expanded with Plan 0.7 Zeek/Suricata + endpoint events, §9 sequencing includes P0c-EDR.
- **`01-state.md`**: §2 restructured to 4 tracks, §8.4 rewritten with definitive EDR diagnosis (live policy interrogation, license tier analysis, impact assessment).
- **`plan0.7-defense-deepening.md`**: 220-line §Phase F added — EDR context (F.1), what endpoint events add (F.2), 10 candidate rules (F.3), implementation plan (F.4), integration (F.5), deployment commands (F.6).
- **`phase0/README.md`**: Part D (P0c-EDR) added after Part C, §A.6 EDR note inserted, execution order updated.
- **`AGENTS.md`**: Testing + Constraints sections updated to 4-track model, EDR key learnings section added.

### Added (2026-05-29 — Plan 0.8 Supply-Chain Setup)

- **Installation guide** created at `docs/internal/npm-supplychain-installation-guide.md` — detailed step-by-step guide following SQL/ADCS/SCCM format. Covers linux01 (Node.js + repo + mock sink + auditd) and mbr01 (Node.js + repo + tools).
- **Deploy playbook** `16-supplychain.yml` — post-install configuration (mock sink systemd, auditd watches, symlinks). Verifies prerequisites before applying.
- **Verify playbook** `16-supplychain-verifyOnly.yml` — checks all components in place after manual install + deploy.
- **NPM-Threat-Emulation repo** extracted to both linux01 (`/opt/npm-threat-emulation`) and mbr01 (`C:\Tools\NPM-Threat-Emulation-main`) — 9 scenarios ready.
- **Mock webhook sink** running on linux01 :8080 (systemd service `npm-mock-sink`). Receives POST payloads in-lab — Zeek on monitor VM captures the network traffic.
- **Provisioning VM HTTP server** started on vmnet2 (192.168.77.60:8081) for file transfers to mbr01. Bound to vmnet2, not NAT.
- **Auditd watches** added to linux01: `npm_emulation` (directory watch) + `npm_node_exec` (node execve).
- **Playbook approach**: Semi-manual — manual install guide + deploy playbook (post-install config) + verifyOnly playbook. Scenarios are user's choice (not automated).

### Fixed (2026-05-29 — DNS Infrastructure Complete: All VMs Verified)

- **linux01 DNS A record created**: `linux01.cadre.local → 192.168.77.40` added to DC01 via `samba-tool dns add`. Record was missing because domain join didn't register it automatically.
- **All 6 machines resolve correctly**: linux01, provisioning, monitor can resolve dc01/cadre.local, dc02/cadre.local, dc03/range.local, mbr01/child.cadre.local, mbr02/range.local, linux01/cadre.local via DC01 DNS.
- **NAT safe to re-enable**: vmnet2 NIC keeps DC01 DNS (`60-dns.yaml`), NAT interface gets its own DHCP DNS. No conflicts — lab DNS goes through vmnet2, internet through NAT.
- **Verified DNS on all VMs**: DC01 ✅, DC02 ✅, DC03 ✅, MBR01 ✅, MBR02 ✅, linux01 ✅, provisioning ✅, monitor ✅, elk ✅, vr ✅.

### Fixed (2026-05-29 — DNS Infrastructure Fix: Ansible Playbooks + Vagrantfile)

- **DC01/DC02/DC03 DNS service resilience**: Added `win_service` task to `00-domain-deploy.yml` for all 3 DCs. Ensures DNS service is `start_mode: auto` and `state: started` after role installation. Prevents silent DNS failure if service stalls or VM reboots. Previously, DNS role was installed via `Install-WindowsFeature` but no task guaranteed the service stayed running.
- **DNS service verification added**: `00-domain-deploy-verifyOnly.yml` now checks DNS service status (`Running` + `Auto`) on dc01, dc02, and dc03. dc01 also gets a DNS resolution check (`Resolve-DnsName dc01.cadre.local` against 127.0.0.1) to confirm the server can resolve its own zone.
- **Linux DNS verification added**: `07-linux-infra-verifyOnly.yml` now checks that the vmnet2 NIC has DNS pointing to `192.168.77.10` (DC01) and can resolve `cadre.local`. Detects NIC dynamically via `ip -4 addr show | grep 192.168.77.x`.
- **Vagrantfile DNS provision block**: Added to all Linux VMs (linux01, provisioning, monitor, elk, vr). Auto-detects vmnet2 NIC, writes `/etc/netplan/60-dns.yaml` with DC01 as nameserver. Persists across reboots (netplan files survive reboot). `chmod 600` suppresses permission warnings.
- **NAT removed from attack VMs**: NAT networking previously caused DNS resolution failures because VMware DHCP assigned DNS servers pointed to the NAT gateway, not DC01. With NAT removed, all VMs use vmnet2 exclusively and must have explicit DNS configuration pointing to DC01.

### Fixed (2026-05-29 — DNS Infrastructure Fix + Suricata Rule Fix)

- **DNS infrastructure broken across all Linux VMs**: `linux01`, `provisioning`, and `monitor` all had no DNS configured on vmnet2 interface. `resolvectl dns eth0`/`eth1` showed nothing. Root cause: Vagrantfile configures `private_network` IPs but does not set DNS servers for Linux VMs (unlike Windows VMs which get DHCP-provided DNS via NAT). Fix: added a provision block to Vagrantfile that dynamically detects which NIC has the 192.168.77.x vmnet2 IP and writes `/etc/netplan/60-dns.yaml` pointing to DC01 (`192.168.77.10`). NIC ordering varies per VM: `linux01` has `eth0=vmnet2`/`eth1=NAT`; `provisioning` and `monitor` have `eth0=NAT`/`eth1=vmnet2`. Applied to running VMs immediately via SSH. `chmod 600` added to suppress netplan permission warnings.
- **DC01 DNS Server service broken**: Service showed "Running" but could not resolve queries even from `127.0.0.1`. Zones were loaded, firewall rules correct (UDP+TCP inbound Allow, Profile Any), `netstat` showed port 53 listening on both `127.0.0.1` and `192.168.77.10`. Fix: `Restart-Service DNS -Force`. DNS confirmed working after restart (queries from `linux01` returned correct A records for `cadre.local`, `dc01.cadre.local`, `dc02.cadre.local`).
- **Suricata SID:1000027 (NXDOMAIN burst) never fired**: Rule used `-> any 53` which matches only packets going TO port 53 (DNS queries). DNS responses come FROM port 53, so the rule never matched response packets with `dns.rcode:3`. Fix: changed to `-> any any` (rev:2). Rule now fires — 1 alert on 30 sequential NXDOMAIN queries to `nonexistent-NNN.cadre.local`.
- **DNS query domain choice matters**: Queries to unknown TLDs (`.badtld`) time out because DC01 has no forwarders/internet. Queries within `cadre.local` zone for nonexistent subdomains return proper NXDOMAIN. Attack scripts must target the authoritative zone.

### Changed (2026-05-29 — Plan 0.7 Attack Testing: Batch B-D Complete)

- **B-04 DNS Suspicious TLD**: SID:1000028 (157 fires), ET:2000021 (42 fires). Both rules fire on DNS query packets even though DC01 can't resolve external TLDs (no internet). Rule fix applied: ET:2000021 PCRE trailing dot removed so `test-domain.tk` matches.
- **B-05 DNS IP Literal**: SID:1000029 rev:2 (38 fires). Rule fix applied: PCRE changed to match `X.X.X.X.in-addr.arpa` format (actual PTR query format).
- **C-01 TLS 1.0**: SID:1000010 (1 fire), ET:2000031 (1 fire). ClientHello captured before timeout. Server 2025 rejects TLS 1.0.
- **C-02 High Entropy SNI**: ET:2000032 (0 fires). DC01 doesn't serve HTTPS — connection timeout before SNI sent. **Lab limitation — need HTTPS endpoint.**
- **C-03 Weak Ciphers**: Z6 (0 fires). DC01 doesn't serve HTTPS — connection timeout before cipher negotiation. **Lab limitation — need HTTPS endpoint.**
- **C-04 Cert Chain >5**: SID:1000014 (0 fires). **Lab limitation — lab certs are 1-2 deep, will never exceed 5.**
- **D-01 SMB Admin Share**: ET:2000012 (1 fire). ADMIN$ share access detected. First run with C$ didn't fire — rule requires `ADMIN$` in share name.
- **D-02 SMBv1**: ET:2000010 (99 fires). Fires from SMB traffic on the wire. NT1 negotiation rejected by Server 2025.
- **D-03 HTTP Suspicious UA**: ET:2000041 (10 fires). Works correctly.
- **D-04 HTTP Exploit Path**: ET:2000070 (21446 fires). Lots of background noise matching exploit paths.
- **D-05 HTTP Content-Type**: ET:2000072 (2 fires). Works correctly.
- **D-06 SSH Brute Force**: ET:2000060 (177 fires). Script fixed (removed BatchMode). Works correctly.
- **D-07 Cross-Subnet**: Z8 (0 fires). **Lab limitation — single subnet (192.168.77.x).**
- **D-08 Long Connection**: Z9 (3 fires). Fires from background connections exceeding threshold.
- **D-09 QUIC C2**: Z10/Z11 (0 fires). **Informational only — thresholds impractical (3600s/10MB).**
- **Rule fixes applied**: SID:2000001 removed (krb5_msg_type:14 doesn't work), SID:2000021 PCRE fixed, SID:1000029 PCRE fixed.
- **Script fixes applied**: B-04/B-05 run from linux01, SSH brute force removed BatchMode.
- **Failure analysis documented**: 3 categories — can fix (C-02/C-03 need HTTPS), not applicable (C-04/D-07/D-09 lab limitations), working as intended (C-01/D-02/D-08).

### Changed (2026-05-29 — Plan 0.7 Attack Testing: Batch B DNS Anomalies)

- **B-02 DNS TXT (plan0.7-dns-txt.sh)**: SID:1000026 (137 fires), ET:2000020 (137 fires). Both rules work — fire on `dns.rrtype:16` (TXT query type) regardless of response. Zeek `DNS_Duplicate_TXID` did not fire (expected — sequential `dig` calls get random TXIDs). Script updated to run from `linux01` (provisioning VM cannot reach DC DNS on UDP/53).
- **B-03 NXDOMAIN Burst (plan0.7-dns-nxdomain-burst.sh)**: SID:1000027 rev:2 fires (1 alert after 20+ NXDOMAIN responses from same source within 60s). Original rule (rev:1) used `-> any 53` which never matched responses. Fixed to `-> any any`. Zeek `DNS_NXDOMAIN_Burst` not yet verified. Script updated to run from `linux01`, queries `nonexistent-NNN.cadre.local` (not `.badtld`).
- **B-04 Suspicious TLD (plan0.7-dns-suspicious-tld.sh)**: In progress — queries to `.tk`, `.ml`, `.ga`, `.cf`, `.gq` TLDs. DC01 does not resolve these (no internet), but query packets are on the wire for Suricata to match `dns.rrname` regex. ET:2000021 regex requires TLD between dots (`test.tk.domain.com`), not at end — may not fire for `test-domain.tk`. SID:1000028 uses `\.(tk|ml|ga|cf|gq)$` and should fire.
- **B-05 DNS IP Literal (plan0.7-dns-ip-literal.sh)**: Pending — 4 PTR queries for IP addresses. SID:1000029 matches `dns.rrname` with regex for dotted-quad format.

### Fixed (2026-05-28 — Plan 0.7 Phase A Bugfixes + Zeek Deployment Recovery)

- **`cadre-conn-beacon.zeek` — missing closing brace fixed**: Event handler body `{` at line 41 was never closed. Introduced during `else if` → independent checks rewrite. Caused "syntax error, at end of file" when loading multiple CADRE scripts together. Zeek couldn't start at all — error manifested as "syntax error, at end of file" on whichever script was loaded after conn-beacon.
- **`cadre-conn-beacon.zeek` — `else if` logic fixed**: Changed to two independent `if` blocks so byte threshold and duration threshold are checked independently. Both fire their own `NOTICE()` with separate `$identifier` values (avoids suppress collision).
- **`cadre-quic-c2.zeek` — missing closing brace fixed**: Same event handler body issue as conn-beacon. Also the byte threshold detection (>10 MB) was never implemented despite being in the spec — only duration was checked. Both bugs fixed together.
- **`cadre-tls-fingerprint.zeek` — cipher list replaced**: Old list had 4 harmless ciphers (RSA key exchange, renegotiation info — all normal in production). New list has 13 genuinely suspicious ciphers: anonymous DH suites, export-grade, RC4, CCM_8 (IoT/malware), NULL (SSLv2 fallback).
- **`cadre-tcp-profile.zeek` — UTF-8 em-dash removed**: Replaced `—` (U+2014) with ASCII `-` in comments to avoid potential Zeek parser issues.
- **`local.zeek` — accidentally wiped and recovered**: During debugging, a `grep -v | tee` pipeline truncated `local.zeek` to 0 bytes (both the main file and backup). Reconstructed from session context and restored. Root cause: PowerShell piping through SSH+sudo can silently corrupt file output.
- **Zeek deployment approach clarified**: `zeekctl deploy` (check+install+start) was never the correct approach — the original Ansible deploy used `zeekctl deploy` with `failed_when: false`, then systemd used `zeekctl start`. The `controllee.zeek` error is a pre-existing Zeek 8.0.8 issue in the control framework loading order — not related to CADRE scripts. Correct deployment: `zeekctl start` (bypasses check phase).
- **Phase A-E improvement plan documented** in `plan0.7-defense-deepening.md` — covers Suricata JA3/JA4 rules (Phase B), supply-chain HTTP detection (Phase C), script improvements (Phase D), and integration/verification (Phase E). Each phase scoped to what's achievable on our current Zeek 8.0.8 + Suricata 8.0.4 setup.

### Changed (2026-05-28 — RITA Usage Guide + Plan 0.7 Internal Doc Updated)

- **`docs/internal/rita-usage-guide.md`** created — standalone usage guide for RITA (start Docker, import, analyze, HTML report, stop). Ready for public release after testing.
- **`docs/internal/zeek-packet-drop-guide.md`** created — how to check `capture_loss.log`, interpret drop rates, apply mitigations. Documents gap: if drops persist, cluster mode is next step.
- **`docs/internal/zeek-file-extraction-guide.md`** created — session-only file extraction workflow (enable → run → archive → disable). Covers selective extraction, storage estimates.
- **`plan0.7-defense-deepening.md`** fully updated — Phase 0 deployed state, Phase A-E plan, bugfix history, Zeek/Suricata API quirks documented, Key Design Decisions expanded with 7 new entries covering all discovered limitations.

### Added (2026-05-28 — Plan 0.7 Phase B: Suricata Rule Expansion)

- **Suricata 8.0.4 upgraded** from 2 CADRE rules to 34 curated rules total (2 AD + 9 Phase B + 13 hand-picked ET lab + 10 supply-chain). Full ET ruleset (50K+) removed as overkill for lab VM — resource concern. Config at `suricata.yaml` rewritten with proper port-groups, address-groups, app-layer protocols, and JA3/JA4 fingerprinting enabled.
- **JA3/JA4 fingerprinting enabled** — `app-layer.protocols.tls.ja3-fingerprints: yes` and `ja4-fingerprints: yes`. Compensates for Zeek 8.0.8's `ssl_client_hello` API mismatch that prevented JA3 computation in our custom scripts.
- **Curated ET rules** (`cadre-et-lab.rules`) — 13 hand-picked rules covering Kerberos attacks, SMB lateral movement, DNS anomalies, TLS anomalies, HTTP exploits. Replaces bulk ET ruleset (50K+ rules) to save lab VM resources.
- **9 CADRE Phase B rules** (`cadre-phaseb.rules`):
  - TLS anomalies: TLS 1.0 downgrade (SID:1000010), cert chain length >5 (SID:1000014)
  - Kerberos weak crypto: RC4 ticket (SID:1000015), DES ticket (SID:1000016)
  - DNS anomalies: high-entropy DGA query (SID:1000025), TXT record query (SID:1000026), NXDOMAIN burst (SID:1000027), suspicious TLD (SID:1000028), IP literal query (SID:1000029)
- **QUIC fingerprinting rules deferred** — `quic.version` negation syntax and `quic.cyu.hash` without content match both fail in Suricata 8.0.4. Will revisit after lab attacks reveal actual QUIC signatures.
- **Port-group variables added** to suricata.yaml: `HTTP_PORTS`, `SMTP_PORTS`, `ORACLE_PORTS`, `SHELLCODE_PORTS`, `SSH_PORTS`. Required by curated rules.

### Added (2026-05-28 — Plan 0.7 Phase C: Supply-Chain Network Detection)

- **10 new Suricata supply-chain rules** (`cadre-supplychain.rules`, SID:1000030-1000049) deployed to monitor VM. Detects 5 of 9 Plan 0.8 NPM-Threat-Emulation network-visible scenarios:
  - Scenario 1 (webhook POST): SID:1000030 (POST to external), SID:1000031 (webhook content-type)
  - Scenario 2 (TruffleHog): SID:1000035 (github.com/trufflesecurity), SID:1000036 (binary download)
  - Scenario 5 (/tmp stage1→stage2): SID:1000040 (/tmp path in URI), SID:1000041 (executable content-type)
  - Scenario 6 (npm publish worm): SID:1000045 (POST to registry.npmjs.org), SID:1000046 (auth header)
  - Scenario 7 (cloud metadata): SID:1000048 (HTTP to 169.254.169.254), SID:1000049 (DNS query)
- **New Zeek script** (`cadre-supplychain-http.zeek`) — module `CADRE_SupplyChainHTTP`, 3 Notice types:
  - `SupplyChainHttpPost` — HTTP POST to external host from internal subnet (webhook exfil)
  - `SupplyChainCloudMetadata` — HTTP POST to cloud metadata endpoints (169.254.169.254)
  - `SupplyChainRegistryAbuse` — POST to npm registry from unexpected source (publish worm)
- **Both playbooks updated**: deploy (`13-net-monitor.yml`) adds deployment tasks + suricata.yaml config; verifyOnly (`13-net-monitor-verifyOnly.yml`) adds 5 verification checks for supply-chain rules + script.
- **Total Suricata rules now: 34** (2 AD + 9 Phase B + 13 ET lab + 10 supply-chain).

### Changed (2026-05-28 — Plan 0.7 Phase D: Script Improvements + File Extraction)

- **cadre-tcp-profile.zeek fixed** — Cross-subnet detection scoped to 192.168.77.x ↔ other internal subnets (10.x, 172.16.x). Old version only compared IPs within 192.168.77.0/24 (always empty, never fired). Notice type renamed from `TCP_Profile_Alert` to `Cross_Subnet_Connection`.
- **File extraction session-only** — Created `cadre-extract-toggle.sh` script deployed to monitor VM at `/usr/local/bin/cadre-extract-toggle.sh`. Enables/disables `@load policy/frameworks/files/extract-all-files.zeek` in local.zeek and restarts Zeek. Currently DISABLED.
- **RITA analysis script** — Created `cadre-rita-analyze.sh` deployed to `/usr/local/bin/cadre-rita-analyze.sh`. One-command RITA workflow: unmask Docker → import Zeek logs → analyze → generate HTML report → stop Docker → re-mask. Usage: `sudo cadre-rita-analyze.sh [database] [logs_path]`
- **Packet-drop investigation guide** — `docs/internal/zeek-packet-drop-guide.md` reviewed, complete. Covers 4 check methods, severity table, 4 mitigation options, cluster mode reference.

### Fixed (2026-05-29 — ES ILM: Fleet Indices Not Deleting, Disk Would Overflow)

- **Root cause discovered**: Fleet-managed indices (Zeek/Suricata/Windows Security/Sysmon/Auditd/etc.) use Elastic's default `logs@lifecycle` ILM policy which had **no delete phase** — indices grew forever regardless of age. The `@custom` component templates (which apply `cadre-3d-retain` with a 7d delete) existed as a fallback but `logs@lifecycle` overrode them.
- **Evidence**: 11-day-old indices (`2026.05.18`) still in hot phase, consuming ~20 GB. 15 data streams were stuck past retention, including `logs-system.security` (18 GB), `logs-windows.sysmon_operational` (1.7 GB), and `logs-zeek.*` + `logs-suricata.eve` (~400 MB combined).
- **Fix applied live on elk VM**: Updated `logs@lifecycle` to add a delete phase at `0ms` (immediately after rollover), shortened hot rollover from 30d to 7d. Force-rolled 15 heavy data streams to trigger cleanup. Old indices will be deleted in the next ILM cycle.
- **Playbooks updated**: `12-elk-fleet.yml` now creates `logs@lifecycle` policy directly (hot: 7d/50GB → delete: 0ms) alongside `cadre-3d-retain` (hot: 1d/10GB → delete: 3d). `12-elk-fleet-verifyOnly.yml` checks both policies exist.
- **ELK VM disk**: 61 GB total, 40 GB used (68%) — will drop as ILM cleans up old indices.

### Changed (2026-05-29 — Plan 0.7 Phase E: Integration & Verification)

- **Phase E item 1 — Zeek/Suricata telemetry verified**: All 6 data streams confirmed shipping to Elastic (`zeek.connection`, `zeek.http`, `zeek.dns`, `zeek.ssl`, `zeek.kerberos`, `suricata.eve`). Data was temporarily delayed after monitor VM OS upgrade — Fleet integrations needed to re-sync. Resolved naturally after the agent re-checked in.
- **Phase E — Zeek notice.log added**: Created `zeek-cadre-notice-1` filestream integration on CADRE-Monitor policy, ingesting `/opt/zeek/logs/current/notice.log` as `zeek.notice` dataset. 14 documents indexed with CADRE script alerts. Previously existing `logs-zeek.notice` index template deleted to resolve force-flag conflict.
- **Phase E — linux01 agent upgraded**: Elastic APT repo added to linux01 (GPG key + sources.list), elastic-agent upgraded from 9.4.1 to 9.4.2 via `apt-get install`. Config file preserved (force-confold). Agent confirmed running at 9.4.2.
- **Phase E — linux01 NAT networking fixed**: NIC interface swap corrected — `eth0` (MAC `...e6`, vmnet2/lab) now has static `192.168.77.40/24`, `eth1` (MAC `...dc`, vmnet8/NAT) now gets DHCP from VMware NAT at `192.168.90.x`. Root cause: Kernel enumerated NICs in opposite order from VMX configuration — Vagrant VMware provider's netplan generated the wrong mapping. Netplan files swapped to match actual hardware ordering.
- **Both playbooks updated**: `12-elk-fleet.yml` adds zeek.notice filestream integration; `12-elk-fleet-verifyOnly.yml` verifies it exists.

- **Plan 0.7 scoped to public-safe content** — Zeek built-in detection scripts, Suricata AD rules, RITA installation, ShowMeThePackets tools (GPL-3.0, dhoelzer/ShowMeThePackets). Course-specific PCAP/log imports kept local and out of repo.
- **Plan 0.9 — Malware RE Lab** added as Post-Foundation Upgrade: REMnux OVA + Flare VM (no Vagrant), Ghidra MCP AI-assisted RE, quick-scan pipeline, sample DB (theZoo/Flare-On/MalwareBazaar). Spec at `plan00-upgrades/plan0.9-malware-re-lab.md`. Full detail at `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\MalwareRev\README.md`. Deferred to Plan 7 (MCP integration) for execution.
- **File naming normalized** — `plan07-` → `plan0.7-`, `plan08-` → `plan0.8-`, `plan09-` → `plan0.9-` for consistency. All references updated across CHANGELOG, roadmap, AGENTS.md.
- **`00-plan.md` prerequisites updated** — old "6 E2E attack scripts" prerequisite replaced with Phase 0 per-attack verification workflow.
- **`01-state.md` updated** — date, stale E2E reference replaced with Phase 0 reference.
- **`roadmap.md` updated** — Plan 0.9 added to phase table + decisions log; PCAP note removed.
- **`AGENTS.md` execution order** updated to `0.7 → 0.8 → 0.9 → core catalog`.
- **C2Stack repo finalized** — Vagrantfile rewritten to 2-VM architecture (Kali C2 + Redirector, dual NICs vmnet2+vmnet3), stale redStack files removed, setup scripts written, README + deployment guide completed. Separate sibling repo (Plan 10/P3, deferred).

### Added (2026-05-26 — Session Wo: Plan 1 Phase0 Restructured — 0.7 + 0.8 Lead, Core Telemetry Follows)
- **Phase 0 README.md restructured** to new execution order: Plan 0.7 (monitor VM defense deepening) → Plan 0.8 (npm supply-chain) → core Telemetry Catalog (59 CADRE attacks).
- **Plan 0.7 — Defense Deepening** added to Phase 0: Zeek built-in detection scripts (krb/ntlm/intel/known-hosts/known-services), Suricata AD-specific rules (Kerberoast burst, DCSync, SMB coercion, NTLM relay), ShowMeThePackets tools (GPL-3.0, dhoelzer/ShowMeThePackets), RITA C2/beacon detection. Full spec at `plan00-upgrades/plan0.7-defense-deepening.md`.
- **Plan 0.8 — npm Supply-Chain** added to Phase 0: MHaggis/NPM-Threat-Emulation integration (9 scenarios × 2 platforms), 10 new detection rules (`npm-001..010`), mock webhook sink, Campaign E + 9 walkthroughs. Full spec at `plan00-upgrades/plan0.8-supplychain.md`.
- **Verification table** extended: "Emerging Threats — Plan 0.8" section added with 10 npm rule rows.
- **Prerequisites** split into 3 groups: global, Plan 0.7 (monitor VM), Plan 0.8 (supply chain).
- **Execution order** reworked: 0.7 before any attack runs (enriched network telemetry), 0.8 second (fast setup), core catalog third (59 attacks campaign by campaign).
- **01-state.md** updated: Phase P0 points to `phase0/` directory; old inline checklist replaced.
- **Docs now ready for Phase 0 execution**: 0.7 monitor config → 0.8 npm scenarios → core catalog campaign by campaign → verification table filled → Sigma YAML catalog writing.

### Changed (2026-05-26 — Session Wr: Public-Doc Count Standardization + Clean Git Re-Init)
- **Doc accuracy pass (public):** standardized walkthrough/attack/Sigma counts to **60** (was inconsistently "62") across README, DOCS, goals, forensic-workflow, attack-matrix/README; reconciled **ESC coverage to 12/15** (ESC5/12/15 out of scope) across cert-coverage, adcs-configuration-guide, goals (was variously 13/15, 14/15); fixed residual `T001`/RC4 example commands → `T002`; phase-05 deploy summary "RC4/AES" → "AES" (matches the playbook fix). `60` is a placeholder pending the vector-by-vector review.
- **Repository re-initialized clean.** Prior `.git` was deleted (gitnexus/graphify post-commit hooks were breaking the opencode CLI). Re-`git init` + single clean commit, force-pushed to `github.com/Ganron007/CADRE` (`93ef410…a4230a1`, forced). **Critical:** the `.gitignore` had been deleted with `.git` — recreated it *first* (portable, not reliant on global ignore) so a naive `git add -A` couldn't leak `docs/internal/` + `AGENTS.md` + `CLAUDE.md` to the public repo or bloat it with `.gitnexus/`/`graphify-out/`/`.vagrant` (9 GB)/installers. Final commit: 258 files, largest 500 KB, zero leaks.
- **No git hooks installed** (by design) — the gitnexus/graphify commit-hook breakage can't recur. Run `npx gitnexus analyze` / `graphify update .` **manually**; both write only to gitignored dirs. `AGENTS.md` + `CLAUDE.md` now gitignored (CLAUDE.md is gitnexus-generated).

### Removed (2026-05-26 — Session Wq: Killed Two Non-Viable Detections (cadre-001 RC4, L10 xp_cmdshell-Linux) + Reframed WT#044/cadre-007)
- **cadre-001 (RC4 Kerberoast) rule deleted** from `12-elk-fleet.yml` + `12-elk-fleet-verifyOnly.yml` (rid-loop + check_query). It was still live despite plan docs claiming removal — RC4 is non-viable on Server 2025 (KDC `KDC_ERR_ETYPE_NOSUPP`). No attack, no rule. WT#001 slot reserved for a future initial-access technique.
- **cadre-l10 (MSSQL xp_cmdshell on Linux) rule deleted** — `xp_cmdshell` is **impossible** on SQL Server Linux (`xpstar.dll` absent), so the "blocked-attempt" detector was detecting a non-event (the prior "1 alert confirmed" was contrived). Removed from `12-elk-fleet.yml`, `12-elk-fleet-verifyOnly.yml`, `index-reference.yml`, `07-detection-rules/README.md`, `sql-integration-guide.md`, `dfir-logging-reference.md`, and the E2E doc. **L-number gap kept** (no renumber) — reserved for a future real Linux technique (e.g. SUID/copy-based priv-esc).
- **Rule counts corrected**: Windows 8→7, Linux 15→14, verifyOnly "23 rules"→"21".
- **cadre-007 reframed** (kept — it's a *real* detection): "Zeek Kerberoasting (Failed TGS)" → "Kerberoast Attempt (Zeek)". It's the genuine network signature of a working Kerberoast (WT#002/033) — the KDC rejecting the encryption downgrade — not a contrived RC4 artifact. RC4/"failed" framing dropped.
- **WT#044 reframed** as a **reconnaissance sub-technique of the MSSQL chain (WT#040–043)**, not a standalone vector (it's recon — no OS exec on SQL Linux; hands off to WT#045/046).
- **Doc punch-list completed**: all ~15 cosmetic RC4/WT#001 text mentions cleaned across public (README/goals/architecture/cert-coverage/deployment/forensic-workflow/dfir-logging/attack-tools/03-attackpath/cert-matrix/missing-techniques/prerequisites/04-automation) + internal (core-plan walkthrough table, AGENTS, schema.yml, plan01 catalog T001→none, e2e 001 section retired). One canonical "numbering starts at WT#002" line kept in `01-walkthroughs/README.md`.
- **FUNCTIONAL FIX — playbook was configuring the dead attack**: `05-ad-attack-surface.yml` (+ verifyOnly) forced **RC4-only** (`msDS-SupportedEncryptionTypes=4`) on `chief_command` + `svc_ldap`, tagged `[WT#1]`. On Server 2025 the KDC blocks RC4, so RC4-*only* accounts can't obtain Kerberos tickets at all — and `chief_command` is the DA used by DCSync/Golden Ticket/campaign chains, so this was likely silently breaking downstream attacks. Changed to **AES128+AES256 (`24`)** + retagged `[WT#2]`; they remain real AES Kerberoast targets (WT#002). config.json/roles/host_vars confirmed clean (playbook was the sole source). Design-folder build-notes left historical.

### Fixed (2026-05-26 — Session Wo: 002 AS-REP Roast Tested, 006 Relay Attempted, Scheduler Bug Identified)

- **002 AS-REP Roast confirmed working**: Attack launched from provisioning VM via GetNPUsers.py — hash returned for intern_blue. 4768 event with PreAuthType:0 confirmed in ES (`query: "event.code:4768 AND winlog.event_data.PreAuthType:0"`). Rule fires no alerts — shares scheduler bug with 001/006 (no task manager entry, `last_run=None`).
- **006 NTLM relay attempted**: Full relay setup tested. Provisioning VM blocked by port 445 (Samba). Switched to linux01 (domain-joined) — ntlmrelayx started successfully (`sudo -E env PYTHONPATH=...`). Coercer installed and run against dc01 — all MS-RPRN/DFSNM/EVEN methods returned `NO_AUTH_RECEIVED`. No relayed auth captured.
- **LD_PRELOAD rootkit cleaned from linux01**: `/etc/ld.so.preload` referencing `/tmp/evil.so` (artifact from prior attack) removed — was causing `ERROR: ld.so: object '/tmp/evil.so' cannot be preloaded` on every command.
- **Scheduler bug confirmed for 3 rules**: 001, 002, and 006 all have `execution_summaries=[]`, `last_run=None`. Rules exist in Kibana but never execute. Other rules (L09, L10) run fine. Root cause unknown.

### Fixed (2026-05-25 — Session Vn: L09 Fixed, L10 Restored as Blocked-Attempt Detector, WT#044 as Lateral Recon)

- **L09 MSSQL failed login rule fixed**: `.sqlaudit` audit files are UTF-16 LE binary — unparseable by filestream integration on Linux. Re-targeted from `logs-mssql.audit.linux-*` to `logs-microsoft_sqlserver.log-*` (errorlog). Changed from threshold (FAILED_LOGIN_GROUP) to query (`message:"Login failed"`). KQL wildcard `*Login failed*` doesn't work on analyzed `message` field — fixed to quoted phrase `"Login failed"`. L09 now has 10 alerts (confirmed).
- **L10 restored as "Blocked Attempt" detector**: `xp_cmdshell` cannot be enabled on SQL Server Linux (xpstar.dll absent), but probing for it via linked server is a valid lateral-movement reconnaissance signal. Rule detects `message:"blocked access" AND message:"xp_cmdshell"` in `logs-microsoft_sqlserver.log-*` (errorlog). L10 has 1 alert (confirmed).
- **WT#044 rewritten as lateral recon**: Changed from "xp_cmdshell via linked server" to "lateral reconnaissance via SELECT queries" — linked server queries enumerate linux01 databases and Kerberos-authenticated logins, then pivot to WT#045/046 for credential abuse. No xp_cmdshell examples in walkthrough. L10 signals the blocked probe.
- **attack-specifications.md:670 corrected**: Changed `xp_cmdshell via link → Linux command execution` to `SELECT queries → enumerate linux01 databases (xp_cmdshell unavailable on SQL Linux)`.
- **SQL integration guide §3.2 updated**: Added note about Linux audit binary format limitation — `.sqlaudit` files are UTF-16 LE binary, unparseable by filestream integration on Linux. Verify section updated to note errorlog-based detection for L09/L10.
- **001/006 still pending**: 30 RC4 TGS events (001) and 519 NTLM events (006) exist in matching indices. Rules extended to `now-24h` lookback — awaiting next rule cycle.

### Fixed (2026-05-25 — Session Vm: E2E Rule Fixes Verified + Attack Doc Updated + 004 Attack Launched)

- **6 seed detection rules fixed** — field path bugs identified via live ES data analysis:
  - **003-DCSync**: `AccessMask:*1400*` → `*0x100*` (hex vs decimal). 311 matching events confirmed.
  - **004-SuspiciousProc**: `winlog.event_data.CommandLine:` → `process.command_line:` (ECS field). 2 existing mimikatz events match.
  - **005-ADCS Tamper**: `event.code:(4899/4900/4902)` (Windows Update PUA events) → Sysmon-based `process.command_line:(*certutil* AND *setreg* AND *CA*)`. 53 matches confirmed.
  - **008-gMSA**: `ObjectType:msDS-ManagedPassword` → `ObjectServer:DS AND Properties:*msDS-ManagedPassword*` (ObjectType is always a GUID). 0 matches — audit SACL needed on DC.
  - **L12-Authorized Keys**: `home_dir_writes AND process.name:authorized_keys` (process is always bash/sudo) → `auditd.log.name:*authorized_keys*`. 190 PATH records match.
  - **L15-Domain User sudo**: Was querying `logs-system.auth-*` for `event.action:sudo` — sudo events are in `logs-auditd.log-*` with `auditd.log.record_type:USER_CMD`. 1081 matches confirmed.
- All 6 fixes applied to both `ansible/playbooks/12-elk-fleet.yml` (persistent) and live Kibana rules via `PUT /api/detection_engine/rules`.
- **`docs/internal/plan00-foundation/gaps/plan0-e2e-attack-scripts.md`** updated — 005 attack changed to `certutil -setreg`, L12/L15 `Check:` fields synced to new queries.
- **L02 audit rule fix**: `07-linux-config.yml:71` — path was `/usr/sbin/realmd` (daemon binary, doesn't exist), changed to `/usr/sbin/realm` (CLI tool). Applied to rules file on linux01; auditd immutable mode required reboot to activate. linux01 rebooted successfully.
- **All attacks re-run** for fresh events within the 6min rule lookback window: DCSync (44 events), certutil (1), realm (1), authorized_keys (1). Rules will fire on next 5min cycle.
- **L04 osquery fix**: `12-elk-fleet.yml:1299` — osquery query used `FROM suid_bin` (non-existent table), changed to `FROM suid_bins` (correct table name). Applied to live Fleet osquery_manager policy via `PUT /api/fleet/package_policies/92c6e47d-6ec0-46d3-a9bc-e37b69d1f3f5`.
- **008-gMSA SACL fix**: gMSA object had no SACL to audit `msDS-ManagedPassword` reads. Added SACL for Everyone + ReadProperty + Success via `Set-Acl` on dc01. Rule query changed from `Properties:*msDS-ManagedPassword*` to `Properties:*e48d0154*` (schemaIDGUID, not human-readable attr name). 3 fresh events confirmed. SACL task added to `02-ad-objects.yml` for persistence.
- **All 21 live rules verified** — queries and indices correct. Remaining gaps: L09/L10 (MSSQL audit), 006 (relay deferred).
- **004-mimikatz attack launched** via provisioning VM against dc01 — Sysmon process creation logged with `mimikatz.exe` in command line.
- **L09/L10** still blocked by lost MSSQL audit config on linux01. **L02/L03** have data (35/317 events) but need fresh triggering events.
- **Verify-only playbook mirrors updated** — `02-ad-objects-verifyOnly.yml` (gMSA SACL check via `Get-Acl -Audit`), `07-linux-config-verifyOnly.yml` (realm audit rule path + no realmd grep), `12-elk-fleet-verifyOnly.yml` (7+ rule query content checks via `jq`).
- **006 NTLM Relay fixed**: `winlog.event_data.WorkstationName` is never populated in ECS — replaced with `source.ip` alone in threshold fields. Added `AuthenticationPackageName:NTLM` filter. 517 NTLM events available for threshold matching.
- **007 Zeek Kerberoast redesigned**: Old query `zeek.kerberos.request_type:TGS AND zeek.kerberos.cipher:rc4-hmac` never matched (KDC responds with aes256). New query `zeek.kerberos.request_type:TGS AND zeek.kerberos.error.msg:KDC_ERR_ETYPE_NOSUPP` detects failed TGS (Kerberoast fingerprint). 12 matching events confirmed. Rule added to `12-elk-fleet.yml` playbook (was missing).
- **Attack scripts doc restored**: 001 and 007 re-added as active rules. Header updated — 001 works for RC4 TGS (30+ events), 007 catches `KDC_ERR_ETYPE_NOSUPP` from GetUserSPNs attacks.
- **Verify-only rule list updated**: includes 001 + 007 in existence check. Added query verification for 001 (`TicketEncryptionType:0x17`) and 007 (`KDC_ERR_ETYPE_NOSUPP`). Added 006 threshold field check.

### Fixed (2026-05-25 — E2E Attack Script Doc Synced to Fixed Rule Queries)
- **`docs/internal/plan00-foundation/gaps/plan0-e2e-attack-scripts.md`**: All 11 Linux rule `Check:` fields updated from stale `auditd.key:XXX` to `auditd.log.key:XXX`, `auditd.auid:` → `auditd.log.AUID:`, `auditd.exe:` → `process.executable:`. L12 `home_access` → `home_dir_writes AND process.name:authorized_keys`. L14 paths expanded to include `/dev/shm/*` and `/var/tmp/*`. L15 added `NOT user.name:vagrant` filter and note about potential `logs-system.syslog-*` routing. L09/L10 added MSSQL audit-reconfiguration caveat. Matches the fixed queries in `12-elk-fleet.yml`.

### Fixed (2026-05-25 — Session Vk: E2E Field Path Bug — Seed Rule Queries Mismatched Auditd Schema)
- **Bug found**: All 11 Linux seed rules used `auditd.key:XXX` as the query field path, but the Elastic auditd integration stores the key as `auditd.log.key:XXX`. Similarly, `auditd.auid:` should be `auditd.log.AUID:` and `auditd.exe:` should be `process.executable:`. This caused 0 alerts despite attacks generating the expected telemetry.
- **Fix applied**: Updated `ansible/playbooks/12-elk-fleet.yml` — changed all 11 Linux rule queries to use the correct field paths. Also updated the 11 existing rules live via Kibana API (`PUT /api/detection_engine/rules`).
- **Additional fixes**: L12 key corrected from `home_access` to `home_dir_writes`, L14 `auditd.exe` → `process.executable`, L07/L11 `auditd.auid` → `auditd.log.AUID`.
- **L15 sudo rule** identified as needing index change (`logs-system.auth-*` has no sudo events; sudo events land in `logs-system.syslog-*`).
- **MSSQL audit** (`cadre-l09`, `cadre-l10`) — audit config lost during SQL reinstall on linux01; needs reconfiguration via Ansible.
- **dc03 VMDK parent pointer fixed** — `disk-cl2.vmdk` had stale `parentFileNameHint` to missing `disk-cl1-000002.vmdk`. Edited descriptor at byte offset 762 to point to `disk-cl1.vmdk` instead.
- **Live index verification completed**: 12/15 expected index patterns confirmed against live Elastic cluster. 121M Windows Security Events, 13M Sysmon events, 527K auditd events, 282K Zeek conn logs, all confirmed.

### Added (2026-05-25 — Session Vk: Plan 1 Phase P1 — Catalog Foundation)
- **Plan 1 spec docs created** at `docs/internal/plan01-telemetry-catalog/00-plan.md` (full 418-line spec with schema, 62-entry inventory, 8-phase sequencing, ART integration, done criteria) and `01-state.md` (current-state tracker with per-entry checklist, index reference, rule map).
- **`attack-matrix/06-telemetry-catalog/schema.yml`** — full YAML schema defining catalog entry structure: required fields, type validation, regex patterns, enumeration for campaigns/difficulty, telemetry source definitions (Elastic, Zeek, Suricata, Arkime, Velociraptor, auditd, MSSQL, Podman, osquery), detection rule contracts, timing, and alternative paths.
- **`attack-matrix/06-telemetry-catalog/index-reference.yml`** — compact telemetry source manifest: 25 Elastic index patterns with EIDs/keys/actions per source, 10 Velociraptor pre-built hunts with artifact lists, 11 Zeek log files with Elastic index mapping, 21 seed detection rules with queries and MITRE mapping, 4 campaign definitions, and 10 VM short-name/IP/role entries.
- **2 reference catalog entries** written and validated: `T003-asrep-roasting.yml` (EID 4768, PreAuthType:0, cadre-002 rule trigger) and `T002-kerberoasting-aes.yml` (EID 4769, TicketEncryptionType:0x12, no detection rule — AES blends with legitimate traffic).
- **`tools/validate-catalog/validate.py`** — Python validator that checks all catalog YAML against schema.yml, cross-references walkthrough files, validates index/hunt/rule references against index-reference.yml. Passes 2/2 with 0 errors.
- **`AGENTS.md`** updated — session header directing to DOC-MAP.md/roadmap.md, Plan 1 docs in key directories, E2E tests pending note, expanded Plan 0 internal doc paths, dfir-logging-reference.md citation.
- **`DOC-MAP.md`** updated — plan01-telemetry-catalog/ section added to internal docs table, design decision-tree updated for Plan 1.

### Changed (2026-05-25 — Session Vj: Index Refresh + MCP Health Check)
- **GitNexus re-indexed** (`npx gitnexus analyze --force`) — rebuilt the full-text-search indexes (they had gone missing, which was degrading `query` to empty results) and re-indexed to current HEAD. 2,868 nodes / 3,130 edges / 31 flows.
- **Graphify incremental update** — absorbed 84 changed files (42 code via free AST + 42 docs via 3 semantic agents). Graph grew 4,824 → 4,940 nodes, 5,316 → 5,458 edges, 454 communities. `graph.json` / `GRAPH_REPORT.md` / `graph.html` regenerated; `.graphifyignore` kept `docs/internal/archive/` out.
- **MCP health check** — verified the GitNexus MCP server: `list_repos` ✅, `impact` ✅ (e.g. `cmd_install` upstream → `show_menu` + `main`, risk LOW), `context` ✅; `query` was degraded by the missing FTS indexes (now rebuilt). Note: the in-session MCP server caches the prior index until Claude Code restarts.
- Both generated graphs (`graphify-out/`, `.gitnexus/`) are gitignored; only `CLAUDE.md`'s auto-refreshed GitNexus section is committed here. The post-commit hook re-refreshes both indexes at the new commit.

### Changed (2026-05-25 17:12:48 +05:30 — Session Vi: Graphify Fork + Selective Ignore Configuration)
- **Graphify fork** — cloned `safishamsi/graphify` to `C:\STUDY\Github\graphify-fork`, commented out `_SENSITIVE_PATTERNS` (7 regex rules: `.env`, `.pem/.key`, `credential/secret/passwd/password/private_key`, `token`, `id_rsa`, `.netrc/.pgpass`, `aws_credentials`). Installed in editable mode (`pip install -e .`). `_SENSITIVE_DIRS` (`.ssh`, `.gnupg`, `.aws`, `.gcloud`, `secrets`, `credentials`) still enforced — real SSH keys and cloud credentials in standard directories are never indexed.
- **`.graphifyignore`** — created with single rule `docs/internal/archive/`. Graphify reads this instead of falling back to `.gitignore`, so it indexes everything in `docs/internal/` (plans, specs, reference) except the archive subfolder. Previously, graphify fell back to `.gitignore` and skipped ALL of `docs/internal/`.
- **GitNexus — no changes** — continues to read `.gitignore` as designed. Since `docs/internal/` is gitignored, GitNexus correctly skips all internal docs (code-only tool). No fork or modification needed.
- **Result**: `skipped_sensitive` count dropped from 10 to 0. Graphify now indexes 325 files (282K words) vs previous run. GitNexus index unchanged (2602 symbols, 2864 relationships).
- **Post-commit hook verified** — still runs both `graphify update` and `npx gitnexus analyze` in parallel background processes after every commit.
- **Documentation**: `docs/internal/reference/Agents_context_bestpractices.md` — added Part 10 covering tool ignore behavior (`.gitignore` vs `.graphifyignore` vs `.gitnexusignore`), fork rationale, `_SENSITIVE_DIRS` table, GitNexus hardcoded lists, `.gitnexus/.gitignore` self-protection explanation, and summary table of what each tool indexes/skips per path.

### Changed (2026-05-25 15:31:50 +05:30 — Session Vh: Opencode Config Split (Global vs Per-Repo))
- **Global opencode config** (`~/.config/opencode/opencode.json`): moved universal settings here — core plugins (`oc-crofai`, `oc-lsp`, `oc-mcp`, `oc-terminal`), LSP (TypeScript + JSON), GitNexus MCP (new `mcpServers` syntax via `npx`), and minimal agent instruction ("Do not hallucinate imports; use LSP to verify symbols exist before calling them.").
- **Local opencode config** (`.opencode/opencode.json`): simplified to repo-specific only — graphify plugin (`.opencode/plugins/graphify.js`). No `autoLoadContext`, no extra system instructions — the plugin already injects the graphify reminder before bash commands.
- **Rationale**: during long uncommitted sessions, the context window is the source of truth. MCP/graphify are snapshots of the last commit and can be stale. LSP reads from disk in real-time. Over-instructing the agent to "always query MCP first" could cause it to trust stale index data over what it just read.

### Added (2026-05-25 14:51:37 +05:30 — Session Vh: Graphify Knowledge Graph + Auto-Update Pipeline)
- **Graphify knowledge graph built** — 1,103 nodes, 1,724 edges, 146 communities across 245 files (code + docs + architecture). Outputs in `graphify-out/` (`graph.json`, `graph.html`, `graph.svg`, `GRAPH_REPORT.md`). 56.2x token reduction vs naive full-corpus queries.
- **Post-commit hook** (`.git/hooks/post-commit`) — auto-rebuilds both Graphify (`graphify update`, incremental, seconds) and GitNexus (`npx gitnexus analyze`, ~10-30s) in parallel background processes after every commit. Git commit returns immediately; logs at `~/.cache/graphify-rebuild.log` and `~/.cache/gitnexus-rebuild.log`.
- **Agent instruction injection** — `graphify claude install` + `graphify opencode install` added knowledge-graph policy blocks to `CLAUDE.md` and `AGENTS.md`. Graphify plugin (`.opencode/plugins/graphify.js`) injects reminder before bash tool calls. Claude PreToolUse hook warns against grepping when graph exists.
- **Global gitignore cleanup** — moved all AI/tooling ignores from local `.gitignore` to global `~/.gitignore_global`: `CLAUDE.md`, `AGENTS.md`, `.agents/`, `.claude/`, `.cursor/`, `.opencode/`, `.gitnexus/`, `graphify-out/`, `.github/copilot-instructions.md`. Local `.gitignore` now contains only project-specific ignores (Python, Vagrant, Ansible, IDE, internal docs).
- **Documentation**: `docs/internal/reference/Gitnexus_graphify_agentuse.md` — explains how agents use GitNexus (MCP) vs Graphify (CLI), update mechanisms, what gets committed vs stays local, and one-time setup per repo.
- **Changelog convention**: all entries now include time + timezone (e.g., `2026-05-25 14:51:37 +05:30`) alongside the date for precise session tracking.

### Changed (2026-05-24 — Session Vg: Internal-Doc Accuracy Pass (VM count + manual-install + kali))
- **`core-plan.md`**: Half A substrate line — "10 VMs via cadre.py" → "7 core (+ 3 optional extension VMs)"; "ESC1-15 templates (PSPKI-based)" → "ESC1-14 (**manual install** — PSPKI can't create v1 templates on Server 2025)"; flagged SQL + SCCM as manual. Tool-roster header "On kali VM" → "attacker host (user-managed Kali/Parrot — CADRE does not ship a kali VM)".
- **`process/deploy-test-recipe.md`**: "All 11 VMs up" (kali-era) → "7 core VMs (+ selected extensions)"; corrected the run location ("in your install dir — NOT the repo"); replaced the stale `ping kali (.41)` row with `ping linux01 (.40)`.
- **`plan00-foundation/state/status.md`** + **`spec/implementation-guide.md`** + **`_canonical/arch-flow.md`**: "10 VMs" → "7 core + 3 extension VMs gated by `CADRE_EXTENSIONS`". arch-flow test count 137 → 128.
- **`plan00-foundation/spec/attack-specifications.md` §4 (ADCS)**: added a REALITY banner — the PSPKI/ADSI template-creation approach doesn't work on Server 2025; templates are a manual install (adcs-configuration-guide.md), the snippets are retained as the attribute reference to apply by hand.
- **`monitoring-dfir-specifications.md`**: example evidence-bundle `"attacker": "kali (192.168.77.41)"` → "user-managed (Kali/Parrot on vmnet2)" (no CADRE-assigned kali IP).
- **`ad-structure-summary.md`**: ESC7 "NOT Applied (PSPKI silently fails — pending re-run)" → "Applied (manual — certutil `-setreg CA\Security` SDDL; see adcs-configuration-guide.md)"; template line "ESC1-4,9,13-15 … all 9 exist" → "ESC1-4, 9, 13-14 … ESC15 excluded (Server 2025), ESC12 N/A".
- **`docs/architecture.md` + `docs/goals.md`**: fixed an ESC enumeration contradiction — both listed "ESC1-11, **13-15**" (claiming ESC15 done) while ESC15 is *excluded* everywhere else. Now "ESC1-14 matrix · ESC15 excluded (Server 2025 rejects v1 schema) · ESC12 N/A".
- **Verified**: remaining PSPKI mentions are correct (they document *why* ADCS is manual). Acceptable "10 VMs" topology-total references (diagrams, RAM budget, out-of-scope) left as-is — they refer to the full 7+3 count, not the deploy mechanism. Final repo-wide sweep: no deploy-mechanism lies, kali-VM, "11 VMs", or ESC15-included claims remain outside `archive/`.

### Changed (2026-05-24 — Session Vg: Public-Doc Accuracy Pass (VM count + manual-install truth))
- **`docs/deployment.md`**: "Boots the 10 VMs" → "Boots the **7 core VMs** (+ any selected extension VMs gated behind `CADRE_EXTENSIONS`)". Matches the actual Vagrant behavior (7 core default; elk/monitor/vr on demand).
- **`docs/testing-recommendations.md`**: fixed a false troubleshooting entry — "ADCS templates missing | PSPKI role failed" implied automated template creation, but ADCS is a **manual install** (PSPKI can't create v1 templates on Server 2025). Now points to `adcs-configuration-guide.md`. MSSQL row points to `sql-integration-guide.md`. Refined "extension VMs deployed separately" → "created on demand via `cadre.py install -e`".
- **`docs/cert-coverage.md`**: "not in 10 VMs" → "not in the 7-core + 3-extension VM set" (avoids the bare 10-VM phrasing).
- **Verified clean across all public docs**: no remaining false "deploys 10 VMs", auto-install (SCCM/SQL/ADCS), PSPKI-creates-templates, "26-play", or kali-VM claims. The 7-core + 3-optional-extension framing is now consistent in README, DOCS, architecture, goals, extensions, deployment, testing-recommendations, cert-coverage. (`extensions.md` already correctly described on-demand extension-VM creation.)

### Changed (2026-05-24 — Session Vg: Cloud-Sync Executable Path + File Convention)
- **`ansible/playbooks/15-cloud-sync.yml`**: repointed the AADConnect agent `src` from `{{ playbook_dir }}/../docs/internal/archive/old_playbook/roles/cloud/files/...` to **`../files/executables/AADConnectProvisioningAgentSetup.exe`** (matches the VR playbook's `../files/...` pattern). This **fixes a latent bug** — the old `docs/...` path never resolved on the provisioning VM (cadre.py copies only `ansible/`, not `docs/`), so the agent silently no-op'd; it now lives under `ansible/files/` which *is* copied, so the agent actually stages on dc01 during the base run. Header comment documents the convention: **executables → `ansible/files/executables/`, scripts → `ansible/files/`**.
- The executable was already present at `ansible/files/executables/AADConnectProvisioningAgentSetup.exe` (alongside adksetup/dotnetfx35/SQL2025 installers) — no move needed.
- **Confirmed `15-cloud-sync` stays in the base install** (runs with the 7 core VMs, targets dc01) — it is NOT in `EXT_PHASE_IDS`, so the extension-skip fix does not exclude it. Guarded against hard-fail (`failed_when: false` on copy + `Test-Path` SKIP in install task). Scanned all active playbooks: no other stale archive/installer copy-paths — remaining `.exe` refs are system binaries or on-VM runtime paths.

### Fixed (2026-05-24 — Session Vg: Extension VMs Created on Demand (Option 1))
- **Extension VMs (elk/monitor/vr) are now created by the deploy flow** — closing the Session Vf gap. Implemented Option 1 (gated in the core Vagrantfile):
  - **`lab/providers/vmware/Vagrantfile`**: added `EXT_VMS` map (elk .50 12 GB/6 CPU, vr .51 2 GB/2 CPU, monitor .55 8 GB/4 CPU + promiscuous 2nd NIC) appended to `VMS` only for names in the `CADRE_EXTENSIONS` env var. `vagrant up` alone = 7 core; `CADRE_EXTENSIONS="net-monitor" vagrant up` = 7 core + monitor.
  - **`cadre.py`**: `run`/`run_stream`/`run_vagrant` accept an `env`; module-level `CORE_VM_NAMES` + `EXTRA_VMS`; `cmd_install` sets `CADRE_EXTENSIONS` from `-e` and runs `vagrant up` (not just vmrun power-on) whenever a selected VM is missing — so re-running with a new extension **creates that VM then configures it**. The menu "[8] Install Extensions" path (`run_extension_install`) now brings the VM up before running the playbook. Install summary shows the actual extension VM names.
  - **`docs/internal/tools/deploy-harness/test_plan0.py`**: "Core VM count is 7" (excludes gated `EXT_VMS`) + new checks for `CADRE_EXTENSIONS` gating and the 3 extension VMs. **128/128 pass.**
- **Fixed extension-phase double-run**: the main `PHASES` loop ran `12-elk-fleet`/`13-net-monitor`/`14-velociraptor` **unconditionally** (against possibly-nonexistent VMs) AND the `-e` loop ran them again. Added `EXT_PHASE_IDS`; the main loop now skips them — extensions run only via the `-e` selection loop. So a no-extension install = core only; selecting later runs once. (`15-cloud-sync` targets dc01/core, single-run, left as-is.)
- **Dead-reference cleanup**: removed unused `EXTENSIONS_DIR` constant (cadre.py); fixed the stale `cmd_install_extension` comment (playbooks are self-contained — templates inlined, VR artifacts under `ansible/files/`, no `extensions/` dir); updated `AGENTS.md` (`extensions/` row → `ansible/playbooks/{12,13,14}-*.yml`). The `extensions/` directory is empty + untracked (not in the repo).
- **Docs updated**: `deployment.md` (model section — extension VMs gated/auto-created), `AGENTS.md` (Vagrantfile description), `defense-summary.md` (EXT_VMS instead of per-extension Vagrantfiles), `deploy-reality.md` (gap marked RESOLVED), `roadmap.md` (decision: Option 1 chosen over Option 2).

### Changed (2026-05-24 — Session Vf: Extension-VM Creation Gap Documented)
- **Confirmed + documented a deploy gap** in `docs/internal/process/deploy-reality.md`: the 7-VM core is correct and cadre.py's extension *selection* logic works, but **nothing in the active code *creates* the elk/monitor/vr extension VMs** — the extension Vagrantfiles live only in `archive/old_playbook/extensions/`, the active `extensions/` dir is empty, and the core Vagrantfile references a now-missing `extensions/net-monitor/Vagrantfile`. Selecting an extension currently fails the health check (VM never created → unreachable → abort). VMs exist on the live lab because they were created manually before the cleanup. Two fix options captured (Option 1: gated VMs in core Vagrantfile, recommended; Option 2: restore per-extension Vagrantfiles). Decision pending — no code changed.

### Changed (2026-05-24 — Session Vf: Deploy Docs Corrected + SQL Integration Guide)
- **`docs/deployment.md` fixed** — added a "How CADRE deploys (the model)" section (Vagrant = reachable VMs only; Ansible = all config; the deploy/verify-gate/manual-verify split; the 3 manual installs ADCS/SQL/SCCM). **Replaced the stale "What runs in Stage A" list** — it described the retired 26-play monolith and falsely claimed SQL/ADCS/SCCM were automated; now shows the accurate 18-playbook structure with manual installs flagged.
- **`docs/sql-integration-guide.md`** (NEW): the missing SQL manual-install guide. Covers all three SQL hosts to satisfy `09-sql-wsus-verify.yml`: **mbr01** SQL Express (`SQLEXPRESS`, xp_cmdshell, linked servers → MBR02/LINUX01 + RPC OUT, IMPERSONATE on sa), **mbr02** SQL Developer (CLR/TRUSTWORTHY/strict-off, linked server → MBR01; install via SCCM guide), **linux01** SQL-on-Linux (mssql-server install, audit dir, `CADRE_AuditSpec`, Kerberos keytab). Previously only mbr02/SCCM SQL was documented — mbr01 Express and linux01 steps were missing. Linked from deployment.md.
- **`docs/internal/process/deploy-reality.md` extended** — added the playbook-architecture reference (the two sets: 18 deploy + 14 verifyOnly; the 3 deploy-set categories; **why `01-core-ad` is verify-only** — it verifies `00-domain-deploy`'s promotion, NOT Vagrant, which never touches AD; the SQL install matrix). So the deploy/verify split doesn't have to be re-derived.

### Changed (2026-05-24 — Session Ve: Deploy Story Right-Sized + Interactive-Shell Plan Retired)
- **Decision: WON'T DO the interactive-shell / variant / multi-provider system** (`docs/internal/archive/cadre-py-interactive-shell-plan.md`). GOAD-envy, not CADRE need — would add 7 variant JSONs, 2 extra provider Vagrantfiles, instance versioning, and a web dashboard (~5.5 days + permanent drift tax) for a one-provider, one-topology portfolio lab the maintainer deploys by hand. Plan stays archived as won't-do. Recorded in `roadmap.md` Decisions Log.
- **`docs/internal/process/deploy-reality.md`** (NEW): the honest deploy story — `vagrant up` + the numbered playbooks in `cadre.py` PHASES order, with ADCS/SQL/SCCM as **verify-only** (installed manually by GUI). cadre.py reframed as a thin helper (pre-flight + VM bring-up + ordered hand-off), not a one-button installer. Note flags that public `docs/deployment.md` should align to this flow when there's bandwidth.

### Added (2026-05-24 — Session Ve: Windows Attack Scripts (P0) + Linux Automation Review/Fixes)
- **12 Windows PowerShell attack scripts** created in `attack-matrix/04-automation/windows/attacks/` (was empty; ADOPT had 12). Windows-native execution, dot-sourcing the existing `cadre-env.ps1`/`common.ps1` libs: kerberoast, asrep, unconstrained/constrained delegation, RBCD, shadow-credentials, dcsync, golden-ticket, ACL-abuse (PowerView), SCCM (SharpSCCM), MSSQL (PowerUpSQL), ADCS-ESC (Certify, `-Esc` param). Closes the offense-automation asymmetry (Windows half had no scripted path).
- **`windows/lib/common.ps1`**: added missing `result` function (Linux `common.sh` had one; Windows didn't) — honest pass/fail instead of nothing.
- **PowerShell escaping bugs fixed** during authoring: WT040 `\"`→`` `" `` (PS escapes with backtick, not backslash); WT050 `/ca:` `\\`→`\` (single backslash).
- **Linux automation review** (`04-automation/linux/`, 59 scripts) — focus on the Linux-native WT#044/045/047/048:
  - **Verified correct against the live playbook**: NFS export `/exports/secure-share` and podman `--privileged --pid=host` both match `07-linux-config.yml` (so WT#048's `/proc/1/root/etc/shadow` host read is a real escape).
  - **Fixed hardcoded `result 0` masking failures** in 8 real-execution scripts (WT#041/042/043/044/045/047/048/049) → `result $?`. (9 other `result 0` scripts are intentional "run on Windows host" pointer-stubs, left as-is.)
  - **WT#047**: added `kinit`/`klist` prerequisite (krb5p mount fails with no ticket) + `nfs4` + real mount verification.
  - **WT#045**: replaced `/tmp`-only ticket check (SSSD uses KCM/KEYRING) with `.ldb` `cachedPassword` parsing + `klist`/`sssctl`.
- **WT#000 credential reconciled** to `analyst_dfir`/`An@lyst_DF1R!` (matches the automation libs), replacing the unverified `analyst_cloud` placeholder.
- Review captured at `docs/internal/plan00-foundation/gaps/attack-matrix-review.md`. **P0 now complete.**

### Added (2026-05-24 — Session Vd: attack-matrix Gap Fixes vs ADOPT — Front Door + Rule Catalog + Defender Views)
- **`attack-matrix/01-walkthroughs/00-initial-access.md`** (NEW, WT#000): the matrix front door — network recon, `/etc/hosts` + `/etc/krb5.conf` for all 3 realms, TGT verification, full service scan. Ported from ADOPT's `01-recon.md`, adapted to 192.168.77.0/24 + cadre/child/range domains, with a CADRE-style Telemetry Verification block (Zeek/Suricata/Elastic recon signals). Closes the "WTs start mid-attack with no setup doc" gap.
- **`attack-matrix/prerequisites.md`** (NEW): restored (ADOPT had one; CADRE had dropped it) — points to deployment, tools, 00-initial-access, naming-scheme; notes WT#001 dead + telemetry-exercise framing.
- **`attack-matrix/07-detection-rules/README.md`** (NEW): catalogs the 6 Windows + 15 Linux seed rules live in the lab, resolves walkthrough "Detection Rule:" references (e.g. `cadre-003-dcsync`), and lists the Plan-5 detection backlog. Removes dangling rule-ID references.
- **Defender view + Alternative paths** added to 5 flagship walkthroughs (WT#002 Kerberoast, WT#004 unconstrained delegation, WT#007 RBCD, WT#009 DCSync, WT#050 ESC1) — each now states the high-fidelity detection signal and a quieter/alternate attack route, leaning into the purple-team differentiator.
- **Empty scaffolding cleaned**: removed 14 empty deep subdirs under `07-detection-rules/`, `08-hunting/`, `09-cloud/` (they advertised capability not yet built). Top-level dirs retained with READMEs; populated by Plans 1/5/6/11.
- **Review captured** at `docs/internal/plan00-foundation/gaps/attack-matrix-review.md` (CADRE-vs-ADOPT comparison + prioritized plan). Remaining gap: **P0 Windows attack scripts** (`04-automation/windows/attacks/` empty vs ADOPT's 12) — deferred to its own session, pending execution-model decision.

### Changed (2026-05-24 — Session Vd: `docs/internal/` Reorganization into Per-Plan Folders)
- **Internal docs restructured** from 35 flat files into a per-plan layout (all gitignored — no public-repo impact). Phases 1–5 executed; tracked in `docs/internal/doc-reorg-plan.md`.
- **Phase 1 (dedup/archive)**: moved 6 stale/duplicate docs to `archive/` — `adcs-configuration-guide.md` + `sccm-integration-guide.md` (public copies at `docs/` are now canonical), `doc-inventory.md` (stale ADOPT-parity tracker), `plan0-current-updated-state.md` (superseded by plan_status), `cadre-py-interactive-shell-plan.md` (implemented), `CADRE.txt` (scratch).
- **Phase 2 (upgrades)**: `plan00-upgrades/` — `upgrade-suggestions.md`, `plan0.7-defense-deepening.md`, `plan0.8-supplychain.md`, `newwalkthrough-ideas.md`, `_out-of-tree/evasion-lab.md`.
- **Phase 3 (reference)**: `_canonical/` (naming-scheme, ad-structure-summary, arch-flow), `reference/` (2 ansible-research docs, course-comparison, lab-why), `process/` (deploy-test-recipe).
- **Phase 4 (foundation)**: `plan00-foundation/` with `spec/` (attack-specifications, monitoring-dfir-specifications, implementation-guide), `design/` (4 historical playbook-rewrite notes), `state/` (status, offense-summary, defense-summary), `gaps/` (cert-attack-gap, e2e-attack-scripts, known-gaps).
- **Phase 5 (index/link repair)**: rebuilt `DOC-MAP.md` to the new tree; updated `AGENTS.md` Key Files + `core-plan.md` Companion Documents/inline links. roadmap-vs-status split formalized (roadmap = cross-plan; `plan00-foundation/state/status.md` = Plan 0 detail). Root now holds only 4 live docs: core-plan, roadmap, DOC-MAP, doc-reorg-plan.

### Added (2026-05-24 — Session Vd: Plan 0.7 / 0.8 Roadmap Fold-In + Evasion-Lab Disposition)
- **`docs/internal/plan0_upgrade-suggestions.md`** (NEW): mapping + disposition doc. Defense upgrade → **Plan 0.7 (DFIR Deepening)**, npm threat emulation → **Plan 0.8 (Emerging Threats)**, OSEP/CETP evasion lab → **permanent out-of-tree sibling** (not a CADRE plan). Records monitor-VM 4 GB / elk-analysis-plane constraint, the "no course material named — additional PCAP only" rule, and sequencing behind Plan 0 E2E tests + clean-baseline snapshot.
- **`docs/internal/roadmap.md`**: added "Plan 0.7 / 0.8 — Post-Foundation Upgrades" section (phase table, gating) + "Evasion lab — out of tree (decided)" note. Two new Decisions Log entries (2026-05-24): defense→0.7 / npm→0.8 fold-in; evasion-lab kept out-of-tree (repo-risk + RAM budget).
- **`docs/internal/core-plan.md`**: inserted Plan 0.7 (Zeek protocol scripts + Suricata AD rules + RITA beacon detection on elk + additional PCAP into Arkime) and Plan 0.8 (Shai-Hulud npm emulation → 10 seed rules, clone-at-deploy w/ attribution, Emerging Threats not 9th cert) between Plan 0 and Plan 1 in the 11-Plan Roadmap.
- All three docs are gitignored (`docs/internal/`); PCAP corpus referenced generically as "additional PCAP" — no course/source material named or shipped.

### Changed (2026-05-24 — Session Vc: Architecture Diagram v4 Restructuring + AGENTS.md Sync)
- **`docs/img/cadre-architecture-official.svg`** restructured to v4: flipped column order to Red Team (280px) → Environment (940px) → DFIR (540px) reflecting attack → telemetry → analysis flow. "The Cycle" moved from bottom band into Environment panel (above single-source telemetry window). Telemetry flow arrow placed in Environment header row with long right-pointing arrow. Five Pillars header restored with full C-A-D-R-E acronym in correct order with even 200px spacing. Callout redesigned — "First" → "The Only Open-source Lab" with uniqueness-focused body lines: SCCM·SQL·ADCS instrumented, Attack → investigation chain, 5 unique telemetry sources, End-to-end kernel → SIEM, Forensic-ready by design. Header tagline updated to "LangGraph + MCP . DFIR ToolChain". "DFIR ANALYST TOOLCHAIN" → "DFIR TOOLCHAIN".
- **Card styling unified**: All 7 VM cards (dc01/dc02/dc03/provisioning/mbr01/mbr02/linux01) standardized to 200px width. Thick left border removed from linux01 and vr cards — all cards now identical styling. "First lab" callout repositioned left (710→680) to align with provisioning card boundary.
- **Spacing fixes**: Attack surface right column tightened (440→260). Investigation flow card moved down (552→560) to avoid overlap with DFIR toolchain card. Footer pulled up (1032→890) to eliminate dead space. viewBox adjusted from `0 0 1920 1080` → `0 -30 1920 930` for top breathing room and trimmed bottom.
- **4K PNG regenerated**: Viewport matched to SVG aspect ratio (3840×1860) eliminating letterboxing. File: 509 KB.
- **`AGENTS.md` updated**: Added diagram files to Key Files table, diagram layout + 5 telemetry sources to Conventions, PNG regeneration to Build & Test, v4 status to Plan 0 Status. Gitignored and untracked from repo (`git rm --cached`, `.gitignore` updated).

### Added (2026-05-24 — Session Vb: Public Docs Stale Content Cleanup)
- **SCCM + ADCS guides made public**: Removed `AUDIENCE: INTERNAL` comments and "deferred" language from `docs/sccm-integration-guide.md` (14 KB) and `docs/adcs-configuration-guide.md` (24 KB). Both now marked as tested and verified with live check counts (7/7 SCCM, 18/18 ADCS).
- **README.md updated**: Status section changed from "In Progress" to "Deployed". Added Work in Progress section at bottom with links to SCCM + ADCS guides and a caveat that other doc status markers may still be inaccurate. Added both guides to Documentation table.
- **60+ stale status markers fixed across 10 public docs**: SCCM "deferred" language removed from deployment.md, architecture.md, goals.md, cert-coverage.md, forensic-workflow.md (19 instances). "10 VMs" → "7 core VMs" in README, deployment.md, architecture.md, goals.md, DOCS.md, testing-recommendations.md, AGENTS.md (17 instances). Kali "Plan 1" → "user-managed Kali" in deployment.md, architecture.md, cert-coverage.md, forensic-workflow.md, testing-recommendations.md (10 instances). `roles/` path references updated to playbook references in dfir-logging-reference.md, testing-recommendations.md. RC4/Kerberoast exclusion notes added in architecture.md, cert-coverage.md. osquery "deferred" removed in architecture.md, extensions.md, dfir-logging-reference.md, testing-recommendations.md. Velociraptor MCP "deferred" removed in architecture.md.
- **goals.md**: Plan 0 status changed from "~99% complete" to "Deployed".
- **126/126 test harness pass**.

### Fixed (2026-05-24 — Session V: Attack Matrix Verification + Stale Status Cleanup)
- **47 stale BROKEN status labels corrected** across the attack matrix. All 14 ADCS ESC walkthroughs (WT#050-061) had stale "CertSvc Stopped" / "CA not running" — CA `cadre-CA` IS running and 18/18 verify checks pass. WT#029 (CertPotato DCOM) had stale "ADCS Web Enrollment missing" — IIS pool IS configured on mbr01, Web Enrollment IS active on dc01. WT#046 (Keytab Abuse) had stale "keytab may not be auto-generated" — keytab EXISTS at `/var/opt/mssql/secrets/mssql.keytab` per `09-sql-wsus-verify.yml`. WT#062 (ESC15) correctly stays BROKEN — Server 2025 PKI rejects v1 templates.
- **`03-attackpath/README.md`** — 19 stale status entries fixed (ADCS ESC1-11/13/14, WT#29, WT#46). 6 SCCM entries corrected from `DEFERRED -- SCCM not installed` → `CONFIGURED` (SCCM site CAD running on mbr02). ESC4/9/13/14 names restored (were corrupted to "ESC2" by replaceAll in Session U).
- **ESC automation script headers** (12 files) — stale `# BROKEN — CA not running` headers corrected to `# CONFIGURED`. Fixed `# #` regex duplication artifact.
- **`CAMPAIGNS.md`** — corrupted summary section cleaned (tool call artifacts + broken markdown table). Summary table restored to `60 attacks`. CRLF line ending issues resolved.
- **126/126 test harness pass**. Verified: 61 walkthrough files (WT#002-062, all non-empty, all valid structure), 59 automation scripts (all with valid shebangs), 3 diagram files (with Mermaid), 14 study guide files (all non-empty). `06-tools-manifest/` directory confirmed nonexistent (stale reference — actual dir at index 06 is `06-telemetry-catalog/`).

### Added (2026-05-23 — Session U: attack-matrix Populated — Walkthroughs + Automation + Diagrams + Study Guide + Campaigns)
- **`CAMPAIGNS.md`** fully rewritten — all 4 campaigns now have same depth as Campaign A (full phase-by-phase commands, BloodHound Cypher queries, alternative paths shown inline). Campaign A covers Kali zero-creds → forest compromise in 8 MITRE-aligned phases. Campaign B covers cadre.local ACL abuse (5 phases, 10 WT#). Campaign C covers range.local SCCM + delegation (4 phases, 12 WT#). Campaign D covers linux01 post-exploit (4 phases, 5 WT#). All 60 attacks referenced in campaigns. WT#001 deleted (RC4 Kerberoast). Stale "13 broken/6 deferred" audit table in `03-attackpath/README.md` replaced with current verified status.
- **14 study guide files** created at `attack-matrix/05-study-guide/` (68.5 KB): 9-tier learning path, 62×8 cert matrix, per-cert paths for CRTP/CRTE/CESP-ADCS/CAPE/OSCP+/WKL-OADOC/CARTP/CARTE, course comparison, 16-gap analysis, external resources.
- **3 diagram files** created at `attack-matrix/02-diagrams/`: Mermaid-based 5-stage attack flow with minimum path to DA, architecture reference with topology/VM specs/data flow, and index linking to full-color SVG.
- **59 Linux bash automation scripts** created at `attack-matrix/04-automation/linux/attacks/`. Each script sources `cadre-env.sh` + `common.sh`, uses CADRE-specific IPs/creds, follows consistent template (print_banner→start_attack→step→run_cmd→result). Covers: Kerberos/Recon (10), Delegation/ACL (11), Coercion/Relay/GPO (7), MSSQL/SCCM/Linux (16), ADCS ESC (13). Plus `common.sh` + `common.ps1` helper libraries with logging and command-runner functions. Skipped WT#001 (dead), WT#029, WT#046 (broken).
- **62 walkthrough files created**: Full set at `attack-matrix/01-walkthroughs/` (154 KB, 62 files). Each covers: metadata, prerequisites, step-by-step commands, post-exploitation chain, telemetry verification, status. Covers Kerberos (9), Delegation (5), ACL Abuse (6), Coercion (4), Relay (2), GPO (1), MSSQL (5), Linux (4), Modern (2), Recon/Other (4), SCCM (6), ADCS ESC (14). WT#001 marked **DEAD** (Server 2025 KDC blocks RC4 — points to WT#002). SCCM walkthroughs corrected from DEFERRED→CONFIGURED (SCCM site server live on mbr02, `RANGE\svc_sccm` Full Admin). README catalog updated with footnote.
- **Playbooks made self-contained**: ES and Kibana templates inlined from `../extensions/elk-fleet/templates/*.j2` into `12-elk-fleet.yml` via `ansible.builtin.copy` `content:`. Velociraptor artifact/hunt files moved from `extensions/velociraptor/files/` to `ansible/files/vr-{artifacts,hunts}/`. Updated `14-velociraptor.yml` `src:` paths accordingly. Zero `../extensions` references remain in any playbook.
- **E2E attack script doc fixed**: `plan0-e2e-attack-scripts.md` corrected — AS-REP target from `analyst_purple`→`intern_blue` (correct AS-REP roastable user), domain/DC from cadre→child, `-users-file`→`-usersfile`. DCSync user from `eng_agentic`→`chief_command` (requires DA). Suspicious proc trigger improved to direct `mimikatz.exe`. L01 changed from read→write (audit rule `-p wa` catches writes only). L03 added `sudo`. L07 removed `-it` (no TTY in Ansible). L08 changed to `/etc/cron.d/`. L11 added `mkdir -p /mnt`. L05 ADCS doc updated (certutil -setreg fires event 4898, not 4899/4900/4902).
- **E2E detection rules fixed**: 4 audit key mismatches in `12-elk-fleet.yml` — L03 (`sssd_cache`→`sssd_db OR sssd_secrets`), L08 (`persistence_cron`→`cron_dir OR cron_daily OR cron_hourly OR systemd_units`), L11 (`mount_syscall`→`nfs_mount`), L12 (`home_dir_writes`→`home_access`). Same fixes applied to `extensions/elk-fleet/playbook.yml`, `linux-seed.ndjson`, and `saved-searches/seed.ndjson`.
- **Verify-only playbook updates**: `12-elk-fleet-verifyOnly.yml` — added 2 config content verification tasks (ES config inline template, Kibana config inline template).
- **test_plan0.py updated**: Removed extension Vagrantfile checks (never existed). Changed extension tests from playbook checks to info-only (extensions archived). Removed MISP/redstack stub checks. 126/126 pass.
- **Dead code audit completed**: Full repo audit across ansible/, extensions/, tools/, tests/. 90+ files staged for deletion (41 roles, 3 old playbooks, 25 extension files, 19 autobuild files). 4 broken references identified in `cadre.py` (media check paths, stale help text). 2 empty test directories identified.

### Added (2026-05-23 — Session T: SCCM Fix + Playbook Renumbering + Config Sync)
- **SCCM admin access restored**: DCOM Remote Activation/WMI permission fix via Distributed COM Users group. `RANGE\svc_sccm` and `CADRE\chief_command` added as SCCM Full Administrators via SQL `RBAC_ExtendedPermissions` insert.
- **CRED-2 task sequence created**: Manually via SCCM Console — `10-sccm-verify.yml` now passes all 7 checks.
- **svc_sccm SCCM Full Administrator**: Deploy task added to `06-member-services.yml` (rc=0/2), verify tasks added to `06-member-services-verifyOnly.yml` and `10-sccm-verify.yml` (rc=0/1). Enables WT#37-40 (CMPivot, app deploy, site takeover).
- **Playbook renumbering**: `08-sql-sccm-wsus-verify.yml` split into `09-sql-wsus-verify.yml` (SQL + WSUS) and `10-sccm-verify.yml` (SCCM). All playbooks 09→15 renumbered: baseline→11, elk→12, net-monitor→13, velociraptor→14, cloud-sync→15. `cadre.py` PHASES + EXT_PLAYBOOKS updated. 9 playbook files renamed.
- **ESC13-Vulnerable-Target group**: Added to `02-ad-objects.yml` (deploy + verifyOnly) as Universal scope in OU=Command — fixes `08-adcs-verify.yml` WT#61 check.
- **config.json synced**: 9→10 groups (added ESC13-Vulnerable-Target), 11→12 users (added mssql-linux01), CA name `CADRE-CA`→`cadre-CA`, SID filtering `true`→`false`, Vulnerable-GPO target `OU=DFIR`→`OU=Command`, ESC15 removed, SCCM-Client-Push GPO removed, SCCM `false`→`true`.
- **GPP cpassword bait**: Groups.xml with cpassword (`SCCM_Rec0very!`) deployed to SYSVOL via Vulnerable-GPO. Deploy+verify tasks added to `02-ad-objects.yml`.
- **`docs/internal/course-comparison.md`**: Ported from ADOPT repo. Updated with SCCM status, ESC15 exclusion, ADOPT→CADRE rename, Server 2022→2025, ext.local→range.local.
- **`docs/internal/plan0-newwalkthrough-ideas.md`**: 11 new walkthrough ideas leveraging existing infra (password spraying, targeted AS-REP/Kerberoast, WMI/WinRM/PsExec/DCOM lateral movement, NTLM farming, Restricted Admin RDP, NTLM Relay+RBCD, GPP cpassword).
- **`docs/internal/plan0-evasion-lab-upgrade.md`**: OSEP/CETP extension plan — proposed `build01` (dev VM) + `target01` (evasion target) extension VMs.
- **`audit-attack-surface.ps1`**: ESC15 removed from template list, SID filtering check fixed, undefined `$mbr01RBCD` fixed. Added SCCM misconfig checks (CRED-1/2/3, ELEVATE-2, svc_sccm admin), WSUS check, and Linux section (SSSD, auditd, NFS, Podman — 8 checks).
- **`01-core-ad.yml`**: Task naming bug fixed — "SID filtering enabled"→"disabled" (both range.local and cadre.local trust checks).
- **137/137 static tests pass** (was 136/136).
- **Elk VM spec upgrade**: Vagrantfile updated to 6 vCPU (was 4). ES JVM heap configured to 6GB (was 4GB) via `/etc/elasticsearch/jvm.options`. Heap verify task added to `12-elk-fleet-verifyOnly.yml`. ILM retention tightened from 7d→3d in `cadre-3d-retain` policy.
- **Security log reverted to 1GB**: 4GB caused Fleet agent backpressure. Reverted `cadre-dfir-monitoring.ps1` and both `11-security-baseline.yml` / verifyOnly to check for ≥1GB. Applied live via Ansible across all 5 Windows VMs.
- **Playbooks + config synced**: `cadre-dfir-monitoring.ps1` back to 1GB, `01-core-ad.yml` SID filtering task name bug fixed, `audit-attack-surface.ps1` expanded with SCCM/Linux checks.

### Added (2026-05-21 — Session Q: Full Playbook Rewrite + Deploy — 0 Failures Across 8 Layers)
- **7 new modular playbooks** at `ansible/playbooks/` replacing old role-based system:
  - `01-core-ad.yml` — Verify domains, trusts, DNS (verify only, DNS tag-skippable)
  - `02-ad-objects.yml` — Deploy OUs, users, groups, gMSA, dMSA, memberships (rc=2 pattern)
  - `04-vulnerabilities.yml` — Registry, services, features (native modules + rc=2)
  - `05-ad-attack-surface.yml` — 26 ACEs, 5 SPNs, 3 AS-REP, delegation, RC4, AES-only (rc=2)
  - `06-member-services.yml` — IIS, shares, bait, SQL/SCCM/WSUS verify
  - `07-linux.yml` — SSSD, podman, NFS, auditd, MSSQL, realm check
  - `08-adcs-verify.yml` — CA, ESC6/7/8/10/11, 8 templates, template property checks
- **All tasks use `win_shell` with explicit exit codes**: rc=0 (skip/ok), rc=2 (applied+verified), rc=1 (fail)
- **ACE constructor fixed**: All 26 ACE tasks use typed .NET enums (`[ActiveDirectoryRights]::GenericAll`) avoiding ambiguous overload on Server 2025
- **SPN registration split per-DC**: No cross-domain ADWS connectivity issues
- **SQL verification uses `sqlcmd -E -C`**: Replaced fragile `Invoke-Sqlcmd` which crashes on Server 2025
- **SCCM WMI classes updated**: `SMS_SCI_Reserved` for NAA, `SMS_SCI_ClientComp` for client push, `SMS_PXECertificateInfo` for PXE (Server 2025 changed WMI schema)
- **WSUS check fixed**: Corrected registry path from `UpdateServices` (no space) to `Update Services` (with space)
- **VSC template check fixed**: Uses `Get-ADObject` instead of broken `Get-CATemplate`
- **ESC8 SSL check added**: Verifies `sslFlags:None` on /CertSrv IIS path
- **ESC11 documented**: Added Phase 1.5 to ADCS configuration guide
- **ESC15 removed**: Server 2025 CA no longer supports v1 schema templates. Documented as excluded.
- **Podman container fix**: Uses `podman container exists` + `podman start` instead of `podman ps` (which misses stopped containers)
- **All old playbooks/roles archived**: Moved to `docs/internal/archive/old_playbook/`
- **Full clean run**: All 8 layers deployed with 0 failures across all 6 VMs (202 tasks, 16 changes)

### Fixed (2026-05-21T02:00:00+05:30 / 2026-05-20T20:30:00Z — Session P: Audit v5 + Playbook ESC7 Fix + Linux Audit)
- **`ansible/roles/adcs/tasks/main.yml`**: ESC7 fix — replaced PSPKI `Set-CertificationAuthorityAcl` (silently fails on Server 2025) with `certutil -setreg CA\Security` using `RawSecurityDescriptor` binary manipulation. Reads current CA security descriptor from registry binary, adds ManageCA ACE for `lead_engineering`, writes back. Idempotent — skips if ACE already present.
- **`docs/internal/tools/audit-attack-surface.ps1`**: Three script bugs eliminated — (1) `auditpol /query` → `/get` (Server 2025 uses different subcommand), (2) `identityType -eq 2` → `-eq "NetworkService"` (Server 2025 returns string not int enum), (3) `Get-Acl "AD:\$path"` replaced with new `Get-ADAcl` helper using `Get-ADObject -Properties ntSecurityDescriptor` (no more "Cannot find path" errors, handles missing objects gracefully). ESC7 check uses `RawSecurityDescriptor` from registry binary (no PSPKI). AS-REP checks wrapped in try/catch for clean output. **Zero script bugs** — all 21 reported failures are real.
- **`docs/internal/tools/audit-linux.sh`**: Created — 15-check Linux audit for linux01 covering SSSD/realm join, debug_level, MSSQL install+keytab, NFS krb5p export, Podman containers, auditd rules. First-ever Linux-side audit coverage.
- **Audit v5 run** on all 6 domain-joined machines: dc01=75P/5F, dc02=22P/8F, dc03=30P/5F, mbr01=16P/0F, mbr02=23P/0F, linux01=12P/3F. **Total: 178P / 21F / 5W**.
- **`docs/internal/plan0-offense-audit-report.md`**: Updated to 21 failures (was 18) with linux01 section. Phase 3 ESC7 fix updated to certutil SDDL (not PSPKI). linux01 Phase 6 added (sssd debug_level, cadre-monitor container, auditd rules). Scope expanded to 6 machines.
- **`docs/internal/plan0-current-updated-state.md`**: updated to 21 failures with linux01. `cadre-monitor` status corrected to NOT running.
- **`docs/internal/plan0-cert-attack-gap.md`**: Rewritten with v5 audit data, 6-machine totals, Linux walkthrough table, 7-phase remediation.
- **`docs/internal/ad-structure-summary.md`**: 4 inaccuracies fixed — cadre.local ACE count 12→13, range.local 7→6, ESC7/Templates/ESC8 statuses from PENDING/Applied to current truth.

### Fixed (2026-05-20 — Session O2: Arkime ES Yellow → Green)
- **`extensions/net-monitor/playbook.yml`**: Added persistent cluster setting `index.number_of_replicas: 0` (Play 2) and Arkime-specific composable index template `cadre-arkime` with priority 200 and `number_of_replicas: 0` (Play 3). All 6 yellow indices resolved — cluster is green, 0 unassigned shards.
- **Monitor VM ES**: Applied `number_of_replicas: 0` live (existing indices + cluster setting). `cadre-arkime` template created. Resolves `search_phase_execution_exception` on Arkime dashboard.

### Fixed (2026-05-20 — Session O: Attack Surface Playbook Applied + VMs Rebooted)
- **`99-fix-attack-surface.yml`**: Re-ran across 2 reboot cycles. Fixed PowerShell parser error (`$current:` → `${current}`) in RC4 task. All 5 plays idempotent and passing.
- **Role files synced** to provisioning VM: `adcs/tasks/main.yml` + `vulns/tasks/main.yml` — fresh deploy path matches fix playbook.
- **`test_plan0.py`**: 101/101 still passing (no code changes).
- **Attack surface applied**: ESC1 (Client Auth EKU + EnrolleeSuppliesSubject), ESC9 (security ext removed), ESC10 (StrongCertificateBindingEnforcement=0 + CertificateMappingMethods=31 on all 3 DCs), RC4-HMAC on chief_command/svc_ldap, WDigest enabled + CredentialGuard disabled on mbr01/mbr02.

### Fixed (2026-05-20 — Session N: Attack Surface Audit + Fix Playbook)
- **`ansible/playbooks/99-fix-attack-surface.yml`**: New one-shot playbook fixing all 7 critical gaps between `attack-specifications.md` and Ansible role code. 4 plays: ESC1 template props, ESC10 registry (all DCs), RC4 value fix, WDigest/CredentialGuard scope.
- **`ansible/roles/adcs/tasks/main.yml`**: Fixed ESC1 template — EKU changed from `1.3.6.1.5.5.7.3.1` (Server Auth) to `1.3.6.1.5.5.7.3.2` (Client Auth), added `msPKI-Certificate-Name-Flag=1` (EnrolleeSuppliesSubject), changed `msPKI-Enrollment-Flag` from `0x2` (PEND) to `0`. Added unconditional fix outside guard for existing deployments. Fixed ESC10 — corrected registry path from Schannel to Kdc, added `CertificateMappingMethods=31`. Added ESC9 `szOID_NTDS_CA_SECURITY_EXT` removal. Removed conflicting KDC `StrongCertificateBindingEnforcement=1` (ESC10 value 0 wins globally).
- **`ansible/roles/vulns/tasks/main.yml`**: Fixed RC4 encryption value (`msDS-SupportedEncryptionTypes` 1→4) for `chief_command` and `svc_ldap`. Added ESC10 registry settings for all DCs. Removed `when: "'dc' in inventory_hostname"` from WDigest and CredentialGuard — now applies to member servers too.

### Changed (2026-05-20 — Session M: Manual PCAP + CADRE-Linux Policy Split + Osquery Active)
- **PCAP workflow**: Stopped continuous tcpdump/Arkime capture (was killing SSD). Replaced with on-demand manual workflow: `cadre-pcap-capture-manual.sh` → `/opt/pcap/manual/` + `cadre-arkime-import.sh` (offline `capture -r`). Disabled `cadre-pcap.service`, `cadre-pcap-cleanup.timer`, `arkimecapture.service`. Fixed `/opt/pcap/` dir ownership (was root → tcpdump, blocking `-z gzip` at rotation).
- **`extensions/net-monitor/playbook.yml`**: Replaced continuous capture/cleanup scripts + systemd units with manual scripts (`cadre-pcap-capture-manual.sh`, `cadre-arkime-import.sh`). Added `/opt/pcap/manual/` directory. Removed all cleanup timers/services.
- **`extensions/elk-fleet/playbook.yml`**: Created **CADRE-Linux** Fleet policy (separated from CADRE-All). Moved Linux integrations (auditd, mssql, filestreams, sysmon_linux, system) from CADRE-All → CADRE-Linux. Added **osquery_manager** integration with 2 packs (SUID 5-min + recent-login 30-min) — osquery now ACTIVE (was deferred). CADRE-All now targets 5 Windows VMs only. linux01 enrolls into CADRE-Linux. Added osquery ILM component template + index template.
- **`lab/data/config.json`**: Verified — 11/8/10 users correct. (Test was stale; not config.json.)
- **`docs/internal/plan0-current-updated-state.md`**: Updated — osquery now ACTIVE (not deferred), PCAP manual workflow, CADRE-Linux policy, 3 Fleet policies. Updated `plan0-current-updated-state.md` to reflect Session M reality.
- **`docs/` (18 files)**: Bulk doc sync — fixed "11 VMs" → "10 VMs", SCCM/osquery/MCP deferral language, RAM/CPU specs (elk 12GB, monitor 8GB/4c, mbr02 4c), `MSSQLSERVER` → `SQLEXPRESS`, Elastic agent `9.0.0` → `9.4.1`, removed `microsoft.ad.*` references, updated CHANGELOG historical notes. See `plan0-current-updated-state.md` for full per-file stale-ref audit.
- **`docs/internal/naming-scheme.md`**: Re-synced via `tools/regen-config/regen.py` to match current config.json derived state.
- **`docs/internal/tools/deploy-harness/test_plan0.py`**: Fixed stale user-count assertions (10→11, 7→8, 7→10) — was missing service accounts (`svc_ldap`, `svc_mssql`, `svc_sccm`, `svc_naa`). 101/101 pass.

### Changed (2026-05-20 — Session L: NAT/vmnet2 Architecture Cleanup)
- **`ansible/roles/vulns/tasks/main.yml`**: Removed NAT adapter DNS hardcoding (`8.8.8.8`/`1.1.1.1`). NAT adapter is now left untouched — auto-configured by VMware DHCP/DNS. vmnet2 adapter still gets DC DNS per GOAD pattern (adapter detection + dead gateway removal).
- **`ansible/playbooks/fix-dns.yml`**: Removed Linux `/etc/resolv.conf` brute-force hack (`nameserver 192.168.77.10`). Refactored Windows section to target **only** the vmnet2 adapter (matched by `192.168.77.*` IP), skipping NAT adapters entirely. No longer clobbers NAT DNS.
- **`lab/providers/vmware/Vagrantfile`**: Synced Windows static IP provisioner with working copy — removed `-DefaultGateway 192.168.77.1` and `Set-DnsClientServerAddress` from `New-NetIPAddress` block. vmnet2 gets static IP only; no gateway/DNS at provision time.
- **`docs/internal/arch-flow.md`**: Added explicit `vmnet2 vs NAT segregation` constraint table entry — NAT = internet-only (VMware auto-config), vmnet2 = our attack/management plane (static IP, DC DNS for domain VMs).

### Changed (2026-05-19 — Session K: Golden Playbook Completion + Cleanup)
- **`04-extras.yml`**: Re-run (0 failures) — IIS/W029, WSUS/W030, VSC/W049, SQL Express, MSSQL vulns, shares, cloud. Removed SCCM play + sccm role from header. Phase 4 header cleaned (no more Kali, SCCM references).
- **`extensions/elk-fleet/playbook.yml`**: Fixed 23 detection rule index patterns (`logs-windows.security-*` → `logs-system.security-*`, `logs-zeek-*` → `logs-zeek.kerberos-*`). Added gMSA extraction rule (`cadre-008-gmsa-extract`). Removed `osquery_manager` integration + ILM template (deferred). ILM policy: 10gb rollover, 7d retention.
- **`extensions/velociraptor/playbook.yml`**: Rebuilt server (v0.76.1) — 7 clients enrolled. Fixed Linux client (dir creation, config push — no stale guards). Fixed Windows client (New-Service, stale MSI product GUID cleanup). Added vr server self-enrollment client. Removed MCP Play 4 (tagged for Plan 7).
- **`lab/data/config.json`**: Fully regenerated from playbook role files via `tools/regen-config/regen.py`. All 27 users, 17 groups, 10 OUs, trusts, gMSA, shares aligned to deployed code.
- **`docs/internal/naming-scheme.md`**: Synced to match regenerated config.json. Fixed MSSQL instances → SQLEXPRESS, GPO targets, provisioning → 24.04, removed kali.
- **`docs/` (7 files)**: Fixed stale index patterns (`logs-windows.security-*` → `logs-system.security-*`, `logs-zeek-*` → `logs-zeek.*-*`) in dfir-logging-reference, deployment, architecture, forensic-workflow, testing-recommendations, extensions, walkthroughs README.
- **`docs/architecture.md + docs/deployment.md`**: Removed kali references; updated deploy steps; added SCCM/osquery deferral notes.
- **`attack-matrix/04-automation/*/lib/cadre-env.*`**: Kali exports commented out (kali returns in Plan 1).
- **`ansible/roles/sccm/tasks/main.yml`**: Orphaned role — marked deferred (needs Server 2025 SxS). No play imports it.
- **`ansible/roles/members/tasks/shares.yml`**: Removed kali reference from bait file comment.
- **`extensions/elk-fleet/README.md`**: Updated policy description with osquery deferral.
- **ES heap**: Reduced 6GB → 4GB on elk VM.
- **`docs/internal/arch-flow.md`**: Created — codebase architecture flow, source of truth hierarchy, file purpose map, data flow layers.
- **`docs/architecture.md`**: Updated for Plan 0 — 10 VMs, elk 12GB, provisioning 24.04, MSSQL index pattern fix, SCCM/osquery/MCP deferral notes, attack VM → Plan 1.
- **`tools/deploy-harness/test_config_sync.py`**: Created — drift test ensuring config.json matches playbook roles (0 drift on first run).
- **GREM practice plan**: Created `CADRE-Courses/MalwareRev/README.md` — Remnux + FLARE-VM lab setup, Ghidra MCP AI-assisted reverse engineering, 6-week practice path, theZoo malware sample sourcing, integration with existing Elastic/VR/monitor infrastructure for behavioral analysis during RE.

### Changed (2026-05-18 — Session J: Live Deploy Marathon — 9 Playbook Bugfixes)
- **`playbooks.yml`**: Fixed indent bug (Phase 4 had 4 leading spaces).
- **`03-foundation.yml`**: Appended linux01 substrate play (realm join, MSSQL-Kerberos, NFS-krb5p, Podman privileged, auditd).
- **`04-extras.yml`**: Changed SQL Express instance from `MSSQLSERVER` to `SQLEXPRESS`; added TCP/IP enable task (registry: IPAll Enabled=1, TcpPort=1433, TcpDynamicPorts='').
- **`roles/vulns/tasks/main.yml`**: Fixed RC4 PowerShell `$sam: $_` → `${sam}: $_` (parser error).
- **`roles/linux/tasks/main.yml`**: Added `/var/opt/mssql/audit` to MSSQL directory list.
- **`roles/linux/tasks/auditd.yml`**: Replaced `pip` with `apt` for `python3-pymssql` (Ubuntu 24.04 PEP 668). Added FreeTDS config (`encryption = require`). Replaced `community.general.mssql_script` module with Python shell using `conn.autocommit(True)` (DDL fails inside transactions).
- **`roles/security/tasks/main.yml`**: Removed `svc.elastic` account creation (unused).
- **`extensions/velociraptor/playbook.yml`**: Fixed config generation (Python, not broken `--merge` heredoc). Fixed `public_url` suffix (`/app/index.html`). Removed `use_self_signed` (invalid field). Fixed user add syntax.
- **`extensions/elk-fleet/playbook.yml`**: Fixed all `.json.items` → `.json['items']` (Jinja2 dict method conflict). ES/Kibana templates updated (no `xpack.security.enabled`, service account token auth, encryption key ≥32 chars). Fleet Server enrollment uses `.deb` with `ELASTIC_AGENT_FLAVOR=server` (tarball bypasses system package lock).
- **`extensions/net-monitor/playbook.yml`**: Arkime uses local ES on monitor (127.0.0.1:9200, `xpack.security.enabled: false`). Suricata YAML header fixed. nfdump added. logrotate configured for Suricata (500 MB/daily/2 rotations).
- **New `docs/internal/next-steps-plan0-completion.md`**: Canonical completion guide with 5 steps to close Plan 0.
- **Static tests**: Updated to 105 checks. 105/105 pass.
- **`requirements.yml`**: Pinned all 3 collections (`ansible.windows: 3.5.0`, `community.windows: 3.1.0`, `microsoft.ad: 1.10.0`) — stops version-drift bleeding.
- **All `microsoft.ad.*` modules removed** from `ansible/roles/members/` (`cadre.yml`, `child.yml`, `range.yml`) — replaced with idempotent `win_powershell` calling raw RSAT-AD-PowerShell cmdlets (`New-ADOrganizationalUnit`, `New-ADUser`, `New-ADGroup`, `Add-ADGroupMember`). Zero remaining `microsoft.ad.*` calls in the codebase. Module-version-proof forever.
- **`microsoft.ad.membership` removed** from `playbooks.yml` — replaced with `Add-Computer` via `win_powershell` + `win_reboot` for mbr01/mbr02 domain joins.
- **26-play monolith split** into 4 phase playbooks under `ansible/playbooks/`:
  - `01-forests.yml` (9 plays) — collections + domain promos + DNS + trusts
  - `02-objects.yml` (5 plays) — AD objects + member joins
  - `03-foundation.yml` (5 plays) — security baseline + GPOs + vulns + ADCS
  - `04-extras.yml` (7 plays) — Linux + Kali + SCCM + SQL + shares + MSSQL + cloud
  - Master `playbooks.yml` imports all four via `import_playbook`
  - Failure in Phase 3 no longer forces re-running Phase 1.
- **`fix-dns.yml`** standalone play added — resets DNS on every VM to the correct domain DC. Re-runnable: `ansible-playbook -i inventories/hosts playbooks/fix-dns.yml`
- **`cadre.py`**: `--from-phase` flag added (e.g., `--from-phase 03-foundation` skips completed phases). Collection install now uses `--force` to enforce pinned versions. Help text updated with DNS fix command.
- **Static tests**: Updated play counter to scan phase playbooks too. 104/104 pass.

### Blocked (2026-05-18 — Session H: Live Deploy Attempt — 11 VMs Booted, Ansible Blocked by Module API Incompatibilities)

#### What Worked
- **All 11 VMs created and running**: dc01/dc02/dc03/mbr01/mbr02 on Windows Server 2025, linux01/kali/elk/vr/monitor/provisioning on Linux. VMware Workstation 25.0.0 + Vagrant 2.4.9 + vagrant-vmware-desktop 3.0.5.
- **`v.linked_clone = true`** added to Vagrantfile — cuts VM clone from ~5 min to ~30 sec.
- **Ethernet0 override bug fixed**: Removed `ethernet0.connectiontype = custom` + `vnet = VMNET` from Vagrantfile — these overwrote box-defined `pcislotnumber` and broke ALL guest networking (SSH + WinRM). Root cause of all earlier connectivity failures.
- **Provisioning VM switched** from `bento/ubuntu-22.04` to `bento/ubuntu-24.04` (22.04 had SSH auth issues with VMware provider).
- **`find_provisioning_key()` / `get_provisioning_ip()` bug**: Both hardcoded `PROVIDER_DIR` instead of accepting `vm_dir` — fixed. Also added password-based SSH fallback.
- **Static IP for Windows VMs**: Vagrant VMware cannot auto-configure Windows guest static IPs. Added PowerShell provisioner that finds the vmnet2 adapter (Ethernet1) and sets `New-NetIPAddress`. Destroyed + recreated dc02/mbr01/mbr02 which had corrupted WinRM from partial provisioning.
- **WinRM connectivity**: All 5 Windows VMs reachable on static IPs (192.168.77.10/11/12/22/23:5985) using `ansible_port: 5985` + `ansible_winrm_scheme: http`.
- **Ansible 13.6.0 installed** on provisioning VM via PPA. `microsoft.ad` 1.10.0, `ansible.windows` 3.5.0, `community.windows` 3.1.0 pre-installed.
- **Domain promotions**: All 3 forests promoted successfully via PowerShell `Install-ADDSForest` / `Install-ADDSDomain` (cadre.local, child.cadre.local, range.local).
- **DNS conditional forwarders**: Forwarder zones for `range.local` → dc03 and `cadre.local` → dc01 created successfully.
- **autobuild `cwd` bug**: Path resolution was off by one directory level — fixed.

#### What Failed — Ansible Module API Incompatibilities (Root Cause)
Every Ansible AD-related module failed because the installed collection versions (latest from Ubuntu 24.04 PPA) had different APIs than what the playbooks were written for. 13 distinct errors encountered:

| # | Play | Module | Error | Fixed? |
|---|------|--------|-------|--------|
| 1 | PLAY 2 | `ansible.windows.win_domain_membership` → **REMOVED** in ansible.windows ≥3.0 | `module has been removed. Use microsoft.ad.membership instead.` | ✅ Changed to `microsoft.ad.membership` |
| 2 | PLAY 2 | `microsoft.ad.domain` — `netbios_name` renamed → `domain_netbios_name` | `Unsupported parameters: netbios_name` | ✅ Changed to `domain_netbios_name` |
| 3 | PLAY 2 | `microsoft.ad.domain` — `domain_type` param removed | `Unsupported parameters: domain_type` | ✅ Removed param (module auto-detects forest vs child) |
| 4 | PLAY 2 | `microsoft.ad.domain_child` — `parent_domain_name` rejected for child domains | `parent_domain_name must not be set when domain_type=child` | ✅ Removed param (derived from `dns_domain_name`) |
| 5 | PLAY 2 | WinRM port defaulted to 5986 (HTTPS) despite `scheme: http` | `Connection to 192.168.77.10 timed out. (connect timeout=130)` | ✅ Added `ansible_port: 5985` |
| 6 | PLAY 2 | dc02 child promotion DNS — `Administrator@cadre.local` unreachable | `domain controller for cadre.local could not be contacted` | ✅ Added `win_dns_client` task to set DNS → dc01 before child promotion |
| 7 | PLAY 4-6 | `ansible.windows.win_dns_zone` — `forwarder` renamed → `dns_servers` | `Unsupported parameters: forwarder` | ✅ Changed to `dns_servers` |
| 8 | PLAY 6 | `child.cadre.local` forwarder on dc01 — delegation conflict | `Failed to create zone child.cadre.local on server DC01` | ✅ Changed to `Add-DnsServerConditionalForwarderZone` via win_shell |
| 9 | PLAY 8 | `microsoft.ad.ou` — `protected` renamed → `protect_from_deletion` | `Unsupported parameters: protected` | ✅ Changed to `protect_from_deletion` |
| 10 | PLAY 2 | Domain promotion (original attempt) — Ansible `dense` callback crashed with no TTY | `dense` callback uses ANSI cursor codes; output to file causes silent crash | ✅ Changed to `default` callback |
| 11 | PLAY 1 | `ansible_winrm_retry_delay` unsupported by pywinrm 0.4.3 | Warning only, non-fatal | ✅ Removed from group_vars |
| 12 | PLAY 1 | `community.windows.win_dns_zone` deprecated path (still works but warns) | Deprecation warning | ✅ Already changed to `ansible.windows.win_dns_zone` |
| 13 | — | `nohup` + `$!` PID capture broken via SSH | PID variable empty in output | Workaround: use `pgrep -f ansible-playbook` after launch |

**Status at end of session**: Playbook reached PLAY 8 (OUs/Groups/Users) before failing on `protected` param. 3 domains promoted, DNS forwarders configured, playbook ~30% through 26 plays.

#### What GOAD Does Differently (And Why We Should Adopt It)
From analysis of `C:\STUDY\Github\GOAD\ansible\`:

1. **Collection version pinning**: GOAD pins `ansible.windows: 1.11.0` (legacy) or `2.5.0` (Python 3.11) and `community.windows: 1.11.0`/`2.3.0`. CADRE uses `latest` for all collections — guarantees breakage when upstream changes APIs.
2. **`requirements.yml` with versions**: GOAD has TWO profiles (Python 3.10 vs 3.11). CADRE has `requirements.yml` but NO version pins.
3. **No `microsoft.ad` dependency**: GOAD avoids `microsoft.ad` entirely — uses `win_domain`, `win_domain_controller`, `win_domain_membership` from old `ansible.windows` which are stable when pinned.
4. **Two-adapter pattern**: GOAD auto-detects NAT vs domain adapter per-host and sets DNS only on the domain adapter. CADRE hardcodes `adapter_names: "*"`.
5. **`fix_dns` safety net**: GOAD has a re-runnable role that resets DNS on all interfaces. CADRE has none.
6. **Dynamic config loading**: GOAD loads `config.json` as an Ansible fact (`lab`) via `data.yml`. CADRE keeps config in `host_vars/` static files — harder to maintain.
7. **Focused playbooks**: GOAD has 20+ single-concern playbooks. CADRE has one 26-play monolith — hard to restart from failures.
8. **`import_playbook` chain**: GOAD chains with `import_playbook`. CADRE has everything inline.
9. **Raw PS as fallback**: GOAD uses Ansible modules where they work and falls back to PowerShell only when needed. CADRE does the reverse — uses PowerShell for most things but gets caught by module parameters for the rest.

#### Recommended Next Steps
1. **Pin collection versions immediately** in `requirements.yml`:
   ```yaml
   collections:
     - name: ansible.windows
       version: 2.5.0
     - name: community.windows
       version: 2.3.0
     - name: microsoft.ad
       version: 1.10.0
   ```
2. **Install pinned versions** on provisioning VM before playbook run:
   ```bash
   ansible-galaxy collection install -r requirements.yml --force
   ```
3. **Or (better): convert ALL module-based AD operations to raw PowerShell** — eliminates version dependency entirely. Already done for domain promotion and DNS forwarders. Remaining candidates: `microsoft.ad.ou`, `microsoft.ad.group`, `microsoft.ad.user`, `microsoft.ad.membership`.
4. **Add `fix_dns` safety net role** (like GOAD) — a standalone play that resets all VM DNS to point to the correct DC.
5. **Reduce deployment time**: Domain promotion + reboot is 5-10 min per DC. Total playbook time is dominated by Windows reboots (5 reboots × ~3 min each = 15 min). SCCM install will be the longest single play. Split playbook into phases so partial progress is recoverable.
6. **All VMs are currently halted** (`vagrant halt --force` ran, 10 VMs stopped). User will restart host machine. Next session needs `vagrant up` + playbook re-run from green field.

### Fixed (2026-05-18 — Vagrantfile Network + Provisioning Fixes)
- **Ethernet0 overrides removed**: `ethernet0.connectiontype` and `ethernet0.vnet` were overwriting box VMX `pcislotnumber` values, breaking ALL guest networking (SSH for Linux, WinRM for Windows). Root cause of all earlier "no route to host" errors.
- **`v.linked_clone = true` added** to VMware provider block — clone time drops from ~5 min to ~30 sec per VM.
- **Provisioning VM box**: `bento/ubuntu-22.04` → `bento/ubuntu-24.04` (22.04 had unrecoverable SSH auth with VMware provider).
- **Windows static IP provisioner**: Added PowerShell `New-NetIPAddress` + `Set-DnsClientServerAddress` since VMware cannot auto-configure Windows guest static IPs. Targets "Ethernet1" (vmnet2 adapter) specifically.
- **WinRM firewall rules**: Added ICMPv4 allow rule for ping verification.
- **Provisioning VM extras**: Added `sshpass` to the Ansible toolchain install.

### Changed (2026-05-17 — Session G: Modern CLI + net-monitor Independence)
- **`cadre.py` interactive install**: `cmd_install()` now prompts for all 3 options (VM directory, extensions, verbosity) with explanations and sensible defaults. Menu [2] renamed to "Quick Install" (all extensions, verbose=2, no prompts). Menu [3] "Custom Install" prompts for everything. CLI flags (`-vv`, `-e elk-fleet`, `--vm-dir`) override prompts when provided.
- **`_prompt_extensions()`**: Shows all 3 extensions with descriptions. Default: all. Per-extension y/n if "no" selected.
- **`_prompt_verbosity()`**: Shows 4 levels (0-3) with descriptions. Default: level 2 (task names, recommended).
- **`run_custom_install()` removed**: Logic folded into `cmd_install()`.
- **net-monitor standalone capability**: Play 3 (Elastic Agent enrollment) now conditional on Fleet server reachability. If elk-fleet is unreachable, Play 3 skips silently. Re-running net-monitor with elk-fleet on auto-enrolls the agent. All 3 extensions are now fully independent.
- **CLI argparse**: `--verbose` default changed from `0` to `None` so `cmd_install` can detect "not specified" and prompt.
- **Test harness**: Updated VM count check to accept Ruby 1.9+ hash syntax (`name:` in addition to `:name =>`).
- **Help text**: Updated with extensions section, verbosity levels, and re-run toggle info for net-monitor/ELK integration.

### Added (2026-05-17 — Plan 0 Final Gaps: GeoIP + osquery + Full-Coverage Audit)
- **GeoIP enrichment pipeline**: GeoLite2-City.mmdb downloaded from P3TERX/GeoLite.mmdb releases to `/etc/elasticsearch/ingest-geoip/`. ES ingest pipeline `cadre-geoip` created with 4 IP-field processors (source.ip, destination.ip, client.ip, server.ip). Applied to 11 `logs-*` index patterns via `_index_template` (priority 100) so all Elastic agents get GeoIP enrichment automatically.
- **Osquery scheduled pack** (§2.6.5): `osquery_manager` Fleet package installed on CADRE-All policy. Two scheduled packs created — `cadre-linux-pack` (5-min: suid_bin, memory-only processes, listening ports, kernel modules, users, authorized_keys) and `cadre-linux-pack-long` (30-min: deb_packages, last logins). 8 OSQuery SQL queries total as specified.
- **Attack Telemetry dashboard**: Rewritten NDJSON with 12 panel references to real saved searches in a 2-column 12-row grid layout. Covers authentication, process, ADCS, coercion, lateral movement, and cloud.
- **Elastic Defend API shape** (#28): Verified against 9.x Fleet `POST /api/fleet/package_policies` schema — `type: endpoint`, `streams: []`, `vars.policy.value` with per-OS protection modes matches official doc format.

### Fixed (2026-05-17 — Comprehensive 30-Item Audit: 10 Critical + 8 High + 9 Medium)
- **10 critical bugs**: Velociraptor MSI repack args (missing `--msi` flag, wrong position), MSI download pointed at stock file (fixed to fetch repacked MSI from vr server), dead artifact import before copy task (removed), MCP API paths used `/v1/` instead of `/api/v1/` (corrected), Zeek `creates:` blocked re-deploy (changed to `changed_when`), Suricata `creates:` blocked rule updates (changed to `changed_when`), dead Arkime systemd block `when: false` (removed), tcpdump conflicting `-G`+`-C` flags (removed `-C 1000`), tcpdump cleanup deadlock before `wait` (split to separate systemd timer), auditd regex matched wrong config key (added `\s*=` suffix).
- **8 high-severity**: Package `version: latest` → `"{{ elk_package_version }}"` (default `9.0.0`) across 6 integrations. Hardcoded `elastic-agent-9.0.0` → `elastic-agent-{{ elastic_agent_version }}` (~12 occurrences in elk-fleet + net-monitor). Zeek race condition (systemd `ExecStart` changed from `zeekctl deploy` to `zeekctl start`). Suricata upgraded from apt v6.x to OISF PPA 7.x. Zeek OBS key parameterized as `{{ ubuntu_release }}`. VR version corrected from nonexistent `0.76.5` to actual `v0.76` tag / `0.76.1` binary. `cadre.py` extension Vagrantfile path fixed (added `cwd` param to `run_vagrant()`).
- **9 medium**: `check_disk_gb()` locale-safe via `.Free` property. `find_provisioning_key()` exact VM match via `Path("provisioning") in kp.parents`. Help text extension list expanded. Vagrantfile redundant `type: "rsync"` removed. Arkime password parameterized as `{{ arkime_password }}`. `community.general` collection pre-installed via `ansible-galaxy`. auditd handler changed from `systemd` to `service` module.
- **4 missing components**: 26 saved searches NDJSON (elk-fleet/files/saved-searches/seed.ndjson). Attack Telemetry dashboard NDJSON (elk-fleet/files/dashboards/attack-telemetry.ndjson). 10 VR hunt YAMLs as proper CADRE.Hunts.* artifacts with VQL queries (velociraptor/files/hunts/). 15 Linux detection rules L01-L15 (elk-fleet/files/detection-rules/linux-seed.ndjson).
- **Linux auditd**: 48 immutable rules covering execve, credential files, Kerberos/SSSD, keytabs, realmd, SSH/PAM/NSS, NFS, Podman, kernel modules, SUID, cron/systemd persistence — matching §2.6 spec. plus MSSQL `SERVER_AUDIT_SPECIFICATION` (10 groups), SSSD debug_level=5, podman-events-log systemd unit.

### Added (2026-05-17 — DFIR Logging Reference + Diagram v2)
- **`docs/dfir-logging-reference.md`** (NEW, ~500 lines): single-page reference covering every CADRE telemetry source. 20 sections: quick-index table; 49 Windows audit subcategories grouped by 9 categories with EID + catches; 26 operational channels (incl. 5 Server 2025-only); PowerShell logging (4103/4104/transcription); NTLM auditing (8001-8004); 22 Sysmon EIDs; Elastic Defend; 30+ auditd keys; MSSQL 10 audit groups; SSSD debug logs; podman events; osquery scheduled pack (8 queries); 15 Zeek protocol logs; Suricata; Arkime/tcpdump/SiLK; cloud (Entra/Azure/M365 — 6 sources); Velociraptor (15+ built-ins + 5 custom CADRE artifacts + 10 pre-built hunts); Elastic indices cheat sheet; 11 sample KQL queries; provenance section linking back to source-of-truth Ansible files. Mirrors `cadre-dfir-monitoring.ps1` and `monitoring-dfir-specifications.md §2.6` so when those change, this updates in the same commit.
- **Deleted `docs/ADOPT_DFIR_Logging_Reference.xlsx`** — stale ADOPT-era binary, replaced by the markdown above (diff-friendly, version-controlled, GitHub-renderable, searchable, free).
- `README.md` + `DOCS.md` now link the new reference.

### Changed (2026-05-17 — Architecture Diagram v2)
- **`docs/img/cadre-architecture.svg`** rewritten end-to-end (v1 → v2). v1 had overflow issues (CADRE wordmark cut at top, cycle band falling outside the viewBox, cloud-indices text running past the column, "too colorful causes distraction"). v2 fixes: stricter grid (60 px margins, 20 px gutters), all content provably inside `0 0 1920 1080`, monochrome base (`#0d1117` bg, `#c9d1d9` body, `#161b22` cards), one accent color per pillar used only once (`#d97706` red-team, `#16a34a` DFIR, `#2563eb` cloud, `#8b5cf6` agentic, `#ca8a04` environment). Agentic and Cycle now stacked vertically as full-width bands at the bottom (no horizontal collision). Pillar legend row sits below the divider for clarity. Embedded `<style>` block (CSS classes) instead of per-element fills for consistency.
- Both PNGs re-rendered: `cadre-architecture.png` (1920×1080, ~190 KB), `cadre-architecture-4k.png` (3840×2160, ~580 KB).

### Added (2026-05-17 — Architecture Diagram Assets)
- **`docs/img/cadre-architecture.svg`**: 1920×1080 hand-authored SVG architecture diagram. C-A-D-R-E pillar header with color-coded strip; cloud layer (Plan 11); 3-domain AD substrate (cadre.local + child + range.local) with trusts; all 11 VMs as cards with IPs + per-VM specs; "FIRST OPEN-SOURCE LAB" badge on linux01; single-source Windows telemetry baseline callout (`cadre-dfir-monitoring.ps1`); right-column telemetry stack (elk + monitor + vr/MCP + DFIR toolchain); bottom band for Agentic pillar + the cycle. Dark professional palette (`#0a0e17` background, pillar gradients). `viewBox` + `preserveAspectRatio` + `max-width:100%` for responsive embed without clipping.
- **`docs/img/cadre-architecture.png`**: 1920×1080 PNG render (260 KB) — default embed in README + architecture.md.
- **`docs/img/cadre-architecture-4k.png`**: 3840×2160 PNG (800 KB) — 4K / high-DPI wallpaper.
- **`docs/img/README.md`**: asset inventory + markdown embed snippet + Windows wallpaper instructions + re-render-from-SVG recipe (headless Edge, no install required).
- `README.md`: embeds `cadre-architecture.png` above the C-A-D-R-E text block.
- `docs/architecture.md`: NEW "Full Architecture Diagram" section above Detection Coverage, lists all asset variants.

### Added (2026-05-17 — Doc Map + Leak-Prevention Contract)
- **`DOCS.md`** (repo root, public): documentation index — "start here", per-stage reading paths (deploy / use attack matrix / contribute), explicit out-of-scope note that internal planning lives in gitignored `docs/internal/`. Curated subset of the internal map.
- **`docs/internal/DOC-MAP.md`** (gitignored, internal): comprehensive doc map — every public + internal file with purpose, audience tag, reading stage, owner cadence. Includes: doc-segregation rules contract; leak-audit grep (PowerShell + bash); filename collision-prevention rationale (DOCS vs DOC-MAP); audience taxonomy (public / internal / mixed); stage taxonomy (onboard / understand / plan / code / deploy / investigate / maintain); per-task decision tree ("I am about to…"); maintenance checklist; rationale for two-layer doc system.
- **Naming convention** locked: `DOCS.md` (public) vs `DOC-MAP.md` (internal). Asymmetric on purpose — tab completion can't confuse them, grep returns one or the other cleanly, PR diffs are visually unambiguous.
- **`README.md`**: documentation table now links `DOCS.md` as the entry point.
- **`AGENTS.md`**: key-files table now lists `DOC-MAP.md` as "read first every session."

### Added (2026-05-17 — Linux AD Audit Spec + Full Doc Sweep)
- **docs/internal/monitoring-dfir-specifications.md §2.6**: Rewritten from 40-line stub → full Linux-AD substrate spec (~300 lines). ADOPT had no Linux box at all; this is greenfield. Covers: attack-surface enumeration (19 sources — SSSD, krb5/mssql keytabs, sssd cache, realmd, MSSQL-on-Linux, NFS-krb5, Podman privileged/`--pid=host`, PAM/NSS hijack, kernel modules, SUID changes); layered logging stack diagram (auditd → audispd → rsyslog → Elastic Agent + MSSQL audit + podman events + SSSD debug + osquery); complete `auditd.yml` Ansible task (≥45 immutable rules organized by attack stage); SSSD `debug_level=5`; MSSQL `SERVER_AUDIT_SPECIFICATION` for 10 audit groups; podman-events-log systemd unit; auditd retention bump (4 GB); 6 required Elastic Agent integrations for linux01 (auditd/system/mssql/custom_logs×2/osquery_manager); osquery scheduled pack (8 queries); 15 seed detection rules (L01-L15) with MITRE mappings; 9 required Velociraptor Linux artifacts incl. custom `CADRE.Linux.KeytabFingerprints`; full done criteria.
- **docs/architecture.md**: Added "Linux Telemetry Baseline (linux01 — AD-joined substrate)" section with 7-layer source table, explicitly noting ADOPT had no Linux AD coverage.
- **Doc sweep (Session C)** — every .md file made aware of the script + Linux AD substrate:
  - `README.md` — telemetry bullets cite the script + Linux audit first-class
  - `AGENTS.md` — new key-files entries for script, sysmon.yml, auditd.yml spec
  - `docs/goals.md` — 2 new differentiator rows (Linux audit greenfield, single-source Windows audit script)
  - `docs/extensions.md` — CADRE-All Linux integration list explicit; 5 new Linux index rows; `cadre-linux-triage` artifact list expanded incl. `CADRE.Linux.KeytabFingerprints`
  - `docs/forensic-workflow.md` — 5 new Linux-specific Data Sources rows (auditd / MSSQL audit / SSSD / podman / osquery); data flow diagram references full AD-substrate coverage
  - `docs/testing-recommendations.md` — §3.2 Windows baseline expanded (Server 2025 channels); new §3.2.5 Linux baseline (10 commands); 5 Linux indices added to §3.3; new §4b Linux-substrate attack smoke test
  - `docs/deployment.md` — already done in prior session
  - `docs/internal/roadmap.md` — Phase 0J now ✅; new Phase 0P (Linux AD audit, spec ✅/code ❌); 2 new decisions log entries
  - `docs/internal/lab-redesign.md` — 2 new "structurally superior" items (#11 single-source Windows audit, #12 Linux greenfield); "what was kept" table reframed to credit the script
  - `docs/internal/plan-implementation-guide.md` — status updated to ~60% (was 50%); Half B section split into Windows ✅ / Linux ⚠️; gap-vs-exists table for Half B rebuilt with current truth; priority order item #4 narrowed to Linux baseline only
  - `docs/internal/deploy-test-recipe.md` — A5 expanded with script verification; A9 grew from 5 to 13 checks (Linux audit baseline)
  - `docs/internal/doc-inventory.md` — Session C status log entry added
  - `extensions/elk-fleet/README.md` + `extensions/velociraptor/README.md` + `extensions/net-monitor/README.md` — stubs rewritten with substantive content + Linux integration callouts
  - `attack-matrix/README.md` — 07-detection-rules row references Linux L01-L15
  - `attack-matrix/01-walkthroughs/README.md` — new "Per-Walkthrough Telemetry Verification" section with explicit Linux indices to check for walkthroughs 044-048

### Added (2026-05-17 — DFIR Monitoring Script + Attack-Matrix Scaffold)
- **ansible/roles/security/files/cadre-dfir-monitoring.ps1**: Relocated from repo root (`adopt-dfir-monitoring.ps1`), renamed ADOPT→CADRE throughout. Added 5 Server 2025-specific channels (Kerberos/Operational, KDC/Operational, LDAP-Client/Debug, Security-Mitigations/UserMode, Credential-Guard/Operational). Added Sysmon log size (1 GB). Covers: 49 audit subcategories, process cmdline (4688), PowerShell deep visibility (4104/4103/Transcription), NTLM auditing, 26 operational channels, core log sizes. Executes on all 5 Windows VMs after OS setup via the security role.
- **ansible/roles/security/tasks/main.yml**: Rewritten — replaced 8 scattered partial registry tasks (5 audit subcats only, basic PS logging, no NTLM, no channels) with a 3-task block that deploys the script to `C:\Tools\cadre-dfir-monitoring.ps1`, executes it, and asserts `rc==0`. Single source of truth for all Windows audit configuration. Preserves `svc.elastic` local account creation and imports `sysmon.yml`.
- **ansible/roles/security/tasks/sysmon.yml**: NEW — installs Sysmon with Olaf Hartong's sysmon-modular config (download from sysinternals + raw.githubusercontent.com). Idempotent (`Get-Service Sysmon64` guard, `-c` for config refresh if already installed). Imported by `main.yml` after the DFIR script runs so the Sysmon channel is pre-sized to 1 GB.
- **attack-matrix/**: Full directory scaffold (24 dirs, 6 index READMEs, 2 env libs). Structure for 62 walkthroughs + 8 cert study paths + telemetry catalog + detection rules + hunting + cloud content.
- Deleted `adopt-dfir-monitoring.ps1` from repo root (replaced by relocated version above)

### Added (2026-05-17 — Documentation Overhaul)
- **docs/forensic-workflow.md**: Full rewrite (51→350 lines) — cycle vision, 3 investigation paths (red-team operator / DFIR practitioner / agentic), data flow architecture, export structure, VR hunts, cloud telemetry, service access
- **docs/deployment.md**: Full rewrite (103→430 lines) — 4-stage guide (A/B/C/D), prerequisites, per-stage verification, troubleshooting (11 entries), gotchas (5 entries)
- **docs/extensions.md**: Full rewrite (46→250 lines) — per-extension component tables, Fleet policies, promiscuous NIC, tool comparison, VR hunts + MCP, deployment order
- **docs/testing-recommendations.md**: NEW (310 lines) — 5-stage verification from static analysis through end-to-end smoke test
- **docs/goals.md**: Expanded (28→148 lines) — C-A-D-R-E pitch, 8-cert table, uniqueness comparison, roadmap with status
- **docs/architecture.md**: Expanded (69→210 lines) — topology diagram, VM specs, trust diagram, data flow pipeline, detection coverage (14 categories), service access
- **docs/internal/roadmap.md**: NEW (200 lines) — phase tracking, content stages, decisions log, priorities, cert coverage status
- **docs/internal/deploy-test-recipe.md**: NEW (400 lines) — 83-check verification recipe across all deploy stages
- **docs/internal/lab-redesign.md**: NEW (280 lines) — ADOPT→CADRE transition decisions, what changed/kept/cut
- **docs/internal/naming-scheme.md**: Expanded (141→280 lines) — conventions section, service account purposes, MSSQL creds, ADCS summary, extension creds, DSRM passwords
- **docs/internal/doc-inventory.md**: NEW — documentation tracking with gap analysis, session plan, narrative correction, status log
- **docs/internal/monitoring-dfir-specifications.md**: NEW (1520 lines) — Plan 0 Half B full spec (Sysmon, audit, ELK-Fleet, net-monitor, Velociraptor, export pipeline, snapshot/cycle)
- **docs/internal/attack-specifications.md**: NEW (1117 lines) — Plan 0 Half A full spec (ACLs, SPNs, ADCS templates, delegation, MSSQL, SCCM, coercion, shares, Linux, cross-forest, cloud, CVEs)
- **docs/internal/plan-implementation-guide.md**: NEW (850 lines) — per-plan build instructions, gap-vs-exists tables, priority order
- **core-plan.md**: Added Connected Vision section (loop diagram, three user journeys, inputs/outputs table, "Every Tool Has a Home" mapping)
- **core-plan.md**: Added complete 62+17 walkthrough list with VM targets, cert mappings, MITRE IDs

### Changed (2026-05-17 — Narrative Correction)
- Journey 1 renamed "Manual SOC Analyst" → "Red-Team Operator + Cert Student"
- Journey 2 renamed "Detection Engineer" → "DFIR Practitioner"
- All docs aligned to C-A-D-R-E pillar narrative (Cloud / Agentic / DFIR / Red-team / Environment)
- Elastic SIEM reframed as "forensic data source for red-team operator + agentic pipeline" — not SOC workbench

### Added
- Plan 0 — Foundation: Vagrantfile, cadre.py CLI, config.json source of truth
- 10 Ansible roles: domain, members, vulns, security, settings, adcs, sccm, linux, kali, cloud
- 3 extension playbooks: elk-fleet (Elastic 9.x), net-monitor (Zeek/Suricata/Arkime), velociraptor (VR + MCP)
- Deploy-test harness: 105 validation checks across all artifacts
- Public docs: deployment.md, architecture.md, goals.md
- MIT license, .gitignore, CHANGELOG.md

### Fixed (2026-05-17 — Code Review Pass)
- **LDAP paths**: child.yml `ou=` → `dc=` for proper SID/UPN resolution
- **Ansible module**: `microsoft.ad.member` → `microsoft.ad.group` (members.add)
- **ADCS templates**: PSPKI module load for `New-AdcsTemplate` + `Install-AdcsCertificationAuthority` cmdlet
- **Linux realm join**: elevated to privileged AD account (`CADRE\srvc-linux`)
- **Linux MSSQL**: added Microsoft APT repo before mssql-tools install
- **SCCM GPO**: fixed unreachable code block for `SCCM-Client-Push`
- **Vulns RC4**: corrected SAM account name typo in kerberos-rc4 script
- **Vulns OS family**: added `ansible_os_family` default for `setspn_ad_delegation`
- **cadre.py SCP**: fixed arg splitting for copy-id with key paths
- **download-media.ps1**: aligned EXE filename + switched `python->pwsh` execution in cadre.py
- **Elastic/Velociraptor**: fixed password setup ordering and gather_facts:false for extension VMs
- **Member join**: added mbr01 → `child.cadre.local` and mbr02 → `range.local` domain join plays
- **GPO idempotency**: merged duplicate `Secedit` tasks, deduplicated SSSD config, fixed Kali package names
- **DNS forwarders**: conditional forwarders for cross-forest trust resolution (`child.cadre.local` ↔ `range.local`)
- **Deploy harness**: added `become:true`, WinRM password var, MCP systemd daemon-reload fix
- **Framework docs**: moved `core-plan.md` → `docs/internal/`, added `.gitignore` entry
- **Net-monitor Jinja2**: hardcoded `arkime_interface` → `eth0`, removed variable from `content:` fields (clarified: "no Jinja2" referred to cadre.py, not Ansible's native `{{ }}` syntax)

### Added (2026-05-17 — Plan 0 Gap Closure)
- **ACL abuse paths**: 19 ACE entries across 3 domains in `vulns/tasks/acls.yml`
- **SPN registrations**: 5 Kerberoasting targets (svc.mssql×2, svc.sccm, svc.ldap, chief.command)
- **AS-REP roasting targets**: 3 accounts with no preauth (intern.blue, intern.intel, analyst.purple)
- **Delegation settings**: Constrained delegation with protocol transition (mbr02$) and without (svc.sccm)
- **ADCS ESC templates**: ESC3-Agent, ESC3-Target, ESC4, ESC7, ESC9, ESC13, ESC14, ESC15 — full 14/15 coverage
- **MSSQL Windows config**: xp_cmdshell, linked servers (mbr01↔mbr02↔linux01), CLR, TRUSTWORTHY, impersonation
- **SCCM misconfigurations**: NAA with DA credentials, PXE without boot password, auto client push
- **Coercion services**: DFS Namespace feature, LDAP signing verification
- **SMB shares + bait files**: 3 shares (public, restricted, vault), 4 bait files with recon intel
- **Credential harvesting prereqs**: Credential Guard off, LSA Protection (RunAsPPL) off
- **Linux AD attacks**: NFS Kerberos (`sec=krb5p`), Podman privileged container, MSSQL SA+keytab
- **dMSA / BadSuccessor**: `dmsaPrivService` on dc03 + KDS root key + gMSA (`gmsaTools`)
- **gMSA**: `gmsaTools` managed service account with ReadGMSAPassword ACL

### Fixed (2026-05-17 — Implementation Flow Audit)
- **Play order — DNS before trusts**: Moved DNS conditional forwarders (plays 4-6) BEFORE forest trust creation (was after — trust creation would fail without DNS resolution)
- **Play order — AD objects before member join**: Moved AD object creation (OUs, users, groups) BEFORE member server domain join (was after — `domain_ou_path` target OU didn't exist)
- **Play order — SQL on mbr01**: Added dedicated SQL Server 2022 Express install play for mbr01 (was missing — MSSQL config used `Invoke-Sqlcmd` on a server without SQL)
- **svc.naa Domain Admin idempotency**: Added `Get-ADGroupMember` guard before `Add-ADGroupMember` (crashed on re-run)
- **Child DNS forwarder**: Added missing conditional forwarder for `child.cadre.local` on dc01 (trust resolution safety net)

### Added (2026-05-17 — Naming Scheme & Documentation)
- **AGENTS.md**: Operator-facing repo guidance with conventions, build/test steps, Plan 0 status
- **docs/internal/naming-scheme.md**: Full per-user/password manifest — 24 users, 7 service accounts, 17 groups, 10 OUs, 3 shares, 4 GPOs
- **docs/forensic-workflow.md**: Public documentation of attack→telemetry→export→reset cycle
- **svc.elastic local account**: Created on all Windows VMs via security role for Elastic agent (`s3rv1c3_El@st1c!`)

### Audit (2026-05-17 — 5-Type Code Audit)
| Type | Method | Result |
|------|--------|--------|
| **Variable Resolution** | Scanned 43 YAML files, 33 known vars | ✅ All `{{ var }}` references resolve |
| **Cross-Referential Integrity** | 110 valid identities from `config.json` vs Ansible refs | ✅ 0 mismatches (5 computer refs are valid) |
| **Idempotency** | PowerShell cmdlets without existence guards | ✅ 1 bug found + fixed (`Add-ADGroupMember`) |
| **PowerShell Error Handling** | `try/catch` and `-ErrorAction` coverage | ✅ All critical operations guarded |
| **Playbook Flow Ordering** | 26-play dependency chain analysis | ✅ 3 bugs found + fixed (see above) |

### Changed
- `cadre.py` improved arg handling, SCP wrapper, `--install-extension` flow
- `playbooks.yml` expanded to 26 plays (added DNS child forwarder, SQL on mbr01, reordered 12 plays)
- `vulns/tasks/main.yml` restructured with logical sections, 2× tasks added
- `adcs/tasks/main.yml` expanded from 84→232 lines with all missing ESC templates
- `members/tasks/` grew from 3→6 files (added shares.yml, mssql-windows.yml)
- `members/tasks/range.yml` added svc.naa→Domain Admins with idempotency guard
- `linux/tasks/main.yml` expanded with NFS, Podman, MSSQL Kerberos config + SA password
- `sccm/tasks/main.yml` added post-install SCCM misconfiguration tasks
- `security/tasks/main.yml` added local `svc.elastic` user creation
- `.gitignore` already had `AGENTS.md` + `docs/internal/` (verified correct)

## [0.1.0] — 2026-05-16 — Plan 0 scaffolding

### Added
- Project documentation: core-plan.md, lab-redesign.md, deploy-test-recipe.md
- Directory structure matching repository layout specification
