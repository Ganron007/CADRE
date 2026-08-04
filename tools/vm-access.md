# CADRE Main Lab — VM Access (Quick Reference)

> For agents/scripts that drive the **main CADRE lab** from the Windows host or from **provisioning** (Kali role, `.60`).
> **Tracking:** flip items in [`CHECKLIST.md`](../CHECKLIST.md) first each session.
> Last updated 2026-07-26 (P11.6 RedStrike paths).

## Configurator vs attacker (locked)

| Role | Path | Credentials | When |
|------|------|-------------|------|
| **Configurator** | Host → SSH **provisioning** (`vagrant` key) → WinRM/SSH to VMs as **`vagrant`/`vagrant`** | Vagrant only | Reachability, firewall, SQL listen, Local Admin prep, Ansible verify — **whenever the host cannot reach VMs or a setup check is needed** |
| **Attacker** | provisioning → **ws01** (`analyst_t1`) → targets | Domain / earned | Campaign WT# / Plan 1.1 beachhead |

**Rule:** Do not diagnose lab setup from the Windows host alone (vmnet2 often not routed to Cursor). Always configurator-hop via provisioning.

**ws01 (non-Vagrant, `.62`):** same `vagrant`/`vagrant` WinRM. If `:5985` is **filtered**, service alone is not enough — open inbound FW (see [`WS01-WINRM-CONSOLE.md`](../docs/internal/plan01-telemetry-catalog/plan1.1-campaign-automation/WS01-WINRM-CONSOLE.md)); Play 0 in `17-ws01-deploy.yml` encodes the lasting config.

## The attacker / orchestrator machines

| Hostname | IP (lab / vmnet2) | IP (NAT) | OS | User | Role |
|----------|-------------------|----------|-----|------|------|
| host | `192.168.77.1` | — | Windows 11 | `Ganro` | Cursor / agents / `cadre.py` |
| **provisioning** | **`192.168.77.60`** | `192.168.90.135` | Ubuntu 24.04 (Bento) | **`vagrant`** | **Ansible runner + attack tools** (campaign “Kali”) |
| elk | `192.168.77.50` | — | Ubuntu 24.04 | `vagrant` | Elastic Stack / Kibana / Fleet |
| monitor | `192.168.77.55` | — | Ubuntu 24.04 | `vagrant` | Zeek / Suricata / Arkime |

Lab subnet: **`192.168.77.0/24`** on VMware `vmnet2`. Vagrant VM directory: **`C:\Users\Ganro\VMs\CADRE`** (all core + extension VMs typically **running**; legacy separate `kali` VM may be **off** — campaign uses **provisioning** as Kali).

See [`attack-matrix/Campaign/LAB-PROFILES.md`](../attack-matrix/Campaign/LAB-PROFILES.md) for which domain VMs to power per campaign phase.

### Core domain VMs (static IPs)

| VM | IP | Domain | Notes |
|----|-----|--------|-------|
| dc01 | `.10` | `cadre.local` | Root forest DC |
| dc02 | `.11` | `child.cadre.local` | Phase 1 AS-REP / Kerberos |
| dc03 | `.12` | `range.local` | Trust peer |
| mbr01 | `.22` | `cadre.local` | MSSQL / Phase 3 |
| mbr02 | `.23` | `cadre.local` | SCCM |
| linux01 | `.40` | `cadre.local` | Linux pivot |
| ws01 | `.62` | `child.cadre.local` | Win11 + MDE — Phase 0.5 (not in Vagrantfile) |

Ground truth for users/passwords: [`lab/data/config.json`](../lab/data/config.json) (regen from Ansible).

---

## SSH key (host → provisioning)

The Vagrantfile sets `config.ssh.insert_key = false`, so **no per-VM `private_key`** is created under `.vagrant/machines/`. Use the standard Vagrant insecure key, copied once to `.ssh` with restrictive ACLs.

| Key file (Windows) | User | Target |
|---|---|---|
| `C:\Users\Ganro\.ssh\cadre-provisioning-key` | `vagrant` | `192.168.77.60` (provisioning) |

### One-time setup (PowerShell on host)

```powershell
# 1. Copy the Vagrant default key
Copy-Item "C:\Users\Ganro\.vagrant.d\insecure_private_key" `
  "C:\Users\Ganro\.ssh\cadre-provisioning-key" -Force

# 2. Fix ACLs (OpenSSH rejects keys that are world-readable)
icacls "C:\Users\Ganro\.ssh\cadre-provisioning-key" /inheritance:r
icacls "C:\Users\Ganro\.ssh\cadre-provisioning-key" /grant:r "${env:USERNAME}:(R)"

# 3. Smoke test
ssh -i "C:\Users\Ganro\.ssh\cadre-provisioning-key" -o StrictHostKeyChecking=no `
  vagrant@192.168.77.60 "hostname; whoami"
# expect: provisioning / vagrant
```

**Alternative:** `cd C:\Users\Ganro\VMs\CADRE` then `vagrant ssh provisioning` (interactive; no key copy needed).

`cadre.py` resolves keys via `find_provisioning_key()` — it falls back to `.vagrant.d\insecure_private_key` if no machine key exists.

### Optional: SSH config snippet

Add to `C:\Users\Ganro\.ssh\config`:

```
Host cadre-prov cadre-kali
    HostName 192.168.77.60
    User vagrant
    IdentityFile C:\Users\Ganro\.ssh\cadre-provisioning-key
    StrictHostKeyChecking no
```

Then: `ssh cadre-prov "whoami"`

---

## Standard SSH commands

### From host (PowerShell)

```powershell
$k = "C:\Users\Ganro\.ssh\cadre-provisioning-key"

# Run a command on provisioning (Kali role)
ssh -i $k -o StrictHostKeyChecking=no vagrant@192.168.77.60 "hostname"

# Copy file to provisioning
scp -i $k -o StrictHostKeyChecking=no .\local-script.sh vagrant@192.168.77.60:/tmp/
```

### From provisioning → other lab VMs

Passwordless SSH to **elk** / **monitor** works with the same Vagrant key material when those boxes still trust `insecure_public_key`:

```bash
ssh -o StrictHostKeyChecking=no vagrant@192.168.77.50 "hostname"   # elk
ssh -o StrictHostKeyChecking=no vagrant@192.168.77.55 "hostname"   # monitor
```

Domain Windows targets use **WinRM / Ansible / impacket** from provisioning — not SSH.

---

## Important paths on provisioning (`.60`)

| Path | What |
|---|---|
| `/home/vagrant/ansible/` | Ansible tree copied by `cadre.py` during deploy |
| `/home/vagrant/ansible/playbooks/` | Numbered playbooks (`00-domain-deploy.yml` …) |
| `/home/vagrant/ansible/ansible/inventories/group_vars/all.yml` | Includes `elastic_password` default |
| `/home/vagrant/attack-matrix/` | Staged campaign / automation copies (if present) |
| `/home/vagrant/CADRE/` | Plan 1.1 glue (graph, seeds, `04-automation/linux`) — **P11.6** |
| `/home/vagrant/RedStrike/` | RedStrike engine + `.venv` — **P11.6** |
| `/home/vagrant/cadre_passwords.txt` | Wordlist for hashcat / cracking drills |
| `/tmp/users-cadre.txt` | cadre.local spray wordlist — copy from `ansible/files/users-cadre-spray.txt` |

### RedStrike on provisioning (P11.6)

```bash
export CADRE_ROOT=$HOME/CADRE
export CADRE_AUTOMATION_ROOT=$HOME/CADRE/attack-matrix/04-automation/linux
# PATH wrapper: ~/.local/bin/redstrike-campaign → ~/RedStrike/.venv/bin/...
redstrike-campaign run --phase 1-3 --beachhead windows --engage lab1
redstrike-campaign stream E --engage lab1
```

Re-sync from Windows host after engine/glue changes (tar+scp of `RedStrike/` + `CADRE/attack-matrix/Campaign/automation` + `04-automation/linux`). See [`Red-Strike-workflow.md`](../attack-matrix/Campaign/Red-Strike-workflow.md).

### Attack tools (verified on lab)

| Tool | Path / notes |
|---|---|
| impacket | `/usr/local/bin/impacket-GetNPUsers`, `impacket-getTGT`, `impacket-GetUserSPNs`, `impacket-mssqlclient` |
| bloodyAD | `/usr/local/bin/bloodyAD` |
| redstrike-campaign | `~/RedStrike/.venv` + `~/.local/bin` wrapper (0.5.0+) |
| nmap, curl, jq, python3 | system PATH |

NetExec (`nxc`) may not be installed on older provisioning snapshots — check with `which nxc` before Phase 0 NetExec runbooks.

---

## Elasticsearch / Kibana (from provisioning)

| Item | Value |
|---|---|
| ES URL | **`http://192.168.77.50:9200`** (HTTP — not HTTPS from lab net) |
| Kibana | `http://192.168.77.50:5601` |
| User | `elastic` |
| Password | Ansible default in `group_vars/all.yml`; if reset at deploy, see **`/root/es-generated-pw.txt`** on **elk** |

### Quick ES health + query template

```bash
ES="http://elastic:elastic_CADRE_2026!@192.168.77.50:9200"

curl -s "$ES/_cluster/health?pretty"

# Example: latest WinSec 4768 (AS-REP) from provisioning source IP
curl -s "$ES/logs-system.security-*/_search" -H 'Content-Type: application/json' -d '{
  "size": 1,
  "sort": [{"@timestamp": "desc"}],
  "query": {"bool": {"must": [
    {"range": {"@timestamp": {"gte": "now-15m"}}},
    {"term": {"winlog.event_id": "4768"}},
    {"term": {"source.ip": "192.168.77.60"}}
  ]}}
}' | jq .
```

Plan 1 indices of interest:

- `logs-system.security-*` — WinSec (PRIMARY for Kerberos / AD)
- `logs-windows.sysmon_operational-*` — Sysmon
- `logs-endpoint.events.*` — Elastic Agent endpoint telemetry
- `logs-zeek.kerberos-*` — Kerberos (monitor → Fleet)
- `logs-suricata.eve-*` — Suricata EVE JSON (not `logs-suricata-*`)

---

## Plan 1 telemetry workflow (agent checklist)

Repo paths (edit on host; attacks run from provisioning):

| Doc | Path |
|---|---|
| **CHECKLIST** | `CHECKLIST.md` (flip items first) |
| **Attack status / workflow** | `docs/internal/plan01-telemetry-catalog/phase1-source-matrix/ATTACK-STATUS.md` |
| Pipeline README | `docs/internal/plan01-telemetry-catalog/phase1-source-matrix/README.md` |
| **SQL setup (manual SSoT)** | `docs/sql-integration-guide.md` |
| **ADCS setup (manual SSoT)** | `docs/adcs-configuration-guide.md` |
| **SCCM setup (manual SSoT)** | `docs/sccm-integration-guide.md` |
| Raw event log | `docs/internal/plan01-telemetry-catalog/phase1-source-matrix/tracker.md` |
| PRIMARY/C grid | `docs/internal/plan01-telemetry-catalog/phase1-source-matrix/source-matrix-grid.md` |
| Proof table | `docs/internal/plan01-telemetry-catalog/phase1-source-matrix/verification-table.md` |
| Evidence index | `docs/internal/evidence-catalog.md` |
| Field dictionary | `docs/internal/plan01-telemetry-catalog/elastic-field-dictionary/` |

### Evidence export (after each attack)

```bash
# On provisioning — script also at /home/vagrant/cadre-es-export.sh
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
# ... run attack ...
~/cadre-es-export.sh CADRE-T003-ASREP-20260725 T003 "$T0"
```

Uses **15-minute lookback** (`now-15m`) so Fleet ingest lag does not miss WinSec/Zeek docs.

**Per attack:**

1. **Surface check** — Core AD: `config.json` + ansible verify. SQL/ADCS/SCCM: integration guide + live probe (`impacket`, `certipy`, etc.); `*-verify.yml` is confirmatory only.
2. Note `T0` / `T1` UTC on provisioning.
3. Run the campaign command (from runbook or `tracker.md`).
4. Wait ~15s for Fleet ingest.
5. Query ES for all 7 sources (WinSec, Sysmon, Endpt, PS, auditd, Zeek, Suri).
6. Paste one raw JSON hit per source into `tracker.md`.
7. Mark `P` / `C` / `—` in `source-matrix-grid.md` only after proof.
8. Fill `verification-table.md` row; export bundle optional.

### Example — WT003 / T003 AS-REP (Phase 1)

```bash
echo intern_blue > /tmp/users.txt
impacket-GetNPUsers child.cadre.local/ -dc-ip 192.168.77.11 -no-pass -usersfile /tmp/users.txt
```

**Requires:** `dc02` (`.11`) up + **elk** (`.50`) + **monitor** (`.55`) for Zeek/Suricata. Profile: **P-PHASE1** or minimal `dc02 + provisioning + elk + monitor` (see LAB-PROFILES).

**Last verified:** 2026-07-25 — WinSec 4768 + Zeek kerberos from `.60` → `.11`.

---

## Lab profiles (what to power on)

| Work | Minimum VMs |
|---|---|
| Plan 1 backfill T002/T003 (Kerberos) | provisioning, dc02, elk, monitor |
| Phase 0.5 / H-01..H-06 (ws01) | provisioning, ws01, dc02, elk (+ monitor optional) |
| Phase 3 SQL | + mbr01 |
| Full campaign | See **P-FULL** in LAB-PROFILES |

Check reachability from provisioning:

```bash
for ip in 10 11 22 40 50 55 62; do
  ping -c1 -W1 192.168.77.$ip >/dev/null && echo ".${ip} UP" || echo ".${ip} DOWN"
done
```

---

## `cadre.py` quick reference (host)

```powershell
cd C:\STUDY\Github\CADRE-Platform\CADRE
python cadre.py status          # VM state
python cadre.py start           # start all defined VMs
python cadre.py check           # pre-flight
```

VM directory default: `C:\Users\Ganro\VMs\CADRE` (confirm in `cadre.py` / install prompts).

---

## Caveats

1. **Use lab IP `.60`**, not NAT `.90.135`, for Ansible and attack traffic — DCs and Fleet agents live on `77.x`.
2. **HTTPS to ES on :9200 fails** from provisioning (`wrong version number`) — use **HTTP** on port 9200.
3. **ws01** is imported separately — if `.62` is DOWN, Phase 0.5 attacks cannot run; Kerberos phases only need dc02.
4. **Do not commit** live ES passwords or cracked hashes into git — `tracker.md` may contain lab creds by design in internal docs; treat accordingly.
5. **Defender is disabled** on most Windows lab VMs per `04-vulnerabilities.yml` — **not** on ws01.
6. Sister labs: RevEng uses `.41`/`.42` — see `CADRE-RevEng/Tools/vm-access.md` (different keys).

---

## Smoke tests

```powershell
# Host → provisioning
ping 192.168.77.60
ssh -i "C:\Users\Ganro\.ssh\cadre-provisioning-key" vagrant@192.168.77.60 whoami

# On provisioning: ES + child DC
ssh -i "C:\Users\Ganro\.ssh\cadre-provisioning-key" vagrant@192.168.77.60 @'
  curl -s -u elastic:elastic_CADRE_2026! http://192.168.77.50:9200/_cluster/health | jq .status
  ping -c1 192.168.77.11
'@
```

Expected: `vagrant`, cluster `yellow` or `green`, dc02 ping OK.
