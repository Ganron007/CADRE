# CADRE — Walkthroughs (61 files, 99 attacks planned)

Each walkthrough is a verified, step-by-step attack against the live CADRE substrate. Produces observable telemetry in Elastic/Zeek/Suricata/Velociraptor.

> **Full campaign:** [`../Campaign/CAMPAIGNS_v3.md`](../Campaign/CAMPAIGNS_v3.md) — 8 phases + 4 branches, 75 campaign attacks across a single identity-driven credential chain.
> **Standalone exercises:** 14 E (network defense) + 10 F (supply-chain). See [`../Campaign/CAMPAIGNS_v3.md`](../Campaign/CAMPAIGNS_v3.md) for details.
> **Per-attack metadata:** [`../Campaign/CAMPAIGNS-METADATA-v2.md`](../Campaign/CAMPAIGNS-METADATA-v2.md) — playbook refs, ACE#s, telemetry expectations.

## On-Prem AD (001-033)

| # | Title | Target VM | Cert |
|---|-------|-----------|------|
| 002 | Kerberoasting (AES) | dc03 | CRTE |
| 003 | AS-REP Roasting | dc02 | CRTP, OSCP+ |
| 004 | Unconstrained Delegation | mbr01 | CRTP, CRTE |
| 005 | Constrained Delegation (w/ protocol transition) | mbr02 | CRTE |
| 006 | Constrained Delegation (w/o protocol transition) | mbr02 | CRTE |
| 007 | RBCD | mbr01 | CRTE, CAPE |
| 008 | Shadow Credentials | dc01 | CRTE |
| 009 | DCSync | dc01 | CRTP, CRTE, OSCP+ |
| 010 | Golden Ticket | any | CRTP, CRTE |
| 011 | Silver Ticket | any | CRTP, CRTE |
| 012 | Diamond Ticket (Server 2025) | dc01 | CRTE |
| 013 | ACL — WriteDacl chain | dc01 | CRTE, CAPE |
| 014 | ACL — GenericWrite | dc01 | CRTE |
| 015 | ACL — ForceChangePassword | dc01 | CRTP, OSCP+ |
| 016 | ACL — GenericAll on OU | dc01 | CRTE |
| 017 | PrinterBug coercion | dc01 | CRTE, CAPE |
| 018 | ~~PetitPotam (EFS)~~ ❌ | dc01 | — |
| 019 | ~~DFSCoerce~~ ❌ | dc01/dc02 | — |
| 020 | ~~ShadowCoerce~~ ❌ | dc01 | — |
| 021 | NTLM relay → LDAP | dc01 | CRTE, CAPE |
| 022 | NTLM relay → SMB | mbr02 | OSCP+, CAPE |
| 023 | GPO abuse | dc01 | CRTE |
| 024 | gMSA password extraction | dc01 | CRTE |
| 025 | AdminSDHolder persistence | dc01 | CRTE |
| 026 | dMSA / BadSuccessor | dc03 | CRTE |
| 027 | SPN Jacking (CVE-2026-25177) | dc01 | — |
| ~~028~~ | ~~Null session enumeration~~ ❌ | dc02 | — |
| 029 | CertPotato (DCOM) | mbr01 | WKL |
| 030 | WSUS abuse | mbr02 | WKL |
| ~~031~~ | ~~Password spray~~ ⏳ | dc01 | — |
| 032 | Token impersonation | mbr01 | OSCP+, CAPE |
| 033 | Cross-forest Kerberoast | dc03 | CRTE |

> Attacks are numbered from **WT#002** — there is no WT#001. (Kerberoasting starts at WT#002 with AES; RC4 is non-viable on Server 2025.)
> **Status notes:** ~~WT028~~ ❌ Invalid — SAMR null bind blocked on Server 2025. ~~WT031~~ ⏳ Pending relocation — needs user list source. ~~WT018-020~~ ❌ Non-functional on Server 2025 (EFSR blocked, DFSNM undetectable, FSRVP unavailable). Remaining 75 attacks active.

## SCCM + Linux + Modern (034-049)

| # | Title | Target VM | Cert |
|---|-------|-----------|------|
| 034 | SCCM NAA credential extraction | mbr02 | WKL |
| 035 | SCCM PXE boot abuse | mbr02 | WKL |
| 036 | SCCM client push relay | mbr02 | WKL |
| 037 | SCCM CMPivot abuse | mbr02 | WKL |
| 038 | SCCM application deployment | mbr02 | WKL |
| 039 | SCCM site server takeover | mbr02 | WKL |

✅ SCCM site server (CAD) installed on mbr02. `RANGE\svc_sccm` has SCCM Full Administrator rights. NAA/PXE/Client Push/CRED-2 all configured and verified. WT#034-036 are WMI-queryable; WT#037-039 require SCCM Console access.

| 040 | MSSQL linked server hop | mbr01→mbr02 | OSCP+, CAPE |
| 041 | MSSQL xp_cmdshell | mbr01 | OSCP+ |
| 042 | MSSQL CLR assembly | mbr02 | CAPE |
| 043 | MSSQL impersonation | mbr01 | OSCP+ |
| 044 | MSSQL-on-Linux lateral | linux01 | CAPE |
| 045 | Linux SSSD ticket extraction | linux01 | CAPE |
| 046 | Linux keytab abuse | linux01 | CAPE |
| 047 | NFS Kerberos mount abuse | linux01 | CAPE |
| 048 | Podman container escape | linux01 | CAPE |
| 049 | Virtual Smart Card enrollment | mbr02 | WKL |

## ADCS ESC Matrix (050-062)

| # | Title | Template | Cert |
|---|-------|----------|------|
| 050 | ESC1 — Enrollee Supplies Subject | CADRE-ESC1 | ADCS |
| 051 | ESC2 — Any Purpose EKU | CADRE-ESC2 | ADCS |
| 052 | ESC3 — Certificate Request Agent | CADRE-ESC3 | ADCS |
| 053 | ESC4 — Writable Template ACL | CADRE-ESC4 | ADCS |
| 054 | ESC6 — EDITF_ATTRIBUTESUBJECTALTNAME2 | CA-level | ADCS |
| 055 | ESC7 — CA Manager Approve | CA-level | ADCS |
| 056 | ESC8 — Web Enrollment Relay | HTTP | ADCS |
| 057 | ESC9 — No Security Extension | CADRE-ESC9 | ADCS |
| 058 | ESC10 — Weak Certificate Binding | Registry | ADCS |
| 059 | ESC11 — RPC Enrollment Relay | RPC | ADCS |
| 060 | ESC13 — Issuance Policy Group Map | CADRE-ESC13 | ADCS |
| 061 | ESC14 — Explicit Cert Mapping | CADRE-ESC14 | ADCS |
| 062 | ESC15 — EKUwu (v1 Template) | CADRE-ESC15 | ADCS |

## Cloud + Hybrid (Plan 11 — separate numbering)

See `09-cloud/` for Azure attack scenarios (C01-C09), hybrid chains (H01-H04), and Azure RM (A01-A04).

## Per-Walkthrough Telemetry Verification

Every walkthrough must, at minimum, verify which of these indices the attack landed in (target depends on attack type):

**Windows attacks (001-043, 049-062, C/H/A series):**
`logs-system.security-*`, `logs-windows.sysmon_operational-*`, `logs-windows.powershell-*`,
`logs-endpoint.*`, `logs-zeek.*-*`, `logs-suricata-*`, plus a VR hunt where appropriate.

**Linux attacks (044-048):**
`logs-auditd.log-*` (filter by `auditd.log.key` matching `mssql_keytab`, `keytab_access`,
`sssd_cache`, `mount_syscall`, `container_escape`, etc. — see the Linux Telemetry Baseline table in [`docs/architecture.md`](../../docs/architecture.md)),
`logs-mssql.audit-*`, `logs-sssd-*`, `logs-podman-*` (osquery deferred to Plan 0.5 — `logs-osquery_manager.result-*` not yet available),
plus `cadre-linux-triage` VR hunt (includes `CADRE.Linux.KeytabFingerprints`).

## Status

Scaffolded. Walkthroughs written as each attack is verified against the deployed lab. New attacks (WT063–WT103) have automation scripts in `04-automation/campaign-{e,g,h}/` but walkthrough markdown files are pending.
