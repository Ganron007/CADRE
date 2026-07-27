# CAMPAIGNS v2 — Branch B — ADCS (Certificate Services)

> **Campaign v2** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA.md`](../CAMPAIGNS-METADATA.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v2.md`](../CAMPAIGNS_v2.md) · **Topology:** [`CAMPAIGNS.md`](../CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v2.md`](../CAMPAIGNS_v2.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

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
| ESC9  | `CADRE-ESC9`              | `NO_SECURITY_EXTENSION` flag (`0x80000`)                                                           | Write on user object |
| ESC10 | *(Registry)*              | `StrongCertificateBindingEnforcement=0` + `CertificateMappingMethods=31`                           | Write on user        |
| ESC11 | *(ICPR)*                  | `0x43E0000` flags — ICPR enabled, integrity removed                                                | Network access to CA |
| ESC13 | `CADRE-ESC13`             | Issuance Policy OID → `Command-Cadre` group (Universal)                                            | Cert enrollment      |
| ESC14 | `CADRE-ESC14`             | Client Authentication + `altSecurityIdentities` mapping                                            | Write on AD object   |
| ESC16 | *(CA-level)*              | `DisableExtensionList` contains SID OID (`1.3.6.1.4.1.311.25.2`) — globally disables SID embedding | ManageCA rights      |


> **Out of scope:** ESC5 (CA object ACL not configured). ESC12 (no formal definition). **Excluded:** ESC15 (Server 2025 rejects v1 schema).

**Common command pattern (ESC1):**

```bash
certipy-ad req -ca cadre-CA -template ESC1-Template -upn administrator@cadre.local \
  -u analyst_dfir@cadre.local -p 'An@lyst_DF1R!' -dc-ip 192.168.77.10
certipy-ad auth -pfx administrator.pfx -dc-ip 192.168.77.10 -domain cadre.local
```

---

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-branch-a.md`](CAMPAIGNS-RUNBOOK-branch-a.md) · Next: [`CAMPAIGNS-RUNBOOK-branch-c.md`](CAMPAIGNS-RUNBOOK-branch-c.md) →
