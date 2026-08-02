# CAMPAIGNS v3 — Branch B — ADCS (Certificate Services)

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA-v2.md`](../CAMPAIGNS-METADATA-v2.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`archive/CAMPAIGNS.md`](../archive/CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### Branch B: ADCS (Certificate Services)


**Diverges from:** Phase 4 (BloodHound reveals ADCS templates).
**Converges to:** Phase 7 (certificate auth can give DA/EA without SID History).
**CA Server:** dc01.cadre.local — CA name `cadre-CA`.

> 💡 **Pre-Certipy visual scan:** Run [ADeleg](Phase 0 Step 7) from mbr01 first to visually identify ADCS template misconfigurations (ESC1-8) BEFORE running `certipy find -vulnerable`. ADeleg flags ESC4 (vulnerable template ACLs — WriteOwner/WriteDacl), ESC1 (enrollee supplies subject), ESC2 (any purpose EKU), ESC3 (enrollment agent EKU). Useful for quick triage without triggering Certipy's noisier LDAP queries.

AD CS is deployed on dc01 with **12 in-scope ESC misconfigurations**. Each exploits a different certificate service weakness. Template names in CADRE are prefixed `CADRE-ESC`*.


| ESC#  | Template                  | Vulnerability                                                                                      | Requires             |
| ----- | ------------------------- | -------------------------------------------------------------------------------------------------- | -------------------- |
| ESC1  | `CADRE-ESC1`              | Manager approval=False + Enrollee Supplies Subject + Client Auth EKU                               | Authenticated user   |
| ESC2  | `CADRE-ESC2`              | Any Purpose EKU (`2.5.29.37.0`) + Supply Subject                                                   | Authenticated user   |
| ESC3  | `CADRE-ESC3-Agent/Target` | Certificate Request Agent EKU + authorized signature                                               | Agent enrollment     |
| ESC4  | `CADRE-ESC4`              | Engineering-Cadre has WriteDacl on template                                                        | Template ACL write   |
| ESC6  | *(CA-level)*              | `EDITF_ATTRIBUTESUBJECTALTNAME2` flag enabled                                                      | CA admin             |
| ESC7  | *(CA-level)*              | `lead_engineering` has ManageCA + Issue rights                                                     | Any user             |
| ESC8  | *(Web Enrollment)*        | CertSrv app pool as NetworkService (NTLM relay)                                                    | Cred coercion        |

> **ESC8 (WT052) — DEFERRED 2026-08-01 (root cause documented):** Prior attempts treated ws01's kernel-held port 445 as the blocker. Live testing (tcpdump on relay host + relay logs) proved the REAL blocker: **no SMB-authenticated coercion works on Server 2025 in this lab.** (1) The v5 "custom SMB port `--smb-port 8445` + Coercer `@8445` UNC" premise is FALSE — the Windows SMB client does not honor `@port` in UNC (zero TCP connections to non-445 ports captured). (2) MS-RPRN (WT017, the only working coerce) makes the victim dial the attacker's **RPC endpoint 135 anonymously** ("Empty username ... just waiting" in impacket `rpcrelayserver.py`) — never an authenticated SMB session. (3) MS-EFSR blocked, MS-DFSNM/MS-FSRVP/MS-EVEN no dial-out. ADCS web-enrollment surface remains configured (401 = NTLM challenge). **Revisit at end** (candidates: Kerberos-relay/krbrelayx, or restoring an SMB-coerce primitive).
| ESC9  | `CADRE-ESC9`              | `NO_SECURITY_EXTENSION` flag (`0x80000`)                                                           | Write on user object |
| ESC10 | *(Registry)*              | `StrongCertificateBindingEnforcement=0` + `CertificateMappingMethods=31`                           | Write on user        |
| ESC11 | *(ICPR)*                  | `0x43E0000` flags — ICPR enabled, integrity removed                                                | Network access to CA |
| ESC13 | `CADRE-ESC13`             | Issuance Policy OID → `Command-Cadre` group (Universal)                                            | Cert enrollment      |
| ESC14 | `CADRE-ESC14`             | Client Authentication + `altSecurityIdentities` mapping                                            | Write on AD object   |
| ESC16 | *(CA-level)*              | `DisableExtensionList` contains SID OID (`1.3.6.1.4.1.311.25.2`) — globally disables SID embedding | ManageCA rights      |


> **Out of scope:** ESC5 (CA object ACL not configured). ESC12 (no formal definition). **Excluded:** ESC15 (Server 2025 rejects v1 schema).

> **Verification note (2026-08-01 — deep):** Fresh `certipy find -vulnerable` (chief_command) confirmed the live surface. **Deployed vulnerable templates:** CADRE-ESC1 (ESC1), CADRE-ESC2 (ESC1+ESC2+ESC3+ESC17), CADRE-ESC3-Agent/Target (ESC3), CADRE-ESC4 (ESC4 — Engineering-Cadre WriteDacl), CADRE-ESC9 (ESC1+ESC9), MachineEnrollmentAgent (default, ESC4 flag). **NOT deployed:** CADRE-ESC13/ESC14 (docs list them, templates absent), ESC6 (CA User Specified SAN = Disabled). CA cadre-CA flags **ESC7** (lead_engineering ManageCA+ManageCertificates+Enroll+Read), **ESC8** (HTTP web enrollment), **ESC11** (ICPR no encryption). **Verified live 2026-08-01:** ESC1 (WT050), ESC3 (WT051), UnPAC (WT053), **ESC2** (CADRE-ESC2, low-priv hunter_dfir → PKINIT admin), **ESC9** (CADRE-ESC9, → PKINIT + NT hash), **ESC4** (CADRE-ESC4, lead_engineering WriteDacl → template modify → enroll admin; template restored), **ESC7** (lead_engineering `certipy ca -add-officer` succeeded/cleaned). **Deferred with ESC8:** ESC11 (relay family). Recurring flags: ESC2/4/7/9 require `-sid` + `-dynamic-endpoint` on req, NetBIOS `-on-behalf-of` for ESC3, kill orphaned certipy procs before `certipy auth`.

**Common command pattern (ESC1):**

```bash
# Live template names are CADRE-ESC* (see adcs-configuration-guide.md)
certipy req -u chief_command@cadre.local -p 'C0mm@nd_Ch1ef!' -ca cadre-CA \
  -target dc01.cadre.local -template CADRE-ESC1 -upn administrator@cadre.local -dc-ip 192.168.77.10
certipy auth -pfx administrator.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

**Full ESC chain (Plan 1.1 — run as Branch B graph, not forever deferred):**

1. `certipy find -vulnerable` (or ADeleg visual) → pick ESC  
2. ESC1/2/3/4/6/7/9/10/11/13/14 as applicable from table above  
3. ESC8 after coercion (Phase 5 PrinterBug / coerce_plus)  
4. Auth with PFX → DA/EA path → converge Phase 7  

#### UnPAC-the-Hash (Branch B — after ESC cert) ⏳

**Source:** SpecterOps U2U / UnPAC-the-Hash. **Status:** first-class Branch B step for Plan 1.1 (not suggestions-only).

After obtaining a usable cert (ESC1/ESC8/etc.), request a TGT via PKINIT then abuse User-to-User to recover the account’s NT hash without offline cracking:

```bash
# After certipy auth / PKINIT TGT in ccache
# Tooling: certipy / impacket / Whisker-class U2U — verify live against Server 2025
certipy auth -pfx user.pfx -dc-ip 192.168.77.10 -domain cadre.local
# Then U2U / UnPAC path per unpac-the-hash writeup → NT hash into CredentialLedger
```

**Why in campaign:** bridges Branch B cert → pass-the-hash / further Kerberos without hashcat. Seed ledger may still hold lab cleartext; UnPAC is for telemetry + realistic post-cert tradecraft.

**Detection:** Kerberos PKINIT + unusual U2U; WinSec 4768/4769 anomalies; Certipy LDAP noise.

#### ESC16 — CA SID-Extension Disable (WT109) ⏳

**Source:** SpecterOps ESC16 research. If `DisableExtensionList` on the CA contains the SID OID (`1.3.6.1.4.1.311.25.2`), the CA strips SID extensions from issued certs — a **CA-admin-level** misconfiguration (needs ManageCA, already held by `lead_engineering` — ESC7 verified). Adopted 2026-08-02 from `Campaign_suggestions.md` upgrade candidates.

```bash
# Check CA extension config (certipy CA ACL / certsrv config):
# If DisableExtensionList contains the SID OID → issued certs lack SID → SID-based authZ broken
certipy ca -u lead_engineering@cadre.local -p 'Eng_L3ad!' -dc-ip 192.168.77.10 -ca cadre-CA -show
```

**Why in campaign:** extends Branch B with a CA-level (not template-level) primitive; ManageCA already proven via ESC7.

**Test:** verify `DisableExtensionList` state on cadre-CA; if configured, demonstrate effect on issued certs.

**Detection:** CA config changes (WinSec 4886/4887), certipy CA ACL ops.

**Cross-refs:** Branch B ESC7 (verified), `Campaign_suggestions` ESC16.

---

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-branch-a.md`](CAMPAIGNS-RUNBOOK-branch-a.md) · Next: [`CAMPAIGNS-RUNBOOK-branch-c.md`](CAMPAIGNS-RUNBOOK-branch-c.md) →
