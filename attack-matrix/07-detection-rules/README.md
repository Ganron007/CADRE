# 07 — Detection Rules

Elastic detection rules mapped to CADRE walkthroughs. Full **Detection-as-Code** rule packs (Sigma → pySigma → Elastic TOML, with CI validation) are authored in **Plan 5** — this directory holds the catalog and the seed rules that already ship live in the lab.

> **Status:** seed rules below are deployed in the lab today (via the ELK-Fleet extension). The per-category TOML packs (`adcs/`, `sccm/`, `kerberos/`, `entra/`, `azure/`, `lateral/`, `2026-cves/`) are created in Plan 5 — they are intentionally absent until then. Walkthrough "Detection Rule:" references resolve to the seed-rule IDs in the table below; where a WT says "no dedicated rule," that detection gap is a Plan 5 backlog item.

## Seed rules shipping in the lab

### Windows (7 seed rules)

| Rule ID | Fires on | Walkthroughs |
|---------|----------|--------------|
| `cadre-002-asrep-roast` | AS-REP roastable TGT request (EID 4768, no preauth) | WT#003 |
| `cadre-003-dcsync` | Directory replication (EID 4662, DS-Replication GUID) | WT#009 |
| `cadre-004-suspicious-proc` | Known attack-tool process names (Sysmon EID 1) | WT#010/011/012, impacket-ticketer |
| `cadre-005-adcs-tamper` | ADCS template/CA config modification | WT#050-061 (ADCS ESC) |
| `cadre-006-ntlm-relay` | NTLM relay indicators | WT#021/022 |
| `cadre-007-zeek-kerberoast` | Kerberoast attempt network signature — KDC rejects the encryption downgrade (Zeek `kerberos.log`) | WT#002, WT#033 |
| `cadre-008-gmsa-extract` | msDS-ManagedPassword read (EID 4662) | WT#008 (Shadow Creds), WT#024 (gMSA) |

(cadre-001 RC4 Kerberoast removed — non-viable on Server 2025; the real Kerberoast signal is cadre-007.)

(2 further Windows seed rules + tuning land in Plan 5.)

### Linux (14 seed rules)

`L01`–`L09`, `L11`–`L15` ship via the ELK-Fleet `linux-seed.ndjson` and cover auditd keys for credential access, Kerberos/SSSD, keytabs, NFS-krb5 mounts, podman, cron/systemd persistence, and home-dir access. Mapped to WT#044–048. (**L10 retired** — number gap reserved.) Full mapping table is added in Plan 1 (Telemetry Catalog).

## Coverage gaps (Plan 5 backlog)

Walkthroughs that currently have **no dedicated rule** — author these in Plan 5:
- Kerberoasting AES (legitimate-looking traffic — needs behavioral/volume rule)
- Golden / Silver / Diamond Ticket (no native event — needs anomalous-TGT heuristic)
- Constrained-delegation abuse, cross-forest Kerberoast
- SPN Unicode collision (CVE-2026-25177)

## Layout (populated in Plan 5)

```
07-detection-rules/
├── README.md          ← this file (catalog + seed-rule map)
├── adcs/              ← ESC1-14 rules        (Plan 5)
├── sccm/              ← Misconfig-Manager     (Plan 5)
├── kerberos/          ← roast/ticket rules    (Plan 5)
├── lateral/           ← relay/delegation      (Plan 5)
├── entra/  azure/     ← cloud rules           (Plan 5 / Plan 11)
└── 2026-cves/         ← BadSuccessor, SPN dup  (Plan 5)
```
