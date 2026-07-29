# CADRE — Documentation Map

<!-- AUDIENCE: PUBLIC. Safe to publish. Never link to docs/internal/ from this file. -->

Welcome. This page is the entry point to all CADRE documentation. Pick the doc that matches
what you are trying to do.

```
CADRE
├── C — Cloud       ── Entra + Azure + Azure attack scenarios + Azure RM
├── A — Agentic     ── LangGraph + DFIR-Nexus + multi-LLM + Velociraptor MCP
├── D — DFIR        ── Elastic SIEM + Velociraptor + Plaso + Hayabusa + Timesketch
├── R — Red-team    ── 60+ red-team attack surfaces · multi-domain AD + cloud
├── E — Environment ── Server 2025 + Linux AD · 7 core VMs + 3 extensions · SCCM + ADCS
```

---

## Start Here

| You want to… | Read this |
|--------------|-----------|
| Understand what CADRE *is* in 60 seconds | [`README.md`](README.md) |
| Understand *why* it exists and the C-A-D-R-E pillars | [`docs/goals.md`](docs/goals.md) |
| See the topology, VMs, data flow, indices, detection coverage | [`docs/architecture.md`](docs/architecture.md) |
| Understand the cycle: attack → telemetry → investigate → export → reset | [`docs/forensic-workflow.md`](docs/forensic-workflow.md) |
| Track what changed and when | [`CHANGELOG.md`](CHANGELOG.md) |

---

## Deploy CADRE

| You want to… | Read this |
|--------------|-----------|
| Deploy the lab end-to-end (prereqs → 4 stages → verify) | [`docs/deployment.md`](docs/deployment.md) |
| Add a telemetry extension (ELK-Fleet, Net-Monitor, Velociraptor, MISP, C2Stack) | [`docs/extensions.md`](docs/extensions.md) |
| Verify a deploy actually works (5-stage checklist, copy-paste commands) | [`docs/testing-recommendations.md`](docs/testing-recommendations.md) |
| Look up every logging source (channel / EID / index / sample query) | [`docs/dfir-logging-reference.md`](docs/dfir-logging-reference.md) |
| See coverage % for all certifications (internal reference) | Internal certification mapping (maintainers only) |

Per-extension details live in [`docs/extensions.md`](docs/extensions.md). Playbooks are self-contained in `ansible/playbooks/`.

---

## Use the Attack Matrix

After deployment, the attack matrix is where the actual content lives — walkthroughs,
scripts, study guides, detection rules, cloud scenarios.

| You want to… | Read this |
|--------------|-----------|
| Browse all 60 walkthroughs + cert alignment | [`attack-matrix/README.md`](attack-matrix/README.md) |
| Find a walkthrough for a specific technique | [`attack-matrix/01-walkthroughs/README.md`](attack-matrix/01-walkthroughs/README.md) |
| Run an attack from a script (user-managed Kali) | [`attack-matrix/04-automation/README.md`](attack-matrix/04-automation/README.md) |
| Follow a structured study path | [`attack-matrix/Campaign/study-guide/README.md`](attack-matrix/Campaign/study-guide/README.md) |
| Cloud + hybrid attacks (Plan 11) | [`attack-matrix/09-cloud/README.md`](attack-matrix/09-cloud/README.md) |

---

## Contribute

| You want to… | Read this |
|--------------|-----------|
| Pick a walkthrough to write up after running it | [`attack-matrix/01-walkthroughs/README.md`](attack-matrix/01-walkthroughs/README.md) |
| Understand the C-A-D-R-E philosophy before extending | [`docs/goals.md`](docs/goals.md) + [`docs/forensic-workflow.md`](docs/forensic-workflow.md) |
| See the data flow before touching telemetry plumbing | [`docs/architecture.md`](docs/architecture.md) |

The repository ships with no required pre-commit hooks. Pull requests welcome — please
include a test plan and reference the relevant `docs/` section your change touches.

---

## Reading Order Recommendations

**New operator (15-min skim):**
`README.md` → `docs/goals.md` → `docs/architecture.md` → `docs/deployment.md`.

**Operator about to deploy (1 hour):**
`docs/deployment.md` end-to-end → `docs/testing-recommendations.md` § 0–2.

**Investigator about to use the cycle:**
`docs/forensic-workflow.md` → `docs/extensions.md` for the tools you'll touch.

**Cert student picking a path:**
`docs/goals.md` → `docs/internal/cert-map/<your-cert>-path.md` → walkthroughs in listed order.

---

## What's Not Linked Here

Internal planning material (roadmap, gap-vs-exists tables, spec drafts, naming-decision history,
session-by-session work logs) lives in `docs/internal/` and `AGENTS.md`. Both paths are
**gitignored** and are not part of the published repository. If you've cloned the project
and don't see them, that's expected.

---

## File Conventions

- Public docs are stable surface — file names and section anchors should not break.
- Cross-references use repo-relative paths (e.g., `docs/architecture.md`) so they work on
  GitHub web view, in IDEs, and in local previews.
- Code blocks use language hints (`powershell`, `bash`, `yaml`) for syntax highlighting.
