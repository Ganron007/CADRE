# CADRE — Project Goals

```
CADRE
├── C — Cloud       ── Entra + Azure + Azure attack scenarios + Azure RM
├── A — Agentic     ── LangGraph + DFIR-Nexus + multi-LLM + Velociraptor MCP
├── D — DFIR        ── Elastic SIEM + Velociraptor + Plaso + Hayabusa + Timesketch
├── R — Red-team    ── 60+ red-team attack surfaces · multi-domain AD + cloud
└── E — Environment ── Server 2025 + Linux AD · 7 core VMs + 3 extensions 
```

**CADRE** — *Cloud · Agentic · DFIR · Red-team · Environment* — is an open-source MIT-licensed hybrid identity attack + investigation lab. The first open-source environment combining red-team practice, agentic AI investigation, DFIR tooling, cloud identity (Azure/Entra), and 8 industry certifications in a single instrumented substrate.

---

## What CADRE Does

1. **Red-team practice** — 60 walkthroughs covering CRTP, CRTE, CESP-ADCS, HTB-CAPE, OSCP+, WKL-OADOC, CARTP, CARTE + 2026 CVEs. Practice attacks against a live multi-domain AD + Azure environment.

2. **Telemetry knowledge via offense** — every attack produces ground-truth telemetry (Windows Events, Sysmon, Elastic Defend EDR, Zeek network logs, PCAP, Velociraptor artifacts). Learn what attacks look like by executing them.

3. **DFIR investigation practice** — use professional forensic tools (Velociraptor VQL, Hayabusa, Plaso/Timesketch, KAPE, Volatility 3) to investigate the aftermath of each attack.

4. **Agentic AI investigation** — a LangGraph multi-agent pipeline (6 specialized agents) consumes the same telemetry and produces findings via DFIR-Nexus. Proves that AI-assisted incident response works on real evidence.

5. **Cloud + hybrid identity** — Entra Cloud Sync, Azure attack scenarios, Azure RM attacks (CARTE-level), hybrid attack chains bridging on-prem AD and cloud Entra ID.

6. **C2 practice** — C2Stack integration (Mythic/Sliver/Havoc) for realistic command-and-control traffic that feeds into the same telemetry pipeline.

---

## 8 Certification Coverage

> Detailed per-cert syllabus-to-walkthrough mapping with honest % coverage:
> [`cert-coverage.md`](cert-coverage.md).



| Certification | What it covers | CADRE alignment |
|---------------|---------------|-----------------|
| **CRTP** | AD pentesting fundamentals | 10/13 techniques + modern replacements |
| **CRTE** | AD expert (cross-forest, delegation, dMSA) | 10/10 + SOAPHound + cross-forest Kerberoast |
| **CESP-ADCS** | Certificate Services abuse | ESC1-14 matrix · ESC15 excluded (Server 2025 rejects v1 schema) · ESC12 N/A |
| **HTB CAPE** | AD pentesting expert + coercion + Linux | Full coercion + ADCS + MSSQL on Windows + Linux |
| **OSCP+** | Offensive Security AD portion | All + AMSI/logging awareness |
| **WKL OADOC** | WhiteKnight Labs offensive AD | Full SCCM Misconfiguration-Manager + Virtual Smart Cards |
| **CARTP** | Certified Azure Red Team Professional | Azure attack scenarios + Cloud Sync + hybrid chains |
| **CARTE** | Certified Azure Red Team Expert | Azure RM RBAC + PIM + multi-tenant + Azure Arc |

---

## Roadmap

| Plan | What | Status |
|------|------|--------|
| **0** | Foundation: 7 VMs + attack surface + telemetry stack | Deployed |
| **1** | Telemetry Catalog: 60 Sigma YAML mapping attack → expected artifacts | Not started |
| **2** | Exporter: Multi-source evidence bundle (DFIR-Nexus schema) | Not started |
| **3** | Reproducibility: Snapshot baseline + health-check + cycle script | Not started |
| **4** | Coverage Visualization: DeTT&CT → ATT&CK Navigator heatmap | Not started |
| **5** | Detection-as-Code: Sigma → Elastic TOML + GitHub Actions CI | Not started |
| **6** | Hunting Playground: PEAK + TaHiTI hypotheses + VQL hunt library | Not started |
| **7** | Agentic DFIR Pipeline: LangGraph + DFIR-Nexus + multi-LLM router | Not started |
| **8** | Threat Intelligence: MISP (optional — Elastic TI baseline first) | Not started |
| **9** | Memory + Disk Forensics: WinPMEM + AVML + Volatility 3 + Plaso | Not started |
| **10** | C2 + Adversary Emulation: C2Stack (Mythic/Sliver/Havoc) | Not started |
| **11** | Cloud + Hybrid Identity: 6 sub-plans (Entra, Azure attack scenarios, Azure RM, hybrid chains, log collection, AzureHound) | Not started |

---

## What Makes CADRE Unique (2026)

| Capability | Other open-source labs | CADRE |
|------------|----------------------|-------|
| All DCs on Server 2025 | 2019/2022 | ✅ |
| Server 2025-only telemetry channels (Kerberos, KDC, LDAP-Client, Credential-Guard, Security-Mitigations) | None | ✅ enabled by `cadre-dfir-monitoring.ps1` |
| Full SCCM Misconfiguration-Manager matrix | None or minimal | ✅ site CAD on mbr02 — NAA/PXE/push/CRED-2 |
| Linux AD member (MSSQL + NFS-krb + Podman) | None | ✅ |
| Linux AD-substrate audit (auditd + MSSQL Linux audit + SSSD debug + podman events + VR Linux artifacts) | None | ✅ greenfield — see Linux Telemetry Baseline in [`architecture.md`](architecture.md) |
| Single-source-of-truth Windows audit script (49 subcats + PS deep + NTLM + 26 channels) | scattered partial registry tweaks | ✅ `cadre-dfir-monitoring.ps1` |
| ADCS ESC matrix (12/15 — ESC5/12/15 out of scope) | Various partial | ✅ |
| Agentic DFIR pipeline (LangGraph + multi-LLM) | None | ✅ |
| Azure attack scenarios (CARTP) | None | ✅ |
| Azure RM CARTE-level content | None | ✅ |
| Hybrid attack chains (on-prem ↔ cloud) | None | ✅ |
| Offline + tenant dual-mode for cloud content | None | ✅ |
| 8 industry certifications aligned | 1-2 typically | ✅ |
| 2026 CVE coverage (SPN Unicode, RC4 deprecation, BadSuccessor) | None | ✅ |
| Multi-LLM cloud agent harness | None | ✅ |
| Python deployer, no WSL2 | WSL2-dependent | ✅ |

**Cost: $0 baseline.** Free tier M365 dev tenant + Azure free trial covers all cloud content.

---

## Current Status

**Plan 0 — Deployed.** All infrastructure, attack surface, and telemetry stack configured and verified. 124/127 static structure checks pass (3 non-passing = user-provided installer media, gitignored). 60 attacks configured. SCCM on mbr02, ADCS on dc01. Playbooks are self-contained at `ansible/playbooks/`. See [deployment.md](deployment.md) for deploy instructions.

---

## Links

- [Deployment Guide](deployment.md)
- [Architecture](architecture.md)
- [Extensions](extensions.md)
- [Attack → Telemetry → Investigation Workflow](forensic-workflow.md)
