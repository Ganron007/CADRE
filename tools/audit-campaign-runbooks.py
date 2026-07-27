#!/usr/bin/env python3
"""Audit runbook coverage vs CAMPAIGNS_v2.md — report gaps and stale line ranges."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
V2 = ROOT / "attack-matrix" / "Campaign" / "CAMPAIGNS_v2.md"
RUNBOOKS = ROOT / "attack-matrix" / "Campaign" / "Runbooks"
SPLIT = ROOT / "tools" / "split-campaign-runbooks.py"

HEADING_RE = re.compile(r"^(#{2,4})\s+(.+)$")


def find_headings(lines: list[str]) -> list[tuple[int, str, str]]:
    out = []
    for i, line in enumerate(lines, 1):
        m = HEADING_RE.match(line.rstrip())
        if m:
            out.append((i, m.group(1), m.group(2).strip()))
    return out


def normalize(s: str) -> str:
    s = re.sub(r"\s+", " ", s.strip().lower())
    return s


def main() -> None:
    text = V2.read_text(encoding="utf-8")
    lines = text.splitlines(keepends=True)
    plain = [ln.rstrip("\n") for ln in lines]

    print(f"CAMPAIGNS_v2.md: {len(lines)} lines\n")
    print("=== Section headings (## / ### / ####) ===")
    for ln, level, title in find_headings(lines):
        if level in ("##", "###"):
            print(f"  L{ln:4d} {level} {title}")

    # Expected anchors from v2
    anchors = {normalize(t): ln for ln, _, t in find_headings(lines) if _ == "##" or _ == "###"}
    
    # Import sections from split script (parse start/end manually)
    import importlib.util
    spec = importlib.util.spec_from_file_location("split", SPLIT)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    sections = mod.SECTIONS

    print("\n=== Split script range check ===")
    issues = []
    for sec in sections:
        start, end = sec["start"], sec["end"]
        if start > len(lines) or end > len(lines):
            issues.append(f"{sec['file']}: end={end} exceeds file length {len(lines)}")
            continue
        first = plain[start - 1].strip()[:80]
        last = plain[end - 1].strip()[:80]
        print(f"  {sec['file']}: L{start}-{end} | start: {first!r}")
        if sec.get("study_start"):
            ss, se = sec["study_start"], sec["study_end"]
            if se > len(lines):
                issues.append(f"{sec['file']}: study_end={se} exceeds file length")
            else:
                print(f"    study L{ss}-{se}: {plain[ss-1].strip()[:60]!r}")

    # Coverage: which v2 body lines are assigned to any runbook range?
    covered = set()
    for sec in sections:
        for i in range(sec["start"], min(sec["end"], len(lines)) + 1):
            covered.add(i)
        if sec.get("study_start"):
            for i in range(sec["study_start"], min(sec["study_end"], len(lines)) + 1):
                covered.add(i)

    # Index covers 44-127 and 2930-2954 in old script - check
    index_ranges = [(44, 127), (2930, 2954)]
    for a, b in index_ranges:
        for i in range(a, min(b, len(lines)) + 1):
            covered.add(i)

    # Content lines (exclude header/how-to 1-22, topology in index 23-127)
    content_start = 107  # Phase 0
    content_end = len(lines)
    missing = []
    for i in range(content_start, content_end + 1):
        if i not in covered and plain[i - 1].strip():
            missing.append(i)

    print(f"\n=== Uncovered non-empty lines in campaign body (L{content_start}+) ===")
    if not missing:
        print("  (none)")
    else:
        # group contiguous
        groups = []
        start = missing[0]
        prev = missing[0]
        for ln in missing[1:]:
            if ln == prev + 1:
                prev = ln
            else:
                groups.append((start, prev))
                start = prev = ln
        groups.append((start, prev))
        for a, b in groups[:30]:
            snippet = plain[a - 1][:70] if a == b else f"{plain[a-1][:50]} ... {plain[b-1][:50]}"
            print(f"  L{a}" + (f"-{b}" if b != a else "") + f": {snippet!r}")
        if len(groups) > 30:
            print(f"  ... {len(groups) - 30} more gap groups, {len(missing)} lines total")

    if issues:
        print("\n=== ERRORS ===")
        for x in issues:
            print(f"  {x}")

    # Compare runbook-0 first heading to v2 phase 0
    rb0 = (RUNBOOKS / "CAMPAIGNS-RUNBOOK-0.md").read_text(encoding="utf-8")
    v2_phase0 = "".join(lines[106:439])  # 107-439 expected
    # strip runbook header from rb0
    rb_body = rb0.split("---\n", 1)[-1].split("## Navigation")[0].strip()
    v2_norm = normalize(re.sub(r"^>.*$", "", v2_phase0, flags=re.MULTILINE))
    rb_norm = normalize(re.sub(r"^#.*$", "", rb_body, flags=re.MULTILINE))
    if v2_norm[:500] != rb_norm[:500]:
        print("\n=== Phase 0 content drift (first 500 chars normalized differ) ===")
        print("  v2 starts:", repr(v2_norm[:120]))
        print("  rb starts:", repr(rb_norm[:120]))


if __name__ == "__main__":
    main()
