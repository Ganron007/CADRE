# Campaign automation (CADRE glue)

CADRE-owned assets for Plan 1.1. **Not** part of standalone RedStrike product identity.

| File | Role |
|------|------|
| `campaign-graph.yaml` | Full graph v9 (90 nodes: spine + A/B/C/D/E/F/G/H/sql-ai) |
| `lab-seed-creds.example.json` | **Published template** — copy to `lab-seed-creds.json` (gitignored) after deploy |
| `lab-seed-creds.json` | Filled credential ledger for RedStrike (local only; not published) |
| `lab-profiles.yaml` | Machine-readable LAB-PROFILES preflight (`P-DFIR` = full DFIR collection: ws01 + linux01 + VR + elk/monitor) |
| `scope.cadre.example.yaml` | Example scope file for RedStrike API/MCP |

This directory is the **only** home for CADRE missions, graph, and lab seeds. Do not copy these files into standalone RedStrike.

Engine for Plan 01 / CADRE assessment: **`CADRE/tools/red-strike/`** (integrated pin) — run **only** that copy. Upstream features land in sister **`RedStrike\`** and are copied into the pin as needed.
