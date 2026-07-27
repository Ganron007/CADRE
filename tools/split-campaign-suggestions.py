#!/usr/bin/env python3
"""Split Campaign_suggestions.md into index + detail (preview-friendly)."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CAMPAIGN = ROOT / "attack-matrix" / "Campaign"
MAIN = CAMPAIGN / "Campaign_suggestions.md"
DETAIL = CAMPAIGN / "Campaign_suggestions-detail.md"
SPLIT_AT = "## Tier 1 — Directly Maps to Our Attack Surface"


def main() -> None:
    text = MAIN.read_text(encoding="utf-8")
    if DETAIL.exists() and "## Tier 1" in text[:5000]:
        print(f"skip: already split ({DETAIL.name} exists, index still has Tier 1 body)")
        return
    if DETAIL.exists():
        # index-only file; detail already on disk
        print(f"skip: {DETAIL.name} exists")
        return
    idx = text.find(SPLIT_AT)
    if idx < 0:
        raise SystemExit(f"split marker not found: {SPLIT_AT!r}")
    head = text[:idx].rstrip()
    tail = text[idx:].lstrip()
    head += """

---

## Full item write-ups (separate file)

Per-item sources, test plans, and integration notes are in **[Campaign_suggestions-detail.md](Campaign_suggestions-detail.md)** (~3.9k lines). Keep this index open for the summary table; open the detail file when researching a specific item.
"""
    detail_header = (
        "# Campaign Suggestions — Detail Write-ups\n\n"
        "**Index (summary table):** [Campaign_suggestions.md](Campaign_suggestions.md)\n\n"
        "---\n\n"
    )
    tail = tail.replace("Episode 173_*.txt", "Episode 173 (wildcard).txt")
    MAIN.write_text(head + "\n", encoding="utf-8", newline="\n")
    DETAIL.write_text(detail_header + tail, encoding="utf-8", newline="\n")
    print(f"wrote {MAIN.name} ({len(head)} chars)")
    print(f"wrote {DETAIL.name} ({len(detail_header + tail)} chars)")


if __name__ == "__main__":
    main()
