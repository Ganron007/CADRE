# ADCS Configuration Guide — Manual Path

**Status:** ADCS CA `cadre-CA` IS running on dc01 and all ESC templates are published (18/18 checks pass in `08-adcs-verify.yml`). This document is the tested and verified manual recipe used to configure it. Use it to re-deploy from scratch or to understand the full ADCS setup sequence.

**Target:** `dc01.cadre.local` (Domain Controller + Enterprise Root CA)
**Goal:** Create + publish 9 vulnerable ADCS templates (CADRE-ESC1 through CADRE-ESC15) to enable ESC1-ESC15 attack surface for CESP-ADCS / HTB CAPE / CRTE coverage
**Prerequisite:** dc01 promoted as DC, CA installed (Phase 0 verifies), domain Administrator credentials available
**Unblocks:** Walkthroughs **W050-W061** (12 ADCS walkthroughs) + CESP-ADCS cert coverage from 0% → 80% (12/15 ESCs; ESC5/ESC12/ESC15 out of scope — ESC15 rejected by Server 2025 v1-schema)

---

## TL;DR — Start Here

Six phases. Phase 2 is manual MMC work (~25 min, the long one). All others are quick.

| # | Phase | What it does | Time |
|---|-------|--------------|------|
| 0 | Verify current state | What's already working — don't re-do | 5 min |
| 1 | **ESC8 — Web Enrollment** | Quick win first: get the IIS app pool right | 5 min |
| 2 | **Manual template creation via MMC** | THE big one — 9 templates via `certtmpl.msc` | 20-30 min |
| 3 | ESC9 enrollment flag bit | One ADSI Edit or PowerShell tweak | 2 min |
| 4 | Publish all 9 templates to CA | `certsrv.msc` → publish | 5 min |
| 5 | Verification + snapshot | Lock the result in with `certipy find` | 10 min |

**Why manual instead of Ansible:** Server 2025 + PSPKI 4.4.0 lost the `Add-CATemplate -Name -DisplayName` create+publish API. Modern PSPKI only PUBLISHES existing templates. Direct ADSI/`New-ADObject` hits schema constraint violations (`pKIExpirationPeriod` byte-array format, missing required attrs). 5 hours of automation attempts vs 30 min of MMC work — manual wins.

**Cross-reference:** SCCM config (the other manual path) is at [`sccm-integration-guide.md`](sccm-integration-guide.md). Both are tested and verified. Different VM (mbr02 vs dc01), no shared resources — run in parallel sessions if you have the time.

---

## Phase 0 — Verify Current State

Confirm what's already working before touching anything.

**RDP to dc01** as `cadre\Administrator` / `vagrant` (or SSH via the provisioning VM if WinRM is happier):

```powershell
# 1. CA service running
certutil -ping
# Expected: "CA service is online" — if not, Install-AdcsCertificationAuthority needs to re-run

# 2. PSPKI module installed
Get-Module -ListAvailable PSPKI | Select-Object Name, Version
# Expected: PSPKI v4.4.0 (or newer)

# 3. ESC6 already set
certutil -getreg CA\EditFlags
# Expected: line containing "EDITF_ATTRIBUTESUBJECTALTNAME2"

# 4. ESC10 already set
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\Schannel' StrongCertificateBindingEnforcement
# Expected: 0

# 5. ESC11 already set
certutil -getreg CA\InterfaceFlags
# Expected: 0x4000000 bit set, 0x200 bit NOT set

# 6. ESC7 already set (lead_engineering has ManageCA)
Import-Module PSPKI -Force
Get-CertificationAuthority -Name "cadre-CA" | Get-CertificationAuthorityAcl | Select-Object -ExpandProperty Access
# Expected: row for cadre\lead_engineering with Allow / ManageCA

# 7. List currently-published templates
certutil -catemplates
# Expected: built-in templates (User, Machine, etc.) but NO "CADRE-ESC*" yet
```

Per `ifailedatadcs.txt`, items 1-7 are confirmed working. Items 8-9 are what this guide tackles:

- ❌ ESC8 — Web Enrollment app pool identity (Phase 1)
- ❌ 9 templates (CADRE-ESC1, ESC2, ESC3-Agent, ESC3-Target, ESC4, ESC9, ESC13, ESC14, ESC15) — Phase 2

---

## Phase 1 — ESC8 (Web Enrollment) — Quick Win First

**Why first:** This is 2 minutes of work, gives you a small "I'm making progress" win before the longer Phase 2 grind.

```powershell
# 1. Check if ADCS-Web-Enrollment feature is installed
Get-WindowsFeature ADCS-Web-Enrollment

# 2. If Installed = False, install it:
Install-WindowsFeature ADCS-Web-Enrollment -IncludeManagementTools

# 3. Configure the role (links to the existing CA)
Install-AdcsWebEnrollment -Force

# 4. Verify IIS app pool was created
Import-Module WebAdministration
Get-IISAppPool | Where-Object Name -like "*Cert*"
# Expected row: Name="CertSrv", State="Started"

# 5. Set NetworkService identity (this is what makes ESC8 relay actually abusable)
Set-ItemProperty "IIS:\AppPools\CertSrv" -Name processModel.identityType -Value 2
Restart-WebAppPool CertSrv

# 6. Smoke test — Web Enrollment endpoint reachable
Invoke-WebRequest http://dc01.cadre.local/certsrv -UseDefaultCredentials -UseBasicParsing | Select-Object StatusCode
# Expected: StatusCode 200
```

Done. ESC8 is now exploitable: NTLM relay → http://dc01.cadre.local/certsrv → coerced authentication produces a certificate.

---

## Phase 1.5 — ESC11 (RPC ICPR with No Integrity)

**Why before templates:** ESC11 is a CA-side registry configuration, not a template setting. It enables remote certificate enrollment via DCOM/RPC without integrity enforcement, allowing relay attacks against the CA itself.

### Implementation (dc01 as Administrator)

```powershell
# Enable RPC ICPR interface
certutil -setreg CA\Flags +0x4000000

# Remove integrity enforcement
certutil -setreg CA\Flags -0x200

# Restart CA for changes to take effect
Restart-Service CertSvc
```

If `certutil -setreg CA\Flags` fails because the `Flags` value doesn't exist yet, create it directly:

```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\cadre-CA" -Name "Flags" -Value 0x43E0000 -Type DWord
Restart-Service CertSvc
```

### Verification

```powershell
# Via certutil
certutil -getreg CA\Flags
# Expected: line showing 0x43E0000 or similar with both flags set

# Via registry
$flags = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\cadre-CA" -Name "Flags").Flags
Write-Host "Flags: 0x$('{0:x}' -f $flags)"
Write-Host "ICPR enabled: $((($flags -band 0x4000000) -eq 0x4000000))"
Write-Host "Integrity removed: $((($flags -band 0x200) -ne 0x200))"
# Expected: ICPR enabled = True, Integrity removed = True
```

### What If It Fails?

- **"The system cannot find the file specified"** — the `Flags` value doesn't exist yet. Use the `Set-ItemProperty` approach above to create it.
- **Insufficient access** — run as `CADRE\Administrator` (not an RDP user session).
- **Already configured** — verification shows both flags set. Nothing to do.

---

## Phase 2 — Manual Template Creation (the long one)

Open **`certtmpl.msc`** (Certificate Templates Console) on dc01.

For each of the 9 templates below: **right-click the source template → Duplicate Template** → fill in tabs → OK. Then move to next template.

### MMC tab map — where each setting lives

```
Duplicate Template → Properties dialog tabs:

┌─ General ──── Subject Name ──── Cryptography ──── Extensions ───────┐
│  Compatibility    Issuance Requirements    Server    Security      │
└─────────────────────────────────────────────────────────────────────┘
```

| What we'll set | MMC location |
|----------------|--------------|
| Template name | **General** tab → "Template display name" (template name field auto-fills) |
| Compatibility schema | **Compatibility** tab → "Certification Authority" + "Certificate recipient" dropdowns |
| Subject Name source | **Subject Name** tab → radio buttons |
| EKU (Application Policies) | **Extensions** tab → click "Application Policies" → Edit → Add/Remove |
| Issuance Policy | **Extensions** tab → click "Issuance Policies" → Edit → Add → New (creates OID) |
| Cert Request Agent requirement | **Issuance Requirements** tab → "This number of authorized signatures" |
| Enrollment ACL | **Security** tab → Add group → check Enroll permission |
| Vulnerable ACL (ESC4) | **Security** tab → Add `Engineering-Cadre` → check `Full Control` |

### The 9 templates — exact configurations

For each: defaults are fine UNLESS specified below.

#### CADRE-ESC1 — Enrollee Supplies Subject

| Tab | Setting |
|-----|---------|
| **Source** | Duplicate **`WebServer`** template (not User — User doesn't allow SAN by default) |
| **Compatibility** | Both dropdowns = `Windows Server 2008 R2` (gives v2 schema) |
| **General** | Display name: `CADRE-ESC1` |
| **Subject Name** | ✅ "Supply in the request" (the vulnerability) |
| **Extensions → Application Policies** | Edit → ensure `Client Authentication` is present |
| **Security** | Add `Domain Users` → check **Enroll** |

#### CADRE-ESC2 — Any Purpose EKU

| Tab | Setting |
|-----|---------|
| **Source** | Duplicate `User` |
| **Compatibility** | `Windows Server 2008 R2` |
| **General** | Display name: `CADRE-ESC2` |
| **Subject Name** | ✅ "Supply in the request" |
| **Extensions → Application Policies** | Edit → **Remove all existing** → Add → `Any Purpose` (or click "Make this CA an unrestricted issuer") |
| **Security** | Add `Domain Users` → check **Enroll** |

#### CADRE-ESC3-Agent — Enrollment Agent

| Tab | Setting |
|-----|---------|
| **Source** | Duplicate `User` |
| **Compatibility** | `Windows Server 2008 R2` |
| **General** | Display name: `CADRE-ESC3-Agent` |
| **Extensions → Application Policies** | Edit → Add → `Certificate Request Agent` (1.3.6.1.4.1.311.20.2.1) |
| **Security** | Add `Domain Users` → check **Enroll** |

#### CADRE-ESC3-Target — On Behalf Of

| Tab | Setting |
|-----|---------|
| **Source** | Duplicate `User` |
| **Compatibility** | `Windows Server 2008 R2` |
| **General** | Display name: `CADRE-ESC3-Target` |
| **Issuance Requirements** | ✅ "This number of authorized signatures" = `1` → "Application policy" dropdown = `Certificate Request Agent` |
| **Extensions → Application Policies** | Confirm `Client Authentication` present |
| **Security** | Add `Domain Users` → check **Enroll** |

#### CADRE-ESC4 — Writable Template ACL

| Tab | Setting |
|-----|---------|
| **Source** | Duplicate `User` |
| **Compatibility** | `Windows Server 2008 R2` |
| **General** | Display name: `CADRE-ESC4` |
| **Security** | Add `Engineering-Cadre` → check **Full Control** (this is the ESC4 vuln — group can WriteDacl on the template) |
| **Security** | Also add `Domain Users` → check **Enroll** |

#### CADRE-ESC9 — No Security Extension

| Tab | Setting |
|-----|---------|
| **Source** | Duplicate `User` |
| **Compatibility** | `Windows Server 2008 R2` |
| **General** | Display name: `CADRE-ESC9` |
| **Subject Name** | ✅ "Supply in the request" |
| **Extensions → Application Policies** | Confirm `Client Authentication` present |
| **Security** | Add `Domain Users` → check **Enroll** |
| **Enrollment Flag bit `0x80000`** | ⚠️ **NOT in MMC** — see [Phase 3](#phase-3--esc9-enrollment-flag-bit) below |

#### CADRE-ESC13 — Issuance Policy → Group Mapping

| Tab | Setting |
|-----|---------|
| **Source** | Duplicate `User` |
| **Compatibility** | `Windows Server 2008 R2` |
| **General** | Display name: `CADRE-ESC13` |
| **Extensions → Issuance Policies** | Edit → **Add** → **New** → Name: `CADRE Issuance Policy`, OID: `1.3.6.1.4.1.311.21.55.1` → OK → highlight it → OK |
| **Security** | Add `Domain Users` → check **Enroll** |

> **After OK:** also need to link the OID to a group (one-time AD object edit). PowerShell:
> ```powershell
> $cn = (Get-ADRootDSE).configurationNamingContext
> # Find the OID object — MMC names it with a hex GUID, not the OID string
> $oidObj = Get-ADObject -SearchBase "CN=OID,CN=Public Key Services,CN=Services,$cn" -Filter * -Properties displayName | Where-Object { $_.displayName -eq "CADRE Issuance Policy" }
> $oidObj.DistinguishedName
> # Note the actual DN, use it below
> Set-ADObject -Identity $oidObj.DistinguishedName -Replace @{
>     "msDS-OIDToGroupLink" = "CN=Command-Cadre,OU=Command,DC=cadre,DC=local"
> }
> ```
> **⚠️ Requirements:**
> - Target group must be **Universal** scope (not Global). If group is Global, change first:
>   `Set-ADGroup "CN=Command-Cadre,OU=Command,DC=cadre,DC=local" -GroupScope Universal`
> - `msDS-OIDToGroupLink` attribute value must be the group's **DistinguishedName**
> 
> Now any cert with this issuance policy automatically gets the group's SID added to the user's token at logon.

#### CADRE-ESC14 — Explicit Certificate Mapping

| Tab | Setting |
|-----|---------|
| **Source** | Duplicate `User` |
| **Compatibility** | `Windows Server 2008 R2` |
| **General** | Display name: `CADRE-ESC14` |
| **Extensions → Application Policies** | Confirm `Client Authentication` present |
| **Security** | Add `Domain Users` → check **Enroll** |

> **Note:** ESC14's vulnerability isn't in the template — it's in the `altSecurityIdentities` attribute on target user accounts. The template just needs to exist and be enrollable. The actual exploit is to set `altSecurityIdentities` on a privileged user's AD object to map to the cert subject. That's a separate manual step done during the walkthrough, not Plan 0.

#### CADRE-ESC15 — 🚫 DELIBERATELY EXCLUDED (Server 2025 limitation)

Server 2025's CA hardened v1 template validation. MMC forces all new templates to v2, and `certutil -setcatemplates` rejects v1 schema templates with "Invalid Template." ESC15 cannot be implemented without downgrading CA security, which would break other attack paths.

**What you need to know:**
- Instead of CADRE-ESC15, practice ESC15 using **ESC6** (SAN injection already enabled) which achieves a similar outcome — requesting a cert with alternative EKUs via SAN attributes in the request.
- The remaining **8 templates (ESC1-4, ESC3-Agent/Target, ESC9, ESC13, ESC14)** fully cover the CESP-ADCS attack surface minus ESC5 (out of scope) and ESC12 (out of scope).
- **No guide steps needed** — skip this template in `certtmpl.msc`.

### Workflow tip — do them in batches

Open 3 MMC windows side-by-side:
- **`certtmpl.msc`** — Certificate Templates (where you create/edit templates)
- **`certsrv.msc`** — Certification Authority (where you publish — Phase 4)
- **`adsiedit.msc`** — only needed for the ESC9 flag bit (Phase 3)

Then loop: duplicate → set tabs → OK → switch to certsrv → publish → repeat. ~2 min per template once you have the rhythm.

---

## Phase 3 — ESC9 Enrollment Flag Bit

MMC doesn't expose the `CT_FLAG_NO_SECURITY_EXTENSION` bit (`0x80000`) as a checkbox. Set it after CADRE-ESC9 template is created.

### Option A — PowerShell (recommended)

```powershell
$configNC = (Get-ADRootDSE).configurationNamingContext
$tplDN = "CN=CADRE-ESC9,CN=Certificate Templates,CN=Public Key Services,CN=Services,$configNC"

$tpl = Get-ADObject -Identity $tplDN -Properties "msPKI-Enrollment-Flag"
$current = $tpl.'msPKI-Enrollment-Flag'
$new = $current -bor 0x80000

Set-ADObject -Identity $tplDN -Replace @{ "msPKI-Enrollment-Flag" = $new }

# Verify
(Get-ADObject -Identity $tplDN -Properties "msPKI-Enrollment-Flag").'msPKI-Enrollment-Flag'
# Expected: original value OR'd with 524288 (decimal for 0x80000)
```

### Option B — ADSI Edit GUI

1. Start → run `adsiedit.msc`
2. **Action → Connect to** → "Select a well known Naming Context" = **Configuration** → OK
3. Expand: `CN=Configuration → CN=Services → CN=Public Key Services → CN=Certificate Templates`
4. Right-click `CN=CADRE-ESC9` → Properties
5. Find attribute `msPKI-Enrollment-Flag` → Edit → note current value
6. Add `524288` to current (e.g., if was `0`, set to `524288`; if was `8`, set to `524296`)
7. OK twice

---

## Phase 4 — Publish All 9 Templates to the CA

Templates now exist in AD but are not yet enrollable. Switch to **`certsrv.msc`** (Certification Authority Console):

1. Expand `cadre-CA` → expand `Certificate Templates` folder
2. Right-click the `Certificate Templates` folder → **New → Certificate Template to Issue**
3. In the dialog, multi-select all 9 (Ctrl+click): `CADRE-ESC1`, `CADRE-ESC2`, `CADRE-ESC3-Agent`, `CADRE-ESC3-Target`, `CADRE-ESC4`, `CADRE-ESC9`, `CADRE-ESC13`, `CADRE-ESC14`, `CADRE-ESC15`
4. Click OK

All 9 should now appear in the CA's published list (right pane).

### Verify via command line

```powershell
certutil -catemplates | Select-String "CADRE-ESC"
# Expected: 9 lines, each ending with "AutoEnrollment: All Tasks"
```

---

## Phase 5 — Verification + Snapshot

### Local verification (from dc01)

```powershell
# All 9 templates exist in AD?
$configNC = (Get-ADRootDSE).configurationNamingContext
$expected = @("CADRE-ESC1","CADRE-ESC2","CADRE-ESC3-Agent","CADRE-ESC3-Target","CADRE-ESC4","CADRE-ESC9","CADRE-ESC13","CADRE-ESC14","CADRE-ESC15")
foreach ($t in $expected) {
    $dn = "CN=$t,CN=Certificate Templates,CN=Public Key Services,CN=Services,$configNC"
    if (Get-ADObject -Identity $dn -ErrorAction SilentlyContinue) {
        Write-Host "[+] $t exists in AD" -ForegroundColor Green
    } else {
        Write-Host "[-] $t MISSING from AD" -ForegroundColor Red
    }
}

# All 9 published to CA?
$published = (certutil -catemplates | Select-String "CADRE-ESC").Line
foreach ($t in $expected) {
    if ($published -match $t) {
        Write-Host "[+] $t published to CA" -ForegroundColor Green
    } else {
        Write-Host "[-] $t NOT published" -ForegroundColor Red
    }
}

# ESC9 flag bit set?
$flag = (Get-ADObject -Identity "CN=CADRE-ESC9,CN=Certificate Templates,CN=Public Key Services,CN=Services,$configNC" -Properties "msPKI-Enrollment-Flag").'msPKI-Enrollment-Flag'
if (($flag -band 0x80000) -ne 0) {
    Write-Host "[+] ESC9 NO_SECURITY_EXTENSION flag bit set" -ForegroundColor Green
} else {
    Write-Host "[-] ESC9 flag bit MISSING — re-run Phase 3" -ForegroundColor Red
}
```

### Attacker-perspective verification (from kali or any tool with `certipy`)

```bash
certipy find -u analyst_cloud@cadre.local -p 'Cl0ud_An@lyst!' -dc-ip 192.168.77.10 -stdout
# Expected output should enumerate all 9 CADRE-ESC* templates
# And flag the vulnerable ones in the "Vulnerable Certificate Templates" section:
#   - CADRE-ESC1   (ESC1 — ENROLLEE_SUPPLIES_SUBJECT + ClientAuth + Domain Users)
#   - CADRE-ESC2   (ESC2 — Any Purpose EKU)
#   - CADRE-ESC3   (ESC3 — Cert Request Agent → On-Behalf-Of)
#   - CADRE-ESC4   (ESC4 — Engineering-Cadre WriteOwner/WriteDacl)
#   - CADRE-ESC9   (ESC9 — No Security Extension)
#   - CADRE-ESC13  (ESC13 — Issuance Policy → group)
#   - CADRE-ESC15  (ESC15 — v1 schema)
```

If `certipy find` flags 5+ vulnerable templates, **the ADCS attack surface is live**.

### Snapshot

```powershell
# From the host PowerShell (as admin), with the VM dir as cwd:
vagrant snapshot save dc01 adcs-templates-done
```

From now on, every regression on dc01 is `vagrant snapshot restore dc01 adcs-templates-done` away (~30 sec).

---

## Phase 6 — Update the Ansible Playbook (Optional, Future-Proofing)

You'll never need to re-create templates manually if you do this once. The pattern: detect-missing → fail-loud.

Edit `ansible/roles/adcs/tasks/main.yml` — replace the broken `Add-CATemplate` tasks with a single detection block:

```yaml
- name: Check which ADCS templates exist + are published
  ansible.windows.win_powershell:
    script: |
      $expected = @("CADRE-ESC1","CADRE-ESC2","CADRE-ESC3-Agent","CADRE-ESC3-Target","CADRE-ESC4","CADRE-ESC9","CADRE-ESC13","CADRE-ESC14","CADRE-ESC15")
      $published = (certutil -catemplates 2>$null | Select-String "CADRE-ESC").Line
      $missing = $expected | Where-Object { $published -notmatch $_ }
      $missing
  register: missing_templates
  when: "'dc01' in inventory_hostname"

- name: Fail with actionable message if templates missing
  fail:
    msg: |
      ADCS templates missing from dc01:
        {{ missing_templates.output | default([]) | join(', ') }}
      Server 2025 + PSPKI 4.4 cannot create these programmatically.
      Manual creation required: see docs/internal/adcs-configuration-guide.md
      After creation: vagrant snapshot save dc01 adcs-templates-done
  when:
    - "'dc01' in inventory_hostname"
    - missing_templates.output is defined
    - missing_templates.output | length > 0
```

This makes future `cadre.py install` runs detect the gap and fail loud instead of silently producing a broken lab. Manual creation becomes a one-time documented prereq, not a hidden landmine. Restoring from the `adcs-templates-done` snapshot also restores the templates — no re-creation needed.

### Programmatic alternative (defer — not now)

If you want full automation later, the only reliable scripted method on Server 2025 + PS 5.1 is **`ldifde` clone**:

```powershell
# Dump existing User template as LDIF
ldifde -d "CN=User,CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,DC=cadre,DC=local" `
       -f C:\temp\user.ldif -p Base

# Modify the LDIF (sed/find-replace):
#   dn: CN=User,...       →  dn: CN=CADRE-ESC1,...
#   cn: User              →  cn: CADRE-ESC1
#   displayName: User     →  displayName: CADRE-ESC1
#   msPKI-Cert-Template-OID: <existing>  →  unique OID (increment last octet)
#   ADD: changetype: add  (after dn line)

# Import
ldifde -i -f C:\temp\esc1.ldif -k

# Then publish via PSPKI (this DOES work)
Import-Module PSPKI -Force
$CA = Get-CertificationAuthority -Name "cadre-CA"
$tpl = Get-CertificateTemplate -Name "CADRE-ESC1"
$CA | Add-CATemplate -InputObject $tpl
```

This pattern is bulletproof because every byte comes from an already-valid schema. But it's a separate engineering effort — defer until you have time. Manual MMC + snapshot is the practical Plan 0.5 answer.

---

## After Completing This Guide

1. Flip `plan_status.md` rows for ADCS templates from ⚠️ to ✅
2. Update `cert-coverage.md` CESP-ADCS row from `target 87%` to `current 87%`
3. Append a Session entry to `BUG_FIX_TRACKING.md` documenting the manual completion (link to `ifailedatadcs.txt` for the failed-automation history)
4. Update `attack-matrix/01-walkthroughs/README.md` to mark W050-W062 as practicable
5. Add the detection block (Phase 6) to `adcs/tasks/main.yml` so future deploys fail-loud instead of silent

---

## Cross-Reference

| Related guide | What it covers |
|---------------|----------------|
| [`sccm-integration-guide.md`](sccm-integration-guide.md) | The other manual path — SCCM install on mbr02. Different VM, can be done in parallel session. Unblocks WKL OADOC walkthroughs W034-W039. |
| [`plan0-next-steps-completion.md`](plan0-next-steps-completion.md) | Plan 0 completion master doc — runs both manual paths through E2E smoke tests + clean-baseline snapshot. |
| [`ifailedatadcs.txt`](../../ifailedatadcs.txt) | The failure log that motivated this manual approach (5 scripted attempts, all failed). Worth reading once to understand why we abandoned automation. |
| `monitoring-dfir-specifications.md` | What telemetry these templates produce when enrolled — EID 4886/4887/4888 land in `logs-system.security-*`. |

---

## What This Guide Deliberately Does NOT Touch

- **ESC5** (Vulnerable PKI AD Object Access Control) — environment-specific, requires existing privileged ACLs that don't naturally exist in a fresh lab. Out of scope for CADRE.
- **ESC12** (YubiHSM Storage) — requires physical HSM. Out of scope.
- **The orphaned PSPKI `Add-CATemplate -Name` tasks** in `adcs/tasks/main.yml` — those are dead code from the failed-automation history. Phase 6 above replaces them with the detection block.
- **CA root certificate trust** — already established by Enterprise CA install (auto-trusted by all domain members via GPO).
- **AIA/CDP configuration** — left at defaults; if you later need offline cert revocation testing (CRL Distribution Point attacks), revisit.
