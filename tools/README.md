# CADRE — `tools/` directory

**Path:** `C:\STUDY\Github\CADRE-Platform\CADRE\tools\`  
**Last updated:** 2026-07-26

> **Policy:** Plan **1.1** (RedStrike campaign automation) is **done**. Focus **Plan 1** telemetry. In-tree pins here mirror sister repos — see `docs/internal/PLANS.md` (local maintainers).

---

## Layout

| Path | Plan | Status | When to integrate |
|------|------|--------|-------------------|
| [`cadre-es-export.sh`](cadre-es-export.sh) | **1** | ✅ In use | Now — evidence bundles from provisioning → ES |
| [`plan1-orchestrator.sh`](plan1-orchestrator.sh) | **1** | ✅ In use | Attack → wait → export → `plan1-results.jsonl` |
| [`plan1-batch-campaign-e.sh`](plan1-batch-campaign-e.sh) | **1** | ✅ In use | E-01..E-15 network defense batch |
| [`plan1-batch-campaign-a-fix.sh`](plan1-batch-campaign-a-fix.sh) | **1** | ✅ In use | T041/T043 MSSQL re-runs |
| [`vm-access.md`](vm-access.md) | **0 / 1** | ✅ In use | Operator + agent SSH/ES reference |
| [`dfir-nexus/`](dfir-nexus/) | **7** | ⏸ Incubator | After Plan 1 + Plan 2 exporter; Ansible on provisioning |
| [`dfir-nexus-extension/`](dfir-nexus-extension/) | **7** | ⏸ Scaffold | With Plan 7 portal/push |
| [`red-strike/`](red-strike/) | **1.1** | ✅ Pin 0.5.0 | SSoT = `RedStrike\`; live on `.60` (see `integrations/red-strike.md`) |
| [`regen-config/`](regen-config/) | **0** | ✅ | `config.json` regen from ansible |
| [`deploy-harness/`](deploy-harness/) | **0** | ✅ | Config drift tests |
| [`split-campaign-runbooks.py`](split-campaign-runbooks.py) | Campaign | ✅ | Runbook split/check |
| [`audit-campaign-runbooks.py`](audit-campaign-runbooks.py) | Campaign | ✅ | Coverage audit |
| [`render-campaign-preview.py`](render-campaign-preview.py) | Campaign | ✅ | Preview helper |

**External clones (read-only):** `CADRE-Integrations/` — e.g. **C2Stack** + Loki for **Plan 10** (not in `tools/` until integration phase).

---

## Plan gates (summary)

```text
Plan 1.1 ✅ → red-strike pin + Campaign/automation glue (done)
Plan 1    → cadre-es-export, vm-access, campaign tooling + RedStrike runs
Plan 2    → export-attack collectors (future; may live under tools/)
Plan 7    → dfir-nexus Ansible + push ingest + Pioneer loop
Plan 10   → C2Stack (Integrations clone) — C2 traffic into telemetry
```

**DFIR standalone testing:** Use Plan 1 bundles on provisioning (`~/cadre-evidence/`). Full `tools/dfir-nexus/` wiring is Plan 7 — not required to finish Plan 1.

---

## Related

| Doc | Role |
|-----|------|
| `docs/internal/PLANS.md` (local maintainers) | Plan index + naming (`plan01-telemetry-catalog` = Plan 1) |
| `docs/internal/core-plan.md` (local maintainers) | Vision + integration map |
| `CHECKLIST.md` (local maintainers) | P1.* now; D7.* deferred |
