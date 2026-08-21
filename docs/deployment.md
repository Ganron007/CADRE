# CADRE — Deployment Guide

Deploy via `python cadre.py` from an **elevated PowerShell**. No WSL2 — CADRE provisions
its own Ubuntu PROVISIONING VM that runs Ansible against the rest of the lab.

This guide is written to follow top-to-bottom on a fresh machine. Every command is
copy-paste ready. Every `cadre.py` step shows what you'll see on screen so you know what's
normal versus what's a problem.

---

## Overview — Four Stages

| Stage | What | Command | First-run time |
|-------|------|---------|----------------|
| **A** | Base lab (7 core VMs + AD + vulnerabilities + Windows audit baseline + Sysmon) | `python cadre.py install` | 2-3 h (box downloads dominate) |
| **B** | ELK-Fleet (Elasticsearch + Kibana + Fleet + Elastic Defend + agents + detection rules) | add `-e elk-fleet` | 20-30 min |
| **C** | Net-Monitor (Zeek + Suricata + Arkime + tcpdump + SiLK + promiscuous NIC) | add `-e net-monitor` | 15-20 min |
| **D** | Velociraptor (DFIR server + 6 clients + 10 hunts + MCP for Plan 7) | add `-e velociraptor` | 10-15 min |

**Three ways to start the install:**

```powershell
# 1. Interactive menu (RECOMMENDED first time — Rich UI, confirm prompts, summary panel)
python cadre.py

# 2. Direct CLI, full deploy (after you've done it once and know what to expect)
python cadre.py install -vv -e elk-fleet -e net-monitor -e velociraptor

# 3. Direct CLI, base only (you can add extensions later)
python cadre.py install -vv
```

---

## How CADRE deploys (the model — read this once)

CADRE uses the **provisioning-VM model**: Vagrant only makes the machines *reachable*; **Ansible does all configuration**, run from the `provisioning` VM. Understanding the split saves confusion later.

**What Vagrant does (and *only* this):**
- Boots the **7 core VMs** from boxes (linked clones) — plus any extension VMs you selected (elk/monitor/vr), which are gated in the Vagrantfile behind `CADRE_EXTENSIONS`
- Sets each hostname + a static IP on `vmnet2`
- Enables WinRM on Windows; installs the Ansible toolchain on the `provisioning` VM

After `vagrant up` every Windows box is a **blank, domain-less server**. No AD, no DNS, no trusts yet.

**What the Ansible playbooks do** (`ansible/playbooks/`, run in order — `cadre.py install` runs them for you over WinRM/SSH, or you can run them by hand from the provisioning VM):

| Kind | Playbooks | Behaviour |
|------|-----------|-----------|
| **Deploy (idempotent)** | `00-domain-deploy`, `02-ad-objects`, `03-member-join`, `04-windows-features`, `04-vulnerabilities`, `05-ad-attack-surface`, `06-member-services`, `07-linux-infra`, `07-linux-config`, `11-security-baseline`, extensions `12`–`15` | apply config; safe to re-run |
| **Verify-gate** | `01-core-ad` | no changes — confirms `00`'s domain promotion landed before the rest proceeds (this is why it's "verify-only": it checks `00`, not Vagrant) |
| **Verify-only over a MANUAL install** | `08-adcs-verify`, `09-sql-wsus-verify`, `10-sccm-verify` | you install ADCS / SQL / SCCM **by hand** (GUI), then these playbooks confirm the settings |

> ⚠️ **Three components are NOT automated** — you install them manually, then run their verify playbook:
> - **ADCS** (CA + ESC templates) — PSPKI can't create v1 templates on Server 2025. See [adcs-configuration-guide.md](adcs-configuration-guide.md).
> - **SQL** — Express on mbr01, SQL-on-Linux on linux01, SQL Developer on mbr02 (for SCCM). See [sql-integration-guide.md](sql-integration-guide.md).
> - **SCCM** site on mbr02. See [sccm-integration-guide.md](sccm-integration-guide.md).
>
> `cadre.py install` will run the deploy playbooks and the verify playbooks; the verify steps for ADCS/SQL/SCCM will **report failures until you do the manual installs**. That is expected — do the manual installs, then re-run the verify playbooks.

**Extension VMs (elk `.50`, monitor `.55`, vr `.51`) are created on demand.** They live in the *same* core Vagrantfile but are gated behind the `CADRE_EXTENSIONS` env var. When you select an extension (`-e elk-fleet`, menu, or prompt), cadre.py sets `CADRE_EXTENSIONS` and runs `vagrant up` — which creates just that extension VM (the 7 core stay as-is) — then runs the extension playbook against it. So `vagrant up` alone = 7 core VMs; selecting an extension later (`cadre.py install -e net-monitor` or menu **[8]**) creates *and* configures its VM automatically. No separate Vagrantfile, no manual VM creation.

---

## Prerequisites

### Hardware (host machine)

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| RAM | ~48 GB | 64 GB |
| Disk | 150 GB free (SSD) on the drive you'll install into | 250 GB (NVMe) |
| CPU | 8 cores | 12+ cores |
| OS | Windows 11 Pro | Windows 11 Pro 24H2+ |

> If you have 32 GB RAM, you can still deploy Stage A but should stop/destroy heavy VMs
> before running extensions, or skip Stages B/C/D entirely. Below 32 GB is not supported.

### Software

| Component | Version | Install |
|-----------|---------|---------|
| VMware Workstation Pro | 17+ (free since 2024) | <https://www.vmware.com/products/workstation-pro/> |
| Vagrant | 2.4+ | <https://www.vagrantup.com/downloads> |
| vagrant-vmware-desktop plugin | latest | `vagrant plugin install vagrant-vmware-desktop` |
| vagrant-reload plugin | latest | `vagrant plugin install vagrant-reload` |
| vagrant-vmware-utility service | latest | Bundled with vagrant-vmware-desktop; runs as a Windows service |
| Python | 3.10+ | <https://www.python.org/downloads/> |
| Python `rich` library | latest | `pip install rich` |

`cadre.py` exits with a clear error if `rich` is missing — install it once and you're done.

### VMware network configuration (one-time)

1. Install VMware Workstation Pro 17+
2. Open **Edit → Virtual Network Editor** (run as Administrator)
3. Configure **`vmnet2`** as **Host-only**:
   - Subnet: `192.168.77.0`
   - Mask: `255.255.255.0`
   - **DHCP: disabled** (CADRE VMs use static IPs)
   - For Stage C / the `monitor` VM: also check **"Allow promiscuous mode"** on `vmnet2`
4. Verify the helper service is running:
   ```powershell
   Get-Service vagrant-vmware-utility
   # StatusName              DisplayName
   # ------ ----              -----------
   # Running vagrant-vmware-utility  vagrant-vmware-utility
   ```

### Vagrant plugins

```powershell
vagrant plugin install vagrant-vmware-desktop
vagrant plugin install vagrant-reload
vagrant plugin list
# Should list both plugins
```

### Media downloads (one-time, manual — Microsoft requires sign-in)

Two installer binaries can't be auto-downloaded. The helper script opens browser pages
to the right Microsoft Eval Center URLs:

```powershell
pwsh docs/internal/tools/download-media/download-media.ps1
```

Save the downloads to:
- `downloads/ConfigMgr_2509.exe` (~1.2 GB — ConfigMgr 2509 eval) *(already deployed — media needed for fresh re-deploy only)*
- `downloads/AADConnectProvisioningAgentSetup.exe` (~50 MB — Entra Cloud Sync agent)

The pre-flight check in Step 1 will flag these as missing if you skip this step.

---

## Step 1 — Pre-flight check

```powershell
cd C:\STUDY\Github\CADRE-Platform\CADRE
python cadre.py check
```

**What you'll see (Rich-formatted output):**

```
─────────────── CADRE Pre-flight Check ───────────────
  +  Admin                       True
  +  RAM >= 36GB                  Has 64 GB
  +  Disk >= 150GB                Free 220 GB
  +  Vagrant installed            Vagrant 2.4.3
  +  VMware Utility running       Running
  +  Plugin: vagrant-vmware-desktop  installed
  +  Plugin: vagrant-reload       installed

Config: config.json — 3 domains, 31 users
Media: SCCM eval EXE = present (site CAD deployed)
        Cloud Sync agent = + present

ALL CHECKS PASSED
```

Any line with a red `-` is a blocker — fix it before Step 2. The most common ones:

- `Admin: False` → Re-launch PowerShell as Administrator
- `VMware Utility running: Stopped` → `Start-Service vagrant-vmware-utility`
- `Plugin: ... MISSING` → Run the plugin install commands above

---

## Step 2 — Launch the installer (interactive menu)

```powershell
python cadre.py
```

You land on the main menu. This is the recommended first-time path because every
destructive operation has a confirm gate.

**Main menu (10 options):**

```
╭──────────────────────────────────────────────────────────────╮
│ CADRE v0.3 — Cloud · Agentic · DFIR · Red-team · Environment │
│ 7 VMs · 3 Domains · 8 Certifications · Server 2025          │
╰──────────────────────────────────────────────────────────────╯

Main Menu:

  [1] Pre-flight Check
  [2] Full Install (all VMs + all extensions)
  [3] Custom Install                        ← select extensions one by one
  [4] Start VMs
  [5] Stop VMs
  [6] VM Status
  [7] Destroy Lab
  [8] Install Extensions                    ← extensions only, base must exist
  [9] Set VM Directory                      ← change install location mid-session
  [10] Help
  [q] Quit

Select an option [1]:
```

### What each menu option does (quick reference)

| Option | When to use |
|--------|-------------|
| **1** | Re-run pre-flight after fixing something |
| **2** | Standard path: deploys base + all 3 extensions in one go |
| **3** | Same as 2 but asks per-extension yes/no + verbosity level |
| **4 / 5** | Resume / halt all VMs gracefully (after a reboot, say) |
| **6** | Show `vagrant status` — what's running |
| **7** | Destroy ALL VMs (asks twice — irreversible) |
| **8** | Install extensions after base is already deployed |
| **9** | Pick a different install drive without restarting cadre.py |
| **10** | Inline help (same as `python cadre.py --help`) |

---

## Step 3 — Pick where to install the VMs

Choose option **[2] Full Install** (or **[3] Custom**). cadre.py prompts:

```
Parent directory (a 'CADRE' folder will be created inside) [C:\Users\you\VMs]:
```

**Important behavior:** whatever you give, a `CADRE/` subfolder is **always** created
inside it. This keeps everything tidy like a normal installer.

| You enter | Lab ends up at |
|-----------|----------------|
| (press Enter — default) | `C:\Users\you\VMs\CADRE\` |
| `D:\VMs` | `D:\VMs\CADRE\` |
| `D:\Lab\Practice` | `D:\Lab\Practice\CADRE\` |
| `D:\VMs\CADRE` | `D:\VMs\CADRE\` *(no double-nest, already correct)* |

The folder you pick needs at least **150 GB free** on the same drive.

---

## Step 4 — Review the configuration summary and confirm

Before any vagrant work starts, cadre.py shows you a summary panel and waits for `Y/n`:

```
╭──────────── Deployment Configuration ────────────╮
│  Install location     D:\VMs\CADRE                │
│  Parent directory     D:\VMs                      │
│  CADRE folder         CADRE/  (will be created)   │
│  Vagrantfile source   C:\STUDY\Github\CADRE-Platform\CADRE\lab\providers\vmware\Vagrantfile │
│  Config source        C:\STUDY\Github\CADRE-Platform\CADRE\lab\data\config.json │
│  VMs to provision     7 (5 Windows Server 2025 + 2 Linux)   │
│  Extension VMs        elk-fleet(.50) · net-monitor(.55) · vr(.51) — deployed on demand │
│  Extensions           elk-fleet, net-monitor, velociraptor │
│  Verbosity            -vv (Task names (recommended)) │
│  Estimated time       2-3 h first run · 30-60 min subsequent │
│  RAM needed           ~48 GB (close other VMs if tight) │
│  Disk needed          ~150 GB free on target drive │
╰──────── Confirm to proceed ────────╯

Proceed with these settings? [Y/n]:
```

- Press **`Y`** (or Enter) → install begins
- Press **`n`** → cancel cleanly, no folders created, no side effects

If anything in the panel looks wrong (wrong drive, missing extension, wrong verbosity)
say `n`, go back to the menu, fix it, and re-enter.

---

## Step 5 — Watch the deploy run (Stage A: base lab)

Once you confirm, cadre.py walks through three phases. Each phase prints a header so
you know where you are.

### Phase 1/3 — Bringing up VMs

```
Phase 1/3 — Bringing up VMs
==> dc01: Importing base box 'gusztavvargadr/windows-server-2025-standard'...
==> dc01: Booting VM...
==> dc01: Waiting for machine to boot. This may take a few minutes...
...
```

**First-run reality:** Vagrant downloads Server 2025 (~6 GB) + Ubuntu 24.04 (~1 GB) +
Total ~7 GB on first run. Subsequent runs reuse the cached boxes.

All 7 core VMs come up sequentially, then Ansible kicks off.

### Phase 2/3 — Locating PROVISIONING VM

```
Phase 2/3 — Locating PROVISIONING VM
  Key: D:\VMs\CADRE\.vagrant\machines\provisioning\vmware_desktop\private_key
  IP: 192.168.77.60
```

This is quick (seconds) — cadre.py just finds the SSH key Vagrant generated and the
IP the provisioning VM picked up.

### Phase 3/3 — Running Ansible playbooks

```
Phase 3/3 — Running Ansible Playbooks
[*] Copying Ansible to PROVISIONING VM...
[*] Copying config.json to PROVISIONING VM...
[*] Installing Ansible collections (pinned versions)...
[*] Running numbered phase playbooks (00 → 11, + selected extensions)...

⠋ Ansible  ████████████░░░░░░░░░░░░░░░░░░░░ Phase 02-ad-objects — Create cadre.local OUs
```

The progress bar shows play-by-play progress. The text on the right shows the current
task name. At **`-vv`** verbosity (recommended) you'll also see each task name as it
fires under the bar.

### What runs in Stage A

The numbered playbooks in `ansible/playbooks/`, in `cadre.py` PHASES order. (Auto = applied by the playbook; **Manual** = you install by hand, the playbook only verifies.)

| # | Playbook | What it does |
|---|----------|--------------|
| 00 | `00-domain-deploy` | **Auto, one-shot.** Promote cadre.local + child.cadre.local + range.local, DNS zones, cross-forest trust |
| 01 | `01-core-ad` | Verify-gate — confirms `00` landed (domains/trusts/DNS) |
| 02 | `02-ad-objects` | OUs, users, groups, gMSA/dMSA, KDS root key, GPOs, GPP cpassword bait |
| 03 | `03-member-join` | Join mbr01 → child, mbr02 → range |
| 04a | `04-windows-features` | IIS, WSUS features |
| 04b | `04-vulnerabilities` | Registry/services — WDigest on, LSA/Cred Guard/Defender off |
| 05 | `05-ad-attack-surface` | 26 ACEs · 5 Kerberoast SPNs (AES) · 3 AS-REP · delegation (unconstrained/constrained±transition/RBCD) |
| 06 | `06-member-services` | Shares + bait files, IIS app pool, VSC verify |
| 07a | `07-linux-infra` | linux01 realmd join + packages |
| 07b | `07-linux-config` | SSSD, auditd (≥45 rules), NFS-krb5p export, Podman privileged container |
| 08 | `08-adcs-verify` | **Manual:** install CA + ESC1-14 templates (PSPKI can't on 2025). Playbook verifies. → adcs guide |
| 09 | `09-sql-wsus-verify` | **Manual:** SQL Express (mbr01), SQL-on-Linux (linux01), SQL Developer (mbr02). WSUS is auto (04a). Playbook verifies. → sql guide |
| 10 | `10-sccm-verify` | **Manual:** SCCM site CAD on mbr02 + NAA/PXE/push misconfigs. Playbook verifies. → sccm guide |
| 11 | `11-security-baseline` | **Auto.** `cadre-dfir-monitoring.ps1` (49 audit subcats, PS ScriptBlock+Module(*)+Transcription, NTLM auditing, 26 channels @256 MB, Security log 1 GB) + Sysmon (Olaf Hartong sysmon-modular) on all 5 Windows VMs |

Attack tooling is **not** deployed — Kali is user-managed (see `attack-matrix/attack-tools-required.md`). Extensions (`12`–`15`) run in Stages B–D below.

> The old 26-play monolith is retired (archived). The list above is the current 18-playbook structure — ADCS/SQL/SCCM are now manual installs with verify-only playbooks, not automated steps.

### When you see the final summary panel

```
─────────────── Deployment Summary ───────────────

  Play                                        Time      OK   Changed Failed  Skipped Total
  Create cadre.local forest                  0:08:42   12    3       0       0       15
  Create child.cadre.local domain            0:07:11   12    3       0       0       15
  ...
  Cloud integration                          0:00:14    1    1       0       0        2

  Total Plays         26
  Total Tasks         287
  OK                  245
  Changed             42
  Skipped              0
  Files Created       18

Deployment complete in 1:42:18
```

**Failed = 0 means Stage A is done.** If Failed > 0, see [Troubleshooting](#troubleshooting)
or re-run `install` — Ansible is idempotent and will only retry the failed tasks.

### Verify Stage A — quick sanity checks

```powershell
# All 7 core VMs running
python cadre.py status
# Should show all 7 core VMs as "running"

# Domain health (RDP or WinRM to dc01)
nltest /dsgetdc:cadre.local              # DC: \\dc01.cadre.local
nltest /dsgetdc:child.cadre.local        # DC: \\dc02.child.cadre.local
nltest /domain_trusts                    # Lists child + range.local trusts

# Windows audit baseline applied
auditpol /get /category:* | Select-String "Success and Failure" | Measure-Object
# Count: should be >= 44

# Sysmon running
Get-Service Sysmon64                                                   # Running

# PowerShell deep visibility configured
(Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging').EnableScriptBlockLogging
# 1
(Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames')."*"
# *

# 4688 includes command line
(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit').ProcessCreationIncludeCmdLine_Enabled
# 1

# Security log sized
wevtutil gl Security | Select-String maxSize
# maxSize: 1073741824
```

For the exhaustive check list see [`docs/testing-recommendations.md`](testing-recommendations.md)
§ Stage 2 + § Stage 3.2.

---

## Step 6 — Deploy Stage B (ELK-Fleet)

If you chose **[2] Full Install** in Step 2, Stages B/C/D run automatically right after A.
If you chose base-only, install ELK-Fleet now:

```powershell
# From menu → option 8 → check elk-fleet → confirm
# OR direct CLI:
python cadre.py install -e elk-fleet
```

Same Rich progress UI; play-by-play summary at the end.

### What runs

1. Bring up the `elk` VM (skipped if already running)
2. Install Elasticsearch 9.x + Kibana + Fleet Server
3. Set the `elastic` password (`elastic_CADRE_2026!`) + create GeoIP ingest pipeline
4. Enroll Fleet Server on the elk VM itself (port 8220)
5. Create three Fleet policies:
   - **CADRE-All** → assigned to 5 Windows VMs (Windows Events, Sysmon, PS, Elastic Defend, System)
   - **CADRE-Linux** → assigned to linux01 (auditd, osquery, MSSQL, Sysmon Linux, custom_logs, System)
   - **CADRE-Monitor** → assigned to monitor VM only (Zeek + Suricata)
6. Add integrations + Elastic Defend (DETECT mode, never PREVENT)
7. Configure 2 osquery scheduled packs (cadre-linux-pack 5-min + 30-min) on CADRE-Linux
8. Generate enrollment tokens → install Elastic Agent on all 5 Windows VMs + linux01
9. Load 7 Windows + 15 Linux (L01-L15) seed detection rules, 29 saved searches, Attack Telemetry dashboard
10. Configure Threat Intel (Abuse.ch URLhaus / MalwareBazaar / ThreatFox)

### Verify Stage B

```powershell
# Get the elastic password (it's the same one used in playbook.yml)
$PASS = "elastic_CADRE_2026!"

# Cluster health
curl -u "elastic:$PASS" http://192.168.77.50:9200/_cluster/health
# status: green or yellow

# Agents enrolled
curl -u "elastic:$PASS" http://192.168.77.50:5601/api/fleet/agents
# 6+ agents online (5 Windows + linux01)

# Windows events flowing (wait 2-3 min after enrollment for first events)
curl -u "elastic:$PASS" "http://192.168.77.50:9200/logs-system.security-*/_count"
# count > 100

# Open Kibana: http://192.168.77.50:5601  · login: elastic / $PASS
# Analytics → Discover → select "logs-*" data view → events should appear
```

---

## Step 7 — Deploy Stage C (Net-Monitor)

```powershell
# Menu option 8 → check net-monitor → confirm
# OR:
python cadre.py install -e net-monitor
```

### What runs

1. Bring up the `monitor` VM with the second NIC in promiscuous mode (see VMware config above)
2. Install Zeek + configure zeekctl (JSON output, capture on `eth1`)
3. Install Suricata 7.x (from OISF PPA, not apt v6.x) + Emerging Threats Open ruleset
4. Install Arkime + local Elasticsearch + viewer
5. Configure tcpdump hourly rotation (1 GB cap, 24 h retention) via systemd timer
6. Install SiLK (CERT/SEI offline flow tools)
7. Install Elastic Agent on monitor → enrolled into CADRE-Monitor policy
8. Zeek + Suricata logs begin shipping to central Elasticsearch on elk VM

### Verify Stage C

```bash
# SSH to monitor:
ssh vagrant@192.168.77.55

sudo /opt/zeek/bin/zeekctl status         # all workers running
sudo systemctl is-active suricata         # active
sudo systemctl is-active arkimecapture    # inactive (manual offline workflow)
sudo systemctl is-active arkimeviewer     # active
ls /opt/pcap/manual/                       # capture-*.pcap files after manual run
ls /opt/zeek/logs/current/                 # conn.log, dns.log, kerberos.log...

# Arkime web UI:
# Open https://192.168.77.55:8005 (accept self-signed cert) · login: admin / arkime
# Sessions should populate within a few minutes of traffic

# Zeek data flowing to central elk:
curl -u "elastic:$PASS" "http://192.168.77.50:9200/logs-zeek.*-*/_count"
# count > 0
```

---

## Step 8 — Deploy Stage D (Velociraptor)

```powershell
# Menu option 8 → check velociraptor → confirm
# OR:
python cadre.py install -e velociraptor
```

### What runs

1. Bring up the `vr` VM
2. Install Velociraptor binary (v0.76 / 0.76.1) + generate server config + TLS certs
3. Start Velociraptor frontend (systemd, port 8889)
4. Create admin user (`admin` / `VelociraptorDefault!`)
5. Generate client config + repack MSI with embedded server URL
6. Deploy Windows MSI client on **dc01, dc02, dc03, mbr01, mbr02, and ws01** (Ansible push of the repacked MSI; msiexec **fail-closed**). ws01 is also enrolled by `17-ws01-deploy.yml` so the launcher can be added without re-running the full Windows inventory.
7. Deploy Linux client on linux01
8. Load 10 pre-built hunt collections into the **live** server catalog via `defaults.artifact_definitions_directories` (`/opt/cadre-hunts`, `/opt/cadre-artifacts`). Velociraptor 0.76 has `artifacts`, not `artifact add`.
9. Import the `CADRE.Linux.KeytabFingerprints` custom artifact (same catalog path)
10. Generate `config api_client` YAML and start the MCP HTTP front (`velociraptor-mcp`, port 8002) for Plan 7 / DFIR-Nexus. Health: `GET /health`. VQL: `POST /vql` with Bearer from `/etc/velociraptor/mcp.env`. **Do not** point `NEXUS_VR_ENDPOINT` at `:8001` (gRPC).

### Verify Stage D

```powershell
# Web GUI reachable
# Open https://192.168.77.51:8889 (accept self-signed cert)
# Login: admin / VelociraptorDefault!
# Dashboard → "Show all" should list campaign clients: 6 Windows (dc01–dc03, mbr01, mbr02, **ws01**) + linux01 (+ vr self-enrolled)

# MCP endpoint healthy
curl http://192.168.77.51:8002/health
# {"status":"ok","ok":true,...}

# Live hunt catalog (no --definitions)
ssh vagrant@192.168.77.51 "sudo velociraptor -c /etc/velociraptor/server.config.yaml artifacts list | grep CADRE.Hunts.FullBreach"
```

---

## Step 9 — Take a clean baseline snapshot

After all 4 stages complete and all verifications pass, snapshot every VM. From now on
every attack cycle reverts to this baseline.

```powershell
python docs/internal/tools/snapshot/snapshot.py take clean-baseline --all
```

Revert after every attack cycle:

```powershell
python docs/internal/tools/snapshot/snapshot.py revert clean-baseline --all
```

> Plan 3 will add a single `docs/internal/tools/snapshot/cycle.py` that wraps revert → attack → wait → VR hunt → export → validate → revert in one command. Until then the manual revert above is the right interim flow.

---

## Step 10 — Run your first attack (end-to-end validation)

```bash
# From attack VM (user-managed Kali):
impacket-GetUserSPNs cadre.local/analyst_dfir:'An@lyst_DF1R!' -dc-ip 192.168.77.10 -request
```

Wait 60 seconds for telemetry propagation, then verify the attack landed in every source:

```powershell
$PASS = "elastic_CADRE_2026!"

# 1. Windows Security Event 4769 (Kerberos TGS request)
curl -u "elastic:$PASS" "http://192.168.77.50:9200/logs-system.security-*/_count?q=event.code:4769"
# count > 0

# 2. Sysmon process creation (impacket-GetUserSPNs invocation)
curl -u "elastic:$PASS" "http://192.168.77.50:9200/logs-windows.sysmon_operational-*/_count?q=event.code:1"
# count > 0

# 3. Zeek kerberos.log (the actual TGS-REQ/TGS-REP on the wire)
curl -u "elastic:$PASS" "http://192.168.77.50:9200/logs-zeek.*-*/_count?q=event.dataset:zeek.kerberos"
# count > 0

# 4. Arkime captured the session
curl -k -u admin:arkime "https://192.168.77.55:8005/api/sessions?expression=protocols==kerberos"
# recordsTotal > 0

# 5. Kerberoast detection rule fired
curl -u "elastic:$PASS" "http://192.168.77.50:9200/.alerts-security.alerts-*/_count"
# count > 0
```

If all 5 produce data → **CADRE is fully operational.** Move on to
[`docs/forensic-workflow.md`](forensic-workflow.md) for the attack-cycle loop.

For the exhaustive Stage 4/4b checklist (Windows + Linux substrate smoke tests) see
[`docs/testing-recommendations.md`](testing-recommendations.md).

---

## Management commands (post-deploy)

| Command | What |
|---------|------|
| `python cadre.py` | Open the interactive menu |
| `python cadre.py status` | Show `vagrant status` for all VMs |
| `python cadre.py start` | Resume all VMs (after host reboot) |
| `python cadre.py stop` | Graceful halt of all VMs |
| `python cadre.py destroy` | Destroy all VMs (irreversible — asks twice) |

`status` / `start` / `stop` / `destroy` will prompt for the install location the same way
`install` does (Parent → CADRE/) unless you pass `--vm-dir`.

---

## Verbose levels — what to use when

| Flag | Output style | When to use |
|------|--------------|-------------|
| (default) | Rich progress bar + final summary panel | First successful deploy; you don't want to watch every task |
| `-v` | Bar + key events (play boundaries) | Long unattended run; check occasionally |
| `-vv` | Bar + task name on every fire **(RECOMMENDED for first run)** | You want to see what's happening without drowning in Ansible JSON |
| `-vvv` | Full raw Ansible output, no progress bar | A task failed and you need the actual error message |

---

## VM access

| VM | IP | Method | Default credentials |
|----|----|--------|---------------------|
| dc01-dc03, mbr01-mbr02 | .10-.12, .22-.23 | RDP or WinRM | `vagrant` / `vagrant` (local), plus domain users from `naming-scheme.md` |
| linux01 | .40 | SSH | `vagrant` / `vagrant` (local), plus AD users via SSSD (e.g., `chief_command` / `C0mm@nd_Ch1ef!`) |
| elk | .50 | SSH | `vagrant` / `vagrant` |
| monitor | .55 | SSH | `vagrant` / `vagrant` |
| vr | .51 | SSH | `vagrant` / `vagrant` |
| provisioning | .60 | SSH | `vagrant` / `vagrant` |

| Web UI | URL | Login |
|--------|-----|-------|
| Kibana | <http://192.168.77.50:5601> | `elastic` / `elastic_CADRE_2026!` |
| Arkime | <https://192.168.77.55:8005> (self-signed) | `admin` / `arkime` |
| Velociraptor | <https://192.168.77.51:8889> (self-signed) | `admin` / `VelociraptorDefault!` |
| Velociraptor MCP | <http://192.168.77.51:8002> | API key |

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `cadre.py` exits with "rich not installed" | Python `rich` library missing | `pip install rich` (or `py -m pip install rich`) |
| `vagrant up` certificate error | vagrant-vmware-utility certs not readable | Elevated PS: `icacls "C:\ProgramData\hashicorp\vagrant-vmware-desktop\certificates" /grant "Users:(OI)(CI)RX" /T` |
| WinRM connection timeout | Windows VM still booting / WinRM not ready | Wait 2-3 min, run `install` again (Ansible retries 30×, 10 s delay) |
| VM gets wrong IP | VMware DHCP interference | Make sure vmnet2 DHCP is **disabled** in Virtual Network Editor |
| `cadre.py check` says "not enough RAM" | System reports less than physical | Close other VMs; verify no hypervisor overhead |
| Stage A halts at "Add child domain" | DNS forwarders missing OR win_powershell module issues | We use `win_powershell` + `community.windows.*` tasks. If you see this error, check `ansible/playbooks/` for any remaining `microsoft.ad` calls and replace with `community.windows.*` + `win_powershell` |
| Stage A halts at "forest trust" | One DC's DNS forwarder didn't take | RDP to dc01 → `Add-DnsServerConditionalForwarderZone -Name range.local -MasterServers 192.168.77.12`; re-run |
| Sysmon not running after deploy | Sysinternals download URL changed | Check <https://download.sysinternals.com/files/Sysmon.zip> in a browser; re-run security role |
| Fleet agents show "offline" | Fleet Server cert mismatch / not reachable | Check `https://192.168.77.50:8220` responds; agents use `--insecure` flag |
| Zeek/Suricata no data in Elastic | Elastic Agent not enrolled on monitor | Check CADRE-Monitor policy has monitor VM registered |
| Arkime shows 0 sessions | Promiscuous NIC not working | Verify VMX has `ethernet1.allowPromiscuous = TRUE`; restart VM; in Virtual Network Editor check "Allow promiscuous mode" on vmnet2 |
| ADCS templates missing | PSPKI module install failed | On dc01: `Install-Module PSPKI -Force`; re-run with `python cadre.py install` (Ansible re-runs only what's missing) |
| MSSQL connection refused | Service not started or firewall | `Get-Service MSSQL$SQLEXPRESS` on mbr01; check port 1433 firewall rule |
| Velociraptor clients not connecting | TLS cert mismatch | Re-generate client config from VR server; re-run `install -e velociraptor` |
| "elastic_agent_version is undefined" | `inventories/group_vars/all.yml` missing | Verify the file exists; should contain `elastic_agent_version: "9.4.1"` |
| Trust says "RPC server unavailable" | Cross-forest DNS not resolving | From dc01: `nslookup dc03.range.local 192.168.77.12` should resolve; if not, conditional forwarder failed |

---

## Deployment gotchas — known issues

| # | Stage | Issue | Workaround |
|---|-------|-------|------------|
| G1 | A | SCCM deployed on mbr02 | SCCM site CAD is deployed and verified. Media needed for fresh re-deploy only. See [`sccm-integration-guide.md`](sccm-integration-guide.md). |
| G2 | A | Server 2025 box download is ~6 GB on first run | First `vagrant up` is slow; subsequent runs use cached box |
| G3 | A | Linux MSSQL keytab not auto-generated | MSSQL service starts fine but Kerberos auth from Windows MSSQL won't work until you generate `mssql.keytab` manually with `ktpass`. Not blocking — most attacks work without it. |
| G4 | B | Elasticsearch needs 2-3 min to initialize before Kibana connects | Fleet setup retries automatically (30× / 10 s) |
| G5 | C | Promiscuous mode requires VMware host permission | On Windows: Virtual Network Editor → vmnet2 → check "Allow promiscuous mode" (one-time) |
| G6 | D | Velociraptor MSI enrollment requires server reachable from VMs | Verify VR port 8000 is open from a Windows VM: `Test-NetConnection 192.168.77.51 -Port 8000` |

---

## After a successful deploy

| Step | Reference |
|------|-----------|
| 1. Understand the attack → telemetry → investigate → export → reset cycle | [`docs/forensic-workflow.md`](forensic-workflow.md) |
| 2. Look up which channel / EID / index a source lands in | [`docs/dfir-logging-reference.md`](dfir-logging-reference.md) |
| 3. Pick a walkthrough | [`attack-matrix/01-walkthroughs/README.md`](../attack-matrix/01-walkthroughs/README.md) |
| 4. Run it from attack VM (user-managed Kali) | [`attack-matrix/04-automation/README.md`](../attack-matrix/04-automation/README.md) |
| 5. Observe telemetry across Kibana / Arkime / Velociraptor | [`docs/forensic-workflow.md`](forensic-workflow.md) Path A |
| 6. Export evidence bundle | `python docs/internal/tools/export-attack/export.py --attack T002` (Plan 2 — not yet built) |
| 7. Revert | `python docs/internal/tools/snapshot/snapshot.py revert clean-baseline --all` |
| 8. Repeat with next walkthrough | |

### Manual configuration guides

These guides document the tested and verified manual paths used during initial deployment. Use them to re-deploy from scratch or to understand the full setup sequence.

| Guide | What | Verified |
|-------|------|----------|
| [SQL Integration Guide](sql-integration-guide.md) | SQL Express (mbr01), SQL-on-Linux (linux01), SQL Developer (mbr02) + linked servers / CLR / impersonation | `09-sql-wsus-verify` |
| [SCCM Integration Guide](sccm-integration-guide.md) | SCCM site CAD on mbr02 — NAA/PXE/push/CRED-2 misconfigs | 7/7 checks pass |
| [ADCS Configuration Guide](adcs-configuration-guide.md) | CA cadre-CA on dc01 — ESC1-14 templates published | 18/18 checks pass |

---

## Re-running the deploy (idempotency note)

Ansible is **idempotent** — every task checks state before acting. You can safely:

- Re-run `python cadre.py install` after a partial failure → only the failed/missing tasks re-execute
- Edit `lab/data/config.json` (passwords, users, groups), then re-run install → changes apply
- Edit the Vagrantfile (RAM, CPU), then `python cadre.py status` → run `vagrant reload <vm>` from inside `D:\VMs\CADRE\` to pick up changes

The files in `D:\VMs\CADRE\Vagrantfile` and `D:\VMs\CADRE\config.json` are **not overwritten**
by subsequent `install` runs (they're write-if-missing). To resync from the repo template,
delete the file in the install dir first, then re-run.
