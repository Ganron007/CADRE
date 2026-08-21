# Campaign automation (CADRE glue)

CADRE-owned assets for Plan 1.1. **Not** part of standalone RedStrike product identity — see `red-strike-product.md` (local maintainers).

| File | Role |
|------|------|
| `campaign-graph.yaml` | Full graph v9 (90 nodes: spine + A/B/C/D/E/F/G/H/sql-ai) |
| `lab-seed-creds.json` | Lab credential seed (never commit real prod secrets) |
| `lab-profiles.yaml` | Machine-readable LAB-PROFILES preflight (`P-DFIR` = full DFIR collection: ws01 + linux01 + VR + elk/monitor) |

This directory is the **only** home for CADRE missions, graph, and lab seeds. Do not copy these files into standalone RedStrike.

Engine for Plan 01 / CADRE assessment: **`CADRE/tools/red-strike/`** (integrated pin) — run **only** that copy. Upstream features land in sister **`RedStrike\`** and are copied into the pin as needed.