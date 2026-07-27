# CAMPAIGNS v3 — Runbook Index

> **Purpose:** One runbook per phase — **full narrative + commands** for learning and live testing.
> **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Lab RAM modules:** [`LAB-PROFILES.md`](../LAB-PROFILES.md)
> **Tracking:** [`CHECKLIST.md`](../../../CHECKLIST.md) (repo root) — flip campaign + telemetry items each session.
> **Older index:** [`CAMPAIGNS.md`](../CAMPAIGNS.md) · **Metadata:** [`CAMPAIGNS-METADATA.md`](../CAMPAIGNS-METADATA.md) · **DFIR:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)

**Default host:** Kali / provisioning (`192.168.77.60`) unless a runbook says otherwise.  
**Before Phase 0.5:** start **P-BEACH** in [`LAB-PROFILES.md`](../LAB-PROFILES.md) — Kali + **ws01** (`.62`) + **dc02** (`.11`).

### Preview flashes then goes blank?

Cursor preview can **flash content then clear** when the file is too large or the webview re-renders in a loop.

1. **Reload window** once after pulling these fixes (`Developer: Reload Window`).
2. **Use side preview** — `Ctrl+K` then `V` (not the inline preview tab).
3. **Open the index files** (not the huge detail files):
   - `CAMPAIGNS-METADATA.md` (~1k lines) — not `CAMPAIGNS-METADATA-mechanics.md`
   - `Campaign_suggestions.md` (~130 lines) — not `Campaign_suggestions-detail.md`
   - `CAMPAIGNS-RUNBOOK-0.md` — Step 7 ADeleg is in [`CAMPAIGNS-RUNBOOK-0-addeleg.md`](CAMPAIGNS-RUNBOOK-0-addeleg.md)
4. Workspace setting `markdown.preview.updateOnKeystroke` is **off** in `.vscode/settings.json` to stop flicker while typing.

---

## Main spine (open in order)

| Phase | Runbook | Status |
|-------|---------|--------|
| **0** | [`CAMPAIGNS-RUNBOOK-0.md`](CAMPAIGNS-RUNBOOK-0.md) | ⏳ / partial verified |
| **0.5** | [`CAMPAIGNS-RUNBOOK-H.md`](CAMPAIGNS-RUNBOOK-H.md) | 🔨 Active — ws01 initial access |
| **1** | [`CAMPAIGNS-RUNBOOK-1.md`](CAMPAIGNS-RUNBOOK-1.md) | ✅ AS-REP verified |
| **2** | [`CAMPAIGNS-RUNBOOK-2.md`](CAMPAIGNS-RUNBOOK-2.md) | ✅ Kerberoast verified |
| **3** | [`CAMPAIGNS-RUNBOOK-3.md`](CAMPAIGNS-RUNBOOK-3.md) | ✅ SQL → GodPotato verified |
| **3.5** | [`CAMPAIGNS-RUNBOOK-3.5.md`](CAMPAIGNS-RUNBOOK-3.5.md) | 🔨 Active |
| **4** | [`CAMPAIGNS-RUNBOOK-4.md`](CAMPAIGNS-RUNBOOK-4.md) | ⏳ |
| **5** | [`CAMPAIGNS-RUNBOOK-5.md`](CAMPAIGNS-RUNBOOK-5.md) | ⏳ |
| **6** | [`CAMPAIGNS-RUNBOOK-6.md`](CAMPAIGNS-RUNBOOK-6.md) | ⏳ |
| **7** | [`CAMPAIGNS-RUNBOOK-7.md`](CAMPAIGNS-RUNBOOK-7.md) | ⏳ |
| **8** | [`CAMPAIGNS-RUNBOOK-8.md`](CAMPAIGNS-RUNBOOK-8.md) | ⏳ |

## Optional branches

| Branch | Runbook | When |
|--------|---------|------|
| **A** ACL abuse | [`CAMPAIGNS-RUNBOOK-branch-a.md`](CAMPAIGNS-RUNBOOK-branch-a.md) | After Phase 4 BH reveals ACEs |
| **B** ADCS | [`CAMPAIGNS-RUNBOOK-branch-b.md`](CAMPAIGNS-RUNBOOK-branch-b.md) | After Phase 4 / ADeleg ADCS scan |
| **C** SCCM | [`CAMPAIGNS-RUNBOOK-branch-c.md`](CAMPAIGNS-RUNBOOK-branch-c.md) | After Phase 8 cross-forest access |
| **D** Linux pivot | [`CAMPAIGNS-RUNBOOK-branch-d.md`](CAMPAIGNS-RUNBOOK-branch-d.md) | After Phase 3 SQL linked-server recon |

## Standalone exercises

| Stream | Runbook | Scripts |
|--------|---------|---------|
| **E** Network defense (14) | [`CAMPAIGNS-RUNBOOK-e.md`](CAMPAIGNS-RUNBOOK-e.md) | `../../04-automation/campaign-e/wt069-*.sh` |
| **F** Supply chain (10) | [`CAMPAIGNS-RUNBOOK-f.md`](CAMPAIGNS-RUNBOOK-f.md) | `../../../docs/internal/npm-supplychain-installation-guide.md` |
| **G** Pre-auth DC CVE lab | [`CAMPAIGNS-RUNBOOK-exercises-g.md`](CAMPAIGNS-RUNBOOK-exercises-g.md) | Snapshot required |

---

## Format rules (when editing)

1. **Edit runbook + `CAMPAIGNS_v3.md` together** — same section in both files; runbooks are primary for lab work.
2. **Keep explanations** — theory, tables, detection notes, and prerequisites stay in the runbook.
3. **One command per fenced block** where practical — comments above the block, not inside.
4. **Study references** for phases 3.5, 4, 6, 8 are appended at the end of those runbooks (from v3 Study Reference Library).
5. **Verify coverage:** `python tools/split-campaign-runbooks.py --check` (v2 only; v3 runbooks are manually synced).
