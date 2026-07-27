# Phase 0 — Step 7 — ADeleg GUI Recon (supplement)

> **Main runbook:** [CAMPAIGNS-RUNBOOK-0.md](CAMPAIGNS-RUNBOOK-0.md) · **Metadata:** [CAMPAIGNS-METADATA-mechanics.md](../CAMPAIGNS-METADATA-mechanics.md) (ADeleg section)

**Tool:** [ADeleg](https://github.com/trimarc/ADeleg) (Windows GUI). Course notes: `CADRE-Courses/How to Find Insecure Active Directory Permissions with ADeleg/Episode 173 (wildcard).txt`

**Why use ADeleg:** GUI ACL/ADCS recon without SharpHound, Docker, or Neo4j — lower EDR noise than BloodHound collection.

**Workflow (mbr01):**

```powershell
Copy-Item .\ADeleg.exe \\mbr01\C$\Tools\
```

Then RDP to mbr01, run ADeleg.exe, Connect, View → Index View By → Trustees. Check Authenticated Users / Domain Users for unsafe Allow permissions. For ADCS: View by → Resources → Certificate Templates (ESC markers).

**Maps to:** Branch A (14 ACEs), Branch B (ESC templates), Phase 4 pre-BloodHound check.

**Detection:** WinSec 4662 burst, Sysmon EID 1 (`ADeleg.exe`), bulk LDAP from one host.

**KQL cardinality idea:**

```text
event.code:4662 AND winlog.event_data.SubjectUserName:*
```

Correlate high-volume 4662 from one source in 60s.

**Cross-ref:** Campaign_suggestions.md item #99 (detail file).
