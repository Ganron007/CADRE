# CADRE Main Lab — Canonical Checklist

**Path:** `CHECKLIST.md` (repo root)  
**Last updated:** 2026-08-01  
**Writer repo:** `C:\STUDY\Github\CADRE-Platform\CADRE\`  
**Scope:** Lab operations, **Plan 1.1 campaign automation (RedStrike)**, **campaign execution**, **Plan 1 telemetry catalog**, **log corpus for DFIR-Nexus**, integrations — **not** per-exercise study progress (`plan1.7-exercises.md` / `plan1.8-exercises.md`).

> **Execution mode (2026-07-26):** Agents/operators fulfill checklist items from **provisioning** without waiting for manual runbook study. Learning is parallel and optional. Flip `CHECKLIST.md` first; docs follow evidence.
>
> **NEXT ACTION (locked):** **RedStrike campaign-ready** (engine Rules 1–4 + graph sync) → pin `tools/red-strike/` → **Plan 1 telemetry** (P1.1–P1.5). Attack rollup **⏳ = 0** (2026-08-03 closure pass).
>
> **Naming:** `plan01-telemetry-catalog/` = **Plan 1**. `plan01-telemetry-catalog/plan1.1-campaign-automation/` = **Plan 1.1**. `plan00-foundation/` = **Plan 0**. See [`docs/internal/PLANS.md`](docs/internal/PLANS.md).

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
| [`docs/internal/plan01-telemetry-catalog/plan1.1-campaign-automation/README.md`](docs/internal/plan01-telemetry-catalog/plan1.1-campaign-automation/README.md) | **Plan 1.1** — RedStrike campaign automation (**next**) |
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
| A — Access & ops | 3 | 3 | 0 | 0 | 0 | 6 |
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
| A.6 | Automated boot-time log cleanup on `elk` + `monitor` VMs | [ ] | | `ansible/playbooks/` or `systemd` | Clear old ES GC logs, Suricata/Zeek archives, Arkime raw pcaps, journal vacuum; preserve current logs and ES data |
| A.7 | Restore `ssh-agent` / working local SSH to `ws01` | [x] | 2026-07-31 | operator | `localhost -> ws01` now works via `cadre-ws01-key`; prior local agent issue no longer blocks execution |
| A.8 | Stage `nxc`/`certipy` on `ws01` or resolve Rust/PyPI install path | [ ] | | operator/lab | `ws01` Python 3.12/pip 24.3.1 can reach PyPI, but `pip install NetExec/netexec` returns `No matching distribution found`; `git+https` install fails on `aardwolf` wheel build because Rust compiler is missing. Blocked until Rust toolchain is installed, prebuilt wheels are available, or tools are pre-staged on `ws01`. |

---

## C — Campaign v3 execution

**Runbook:** [`CAMPAIGNS-RUNBOOK-*.md`](attack-matrix/Campaign/Runbooks/) · **Narrative:** [`CAMPAIGNS_v3.md`](attack-matrix/Campaign/CAMPAIGNS_v3.md) · **Metadata:** [`CAMPAIGNS-METADATA-v2.md`](attack-matrix/Campaign/CAMPAIGNS-METADATA-v2.md)

| ID | Phase / stream | Profile | Status | Attack | Tracker | Metadata | Notes |
|----|----------------|---------|--------|--------|---------|----------|-------|
| C.0 | Phase 0 — Recon | P-CHILD | [ ] | [ ] | [ ] | [ ] | Unauth recon, Kerberos enum, NetExec modules |
| C.0.5 | Phase 0.5 — ws01 beachhead | **P-BEACH** | [x] | [x] | [x] | [~] | **H-01/02/04/05/06 VERIFIED 2026-08-03** (provisioning→ws01); H-03 build+content, exec platform-blocked; playbooks `19-initial-access` |
| C.1 | Phase 1 — AS-REP | P-CHILD | [x] | [x] | [x] | [~] | WT003/T003; re-verified 2026-07-25 |
| C.2 | Phase 2 — Kerberoast | P-CHILD | [x] | [x] | [x] | [~] | WT002; re-verified + bundle 2026-07-25 |
| C.3 | Phase 3 — SQL → GodPotato | P-CHILD | [x] | [x] | [~] | [~] | Needs **mbr01** up |
| C.3.5 | Phase 3.5 — Credential access | P-CREDS | [ ] | [ ] | [ ] | [ ] | Active per runbook README |
| C.4 | Phase 4 — BH / delegation | P-DELEG | [ ] | [ ] | [ ] | [ ] | |
| C.5 | Phase 5 — Persistence / coercion | P-DELEG | [ ] | [ ] | [ ] | [ ] | |
| C.6 | Phase 6 — DCSync | P-DELEG | [ ] | [ ] | [ ] | [ ] | |
| C.7 | Phase 7 — Golden / alt persistence | P-FOREST | [ ] | [ ] | [ ] | [ ] | |
| C.8 | Phase 8 — Cross-forest | P-FOREST | [ ] | [ ] | [ ] | [ ] | |
| C.A | Branch A — ACL abuse | P-DELEG | [x] | [x] | [x] | [~] | Branch A 013/014/015/016/023/024/025/008/GPP verified; WT027 SPN Jacking verified 2026-08-01 |
| C.B | Branch B — ADCS | P-DELEG | [x] | [x] | [x] | [~] | ESC1/2/3/4/7/9 + UnPAC verified 2026-08-01; ESC8/11 🔬 deferred |
| C.C | Branch C — SCCM | P-FOREST | [x] | [x] | [x] | [x] | **WT037 CMPivot + WT038 app deploy + WT039 script-as-SYSTEM FULL EXEC VERIFIED 2026-08-02** (live data + `nt authority\system` on WS01 via AdminService as svc_sccm; enablers: BGB fast channel + svc_sccm Full Admin DB grant + DB script approval + mp.msi MP repair). Recipes: guide Phase 6B/6C. Remaining: WT035 PXE client, WT036 relay device |
| C.D | Branch D — Linux pivot | P-LINUX | [x] | [x] | [x] | [~] | WT044-048 verified 2026-08-01 |
| C.E | Stream E — Network defense (14) | P-PURPLE | [ ] | [ ] | [ ] | [ ] | Plan 0.7 overlap |
| C.F | Stream F — Supply chain (10) | P-CHILD + linux01 | [ ] | [ ] | [ ] | [ ] | Plan 0.8 |
| C.G | Stream G — Pre-auth DC CVE lab | snapshot | [~] | [ ] | [ ] | [ ] | Deferred per campaign |
| C.H | H-01..H-06 (initial access) | P-BEACH | [x] | [x] | [x] | [~] | **5/6 VERIFIED 2026-08-03** (H-01/02/04/05/06); H-03 exec platform-blocked (hh.exe sandbox); `19-initial-access.yml` + artifacts hosted provisioning:8081 |

**Campaign hygiene (each phase complete):**

| ID | Item | Status | Owned by |
|----|------|--------|----------|
| C.X1 | Runbook + `CAMPAIGNS_v3.md` section kept in sync | [ ] | Runbooks |
| C.X2 | `python tools/split-campaign-runbooks.py --check` after bulk v2 edits | [~] | v3 manual sync |
| C.X3 | `Campaign_suggestions.md` reviewed before next phase | [ ] | Research backlog |

---

## Campaign re-test tracker (2026-07-31)

> Source of truth: [`attack-matrix/Campaign/CAMPAIGNS-VALIDATION-REPORT.md`](attack-matrix/Campaign/CAMPAIGNS-VALIDATION-REPORT.md) · [`attack-matrix/Campaign/CADRE-Attack-Surface-Coverage-Audit.md`](attack-matrix/Campaign/CADRE-Attack-Surface-Coverage-Audit.md) · [`attack-matrix/Campaign/CAMPAIGNS-METADATA-v2.md`](attack-matrix/Campaign/CAMPAIGNS-METADATA-v2.md)
>
> **Scope:** Phase 1–8 + Branch A–D + Streams E/F/G · **H-01..H-06 initial access verified 2026-08-03** (5/6; H-03 platform-blocked) · **Legend:** ✅ verified / 📝 script corrected pending re-test / ⏳ not exercised / ⠿ blocked / ❌ non-functional or rejected / 🔬 deferred

**How to use this tracker:**
- Flip the main attack checkbox when the attack is re-tested end-to-end.
- Use sub-items for pre-test setup, execution, and post-test evidence capture.
- When a branch section grows, add sub-items per attack rather than collapsing them into one line.

### Phase 0 Recon

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| P0-Step1 | Kerberos user enumeration | Kali / provisioning | None | ✅ Verified |
| P0-Step2 | Check DONT_REQUIRE_PREAUTH | Kali / provisioning | None | ✅ Verified |
| P0-Step3 | NetExec authenticated recon (intern_blue) | provisioning | intern_blue / 1nt3rn_Blu3! | ✅ Verified |
| WT028 | Null session / SAMR anonymous enumeration | Kali / provisioning | None | ❌ Rejected |

- [x] **P0-Step1** Kerberos user enumeration — surface check · attack run · telemetry captured · tracker updated
- [x] **P0-Step2** AS-REP roastable check — surface check · attack run · telemetry captured · tracker updated
- [x] **P0-Step3** NetExec recon (intern_blue) — surface check · attack run · telemetry captured · tracker updated
- [x] **WT028** Null session / SAMR — surface check · attack run · telemetry captured · tracker updated

### Phase 0/1 Fallback

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| WT031 | Password spray against dc01 | provisioning / Kali | cadre_passwords.txt | ✅ Verified |

- [x] **WT031** Password spray — surface check · attack run · telemetry captured · tracker updated

### Phase 1

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| 003 | AS-REP Roast (WT003) | ws01 | child\analyst_t1 / T13r_An@lyst! | ✅ Verified |

- [x] **T003** AS-REP Roast — surface check · attack run · telemetry captured · tracker updated

### Phase 2

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| 002 | Kerberoast via ACE#18 bridge (WT002) | ws01 | intern_blue / 1nt3rn_Blu3! | ✅ Verified |

- [ ] **T002** Kerberoast — surface check · attack run · telemetry captured · tracker updated

### Phase 2 Alt

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| NTLMv1 | NTLMv1 rainbow-table downgrade | ws01 | Coerced NTLMv1 responder | 🔬 Deferred — optional alt |

- [x] **NTLMv1** rainbow-table downgrade — 🔬 deferred (optional alt, not main spine)

### Phase 3

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| 041/043 | SQL xp_cmdshell + GodPotato (WT041/WT043) | ws01 -> mbr01 | child\analyst_t1 / T13r_An@lyst! | ⠿ Partial — GodPotato **IS staged** on mbr01 (57,344 bytes); re-test `GodPotato.exe -cmd whoami` via SQL. Long-lived children (Rubeus monitor) hang SQL ExecuteReader@180s — use ws01 listener path instead |
| 042 | CLR Assembly on mbr02 (WT042) | ws01 -> mbr02 | child\analyst_t1 / T13r_An@lyst! | 📝 Reachable |

- [ ] **T041/T043** SQL xp_cmdshell + GodPotato — surface check · attack run · telemetry captured · tracker updated
- [ ] **T042** CLR Assembly — surface check · attack run · telemetry captured · tracker updated

### Phase 3.5

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| 101 | WinRS lateral pivot ws01 -> mbr01 (T101) | ws01 | child\analyst_t1 / T13r_An@lyst! | ✅ Verified |
| 3.5F | LSASS/SAM credential dump via mimikatz | SYSTEM on mbr01 | SYSTEM | ✅ Verified |
| 3.5A | Winlogon plaintext credential extraction | SYSTEM on mbr01 | SYSTEM | ✅ Verified |
| 3.5G | DPAPI via Nemesis | SYSTEM on mbr01 | SYSTEM | ✅ VERIFIED 2026-08-03 (end-to-end) |
| 3.5H | ctfmon.exe password extraction | SYSTEM on mbr01 | SYSTEM | ⚠️ Partial 2026-08-03 |
| 3.5I | Token impersonation | mbr01 | SYSTEM | ❌ Rejected |
| 3.5B | Scheduled Task as analyst_cloud | mbr01 | analyst_cloud | ❌ Rejected for attack chain |
| 3.5C | RDP interactive session as analyst_cloud | ws01 -> mbr01 | analyst_cloud / Cl0ud_An@lyst! | ✅ VERIFIED 2026-08-03 (prereqs — Rule 3) |
| 3.5D | File detonation / payload drop (WT063-068) | ws01 / mbr01 | analyst_t1 or analyst_cloud | ✅ Verified 2026-08-03 |
| 3.5J | WMI Event Subscriptions | SYSTEM on mbr01 | SYSTEM | ⚠️ Partial 2026-08-03 |
| 3.5K | LSASS dump via WerFault | SYSTEM on mbr01 | SYSTEM | ✅ Verified 2026-08-03 |
| 3.5L | LAPS extraction | dc01 | DA | 🔬 Deferred — LAPS not deployed |
| 3.5M | Azure AD Connect DPAPI dump | dc01 | DA | ⏳ Not exercised |
| 3.5N | UnCanny LPE via InstallService | ws01 | local user | 🔬 Deferred |

- [x] **3.5F** mimikatz LSASS/SAM — surface check · attack run · telemetry captured · tracker updated
- [x] **3.5A** Winlogon plaintext extraction — surface check · attack run · telemetry captured · tracker updated
- [x] **3.5G** DPAPI via Nemesis — surface check · attack run · telemetry captured · tracker updated
- [ ] **3.5H** ctfmon.exe extraction — surface check · attack run · telemetry captured · tracker updated
- [x] **3.5I** Token impersonation — surface check · attack run · telemetry captured · tracker updated
- [x] **3.5B** Scheduled Task — **REJECTED as execution wrapper (Rule 2: scheduled tasks are persistence-only).** Not a campaign attack. SeBatchLogonRight retained as persistence-prerequisite surface only.
- [x] **3.5C** RDP interactive session — ✅ prereqs verified (`wt035c-rdp-prereq.ps1`; full mstsc = user practice)
- [x] **3.5D** File detonation / payload drop — surface check · attack run · telemetry captured · tracker updated
- [ ] **3.5J** WMI Event Subscriptions — surface check · attack run · telemetry captured · tracker updated
- [x] **3.5K** WerFault LSASS dump — surface check · attack run · telemetry captured · tracker updated
- [x] **3.5L** LAPS extraction — 🔬 deferred (LAPS not deployed — same as WT100)
- [ ] **3.5M** Azure AD Connect DPAPI dump — surface check · attack run · telemetry captured · tracker updated
- [~] **3.5N** UnCanny LPE — surface check · attack run · telemetry captured · tracker updated

### Phase 4

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| 004 | BloodHound discovery (WT004) | mbr01 (SYSTEM) or ws01 | SYSTEM on mbr01 | ✅ Verified |

- [x] **T004** BloodHound discovery — surface check · attack run · telemetry captured · tracker updated

### Phase 5

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| 007 | RBCD standalone (WT007) | ws01 | child\analyst_t1 / T13r_An@lyst! | ⠿ BLOCKED |

- [ ] **T007** RBCD standalone — surface check · attack run · telemetry captured · tracker updated

### Phase 5 Coercion

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| 017 | MS-RPRN PrinterBug coercion (WT017) | ws01 -> SYSTEM on mbr01 | SYSTEM | ✅ Confirmed |
| 018 | MS-EFSR PetitPotam (WT018) | ws01 | SYSTEM | ❌ Non-functional |
| 019 | MS-DFSNM DFSCoerce (WT019) | ws01 | SYSTEM | ❌ Non-functional |
| 020 | MS-FSRVP ShadowCoerce (WT020) | ws01 | SYSTEM | ❌ Non-functional |
| 021 | NTLM relay to LDAP / ESC8 (WT021) | Kali / provisioning | Coerced dc02$ or other account | ✅ Active |
| 022 | NTLM relay to ADCS / shadow credentials (WT022) | Kali / provisioning | Coerced account | ✅ Active |
| 094 | UnCanny Coerce (WT094) | ws01 | local user | 🔬 Deferred |
| 095 | Onelogon Zero-Channel (WT095) | Kali -> DC | DC machine account NTLMv2 | 🔬 Deferred |
| 096 | coerce_plus consolidated check (WT096) | ws01 | SYSTEM context | 🔬 Deferred — `nxc` not on ws01 |

- [x] **T017** PrinterBug coercion — surface check · attack run · telemetry captured · tracker updated
- [x] **T018** PetitPotam — surface check · attack run · telemetry captured · tracker updated
- [x] **T019** DFSCoerce — surface check · attack run · telemetry captured · tracker updated
- [x] **T020** ShadowCoerce — surface check · attack run · telemetry captured · tracker updated
- [x] **T021** NTLM relay to LDAP — surface check · attack run · telemetry captured · tracker updated
- [x] **T022** NTLM relay to ADCS — surface check · attack run · telemetry captured · tracker updated
- [~] **T094** UnCanny Coerce — surface check · attack run · telemetry captured · tracker updated
- [~] **T095** Onelogon Zero-Channel — surface check · attack run · telemetry captured · tracker updated
- [ ] **T096** coerce_plus — surface check · attack run · telemetry captured · tracker updated

### Phase 5 T102

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| T102 | Unconstrained delegation capture dc02$ TGT | SYSTEM on mbr01 | SYSTEM | ✅ VERIFIED 2026-07-31 |

- [x] **T102** dc02$ TGT capture — **VERIFIED 2026-07-31**: hostname listener (Kerberos) → dc02$ TGT captured → kirbi→ccache → feeds Phase 6 DCSync

### Phase 6

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| 009 | DCSync (WT009) | ws01 or Kali | child\krbtgt via dc02$ TGT (main path) or chief_command (fallback) | ✅ VERIFIED 2026-07-31 |

- [x] **T009** DCSync — **VERIFIED 2026-07-31 (main path)**: dc02$ TGT → kirbi→ccache → `secretsdump.py -k -no-pass` → child/krbtgt NT + AES256 extracted

### Phase 7

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| 010 | Golden Ticket (WT010) | ws01 | krbtgt hash (child.cadre.local) | ✅ VERIFIED 2026-07-31 |
| 011 | Silver Ticket (WT011) | ws01 | Service account hash | ✅ Script executes |
| 012 | Diamond Ticket (WT012) | ws01 | krbtgt hash | ✅ Script executes |

- [x] **T010** Golden Ticket — **VERIFIED 2026-07-31**: mimikatz golden with extracted child krbtgt (NT+AES256) + `/sids:<root EA>` → forged + PTT + `EA-aes.kirbi`. Rubeus `golden` silent on ws01 (non-Defender quirk) — use mimikatz. Cross-realm DCSync of root via golden = PAC checksum quirk on dc01 DRSUAPI bind; root EA via chief_command fallback.

### Phase 8

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| 033 | Cross-forest Kerberoast (WT033) | ws01 | root EA / chief_command | ✅ Verified |
| 034 | SCCM NAA extraction (WT034) | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ✅ Verified |

- [x] **T033** Cross-forest Kerberoast — surface check · attack run · telemetry captured · tracker updated
- [x] **T034** SCCM NAA extraction — surface check · attack run · telemetry captured · tracker updated

### Phase 8 / Branch C

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| 035 | SCCM PXE Boot abuse (WT035) | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ✅ Surface verified 2026-08-01 — PXE cert + 2 boot images + NAA-in-policy readable; full exploit needs PXE client |
| 036 | SCCM Client Push install (WT036) | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ⚠️ Primitive verified — component enabled + `GenerateCCRByName`/`CreateCCR`; relay needs console-created target |
| 037 | SCCM CMPivot (WT037) | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ✅ FULL EXEC VERIFIED 2026-08-02 — `RunCMPivot` (LogicalDisk) → live WS01 data via AdminService (enablers: BGB fast channel + svc_sccm Full Admin DB grant) |
| 038 | SCCM Application Deployment (WT038) | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ✅ FULL EXEC VERIFIED 2026-08-02 — app+DT+assignment via AdminService; MP web handlers repaired (mp.msi) → payload ran as SYSTEM on WS01 (`nt authority\system` + marker) |
| 039 | SCCM Site Takeover (WT039) | ws01 -> mbr02 | svc_sccm / s3rv1c3_SCCM! | ✅ FULL EXEC VERIFIED 2026-08-02 — script as `nt authority\system` on WS01 (create via AdminService wmi passthrough, approve via DB, `RunScript`) |

- [x] **T035** SCCM PXE Boot — surface check ✅ (cert/boot images/NAA) · attack run ⏳ (needs PXE client) · tracker · telemetry
- [~] **T036** SCCM Client Push — surface check ✅ · attack run ⏳ (relay needs console-created target) · tracker · telemetry
- [x] **T037** SCCM CMPivot — ✅ FULL EXEC VERIFIED 2026-08-02 (live data from WS01; BGB fast channel + svc_sccm Full Admin DB grant) · tracker · telemetry
- [x] **T038** SCCM Application Deployment — ✅ FULL EXEC VERIFIED 2026-08-02 (AdminService app create → mp.msi MP repair → payload as SYSTEM on WS01) · tracker · telemetry
- [x] **T039** SCCM Site Takeover — ✅ FULL EXEC VERIFIED 2026-08-02 (`nt authority\system` on WS01; DB approval bypass) · tracker · telemetry

### Phase 8 Alt

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| Skipjack | Skipjack PAC signature corruption | ws01 | child domain user | 🔬 Deferred |

- [~] **Skipjack** PAC signature corruption — surface check · attack run · telemetry captured · tracker updated

### Branch A — ACL abuse

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| 015 | ACL ForceChangePassword ACE#7 (WT015) | ws01 | hunter_dfir / DF1R_Hunt3r! | ✅ VERIFIED — ACE#7 deployed + verified (`05-ad-attack-surface-verifyOnly.yml` 18/18); hunter_dfir reset chief_command password via bloodyAD |
| 013 | ACL WriteDacl self-escalate (WT013) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA) | ✅ VERIFIED 2026-07-31 — T013 granted hunter_dfir GenericAll on CN=Command-Cadre; ACE read-back verified |
| 014 | ACL GenericWrite -> Shadow Credentials (WT014) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA) | ✅ VERIFIED 2026-07-31 — T014 granted hunter_dfir GenericWrite on analyst_cloud; ACE read-back verified |
| 016 | ACL GenericAll on OU (WT016) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA) | ✅ VERIFIED 2026-07-31 — T016 granted hunter_dfir GenericAll on OU=Command; ACE read-back verified |
| 008 | Shadow Credentials on dc01$ (WT008) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA) | ✅ VERIFIED — pywhisker (explicit creds, LDAPS) added KeyCredential to dc01$; PKINIT TGT as dc01$; NT hash 09493093db08c8afa99193779d401b34 recovered (= DCSync rights) |
| 023 | GPO Abuse (WT023) | ws01 | analyst_cloud / Cl0ud_An@lyst! (ACE#1) | ✅ VERIFIED — analyst_cloud WriteDacl/WriteOwner/GenericAll on Vulnerable-GPO; ScheduledTasks.xml preference write + read-back confirmed |
| 024 | gMSA Extraction (WT024) | ws01 | eng_cloud / Cl0ud_Eng! | ✅ Verified — msDS-ManagedPassword on gmsaTools$ → NT hash → SMB auth as gmsaTools$ |
| GPP | GPP Stored Password (Groups.xml) | ws01 | analyst_cloud / Cl0ud_An@lyst! | ✅ Verified — Groups.xml cpassword → svc_ldap; SMB auth verified; surface fixed 02/05 playbooks |
| 027 | SPN Jacking CVE-2026-25177 (WT027) | ws01 | chief_command (writeSPN) → analyst_cloud | ✅ VERIFIED 2026-08-01 — planted MSSQLSvc/dc01.cadre.local:14333 → KDC TGS (AES) w/ analyst_cloud key; cleaned. Self-write command NOT viable (SPN 1433 owned by svc_mssql / validated-write) |
| 025 | AdminSDHolder persistence (WT025) | ws01 | DA | ✅ VERIFIED 2026-07-31 — analyst_cloud WriteDacl on AdminSDHolder; ACE persisted; DACL restored to 23 ACEs |

- [x] **T015** ACE#7 ForceChangePassword — surface check ✅ · attack run ✅ (bloodyAD reset, DA login confirmed, password restored) · tracker · telemetry
- [x] **EXEC-001** Restore operator SSH access to `ws01` — direct `localhost -> ws01` SSH works via `cadre-ws01-key`
- [x] **T013** WriteDacl self-escalate — surface check ✅ · attack run ✅ (ACE read-back verified) · tracker · telemetry
- [ ] **T014** GenericWrite -> Shadow Credentials — surface check · attack run · telemetry captured · tracker updated
- [ ] **T016** GenericAll on OU — surface check · attack run · telemetry captured · tracker updated
- [x] **T008** Shadow Credentials on dc01$ — surface check ✅ · attack run ✅ (pywhisker + PKINIT TGT + NT hash recovered) · telemetry captured · tracker updated
- [x] **T023** GPO Abuse — surface check ✅ · attack run ✅ (Vulnerable-GPO preference write) · telemetry captured · tracker updated
- [ ] **T024** gMSA Extraction — surface check · attack run · telemetry captured · tracker updated
- [ ] **GPP** Get-GPPPassword — surface check · attack run · telemetry captured · tracker updated
- [ ] **T027** SPN Jacking — surface check · attack run · telemetry captured · tracker updated
- [x] **T025** AdminSDHolder persistence — surface check ✅ · attack run ✅ (ACE persisted) · telemetry captured · tracker updated

### Branch B — ADCS

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| 050 | ADCS ESC1 (WT050) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA+EA) | ✅ VERIFIED 2026-08-01 — cert Req 39 + PKINIT TGT + UnPAC NT hash |
| 051 | ADCS ESC3 (WT051) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA+EA) | ✅ VERIFIED 2026-08-01 — agent + `-on-behalf-of` → admin cert Req 44 |
| 052 | ADCS ESC8 / NTLM relay web enrollment (WT052) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA+EA) | 🔬 DEFERRED — no SMB-authenticated coerce on Server 2025 (root cause documented); revisit at end |
| 053 | UnPAC-the-Hash (WT053) | ws01 | chief_command / C0mm@nd_Ch1ef! (DA+EA) | ✅ VERIFIED 2026-08-01 — `certipy auth` → NT hash `81c3b644…f1eb7b` |
| ESC2 | ADCS ESC2 — Any Purpose EKU (CADRE-ESC2) | ws01 | hunter_dfir → admin | ✅ VERIFIED 2026-08-01 — Req 45 + PKINIT TGT as administrator (also flags ESC3+ESC17) |
| ESC4 | ADCS ESC4 — WriteDacl (CADRE-ESC4) | ws01 | lead_engineering | ✅ VERIFIED 2026-08-01 — template modify → Req 47 → NT hash; **template restored** |
| ESC7 | ADCS ESC7 — CA officer/manager (cadre-CA) | ws01 | lead_engineering | ✅ VERIFIED 2026-08-01 — `certipy ca -add-officer` succeeded (ManageCA) + cleaned |
| ESC9 | ADCS ESC9 — NoSecurityExtension (CADRE-ESC9) | ws01 | hunter_dfir → admin | ✅ VERIFIED 2026-08-01 — Req 46 + PKINIT TGT + UnPAC NT hash |
| ESC11 | ADCS ESC11 — ICPR no encryption (cadre-CA) | ws01 | — | 🔬 Deferred with ESC8 (relay family) |

- [x] **T050** ADCS ESC1 — surface check ✅ · attack run ✅ · tracker · telemetry
- [x] **T051** ADCS ESC3 — surface check ✅ · attack run ✅ · tracker · telemetry
- [~] **T052** ADCS ESC8 — deferred (no SMB coerce on Server 2025) · revisit at end · tracker · telemetry
- [x] **T053** UnPAC-the-Hash — surface check ✅ · attack run ✅ (NT hash recovered) · tracker · telemetry
- [x] **ESC2** Any Purpose EKU — surface check ✅ · attack run ✅ (PKINIT admin) · tracker · telemetry
- [x] **ESC4** WriteDacl — surface check ✅ · attack run ✅ (template modify + enroll + restore) · tracker · telemetry
- [x] **ESC7** CA officer — surface check ✅ · attack run ✅ (add/remove officer) · tracker · telemetry
- [x] **ESC9** NoSecurityExtension — surface check ✅ · attack run ✅ (PKINIT + UnPAC) · tracker · telemetry

### Branch D — Linux pivot

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| 044 | MSSQL Linked Server Recon (WT044) | ws01 -> mbr01 | child\analyst_t1 / T13r_An@lyst! | ✅ Verified |
| 045 | SSSD Ticket Extraction (WT045) | linux01 | mssql-linux01 pivot | ✅ VERIFIED 2026-08-01 — SSSD cache active after keytab fix |
| 046 | MSSQL Keytab Extraction (WT046) | linux01 | mssql-linux01 pivot → root | ✅ VERIFIED 2026-08-01 — keytab readable from pivot root |
| 047 | NFS Kerberos Mount (WT047) | linux01 | mssql-linux01 + TGT | ✅ VERIFIED 2026-08-01 — krb5p mount + read (svcgssd/idmapd/SPN fixed); write denied (root-owned 0755 dir) |
| 048 | Podman Container Escape (WT048) | linux01 | mssql-linux01 → sudo root | ✅ VERIFIED 2026-08-01 — `unshare -r id` → root + host read/write |

- [x] **T044** MSSQL Linked Server Recon — surface check · attack run · telemetry captured · tracker updated
- [x] **T045** SSSD Ticket Extraction — surface check ✅ · attack run ✅ · tracker · telemetry
- [x] **T046** MSSQL Keytab Extraction — surface check ✅ · attack run ✅ · tracker · telemetry
- [x] **T047** NFS Kerberos Mount — surface check ✅ · attack run ✅ (krb5p mount+read) · tracker · telemetry
- [x] **T048** Podman Container Escape — surface check ✅ · attack run ✅ (root) · tracker · telemetry

### Branch G — Pre-auth DC CVE lab

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| CVE-2026-41089 | Netlogon CLDAP Stack Buffer Overflow | Kali -> dc02 | None (unauthenticated UDP/389) | 🆕 Ready, untested |

- [ ] **T007** CVE-2026-41089 — snapshot dc02 · attack run · telemetry captured · tracker updated

### Stream E — Network defense

> **Status (2026-08-02):** Attack side **✅ COMPLETE** — all 13 simulated attacks (WT069–081) + E-10 SNI validated from `ws01` (scripts `attack-matrix/04-automation/campaign-e/ws01-campaign-e.ps1` / `-fix.ps1`). **Detection rules already deployed** in ELK/Suricata/Zeek (`13-net-monitor.yml`: `cadre-ad/phaseb/et-lab/coercion` rules + `cadre-outbound/conn-beacon` Zeek scripts). **PENDING (all that remains):** per-item rule fire-confirmation + telemetry capture + tracker update — deferred to **Plan 1 telemetry catalog** (monitor `.55` unreachable during the ws01 run). **WT093 Ransomware** tracked separately → future Branch R (`plan1.8-offensive-upgrades.md` §7).

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| E-01 | Kerberoast detection | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Rule validate pending |
| E-02 | DCSync detection | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Rule validate pending |
| E-03 | AS-REP roast detection | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Rule validate pending |
| E-04 | DGA detection | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Rule validate pending |
| E-05 | DNS TXT exfil | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Rule validate pending |
| E-06 | DNS NXDOMAIN burst | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Rule validate pending |
| E-07 | TLS 1.0 usage | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Rule validate pending |
| E-08 | SNI anomaly | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Rule validate pending |
| E-09 | Cipher suite anomaly | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Rule validate pending |
| E-10 | Self-signed cert chain | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Rule validate pending |
| E-11 | SMB admin share | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Rule validate pending |
| E-12 | SMBv1 attempt | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Rule validate pending |
| E-13 | HTTP user-agent anomaly | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Rule validate pending |
| E-14 | Exploit path telemetry | monitor VM (192.168.77.55) | None / SIEM analyst | ⏳ Rule validate pending |

- [ ] **E-01** Kerberoast detection — rule validate · telemetry captured · tracker updated
- [ ] **E-02** DCSync detection — rule validate · telemetry captured · tracker updated
- [ ] **E-03** AS-REP roast detection — rule validate · telemetry captured · tracker updated
- [ ] **E-04** DGA detection — rule validate · telemetry captured · tracker updated
- [ ] **E-05** DNS TXT exfil — rule validate · telemetry captured · tracker updated
- [ ] **E-06** DNS NXDOMAIN burst — rule validate · telemetry captured · tracker updated
- [ ] **E-07** TLS 1.0 usage — rule validate · telemetry captured · tracker updated
- [ ] **E-08** SNI anomaly — rule validate · telemetry captured · tracker updated
- [ ] **E-09** Cipher suite anomaly — rule validate · telemetry captured · tracker updated
- [ ] **E-10** Self-signed cert chain — rule validate · telemetry captured · tracker updated
- [ ] **E-11** SMB admin share — rule validate · telemetry captured · tracker updated
- [ ] **E-12** SMBv1 attempt — rule validate · telemetry captured · tracker updated
- [ ] **E-13** HTTP user-agent anomaly — rule validate · telemetry captured · tracker updated
- [ ] **E-14** Exploit path telemetry — rule validate · telemetry captured · tracker updated

### Stream F — Supply chain

> **Status (2026-08-02):** Environment **✅ VERIFIED** on both VMs (`16-supplychain-verifyOnly.yml`: linux01 15/15, mbr01 6/6; mbr01 scenario-path check fixed to canonical `C:\Tools\npm-threat-emulation\scenarios`; windows scripts staged + author refs stripped on mbr01/linux01). **Attack side ⚠️ PARTIAL on linux01:** 8/9 scenarios execute clean (1,2,3,5,6,7,8,9); mock sink captured **+4 exfil payloads**; auditd `npm_node_exec` events confirmed firing. **Scenario 4 env-gated** (npm install to public registry hangs offline). **PENDING (what remains):** per-scenario fire-confirmation + telemetry capture + tracker update — deferred to **Plan 1 telemetry catalog** (same gate as Stream E). Future: independent CADRE NPM-Chain upgrade (`plan1.8-offensive-upgrades.md` §11).

| ID | Attack | Source | Credential | Status |
|----|--------|--------|------------|--------|
| F-01 | npm install lifecycle script exfil | linux01 / mbr01 | npm project context | ⏳ Not exercised |
| F-02 | npm postinstall payload drop | linux01 / mbr01 | npm project context | ⏳ Not exercised |
| F-03 | npm package name typosquat | linux01 / mbr01 | npm publish context | ⏳ Not exercised |
| F-04 | npm manifest token leak | linux01 / mbr01 | npm project context | ⏳ Not exercised |
| F-05 | npm CI cache poisoning | linux01 / mbr01 | CI context | ⏳ Not exercised |
| F-06 | npm dist-tag pollution | linux01 / mbr01 | npm publish context | ⏳ Not exercised |
| F-07 | npm shim/launcher hijack | linux01 / mbr01 | local user | ⏳ Not exercised |
| F-08 | npm workspace cross-package script | linux01 / mbr01 | npm workspace context | ⏳ Not exercised |
| F-09 | npm proxy / registry MITM | linux01 / mbr01 | network position | ⏳ Not exercised |
| F-10 | npm audit ignore supply-chain risk | linux01 / mbr01 | npm project context | ⏳ Not exercised |
| F-11 | GitHub Actions cache poisoning analog | linux01 / mbr01 | CI context | ⏳ Not exercised |
| F-12 | npm tag pollution analog | linux01 / mbr01 | npm publish context | ⏳ Not exercised |
| F-13 | prepare hook persistence | linux01 / mbr01 | npm publish context | ⏳ Not exercised |

- [ ] **F-01** npm lifecycle script exfil — scenario run · telemetry captured · tracker updated
- [ ] **F-02** npm postinstall payload drop — scenario run · telemetry captured · tracker updated
- [ ] **F-03** npm typosquat — scenario run · telemetry captured · tracker updated
- [ ] **F-04** npm manifest token leak — scenario run · telemetry captured · tracker updated
- [ ] **F-05** npm CI cache poisoning — scenario run · telemetry captured · tracker updated
- [ ] **F-06** npm dist-tag pollution — scenario run · telemetry captured · tracker updated
- [ ] **F-07** npm shim/launcher hijack — scenario run · telemetry captured · tracker updated
- [ ] **F-08** npm workspace cross-package script — scenario run · telemetry captured · tracker updated
- [ ] **F-09** npm proxy / registry MITM — scenario run · telemetry captured · tracker updated
- [ ] **F-10** npm audit ignore risk — scenario run · telemetry captured · tracker updated
- [ ] **F-11** GitHub Actions cache poisoning analog — scenario run · telemetry captured · tracker updated
- [ ] **F-12** npm tag pollution analog — scenario run · telemetry captured · tracker updated
- [ ] **F-13** prepare hook persistence — scenario run · telemetry captured · tracker updated

### Re-test priorities

1. ~~**T102** dc02$ TGT capture~~ — **DONE 2026-07-31** (hostname listener → TGT → DCSync). 
2. ~~**Branch A** after T015~~ — **DONE 2026-07-31/08-01** (013/014/015/016/023/024/025/008/GPP + **WT027 SPN Jacking** all verified).
3. ~~**Branch B ADCS scripts**~~ — **DONE 2026-08-01** (ESC1/2/3/4/7/9 + UnPAC). ESC8/11 🔬 deferred (relay family — no SMB coerce on Server 2025).
4. **Branch C SCCM chain** — **WT037 CMPivot + WT038 app deploy + WT039 script-as-SYSTEM ✅ FULL EXEC VERIFIED 2026-08-02** (see `docs/sccm-integration-guide.md` Phase 6B/6C); remaining WT035 PXE (needs PXE client), WT036 relay (console-created device).
5. ~~**Branch D** extraction exercises (WT045-048)~~ — **DONE 2026-08-01** (all verified).
6. **Branch G** CVE-2026-41089 from Kali against dc02 with snapshot.
7. **Stream E** exercises on monitor VM once elk/monitor are online.
8. **Stream F** supply-chain scenarios on linux01/mbr02/npm registry.

### Defender / Tamper Protection (re-verified 2026-07-31 11:20 UTC)

- [x] **DEF-001** Defender OFF on all Windows VMs — dc01/dc02/dc03/mbr01/mbr02: WinDefend **Stopped** + `DisableAntiSpyware=1` (04-vulnerabilities kill) · ws01: RTP/TP `False` + `DisableAntiSpyware=1` + RTP/Behavior/IOAV/OnAccess policy blocks + SpyNet=0 + tooling excludes (`C:\Temp;C:\Tools;...` + mimikatz/Rubeus/etc.) · WinDefend service stays **Running** on ws01 by design — Win 11 Ent 26200 client SKU hard-protects the service: `Set/Stop-Service`, `sc.exe`, and a SYSTEM scheduled task all return `Access denied` (`OpenService FAILED 5`). Matches `17-ws01-deploy.yml` soft-disable design.
- [x] **DEF-002** Root cause of Rubeus `golden` silent failure isolated — persists after full Defender kill → **Rubeus binary quirk**, not EDR. Use mimikatz `kerberos::golden` (verified).
- [x] **DEF-003** MBR01 re-checked CIM-free (2026-07-31): `WinDefend=Stopped|DisableAntiSpyware=1|DisableRealtimeMonitoring=1` — earlier blank MPSTAT was a WMI/CIM access-denied quirk for `analyst_t1` on MBR01, not a Defender issue.

---

## P11 — Plan 1.1 campaign automation (RedStrike) — **NEXT**

**Plan:** [`docs/internal/plan01-telemetry-catalog/plan1.1-campaign-automation/`](docs/internal/plan01-telemetry-catalog/plan1.1-campaign-automation/) · **Sister:** [`RedStrike/CAMPAIGN-AUTOMATION-PLAN.md`](../RedStrike/CAMPAIGN-AUTOMATION-PLAN.md) · **Routing:** [`WS01-ROUTING.md`](attack-matrix/04-automation/linux/lib/WS01-ROUTING.md)

> Plan 1.1 **complete** (M0–M5 + P11.6). Automates spine + Branches A–D/G + E/F streams under provisioning→ws01 rules so Plan 1 telemetry can scale.

| ID | Item | Status | Done | Owned by | Notes |
|----|------|--------|------|----------|-------|
| P11.0 | Plan docs committed (CADRE plan1.1 + RedStrike mirror) | [x] | 2026-07-25 | `plan01-telemetry-catalog/plan1.1-campaign-automation/` · `RedStrike/CAMPAIGN-AUTOMATION-PLAN.md` | Registered in `PLANS.md` |
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

**Pipeline:** deterministic replay → capture across all sources → fill grid → write rules → E2E → Sigma YAML. **Dir:** [`docs/internal/plan01-telemetry-catalog/phase1-source-matrix/`](docs/internal/plan01-telemetry-catalog/phase1-source-matrix/)

**Two-phase approach (2026-07-27 → 2026-07-28):**
- **Phase 1 — Full RedStrike attack run:** ✅ **complete** — `camp-v3-20260803` (2026-08-03) + prior `P1_*` engagements (2026-07-28).
- **Phase 2 — Telemetry capture:** now active — replay attacks deterministically, export ES/Zeek/Suri/Endpt evidence bundles, fill `source-matrix-grid.md`, then write Sigma/KQL rules.

| ID | Item | Status | Done | Owned by | Notes |
|----|------|--------|------|----------|-------|
| P1.0 | **Phase 1 — full RedStrike attack run** (validate tool + campaign) | [x] | 2026-08-03 | `redstrike-campaign` on `.60` | `camp-v3-20260803`; tracker = [`REDSTRIKE-VALIDATION-REPORT.md`](attack-matrix/Campaign/REDSTRIKE-VALIDATION-REPORT.md) |
| P1.1 | Deterministic replay bundle: spine T003/T002/T041/T043/T017/T009/T010/T011/T012/T033/T042 | [ ] | | `campaign-a/` scripts + `cadre-es-export.sh` | Use fixed T0 per attack |
| P1.2 | Deterministic replay bundle: branches A/B/C/D/G + streams E/F | [ ] | | same | Branch A ws01 scripts new this session |
| P1.3 | `source-matrix-grid.md` fill — Campaign A (12 attacks) | [~] | 2026-07-25 | `source-matrix-grid.md` + `verification-table.md` | ✅ T002/T003/T031/T041/T043; ⛔ T028; 🔧 T042; 5 cred-gated |
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
| H — Initial access | 6 | 5 | 1 (H-03 platform-blocked) |
| **Total** | **~110** | **21** | **6+** |

---

## P17 — Plan 1.7 defense engineering (deploy with Plan 1)

**Folder:** [`docs/internal/plan01-telemetry-catalog/plan1.7-defense-engineering/`](docs/internal/plan01-telemetry-catalog/plan1.7-defense-engineering/) · **Specs:** [`plan01-telemetry-catalog/plan1.7-defense-engineering/plan1.7-defense-deepening.md`](docs/internal/plan01-telemetry-catalog/plan1.7-defense-engineering/plan1.7-defense-deepening.md) · **Exercises:** [`plan01-telemetry-catalog/plan1.7-defense-engineering/plan1.7-exercises.md`](docs/internal/plan01-telemetry-catalog/plan1.7-defense-engineering/plan1.7-exercises.md)

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

**Folder:** [`docs/internal/plan01-telemetry-catalog/plan1.8-offensive-upgrades/`](docs/internal/plan01-telemetry-catalog/plan1.8-offensive-upgrades/) · **Specs:** [`plan01-telemetry-catalog/plan1.8-offensive-upgrades/plan1.8-offensive-upgrades.md`](docs/internal/plan01-telemetry-catalog/plan1.8-offensive-upgrades/plan1.8-offensive-upgrades.md)

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


## Campaign Re-test Tracker

> Branch A/B/D rows (013/014/015/016/023/024/025/008/GPP/050/051/053/ESC2-9/044-048) are all **VERIFIED** — see validation report body. Only open items below.

| ID | Attack | Source | Credential | Status | Notes |
|---|---|---|---|---|---|
| WT027 | SPN Jacking (CVE-2026-25177) | ws01 | chief_command (writeSPN) → analyst_cloud | ✅ VERIFIED 2026-08-01 | Planted MSSQLSvc/dc01.cadre.local:14333 → KDC TGS (AES) w/ analyst_cloud key; cleaned. Self-write NOT viable (SPN 1433 owned by svc_mssql; validated-write on self). |
| WT052 | ESC8 | ws01 | chief_command | 🔬 Deferred | No SMB-authenticated coerce on Server 2025; revisit at end (krbrelayx). |
| ESC11 | ESC11 (ICPR) | ws01 | chief_command | 🔬 Deferred | Relay family — deferred with ESC8. |
| E-01..14 | Network defense | monitor/elk | — | ⏳ Configured | Offline until telemetry phase. |
| F-01..13 | npm supply-chain | linux01/mbr01 | — | ⏳ Configured | Scenarios pending. |
| G | CVE-2026-41089 | Kali | — | 🔬 Deferred | PoC present; dc02 patch state + snapshot. |
| H-01..06 | Initial access | provisioning/ws01 | 19-initial-access.yml | ✅ 5/6 verified 2026-08-03 | H-01/02/04/05/06 verified (provisioning→ws01); H-03 build+content verified, exec platform-blocked (hh.exe sandbox) |

