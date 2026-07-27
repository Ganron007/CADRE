# CAMPAIGNS v2 — F — Supply-Chain Simulation (10 scenarios)

> **Campaign v2** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA.md`](../CAMPAIGNS-METADATA.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v2.md`](../CAMPAIGNS_v2.md) · **Topology:** [`CAMPAIGNS.md`](../CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v2.md`](../CAMPAIGNS_v2.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---

### F — Supply-Chain Simulation (10 scenarios)

npm threat emulation on linux01 (Bash) + mbr01 (PowerShell). Detected via auditd (process/file) + Zeek (network). See `docs/internal/npm-supplychain-installation-guide.md`. Attribution: integrates [MHaggis/NPM-Threat-Emulation](https://github.com/MHaggis/NPM-Threat-Emulation) (Shai-Hulud worm emulation).


| F-#  | Scenario                                        | MITRE            | Sensor                                            | Detection Rule                                                 |
| ---- | ----------------------------------------------- | ---------------- | ------------------------------------------------- | -------------------------------------------------------------- |
| F-01 | Malicious postinstall POSTs to webhook          | T1195.002, T1059 | auditd proc_exec (linux01) · Sysmon EID 1 (mbr01) | npm-001: `node/npm child process spawns sh/curl/wget`          |
| F-02 | TruffleHog download + secret scan               | T1552, T1105     | auditd execve + Zeek HTTP/SSL                     | npm-002: `trufflehog binary download or execution`             |
| F-03 | Workflow injection (`.github/workflows/`)       | T1195, T1647     | auditd file-watch · Sysmon EID 11                 | npm-003: `.github/workflows file written outside git checkout` |
| F-04 | Package patching (`node_modules/*/index.js`)    | T1565.001        | auditd file-watch · Sysmon FileCreate EID 11      | npm-004: `write to node_modules/* during npm process`          |
| F-05 | Multi-stage `/tmp` download+exec                | T1105, T1059     | auditd exec + file-watch · Zeek conn              | npm-005: `executable written to /tmp then executed`            |
| F-06 | Worm `npm publish` across packages              | T1080            | auditd/Sysmon exec of `npm publish`               | npm-006: `npm publish burst (>2 in 60s)`                       |
| F-07 | Cloud metadata probe (169.254.169.254)          | T1552.005        | auditd execve of curl · Zeek conn                 | npm-007: `connection attempt to 169.254.169.254`               |
| F-08 | Repo weaponization (fake tokens to `data.json`) | T1199, T1567     | git exec + file creation                          | npm-008: `git commit containing token-like strings`            |
| F-09 | Bundle worm chain (`bundle.js` → `/tmp/*.sh`)   | T1059, T1105     | auditd exec chain · Sysmon                        | npm-009: `bundle.js spawns /tmp/*.sh or /tmp/*.ps1`            |
| F-10 | Webhook exfil (all scenarios — network rule)    | T1567.*          | Zeek `http.log` POST · Suricata                   | npm-010: `POST to non-corporate host with base64 body`         |
| F-11 | Cache poisoning (CI side analog)                | T1195.001        | auditd file-watch · Sysmon EID 11                 | npm-011: `write to .npm/_cacache outside install workflow` (held — Plan 0.8 expansion, see Campaign_suggestions #107) |
| F-12 | Tag pollution analog (`npm dist-tag add`)       | T1195.001        | auditd exec of `npm dist-tag`                    | npm-012: `npm dist-tag add to existing tag name` (held — Plan 0.8 expansion, see Campaign_suggestions #107) |

> **GitHub Actions Supply-Chain Patterns (Plan 0.8 expansion + CADRE-Strike defensive):** F-11/F-12 are npm-side analogs of the GitHub Actions supply-chain attack patterns documented in [GMO Flatt Security blog Part 1](https://blog.flatt.tech/entry/2026-github-actions-security-part1) (2026-06-24). 3 attack patterns: vulnerable trigger injection (Ultralytics Dec 2024, nx Aug 2025), tag pollution + Imposter Commits (tj-actions/changed-files Mar 2025, trivy Feb 2026), AI agent over-permission (cline Feb 2026). F-11/F-12 are NOT yet integrated into Plan 0.8 playbook — held for Plan 0.8 expansion. See Campaign_suggestions.md #107 + CAMPAIGNS-METADATA.md "Mechanics: Item #107" for full Mechanics stub. Also applies to CADRE-Strike (Track H) as defensive guardrails when `claude-code-action` or similar is integrated — see Track H entry.

---

---

## Navigation

← Previous: [`CAMPAIGNS-RUNBOOK-e.md`](CAMPAIGNS-RUNBOOK-e.md) · Next: [`CAMPAIGNS-RUNBOOK-exercises-g.md`](CAMPAIGNS-RUNBOOK-exercises-g.md) →
