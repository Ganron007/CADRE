# CAMPAIGNS v2 — G — Pre-Auth DC Exploits (Standalone)

> **Campaign v2** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA.md`](../CAMPAIGNS-METADATA.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v2.md`](../CAMPAIGNS_v2.md) · **Topology:** [`CAMPAIGNS.md`](../CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v2.md`](../CAMPAIGNS_v2.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### G — Pre-Auth DC Exploits (Standalone)

These exercises demonstrate what happens when a critical CVE hits a DC. Run ONLY with snapshots in place — they crash the target. NOT part of main campaign (would short-circuit Phases 1-3).

#### CVE-2026-41089 — Netlogon CLDAP Stack Buffer Overflow (CVSS 9.8 CRITICAL) 🆕 READY

**Source:** https://github.com/0xABCD01/CVE-2026-41089 (PoC by 0xABCD01, 171 stars, 60 forks, MIT license). Cloned to `docs/internal/references/sources/cve-2026-41089/`.
**CVE:** CVE-2026-41089 (CVSS 9.8 CRITICAL, CWE-121 Stack-based Buffer Overflow, published 2026-05-12 by Microsoft)
**Tool:** `poc.py` (Python 3.8+, no third-party deps, 299 lines)
**MITRE:** T1210 (Exploitation of Remote Services) + T1190 (Exploit Public-Facing Application)

**Vulnerability mechanism:**
- `NlGetLocalPingResponse` allocates a 528-byte stack buffer (`Src[528]`)
- Hands it to `BuildSamLogonResponse` → calls `NetpLogonPutUnicodeString` to write Unicode strings
- **Root cause:** `NetpLogonPutUnicodeString` receives max length in **bytes** but treats it as **WCHAR count** → strings occupy 2x expected space
- "User" field in CLDAP filter (130 wchars = 260 bytes on wire) + other strings overflow the buffer
- LSASS crashes → DC reboots in ~60 seconds

**Affected systems (CADRE DCs presumed vulnerable):**
| Server | Fixed In |
|--------|----------|
| 2012 / 2012 R2 | ESU-only patches |
| 2016 | 10.0.14393.9140 |
| 2019 | 10.0.17763.8755 |
| 2022 | 10.0.20348.5074 |
| 2022 23H2 | 10.0.25398.2330 |
| **2025** | **10.0.26100.32772** |

**Attack vector:** UDP 389 (CLDAP), pre-authentication, **zero credentials required**, single crafted UDP packet.

**Pre-test checklist (CRITICAL — don't crash a production DC):**
- [ ] Snapshot dc01, dc02, dc03 before testing (VMware `vmrun.exe snapshot`)
- [ ] Verify DC patch level on each: `Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name CurrentBuild, UBR` (Server 2025 fixed: 10.0.26100.32772)
- [ ] Test target = **dc02 FIRST** (child domain DC, less critical than dc01)
- [ ] UDP/389 reachable from Kali to target DC (`nmap -sU -p 389 192.168.77.11`)
- [ ] Notify team DC will be down ~60 seconds during test
- [ ] Prepare for `Reset-ComputerMachinePassword` cleanup if needed

**Test plan:**
```bash
# On Kali
cd docs/internal/references/sources/cve-2026-41089

# Phase 1: connectivity check (short username, no overflow)
python3 poc.py 192.168.77.11 child.cadre.local
# Expected: DC responded. Target is alive.

# Phase 2: overflow attempt (130-char username by default)
python3 poc.py 192.168.77.11 child.cadre.local -l 130
# Expected: No response. LSASS may have crashed.

# Phase 3: liveness check (auto after 3s delay)
# If DC is dead: "DC is not responding. LSASS likely crashed. Expect reboot in ~60s."
```

**Expected behavior:**
- **If vulnerable (build < 10.0.26100.32772):** DC's LSASS crashes → no UDP/389 response → DC reboots in ~60s
- **If patched (build >= 10.0.26100.32772):** DC stays alive → no crash → "Try a larger payload: -l 180"

**Telemetry to capture during attack:**
- **Network:** Zeek `udp.log` (CLDAP traffic on port 389) + `udp` notice for oversized search filter
- **Network:** Suricata (new rule candidate for CLDAP overflow pattern — oversized User attribute)
- **Host:** WinSec 1000 (Application Error — `netlogon.dll` crash) on target DC
- **Host:** WinSec 5805 (The LSASS process was terminated)
- **Host:** Sysmon EID 1 (process creation on DC after reboot — may show exploit-related processes if any persist)
- **Host:** Enable Netlogon debug logging pre-test: `nltest /dbflag:0x2080ffff`

**Detection rules to build (post-test):**
- **Suricata new rule (proposed SID:1000100):** Alert on CLDAP search requests where `User` filter attribute > 20-30 characters
  ```
  alert udp any any -> any 389 (msg:"CADRE CVE-2026-41089 Netlogon CLDAP overflow attempt - oversized User attribute"; \
    content:"|A3 04|User"; pcre:"/User\x04[\x81\x82\x83]?[\x50-\xFF]/"; \
    sid:1000100; rev:1;)
  ```
- **Zeek new script `cadre-cldap.zeek`:** Watch for CLDAP search requests with oversized `User` attribute
- **Elastic KQL (WinSec 1000 with netlogon.dll):** `event.code:1000 AND winlog.event_data.SourceName:netlogon`
- **Suricata SID for UDP/389 flood:** Optional — multi-packet detection of CLDAP scanning

**Post-test:**
- Promote CAMPAIGNS-METADATA.md Mechanics section from STUB to TESTED with actual telemetry
- Update CAMPAIGNS.md WT status from 🆕 to ✅ (if worked) or ❌ Patched (if build >= 32772)
- Document outcome in `docs/internal/plan01-telemetry-catalog/phase1-source-matrix/tracker.md` (post-campaign)
- Add to `plan1.7` defense deepening as detection engineering deliverable
- Cross-reference: Item #65 Zerologon Alternative (superseded), Item #76 Onelogon (also exploits Netlogon but different vuln class)

**Mitigation (if vulnerable — for production hardening reference):**
- Install May 2026 Microsoft security update (build 10.0.26100.32772)
- Restrict UDP 389 inbound to trusted management subnets (firewall rule)
- 0patch ships micropatches for legacy Server versions (single instruction fix: `mov edx, 0x40` to halve max username length)

**Why standalone (not main campaign):**
- Unauthenticated DC compromise would short-circuit the entire credential chain (Phases 1-3 become unnecessary)
- CADRE's main campaign demonstrates misconfiguration-based attacks, not CVE exploits
- But valuable as a standalone exercise: tests detection of Netlogon exploitation, shows what happens when a critical CVE hits

**Cross-references:**
- Campaign_suggestions.md #33 (full entry with PoC details, detection rules, mitigation)
- Campaign_suggestions.md #76 Onelogon Zero-Channel (different Netlogon vuln class — also bypasses post-Zerologon hardening)
- Item #65 Zerologon Alternative — superseded by CVE-2026-41089 + Onelogon

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-f.md`](CAMPAIGNS-RUNBOOK-f.md)
