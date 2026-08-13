# Beachhead routing — Plan 1.1 (ws01-primary)

**Operator:** SSH to **provisioning** `.60` (Kali / Ansible config host).  
**Campaign plan:** `docs/internal/plan01-telemetry-catalog/plan1.1-campaign-automation/CAMPAIGN-AUTOMATION-PLAN.md` (local maintainers)

## Locked policy (2026-07-25)

| Path | Role |
|------|------|
| **ws01 `.62`** | **PRIMARY** attack egress + staging. Only host treated as fully defended (MDE + DFIR → Elastic). |
| **linux / provisioning `.60`** | **Alternate** beachhead (optional domain-join). Origin telemetry may be blind — **OK**. Do **not** add monitoring to provisioning. |
| **stage_mbr01** | **Exception only** if ws01 cannot run a required tool. Even after mbr01 SYSTEM, default egress stays **ws01 or kali**. |

```text
PRIMARY:   .60 ──nxc winrm / ws01-exec──► ws01 (.62) ──► targets
ALT:       .60 (domain-joined) ──nxc/impacket as analyst──► targets   (blind origin OK)
EXCEPTION: stage tool on mbr01 ONLY if ws01 blocked — then prefer resume via ws01/kali

Phase 0 only: T028, T031 may run .60 → DC (pre-beachhead).
```

**Forbidden for catalog attacks (windows beachhead):** `.60` → `nxc ldap/smb/mssql` → dc/mbr (skips ws01).

---

## Assume breach — ws01 Local Admin

Config lane (Ansible / vagrant) promotes `CHILD\analyst_t1` to **local Administrators** on ws01 (`17-ws01-deploy.yml`).  

| Lane | Credential | Use |
|------|------------|-----|
| **Config** | `vagrant` | `ws01-stage-file.sh`, Ansible, Local Admin prep |
| **Attack** | `analyst_t1` + earned | `ws01-exec.sh` / `nxc winrm` — **never** vagrant |

---

## Method 1 — via ws01 (default / primary)

| Step | Tool | Credential |
|------|------|------------|
| Remote exec on beachhead | `ws01-exec.sh` or `nxc winrm 192.168.77.62 …` | `child\analyst_t1` |
| Optional pre-stage | `ws01-stage-file.sh` (config lane) | `vagrant` |

Attack packets must leave **ws01** (`192.168.77.62`).

```bash
export PATH="$HOME/.local/bin:$PATH"

nxc winrm 192.168.77.62 -u analyst_t1 -p 'T13r_An@lyst!' -d child.cadre.local \
  -X 'whoami; hostname; whoami /groups | findstr /i Administrators'

bash attack-matrix/04-automation/linux/lib/ws01-exec.sh 'whoami; hostname'
```

**Invalid (windows beachhead catalog):**

```bash
# WRONG — attack traffic from .60, not ws01
nxc ldap 192.168.77.11 -u analyst_t1 ... --asreproast /tmp/asrep.txt
```

---

## Method 2 — stage on ws01 (Windows-only tools)

```bash
bash attack-matrix/04-automation/linux/lib/ws01-stage-file.sh /path/to/Rubeus.exe
bash attack-matrix/04-automation/linux/lib/ws01-exec.sh 'C:\Tools\cadre-attack\Rubeus.exe ...'
```

---

## Method 3 — linux beachhead (optional)

Requires optional playbook [`18-provisioning-domain-join.yml`](../../../../ansible/playbooks/18-provisioning-domain-join.yml) with `CADRE_PROVISIONING_DOMAIN_JOIN=1`.

- Attack as `child\analyst_t1` (or Kerberos) **from `.60`**
- Preserves Vagrant SSH config lane (`vagrant` local)
- **No** new logging/agents on provisioning (Plan 1.1)

---

## Exception — stage_mbr01

Use only when ws01 fails (MDE block, session death, tool cannot run). Record reason in evidence. Prefer returning egress to ws01/kali afterward.

---

## Helpers

| Script | Purpose |
|--------|---------|
| `nxc winrm` (`.60` → ws01) | Primary remote exec |
| `ws01-exec.sh` | Primary — WinRM as beachhead AD user |
| `ws01-stage-file.sh` | Config lane — drop files to `C:\Tools\cadre-attack\` |
| `install-nxc-provisioning.sh` | NetExec on `.60` |

See `CAMPAIGN-ATTACK-PATH.md` (local maintainers).
