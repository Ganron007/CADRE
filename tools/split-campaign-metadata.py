#!/usr/bin/env python3
"""Split CAMPAIGNS-METADATA.md into index + mechanics (preview-friendly)."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CAMPAIGN = ROOT / "attack-matrix" / "Campaign"
MAIN = CAMPAIGN / "CAMPAIGNS-METADATA.md"
MECH = CAMPAIGN / "CAMPAIGNS-METADATA-mechanics.md"
SPLIT_AT = "## Mechanics: Phase 0 Step 0.5 — NetExec Quick-Recon"


def main() -> None:
    text = MAIN.read_text(encoding="utf-8")
    if MECH.exists():
        print(f"skip: {MECH.name} already exists")
        return
    idx = text.find(SPLIT_AT)
    if idx < 0:
        raise SystemExit(f"split marker not found: {SPLIT_AT!r}")
    head = text[:idx].rstrip()
    tail = text[idx:].lstrip()
    head += """

---

## Mechanics & deep reference (separate file)

Command-level steps, NetExec modules, ADeleg workflow, telemetry fingerprints, and study references are in **[CAMPAIGNS-METADATA-mechanics.md](CAMPAIGNS-METADATA-mechanics.md)** (~4.4k lines). Use that file when you need full attack commands; keep this index open for per-attack lookup tables.
"""
    mech_header = (
        "# CAMPAIGNS-METADATA — Mechanics & Deep Reference\n\n"
        "**Index (attack tables):** [CAMPAIGNS-METADATA.md](CAMPAIGNS-METADATA.md)\n\n"
        "---\n\n"
    )
    MAIN.write_text(head + "\n", encoding="utf-8", newline="\n")
    MECH.write_text(mech_header + tail, encoding="utf-8", newline="\n")
    print(f"wrote {MAIN.name} ({len(head)} chars)")
    print(f"wrote {MECH.name} ({len(mech_header + tail)} chars)")


if __name__ == "__main__":
    main()
