# CAMPAIGNS v3 — E — Network Defense Exercises (14)

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA-v2.md`](../CAMPAIGNS-METADATA-v2.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`archive/CAMPAIGNS.md`](../archive/CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

## Exercises (Standalone)



### E — Network Defense (14 exercises)

> **Status (2026-08-02):** Attack side **✅ COMPLETE** — all 13 simulated attacks (WT069–081) + E-10 SNI validated from `ws01` (scripts `04-automation/campaign-e/ws01-campaign-e.ps1` / `-fix.ps1`). Detection rules are **already deployed** in ELK/Suricata/Zeek (`13-net-monitor.yml`: `cadre-ad.rules`, `cadre-phaseb.rules`, `cadre-et-lab.rules`, `cadre-coercion.rules` + `cadre-outbound.zeek` / `cadre-conn-beacon.zeek`). **Fire-confirmation ⏳ PENDING** — deferred to the telemetry catalog stage (monitor `.55` unreachable during the ws01 run). **WT093 Ransomware** tracked separately → future Branch R (see [`plan1.8-offensive-upgrades.md`](../../docs/internal/plan01-upgrades/plan1.8-offensive-upgrades.md) §7).

Attack-side scripts run from `ws01` (beachhead) as `analyst_t1`; each triggers a Suricata SID or Zeek notice. See `04-automation/campaign-e/` and `docs/internal/plan01-telemetry-catalog/phase0.7-defense-deepening/`.


| WT# | Technique                  | Trigger                                | Detection                                 |
| --- | -------------------------- | -------------------------------------- | ----------------------------------------- |
| 069 | DNS DGA                    | `dnsgen` generates 100+ random domains | SID:1000025 (`cadre-ad.rules`)            |
| 070 | DNS TXT Burst              | `dnsgen` TXT queries to lab domain     | SID:1000026 (`cadre-ad.rules`)            |
| 071 | DNS NXDOMAIN Burst         | `dnsgen` queries for nonexistent TLDs  | SID:1000027 rev:2 + Zeek notice           |
| 072 | DNS TLD Abuse              | `dnsgen` queries for unusual TLDs      | SID:1000028 (`cadre-ad.rules`)            |
| 073 | DNS IP Literal             | `dnsgen` PTR queries for IP literals   | SID:1000029 rev:2 (`cadre-ad.rules`)      |
| 074 | TLS 1.0 Downgrade          | `openssl s_client -tls1` to dc01       | SID:1000010 (`cadre-phaseb.rules`)        |
| 075 | SMB Admin Share            | `smbclient //mbr01/admin$`             | ET:2000012 (`cadre-et-lab.rules`)         |
| 076 | HTTP Suspicious UA         | `curl -A` with suspicious user-agent   | ET:2000041 (`cadre-et-lab.rules`)         |
| 077 | HTTP Exploit Path          | `curl` with exploit-like URL path      | ET:2000070 (`cadre-et-lab.rules`)         |
| 078 | HTTP Content-Type Mismatch | `curl -H "Content-Type: ..."` mismatch | ET:2000072 (`cadre-et-lab.rules`)         |
| 079 | SSH Brute Force            | `hydra` SSH brute (10 attempts)        | ET:2000060 (`cadre-et-lab.rules`)         |
| 080 | Long Connection Beacon     | Sustained TCP connection >300s         | Z9 — `cadre-conn-beacon.zeek`             |
| 081 | Outbound Anomaly           | Connection to unknown external IP      | Z1 — `cadre-outbound.zeek`                |
| 093 | Ransomware Simulation      | AES-256 file encryption on disk        | Sysmon EID 11 + Elastic Defend file event |

> **Ransomware Simulation (WT093) — future standalone campaign.** Tracked here in E for now as a single exercise (AES-256 file encryption on disk → Sysmon EID 11 + Elastic Defend file event). It is deliberately **not** re-purposed into the `ws01-campaign-e` scripts — it is a disk-level Impact simulation, not a network trigger. **Planned as a separate Branch R (Ransomware) campaign** with dedicated scripts + more items (shadow-copy deletion T1490, service stop T1489, ransom-note drop, lateral mass-encryption, backup destruction, encryption beacon). See [`plan1.8-offensive-upgrades.md`](../../docs/internal/plan01-upgrades/plan1.8-offensive-upgrades.md) §7.

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-branch-d.md`](CAMPAIGNS-RUNBOOK-branch-d.md) · Next: [`CAMPAIGNS-RUNBOOK-f.md`](CAMPAIGNS-RUNBOOK-f.md) →
