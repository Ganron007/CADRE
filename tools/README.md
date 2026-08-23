# CADRE — `tools/` directory

**Path:** `C:\STUDY\Github\CADRE-Platform\CADRE\tools\`  
**Last updated:** 2026-08-20

> **Policy:** Plan **1.1** (RedStrike campaign automation) is **done**. **Plan 01 campaigns use `tools/red-strike/`**. Sister `RedStrike\` is the engine SSoT — always sync into this pin (`sync-redstrike-pin.ps1`) and onto provisioning (`-PushKali`).

---

## Layout

| Path | Plan | Status | When to integrate |
|------|------|--------|-------------------|
| [`lab-vm-reboot.ps1`](lab-vm-reboot.ps1) | **1 / DFIR** | ✅ | Graceful `vmrun reset … soft` of running CADRE VMs + WS01; wait WinRM/SSH/ES. |
| [`lab-log-reset.sh`](lab-log-reset.sh) / [`lab-log-reset.ps1`](lab-log-reset.ps1) | **1 / DFIR** | ✅ | Pre-run wipe: Windows event logs + linux01 + monitor files + ES `logs-*` docs. Playbooks `20-lab-log-reset.yml` (+ verifyOnly). |
| [`redstrike-dfir-full.ps1`](redstrike-dfir-full.ps1) / [`dfir-spine-bootstrap.sh`](dfir-spine-bootstrap.sh) | **1 / DFIR** | ✅ | Full graph v9 RedStrike dry-run on provisioning pin. Pair: `04-automation/linux/redstrike-dfir-full.sh`. `--execute` is operator-gated. |
| [`cadre-es-export.sh`](cadre-es-export.sh) | **1** | ✅ | Evidence bundles from provisioning → ES |
| [`dfir-nexus-extension/`](dfir-nexus-extension/) | **7** | ⏸ Scaffold | With Plan 7 portal/push |
| [`sync-redstrike-pin.ps1`](sync-redstrike-pin.ps1) | **1.1 / Plan 01** | ✅ | Adopt standalone `RedStrike\` HEAD into the pin; `-PushKali` installs it on provisioning. Overlay: `red-strike-pin-overlay.patch`. |
| [`red-strike/`](red-strike/) | **1.1 / Plan 01** | ✅ Pin 0.6.0 (always follow standalone HEAD) | **Only Plan 01 / CADRE-assessment engine.** Graphs/missions stay in CADRE. |
| [`regen-config/`](regen-config/) | **0** | ✅ | `config.json` regen from ansible |
| [`deploy-harness/`](deploy-harness/) | **0** | ✅ | Config drift tests |
| [`split-campaign-runbooks.py`](split-campaign-runbooks.py) | Campaign | ✅ | Runbook split/check |
| [`audit-campaign-runbooks.py`](audit-campaign-runbooks.py) | Campaign | ✅ | Coverage audit |
| [`render-campaign-preview.py`](render-campaign-preview.py) | Campaign | ✅ | Preview helper |

**External clones (read-only):** `CADRE-Integrations/` — e.g. **C2Stack** + Loki for **Plan 10** (not in `tools/` until integration phase).

---

## Plan gates (summary)

**Maintainer-local (gitignored, not listed above):** `vm-access.md`, `plan1-*.sh`, `es-*.json`, `dfir-full-live.ps1`, `dfir-spine-live.ps1`, and related Plan 1 batch harness scripts.

```text
Plan 1.1 ✅ → red-strike pin + Campaign/automation glue (done)
Plan 1    → cadre-es-export, campaign tooling + RedStrike runs
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
