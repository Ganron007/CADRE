# SharpHound Detection

> **Source:** https://ipurple.team/2024/07/15/sharphound-detection/
> **Date:** 2024-07-15
> **MITRE:** T1087.002 (Account Discovery: Domain Account)
> **CADRE mapping:** Campaign_suggestions.md #22, Phase 4

---

## What It Is

Detection reference for SharpHound (BloodHound data collector). Documents APIs, event IDs, and techniques defenders can use to detect BloodHound enumeration in their environment.

## SharpHound Collection Methods

| # | Method | Command |
|---|--------|---------|
| 1 | Collect All | `SharpHound.exe -c all -d <domain> --searchforrest` |
| 2 | Collect All + GPO LocalGroup | `SharpHound.exe -c all, GPOLocalGroup` |
| 3 | DC Only | `SharpHound -CollectionMethod DCOnly` |
| 4 | PowerShell CSV | `Invoke-BloodHound -SearchForest -CSVFolder C:\Users\Public` |
| 5 | PowerShell Collect All | `Invoke-BloodHound -CollectionMethod All -LDAPUser <user> -LDAPPass <pass>` |
| 6 | Non-Domain Joined | `bloodhound-python -d <domain> -u <user> -p <pass> -gc <dc> -c all` |

## APIs Used by SharpHound

| API | Named Pipe | Function |
|-----|-----------|----------|
| NetSessionEnum | \\PIPE\srvsvc | Active Remote Logon Sessions |
| NetWkstaUserInfo | \\PIPE\wkssvc | Interactive, Service and Batch Logons |
| RegEnumKeyW | \\PIPE\winreg | Interactive Logged Users |

Loaded DLL: `netapi32.dll`

## Windows Event IDs

| Event ID | Category | What It Captures |
|----------|----------|------------------|
| 5140 | File Share | Share access attempts |
| 5145 | Detailed File Share | Shared object access |
| 4662 | Directory Service Access | AD object access |

### Enable Policies

```
GPO → Advanced Audit Policy → Audit Policies → Object Access → Audit Detailed File Share
GPO → Advanced Audit Policy → Audit Policies → Object Access → Audit File Share
GPO → Advanced Audit Policy → Audit Policies → DS Access → Audit Directory Service Access
```

### Key Indicators

- Relative target names: `samr`, `lsarpc`, `srvsvc`, `winreg` from same source to `\\*\IPC$`
- Burst of 4662 events in short period from single source
- LDAP queries for privileged groups

## ETW Detection (LDAP)

Use [SilkETW](https://github.com/mandiant/SilkETW) to monitor LDAP ETW provider:
```bash
SilkETW.exe -t user -pn Microsoft-Windows-LDAP-Client -ot eventlog
```

LDAP queries captured under Event ID 3.

### YARA Rule for Privileged Group Enumeration

```yara
rule PrivilegedGroupEnumeration {
    strings:
        $s1 = "Domain Admins" ascii wide nocase
        $s2 = "Account Operators" ascii wide nocase
        $s3 = "Backup Operators" ascii wide nocase
        $s4 = "DnsAdmin" ascii wide nocase
        $s5 = "Enterprise Admins" ascii wide nocase
        $s6 = "Group Policy Creator Owners" ascii wide nocase
        $s7 = "admincount=1"
    condition:
        any of them
}
```

## CADRE Application

- Phase 4 (BloodHound collection) — understand what telemetry SharpHound leaves
- Validate detection rules for BH collection on mbr01 (analyst_cloud context)
- Test: run SharpHound on mbr01, check which event IDs fire
- Use this reference to build cadre-* detection rules for BH enumeration
- ADWS enumeration (SOAPHound) is stealthier alternative — compare detection gaps

---

*Last updated: 2026-06-09*
