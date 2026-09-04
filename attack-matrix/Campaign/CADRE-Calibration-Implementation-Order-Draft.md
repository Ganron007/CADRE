# CADRE Calibration — Implementation Order

> **Status:** Draft for operator review.  
> **Source:** Follow-up to `CADRE-v3-Architecture-Review-Draft-2026-08-23.md` and `CADRE-AD2025-Real-World-Vectors-Decision-Draft.md`.  
> **Purpose:** Concrete, ordered steps to calibrate the v3 campaign into a reliable, reproducible, enterprise-grade attack chain. Each step is actionable — not another planning doc.  
> **Scope:** Main spine (Phases 0.5-8) + Branches A-D. SCCM/ADCS/SQL remain manual/snapshot branches. E/F/G/H stay separate streams.  

---

## Critical Path

**Step 2 (manual verification) is the critical path.** Everything else depends on knowing which 25 items actually work. Do not skip it.

---

## Step 1 — Lock the Enterprise Campaign scope (1 day)

**Goal:** Stop treating all 119 items as the campaign. Define the 25-item green core as the executable campaign.

**Actions:**
1. Edit `CAMPAIGNS_v3.md` — add a top section "Enterprise Campaign Scope" listing the 25 green items from Appendix A of `CADRE-v3-Architecture-Review-Draft-2026-08-23.md`.
2. Move E/F/G, post-DA extras, 3.5 technique list, and 9 coercion primitives into a new section "Technique Catalog (Reference)" — same file, clearly separated.
3. Move Server-2025-blocked items into a "Platform-Blocked" subsection with reason codes.
4. Update `Runbooks/CAMPAIGNS-RUNBOOK-README.md` to point to three tiers: Enterprise Campaign, Technique Catalog, Research Backlog.
5. Reconcile the count drift: pick one number (25 enterprise + catalog) and update `CAMPAIGNS-METADATA-v2.md` and `CAMPAIGNS-VALIDATION-REPORT.md` to match.

**Verification:** `CAMPAIGNS_v3.md` clearly shows "25 enterprise campaign items" at the top; the rest marked as catalog/reference.

**Dependency:** None.

---

## Step 2 — Run the Operator Verification Checklist manually (your time, VMs online)

**Goal:** You said you don't trust the validation report. This is where you verify it yourself.

**Actions:**
1. Power on the lab: `vagrant up` for the core VMs (dc01, dc02, mbr01, ws01, elk, monitor).
2. Restore snapshots if needed: `adcs-templates-done`, `sccm-done` if testing Branches B/C.
3. Run `ansible-playbook 20-lab-log-reset.yml` to clear stale telemetry.
4. Follow `CADRE-Operator-Verification-Checklist-Draft.md` row by row:
   - Phase 0.5 → Phase 8, then Branches A-D.
   - Mark each row PASS / FAIL / NOT-TESTED.
   - A FAIL stops the chain — fix it before proceeding.
5. For every FAIL, note the root cause in the validation report.

**Output:** A signed-off checklist with real PASS/FAIL per item. This becomes your new ground truth, replacing the self-reported validation.

**Dependency:** VMs online.

**This is the most important step.** Everything else depends on knowing which 25 items actually work.

---

## Step 3 — Fix or remove the missing playbook surfaces (1-2 weeks)

**Goal:** Every attack in the 25-item campaign must have its surface created by a playbook or explicitly marked "manual setup required."

**Actions, in priority order:**

| Item | Action | Playbook |
|---|---|---|
| LAPS | Either deploy LAPS v2 via playbook OR remove WT100/3.5L from campaign | `04-vulnerabilities.yml` |
| AAD Connect | Deploy AD Connect sync on dc01 or a member server OR remove 3.5M | `15-cloud-sync.yml` |
| WerFault dump keys | Add `DumpFolder` registry config | `04-vulnerabilities.yml` |
| Nemesis tool | Stage on mbr01 | `06-member-services.yml` |
| DCOMIllusionist | Stage on ws01 OR move to catalog | `06-member-services.yml` |
| SSP DLL | Build and stage OR move WT107 to catalog | `06-member-services.yml` |
| DLL-hijack app | Stage a vulnerable app OR move WT104 to catalog | `06-member-services.yml` |
| DPAPI-NG blob | Stage a protected target OR remove WT103 | `05-ad-attack-surface.yml` |
| GPP cpassword | Add `Groups.xml` to SYSVOL OR demote to historical reference | `02-ad-objects.yml` |

**Rule:** If you're not going to fix the surface within 2 weeks, move the attack to the catalog. Don't let it sit as a "failed campaign item."

**Dependency:** Step 2 results (know which surfaces are actually missing vs. which attacks just weren't tested).

---

## Step 4 — Mark ADCS/SCCM/SQL as manual branches (1 day)

**Goal:** Stop pretending these are fully automated. Document the manual setup as part of the campaign.

**Actions:**
1. In `CAMPAIGNS_v3.md`, mark Branch B (ADCS) and Branch C (SCCM) with a "Manual Setup Required" banner:
   - Branch B: requires `adcs-configuration-guide.md` + snapshot `adcs-templates-done`.
   - Branch C: requires `sccm-integration-guide.md` + snapshot `sccm-done`.
2. In each branch runbook, add a "Prerequisites" section at the top listing the manual steps and snapshot name.
3. SQL stays in the main spine — it's already playbook-driven via `04-vulnerabilities.yml`.
4. Update RedStrike intent metadata to include a `manual_setup_required: true` flag for Branch B/C so the LLM knows not to attempt them without operator confirmation.

**Dependency:** None (can be done in parallel with Step 2).

---

## Step 5 — Build the RedStrike green-path state model (1 week)

**Goal:** Give RedStrike a deterministic graph of only the verified green items.

**Actions:**
1. Create `attack-matrix/Campaign/campaign_state.json` with the 25 enterprise items:
   ```json
   {
     "phase": "0.5",
     "id": "H-01",
     "intent": "initial_access.lnk",
     "preconditions": ["session.ws01.analyst_t1"],
     "postconditions": ["session.ws01.analyst_t1.executed"],
     "fallback": ["H-02", "H-05", "H-06"],
     "excluded": false,
     "manual_setup": false
   }
   ```
2. For each node, define:
   - `preconditions` — what state must exist before this attack.
   - `postconditions` — what state this attack produces (credential, ticket, SYSTEM, marker).
   - `fallback` — which alternative attacks to try if this one fails.
   - `excluded` — true if platform-blocked or missing surface.
   - `manual_setup` — true for ADCS/SCCM.
3. Mark all 94 non-enterprise items as `excluded: true` with a `reason` field.
4. RedStrike LLM mode should only read nodes where `excluded: false`.

**Verification:** RedStrike should be able to traverse the graph from Phase 0.5 to Phase 8 without encountering a dead end or an unverified item.

**Dependency:** Steps 1-2 (scope locked + manual verification done).

---

## Step 6 — Fix Plan 1 telemetry tooling (1-2 weeks)

**Goal:** Make telemetry capture reliable before cataloging.

**Actions:**
1. Fix `tools/plan1-orchestrator.sh`:
   - Change `source.ip=192.168.77.60` → `source.ip=192.168.77.62` (ws01).
   - Add host-based query fields (`winlog.computer_name`, `host.name`) alongside source.ip.
   - Replace counts-only export with full event document export.
2. Fix `tools/plan1-strict-ad.sh`:
   - Same source.ip fix.
   - Same full-export fix.
3. Remove or quarantine `tools/plan1-batch-campaign-a.sh` and `tools/plan1-batch-campaign-e.sh` — they violate the no-batching rule.
4. Create a per-phase telemetry runner:
   - Snapshot restore → run one phase → wait for ingest → export full events → save to `docs/internal/plan01-telemetry-catalog/phaseN/`.
5. Build `tracker.md` per phase from the exports.

**Verification:** Run Phase 1 (AS-REP) through the fixed orchestrator and confirm:
- WinSec 4768 events captured from ws01.
- Zeek Kerberos AS-REQ captured.
- Full event documents exported (not just counts).

**Dependency:** Step 2 (need verified attacks to capture telemetry for).

**Rule reminder:** Per `plan1-telemetry.mdc` — no batching, no early ES, no Zeek-PRIMARY demotion without ingest-gap note.

---

## Step 7 — Test the new Campaign H vectors (1-2 weeks)

**Goal:** Validate the 6 new initial-access candidates under real MDE P2.

**Actions:**
1. Install prerequisites on ws01: OneNote, Office, .NET Framework, Edge WebView2, ClickOnce runtime.
2. Build the payloads on provisioning:
   - H-07: `.iso` with LNK inside.
   - H-08: `.one` OneNote with embedded HTML.
   - H-09: `.application` ClickOnce.
   - H-10: `.xll` Excel add-in.
   - H-11: WebView2 packaged app.
   - H-12: `.search-ms` connector.
3. Serve via `provisioning:8081`.
4. On ws01, execute each vector with MDE real-time **enabled**.
5. Check for marker file + MDE telemetry.
6. Promote to `CAMPAIGNS_v3.md` only if: marker present + no MDE block (or MDE alert captured as detection evidence).

**Verification:** Each H-07 through H-12 is either promoted (works under MDE) or rejected (MDE blocks it — still useful as detection evidence).

**Dependency:** VMs online + prereqs installed. Can run in parallel with Steps 3-6.

---

## Step 8 — Promote dMSA / BadSuccessor and add VSS fallback (1 week)

**Goal:** Integrate the Server 2025-specific vectors into the main narrative.

**Actions:**
1. Move WT099 (dMSA / BadSuccessor) from Post-DA catalog to a proper step after Phase 7 or as a Branch A extension.
2. Create a `SeBackupPrivilege` surface on a member or DC via playbook.
3. Add VSS shadow-copy `ntds.dit` extraction as a fallback to DCSync (Phase 6).
4. Write runbook entries for both.

**Dependency:** Step 2 (need to confirm dMSA prereqs still hold).

---

## Step 9 — Gate C2Stack behind Plan 1 completion (1 day)

**Goal:** Don't integrate C2 until telemetry is cataloged.

**Actions:**
1. Add a note to `CAMPAIGNS_v3.md` and RedStrike docs: "C2Stack integration requires Plan 1 telemetry catalog for Phases 0.5-8 to be complete."
2. Do not start C2 adapter work until Step 6 is done for all 25 enterprise items.

**Dependency:** Step 6 complete.

---

## Summary — Execution Order

| Step | What | Time | Dependency | Can Parallel? |
|---|---|---|---|---|
| 1 | Lock enterprise scope | 1 day | None | Yes (with 4) |
| 2 | Manual verification (your time) | Your call | VMs online | **Critical path** |
| 3 | Fix/remove missing surfaces | 1-2 weeks | Step 2 results | Yes (with 7, 8) |
| 4 | Mark ADCS/SCCM as manual | 1 day | None | Yes (with 1) |
| 5 | Build RedStrike state model | 1 week | Steps 1-2 | After 1+2 |
| 6 | Fix Plan 1 telemetry | 1-2 weeks | Step 2 | Yes (with 3, 7, 8) |
| 7 | Test new Campaign H vectors | 1-2 weeks | VMs + prereqs | Yes (with 3, 6, 8) |
| 8 | Promote dMSA + VSS fallback | 1 week | Step 2 | Yes (with 3, 6, 7) |
| 9 | Gate C2Stack | 1 day | Step 6 done | After 6 |

---

## What Not to Do During Calibration

- Do not add new attack vectors to the main spine before Step 2 is complete.
- Do not start C2Stack integration before Step 6 is complete.
- Do not let RedStrike LLM mode attempt any item marked `excluded: true` or `manual_setup: true`.
- Do not treat a telemetry count as proof that an attack succeeded.
- Do not treat an attack marker as proof that telemetry was captured.
- Do not use provisioning as an attack source for any phase except H.
- Do not use scheduled tasks as command execution wrappers.
- Do not collapse the child domain or redesign the distributable tier yet — that decision is deferred.

---

*Draft prepared for review. Do not commit until approved.*
