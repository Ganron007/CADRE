# Cross-Session Activation (COM Lateral Movement)

> **Source:** https://ipurple.team/2026/05/04/cross-session-activation/
> **Date:** 2026-05-04
> **MITRE:** T1021.003 (Distributed COM)
> **CADRE mapping:** Campaign_suggestions.md #21, Phase 5

---

## What It Is

COM/DCOM lateral movement technique. Threat actors with elevated privileges can execute code under the context of a user with an interactive session on the target host. Uses COM objects configured with `RunAs=Interactive User` — the attacker's process activates the COM object in the target user's session.

## Prerequisites

| Requirement | Detail |
|-------------|--------|
| Administrative Privileges | Registry modifications, share access, remote COM activation |
| Remote Registry Service | Must be enabled on target |
| Active Interactive Session | A user must be logged in |
| COM Class RunAs=Interactive User | COM object must be configured this way |
| Launch/Activation Permissions | Rights on the COM class |

## Attack Flow

1. Enumerate COM objects with `RunAs=Interactive User` + `Remote Activation` permissions
2. Identify target user's session ID
3. Enable Remote Registry service on target
4. Copy DLL to target host
5. Hijack COM object registry path
6. Activate COM object in target user's session → code runs as that user

## Tools

| Tool | Purpose |
|------|---------|
| [COMThanasia/PermissionHunter](https://github.com/CICADA8-Research/COMThanasia) | Enumerate COM objects with launch/activate permissions |
| CLSIDBruteforceScanner | In-memory scan for CLSIDs running as Interactive User |
| [SessionHop](https://github.com/3lp4tr0n/SessionHop) | IHxHelpPaneServer-based session hijack |
| ComDiver | Identify hijackable COM object registry paths |
| ComHijackWrite | Execute COM hijack |

## Key CLSIDs (Cross-Session Eligible)

| Application | AppID | CLSID | Principals |
|-------------|-------|-------|------------|
| Speech Runtime | {1725704B-...} | {38FE8DFE-...} | Admins, SYSTEM |
| sppui | {0868DC9B-...} | {F87B28F1-...} | Admins, SYSTEM |
| Auth UI CredUI | {924DC564-...} | {924DC564-...} | Admins, SYSTEM |

## Usage Examples

```bash
# Enumerate permissions
PermissionHunter.exe -outfile result -outformat xlsx

# Session hop via IHxHelpPaneServer
dotnet inline-execute SessionHop.exe <session-id> C:\path\to\payload.exe

# sppui cross-session activation
sppui.exe <target-ip> <session-id> <username> <password> <domain> "cmd.exe /c whoami"
```

## Detection

| Data Source | Event ID | Detects |
|------------|----------|---------|
| Windows Events | 4688 | Process Creation (HelpPane.exe, slui.exe, WmiPrvSE.exe) |
| Windows Events | 4663 | Registry Key Modification |
| Sysmon | 1 | Process Create (unusual parent-child) |
| Sysmon | 13 | Registry value set |

### SIGMA Rule (HelpPane.exe child process)

```yaml
title: Suspicious Child Process of HelpPane.exe
detection:
  selection:
    ParentImage|endswith: '\HelpPane.exe'
  filter_legit:
    Image|endswith:
      - '\HelpPane.exe'
      - '\iexplore.exe'
      - '\msedge.exe'
      - '\msedgewebview2.exe'
  condition: selection and not filter_legit
level: high
```

### Key Indicators

- HelpPane.exe spawning non-browser children (discontinued in Win10/11)
- slui.exe initiated remotely
- WmiPrvSE.exe creating processes (WMI-based activation)
- Registry modifications to CLSIDs under HKLM\SOFTWARE\Classes\AppID

## CADRE Application

- Novel lateral movement from SYSTEM on mbr01 → analyst_cloud session
- Alternative to PsExec/WMI — no service creation, no named pipe
- Test: enumerate COM objects on mbr01, find eligible CLSIDs, activate in analyst_cloud session
- Detection: Sysmon EID 1 (HelpPane.exe, slui.exe anomalies), EID 13 (CLSID registry modification)

---

*Last updated: 2026-06-09*
