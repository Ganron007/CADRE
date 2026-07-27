# AD Enumeration via ADWS (Active Directory Web Services)

> **Source:** https://ipurple.team/2025/08/12/active-directory-enumeration-adws/
> **Date:** 2025-08-12
> **MITRE:** T1018 (Remote System Discovery)
> **CADRE mapping:** Campaign_suggestions.md #19, Phase 0 Reconnaissance

---

## What It Is

ADWS runs on all DCs by default on TCP port 9389. Uses SOAP protocol to wrap LDAP queries. Administrators use it via AD PowerShell modules and Active Directory Administrative Center. Stealthier than direct LDAP enumeration — SOAP messages are NOT captured in Windows event logs by default.

## Tools

| Tool | Language | Notes |
|------|----------|-------|
| [SOAPHound](https://github.com/FalconForceTeam/SOAPHound) | C# | In-memory execution via C2. Outputs BloodHound-compatible JSON. |
| [SoaPy](https://github.com/xforcered/SoaPy) | Python | Linux-based enumeration from Kali. |
| [ShadowHound](https://github.com/Friends-Security/ShadowHound) | PowerShell | Blends with environment. Custom LDAP filters supported. |

## SOAPHound Usage

```bash
# Build cache
dotnet inline-execute SOAPHound.exe --buildcache -c C:\temp\cache.txt

# BloodHound collection
dotnet inline-execute SOAPHound.exe --buildcache -c C:\temp\cache.txt --bhdump -o C:\temp\bloodhound-output --nolaps

# DNS dump
dotnet inline-execute SOAPHound.exe --dnsdump -o C:\temp\dns-output
```

## SoaPy Usage (from Kali)

```bash
soapy domain/username:'password'@DC-IP --users
soapy domain/username:'password'@DC-IP --query '(objectClass=computer)' --filter "samaccountname,objectsid"
```

## Why It's Stealthy

- SOAP messages not captured in default Windows event logs
- No SharpHound binary (EDR signatures don't match)
- LDAP queries wrapped in SOAP → different network signature than direct LDAP
- Default visibility is MISSING — requires Field Engineering registry key to detect

## Detection

### 1. Field Engineering Registry (Event ID 1644)

Enable Directory Service logging:
```
HKLM\SYSTEM\CurrentControlSet\Services\NTDS\Diagnostics → Field Engineering = 5
```

Event 1644 captures LDAP queries including user, filter, and attributes.

### 2. Sysmon Event ID 3 (Network Connection)

```xml
<Sysmon schemaversion="4.90">
  <EventFiltering>
    <NetworkConnect onmatch="include">
      <Rule name="Detect Traffic to ADWS">
        <DestinationPort>9389</DestinationPort>
      </Rule>
    </NetworkConnect>
  </EventFiltering>
</Sysmon>
```

### 3. Decoy Accounts (Honey Tokens)

Create decoy OU + account with `Read all properties` auditing for `Everyone`. When enumeration tools access these objects → Event 4662 fires.

## Detection Data Sources

| Data Source | Data Component | Detects |
|------------|---------------|---------|
| Windows Events | 1644 | LDAP Queries |
| Windows Events | 4662 | Read Property |
| Sysmon | 3 | Network Connection to port 9389 |

## CADRE Application

- DC01/DC02/DC03 all have ADWS on port 9389
- SOAPHound or SoaPy can enumerate all 3 domains from Kali
- Stealthier alternative to SharpHound for Phase 4 (Discovery)
- Detection: Sysmon EID 3 to port 9389 + Event 1644 on DCs

---

*Last updated: 2026-06-09*
