# Changelog

All notable changes to CADRE are documented here. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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
- **Phase 2 (upgrades)**: `plan00-upgrades/` — `upgrade-suggestions.md`, `plan07-defense-deepening.md`, `plan08-supplychain.md`, `newwalkthrough-ideas.md`, `_out-of-tree/evasion-lab.md`.
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
