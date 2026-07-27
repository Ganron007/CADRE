# CADRE — Attack Campaign (index)

> **Current:** **[`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md)** — ws01 beachhead, Plan 1.1 dual assume-breach routing, Branches A–D.  
> **Automation:** [`docs/internal/plan1.1-campaign-automation/`](../../docs/internal/plan1.1-campaign-automation/) · **Routing:** [`WS01-ROUTING.md`](../04-automation/linux/lib/WS01-ROUTING.md)  
> **v2 monolith (legacy reference):** [`CAMPAIGNS_v2.md`](CAMPAIGNS_v2.md) · **Archived v1:** [`CAMPAIGNS_v1_archived.md`](CAMPAIGNS_v1_archived.md)

**v3 totals:** 81 campaign + 14 E + 10 F = **105**.

## Phase runbooks

Open **one runbook per phase**. Prefer narrative alignment with **v3** (`CAMPAIGNS_v3.md`); some runbooks still track v2 split until regen.

| Phase / stream | Runbook | Notes |
|----------------|---------|-------|
| **0** Recon | [`Runbooks/CAMPAIGNS-RUNBOOK-0.md`](Runbooks/CAMPAIGNS-RUNBOOK-0.md) | Zero creds / Phase 0 allowlist |
| **0.5** Beachhead | [`Runbooks/CAMPAIGNS-RUNBOOK-H.md`](Runbooks/CAMPAIGNS-RUNBOOK-H.md) | ws01 phishing **or** Plan 1.1 assume-breach |
| **1** Initial access | [`Runbooks/CAMPAIGNS-RUNBOOK-1.md`](Runbooks/CAMPAIGNS-RUNBOOK-1.md) | AS-REP |
| **2** Cred harvest | [`Runbooks/CAMPAIGNS-RUNBOOK-2.md`](Runbooks/CAMPAIGNS-RUNBOOK-2.md) | Kerberoast |
| **3** Execution | [`Runbooks/CAMPAIGNS-RUNBOOK-3.md`](Runbooks/CAMPAIGNS-RUNBOOK-3.md) | SQL → GodPotato · SQL AI alt |
| **3.5** Cred theft | [`Runbooks/CAMPAIGNS-RUNBOOK-3.5.md`](Runbooks/CAMPAIGNS-RUNBOOK-3.5.md) | |
| **4** Discovery | [`Runbooks/CAMPAIGNS-RUNBOOK-4.md`](Runbooks/CAMPAIGNS-RUNBOOK-4.md) | BloodHound → branches |
| **5** Lateral | [`Runbooks/CAMPAIGNS-RUNBOOK-5.md`](Runbooks/CAMPAIGNS-RUNBOOK-5.md) | Coercion |
| **6** DCSync | [`Runbooks/CAMPAIGNS-RUNBOOK-6.md`](Runbooks/CAMPAIGNS-RUNBOOK-6.md) | |
| **7** Forest trust | [`Runbooks/CAMPAIGNS-RUNBOOK-7.md`](Runbooks/CAMPAIGNS-RUNBOOK-7.md) | |
| **8** Cross-forest | [`Runbooks/CAMPAIGNS-RUNBOOK-8.md`](Runbooks/CAMPAIGNS-RUNBOOK-8.md) | + SCCM entry |
| **A** ACL | [`Runbooks/CAMPAIGNS-RUNBOOK-branch-a.md`](Runbooks/CAMPAIGNS-RUNBOOK-branch-a.md) | Plan 1.1 M3 |
| **B** ADCS + UnPAC | [`Runbooks/CAMPAIGNS-RUNBOOK-branch-b.md`](Runbooks/CAMPAIGNS-RUNBOOK-branch-b.md) | Full ESC + UnPAC |
| **C** SCCM WT034–039 | [`Runbooks/CAMPAIGNS-RUNBOOK-branch-c.md`](Runbooks/CAMPAIGNS-RUNBOOK-branch-c.md) | Full site chain |
| **D** Linux | [`Runbooks/CAMPAIGNS-RUNBOOK-branch-d.md`](Runbooks/CAMPAIGNS-RUNBOOK-branch-d.md) | |
| **E / F / G** | [`e`](Runbooks/CAMPAIGNS-RUNBOOK-e.md) · [`f`](Runbooks/CAMPAIGNS-RUNBOOK-f.md) · [`g`](Runbooks/CAMPAIGNS-RUNBOOK-exercises-g.md) | Standalone / Plan 1.1 M5 |

**Full narrative:** [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md) · **Metadata:** [`CAMPAIGNS-METADATA.md`](CAMPAIGNS-METADATA.md) · **Lab profiles:** [`LAB-PROFILES.md`](LAB-PROFILES.md) · **DFIR:** [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md)

**Editing:** Update runbook + matching `CAMPAIGNS_v3.md` section together.

---

## Routing quick reference (Plan 1.1)

| Path | Use |
|------|-----|
| **ws01** | Primary egress; `analyst_t1` Local Admin (config via Ansible) |
| **kali/provisioning** | Alt beachhead (optional domain-join); origin blind OK |
| **stage_mbr01** | Exception only if ws01 blocked |

See [`WS01-ROUTING.md`](../04-automation/linux/lib/WS01-ROUTING.md).
