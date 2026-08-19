# Campaign automation (CADRE glue)

CADRE-owned assets for Plan 1.1. **Not** part of standalone RedStrike product identity — see `red-strike-product.md` (local maintainers).

| File | Role |
|------|------|
| `campaign-graph.yaml` | Spine + branches A/B/C/D/G/sql-ai (v3) |
| `lab-seed-creds.json` | Lab credential seed (never commit real prod secrets) |
| `lab-profiles.yaml` | Machine-readable LAB-PROFILES preflight |

This directory is the **only** home for CADRE missions, graph, and lab seeds. Do not copy these files into standalone RedStrike.

Engine for Plan 01 / CADRE assessment: **`CADRE/tools/red-strike/`** (integrated pin) — run **only** that copy. Upstream features land in sister **`RedStrike\`** and are copied into the pin as needed.