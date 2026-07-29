# AGENTS.md

> **Every session:** first read **`docs/internal/ACTIVE.md`** (which project / writer repo), then `docs/internal/registry.md` (multi-repo index), **`docs/internal/ecosystem-organization.md`** (tracking-doc tiers + proposed folder layout), `docs/internal/roadmap.md` (cross-plan status), and `docs/internal/DOC-MAP.md` (internal doc index). Then the relevant plan state doc.

## Architecture

- **Entry point**: `cadre.py` (1435-line CLI — interactive menu + argparse subcommands)
- **Deployment**: Vagrant (VMware desktop) + Ansible run over SSH on the `provisioning` VM (`192.168.77.60`)
- **Source of truth**: `lab/data/config.json` — regenerated from Ansible playbook roles via `tools/regen-config/regen.py`
- **7 core VMs**: dc01/dc02/dc03 (2 forests + child), mbr01/mbr02 (member servers), linux01 (Ubuntu 24.04 domain-joined), provisioning
- **3 extension VMs** (gated by `CADRE_EXTENSIONS` env var): elk (.50), vr (.51), monitor (.55)
- **Windows-only** — needs VMware Workstation, `vmrun.exe`, PowerShell, Vagrant with `vagrant-vmware-desktop` plugin

## Lab Access

When running live campaign attacks, **use the Vagrant-injected SSH key**, not the `vagrant` password, to reach `provisioning` (`.60`). Vagrant boxes ship with an insecure key that the `vagrant` CLI configures automatically; if you invoke `ssh` directly you must point it at the generated private key.

Default paths:
- Insecure Vagrant key: `C:\Users\<user>\.vagrant.d\insecure_private_key`
- Per-VM generated key: `C:\Users\<user>\.vagrant\machines\provisioning\vmware_desktop\private_key`

Example direct SSH:
```powershell
ssh -i "$env:USERPROFILE\.vagrant\machines\provisioning\vmware_desktop\private_key" vagrant@192.168.77.60
```

Use `vagrant ssh provisioning` (from the `Vagrantfile` directory) when available — it resolves the correct key automatically.

> **Do not run `python cadre.py status` repeatedly during live campaigns.** It can block while waiting for VMware tooling and is meant for cold-start verification, not for rapid reachability checks. Prefer `ping`, `Test-NetConnection`, or the Vagrant SSH key path checks above.

## Attack Campaign (`attack-matrix/Campaign/`)

**Start here:** [`attack-matrix/Campaign/Runbooks/CAMPAIGNS-RUNBOOK-README.md`](attack-matrix/Campaign/Runbooks/CAMPAIGNS-RUNBOOK-README.md) (per-phase learn + execute) · **Index:** [`attack-matrix/Campaign/CAMPAIGNS.md`](attack-matrix/Campaign/CAMPAIGNS.md) (topology + coverage) · **Full reference:** [`CAMPAIGNS_v2.md`](attack-matrix/Campaign/CAMPAIGNS_v2.md) · **DFIR:** [`DFIR-Nexus-Pioneer-workflow.md`](attack-matrix/Campaign/DFIR-Nexus-Pioneer-workflow.md)

| Path | Role |
|------|------|
| `Campaign/CAMPAIGNS.md` | v2 index — topology, attack flow, runbook table |
| `Campaign/CAMPAIGNS_v2.md` | Full monolithic campaign (search / print) |
| `Campaign/CAMPAIGNS_v1_archived.md` | Archived v1 (60-attack campaign) |
| `Campaign/CAMPAIGNS-METADATA.md` | Per-attack metadata, playbook refs, telemetry |
| `Campaign/Campaign_suggestions.md` | Research backlog (promote → campaign when verified) |
| `Campaign/Runbooks/` | **Primary path** — full phase narrative + commands (Phase 0–8, 3.5, branches, E/F/G) |
| `Campaign/study-guide/` | Phase deep-dives (was `05-study-guide/`) |
| `Campaign/diagrams/` | Campaign attack-flow (`attack-flow.md`) |
| `Campaign/attackpath/` | 100-attack kill-chain map |
| `Campaign/artifacts/` | BH zip, nmap captures, etc. |
| `Campaign/ATTACK-MAP.md` | AD attack-surface mindmap |
| `Campaign/attack-tools-required.md` | Tools required per WT# |

**Sibling dirs (not under Campaign/):** `01-walkthroughs/` (WT reference), `04-automation/` (scripts), `02-diagrams/cadre-architecture-reference.md` (lab topology).

**Workflow:** Open phase runbook → read theory → run commands live → update `CAMPAIGNS-METADATA.md` → review `Campaign_suggestions.md` before next phase.

**Editing (going forward):** Change **runbook + matching `CAMPAIGNS_v2.md` section together**. Verify with `python tools/split-campaign-runbooks.py --check`. Full regen from v2 only: `python tools/split-campaign-runbooks.py` (overwrites runbooks).

**Tools:** `tools/split-campaign-runbooks.py` (heading-anchored split + coverage audit).

**Path notes:** Historical entries may say `attack-matrix/CAMPAIGNS.md` → now `attack-matrix/Campaign/CAMPAIGNS.md` (index) or `CAMPAIGNS_v2.md` (full narrative).

## Mini-Projects & Integrations

**Current Session (2026-07-29 — P1.0 campaign validation continues: T035/T035A/T004-mbr01 + T102 coercion scripts + v3 doc updates):**
- **Source / scope:** Continue P1.0 full campaign run from the mbr01 SYSTEM beachhead; harden campaign docs with proven paths and multi-credential identity flow.
- **What was done:**
  - Verified SQL → GodPotato SYSTEM path on `mbr01` via `T043-impersonate-ws01.sh` / `campaign-a-t043-impersonate.ps1`.
  - Created reusable `campaign-a-t043-system-exec.ps1` helper to run arbitrary PowerShell script blocks as SYSTEM on `mbr01` through the verified SQL channel.
  - Created and ran `T035-mbr01-creds-ws01.sh` / `campaign-a-t035-mbr01-creds.ps1` → mimikatz as SYSTEM on `mbr01`, output pulled back to `ws01`.
  - Created and ran `T035A-winlogon-creds-ws01.sh` / `campaign-a-t035a-winlogon-creds.ps1` → extracted `CADRE\analyst_cloud:Cl0ud_An@lyst!` from Winlogon registry as SYSTEM.
  - Created and ran `T004-mbr01-bh-ws01.sh` / `campaign-a-t004-mbr01-bh.ps1` → `SharpHound.exe` as SYSTEM on `mbr01`, zip pulled back to `ws01`.
  - Created `T102-coerce-dc02-ws01.sh` / `campaign-a-t102-coerce-dc02.ps1` to stage Rubeus + SpoolSample on `mbr01` from `ws01` beachhead and coerce `dc02$` to auth to `mbr01`; execution paused for user review.
  - Updated `attack-matrix/Campaign/CAMPAIGNS_v3.md` with verified automation references, multi-credential identity rule, and explicit rejection of scheduled-task abuse for attack execution (scheduled tasks are for persistence only).
  - Updated `attack-matrix/Campaign/automation/campaign-graph.yaml` v8 to add `T035A-WINLOGON`, `T004-MBR01-BH`, and `T102-COERCE-DC02` nodes; corrected `T035-CREDS` to use the mbr01 SYSTEM script and set `pivot_to: mbr01` / `produces_beachhead: mbr01_SYSTEM`.
  - Updated `CHANGELOG.md` with session summary.
- **Files updated:** `CAMPAIGNS_v3.md`, `campaign-graph.yaml`, `CHANGELOG.md`, `AGENTS.md`, `attack-matrix/04-automation/linux/campaign-a/T035A-winlogon-creds-ws01.sh`, `attack-matrix/04-automation/linux/campaign-a/T102-coerce-dc02-ws01.sh`, plus new PowerShell helpers under `attack-matrix/04-automation/linux/windows/`.
- **Next:** Resume T102 execution, then T009 DCSync, T010+ ticket attacks, T033 cross-forest. Update `04-vulnerabilities.yml` to permanently disable Defender on DCs/mbrs per user decision. Continue to plan1 telemetry catalog after spine is solid.

**Previous Session (2026-07-26 — Plan 1.1 complete: M5 E/F streams + P11.6 live smoke):**
- **Source / scope:** Closed Plan 1.1 — RedStrike CampaignOrchestrator E/F thin streams + install/smoke on provisioning `.60`.
- **What was done:**
  - **M5:** Branches E (phase 9) / F (phase 10); CLI `stream E|F`; API/MCP `campaign_stream`; graph v5; wrappers `linux/campaign-e|f/`; profiles `P-NETDEF` / `P-SUPPLY`.
  - **P11.6:** `~/RedStrike` venv **0.5.0** + `~/CADRE` glue on `.60`; dry-run RC=0 for Phases 1–3 (windows/linux) + stream E/F.
  - Docs sweep: CHECKLIST P11.* all `[x]`, CHANGELOG, ACTIVE → Plan 1 next, `red-strike.md`, plan1.1 README/plan, PLANS, registry, workflow, vm-access.
- **Files updated:** `RedStrike\` (0.5.0), `Campaign/automation/`, `04-automation/linux/campaign-e|f/`, `CHECKLIST.md`, `CHANGELOG.md`, `ACTIVE.md`, integrations + plan1.1 docs, pin `tools/red-strike/`.
- **Next:** Plan 1 telemetry catalog; live `--execute` operator-gated.

**Previous Session (2026-07-16 — README & Logo Tagline Refactoring for CADRE-RevAI / RevEng):**
- **Source / scope:** Refactored the public README.md and modified the tagline text inside the vector logo for the `CADRE-RevAI` repository, and merged/refactored the parent `CADRE-RevEng` README.md to prepare both for accurate public releases.
- **What was done:**
  - Refactored `CADRE-RevAI/README.md` to follow the "Pragmatic Hybrid" design: clarified the deterministic stage-based pipeline architecture ("Deterministic Skeleton, Cognitive LLM Union"), cataloged internal scripts, and separated core versus experimental features (such as Z3 symbolic deobfuscation and bottom-up call-graph function recovery).
  - Refactored and merged the parent `CADRE-RevEng/README.md` using `README2.md` as the source of truth, establishing an honest, clear layout describing active status tiers (v2 SQL-first, v3 UI hooks) and future v5 agentic planning.
  - Updated the tagline text inside `assets/revai-logo.svg` from "Autonomous Malware Decompilation & Deobfuscation" to "LLM-Assisted Reverse Engineering & Signature Generation" for technical accuracy.
  - Added absolute `file://` references to key implementation scripts in `README.md` to simplify developer navigation.
- **Files updated:** `c:\STUDY\Github\CADRE-Platform\CADRE-RevAI\README.md`, `c:\STUDY\Github\CADRE-Platform\CADRE-RevAI\assets\revai-logo.svg`, `c:\STUDY\Github\CADRE-Platform\CADRE-RevEng\README.md`, `CHANGELOG.md`, `AGENTS.md`.

**Previous Session (2026-07-13 — README & Image Asset Update for Public Release):**
- **Source / scope:** Updated CADRE README.md and generated public-release ready image assets from vector sources.
- **What was done:**
  - Rendered `docs/img/cadre-architecture-dark.png` from `docs/img/cadre-architecture-dark.svg` using headless Microsoft Edge.
  - Rendered `docs/img/cadre-logo-godfather.png` from `docs/img/cadre-logo-godfather.svg` using headless Microsoft Edge.
  - Formatted and updated `README.md` with the new Godfather logo at the top, along with license and platform badges matching the other sibling repositories.
  - Swapped out the old architecture diagram in `README.md` with the newly generated dark mode PNG.
  - Refactored README section titles to follow the standardized naming convention of public release projects.
- **Files updated:** `README.md`, `CHANGELOG.md`, `AGENTS.md`.

**Previous Session (2026-06-30 — CADRE-RevEng v2.0 COMPLETE + MTA 2025/2026 staging):**
- **Source / scope:** Finalized `CADRE-RevEng` v2.0 lab on `.41` (Linux) and `.42` (Windows). Deferred v3 work (RAG layer, Z3 verification, angr/CFF GhidraScript, CADRE main bridge).
- **Pipeline verified:** T4 pipeline (`intake → quick_scan_v2.py → deep_dive → yara_gen → publish_report`) tested on a real MTA sample.
  - SHA-256: `353ddce78d58aef2083ca0ac271af93659cf0039b0b29d0d169fc015bd3610bc`
  - Source: MTA 2026-04-16 Lumma Stealer + SectopRAT infection
  - Verdict: `malicious`, family `Lumma Stealer`, score 95, agreement `llm_and_v1_agree`.
- **MTA 2025/2026 fully staged on `.41`:**
  - 85 posts, 112 ZIPs downloaded, 65 extraction dirs, ~17 GB extracted.
  - Routing manifest: 130 executables, 71 pcaps, 16 documents, 40 scripts, 376 IOC text files, 30 images, 65 archives.
  - Routed to `/opt/samples/mta-routing/corpus/` (9.2 GB, RevEng) and `/opt/samples/mta-routing/dfir/` (2.9 GB, bridge-ready).
- **`stage_mta_traffic.py` rewritten:** New subcommands `emit-manifest`, `stage-zips`, `classify-artifacts`, `route-to-cadre`. Parses per-post pages for files + indicators. Auto-derives MTA password `infected_YYYYMMDD`. Uses `7z` for extraction (AES + long paths + bad unicode).
- **`stage_case_study.py` updated:** `--hunt-open-sources` queries MalwareBazaar, Hybrid Analysis, Triage, OTX, VirusTotal. Confirmed free-tier keys verify hashes but **cannot download** latest APT samples.
- **Vendor case-studies:** Reduced to 5 active (MLTBackdoor, OceanLotus, GoFlateLoader, MustangPanda, SaassyCode) + SHEET#CREEP workbook-only. Miasma + GopherRAT-FBISE removed.
- **Constraints locked:** Lab interface only: `.41` = `192.168.77.41`, `.42` = `192.168.77.42`. API keys in `/opt/secrets/cadre.env` (chmod 600): DeepSeek, ABUSECH, HA, TRIAGE, OTX, VT.
- **CADRE main bridge:** `publish_to_cadre.py` / `intake-from-cadre.py` **deferred to v3**. Local filesystem topics at `/opt/samples/mta-routing/` are the v2.0 stop point.
- **Key decision:** MTA 2025/2026 replaces vendor case-study samples as the primary real-world source for v2.0 exercises.
- **Files updated (RevEng repo):** `Tools/v2-deploy/verification-log-v2.md`, `Tools/v2-deploy/STAGING-PLAYBOOK.md`, `Tools/v2-deploy/_progress.md`, `Tools/v2-deploy/MTA-CADRE-SHARING.md`.
- **Files updated (CADRE umbrella):** `docs/internal/ACTIVE.md`, `AGENTS.md` (this entry), `CHANGELOG.md`, `registry.md`, `roadmap.md`, `roadmapv2.md`.
- **Next:** Use MTA samples from `/opt/samples/mta-routing/corpus/` for course exercises and pipeline drills. v3 bridge decision (read-only mount vs HTTP push) held until main CADRE campaign/telemetry work resumes.

**Current Session (2026-06-25 — Session 17 — Campaign v2 + full-content runbooks + coverage audit):**
- **Per user direction:** Runbooks include **all campaign details** (theory, tables, detection) — learn from explanation + live testing. Renamed main campaign to **v2** (`CAMPAIGNS_v1_archived.md` = v1).
- **File model:**
  - `CAMPAIGNS.md` — v2 **index** (topology, attack flow, runbook table, coverage)
  - `CAMPAIGNS_v2.md` — full monolithic reference (~3,074 lines)
  - `Runbooks/CAMPAIGNS-RUNBOOK-*.md` — **primary lab path** (18 files, full narrative + commands)
- **Coverage audit:** First split used stale line numbers → gaps in Phase 0, Phase 8 study refs, Branches/Exercises intros. Fixed: `tools/split-campaign-runbooks.py` now uses **heading anchors**; `--check` confirms 100% body coverage.
- **Runbook content verified:** Phase 1 (`## Main Spine`), Phase 3 (Alt + LOLBAS), Branch A (Branches intro), E (Exercises intro), 3.5/4/6/8 (study refs + library preamble).
- **Editing workflow:** Update **runbook + `CAMPAIGNS_v2.md` together** during lab work. Run `python tools/split-campaign-runbooks.py --check` after bulk changes. Regen from v2 only overwrites runbooks.
- **Files updated:** all 18 runbooks, `CAMPAIGNS.md`, `CAMPAIGNS_v2.md`, `Runbooks/CAMPAIGNS-RUNBOOK-README.md`, `Campaign/README.md`, `attack-matrix/README.md`, `CHANGELOG.md`, `AGENTS.md`.
- **Next:** Phase 0 from `Runbooks/CAMPAIGNS-RUNBOOK-0.md`.

**Current Session (2026-06-25 — Session 16 — AMSI Bypass Detection Engineering [plan1.7 §16 added + Item #109 REMOVED from Campaign_suggestions per routing clarification]):**
- **Source:** [One Bool. Six Shells. AMSI's Design Problem](https://bl4ckarch.github.io/posts/One-Bool.-Six-Shells.-AMSI%27s-Design-Problem/) by bl4ckarch, 2026-06-25. 15-min research write-up, 6 reverse-shell-verified AMSI bypass techniques with Defender real-time ON throughout.
- **Routing clarification (locked in this session):**
  - **plan1.7 / plan1.8** = CADRE project upgrades (plan1.7 defense, plan1.8 offense). Outside core campaign. Practical exercises for skill building.
  - **plan1.7-exercises / plan1.8-exercises** = practice library (EX-01..60 plan1.7, EX-OFF-01..37 plan1.8).
  - **Campaign_suggestions / CAMPAIGNS_v2 / CAMPAIGNS-METADATA / Runbooks** = core campaign plan00 + plan01 validation. Testing deployed environment end-to-end. Offensive attack primitives only.
  - **ad-evasion-gap-analysis.md** = AD-specific evasion (held, sister project integration). AD-only techniques tracked here.
  - **Defensive (plan1.7)** = detection rules, hardening, monitoring, deception.
  - **Offensive (plan1.8)** = attack techniques for skill building.
  - **Offensive (Campaign)** = attack primitives tested against deployed lab.
- **What was done this session:**
  - **plan1.7-defense-deepening.md §16 added** (~12 KB) — full detection engineering: 5 Sigma rules + Elastic KQL `cadre-010-amsi-bypass` + Sysmon EID 10/8 additions + memory forensics + native patch detection + 6 architectural findings + root cause mitigations.
  - **Campaign_suggestions.md Item #109 FULLY REMOVED** (per user direction: "Remove AMSI from campaign_suggestions entirely as it has nothing to do with campaign (we disabled defender - no relevance now) and remove any mistaken defense work from this doc as well"). 6 places cleaned: Phase mapping table, Testing Checklist table, Tier 3 Summary table, Cross-Reference Index (with replacement marker), source-style entry, full mechanics section. Item count 102 → 101.
  - **AMSИ bypass AD-specific tracking** — kept in `docs/internal/plan01-upgrades/ad-evasion-gap-analysis.md` reference doc (sister project integration; AMSI IS AD-specific since PowerShell bypass is core to AD attack chains).
- **Critical findings (now in plan1.7 §16 only):**
  - **6 null-pointer guards** in `AmsiScanBuffer` each fail-open to `AMSI_RESULT_NOT_DETECTED` — 6 detection opportunities
  - **PS 7 has TWO scan paths** (Path A `ScanContent` + Path B `ReportContent`) — all 6 new techniques disable BOTH
  - **`s_amsiInitFailed` got `initonly` on PS 7** but **`s_amsiNotifyFailed` did NOT** — Microsoft's inconsistency = bypass vector
  - **Defender kernel callback only watches `AmsiScanBuffer` at RVA 0x8160** — JIT heap, vtable slots, `InternalScan`/`InternalNotify` are **unmonitored**
  - **Event ID 4104 (WinSec PowerShell ScriptBlock) is NOT suppressed by any of these bypasses** — primary detection path
- **Most minimal bypass (Bypass 5):** `[Marshal]::WriteInt64($ctx, 0x08, 0L)` — one write, both paths disabled, zero VirtualProtect calls.
- **Detection key:** Sigma rule for Bypass 3 (`DynamicMethod + GetILGenerator + Stsfld + Emit + AmsiUtils`) is the canonical pattern; Sysmon EID 10 (ProcessAccess on amsi.dll) catches native patches.
- **Files updated (2):**
  - **`plan1.7-defense-deepening.md` §16** — NEW (~12 KB): §16.1-§16.8 covering why previous failed, 6 new techniques, architectural findings, 5 Sigma rules + Elastic KQL, memory forensics, root cause mitigations, cross-references, action items.
  - **`Campaign_suggestions.md`** — Item #109 FULLY REMOVED (6 places).
  - **`CHANGELOG.md` + `AGENTS.md`** — session 16 entries.
- **Workflow note (2026-06-25 session 16):** Per user first ask "you can update these 2 and remove from Todo" — applied bl4ckarch AMSI bypass research to plan1.7 §16 + Campaign_suggestions Item #109. Then per user follow-up "Remove AMSI from campaign_suggestions entirely" — removed Item #109 (per user's clarification that campaign = offensive attack primitives only, defensive work belongs in plan1.7, AD-specific evasion belongs in ad-evasion-gap-analysis.md). Item count 102 → 101.
- **Next:** When Defender is re-enabled in lab (per roadmapv2 decision): deploy Sigma rules + Elastic KQL from plan1.7 §16 to Kibana. Add EX-61 to plan1.7-exercises.md.
- **Per user direction:** Runbooks include **all campaign details** (theory, tables, detection) — learn from explanation + live testing. Renamed main campaign to **v2** (`CAMPAIGNS_v1_archived.md` = v1).
- **File model:**
  - `CAMPAIGNS.md` — v2 **index** (topology, attack flow, runbook table, coverage)
  - `CAMPAIGNS_v2.md` — full monolithic reference (~3,074 lines)
  - `Runbooks/CAMPAIGNS-RUNBOOK-*.md` — **primary lab path** (18 files, full narrative + commands)
- **Coverage audit:** First split used stale line numbers → gaps in Phase 0, Phase 8 study refs, Branches/Exercises intros. Fixed: `tools/split-campaign-runbooks.py` now uses **heading anchors**; `--check` confirms 100% body coverage.
- **Runbook content verified:** Phase 1 (`## Main Spine`), Phase 3 (Alt + LOLBAS), Branch A (Branches intro), E (Exercises intro), 3.5/4/6/8 (study refs + library preamble).
- **Editing workflow:** Update **runbook + `CAMPAIGNS_v2.md` together** during lab work. Run `python tools/split-campaign-runbooks.py --check` after bulk changes. Regen from v2 only overwrites runbooks.
- **Files updated:** all 18 runbooks, `CAMPAIGNS.md`, `CAMPAIGNS_v2.md`, `Runbooks/CAMPAIGNS-RUNBOOK-README.md`, `Campaign/README.md`, `attack-matrix/README.md`, `CHANGELOG.md`, `AGENTS.md`.
- **Next:** Phase 0 from `Runbooks/CAMPAIGNS-RUNBOOK-0.md`.

**Previous Session (2026-06-25 — Session 16 — Campaign folder restructure):**
- **Per user direction:** Organize campaign docs under `attack-matrix/Campaign/` with `Runbooks/` subdirectory. Folder moves: core docs, `study-guide/`, `attackpath/`, `diagrams/attack-flow`, `artifacts/`. Cross-links updated across `attack-matrix/`. Superseded by Session 17 for runbook content model (full narrative, v2 naming, coverage audit).

**Current Session (2026-06-25 — Session 15 — EX-60 SO-CRATES cross-cutting tool + Plan 9 reference):**
- **Source:** [SO-CRATES](https://github.com/dougburks/so-crates) by Doug Burks (Security Onion creator) at `C:\STUDY\Github\so-crates\`. Per user direction (2026-06-25): "b" (low effort, high signal).
- **What SO-CRATES is:** Standalone web app for PCAP + log + binary analysis with Suricata + Zircolite (Sigma) + YARA baked in. ~50 KB Python single file. Air-gapped capable. Same engine as securityonion.net/pcap.
- **What it adds to our stack:**
  - **Zircolite** (Sigma rule engine for log files) — currently missing
  - **YARA binary scanning** — currently missing
  - **Interactive PCAP analyst UI** with Sankey diagram + aggregation tables
  - **SQLite FTS5** full-text search across events
  - **Stream extraction** (click any row → ASCII transcript + hexdump + download)
- **What it does NOT replace:** Elastic Stack (long-term telemetry store), Arkime viewer (already deployed), our Suricata deployment (already deployed)
- **Files updated (3):**
  - **`plan1.7-exercises.md`** — added EX-60 "PCAP + Log Analysis with SO-CRATES (Cross-Cutting Analyst Tool)" + new "Cross-Cutting Tool: SO-CRATES" section + updated source table. **Total: 59 → 60 exercises.**
  - **`roadmapv2.md`** — added SO-CRATES cross-cutting tool reference to Plan 9 section + updated per-plan table (plan1.7 = 60 ex) + added SO-CRATES source path to file references table
  - **`CHANGELOG.md` + `AGENTS.md`** — session 15 entries
- **Workflow note (2026-06-25 session 15):** Per user "b" — added EX-60 with full Mechanics spec + brief Plan 9 reference. NO active deployment (held for next session).
- **CADRE applicability (focused):**
  - **Plan 9 (Memory/Disk Forensics):** per-file analyst UI for PCAP + logs + binaries
  - **plan1.7 EX-47:** analyze `The-Ultimate-PCAP.pcapng` (15 MB) with Suricata + Zircolite + YARA
  - **plan1.7 §10 PCAP Validation Workflow:** practical implementation of malware-traffic-analysis.net workflow
  - **Plan 2 design reference:** SO-CRATES `db.py` SQLite schema + UI is a working example of per-attack evidence bundle
  - **Sigma rule validation (Plan 5):** use Zircolite via SO-CRATES to test our 20 plan1.7 rules before deployment
- **Next:** When Plan 9 work starts: deploy SO-CRATES Docker container on monitor VM (or provisioning VM). Use as Plan 5 CI pre-flight check for Sigma rules.

**Current Session (2026-06-25 — Session 14 — Roadmapv2 + 13Cubed Linux Forensics Integration + EX-49..59 / EX-OFF-32..37):**
- **Per user direction (2026-06-25):** *"save roadmapv2 first and then proceed to review this one as well, i want linux forensics as well into this somehow ... C:\STUDY\Github\CADRE-Platform\CADRE-Courses\13Cubed ... this if anything new, goes into plan1.7 exercises and other places as necessary and update the roadmapv2 in the end. lastly update changelog and agents.md"*
- **Roadmapv2.md saved first** (`docs/internal/roadmapv2.md`, new, 8 sections) — supersedes `roadmap.md` as "where are we + what to do next". Sprint 1+2 = 9 sessions to v1.0.
- **13Cubed survey** — 3 courses found: Investigating Linux Devices (44 topics, 11 sections — primary), Investigating Windows Endpoints (32 topics, 10 sections), Investigating Windows Memory (48 topics, 10 sections). linux01 is our only first-class Linux AD member — Linux DFIR was a gap.
- **Critical new tools identified from 13Cubed:** Sysmon for Linux (Microsoft eBPF port), AVML (Microsoft Rust memory acquisition), UAC (Unix-like Artifacts Collector), Plaso/Log2Timeline, The Sleuth Kit (TSK), debugfs, WSL2 forensics
- **11 new plan1.7 exercises (EX-49..59, Category H - Linux Forensics):** Sysmon for Linux, init.d/systemd persistence, systemd Timers/Cron, SSH Key forensics, Timestomping, TSK fls/mactime, SSH+Cron+systemd chain, Plaso super-timeline, Volatility 3 Linux, UAC live response, full compromised system walkthrough. Total: 48 → 59.
- **6 new plan1.8 offensive exercises (EX-OFF-32..37, Category I - Linux Persistence + Anti-Forensics):** systemd service persistence (T1543.002), SSH authorized_keys backdoor (T1098.004), Timestomping (T1070.006), ext2/3/4 file system recovery, AVML+Volatility 3 memory forensics, WSL cross-OS persistence. Total: 31 → 37.
- **plan1.7-defense-deepening.md §15 added** (13Cubed Linux Forensics Integration, ~12 KB) — covers 13Cubed course library, Sysmon for Linux deployment plan, AVML+UAC as Plan 9 stack, 7 Linux Sigma rules to port (systemd_service_installed, systemd_timer_created, ssh_authorized_keys_modified, file_timestomp, proc_memory_injection, bash_history_cleared, auditd_disabled), 3 Suricata SID proposals (1000106 dd if=/dev/sda1, 1000107 avml, 1000108 ssh-keygen+authorized_keys write), 8 action items for 07-linux-config.yml + extension rules.
- **roadmapv2.md updated** — exercise counts (48→59, 31→37), new section 7 "13Cubed Course Library" with full Linux course mapping (49 topics across 11 sections), per-plan table updated, file references table updated.
- **Workflow note (2026-06-25 session 14):** Per user "save roadmapv2 first" then survey 13Cubed then "goes into plan1.7 exercises and other places as necessary and update the roadmapv2 in the end". Saved Roadmapv2 first (8 sections, ~333 lines), then surveyed 13Cubed Linux (44 topics, 11 sections), then added 11 EX-49..59 to plan1.7 + 6 EX-OFF-32..37 to plan1.8 + §15 to plan1.7-defense-deepening, then updated Roadmapv2.
- **Next:** Add Sysmon for Linux to `07-linux-config.yml`. Deploy 7 Linux Sigma rules to `extensions/elk-fleet/files/detection-rules/`. Add 3 Suricata SIDs to `extensions/net-monitor/files/suricata-rules/`. Add 13Cubed references to Branch D (Linux Pivot) in CAMPAIGNS.md. Plan 9 spec update for UAC as live-response tool. Begin Sprint 1 session 14 work (Plan 1.7 detection rules deploy).

**Current Session (2026-06-25 — Session 13 — ebooks/ Survey + Items #109-115):**
- **Per user direction (2026-06-25):** *"I want you to look into this, this is very huge so look only at the txt files for now... And see if it has anything relevant at all. Dont add anything, just propose your suggestions here."* → Proposed → User said: *"proceed with all of the above (full survey + 3 items + study refs + stubs)"*
- **Survey scope:** All 75 .txt files in `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\ebooks\` surveyed via term-frequency analysis for AD attack vocabulary + DFIR/detection keywords.
- **Survey findings (11 books Tier 1+2 — new content not in existing sources):**
  - **Tier 1 (7 books):** SANS Purple Team Tools poster (single highest), Practical-Red-Teaming, Applied Incident Response, Gray Hat Hacking 6th Ed, Windows Internals Part 1, Cyber Threat Hunting, Practical Threat Detection Engineering
  - **Tier 2 (4 books):** Practical AI Security (2025), Brc4, Windows Internals Part 2, eb-powershell-in-a-month-of-lunches
- **Survey rejections (title-suggested candidates that FAILED on closer inspection):**
  - `Active Directory Pentesting Mind Map.txt` — EMPTY (5 KB, 1 blank line)
  - `Rana-Khalil-Lab-Setup.txt` — NOT AD (PortSwigger Web Security Academy / Burp Suite)
  - `mdmz_book.txt` — 0 AD matches
  - `Practical Malware Analysis.txt` — CONFIRMED DUPLICATE of NoStarchPress_extract
  - SANS DFPS posters — already in `CADRE-Courses/sans/pdf_extract/`
- **3 new attack items extracted (#109-111):**
  - **#109 AMSI Bypass Techniques** (Gray Hat Hacking 6th Ed, 4 mentions — no other source covers) — Phase 3 attack primitive before mimikatz/Rubeus. 3 techniques: amsiInitFailed flag, AmsiScanBuffer patching, forced error. Detection: WinSec 4104 + Sigma `win_amsi_bypass.yml`.
  - **#110 DCShadow Attack** (Applied Incident Response + Practical-Red-Teaming, 5+ mentions — inverse of DCSync) — Phase 7 alternative persistence. Push fake SID history/SPN/group via DRS replication. Detection: WinSec 4662 from non-DC + Zeek DCE-RPC drsuapi.
  - **#111 Rubeus/Kerberoast/AS-REP cross-validation** (Practical-Red-Teaming + Gray Hat Hacking) — Verify existing Phase 1/2/7 commands against book recommendations. Check for missing flags (`/rc4opsec`, `/authexp`, `/tgtdeleg`).
- **4 study reference items (#112-115):**
  - **#112 Practical AI Security (2025)** — LLM security for CADRE-Strike (prompt injection, RAG poisoning, backdoor, supply chain)
  - **#113 Cyber Threat Hunting** — hypothesis-driven hunting methodology for plan1.7
  - **#114 Practical Threat Detection Engineering** — Sigma rule writing methodology
  - **#115 Windows Internals Part 1, 7th Ed** — LSASS/UAC/Kerberos/Credential Guard internals (supplements existing WindowsSecurityInternals)
- **Files updated (4 total):**
  - **`Campaign_suggestions.md`:** New "ebooks Survey (2026-06-25)" top-level section with survey methodology + deprioritized list + Tier 1+2 lists + 7 new items (#109-115). All 5 summary tables + footer updated. Counts: 98 → 102 items (24 ✅ / 59 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 12 🆕). Tier 3: 33 → 40.
  - **`CAMPAIGNS.md`:** New "📖 ebooks/ Survey (2026-06-25)" section in Study Reference Library with 11 book entries (chapter-to-phase mappings + recommended reading order + action items per book).
  - **`CAMPAIGNS-METADATA.md`:** 3 new Mechanics stubs (#109-111) inserted after Item #108 stub. Full 8-part templates each (3 AMSI techniques + DCShadow commands + Rubeus flag matrix). Plus new "Reference Books — ebooks/ Survey" section with 11 study-reference stubs + chapter-to-phase tables + reproduction checklist.
  - **`CHANGELOG.md` + `AGENTS.md`:** Session 13 entries added.
- **Workflow note (2026-06-25 session 13):** Per user direction, did full survey first (no additions), then proceeded with survey + 3 items + study refs + stubs once user approved. Same workflow as NoStarchPress survey (session 8) + extracted techniques (session 9). Detection engineering for new SIDs (plan1.7 §17) held.
- **Next:** When Phase 3 Execution cycle starts (post-Phase 3.5): re-enable Defender + AMSI + Tamper Protection, test AMSI bypass + Defender exclusion chain. When Phase 7 starts (post-Phase 6): test DCShadow as alternative persistence. Cross-validate Phase 1/2/7 commands against book recommendations (Rubeus flag matrix). Deploy plan1.7 §16/§17 detection rules + Sigma rules for AMSI bypass + DCShadow. Read Windows Internals Part 1 Ch 7-8 before Phase 3.5 (Security + Tokens).

**Current Session (2026-06-24 — Session 12 — Item #108: Defender Exclusion via PowerShell (T1562.001) [Detect FYI 2026-06-24]):**
- **Source:** [Testing AI Threat Hunting against Real-World KQL: A Side-by-Side Test](https://detect.fyi/testing-ai-threat-hunting-against-real-world-kql-a-side-by-side-test-4cdda76a5772) by Alex Teixeira, *Detect FYI* (Medium), 2026-06-24. 14-min article. User asked: "whats in it for us here?" + "yes add item #108".
- **Article summary:** Side-by-side AI vs human KQL hunt for PowerShell Defender folder exclusions. ChatGPT (GPT-5.5) 55-line query errored; Claude (Sonnet 4.6) 121-line query had 9/12 false-negatives (75% miss rate); human 15-line query caught 12/12. Author: Alex Teixeira, 10-year detection engineering SME.
- **Key AI meta-finding:** *"A model can produce syntactically correct, semantically plausible-looking queries that are completely useless in practice."* Both LLMs scoped by `FileName` instead of `ActionType`, only used `DeviceProcessEvents` (30% of telemetry) not `DeviceEvents`. **Use AI to review and improve human queries, not generate from scratch.**
- **Relevance check:**
  - **Phase 3 (Execution):** HIGH — `Add-MpPreference -ExclusionPath` is a real attack primitive (T1562.001). More realistic than full Defender disable (no Tamper Protection override needed).
  - **Phase 5 (Persistence):** MEDIUM — GPO-pushed exclusion lists. Maps to ACE paths in our `05-ad-attack-surface.yml`.
  - **plan1.7 §17 (Detection Engineering):** HIGH — article's 15-line human KQL is a complete reference template. Patterns port to Elastic (arg_max→top_hits, dcount→cardinality, parse_json→JsonProperty, search→OR clause).
  - **Track C (Sigma Rule Library):** HIGH — `win_defender_folder_exclusion.yml` candidate from human-improved query.
  - **Track H (CADRE-Strike):** CRITICAL — validates HITL requirement. 75% miss rate means AI-generated attack steps need human review.
  - **DFIR-Nexus:** CRITICAL — when LLM generates hunt queries, expect "syntactically correct, semantically plausible-looking queries that are completely useless in practice." Human review gate required.
  - **Main spine (Phase 0-8 AD attack):** MEDIUM — adds runtime exclusion precursor to Phase 3 execution, but full test requires re-enabling Defender (currently disabled via `04-vulnerabilities.yml`).
  - **plan1.7 detection engineering:** HIGH — direct KQL→Elastic KQL port + Sigma rule + Atomic Red Team T1562.001-1 cross-validation.
- **Item #108 added:**
  - **Campaign_suggestions.md:** Full entry with attack primitive, MITRE mapping (T1562.001, T1059.001, T1106), KQL→Elastic KQL pattern table, CADRE applicability, test plan, defenses, cross-references. Counts: 97 → 98 items (24 ✅ / 55 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 12 🆕). Tier 3: 32 → 33.
  - **CAMPAIGNS-METADATA.md:** New "Mechanics: Item #108 [STUB — UNTESTED]" section inserted between Phase 3 and Phase 3.5 Mechanics. Full 8-part template + KQL→Elastic KQL port + Sigma rule + KQL pattern table + AI meta-finding.
  - **CAMPAIGNS.md:** Inline note added in Phase 3 Execution section. Describes #108 as "Optional Precursor" — held for alternative execution cycle, NOT in main spine. Mentions current lab Defender state.
  - **CHANGELOG.md + AGENTS.md:** Session 12 entries added.
- **CADRE applicability (focused):**
  - **Phase 3 attack primitive:** `Add-MpPreference -ExclusionPath` + `Add-MpPreference -ExclusionProcess "mimikatz.exe"` before payload. Cleaner than full Defender disable.
  - **KQL→Elastic KQL patterns (6):** `arg_max(Timestamp, *)` → `top_hits`, `dcount(DeviceId)` → `cardinality`, `parse_json(AdditionalFields)["X"]` → `JsonProperty(winlog.event_data.X)`, `search in (T1, T2)` → `(T1:term OR T2:term)`, `summarize ... by X` → `aggregate by X.keyword`, `sort by DevCount` → `sort: { "cardinality": "desc" }`.
  - **Sigma rule candidate:** `win_defender_folder_exclusion.yml` (full YAML in CAMPAIGNS-METADATA.md).
  - **Elastic KQL rule candidate:** `cadre-009` — `process.command_line:*MpPreference*ExclusionPath* and process.name:"powershell.exe"`.
  - **Atomic Red Team cross-validation:** T1562.001-1 — `Invoke-AtomicTest T1562.001 -ShowDetails`.
  - **AI meta-finding for HITL:** Direct validation of "use AI to review human queries, not generate from scratch" — applies to CADRE-Strike + DFIR-Nexus + this very session.
- **Workflow note (2026-06-24 session 12):** Per user "yes add item #108" — added with full Campaign_suggestions entry + Mechanics stub + CAMPAIGNS.md inline cross-reference. KQL→Elastic KQL translation + Sigma rule held for plan1.7 §16/§17.
- **Next:** When Phase 3 alternative execution cycle starts: re-enable Defender on mbr01, test runtime exclusion → mimikatz chain. Deploy `cadre-009` Elastic KQL rule + Sigma rule via plan1.7 §16/§17. Validate with Atomic Red Team T1562.001-1. Track H (CADRE-Strike) HITL review gate for AI-generated attack steps.

**Current Session (2026-06-24 — Session 11 — Item #107: GitHub Actions Supply-Chain Attack Patterns [Flatt Security 2026-06-24]):**
- **Source:** [GMO Flatt Security Blog Part 1](https://blog.flatt.tech/entry/2026-github-actions-security-part1) by Sato (@Nick_nick310), 2026-06-24. User asked: "Can you translate this and check whats relevant for us" + "Do it".
- **Translation summary:** 4-part Japanese blog series on GitHub Actions security. Part 1 covers Initial Access via 3 attack patterns derived from real-world compromises (Ultralytics Dec 2024, nx Aug 2025, tj-actions/changed-files Mar 2025, trivy Feb 2026 twice, cline Feb 2026). Each pattern has detailed vulnerability mechanism + defense checklist.
- **Relevance check:**
  - **Plan 0.8 (Supply-Chain Emulation):** HIGH — article introduces CI-side attack patterns (cache poisoning, tag pollution) that lead to npm publish. F-11/F-12 added as held Plan 0.8 expansion scenarios (npm-side analogs: cache poisoning via `.npm/_cacache`, tag pollution via `npm dist-tag add`).
  - **CADRE-Strike (Track H):** HIGH — cline incident uses `anthropics/claude-code-action` which is the same tool class we'll deploy. Provides concrete defensive guardrails checklist.
  - **Main spine (Phase 0-8 AD attack):** NONE — no GitHub Actions in our AD lab VMs.
  - **DFIR-Nexus:** NONE — DFIR doesn't deploy GitHub Actions.
  - **plan1.7 detection engineering:** LIMITED — SIEM rules for "compromised CI/CD" aren't applicable to AD lab; some analogs (npm publish anomaly, cache poisoning telemetry) held for §17.
- **Item #107 added:**
  - **Campaign_suggestions.md:** Full entry with 3 attack chains, MITRE mapping (T1195.001, T1554, T1195.002), CADRE applicability (Plan 0.8 F-11/F-12 + Track H defensive guardrails), test plan, defenses, cross-references. Counts: 96 → 97 items (24 ✅ / 54 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 12 🆕). Tier 3: 26 → 32.
  - **CAMPAIGNS-METADATA.md:** New "Mechanics: Item #107 [STUB — UNTESTED]" section inserted between Phase 8 and Branch A. Full 8-part template.
  - **CAMPAIGNS.md:** F-11 + F-12 rows added to F section table (held status). Inline note explaining Flatt Security source + CADRE applicability.
  - **CHANGELOG.md + AGENTS.md:** Session 11 entries added.
- **CADRE applicability (focused):**
  - **Plan 0.8 expansion F-11:** Cache poisoning via `.npm/_cacache` manipulation in PR-triggered workflow. Analog to GitHub Actions cache poisoning from cline attack.
  - **Plan 0.8 expansion F-12:** Tag pollution analog via `npm dist-tag add <pkg>@<ver> <existing-tag-name>`. Maps to GitHub tag pollution (tj-actions, trivy).
  - **CADRE-Strike defensive guardrails:** When sister repo created + `claude-code-action` integrated: (1) NEVER `allowed_non_write_users: "*"` — restrict to maintainers; (2) NEVER bare `Bash` in `--allowedTools` — scope to specific commands; (3) ALWAYS minimal workflow `permissions:`; (4) ALWAYS pin external actions to commit hash; (5) ALWAYS validate artifacts via `path:` + delimiter syntax.
- **Workflow note (2026-06-24 session 11):** Per user "Do it" — added Item #107 with full Campaign_suggestions entry + Mechanics stub + CAMPAIGNS.md F-11/F-12 cross-reference. NOT in main spine — held for Plan 0.8 expansion or Track H integration. Detection engineering for new attacks held for plan1.7 §17.
- **Next:** Test Plan 0.8 F-11/F-12 in linux01 lab when Plan 0.8 expansion is scoped. Document CADRE-Strike guardrails when sister repo created.

**Current Session (2026-06-24 — Session 10 — CAMPAIGNS.md Flow Correction: NetExec Commands Repositioned to Right Stages):**
- **Per user feedback (2026-06-24):** *"campaign is like the story we simulate a real world attack in the order typically seen in real world... at every stage and at every credentials gains. SO the one you mentioned in step 0.5 isnt happening at that stage. Reveiw them carefully and move them to right sections. netexec tool usage is needed, but which command and which stage with what we have, must suit the flow"*
- **Problem:** Previous CAMPAIGNS.md Phase 0 Step 0.5 contained 11+ NetExec commands that required credentials (`intern_blue:1nt3rn_BLu3!`), but at Phase 0 we don't have those credentials yet. AS-REP Roast is what gives us intern_blue. The commands broke the campaign flow.
- **Quality principle (per user 2026-06-24):** *"Remember we did research on real world AD tool usage - windows lateral and so on. The course materials from SANS also gave us more tools. we use all the best tools at all stages - duplicates/alternative tool usage and alternative techniques all need to be well designed within our campaign. If the campaign isnt good, the whole project becomes worthless."*
- **Fix applied (4 changes):**
  1. **CAMPAIGNS.md Step 0.5** — Stripped to unauthenticated commands only (`--gen-relay-list`, signing state check, guest attempts marked blocked on Server 2025). Added clear note about what CAN run without creds.
  2. **CAMPAIGNS.md Phase 1 Step 3** — NEW — NetExec Authenticated Recon with `intern_blue` (first credential). Multiple tools: NetExec primary, bloodyAD alternative, ADeleg GUI for visual verification, impacket for deeper queries. Includes `nxc -M pre2k/enum_av/get-desc-users/find-delegation/admin-count`, `--asreproast --kdcHost`, `--kerberoasting --kdcHost`.
  3. **CAMPAIGNS.md Phase 2 Step 3** — NEW — NetExec Authenticated Recon with `svc_mssql` (service account). Multiple tools: NetExec (MSSQL unlocked), bloodyAD for ACL analysis, Certipy v5.1.0 for ADCS, impacket-mssqlclient for SQL-specific recon. Includes `nxc -M adcs`, `--find-delegation`, full AS-REP + Kerberoast.
  4. **CAMPAIGNS.md Phase 3.5 Step A** — NEW — NetExec Authenticated Recon with admin/SYSTEM (post-GodPotato on mbr01). Multiple tools: NetExec (16+ dump modules), lsassy v3.1.16, DonPAPI v2.0+, manual mimikatz, secretsdump.py, SharpHound. Includes `--sam --lsa --ntds --dpapi`, `-M winscp`, `--laps`.
- **CAMPAIGNS-METADATA.md updated:**
  - Step 0.5b Mechanics section now includes "FLOW CORRECTION" notice explaining what was moved
  - New Mechanics stubs for Phase 1 Step 3, Phase 2 Step 3, Phase 3.5 Step A — each with primary NetExec + 3-4 alternative tools, CADRE-specific notes, detection, cross-references
- **Quality principle applied:** Each new auth-recon stage shows **3-5 alternative tool options** per the "use all the best tools at all stages" principle — NetExec primary, then alternatives per stage:
  - **Phase 1.3 (intern_blue):** NetExec + bloodyAD + ADeleg GUI + impacket
  - **Phase 2.3 (svc_mssql):** NetExec + bloodyAD + Certipy + impacket-mssqlclient
  - **Phase 3.5A (admin):** NetExec + lsassy + DonPAPI + mimikatz + secretsdump.py + SharpHound
- **Workflow note (2026-06-24 session 10):** Per user direction, fixed the credential flow issue. Each new auth-recon stage shows 3-5 alternative tools/techniques per the "use all the best tools at all stages" principle. Next: local commit + extend if more stages need fixing.

**Current Session (2026-06-24 — Session 9 — 5 Concrete Techniques Extracted from Reference Books [Items #102-106]):**
- **Source:** Per user workflow principle (2026-06-24): *"books are reference material, but specific attack techniques IN them should be extracted as new items in Campaign_suggestions, with phase mapping. Only move to CAMPAIGNS.md Mechanics when verified."*
- **Item #102 — dsHeuristics abuse** (Phase 0/1 Recon) — Forest-level attribute that controls AD behavior (fAllowAnonNSPIUpdates, fDisableListContents). Source: Windows Security Internals Ch 11. Detect modifications as early-warning signal.
- **Item #103 — UAC bit exploitation beyond DONT_REQ_PREAUTH** (Phase 0/1/5 Recon) — Enumerate all 20+ UAC flags (TRUSTED_FOR_DELEGATION 0x80000, TRUSTED_TO_AUTH_FOR_DELEGATION 0x40000, DONT_EXPIRE_PASSWORD 0x10000). Source: Windows Security Internals Ch 10, 11.
- **Item #104 — ms-DS-Machine-Account-Quota check** (Phase 5 RBCD pre-flight) — Default quota = 10 (enables WT007 RBCD). Quota = 0 blocks. Source: Windows Security Internals Ch 11.
- **Item #105 — SACL/audit policy manipulation for detection evasion** (Phase 5+ red team perspective) — Defenders DETECT via WinSec 4907/4719. Adds Elastic KQL (proposed cadre-008) + Suricata SID (proposed 1000104). Source: Windows Security Internals Ch 9.
- **Item #106 — Atomic Red Team as validation framework** (Cross-cutting) — 1000+ pre-built MITRE ATT&CK tests for cross-validation of manual CAMPAIGNS.md attacks. Source: Practical Purple Teaming Ch 8.
- **Files updated (5 total):**
  - **`attack-matrix/Campaign_suggestions.md`**: 5 new items added (#102-106) with phase mapping, MITRE IDs, attack commands, detection rules, cross-references. Summary table, Phase Mapping, Testing Checklist, Tier 3 Summary, Cross-Reference Index, counts (91 → 96), footer all updated.
  - **`attack-matrix/CAMPAIGNS.md`**: Inline cross-references added in Study Reference Library entries for Windows Security Internals + Practical Purple Teaming — listing the 5 extracted items (#102-106) with their book chapter sources.
  - **`attack-matrix/CAMPAIGNS-METADATA.md`**: New "Mechanics: Techniques Extracted from Reference Books (#102-106) [STUB — UNTESTED]" section with full 8-part template Mechanics stubs for each item (why/attack commands/expect/failures/CADRE notes/telemetry/detection/pitfalls + reproduction checklist + cross-references).
  - **`CHANGELOG.md`**: New entry at top of `[Unreleased]`.
  - **`AGENTS.md`**: This entry.
- **CADRE applicability (HIGH — fills specific gaps):**
  - **#102 dsHeuristics** — addresses forest-level AD behavior we haven't touched
  - **#103 UAC bits** — expands from single-flag (0x400000 AS-REP) to 20+ exploitable flag combinations
  - **#104 Machine Account Quota** — pre-flight check prevents wasted RBCD attempts when quota = 0
  - **#105 SACL manipulation** — adds new detection engineering rules (WinSec 4907/4719, Elastic cadre-008, Suricata SID:1000104)
  - **#106 Atomic Red Team** — cross-validation framework — runs 1000+ attacks to verify our detection rules fire
- **Workflow note (2026-06-24 session 9):** Per user direction, all 5 items added to Campaign_suggestions + Mechanics stubs to CAMPAIGNS-METADATA.md (not yet added to CAMPAIGNS.md attack flow — waiting for verification). User's principle: *"We always add into suggestions by mapping to the right phase first. only when i need i move to campaign and metadata only after the actual attack."* — Mechanics stubs in CAMPAIGNS-METADATA.md are forward-looking per user statement: *"in the interest, we can add them on all 3 docs and verify/update as we go"*.
- **Next:** Test #102-105 in lab (Phase 0 read + RBCD pre-flight + audit policy detection). Deploy Atomic Red Team on mbr01 for #106 validation.

**Current Session (2026-06-24 — Session 8 — NoStarchPress Reference Library Survey [Items #100-101]):**
- **Survey scope:** All 49 directories in `CADRE-Courses/NoStarchPress_extract/` surveyed via term-frequency analysis for AD-relevant terms. Two books have high direct value; rest are lower priority or duplicative.
- **Item #100 — Windows Security Internals (Forshaw, 2023):** Located at `CADRE-Courses/NoStarchPress_extract/WindowsSecurityInternals_11172023/` (1.3MB .txt, 19.6MB .html). 600 AD-relevant matches.
  - **Chapter 14 (Kerberos)** — direct support for Phase 1 (AS-REP), Phase 2 (Kerberoast), Phase 7 (Golden Ticket), Skipjack #97, Onelogon #76, Zerologon Alternative #65
  - **Chapter 11 (Active Directory)** — Branch A (14 ACEs), Branch B (ADCS CA ACLs), Phase 8 cross-forest
  - Chapter 4 (Access Tokens) — Phase 3.5 LSASS + token impersonation
  - Chapters 5-8 (Security Descriptors) — Branch A + plan1.7 (AccessMask decoding)
  - Chapter 9 (Security Auditing) — plan1.7 (SACL audit policy)
- **Item #101 — Practical Purple Teaming (Petrey):** Located at `CADRE-Courses/NoStarchPress_extract/Practical_Purple_Teaming-0642572230173/` (725KB .txt, 770KB .html). 255 AD-relevant matches.
  - **Chapter 6 (Collecting Telemetry)** — plan1.7 detection engineering patterns
  - **Chapter 8 (Atomic Red Team)** — 1000+ pre-built attack tests for cross-validation of our manual CAMPAIGNS.md commands
  - Chapter 9 (Caldera AD Recon) — Track B Caldera integration
  - Chapter 10 (Mythic C2) — Plan 10 (C2+Emulation), Loki integration
  - **Chapter 11 (Reporting + Tracking)** — `tracker.md` workflow + DFIR-Nexus case reports
  - Chapter 12 (Purple Teaming Function) — DFIR-Nexus organizational model
- **Files updated (5 total — focused scope per user direction):**
  - **`attack-matrix/Campaign_suggestions.md`**: New top-level section "NoStarchPress Reference Library Survey (2026-06-24)" with full survey methodology + lower-value deprioritized list + Item #100 (Windows Security Internals) + Item #101 (Practical Purple Teaming). All 5 tables (summary, Phase Mapping, Testing Checklist, Tier 3 Summary, Cross-Reference Index) + counts (89 → 91) + footer updated.
  - **`attack-matrix/CAMPAIGNS.md`**: New "📖 Windows Security Internals (Forshaw, 2023)" + "📖 Practical Purple Teaming (Petrey)" entries in Study Reference Library section (just after CVE-2020-0665 Forest Trust entry). Both with chapter → CADRE phase mapping + recommended reading order.
  - **`attack-matrix/CAMPAIGNS-METADATA.md`**: New "Reference Books — Windows Security Internals + Practical Purple Teaming [STUDY]" section after ADeleg. Full chapter mapping tables for both books + recommended reading order + CADRE-specific notes + cross-references. Status: study reference, not new attack Mechanics.
  - **`CHANGELOG.md`**: New entry at top of `[Unreleased]` — "NoStarchPress Reference Library Survey [Items #100-101]" with full breakdown.
  - **`AGENTS.md`**: This entry.
- **CADRE applicability (HIGH):** Both books fill specific reference gaps:
  - Windows Security Internals Ch 14 is the **primary reference for Kerberos protocol mechanics** in our campaign — supports Phase 1/2/7 + Skipjack/Onelogon/Zerologon items
  - Practical Purple Teaming Ch 6 is the **primary reference for telemetry correlation patterns** that match our plan1.7
- **Lower-value books deprioritized (held for Plan 11 / Plan 10 / general reference):** Pentesting Azure Applications, EvadingEDR, Red Team Engineering, Ethical Hacking, Black Hat Python, Gray Hat C#, Foundations of Information Security
- **Workflow note (2026-06-24 session 8):** Per user direction, scope was 3 campaign docs + CHANGELOG/AGENTS. Books added as Study Reference Library entries (not new attack Mechanics). Full integration held until post-campaign.
- **Next:** Read Windows Security Internals Ch 14 (Kerberos) + Ch 11 (AD) before executing Phase 1/2/7. Read Practical Purple Teaming Ch 6 (Telemetry) before plan1.7 detection engineering.

**Current Session (2026-06-24 — Session 7 — ADeleg: Windows GUI Tool for ACL/ADCS Recon [Episode 173]):**
- **Source:** ADeleg podcast Episode 173 + course material at `CADRE-Courses/How to Find Insecure Active Directory Permissions with ADeleg/Episode 173_*.txt` (21,554 bytes). https://github.com/trimarc/ADeleg
- **Why ADeleg:** "almost the same amount of information that bloodhound gets you but with like a third of the hassle" — no SharpHound collector (avoids EDR alerts), no Docker/Neo4j, pure Windows GUI. Direct View by Trustee maps to attacker perspective. ADCS ESC1-8 template misconfig flagging built-in.
- **Key concepts from article:**
  - **Unsafe users/groups**: everyone, authenticated users, domain users, domain computers, domain join account (often over-permissioned)
  - **Unsafe permissions**: GenericAll, WriteDacl, WriteOwner, ForceChangePassword, etc.
  - **ADCS misconfig**: flags ESC1 (enrollee supplies subject), ESC2 (any purpose EKU), ESC3 (enrollment agent), ESC4 (WriteDacl/WriteOwner on template)
- **Files updated (5 total — focused scope per user direction):**
  - **`attack-matrix/CAMPAIGNS.md`** (3 changes): New Phase 0 Step 7 (ADeleg GUI Recon — Alternative to BloodHound) with full workflow + CADRE-specific notes + detection; ADeleg pre-BloodHound tip in Branch A (ACL Abuse); ADeleg pre-Certipy tip in Branch B (ADCS).
  - **`attack-matrix/CAMPAIGNS-METADATA.md`**: New "Mechanics: Phase 0 Step 7 — ADeleg GUI Recon [STUB — UNTESTED]" section after Step 0.5b. Full 8-part template: why it works, attack workflow, success/failure modes, CADRE-specific notes, telemetry fingerprint (WinSec 4662 + Sysmon EID 1 ADeleg.exe + Zeek LDAP + proposed Suricata SID:1000102), detection engineering (Elastic KQL cadre-007), common pitfalls, Wireshark field reference, reproduction checklist, ADeleg vs BloodHound decision matrix.
  - **`attack-matrix/Campaign_suggestions.md`**: New top-level section "ADeleg — Windows GUI Tool for ACL/ADCS Recon (Episode 173, 2026-06-24)" + Item #99 added with full details on workflow, CADRE mapping table, detection, cross-references. All 5 tables + counts (88 → 89) + footer updated.
  - **`CHANGELOG.md`**: New entry at top of `[Unreleased]` — "ADeleg: Windows GUI Tool for ACL/ADCS Recon [Episode 173]" with full breakdown.
  - **`AGENTS.md`**: This entry.
- **CADRE applicability (HIGH — fills a gap):**
  - **Visualizes the 14 ACEs from `05-ad-attack-surface.yml`** — fast deployment verification without SharpHound setup
  - **Visualizes ADCS ESC1-17 templates from `08-adcs-deploy.yml`** — pre-Certipy triage (visual scan, not noisy LDAP queries)
  - **Surfaces domain join account over-permission** — real-world common pattern per article ("i commonly see over permissioned")
  - **No EDR triggers** (vs SharpHound) — useful in hardened environments
  - **Report-ready** — GUI screenshots vs BloodHound graph queries
- **Decision matrix (ADeleg vs BloodHound):**
  | Use case | ADeleg | BloodHound |
  |---|---|---|
  | Setup time | 1 min | 30 min (Docker + Neo4j) |
  | EDR detection | Low | High (SharpHound collector) |
  | Path-finding | No | Yes (Cypher queries) |
  | ADCS misconfig | Yes (visual) | Limited |
  | Visual presentation | GUI screenshots | Graph database |
- **Cross-references:** Phase 4 (BloodHound — deep path-finding), Branch A (ACL Abuse — visual confirmation), Branch B (ADCS — pre-Certipy scan), `certipy find -vulnerable`, `nxc ldap --adcs`.
- **Workflow note (2026-06-24 session 7):** Per user direction, scope was 3 campaign docs + CHANGELOG/AGENTS. ADeleg integrates into Phase 0 + Branch A + Branch B as alternative recon tool. Detection engineering for new SID:1000102 held for plan1.7 §17. Course material in `CADRE-Courses/How to Find Insecure Active Directory Permissions with ADeleg/` (not duplicated to CADRE repo per path convention).
- **Next:** Test ADeleg on mbr01 (domain-joined, less critical than DCs). Verify 14 ACEs + ESC1-17 templates visible in GUI. Capture WinSec 4662 + Zeek LDAP telemetry for detection engineering baseline.

**Current Session (2026-06-24 — Session 5 — NetExec `coerce_plus` + 6 new modules + `--kdcHost` flag [Hacking Articles AI+HexStrike Analysis]):**
- **Source:** https://www.hackingarticles.in/ai-powered-active-directory-pentesting-with-claude-hexstrike-ai-netexec/ (June 21, 2026). Article walks through HexStrike AI + Claude Desktop driving NetExec end-to-end. **Key value for CADRE**: comprehensive NetExec command reference + 6 modules not previously documented.
- **`--kdcHost` flag** (CRITICAL): Fixes "KDC routing quirk" when running AS-REP roast or Kerberoast against multi-DC environments (we have 3 DCs). Without it, AS-REQ may be sent to unreachable DC and fail silently.
- **`-M coerce_plus`** (consolidated coercion check): Single command checks PetitPotam, PrinterBug, DFSCoerce, MSEven, MS-RPRN. Replaces running 5 individual coercion checks (WT017-020). Added to CAMPAIGNS.md as **WT096** in Phase 5.
- **6 new modules documented:**
  - `-M pre2k` — Pre-Windows 2000 computer account abuse check (Phase 0)
  - `-M enum_av` — AV/EDR enumeration (Phase 0, pre-attack OPSEC)
  - `-M get-desc-users` — User description field enumeration (Phase 0, password leak check)
  - `-M winscp` — WinSCP saved session decryption (Phase 3.5 creds)
  - `-M rdp -o ACTION=enable/disable` — RDP enablement (operational primitive)
  - `--dpapi` — Built-in DPAPI loot (Phase 3.5, alternative to DonPAPI module)
- **DCSync detection enhancement:** Property GUID `1131f6aa-9c07-11d1-f79f-00c04fc2dcd2` = DS-Replication-Get-Changes. Alert when 4662 references this GUID + subject account is NOT a domain controller → canonical DCSync detection. Added Elastic KQL.
- **Files updated (5 total — focused scope per user direction):**
  - **`attack-matrix/CAMPAIGNS.md`** (5 changes): Step 0.5 added 3 new recon modules + `--kdcHost` examples; Phase 1 AS-REP + Phase 2 Kerberoast added nxc alternatives with `--kdcHost`; Phase 5 added WT096 `coerce_plus` row + full Mechanics section; Phase 6 Study Reference added DCSync property GUID signature.
  - **`attack-matrix/CAMPAIGNS-METADATA.md`**: New "Mechanics: Phase 0 Step 0.5b — NetExec `--kdcHost` flag + 6 new modules [STUB — UNTESTED]" section with detailed stub for each of the 8 items (kdcHost + 6 modules + DCSync GUID).
  - **`attack-matrix/Campaign_suggestions.md`**: New top-level section "NetExec New Modules" + Item #98. All 5 tables + counts (87 → 88) + footer updated.
  - **`CHANGELOG.md`**: New entry at top of `[Unreleased]` — "NetExec `coerce_plus` + 6 new modules + `--kdcHost` flag" with full breakdown.
  - **`AGENTS.md`**: This entry.
- **CADRE applicability (CRITICAL — silent failure fix):**
  - `--kdcHost` flag fixes silent failure of existing Phase 1/2 commands (AS-REQ may have been sent to unreachable DC)
  - `coerce_plus` consolidates 5 individual coercion checks (Phase 5 pre-flight)
  - 3 new recon modules (pre2k, enum_av, get-desc-users) add Phase 0 coverage
  - 3 new post-ex modules (winscp, dpapi, rdp) add Phase 3.5 coverage
  - DCSync GUID adds high-fidelity detection signal (Phase 6)
- **Cross-references:** All additions complement existing #90 NetExec entry. Detection engineering for new modules → plan1.7 §17.
- **Workflow note (2026-06-24 session 5):** Per user direction, scope was 3 campaign docs + CHANGELOG/AGENTS. All updates integrated directly into CAMPAIGNS.md (no deferral) since the new commands work with existing tooling. **CADRE-Strike agentic approach deferred** — separate from manual campaign automation (per user, similar to DFIR-Nexus pattern, to be shared later).
- **Next:** Test the new commands in lab. Start with `--kdcHost` fix (Phase 1/2) — verify AS-REP roast and Kerberoast now work reliably. Then test `coerce_plus` to confirm full coercion picture. Then add `pre2k`, `enum_av`, `get-desc-users` to Phase 0 recon.

**Current Session (2026-06-24 — Session 4 — Skipjack: Cross-Forest Trust Downgrade via Invalid PAC Signature):**
- **Research source:** https://blog.ghostwolflab.com/redteam/786/ — Ghost Wolf Lab Research, "PAC 签名无效引发的域信任降级攻击" (Domain Trust Downgrade Attack Caused by Invalid PAC Signatures), 2026-06-23. Chinese-language blog, GitWolfLab is a Chinese red team research group.
- **Attack name:** **Skipjack** (skip the PAC signature check, jack the downgrade logic).
- **Vulnerability mechanism:** Kerberos PAC has two signatures (service + KDC) for integrity. When verification **fails**, Windows DCs have a **downgrade fallback** (legacy compatibility): look up user in local AD + rebuild token from AD groups. In **cross-forest trust scenarios where SID filtering is disabled**, an attacker can inject a forged Domain Admins SID into the PAC, corrupt the signatures, and submit the forged TGT to the target forest's DC — DC enters downgrade mode, keeps the forged SID (because SID filter OFF), and grants Domain Admin.
- **CADRE applicability: HIGH** — all pre-conditions met:
  - 2 forests (cadre.local, range.local) with cross-forest trust
  - **SID Filter OFF** verified per `01-core-ad.yml:50` (Server 2025 forest trust default)
  - Attacker controls user in child.cadre.local (`intern_blue`)
  - Target forest (cadre.local) — Enterprise Admins SID `S-1-5-21-<domain>-519` available for injection
- **Skipjack vs current Phase 8 (Golden Ticket):** Skipjack is **cleaner path** — uses legitimate user's TGT + signature corruption, doesn't require DCSync or krbtgt hash extraction. Golden Ticket forges TGT with krbtgt hash + SID history.
- **Files updated (3 total — focused scope per user direction):**
  - **`attack-matrix/Campaign_suggestions.md`**: New top-level section "Skipjack — Cross-Forest Trust Downgrade via Invalid PAC Signature (GhostWolfLab, 2026-06-23)" after Onelogon. Item #97 (next available) added with full mechanism, CADRE pre-conditions table (all met), testing plan, detection rules, defense recommendations, cross-references. Summary table, Phase Mapping, Testing Checklist, Tier 3 Summary, Cross-Reference Index, counts (86 → 87), footer updated.
  - **`attack-matrix/CAMPAIGNS.md`**: New "Skipjack — Cross-Forest Trust Downgrade via PAC Signature Corruption (Phase 8 alt)" section in Phase 8 with full vulnerability mechanism, CADRE applicability, Skipjack vs Golden Ticket comparison table, test plan with `Rubeus.exe asktgt /injectSID /corruptSignature`, detection rules, defense recommendations.
  - **`attack-matrix/CAMPAIGNS-METADATA.md`**: New "Mechanics: Skipjack — Cross-Forest Trust Downgrade via PAC Signature Corruption [STUB — PENDING CUSTOM TOOL]" section after Phase 8 Mechanics. Status ⏳ PENDING. Full 8-part template with predicted attack commands, success/failure modes, CADRE-specific notes, telemetry fingerprint, detection engineering (proposed Suricata SID:1000101), Wireshark field reference, reproduction checklist.
- **Detection engineering candidates (plan1.7 §16 to be added separately):** Suricata SID:1000101 (cross-realm TGS-REQ with corrupted PAC auth-data), Elastic KQL (WinSec 4826 + cross-forest trust correlation), Zeek notice (kerberos.log inter-realm TGT corruption).
- **Defense recommendations (per GhostWolfLab + Microsoft):**
  - **Enable SID filtering** on all cross-forest trusts (CRITICAL — closes attack)
  - Force PAC validation: Group Policy → `HKLM\System\CurrentControlSet\Services\Kdc\Parameters\KdcValidatePac = 1`
  - Monitor WinSec 4826 events (rare in healthy environment — should alert on any)
  - ESAE (Enhanced Security Admin Environment) for high-priv accounts
- **Status:** ⏳ Pending — needs custom Rubeus build with `/corruptSignature` flag, OR `skipjack_forge.py` Python implementation per blog pseudocode. Test in lab after current Phase 8 (Golden Ticket) verified.
- **Cross-references:** Item #66 Forest Trust SID Filtering (root cause fix), Item #67 CVE-2020-0665 Trust Bypass, Item #76 Onelogon (different vuln class but similar outcome), Phase 8 current (Golden Ticket method), Plan 1.7 §16 (detection engineering).
- **Workflow note (2026-06-24 session 4):** Per user direction, scope was analyze + 3 campaign docs + CHANGELOG/AGENTS. No PoC exists (blog provides pseudocode only — `skipjack_forge.py` is conceptual). Custom Rubeus build required to test. Detection rules held for plan1.7 §16.

**Current Session (2026-06-24 — Session 3 — CVE-2026-41089 PoC Integration):**
- **PoC cloned from https://github.com/0xABCD01/CVE-2026-41089** (0xABCD01, 171 stars, 60 forks, MIT license). 4 files, 18 KB total. `poc.py` is 299 lines, Python 3.8+, no third-party deps.
- **Vulnerability:** Windows Netlogon CLDAP Stack Buffer Overflow (CVSS 9.8 CRITICAL, CWE-121). `NlGetLocalPingResponse` allocates 528-byte stack buffer; `NetpLogonPutUnicodeString` receives max length in bytes but treats it as WCHAR count → 2x overflow. CLDAP "User" field (130 wchars) overflows buffer → LSASS crash → DC reboot in ~60s. **No authentication required, single UDP/389 packet.**
- **Affected systems (all 3 CADRE DCs presumed vulnerable):** Server 2025 fixed in build 10.0.26100.32772. Other builds: 2016 (10.0.14393.9140), 2019 (10.0.17763.8755), 2022 (10.0.20348.5074), 2022 23H2 (10.0.25398.2330), 2012/2012 R2 (ESU-only).
- **Files updated (4 total — focused scope per user direction):**
  - **`docs/internal/references/sources/cve-2026-41089/`** — PoC cloned (4 files, README.md, LICENSE, poc.py, .gitignore). Source-only, ready to execute from Kali.
  - **`attack-matrix/Campaign_suggestions.md`**: Item #33 promoted from ⏳ Pending to 🆕 READY. Full entry rewritten with PoC source (0xABCD01), vulnerability mechanism, affected systems table, pre-test snapshot requirement, 3-phase test plan from Kali, detection rules, mitigation, cross-references to #65 Zerologon Alternative (superseded) and #76 Onelogon Zero-Channel. Summary table, Phase Mapping, Testing Checklist, Tier 3 Summary, Cross-Reference Index, counts, and footer updated.
  - **`attack-matrix/CAMPAIGNS.md`**: New "G — Pre-Auth DC Exploits (Standalone)" section added after F-Supply-Chain. Full entry for CVE-2026-41089 with pre-test checklist (snapshot + patch level check), 3-phase test plan, expected behavior for vulnerable vs patched, telemetry fingerprint, detection rules (proposed Suricata SID:1000100 for oversized CLDAP User attribute), post-test cleanup (`Reset-ComputerMachinePassword`), mitigation.
  - **`attack-matrix/CAMPAIGNS-METADATA.md`**: New "Mechanics: G-1 — CVE-2026-41089 Netlogon CLDAP Stack Buffer Overflow" section after WT095 Onelogon. Status 🆕 READY — UNTESTED. Full 8-part template: why it works, attack commands, success/failure modes, CADRE-specific notes (test target = dc02 FIRST), telemetry fingerprint, detection engineering, common pitfalls, Wireshark field reference, 12-item reproduction checklist.
- **Pre-test checklist (CRITICAL — don't crash a production DC):**
  1. Snapshot dc01, dc02, dc03 (VMware `vmrun.exe snapshot`)
  2. Verify DC patch level: `Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name CurrentBuild, UBR` (need UBR < 32772 on Server 2025)
  3. Test target = **dc02 FIRST** (child DC, less critical than dc01)
  4. UDP/389 reachable from Kali (`nmap -sU -p 389 <dc_ip>`)
  5. Notify team DC will be down ~60 seconds during test
  6. Prepare for `Reset-ComputerMachinePassword` cleanup if needed
- **Detection engineering candidates (plan1.7 §17 to be added separately):** Suricata SID:1000100 (oversized CLDAP User attribute), Zeek `cadre-cldap.zeek` (new script), Elastic KQL — WinSec 1000 with netlogon.dll SourceName.
- **Cross-references:** Item #65 Zerologon Alternative (superseded), Item #76 Onelogon Zero-Channel (different Netlogon vuln class — single-channel NRPC bypass vs CLDAP stack overflow), Plan 1.7 detection engineering.
- **Workflow note (2026-06-24 session 3):** Per user direction, focused addition only — clone PoC + update 3 campaign docs + CHANGELOG/AGENTS. No new analysis doc created. PoC cloned to `docs/internal/references/sources/cve-2026-41089/` per existing pattern (UnCanny, Project NightCrawler, KDS Root Key references). Detection rules held for plan1.7 §17.
- **Next:** Test execution gated on user running the PoC. Once user confirms dc02 is vulnerable + crash captured + telemetry recorded, update CAMPAIGNS-METADATA.md from [READY — UNTESTED] to [TESTED — VULNERABLE] or [TESTED — PATCHED] with actual telemetry fingerprints.

**Current Session (2026-06-24 — Session 2 — Modern AD Attack Tool Landscape + NetExec/Bark Research + Campaign Tool Updates):**
- **Comprehensive AD attack tool research** completed: `docs/internal/references/ad-tools-landscape-2026-06-24.md` (~30 KB, 10 sections, 60+ tool inventory). Full tool audit per AD attack lifecycle phase (Phase 0-8 + Plan 11).
- **NetExec confirmed (v1.5.1, Feb 23 2026):** Replaces CrackMapExec (abandoned Sep 2023). 10 protocols (SMB/LDAP/MSSQL/WinRM/WMI/SSH/RDP/FTP/NFS/VNC), 16+ dump modules, native Windows binary, 3 new dump methods added in 2025-2026 (Token Broker Cache for Azure/M365, BackupOperator, NFS auth). https://github.com/Pennyw0rth/NetExec
- **Bark definitively identified as BARK (BloodHound Attack Research Kit):** https://github.com/BloodHoundAD/BARK by Andy Robbins / SpecterOps (BloodHound co-founder). PowerShell, **Azure/Entra ID ONLY** — no on-prem AD functionality. User's "azure only i think" memory was correct. 80+ functions for token management, Entra enumeration, AzureRM enumeration, Intune enumeration, abuse functions, meta-testing. Companion to bloodyAD (same author CravateRouge). Maps to Plan 11 only.
- **7 new items added to Campaign_suggestions.md (#90-96):**
  - **#90 NetExec (nxc)** — CrackMapExec replacement, cross-cutting Phases 0-5
  - **#91 bloodyAD v2.5.4** — already adopted (update version for dMSA + ACL helpers)
  - **#92 Certipy v5.1.0** — already adopted (update version for ESC17 + golden cert)
  - **#93 DonPAPI v2.0+** — Remote DPAPI credential harvesting (12+ collectors)
  - **#94 lsassy v3.1.16** — Remote LSASS dump (15+ methods)
  - **#95 KrbRelay + KrbRelayUp** — LPE via Kerberos relay (no-CVE by-design bypass)
  - **#96 BARK** — Azure/Entra ID abuse validation (Plan 11 only)
- **CAMPAIGNS.md updated (5 changes):**
  - **Lab topology diagram** — Kali tool list updated to include `nxc`, `lsassy`, `DonPAPI`
  - **Phase 0 Step 0.5 — NetExec Quick-Recon** (new) — 10-protocol recon section
  - **Phase 3.5 3.5F-alt — Remote LSASS Dump via lsassy** (new)
  - **Phase 3.5 3.5F-dpapi — Remote DPAPI Harvesting via DonPAPI** (new)
  - **Phase 3.5 3.5N — BARK bridge to Plan 11** (new) — after 3.5M adconnectdump
- **CAMPAIGNS-METADATA.md updated (4 new Mechanics sections):**
  - **Phase 0 Step 0.5 — NetExec Quick-Recon** [READY — UNTESTED]
  - **Phase 3.5 3.5F-alt — lsassy v3.1.16** [STUB — UNTESTED]
  - **Phase 3.5 3.5F-dpapi — DonPAPI v2.0+** [STUB — UNTESTED]
  - **Phase 3.5 3.5P — KrbRelayUp LPE** [STUB — UNTESTED]
- **Recommended update order for next campaign iteration:**
  1. Phase 0 — `nxc smb/ldap/mssql` quick-recon (low risk, high value)
  2. Phase 3.5 — `lsassy` + `donpapi` modules via NetExec
  3. Phase 2 — `bloodyAD` (already in, update version)
  4. Phase 5 Branch B — `Certipy` (already in, update for ESC17)
  5. Phase 5 Branch 3.5 — `KrbRelayUp` + `Whisker` for LPE + Shadow Creds
  6. Phase 1 — `nxc winrm/ssh/ftp/vnc` modules for protocol coverage
  7. Phase 5 Coercion — Migrate to `Coercer`; await Onelogon (Aug 2026) PoC
  8. Plan 1.7 — Run `Locksmith` + `certipy find` as defender view after each Phase 5 attack
- **Confirmed deprecated/absorbed tools (do NOT use in new docs):** `crackmapexec` (use `nxc`), `Certify.exe` (use `Certipy`), `aclpwn.py` (absorbed into bloodyAD + Certipy + Impacket), `pyWhisker` (absorbed into `Certipy shadow auto` + `Whisker.exe`).
- **Counts updated:** 77 → 86 items (24 ✅ / 51 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref / 4 🆕). Tier 3 total: 19 → 26.
- **Held (per user scope):** External references #123-137 update held (tools to add to `docs/internal/plan01-upgrades/external-references.md`). plan1.7 detection engineering for new tools (NetExec rate-limit KQL, KrbRelayUp 4742 detection, DonPAPI 4663 DPAPI detection) held.
- **Workflow note (2026-06-24 session 2):** Per user clarification, scope was narrowed to 3 campaign docs + CHANGELOG.md + AGENTS.md. external-references.md held for next session. The new analysis doc at `docs/internal/references/ad-tools-landscape-2026-06-24.md` is the source of truth for the 60+ tool inventory.

**Current Session (2026-06-24 — Onelogon WOOT 2026 Paper Analysis + Campaign Updates):**
- **Vulnerability:** MS-NRPC's single-channel variant (over SMB/445 via `\PIPE\netlogon`) was **not covered by the post-Zerologon hardening**. The hardening was only added to multi-channel NRPC (DC-to-DC replication). Single-channel NRPC still accepts pre-Zerologon non-secure-RPC calls.
- **Two attacks demonstrated:**
  - **Section 5.2 Zero-Channel:** Call `NetrServerPasswordSet2` against target DC machine account → set DC machine password to attacker-known value → DCSync → KRBTGT → full domain takeover in 1 RPC call.
  - **Section 5.1 AES-CBC8 Downgrade:** Compute hash of ANY password (machine, KRBTGT, user) offline via RFC 4753 weak DES challenge-response.
- **CADRE applicability: HIGH.** All 3 CADRE DCs (dc01/dc02/dc03) presumed vulnerable. Author tested on Server 2022 (latest patches); Server 2025 not explicitly tested but the single-channel path is unchanged since 2016.
- **Maps to existing campaign:** Chains Phase 5 WT017 (MS-RPRN PrinterBug coercion — 12 Suricata SID:1000050 fires confirmed) → captured DC machine account NTLMv2 → Onelogon Zero-Channel → DCSync → Golden Ticket. Provides shortcut to Phase 6/7 without needing Kerberos ticket forgery or RBCD setup.
- **Files updated (5 total — focused scope per user direction):**
  - **`attack-matrix/Campaign_suggestions.md`**: New top-level section "Onelogon — Single-Channel NRPC Authentication Bypass (WOOT 2026, 2026-06-24)" added before "Next Actions / Parallel Tracks". Items #76 (Zero-Channel, Phase 5→7) and #77 (AES-CBC8, Phase 3.5→7) fill the #76-77 reserved gap. **Supersedes item #65 (Zerologon Alternative "patched on Server 2025")** — single-channel NRPC bypass proves Zerologon-class attacks still viable in 2026. Counts: 75 → 77 items (22 ✅ / 48 ⏳ / 4 🔬 / 1 ⏭️ / 2 ref). Updated 5 tables (summary, Phase Mapping, Testing Checklist, Tier 3 Summary, Cross-Reference Index) and footer.
  - **`attack-matrix/CAMPAIGNS.md`**: New row in Phase 5 "Alternative Coercion Techniques" table for WT095 Onelogon Zero-Channel (after WT094 UnCanny). New full Mechanics section in Phase 5 with 5-step attack chain, 5 downstream routes, detection rules (Suricata SID:1000098, WinSec 4662 WriteProperty on DC unicodePwd, Zeek named-pipe netlogon notice), and critical `Reset-ComputerMachinePassword` cleanup step.
  - **`attack-matrix/CAMPAIGNS-METADATA.md`**: New stub Mechanics section "Mechanics: WT095 — Onelogon Zero-Channel (Single-Channel NRPC Bypass)" after "Mechanics: WT018-020 — Non-functional Coercion". Status ⏳ PENDING — gated on author PoC release post-WOOT 2026. Includes predicted attack interface, telemetry fingerprint, detection engineering candidates (Suricata SID:1000098, Zeek `cadre-nrpc.zeek`, Elastic cadre-006), Wireshark field reference, and 11-item reproduction checklist.
  - **`CHANGELOG.md`**: New entry at top of `[Unreleased]` section. Full breakdown of vulnerability mechanism, CADRE applicability, files updated, detection engineering candidates, pre-test verification, cleanup requirements, and cross-references.
- **Detection engineering candidates (plan1.7 §16 to be added separately — NOT touched in this session per user scope):** Suricata SID:1000098 (single-channel NRPC anomaly), Zeek `cadre-nrpc.zeek` (new script), Elastic cadre-006 (4662 WriteProperty), Suricata SID:1000099 (AES-CBC8 cipher).
- **Pre-test verification checklist (do BEFORE author PoC release):**
  1. Snapshot dc01, dc02, dc03 (VMware `vmrun.exe snapshot`)
  2. Confirm SMB/445 reachable from Kali to all 3 DCs
  3. Confirm `DC01$`/`DC02$`/`DC03$` machine account names via Phase 0 Kerberos enum
  4. Verify WT017 PrinterBug still works (12 Suricata SID:1000050 fires baseline)
  5. Prepare `Reset-ComputerMachinePassword` cleanup script
- **Why supersedes #65 (Zerologon Alternative):** Item #65 (Dirk-jan's 2020 Zerologon variant) marked "⏳ Pending — study reference (patched on Server 2025)". Onelogon invalidates that conclusion — original Zerologon is patched but the single-channel NRPC variant is the same protocol path clients have always used, and Microsoft hardening doesn't cover it.
- **Impact on hardened variant track (Track A):** Likely survives RC4 enforcement + AES-only Kerberos since Onelogon is pre-Kerberos (pure NRPC over SMB).
- **Next:** Wait for author PoC release (expected Aug 2026 post-conference). When released:
  1. Clone to `docs/internal/references/sources/onelogon/`
  2. Create `docs/internal/references/onelogon-analysis.md` (full breakdown)
  3. Add external reference #123+ in `external-references.md`
  4. Fill CAMPAIGNS-METADATA.md Mechanics section with actual telemetry
  5. Deploy plan1.7 §16 detection rules
  6. Execute WT095 in lab (dc02 first — child domain DC, less critical than dc01)
  7. Update CAMPAIGNS.md WT095 status from ⏳ to ✅
- **Workflow note (2026-06-24):** Per user clarification, scope was narrowed to 3 campaign docs + CHANGELOG.md + AGENTS.md. Plan1.7 detection engineering work held until after main campaign testing (existing Track A/B/C workflow). External-references.md update also held.

## Mini-Projects & Integrations

**Every external project and workspace root is indexed in [`docs/internal/registry.md`](docs/internal/registry.md)** — that file is the **multi-repo index** (CADRE + CADRE-Courses + CADRE-Integrations + sister repos). Read it first when working on any Plan.

**12 active integrations + 3 sister repos + knowledge corpus:**

| Side | Integration | Plan | Status |
|---|---|---|---|
| **DFIR side** | [DFIR-Nexus (OUR TOOL)](docs/internal/integrations/dfir-nexus.md) + [release roadmap](docs/internal/integrations/dfir-nexus-source-assessment-3-roadmap.md) | Plan 7 (Agentic) | ✅ **v1.0.0 E.0 Constellation COMPLETE** — 96 MCP tools, 475 tests, 72 smoke. Push ingest, browser extension, export parity, integrations. Production hardening shipped. **Next:** CADRE Ansible wiring on `provisioning`. Docs: `E0-CONSTELLATION.md`, `D0-STELLAR.md`. |
| DFIR side | Predecessor MCP suites (features merged into DFIR-Nexus) | Plan 7 | ✅ Merged — see assessment docs in `docs/internal/integrations/` |
| **Offensive side (agentic)** | [**RedStrike**](docs/internal/integrations/red-strike.md) — SSoT `RedStrike\` · pin `tools/red-strike/` | Plan **1.1** ✅ + Plan 1 Track H | ✅ **0.5.0** — CampaignOrchestrator (spine + A–D/G/sql-ai + E/F streams), typed builders, HITL, MCP/API. P11.6 dry-run on `.60`. Workflow: `Campaign/Red-Strike-workflow.md`. Live `--execute` operator-gated. |
| **Offensive side** | [C2Stack + Loki](docs/internal/integrations/c2stack-loki.md) (C2 + payload) | Plan 10 (C2+Emulation) | ⏳ Pending |
| Reference | [Impacket-IoCs](docs/internal/integrations/impacket-iocs.md) (97 mentions) | Plans 1, 6, 7 | ✅ Adopted |
| Reference | [NPM-Threat-Emulation](docs/internal/integrations/npm-threat-emulation.md) (Shai-Hulud) | Plan 0.8 → fold into 1.8 | ⏳ Deployed |
| Reference | [ohmypcap](docs/internal/integrations/ohmypcap.md) (Kali PCAP tool) | Plan 0.7 → fold into 1.7 | ⏳ Pending |
| Reference | [forest-trust-tools-master](docs/internal/integrations/forest-trust-tools.md) | Plan 8 (Forest Trust) | ⏳ Reference |
| AI Forensics | [asftriage (OALABS)](docs/internal/integrations/asftriage.md) (Claude Code forensics) | Plan 9 | ✅ EX-48 added |
| **Knowledge corpus** | **CADRE-Courses** (`C:\STUDY\Github\CADRE-Platform\CADRE-Courses\`) — SANS, RTO, ebooks, cert labs | Plans 0.7–1.8, 0.9, 11 | 🔗 Reference (~36k files) — cite paths, never copy into CADRE git |
| **Sister repo** | CADRE-RevEng (`C:\STUDY\Github\CADRE-Platform\CADRE-RevEng\`) | Plan 0.9 (Malware RE) — **v2.0 COMPLETE**; v3 in progress (RAG + Z3 + browser verify). **Integration plan with DFIR-Nexus written 2026-07-04** (5-step plan: output push + RAG adapter + TI cache + Ollama embedder + langgraph agent). Gated on **V3.18** (DFIR-Nexus sharing decision). | ✅ v2.0 complete; bridge v3 (formally planned) |
| Sister repo | CADRE-Eva7ion (`C:\STUDY\Github\CADRE-Platform\CADRE-Eva7ion\`) | "out of tree" | 🔬 Active |
| Sister repo | CADRE-DarkAI (`C:\STUDY\Github\CADRE-Platform\CADRE-DarkAI\`) | Plan 12 | 📋 Planning |

**Path convention:** External source repos live in `C:\STUDY\Github\CADRE-Platform\CADRE-Integrations\` (read-only). Course material lives in `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\` (reference only). CADRE references them by path — no duplication. Locally cloned small references live in `docs/internal/references/sources/` (project-nightcrawler, uncanny). Analysis docs (kds-root-key-attacks.md, project-nightcrawler-analysis.md) live in `docs/internal/references/` at the same level.

**RedStrike relationship to CADRE campaign (updated 2026-07-26):**
- **Main campaign** (`CAMPAIGNS_v3.md` + runbooks) = manual, reproducible, ground truth for telemetry
- **RedStrike** (SSoT `RedStrike\` · pin `tools/red-strike/`) = CampaignOrchestrator + agentic AD/ADCS toolset; CADRE supplies graph/seeds/profiles
- **Plan 1.1** = ✅ closed (M0–M5 + P11.6 dry-run). Plan 1 catalogs telemetry from automated + manual runs
- **DFIR-Nexus** = agentic DFIR automation (Plan 7)
- Pair with manual campaign via `tracker.md` / Plan 1 grid
- Live path on provisioning: `~/RedStrike` + `~/CADRE`
- **Deprecated:** `CADRE-Strike/` — do not edit

**Rule:** When starting work on any Plan, read the relevant 1-pager in `docs/internal/integrations/` first to know which external projects apply.

**DFIR-Nexus E.0 Constellation (2026-06-22):**
- **v1.0.0** at `tools/dfir-nexus/` — assessment roadmap A.0→E.0 complete
- **E.0.1** `push/` — per-case tokens, `dfir-nexus push-server`, MCP `case_push_token`
- **E.0.2** `tools/dfir-nexus-extension/` — MV3 screenshot scaffold (`EXTENSION.md`)
- **E.0.3** `integration/notifications.py` — env-only webhooks, MCP `integration_notify`
- **E.0.4** export formats (CSV/DOCX/ZIP/snapshot/SVG) + `case_knowledge_graph` MCP
- **Hardening:** VQL policy, path sandbox (`DFIR_NEXUS_DATA_ROOTS`), audit secret, gateway auth, portal password + rate limit, HITL edge cases, push SSRF fix
- **Metrics:** 96 MCP tools, 475 pytest, 72 smoke — all green
- **Production env vars:** `DFIR_NEXUS_AUDIT_SECRET`, `DFIR_NEXUS_DATA_ROOTS`, `DFIR_NEXUS_PORTAL_PASSWORD`, `DFIR_NEXUS_VR_ALLOW_ADHOC_VQL`, `DFIR_NEXUS_PUSH_TOKENS`, gateway `bearer_token` (non-loopback)
- **Next:** Ansible playbook on provisioning VM, live SSH connectors, E2E against CADRE lab telemetry

## Commands

```powershell
python cadre.py check                     # Pre-flight: admin, RAM ≥36GB, disk ≥150GB, Vagrant/VMware
python cadre.py install                   # Interactive full deploy (prompts for extensions, verbosity, vm-dir)
python cadre.py install -y                # Non-interactive: all extensions, -vv verbosity, default dir
python cadre.py install -e elk-fleet      # Install with one extension (repeatable -e)
python cadre.py install --from-phase 02-objects  # Resume failed deploy from a phase
python cadre.py status / start / stop / destroy
```

- **No arguments** → interactive menu. CLI args → argparse path.
- The cadence is `check` → `install` → verify. `install` is idempotent; re-running picks up from already-provisioned VMs.
- `--from-phase` requires a phase ID from `cadre.py` `PHASES` list (e.g. `02-ad-objects`, `04-vulnerabilities`).
- Extension playbooks (12-elk-fleet, 13-net-monitor, 14-velociraptor) are **skipped in the main loop** and run only when selected via `-e`.

## Ansible

- Playbooks live in `ansible/playbooks/` (numbered `00-` through `15-`). Each has a `-verifyOnly.yml` counterpart.
- Ansible runs **on the provisioning VM**, not locally. `cadre.py` SCPs `ansible/` + `config.json` then SSHs in.
- Collections (pinned): `ansible.windows==3.5.0`, `community.windows==3.1.0`, `microsoft.ad==1.10.0`
- `ansible/ansible.cfg`: `roles_path = roles/`, `host_key_checking = False`
- Extension playbooks are self-contained — templates inlined, VR artifacts under `ansible/files/vr-{artifacts,hunts}/`. No `extensions/` dir used at runtime.

## Testing

- `tests/unit/` and `tests/integration/` are **empty** — no test framework exists.
- `tools/deploy-harness/test_config_sync.py` — drift check: config.json vs playbook-derived state. `python tools/deploy-harness/test_config_sync.py`
- `tools/regen-config/regen.py` — regenerates `lab/data/config.json` from Ansible role files.
- Internal test harness at `docs/internal/tools/deploy-harness/test_plan0.py` (gitignored, 127 checks — 124 pass; the 3 non-passing check for user-provided installer media SCCM/SQL, gitignored).
- **EDR agent (2026-05-31):** Elastic Defend behavioral alerts (`logs-endpoint.alerts-*`) require **Platinum license** — Basic license silently downgrades all protections to `mode: off`. Event telemetry (`logs-endpoint.events.*` — 14 indices, ~39 MB) flows freely. Playbook `12-elk-fleet.yml` updated: Platinum protections `mode: off`, malware `mode: detect`.
  - **Detection strategy:** Pre-built SIEM rules + source matrix (P0c-0 decides PRIMARY per attack) + cadre-* gap rules + cadre-e* endpoint rules + Suricata/Zeek. NO EDR behavioral alerts.
- **Defender disable fixed (2026-06-02):** Server 2025 Tamper Protection silently overrode all previous disable attempts. Fixed by disabling TamperProtection first, then stopping WinDefend service, then applying registry + MpPreference + SpyNet blocks. Verified on all 5 Windows VMs. See `04-vulnerabilities.yml` for the full task.
- **D.0.2 "Stellar" VR framework — COMPLETE (2026-06-05):**
  - **`vr/` module** — catalog (10 hunts + 5 artifacts), `VRService`, CADRE MCP bridge, 9 MCP tools
  - **LangGraph:** EndpointAgent runs `vr_run_hunt` from technique → hunt mapping
  - **CADRE .51 defaults** — `192.168.77.51` API/GUI/MCP env vars; mock without API key
  - **Tests:** 439 pytest + 64 smoke
  - **Next:** D.0.3 MITRE Navigator v4.5 + threat actors + RBA
- **D.0.1 "Stellar" TI providers — COMPLETE (2026-06-05):**
  - **Core loop (default):** abuse.ch (ThreatFox, Malware Bazaar, URLhaus, YARAify) + self-hosted MISP — `ti_lookup` / `ti_fanout` / NetworkAgent never auto-call optional APIs
  - **Optional (explicit MCP tool or `providers=[...]` + API key):** OTX (free), Shodan (free tier), VirusTotal, AbuseIPDB, CrowdStrike (OAuth2 live)
  - **LangGraph:** `ti/enrich.py` + NetworkAgent core TI enrichment
  - **Gateway:** all 12 TI MCP tools on in-process backend
  - **Tests:** 431 pytest + 60 smoke
  - **Docs:** `tools/dfir-nexus/docs/D0-STELLAR.md`
  - **Next:** D.0.2 full VR framework, D.0.3 MITRE Navigator v4.5 + threat actors + RBA
- **C.0 "Voyager" COMPLETE (2026-06-05):**
  - **C.0.1 RAG** — `tools/dfir-nexus/src/dfir_nexus/rag/`; `dfir-nexus data download-rag`; ~22K records; MCP: `rag_search`, `rag_list_sources`, `rag_stats`
  - **C.0.2 Triage** — `tools/dfir-nexus/src/dfir_nexus/triage/`; `dfir-nexus data download-triage`; ~2.7M baseline paths; 13 `triage_*` MCP tools
  - **C.0.3 Analysis bonus** — deobfuscation, LLM anonymizer, evidence GraphRAG, EZ tool wrappers; Volatility 3 importer (33rd source)
  - **420 pytest + 57 smoke steps** — see `tools/dfir-nexus/docs/C0-VOYAGER.md`, `DATA.md`
  - **No upstream repo references** in DFIR-Nexus code/docs — production data via CLI download (`DFIR_NEXUS_*_RELEASE_REPO`)
  - **Next:** D.0 Stellar; CADRE Ansible wiring on provisioning (separate)
- **B.0 "Pathfinder" COMPLETE — hardening slices (2026-06-05):**
  - B.0.1 DRAFT/HITL + B.0.2 LangGraph agents in `langgraph/agents/*.py` (prior)
  - B.0.3 HTTP gateway — in-process + HTTP + **stdio** backends, lazy connect, **idle reaper**
  - B.0.4 Examiner Portal — 8-tab SPA, **in-browser approve/reject**, timeline/evidence/hosts APIs
  - B.0.5 Plaso, Velociraptor MCP, SigmaHQ, MITRE Navigator, **Sigma kql + spl** (`sigma_translate`)
  - Velociraptor: `create_velociraptor_client()` — HTTP for remote endpoints, mock for localhost; `DFIR_NEXUS_VR_USE_MOCK` override
  - **360 pytest + 52 smoke steps** at B.0 ship (see `B0-PATHFINDER.md`); superseded by C.0 metrics above
  - **CADRE bridge:** `attack-matrix/DFIR-Nexus-Pioneer-workflow.md` (Phase 3.5 active). **RevEng → main CADRE bridge** (`publish_to_cadre.py` / `intake-from-cadre.py`) **DEFERRED to v3** — see `CADRE-RevEng/Tools/v2-deploy/MTA-CADRE-SHARING.md` + `plan_v2-CADRE-integration.md`.
  - **Source project assessment completed** — deep evidence-first inventory of all 3 source projects (Security-Detections-MCP, DFIR-Companion, DFIR-mcp suite) + feature-by-feature gap mapping. **250+ unique tools / 100+ artifact types / 100+ MITRE techniques / 50+ Event IDs.**
  - **SANS tools integration completed** — separate plan at `docs/internal/integrations/dfir-nexus-sans-tools-integration.md` mapping FOR500 (77 tools) + FOR508 (100+ tools) + FOR608 (100+ tools) → DFIR-Nexus releases. **Total: ~250 unique tools across 3 SANS courses.**
  - **Release naming changed** to avoid CADRE Plan overlap: **A.0 Pioneer (current) → B.0 Pathfinder → C.0 Voyager → D.0 Stellar → E.0 Constellation**. Letter prefixes (A, B, C, D, E) are unique to DFIR-Nexus — no conflict with CADRE Plan 0.7/0.8/0.9/1.0.
  - **Vision v3 (per user 2026-06-22)**: DFIR-Nexus is the **massive DFIR section of CADRE** — a **comprehensive, industry-leading DFIR solution** that:
    - Serves **standalone + agentic + CADRE-integrated** modes (3 modes, all first-class)
    - Borrows the **best of 3 predecessor projects** (DFIR-mcp suite, Security-Detections-MCP, DFIR-Companion)
    - **Integrates our forensic tooling** (KAPE, Plaso, Hayabusa, Timesketch, WinPMEM, AVML, Volatility 3, Velociraptor MCP) + **SANS course tools** (all Eric Zimmerman EZ tools, MFCMAPI, OneDriveExplorer, Hindsight, mac_apt, TSK, CyLR, etc.)
    - **DFIR-mcp is the original predecessor** (per user); Security-Detections-MCP was assessed; DFIR-Companion was added third
    - **Plan 7 spine** — `core-plan.md` A pillar: LangGraph multi-agent graph → DFIR-Nexus → multi-LLM router
    - **6 specialized agents**: Timeline (Hayabusa/Plaso), Endpoint (Velociraptor MCP), Network (Zeek/Suricata/Arkime), Alert (EDR clustering), Cloud (Entra/Azure), Synthesis (record_finding draft)
    - **Borrow all that's relevant to core DFIR work** — comprehensive, not minimal
  - **Design principle v3**: DFIR-Nexus is **BOTH a tool AND an agentic framework**. LangGraph + Velociraptor MCP + multi-LLM router are all in scope. SANS industry practices (Sigma rules, Velociraptor VQL artifacts, Plaso, KAPE) are core.
  - **3 structural gaps** (B.0 "Pathfinder" — all ✅ closed 2026-06-05):
    1. ~~No DRAFT/HITL approval workflow~~ → B.0.1 + Portal approve/reject UI
    2. ~~No HTTP gateway aggregation~~ → B.0.3 stdio + idle reaper
    3. ~~No browser-based Examiner Portal~~ → B.0.4 live case APIs
  - **Documents created/updated** (all in `docs/internal/integrations/`):
    - `dfir-nexus-source-assessment.md` (Part 1: Inventory + Design Principle v2)
    - `dfir-nexus-source-assessment-2-mapping.md` (Part 2: Feature mapping)
    - `dfir-nexus-source-assessment-3-roadmap.md` (Part 3: Roadmap with new letter-based naming)
    - `dfir-nexus-sans-tools-integration.md` (NEW: SANS tools mapping, ~250 tools)
    - `dfir-nexus-codebase-review.md` (code-level verification)
  - **Study guide** at `tools/dfir-nexus/docs/STUDY-GUIDE.md` — full how-to-use guide.
  - **All 5+ docs updated** to reference the assessment + SANS plan + new naming.

- **Previous Session (2026-06-20 — DFIR-Nexus Doc Cleanup + Local Commit):**
  - **Local git init + commit** for DFIR-Nexus at `C:\STUDY\Github\CADRE-Platform\CADRE\tools\dfir-nexus\` — commit `5b37837` on `master`. No push, per user instruction.
  - **`.gitignore` updated** to exclude runtime `data/` (cases.db), `*.log`, `secrets.*`, `*.edb`, `*.db-shm`, `*.db-wal`, `smoke_test_data/`.
  - **Doc polish (in `tools/dfir-nexus/docs/`):**
    - **NEW `SUMMARY.md`** — top-level feature summary (read first).
    - **`ARCHITECTURE.md`** updated to reference SUMMARY.
    - **Phase docs (`PHASE1.md`–`PHASE6.md`)** all consistent, all cross-reference each other.
    - **`README.md`** 📚 Documentation section now lists all 8 docs (SUMMARY + ARCHITECTURE + PROVIDERS + 6 phase docs + improvement plan).
  - **Doc polish (parent CADRE repo):**
    - **`docs/internal/integrations/dfir-nexus.md`** rewritten as v0.6.0 release 1-pager with full stats table, module structure, integration points.
    - **`docs/internal/integrations/dfir-nexus-improvement-plan.md`** → **ARCHIVED 2026-06-22** (moved to `archive/dfir-nexus-improvement-plan-archived-2026-06-22.md`). Superseded by `dfir-nexus-source-assessment-3-roadmap.md`. Roadmap section converted from "to-do" to "completed". All 6 phases marked ✅ DONE.
    - **`docs/internal/registry.md`** DFIR-Nexus row: 🔨 Building → ✅ v0.6.0 FEATURE COMPLETE with local git path.
    - **`CHANGELOG.md`** new top-level `## [Unreleased]` section: "DFIR-Nexus v0.6.0 — FEATURE COMPLETE" with full per-phase breakdown and metric table.
    - **Mini-Projects table** status updated: 🔨 Building → ✅ v0.6.0 FEATURE COMPLETE.
  - **Final verification:** `pip install -e ".[dev,detection,evtx,prefetch]"` succeeded, `pytest tests/` → 311 passed, `python smoke_test.py` → All 42 steps PASSED. Multiple sessions of all-green runs in this cleanup session.
  - **LSP false positives** persist for `dfir_nexus.*` imports and `VisionError` — known false positive, resolves after `pip install -e .` (user task).
  - **Next (held):** CADRE platform wiring (Ansible playbook on `provisioning`, live SSH connectors, end-to-end real-data analysis).

- **Previous Session (2026-06-20 — DFIR-Nexus Phase 6 Integration — FEATURE COMPLETE):**
  - **Phase 1, 2, 3, 4, 5, 6 COMPLETE** for DFIR-Nexus at `C:\STUDY\Github\CADRE-Platform\CADRE\tools\dfir-nexus\` (NOT a git repo yet — user to init).
  - **Phase 6 — Integration (last phase):**
    - **Velociraptor monitoring** (`dfir_nexus.integration.vql_runner`): `VQLRunner` long-running VQL query runner with `MockVelociraptorClient` and `HTTPVelociraptorClient`. Configurable interval, retry logic, result handler callback.
    - **Case export** (`dfir_nexus.integration.case_export`): 4 formats — `export_to_json()`, `export_to_markdown()`, `export_to_html()` (styled), `export_to_stix()` (STIX 2.0 with case as custom object + IoCs as indicators). `CaseExporter` orchestrator with file-write support.
    - **AI vision** (`dfir_nexus.integration.vision`): `VisionAnalyzer` with LLM-powered image analysis. Base64 image encoding, IoC extraction regex (IPv4/SHA/URL/domain/registry/MITRE/GUID/BTC/IPFS), graceful failure on no LLM.
  - **25 new tests** in `test_integration.py` — all pass
  - **Smoke test extended to 42 steps** (was 38) — all pass
  - **Docs:** `tools/dfir-nexus/docs/PHASE6.md` (NEW). README updated.
  - **Total MCP tools: 30.** **Total tests: 311.** **Total importers: 31.** **Hayabusa rules: 12.** **Sigma templates: 12.** **vhir subcommands: 6.** **Case export formats: 4.**
  - **DFIR-Nexus is FEATURE COMPLETE.** All 6 phases done.
  - **Done in cleanup session:** git init for dfir-nexus (commit `5b37837`), pytest run (311 passed), smoke_test.py run (42 passed).
  - **Previous Session (2026-06-20 — ASF Triage AI Agent Forensics Exercise):**
  - **OALABS ASF Triage researched** — Vue 3 web app for forensic investigation of Claude Code + Codex CLI session transcripts (`.jsonl`). Client-side only, no data leaves the machine.
  - **EX-48 added to plan1.7-exercises.md** — "AI Agent Forensic Analysis with ASF Triage". 5-part exercise: setup, recon, attack chain reconstruction, IoC extraction, redaction, detection engineering with Sigma rule.
  - **External reference #122 added** (ASF Triage, OALABS).
  - **Total exercises: 47 → 48.**
  - **Why it matters for CADRE:** Every Claude Code/Codex CLI session I run on this project creates a `.jsonl` transcript at `~/.claude/projects/...`. ASF Triage can audit our own development, investigate insider-threat AI abuse scenarios, and write Sigma rules for agent-assisted attacks. Companion to KDS Root Key attacks (#84-89) — both deal with post-DA "operator did X via AI agent" investigation.
  - **"Make it better" ideas documented in conversation (not in repo):** CADRE-specific redactor patterns (SIDs, NT hashes, gMSA blobs), suspicious-command flagging, MITRE ATT&CK auto-tagging, multi-agent expansion (Cursor/Copilot/Aider), SIEM integration.
  - **Synthetic malicious session:** exercise includes a "generate a sample" workflow — run Claude Code with attack-themed prompts → analyze the resulting `.jsonl`.

- **Previous Session (2026-06-20 — KDS Root Key Attacks Research: Grafnetter TROOPERS26):**
  - **Grafnetter TROOPERS26 talk researched in depth:** KDS Root Key attacks + DPAPI-NG SID Protectors. Author: SpecterOps, DSIternals creator, Shadow Credentials inventor.
  - **Comprehensive analysis doc:** `docs/internal/references/kds-root-key-attacks.md` (30 KB, 300+ lines). All 6 attacks mapped to CADRE phases with DSIternals commands, pre-conditions, and detection engineering.
  - **6 new items added to Campaign_suggestions.md (#84-89):** KDS Root Key Extraction, Golden gMSA Attack, DSRM Password Extract/Set, LAPS Bulk Extraction, Golden dMSA Attack, DPAPI-NG SID Protector Decryption. NOT added to CAMPAIGNS.md per user instruction.
  - **Key insight:** All 6 attacks share one mechanism (KDS Root Key + DPAPI-NG SID Protectors). Zero network signature on the attack — only detection is on the KDS root key dump side.
  - **Testable today (no infra changes):** #84, #85, #86, #87 — need only DA from Phase 6/7.
  - **Testable after small playbook additions:** #88 (dMSA setup), #89-PFX (Branch B sub-technique).
  - **Deferred (need significant infra):** #89-BitLocker, #89-DNSSEC, #89-ASP.NET Core.

- **Previous Session (2026-06-20 — Bookmarks Review + Tier 1 References):**
  - **Analyzed `C:\STUDY\Github\bookmarks.html`** — 3,217 bookmarks, 57 folders, 214 CADRE-relevant across 21 topics, 220 new (not in external-references.md).
  - **Added 11 Tier 1 references (#110-120)** — focused on direct campaign/plan mapping:
    - **Branch A (GPO Abuse):** GPOddity (#110) — Synacktiv's GPO attack via NTLM relaying
    - **Branch B (ADCS):** ADCSKiller (#111), Locksmith (#112), Certify 2.0 (#119), Practice-AD-CS (#120)
    - **Branch 3.5K (WerFault):** ColdWer (#113)
    - **Phase 0/5 (NTLM capture):** Responder (#117), NTLM Relaying 2017 (#116)
    - **WT018 detection:** PetitPotam detection NCC Group (#118)
    - **Plan 11 (Cloud/Entra):** AADInternals (#114), XPN Azure AD Connect (#115)
  - **220 new bookmarks saved for future batch additions** (not added individually to avoid noise).
  - **External references: 109 → 120.**
  - **Future plan:** When revisiting Branch A (GPO Abuse) and Branch B (ADCS), integrate these tools. AADInternals + XPN are required reading when starting Plan 11 (Cloud/Entra) work.

- **Previous Session (2026-06-19 — UnCanny Coerce + LPE 0day + IPv4-Mapped IPv6 Phishing):**
  - **UnCanny repo cloned from https://github.com/0xHossam/UnCanny** (0xHossam, 2026-06-19, 34 stars) to `docs/internal/references/sources/uncanny/UnCanny/` (1.1 MiB, source only). New NTLM coercion primitive + LPE 0day via Windows Store InstallService loose-file AppX registration.
  - **SANS ISC diary 33090 (Xavier Mertens, 2026-06-19) processed:** eBanking phishing via IPv4-mapped IPv6 URL bypasses regex-based URL parsers.
  - **External references:** 107 → 109. Added #108 (UnCanny) and #109 (SANS ISC 33090).
  - **Campaign_suggestions.md:** 80 → 83 items. 3 new entries: #81 UnCanny Coerce (Phase 5, ⏳), #82 UnCanny LPE (Phase 3.5, ⏳), #83 IPv4-Mapped IPv6 URL Parser Bypass (Detection Engineering, ⏳).
  - **CAMPAIGNS.md:**
    - **WT094 (UnCanny Coerce)** added to Phase 5 — Alternative Coercion Techniques table. New working coercion primitive alongside WT017 (PrinterBug). Gated on Developer Mode.
    - **3.5N (UnCanny LPE)** added to Branch 3.5. Direct SYSTEM via InstallService. Gated on Developer Mode + Samba.
  - **plan1.7-defense-deepening.md §14 added:** 4 Elastic KQL rules, 3 Suricata rules (SID 1000095-1000097), 1 Zeek script, 2 Sysmon rules, PCAP analysis patterns, coverage scoreboard.
  - **Gating factor:** Developer Mode must be enabled on CADRE VMs. Run via WinRM from Kali: `Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense"`. If = 0, need separate decision to enable in `00-domain-deploy.yml`.
  - **User decision (2026-06-19): "document only, defer test"** — UnCanny and IPv4-mapped IPv6 marked 🔬 Deferred in CAMPAIGNS.md + Campaign_suggestions.md. New Track G added to Parallel Tracks in Campaign_suggestions.md. UnCanny re-evaluation deferred to Track A (Hardened Environment Variant) or after Phase 8 completes. Detection rules in plan1.7 §14 still valid and ready to deploy when needed.

- **Previous Session (2026-06-18 — Phase 0-3.5 Campaign Alignment):**
  - **All Phase 0-3.5 items from Campaign_suggestions.md now adopted into CAMPAIGNS.md** with detailed test steps. Per user: "anything up to phase 3 need to go in campaign, nothing more until we finish them first." Confirmed adoption of 17 Phase 0-3.5 items.
  - **NTLMv1 Rainbow Tables added to CAMPAIGNS.md Phase 2** with full test plan (LmCompatibilityLevel verification, NTLMv1 vs NTLMv2 detection, hashcat mode 5500, post-test hardening).
  - **Study Reference Library section added to CAMPAIGNS.md** — 6 study-ref topics now have entries organized by phase (Phase 3.5 Logon Types + Credential Guard, Phase 4 SharpHound Detection, Phase 7 DCSync, Phase 8 Forest Trust SID Filtering + CVE-2020-0665). Each entry has Why read, Source, Key concepts, Action item.
  - **Campaign_suggestions.md status updated** to reflect actual adopted state: 31 Adopted → 40 Adopted, 41 Pending → 32 Pending. Total 80 unchanged. Updated across 5 tables (summary, per-item, phase mapping, WT#, year/phase).
  - **Phase 5+ items NOT touched** per user: items 11, 12, 14, 21, 23, 25, 26, 29, 30, 32-41, 43-48, 52-58 remain ⏳ for after Phase 3.5 completion.
  - **MiniPlasma work (previous sub-session, same day):** 8 Windows vulnerability PoC repos cloned from `git.projectnightcrawler.dev` → `docs/internal/references/sources/project-nightcrawler/` (45.7 MiB, source-only). Analysis doc: `docs/internal/references/project-nightcrawler-analysis.md`. Items #78-80 (MiniPlasma, GreenPlasma, YellowKey) added to Campaign_suggestions.md as 🔬 Research only.
  - **Next:** ADWS enumeration test from Kali (Phase 0 Step 3) — `curl --ntlm -u 'intern_blue:1nt3rn_Blu3!' http://192.168.77.10:9389/adws/` to confirm auth path works.

- **Previous Session (2026-06-14 — Full SANS Course Integration: 11 Courses + Exercise Docs):**
  - **All 11 SANS courses analyzed** from `CADRE-Courses/sans/pdf_extract/`: SEC503, SEC504, SEC511, SEC555, SEC583 + FOR500, FOR508, FOR509, FOR572, FOR578, FOR608. ~300K lines total.
  - **SEC504 (Hacker Techniques):** 31K lines, 6 sections — IR + attack hybrid. Labs: PowerShell IR, network/memory/malware investigation, Linux Olympics, PowerShell Olympics, CTF. Offensive exercises mapped to CADRE phases.
  - **FOR508 (Advanced IR + Digital Forensics):** 41K lines across 7 books — KAPE triage, Prefetch/ShimCache/AmCache analysis, Volatility memory forensics, Plaso/Timesketch timelines, anti-forensics detection. Labs: APT IR Challenge, Malware Persistence, KAPE Triage, Scaling IR, Memory Forensics, Timeline Analysis, Anti-Forensics.
  - **SEC511 (Continuous Monitoring):** 44K lines, 19 labs — Sysmon, Autoruns, AppLocker, ModSecurity, Merlin C2, honeytokens, DoH, egress analysis, PCAP carving.
  - **SEC555 (SIEM Tactical Analytics):** 41K lines, 21 exercises — Sigma, MITRE ATT&CK, beacon detection, DNS/HTTP/TLS analytics, Windows Event Logs, PowerShell detection, virtual tripwires.
  - **FOR608 (Enterprise IR + Hunting):** 23K lines — Velociraptor hunting, KAPE collection, Plaso timelines, Timesketch, Sigma rules, YARA scanning.
  - **SEC583 (Defensible Architecture):** 8K lines, 7 labs — Scapy packet crafting for IDS testing.
  - **FOR578 (Cyber Threat Intelligence):** 27K lines — MISP, OpenCTI, YARA, Sigma, STIX/TAXII.
  - **plan1.7-exercises.md created:** 45 defense exercises across 5 categories (Network Monitoring, Endpoint Detection, Forensics, Threat Intel, Security Architecture, Purple Team Defense). Sources: SEC503/511/530/555/583/599 + FOR572/500/508/608/578.
  - **plan1.8-exercises.md created:** 31 offensive exercises across 8 categories (Recon, Password/Access, Execution/Lateral, Defense Evasion, Supply-Chain, Web App, Adversary Emulation Pipeline, Adversary Emulation Planning). Sources: SEC504/565/699 + npm supply-chain.
  - **plan1.7 §12 added:** Additional SANS course integration — course inventory, tools to install (13 tools), exercise doc references, implementation phases (~38hr across 7 phases).
  - **Key finding:** Autoruns + Eric Zimmerman tools + KAPE are the 3 most impactful missing tools. Sigma rules are the highest-priority detection gap.
- **Previous Session (2026-06-12 — SANS Network Forensics + Malware-Traffic-Analysis Workflow + Dirk-jan Mollema Research + SEC503/FOR572 Deep-Dive):**
  - **SANS SEC503/FOR572 comprehensive analysis:** Full tool inventory (tcpdump, Wireshark, Snort/Suricata, Zeek, SiLK, passivedns, Arkime, NetworkMiner, Elastic Stack, RITA, p0f, tcpflow, ngrep, pmacct). 20 detection rules/exercises documented in plan1.7 §9.5. 12 SANS labs mapped to CADRE exercises in §9.6. 12 defensive exercise specifications in §9.8. 6 tools to install on monitor VM in §9.7.
  - **plan1.7 §9 completely rewritten:** Now covers DNS tunneling/exfil/NXDOMAIN/passive DNS, NTLM relay/SMB signing/SMBv2/v3 forensics, TLS cert chain/JA3/self-signed, SiLK beaconing pipeline, IDS evasion detection, HTTP/2 forensics, Arkime workflow, NetworkMiner workflow, Kerberos forensics, DHCP/SMTP forensics, RITA workflow, Elastic NSM dashboards. Total ~22hr implementation.
  - **LOLBAS detection rules built:** 15 Elastic KQL rules from ML ground-truth dataset (500 malicious + 500 benign samples, 65+ features). Rules cover: Office→LOLBAS chain, high-entropy commands, regsvr32/mshta/certutil/bitsadmin/MSBuild/rundll32/cmstp abuse, hidden PowerShell, mimikatz indicators. Saved to `lolbin-detection-rules.md`. ~2hr deployment.
  - **Malware-traffic-analysis.net workflow:** plan1.7 §10 — PCAP validation workflow. Download real malware PCAPs → OhMyPCAP + cadre-* rules → verify detection. Do AFTER campaign validation.
  - **Campaign_suggestions.md lifecycle restructured:** Phase 3.5 (Credential Access) split from Phase 5 (Persistence). Summary table grouped by MITRE ATT&CK lifecycle.
  - **Workflow emphasis:** No more documentation until campaign is validated. Execute attack → update CAMPAIGNS-METADATA.md. Phase complete → capture telemetry → update tracker.md. Before next phase → review Campaign_suggestions.md.
  - **Dirk-jan Mollema blog analyzed (24 posts across 5 pages):** Primary reference for both on-prem AD (forest trusts, ADCS, RBCD, unconstrained delegation) and Azure/Entra ID (PRT, Cloud Kerberos Trust, Actor tokens, Intune ADCS, TAP, Federated Credentials, App Admin). Added:
    - **Campaign_suggestions.md Tier 3:** 16 new items (#43-#58) — adidnsdump, RBCD+Relay, Unconstrained Delegation (krbrelayx), ADCS ESC8 (NTLM Relay), CVE-2019-1040, Zerologon, Forest Trust SID Filtering, CVE-2020-0665, adconnectdump, Actor Tokens, Cloud Kerberos Trust, PRT Phishing, Intune ADCS, TAP Lateral, Federated Creds Persistence, App Admin→GA.
    - **external-references.md:** 24 new entries (#80-#103) — full Dirk-jan blog post list.
    - **plan1.7-defense-deepening.md §11:** ADCS ESC8, Forest Trust SID Filtering, CVE-2020-0665, Unconstrained Delegation Abuse, RBCD, NTLM Relay, Kerberos Relay over DNS, adconnectdump — 8 detection areas with Suricata + Zeek + Elastic rules.
    - **plan1.8-offensive-upgrades.md §10:** 8 Plan 11 offensive techniques (P11.1-P11.8) — Actor Tokens, Cloud Kerberos Trust, PRT Phishing, Intune ADCS, TAP, Federated Creds, App Admin, adconnectdump. Priority: P11.8 (adconnectdump) first — bridges Phase 3 SYSTEM to Plan 11.
  - **Dirk-jan is #1 reference for AD/Azure research.** Future posts by him should be triaged into plan1.7 (defense) or plan1.8 (offense).
- **Previous Session (2026-06-11 — DCOMIllusionist + CVE-2026-41089 + RTO Courses):**
  - **DCOMIllusionist (Synacktiv):** Fileless DCOM lateral movement via .NET deserialization. Campaign_suggestions.md #32. Study guide saved.
  - **CVE-2026-41089 Netlogon RCE:** Unauthenticated DC exploit (CVSS 9.8). Standalone exercise (#33), not main campaign.
  - **RTO-Windows-Persistence:** 4 techniques added — DLL Hijacking (#34), COM Hijacking (#35), IFEO (#36), LSA SSP (#37). All Phase 5.
  - **RTO-Windows-PrivEsc:** 4 techniques added — UACME (#38), Named Pipe Impersonation (#39), Handle Leak (#40), Token Dance (#41).
  - **LAPS Extraction (#42):** Zero Point Security RTO 2025. Phase 3.5 credential access.
- **Previous Session (2026-06-10 — SQL Server 2025 AI Abuse + OhMyPCAP):**
  - **SQL Server 2025 AI Abuse (SpecterOps):** Campaign_suggestions.md #31. mbr02 already runs SQL Server 2025 Developer Edition. Study guide saved.
  - **OhMyPCAP:** plan1.7 §7 — lightweight PCAP analysis tool for Kali.
  - **RPC monitoring:** plan1.7 §8 — `Microsoft-Windows-RPC` ETW provider as future enhancement.
- **Previous Session (2026-06-09 — iPurple.team + UnPAC-the-Hash + ETW Internals):**
  - **9 iPurple.team articles added** to Campaign_suggestions.md (#19-#28). ADWS, WerFault, Cross-Session, SharpHound, BadSuccessor, WinGet, EntryPoint, SpeechRuntime, GAC, Credential Guard.
  - **UnPAC-the-Hash (#29):** SpecterOps U2U deep-dive. Cert → NT hash via U2U. Chains with ADCS. Study guide saved.
  - **ETW Internals (#30):** kernullist blog. Detection engineering reference.
  - **External references master index created:** `docs/internal/plan01-upgrades/external-references.md` — 50+ references.
  - **4 study guides saved:** ref-adws-enumeration, ref-lsass-werfault, ref-cross-session-activation, ref-sharphound-detection.
- **Previous Session (2026-06-08 — Branch 3.5 Execution + Study Guide + Impacket IoCs):**
  - **`05-study-guide/` restructured:** Old cert-specific content moved to `10-cert-map/`. New `05-study-guide/` now holds deep-dive attack reference per campaign phase. Phase 0 (Reconnaissance), Phase 1 (Initial Access), Phase 2 (Credential Harvesting) study guides written. Remaining phases created after each phase is tested.
  - **Branch 3.5 metadata added to CAMPAIGNS-METADATA.md:** 3.5F (SAM dump), 3.5A (Winlogon registry), 3.5H (ctfmon.exe), 3.5I (Token impersonation ❌), 3.5B (Scheduled Task), 3.5D (File Detonation), 3.5J (WMI Persistence) — all with full theory, prerequisites, telemetry.
  - **Branch 3.5 expanded in CAMPAIGNS.md:** WMI Event Subscriptions (3.5J) added as new branch. Invisible Scheduled Tasks (SD deletion) added to 3.5B. Execution order updated to 10 techniques.
  - **Impacket protocol-level IoCs documented:** 73 Impacket IoCs mapped to CADRE phases in `docs/internal/plan01-upgrades/plan1.7-defense-deepening.md`. Tier 1: 9 Suricata rules + 3 Zeek scripts to build. Tier 2: 4 cluster models. Tier 3: 4 hunting queries.
  - **npm supply-chain upgrade planned:** TanStack Shai-Hulud evolution (May 2026) analyzed. 3 new scenarios (F-11 IDE persistence, F-12 dead-man switch, F-13 prepare hook) documented in `docs/internal/plan01-upgrades/plan1.8-npm-upgrade.md`.
  - **VMware escape research:** `docs/internal/plan01-upgrades/vmware-escape-research.md` — 4 escape writeups (2024-2025), risk assessment, hardening recommendations.
  - **RAPTOR v3.0.0 reviewed** — autonomous code vulnerability scanner. Not relevant to CADRE (different tool class).
  - **Workflow locked in:** Execute attack → update CAMPAIGNS-METADATA.md. Phase complete → capture telemetry → update tracker.md. Before next phase → review Campaign_suggestions.md.
- **Previous Session (2026-06-04 — Campaign Verification: Phase 1-3 End-to-End):**
  - **Phase 1-2 VERIFIED from provisioning (Kali):** AS-REP roast → intern_blue → ForceChangePassword → analyst_t2 → Kerberoast → svc_mssql + analyst_t1 (both SPNs). Hashcat mode corrected to 13100 (RC4). Wordlist: `cadre_passwords.txt`.
  - **Phase 3 VERIFIED — SQL auth from Kali (no SSH cheat):** Enabled mixed mode auth (registry), created SQL logins for svc_mssql and analyst_t1, granted IMPERSONATE on sa. Full chain: `Kali → SQL auth (analyst_t1) → IMPERSONATE sa → xp_cmdshell → GodPotato → nt authority\system`.
  - **Reconnaissance section added** — Kerberos user enum via nmap port 88 finds 20 users across both domains. Anonymous enum blocked on Server 2025. Key finding: `analyst_cloud` is in root domain (cadre.local), never discovered by BH.
  - **BH data verified identical** across all user collections (zero difference between intern_blue and svc_mssql). BH from non-admin users can't enumerate local admins, sessions, or RDP users.
  - **Token impersonation marked PATCHED** on Server 2025 (error 1346). File execution (WT063-068) is next step for analyst_cloud.
  - **SQL Server Express fix:** Mixed mode auth via registry (`LoginMode=2`), SA login enabled manually, SQL logins created. Verify playbook updated with 3 new checks.
  - **4 files updated:** `sql-integration-guide.md`, `attack-specifications.md`, `CAMPAIGNS.md`, `09-sql-wsus-verify.yml`.
  - **Password dictionary created:** `ansible/files/cadre_passwords.txt` (7 real + 17 decoy passwords).
- **Previous Session (2026-06-04 — Campaign Accuracy Cross-Check):**
  - **CAMPAIGNS.md fully cross-checked** against all 16 playbooks + 3 integration guides. All 75 core AD attack claims verified against playbook ground truth. No breaking changes needed.
  - **SID Filter: OFF** confirmed — verified by `01-core-ad.yml:50` (`SIDFilteringQuarantined = $false`). Footnote added to CAMPAIGNS.md topology diagram. Trust created with defaults in `00-domain-deploy.yml` (Server 2025 forest trusts default to SID filtering disabled).
  - **E exercises expanded** — 14 entries (WT069-081 + WT093) with full tables: technique, trigger, detection rule per row.
  - **F supply-chain expanded** — 10 entries (F-01 through F-10) with full tables: scenario, MITRE, sensor, detection rule per row.
  - **Playbook comments corrected** — `05-ad-attack-surface.yml` line 8: "14 ACEs across 13 entries" (cadre.local); line 585: "6 entries" (range.local).
  - **All 75 core attacks verified** — ACEs, SPNs, delegations, trust config, SCCM, ADCS, SQL, linux config all match playbook implementations.
- **Previous Session (2026-06-03 — Single-Campaign Restructure + Phase 1 Narrative Complete):**
  - **CAMPAIGNS.md restructured** from 4 separate campaigns (A-D) into single: 8-phase main spine + 4 branches (A: ACL, B: ADCS, C: SCCM, D: Linux). 75 campaign + 14 E + 10 F = 99 total. 'provisioning' → 'Kali'. GOAD-style topology diagram added.
  - **Phase 1 narrative rewritten** with full flow: Kerberos user enum → AS-REP roast → BH recon → discover ACE#18 + SPN → reveals Phase 2.
  - **WT028 ❌ Invalid** (SAMR blocked on Server 2025). **WT031 ⏳ Pending relocation**. **WT018-020 ❌ Non-functional**.
  - **CAMPAIGNS-METADATA.md** created (387 lines, per-attack playbook/ACE/telemetry refs). **ATTACK-MAP.md** updated. **tracker.md** cleaned.
  - **All 5 supporting dirs updated**: walkthroughs (status banners), diagrams (flow), attack-path (totals), automation (annotations), study-guides (9 files renumbered).
  - **BloodHound data** confirmed: 3 zips on Kali (child/cadre/range). **python-is-python3** installed.
  - **Execution standing by** — Phase 1 narrative ready, user signals when to start WT003.
- **Plan 1 — Phase restructuring (2026-06-01):**
  - **100 total attacks across 5 streams:** 59 core AD + 13 E (network defense) + 10 F (supply-chain) + 12 G (MITRE gap) + 6 H (initial access). 76 core campaign, 14 practice scripts, 10 supply-chain simulation.
  - **CAMPAIGNS.md restructured (2026-06-03):** G and H attacks no longer standalone — blended inline into Campaign A phases. H (WT063-068) is an alternate entry path in Phase 3 alongside SQL xp_cmdshell. G attacks spread across Phase 3 (WT082/083/090), Phase 5 (WT084-087), Phase 7 (WT088-089), Phase 8 (WT091-092). WT093 (ransomware) moved to E. Phase 2.5 fixed: uses ACE#18 (intern_blue → ForceChangePassword → analyst_t2 → getTGT → Kerberoast) instead of broken direct-password Kerberoast. Only E (network defense) and F (supply-chain) remain as standalone sections.
  - **BloodHound collected:** All 3 domains (cadre/child/range) via bloodhound-python + SharpHound. 49 users, 6 computers, ~187 groups across 2 forests.
  - **Phasing reset:** Phase 0 (Plan 0.7/0.8/0.9 implementation) = DONE. Phase 1 (source-matrix fill + batched rule writing) = NOW. Phase 2 (E2E) and Phase 3 (Sigma) follow.
  - **Directory:** `phase0/` → `phase1-source-matrix/`. `00-plan.md`/`01-state.md` → `plan01.md`/`state01.md`. `01-three-stream-merge.md` documents the 92-attack merge.
  - `ATTACK-REFERENCE-MAP.md` verified against 150+ actual files (6 reference sources cross-referenced)
  - **MITRE gap analysis:** `mitre-corelab-comparison.md` maps all 92 attacks to MITRE Enterprise. Covers 14 tactics, ~37 technique IDs. Major gaps: Defense Evasion (3/30), Discovery (2/34), Impact (0/15). Campaign E MITRE IDs assigned. Sub-technique check: 91 of ~97 uncovered.
  - **Campaign G designed:** 12 non-evasion attacks (LSASS dump, lateral, persistence, recon, collection, impact). Forms post-exploitation mini-campaign. See `phase0.1/mitre-corelab-comparison.md`.
  - **Initial access explored:** Campaign H proposed — 6 file-based initial access techniques (LNK, MSI, CHM, HTML smuggling, AutoIt3, EXE) using existing infra. See `phase0.1/initial-access-enhancement.md`.
  - **Phase 0.1 implementation tracker:** `phase0.1/implementation-plan.md` tracks Stage 1–3 deployment of 31 new attacks (E+G+H). Stage 1 (deploy attack surface) in progress. All 31 attack scripts written to `04-automation/campaign-{e,g,h}/`. 25 of 31 require zero setup — ready to run. Remaining 6 need tooling staged (WiX, HTML Help WS, procdump, AutoIt3).
  - **Execution order:** fill source-matrix-grid → write ALL rules → one E2E → Sigma catalog
  - P0a: Install pre-built Elastic SIEM rules — EDR diagnosis ✅ complete, install pending
  - **P0c-0: Telemetry source matrix + field dictionary — IN PROGRESS. Prerequisite to all rule writing.**
  - P0c: ~30 custom cadre-* rules for uncovered attacks (ADCS ESC first)
  - P0c-EDR: ~5-7 cadre-e* rules where Endpoint.events is PRIMARY (post-dedup)
  - P0b: Full 100-attack E2E with all rule tiers active
- **Execution order**: Plan 0.7 → 0.8 → 0.9 → P0a → P0c → P0c-EDR → P0b. Phase 1 working dir: `docs/internal/plan01-telemetry-catalog/phase1-source-matrix/`.
- **Five-Stream Merge — 100 attacks (2026-06-03):** Final campaign structure ratified in `attack-matrix/CAMPAIGNS.md` (formerly `_v2.md`, now canonical). Implements the unified 100-attack pipeline specified in `docs/internal/plan01-telemetry-catalog/phase1-source-matrix/five-stream-merge.md` (Core AD 59 + NetDef 14 [13 + WT093] + Supply-Chain 10 + MITRE Gap 11 [WT093 reclassified] + Initial Access 6). Original 60-attack campaign archived at `attack-matrix/CAMPAIGNS_v1_archived.md`. Header cross-link installed at top of `CAMPAIGNS.md`. All `CAMPAIGNS_v2.md` references across the repo (AGENTS, CHANGELOG, attack-flow.md, 01-walkthroughs/README.md, 02-diagrams/README.md, prerequisites.md, README.md) updated to `CAMPAIGNS.md`. `five-stream-merge.md` §3/§5 tables refreshed to match the post-WT093 counts. OCD AD mindmap (`https://orange-cyberdefense.github.io/ocd-mindmaps/img/mindmap_ad_dark_classic_2025.03.excalidraw.svg`) noted as a non-authoritative external reference.

### Plan 0.7 — Defense Deepening (Phases A-D Complete, Attack Testing Complete, Phase F Proposed)

**Monitor VM (192.168.77.55)** — Zeek 8.0.8 + Suricata 8.0.5 running. Phases A-D executed 2026-05-28. Attack testing Batch A-D complete.

**EDR Diagnosis (2026-05-31):** Elastic Defend behavioral alerts require Platinum license → Basic license restricts to `mode: off`. Event telemetry flows freely (14 indices, ~39 MB). Phase F proposed: write custom cadre-e* rules querying `logs-endpoint.events.*` for process/file/network/registry patterns. Full spec in `plan0.7-defense-deepening.md §Phase F`.

**Attack testing results (2026-05-29):**
- **A-01 Kerberoast (WT002)**: SID:1000015 rev:3 ✅ (7 fires). S1/S3 burst ❌ (thresholds too high). Zeek kerberos.log ✅.
- **A-02 DCSync (WT009)**: SID:1000002 ✅ (63 fires). Zeek dce_rpc.log ✅. No Zeek notice viable.
- **A-03 AS-REP Roast (WT003)**: ET:2000002 ✅ (37 fires). Zeek kerberos.log ✅.
- **B-01 DGA**: SID:1000025 ✅ (3-4 fires). ET:2000022 ✅ (3-4 fires). Zeek ✅ (6 notices).
- **B-02 TXT**: SID:1000026 ✅ (137 fires). ET:2000020 ✅ (137 fires).
- **B-03 NXDOMAIN**: SID:1000027 rev:2 ✅ (1 fire). Rule fixed: `-> any 53` → `-> any any`.
- **B-04 TLD**: SID:1000028 ✅ (157 fires). ET:2000021 ✅ (42 fires). Rule fixed: PCRE trailing dot removed.
- **B-05 IP Literal**: SID:1000029 rev:2 ✅ (38 fires). Rule fixed: PCRE matches `.in-addr.arpa` format.
- **C-01 TLS 1.0**: SID:1000010 ✅ (1 fire). ET:2000031 ✅ (1 fire). ClientHello captured.
- **C-02 SNI**: ET:2000032 ❌ (0 fires). DC01 no HTTPS.
- **C-03 Ciphers**: Z6 ❌ (0 fires). DC01 no HTTPS.
- **C-04 Cert Chain**: SID:1000014 ❌ (0 fires). Expected — lab certs 1-2 deep.
- **D-01 SMB Admin**: ET:2000012 ✅ (1 fire). ADMIN$ share access detected.
- **D-02 SMBv1**: ET:2000010 ✅ (99 fires). NT1 rejected by Server 2025.
- **D-03 HTTP UA**: ET:2000041 ✅ (10 fires).
- **D-04 Exploit Path**: ET:2000070 ✅ (21446 fires).
- **D-05 Content-Type**: ET:2000072 ✅ (2 fires).
- **D-06 SSH Brute**: ET:2000060 ✅ (177 fires). Script fixed (removed BatchMode).
- **D-07 Cross-Subnet**: Z8 ❌ (0 fires). Expected — lab single subnet.
- **D-08 Long-Conn**: Z9 ✅ (3 fires). Fires from background connections.
- **D-09 QUIC**: Z10/Z11 ❌ (0 fires). Informational only — thresholds impractical.

**Failures (3 categories):**
- **Can fix**: C-02/C-03 need HTTPS endpoint (enable IIS HTTPS on mbr01)
- **Not applicable**: C-04 (lab certs 1-2 deep), D-07 (single subnet), D-09 (thresholds impractical)
- **Working as intended**: C-01 (ClientHello captured), D-02 (SMBv1 attempt detected), D-08 (background connections fire)

**Zeek scripts (7 loaded via local.zeek):**
- `cadre-outbound.zeek` — Internal → unknown external connections
- `cadre-conn-beacon.zeek` — Byte/duration threshold alerts (independent checks, not else-if)
- `cadre-tcp-profile.zeek` — Cross-subnet alerts (192.168.77.x ↔ 10.x/172.16.x)
- `cadre-dns-anomaly.zeek` — DGA, duplicate TXID, NXDOMAIN bursts
- `cadre-tls-fingerprint.zeek` — 13 suspicious cipher suites (RC4, export, NULL, anon DH)
- `cadre-quic-c2.zeek` — UDP/443 duration + byte threshold (no QUIC event handlers in Zeek 8.0.8)
- `cadre-supplychain-http.zeek` — HTTP POST monitoring for npm attack patterns (Plan 0.8)

**Suricata rules (34 total, 0 failures):**
- `cadre-ad.rules` (2) — Kerberoast burst, DCSync
- `cadre-phaseb.rules` (9) — TLS anomalies, Kerberos weak crypto, DNS anomalies
- `cadre-et-lab.rules` (13) — Curated ET subset (Kerberos, SMB, DNS, TLS, HTTP)
- `cadre-supplychain.rules` (10) — npm attack patterns (webhook, TruffleHog, /tmp download, npm publish, cloud metadata)
- JA3/JA4 fingerprinting enabled in suricata.yaml

**Elastic Fleet integrations on CADRE-Monitor policy:**
- Zeek: `conn.log`, `dns.log`, `http.log`, `ssl.log`, `kerberos.log` (default)
- Zeek Notice: `notice.log` → `zeek.notice` dataset (Custom Logs Filestream)
- Suricata: `eve.json` → `suricata.eve` dataset

**Utility scripts on monitor VM:**
- `cadre-extract-toggle.sh` — Enable/disable file extraction (session-only, currently DISABLED)
- `cadre-rita-analyze.sh` — One-command RITA: unmask → import → analyze → re-mask

**Key learnings (Zeek 8.0.8 API quirks):**
- `@load krb` doesn't load `ticket-logging.zeek` — need explicit path
- `ntlm` package not available in Zeek 8.0.8
- `ssl_client_hello` event signature mismatch — can't compute JA3 in Zeek, use Suricata instead
- `tcp_packet` event signature mismatch — simplified to cross-subnet alerts
- QUIC event handlers not available — fallback to UDP/443 heuristic
- All CADRE scripts must have unique module names to avoid namespace conflicts
- `redef enum Log::ID += { LOG }` must be present in each script's export block
- `zeekctl deploy` fails with controllee.zek error — use `zeekctl start` instead (pre-existing Zeek 8.0.8 issue)

**Key learnings (Suricata 8.0.4→8.0.5 syntax — still applies to 8.0.5):**
- `krb5_msg_type` (underscore) not `kerberos.msg_type` (dot)
- `dcerpc` not `dceprc`
- `http.cookie` and `smb.ntlmssp` need `content:` keyword
- Port variables go in `port-groups` not `address-groups`
- `smb.named_pipe` syntax differs from docs — rule dropped
- Full ET ruleset (50K+) removed — too heavy for lab VM, replaced with 13 curated rules
- **DNS response direction**: `dns.rcode:3` (NXDOMAIN) matches on DNS **response** packets which come FROM port 53. Rules must use `-> any any` (not `-> any 53`) to match responses. `-> any 53` only matches queries going TO port 53.

**Key learnings (NIC ordering on Ubuntu 24.04 w/ VMware):**
- VMware VMX assigns `ethernet0` (NAT, PCI 33) and `ethernet1` (vmnet2, PCI 224) but kernel enumerates by PCI bus order, not VMX index — `ethernet1` becomes `eth0` and `ethernet0` becomes `eth1`.
- Vagrant VMware provider's netplan assumes `eth0` = private network and `eth1` = NAT, which is wrong for this kernel version. Netplan must be swapped to match actual hardware.
- Symptom: static lab IP assigned to the NAT interface, DHCP assigned to the lab interface — internet unreachable, lab IP wrong.
- Fix: rewrite netplan so `eth0` (kernel's first NIC) gets the vmnet2/lab IP and `eth1` (kernel's second NIC) gets NAT DHCP.
- Only matters when NAT is enabled — during normal lab operation VMs only use vmnet2.
- **DNS NIC varies per VM**: `linux01` has `eth0=vmnet2`; `provisioning` and `monitor` have `eth1=vmnet2`. Vagrantfile provision block auto-detects the vmnet2 NIC via `ip -4 addr show | grep 192.168.77.x` and writes `/etc/netplan/60-dns.yaml` targeting that interface.

**Key learnings (DNS infrastructure):**
- Linux VMs get no DNS from Vagrant private_network (unlike Windows which gets DHCP DNS via NAT). Must configure DNS manually via netplan overlay.
- `/etc/netplan/60-dns.yaml` merges with existing Vagrant netplan — add only `nameservers` block, don't override IP addresses.
- `netplan apply` warnings about open file permissions are harmless but can be suppressed with `chmod 600`.
- DC01 DNS service can break silently (shows "Running" but doesn't respond). Fix: `Restart-Service DNS -Force`. Zones and firewall rules remain correct.
- DC01 has no internet forwarders — external TLD queries (`.tk`, `.ml`, etc.) time out. Only `cadre.local` zone queries work. Attack scripts must target the authoritative zone.
- **Ansible playbook fixes**: `00-domain-deploy.yml` now ensures DNS service is `auto`/`started` on all 3 DCs. Verify playbooks check DNS service status and resolution.
- **linux01 DNS record**: Created via `samba-tool dns add 192.168.77.10 cadre.local linux01 A 192.168.77.40 -U Administrator%vagrant`. Domain join doesn't always register DNS records automatically.
- **NAT safe to re-enable**: vmnet2 NIC keeps DC01 DNS (`60-dns.yaml`), NAT interface gets its own DHCP DNS. Lab DNS goes through vmnet2, internet through NAT. No conflicts.

**Key learnings (EDR / Elastic Defend licensing):**
- `logs-endpoint.events.*` (process, file, network, registry, library, api, security — 14 indices) flows on **any license tier** including Basic. These are queryable by any custom Elastic SIEM rule.
- `logs-endpoint.alerts-*` (behavioral alerts from Endpoint Security) requires **Platinum license** to generate. On Basic/Enterprise license, the agent collects events but never produces alerts for behavior/memory/ransomware protections — they are silently set to `mode: off`.
- Malware protection (`malware: mode: detect`) is available on Basic license and CAN produce alerts to `logs-endpoint.alerts-*` — but only for on-write malware scan, not for behavioral attack patterns.
- Kibana API to verify EDR protection state: `GET /api/fleet/package_policies/<policy-id>` → `inputs[0].config.policy.value.windows`
- Elastic Fleet agent policy names are UUID-based — retrieve the CADRE-Monitor policy ID via `GET /api/fleet/package_policies?kuery=ingest-package-policies.package.name:endpoint`
- The "Endpoint Security (Elastic Defend)" pre-built SIEM bridge rule will show "Unable to find matching indices" for `logs-endpoint.alerts-*` on Basic license — this is expected, not a bug.
- Custom cadre-e* rules SHOULD target `logs-endpoint.events.process-*` etc. directly (these indices exist) rather than relying on the bridge rule (which requires alerts-*).

**Key learnings (ES ILM):****
- Fleet-managed indices use `logs@lifecycle` policy by default, NOT `@custom` component templates — the `logs@lifecycle` overrides everything
- The default `logs@lifecycle` had **no delete phase**, causing unbounded index growth (~20 GB of 11-day-old data)
- Fix: explicitly create/update `logs@lifecycle` policy with a delete phase via the deploy playbook (`12-elk-fleet.yml`)
- Equivalent to: `PUT /_ilm/policy/logs@lifecycle` with `hot: rollover max_age=7d` → `delete: min_age=0ms`
- After updating the policy, force-rollover data streams to trigger cleanup: `POST /<data-stream>/_rollover`

### Plan 0.8 — Supply-Chain Emulation (Shai-Hulud / npm)

**Status:** Installation complete. Ready for scenario testing.

**Manual installation** (see `docs/internal/npm-supplychain-installation-guide.md`):
- linux01: Node.js + repo + mock sink + auditd watches ✅
- mbr01: Node.js + repo + Python + Choco ✅
- Provisioning: HTTP server on vmnet2 for file transfers ✅

**Playbooks:**
- `16-supplychain.yml` — Deploy (post-install config: mock sink, auditd, symlinks)
- `16-supplychain-verifyOnly.yml` — Verify (checks all components)

**Scenario execution:** Manual — user runs scenarios when ready, not automated.

### Plan 0.7 Spec A — Coercion Detection (Executed 2026-05-30)

**Detection rules: 20 active seed rules** (6 Windows + 14 Linux). 2 removed (cadre-001 RC4 Kerberoast, cadre-l10 xp_cmdshell-on-Linux). Plus 4 coercion Suricata rules (SID:1000050-53).

**New rules deployed:**
- `cadre-coercion.rules` — 4 coercion detection rules (SID:1000050-1000053), deployed to `ansible/files/zeek-cadre/`.
  - SID:1000050 MS-RPRN (PrinterBug/SpoolSample) — **CONFIRMED WORKING** (12 fires). Direct TCP to dynamic port 49674, ops 1 and 65.
  - SID:1000051 MS-DFSNM (DFSCoerce) — ❌ 0 fires. SMB-pipe DCE-RPC not supported by Suricata 8.0.5 dcerpc keywords.
  - SID:1000052 MS-FSRVP (ShadowCoerce) — ❌ 0 fires. Service not available on Server 2025 DC01.
  - SID:1000053 MS-EFSR (PetitPotam) — ❌ 0 fires. \PIPE\efsrpc not accessible on Server 2025.

**Playbooks updated:**
- `13-net-monitor.yml` — Added cadre-coercion.rules deploy task + rule-files entry + cp to default-rule-path
- `13-net-monitor-verifyOnly.yml` — Added file existence + config + path verification checks

**Key findings:**
- Zeek `dce_rpc_request` events do NOT fire for SMB-pipe DCE-RPC — only for raw TCP port 135
- Suricata `dcerpc.iface` + `dcerpc.opnum` keywords do NOT match SMB-encapsulated DCE-RPC (app_proto:"smb")
- MS-RPRN uses direct TCP transport (port 49674 via EPM lookup) — detection works via dcerpc.iface + dcerpc.opnum
- MS-RPRN confirmations: opnum 1 (RpcRemoteFindFirstPrinterChangeNotification) and opnum 65 (RpcRemoteFindFirstPrinterChangeNotificationEx) from pcap analysis
- Coercer v2.4.3 CLI: `coercer coerce -t <target> -l <listener>` (not `--targets`, not `--spoolsample`). Use `--auth-type smb` for SMB auth.

### Key Learnings — H / Phishing Setup (2026-06-03)

- **RDP on mbr01**: `fDenyTSConnections=0` + firewall rule `Remote Desktop` enabled. `CADRE\analyst_cloud` added to `Remote Desktop Users` local group. Cross-domain RDP works because cadre↔child trust allows authentication.
- **Directories created**: `C:\Users\analyst_cloud\Downloads\` (phishing drop target), `C:\Tools\` (ingress tool transfer target). Both persisted in `06-member-services.yml`.
- **Playbook updates**: `04-vulnerabilities.yml` (RDP enable + firewall), `06-member-services.yml` (user + directories). Both have verify-only counterparts.
- **YAML bracket quoting**: Task names with bracket prefixes like `[SCCM][WT#37-40]` combined with backslashes (e.g., `RANGE\svc_sccm`) trigger YAML flow-sequence parsing — use single-quoted names instead.

### Key Learnings — Phase 2.5 ACE#18 Kerberoast Flow (2026-06-03)

- **Don't Kerberoast as intern_blue**: intern_blue has `DoesNotRequirePreAuth` — `getTGT.py` fails, and dc02's KDC rejects RC4 AS-REQ from impacket, returning `KDC_ERR_ETYPE_NOSUPP`.
- **Use the ACE bridge**: ACE#18 (`intern_blue → analyst_t2: ForceChangePassword`) is the playbook's intended path. Reset analyst_t2's password, then `getTGT.py` works (pre-auth enabled), then Kerberoast `svc_mssql` with the TGT. Crack with `hashcat -m 19700` (AES256).
- **Source-matrix testing began**: WT003 (AS-REP) and WT002 (AES Kerberoast) verified against range.local. Raw event data documented in `tracker.md` with WinSec PRIMARY, Zeek/Suricata/Sysmon/Endpoint corroboration.

### Current Session (2026-07-04 — RevEng ↔ DFIR-Nexus integration plan)

- **Source / scope:** Joint integration plan between **CADRE-RevEng v2.0/v3** and **DFIR-Nexus v1.0.0 E.0 Constellation**. Both tools were built independently; this plan bridges them so the analyst gets one search, two systems, one answer.
- **Q1 answer (LLM-only rewiring):** No. Don't rewire DFIR-Nexus. The embedder is the real divergence (bge-base-en-v1.5 768d vs bge-m3 1024d). Per-corpus best-fit model — keep separate, no re-index. Full reasoning in the mirror docs.
- **Q2 answer (integration solution):** 3-layer integration model with 5-step implementation plan.
  - **Layer 1 (RAG):** separate corpora + per-corpus embedder + shared reranker bge-reranker-v2-m3 + shared RAGDocument format.
  - **Layer 2 (LLM):** router-agnostic + shared `llm_call_metadata` + shared `parrot_flag` (already in RevEng per V3.12).
  - **Layer 3 (output):** **RevEng per-sample → DFIR-Nexus case** (the actual integration point). Uses existing E.0.1 `push/server.py`.
  - **5 steps:** output push (~50 LOC) → RAG adapter (~30 LOC) → Ollama embedder (~50 LOC) → TI cache (~100 LOC) → langgraph agent (~150 LOC).
- **Docs written (mirrors):**
  - **RevEng side:** `CADRE-RevEng/Tools/integrations/dfir-nexus/PLAN.md` (full Q1+Q2 + 5-step plan + CHECKLIST refs)
  - **DFIR-Nexus side:** `CADRE/tools/dfir-nexus/docs/integrations/REVENG-INTEGRATION.md` (mirror, RevEng-specific only)
- **Updated:**
  - `docs/internal/ACTIVE.md` — sister project context row + new handoff log entry
  - `CHANGELOG.md` — new `[Unreleased]` entry
  - `AGENTS.md` — Mini-Projects table row + this entry
- **Hard blocker:** **V3.18** (DFIR-Nexus sharing decision — PR upstream vs local fork vs shared module). User decision required.
- **CHECKLIST cross-references:** V3.18, V3.20, V3.29, O.5, O.6, O.7
- **Recommended work order (after V3.18):** Step 1 (push) → Step 2 (RAG adapter) → Step 4 (Ollama embedder) → Step 3 (TI cache) → Step 5 (langgraph)
- **Next:** Wait for V3.18 user decision. Once decided, start with Step 1 — smallest, highest impact, no model changes.
