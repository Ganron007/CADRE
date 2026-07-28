#!/usr/bin/env python3
"""Split CAMPAIGNS_v3.md into full-content per-phase runbooks and refresh index hub.

Section boundaries are derived from markdown headings — re-run after editing CAMPAIGNS_v3.md.
Going forward: edit runbook + CAMPAIGNS_v3.md together, then run this to verify sync.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CAMPAIGN = ROOT / "attack-matrix" / "Campaign"
SRC = CAMPAIGN / "CAMPAIGNS_v3.md"
RUNBOOKS = CAMPAIGN / "Runbooks"

HEADING_RE = re.compile(r"^(#{2,4})\s+(.+)$")

COPY_PASTE_RE = re.compile(
    r"^> \*\*Copy-paste commands.*\n(?:> .*\n)*",
    re.MULTILINE,
)
RUNBOOK_ONLY_RE = re.compile(
    r"^> \*\*Copy-paste commands \(Phase 3\.5\):.*\n(?:> .*\n)*",
    re.MULTILINE,
)
EXERCISES_CALLOUT_RE = re.compile(
    r"^> \*\*Copy-paste / scripts:\*\*.*\n",
    re.MULTILINE,
)

# (filename, title, start, end_before, study_pat, study_end_before, prev, next)
SECTION_SPECS: list[tuple] = [
    (
        "CAMPAIGNS-RUNBOOK-0.md",
        "Phase 0 — Reconnaissance",
        r"^## Phase 0 ",
        r"^## Main Spine",
        None,
        None,
        None,
        "CAMPAIGNS-RUNBOOK-1.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-1.md",
        "Phase 1 — Initial Access (AS-REP Roast)",
        r"^## Main Spine",
        r"^### Phase 2 ",
        None,
        None,
        "CAMPAIGNS-RUNBOOK-0.md",
        "CAMPAIGNS-RUNBOOK-2.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-2.md",
        "Phase 2 — Credential Harvesting (Kerberoast)",
        r"^### Phase 2 ",
        r"^### Phase 3 — Execution",
        None,
        None,
        "CAMPAIGNS-RUNBOOK-1.md",
        "CAMPAIGNS-RUNBOOK-3.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-3.md",
        "Phase 3 — Execution (SQL xp_cmdshell + alternatives)",
        r"^### Phase 3 — Execution",
        r"^### Branch 3\.5 ",
        None,
        None,
        "CAMPAIGNS-RUNBOOK-2.md",
        "CAMPAIGNS-RUNBOOK-3.5.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-3.5.md",
        "Branch 3.5 — Credential Theft from SYSTEM",
        r"^### Branch 3\.5 ",
        r"^### Phase 4 ",
        r"^### Phase 3\.5 — Credential Access \(read BEFORE",
        None,
        "CAMPAIGNS-RUNBOOK-3.md",
        "CAMPAIGNS-RUNBOOK-4.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-4.md",
        "Phase 4 — Discovery (BloodHound)",
        r"^### Phase 4 — Discovery",
        r"^### Phase 5 ",
        r"^### Phase 4 — Discovery \(read BEFORE",
        None,
        "CAMPAIGNS-RUNBOOK-3.5.md",
        "CAMPAIGNS-RUNBOOK-5.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-5.md",
        "Phase 5 — Lateral Movement (Coercion + Delegation)",
        r"^### Phase 5 ",
        r"^### Phase 6 ",
        None,
        None,
        "CAMPAIGNS-RUNBOOK-4.md",
        "CAMPAIGNS-RUNBOOK-6.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-6.md",
        "Phase 6 — Privilege Escalation (DCSync)",
        r"^### Phase 6 ",
        r"^### Phase 7 — Forest Trust",
        r"^### Phase 7 — DCSync \(read BEFORE",
        None,
        "CAMPAIGNS-RUNBOOK-5.md",
        "CAMPAIGNS-RUNBOOK-7.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-7.md",
        "Phase 7 — Forest Trust Escalation (SID History)",
        r"^### Phase 7 — Forest Trust",
        r"^### Phase 8 ",
        None,
        None,
        "CAMPAIGNS-RUNBOOK-6.md",
        "CAMPAIGNS-RUNBOOK-8.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-8.md",
        "Phase 8 — Cross-Forest + External Domain",
        r"^### Phase 8 ",
        r"^## Branches ",
        r"^### Phase 8 — Forest Trust \(read BEFORE",
        r"^## Coverage Summary",
        "CAMPAIGNS-RUNBOOK-7.md",
        "CAMPAIGNS-RUNBOOK-branch-a.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-branch-a.md",
        "Branch A — ACL Abuse (cadre.local)",
        r"^### Branch A:",
        r"^### Branch B:",
        None,
        None,
        "CAMPAIGNS-RUNBOOK-8.md",
        "CAMPAIGNS-RUNBOOK-branch-b.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-branch-b.md",
        "Branch B — ADCS (Certificate Services)",
        r"^### Branch B:",
        r"^### Branch C:",
        None,
        None,
        "CAMPAIGNS-RUNBOOK-branch-a.md",
        "CAMPAIGNS-RUNBOOK-branch-c.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-branch-c.md",
        "Branch C — SCCM Escalation (range.local)",
        r"^### Branch C:",
        r"^### Branch D:",
        None,
        None,
        "CAMPAIGNS-RUNBOOK-branch-b.md",
        "CAMPAIGNS-RUNBOOK-branch-d.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-branch-d.md",
        "Branch D — Linux Pivot",
        r"^### Branch D:",
        r"^## 📖 Study Reference Library",
        None,
        None,
        "CAMPAIGNS-RUNBOOK-branch-c.md",
        "CAMPAIGNS-RUNBOOK-e.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-e.md",
        "E — Network Defense Exercises (14)",
        r"^### E — Network Defense",
        r"^### F — Supply-Chain",
        None,
        None,
        "CAMPAIGNS-RUNBOOK-branch-d.md",
        "CAMPAIGNS-RUNBOOK-f.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-f.md",
        "F — Supply-Chain Simulation (10 scenarios)",
        r"^### F — Supply-Chain",
        r"^### G — Pre-Auth",
        None,
        None,
        "CAMPAIGNS-RUNBOOK-e.md",
        "CAMPAIGNS-RUNBOOK-exercises-g.md",
    ),
    (
        "CAMPAIGNS-RUNBOOK-exercises-g.md",
        "G — Pre-Auth DC Exploits (Standalone)",
        r"^### G — Pre-Auth",
        None,
        None,
        None,
        "CAMPAIGNS-RUNBOOK-f.md",
        None,
    ),
]


def find_line(lines: list[str], pattern: str, start: int = 1) -> int:
    rx = re.compile(pattern)
    for i in range(start - 1, len(lines)):
        if rx.match(lines[i].rstrip("\n")):
            return i + 1
    raise ValueError(f"Heading not found: {pattern!r} (from line {start})")


def find_study_block(
    lines: list[str],
    phase_pattern: str,
    end_before: str | None = None,
) -> tuple[int, int]:
    """Return inclusive line range for one study-ref subsection."""
    start = find_line(lines, phase_pattern)
    if end_before:
        end = find_line(lines, end_before, start + 1) - 1
        return start, end
    end = len(lines)
    for i in range(start, len(lines)):
        line = lines[i].rstrip("\n")
        if i + 1 <= start:
            continue
        m = HEADING_RE.match(line)
        if not m:
            continue
        lvl, title = m.groups()
        if lvl == "##":
            end = i
            break
        if lvl == "###" and "read BEFORE" in title and i + 1 > start:
            end = i
            break
        if lvl == "###" and title.startswith("How to use this section"):
            end = i
            break
    return start, end


def slice_lines(lines: list[str], start: int, end: int) -> str:
    return "".join(lines[start - 1 : end])


def transform_body(text: str) -> str:
    text = COPY_PASTE_RE.sub("", text)
    text = RUNBOOK_ONLY_RE.sub("", text)
    text = EXERCISES_CALLOUT_RE.sub("", text)
    return text.strip() + "\n"


def nav(prev: str | None, nxt: str | None) -> str:
    parts = []
    if prev:
        parts.append(f"← Previous: [`{prev}`]({prev})")
    if nxt:
        parts.append(f"Next: [`{nxt}`]({nxt}) →")
    return " · ".join(parts) if parts else ""


def runbook_header(title: str) -> str:
    return f"""# CAMPAIGNS v3 — {title}

> **Campaign v3** — read the theory here, run each command block live, then update [`CAMPAIGNS-METADATA.md`](../CAMPAIGNS-METADATA.md).
> **Index:** [`CAMPAIGNS-RUNBOOK-README.md`](CAMPAIGNS-RUNBOOK-README.md) · **Full reference:** [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) · **Topology:** [`CAMPAIGNS.md`](../CAMPAIGNS.md)
> **DFIR track:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)
>
> **Sync rule:** When you change this runbook during lab work, apply the same edit to [`CAMPAIGNS_v3.md`](../CAMPAIGNS_v3.md) (matching section). Re-run `python tools/split-campaign-runbooks.py --check` to verify coverage.

**Default host:** Kali / provisioning (`192.168.77.60`) unless a step says otherwise.

---
"""


def study_preamble(lines: list[str]) -> str:
    lib = find_line(lines, r"^## 📖 Study Reference Library")
    first_phase = find_line(lines, r"^### Phase 3\.5 — Credential Access \(read BEFORE")
    if first_phase > lib + 1:
        return slice_lines(lines, lib, first_phase - 1)
    return ""


def build_runbook(
    spec: tuple,
    lines: list[str],
    study_preamble_text: str,
    include_study_preamble: bool,
) -> str:
    file, title, start_pat, end_pat, study_pat, study_end_pat, prev, nxt = spec
    start = find_line(lines, start_pat)
    if end_pat:
        end = find_line(lines, end_pat, start + 1) - 1
    else:
        end = len(lines)

    body = slice_lines(lines, start, end)

    if file == "CAMPAIGNS-RUNBOOK-branch-a.md":
        branches_hdr = find_line(lines, r"^## Branches ")
        branch_a = find_line(lines, r"^### Branch A:")
        body = slice_lines(lines, branches_hdr, branch_a - 1) + "\n" + body

    if file == "CAMPAIGNS-RUNBOOK-e.md":
        ex_hdr = find_line(lines, r"^## Exercises \(Standalone\)")
        e_start = find_line(lines, r"^### E — Network Defense")
        body = slice_lines(lines, ex_hdr, e_start - 1) + "\n" + body

    if study_pat:
        study_start, study_end = find_study_block(lines, study_pat, study_end_pat)
        body += "\n\n---\n\n## Study references (read before this phase)\n\n"
        if include_study_preamble and study_preamble_text:
            body += study_preamble_text + "\n"
        body += slice_lines(lines, study_start, study_end)

    body = transform_body(body)
    footer = f"\n---\n\n## Navigation\n\n{nav(prev, nxt)}\n"
    return runbook_header(title) + "\n" + body + footer


def build_index(lines: list[str]) -> str:
    topo_start = find_line(lines, r"^## Lab Topology")
    phase0 = find_line(lines, r"^## Phase 0 ")
    topology = slice_lines(lines, topo_start, phase0 - 1)

    cov_start = find_line(lines, r"^## Coverage Summary")
    cov_end = find_line(lines, r"^## Exercises \(Standalone\)", cov_start + 1) - 1
    coverage = slice_lines(lines, cov_start, cov_end)

    index_table = """## Phase runbooks (v3 — read + execute)

Open **one runbook per phase**. Each file contains the full explanation, prerequisites, detection notes, and commands from the campaign — sized for learning and live testing.

| Phase / stream | Runbook | Notes |
|----------------|---------|-------|
| **0** Recon | [`Runbooks/CAMPAIGNS-RUNBOOK-0.md`](Runbooks/CAMPAIGNS-RUNBOOK-0.md) | Zero creds |
| **1** Initial access | [`Runbooks/CAMPAIGNS-RUNBOOK-1.md`](Runbooks/CAMPAIGNS-RUNBOOK-1.md) | AS-REP verified |
| **2** Cred harvest | [`Runbooks/CAMPAIGNS-RUNBOOK-2.md`](Runbooks/CAMPAIGNS-RUNBOOK-2.md) | Kerberoast verified |
| **3** Execution | [`Runbooks/CAMPAIGNS-RUNBOOK-3.md`](Runbooks/CAMPAIGNS-RUNBOOK-3.md) | SQL → GodPotato verified |
| **3.5** Cred theft | [`Runbooks/CAMPAIGNS-RUNBOOK-3.5.md`](Runbooks/CAMPAIGNS-RUNBOOK-3.5.md) | + study refs |
| **4** Discovery | [`Runbooks/CAMPAIGNS-RUNBOOK-4.md`](Runbooks/CAMPAIGNS-RUNBOOK-4.md) | BloodHound |
| **5** Lateral | [`Runbooks/CAMPAIGNS-RUNBOOK-5.md`](Runbooks/CAMPAIGNS-RUNBOOK-5.md) | Coercion |
| **6** DCSync | [`Runbooks/CAMPAIGNS-RUNBOOK-6.md`](Runbooks/CAMPAIGNS-RUNBOOK-6.md) | + study refs |
| **7** Forest trust | [`Runbooks/CAMPAIGNS-RUNBOOK-7.md`](Runbooks/CAMPAIGNS-RUNBOOK-7.md) | SID History |
| **8** Cross-forest | [`Runbooks/CAMPAIGNS-RUNBOOK-8.md`](Runbooks/CAMPAIGNS-RUNBOOK-8.md) | + study refs |
| **A–D** Branches | [`Runbooks/CAMPAIGNS-RUNBOOK-branch-a.md`](Runbooks/CAMPAIGNS-RUNBOOK-branch-a.md) … [`branch-d`](Runbooks/CAMPAIGNS-RUNBOOK-branch-d.md) | Optional |
| **E / F / G** | [`e`](Runbooks/CAMPAIGNS-RUNBOOK-e.md) · [`f`](Runbooks/CAMPAIGNS-RUNBOOK-f.md) · [`g`](Runbooks/CAMPAIGNS-RUNBOOK-exercises-g.md) | Standalone |

**Full monolithic reference (search / print):** [`CAMPAIGNS_v2.md`](CAMPAIGNS_v2.md) · **Archived v1:** [`CAMPAIGNS_v1_archived.md`](CAMPAIGNS_v1_archived.md)

**Per-attack metadata:** [`CAMPAIGNS-METADATA.md`](CAMPAIGNS-METADATA.md) · **DFIR bridge:** [`DFIR-Nexus-Pioneer-workflow.md`](DFIR-Nexus-Pioneer-workflow.md)

**Editing:** Update the runbook and `CAMPAIGNS_v2.md` together. Run `python tools/split-campaign-runbooks.py --check` after bulk regen.

---
"""
    header = """# CADRE — Attack Campaign (v3)

> **v3 is current.** Per-phase runbooks below are the primary path — full narrative + commands for learning and live testing.
> **Archived v1:** [`CAMPAIGNS_v1_archived.md`](CAMPAIGNS_v1_archived.md) · **Full v3 reference:** [`CAMPAIGNS_v3.md`](CAMPAIGNS_v3.md)

**81 campaign attacks + 14 E exercises + 10 F supply-chain scenarios = 105 total.**

"""
    return header + index_table + topology + "\n---\n\n" + coverage + "\n"


def build_readme() -> str:
    return """# CAMPAIGNS v2 — Runbook Index

> **Purpose:** One runbook per phase — **full narrative + commands** for learning and live testing.
> **Campaign index:** [`CAMPAIGNS.md`](../CAMPAIGNS.md) (topology, coverage) · **Full reference:** [`CAMPAIGNS_v2.md`](../CAMPAIGNS_v2.md)
> **Per-attack metadata:** [`CAMPAIGNS-METADATA.md`](../CAMPAIGNS-METADATA.md) · **DFIR:** [`DFIR-Nexus-Pioneer-workflow.md`](../DFIR-Nexus-Pioneer-workflow.md)

**Default host:** Kali / provisioning (`192.168.77.60`) unless a runbook says otherwise.

---

## Main spine (open in order)

| Phase | Runbook | Status |
|-------|---------|--------|
| **0** | [`CAMPAIGNS-RUNBOOK-0.md`](CAMPAIGNS-RUNBOOK-0.md) | ⏳ / partial verified |
| **1** | [`CAMPAIGNS-RUNBOOK-1.md`](CAMPAIGNS-RUNBOOK-1.md) | ✅ AS-REP verified |
| **2** | [`CAMPAIGNS-RUNBOOK-2.md`](CAMPAIGNS-RUNBOOK-2.md) | ✅ Kerberoast verified |
| **3** | [`CAMPAIGNS-RUNBOOK-3.md`](CAMPAIGNS-RUNBOOK-3.md) | ✅ SQL → GodPotato verified |
| **3.5** | [`CAMPAIGNS-RUNBOOK-3.5.md`](CAMPAIGNS-RUNBOOK-3.5.md) | 🔨 Active |
| **4** | [`CAMPAIGNS-RUNBOOK-4.md`](CAMPAIGNS-RUNBOOK-4.md) | ⏳ |
| **5** | [`CAMPAIGNS-RUNBOOK-5.md`](CAMPAIGNS-RUNBOOK-5.md) | ⏳ |
| **6** | [`CAMPAIGNS-RUNBOOK-6.md`](CAMPAIGNS-RUNBOOK-6.md) | ⏳ |
| **7** | [`CAMPAIGNS-RUNBOOK-7.md`](CAMPAIGNS-RUNBOOK-7.md) | ⏳ |
| **8** | [`CAMPAIGNS-RUNBOOK-8.md`](CAMPAIGNS-RUNBOOK-8.md) | ⏳ |

## Optional branches

| Branch | Runbook | When |
|--------|---------|------|
| **A** ACL abuse | [`CAMPAIGNS-RUNBOOK-branch-a.md`](CAMPAIGNS-RUNBOOK-branch-a.md) | After Phase 4 BH reveals ACEs |
| **B** ADCS | [`CAMPAIGNS-RUNBOOK-branch-b.md`](CAMPAIGNS-RUNBOOK-branch-b.md) | After Phase 4 / ADeleg ADCS scan |
| **C** SCCM | [`CAMPAIGNS-RUNBOOK-branch-c.md`](CAMPAIGNS-RUNBOOK-branch-c.md) | After Phase 8 cross-forest access |
| **D** Linux pivot | [`CAMPAIGNS-RUNBOOK-branch-d.md`](CAMPAIGNS-RUNBOOK-branch-d.md) | After Phase 3 SQL linked-server recon |

## Standalone exercises

| Stream | Runbook | Scripts |
|--------|---------|---------|
| **E** Network defense (14) | [`CAMPAIGNS-RUNBOOK-e.md`](CAMPAIGNS-RUNBOOK-e.md) | `../../04-automation/campaign-e/wt069-*.sh` |
| **F** Supply chain (10) | [`CAMPAIGNS-RUNBOOK-f.md`](CAMPAIGNS-RUNBOOK-f.md) | `../../../docs/internal/npm-supplychain-installation-guide.md` |
| **G** Pre-auth DC CVE lab | [`CAMPAIGNS-RUNBOOK-exercises-g.md`](CAMPAIGNS-RUNBOOK-exercises-g.md) | Snapshot required |

---

## Format rules (when editing)

1. **Edit runbook + `CAMPAIGNS_v2.md` together** — same section in both files; runbooks are primary for lab work.
2. **Keep explanations** — theory, tables, detection notes, and prerequisites stay in the runbook.
3. **One command per fenced block** where practical — comments above the block, not inside.
4. **Study references** for phases 3.5, 4, 6, 8 are appended at the end of those runbooks (from v2 Study Reference Library).
5. **Verify coverage:** `python tools/split-campaign-runbooks.py --check`
"""


def resolve_sections(lines: list[str]) -> list[dict]:
    out = []
    for spec in SECTION_SPECS:
        file, title, start_pat, end_pat, study_pat, study_end_pat, prev, nxt = spec
        start = find_line(lines, start_pat)
        if end_pat:
            end = find_line(lines, end_pat, start + 1) - 1
        else:
            end = len(lines)
        entry = {
            "file": file,
            "title": title,
            "start": start,
            "end": end,
            "prev": prev,
            "next": nxt,
        }
        if file == "CAMPAIGNS-RUNBOOK-branch-a.md":
            entry["extra_start"] = find_line(lines, r"^## Branches ")
            entry["extra_end"] = start - 1
        if file == "CAMPAIGNS-RUNBOOK-e.md":
            entry["extra_start"] = find_line(lines, r"^## Exercises \(Standalone\)")
            entry["extra_end"] = start - 1
        if study_pat:
            ss, se = find_study_block(lines, study_pat, study_end_pat)
            entry["study_start"] = ss
            entry["study_end"] = se
            if file == "CAMPAIGNS-RUNBOOK-3.5.md":
                lib = find_line(lines, r"^## 📖 Study Reference Library")
                entry["study_lib_start"] = lib
                entry["study_lib_end"] = ss - 1
        out.append(entry)
    return out


def audit_coverage(lines: list[str], sections: list[dict]) -> list[str]:
    """Return list of gap descriptions."""
    covered: set[int] = set()
    for sec in sections:
        for i in range(sec["start"], sec["end"] + 1):
            covered.add(i)
        if sec.get("extra_start"):
            for i in range(sec["extra_start"], sec["extra_end"] + 1):
                covered.add(i)
        if sec.get("study_start"):
            for i in range(sec["study_start"], sec["study_end"] + 1):
                covered.add(i)
        if sec.get("study_lib_start"):
            for i in range(sec["study_lib_start"], sec["study_lib_end"] + 1):
                covered.add(i)

    topo_start = find_line(lines, r"^## Lab Topology")
    phase0 = find_line(lines, r"^## Phase 0 ")
    for i in range(topo_start, phase0):
        covered.add(i)

    cov_start = find_line(lines, r"^## Coverage Summary")
    cov_end = find_line(lines, r"^## Exercises \(Standalone\)", cov_start + 1) - 1
    for i in range(cov_start, cov_end + 1):
        covered.add(i)

    # Header / how-to (lines 1 through topology) — index metadata, OK to skip
    howto_end = find_line(lines, r"^## Lab Topology") - 1
    for i in range(1, howto_end + 1):
        covered.add(i)

    gaps = []
    plain = [ln.rstrip("\n") for ln in lines]
    run_start = find_line(lines, r"^## Phase 0 ")
    for i in range(run_start, len(lines) + 1):
        if i not in covered and plain[i - 1].strip() and not plain[i - 1].strip() == "---":
            gaps.append(i)

    if not gaps:
        return []

    groups = []
    start = gaps[0]
    prev = gaps[0]
    for ln in gaps[1:]:
        if ln == prev + 1:
            prev = ln
        else:
            groups.append((start, prev))
            start = prev = ln
    groups.append((start, prev))

    msgs = []
    for a, b in groups:
        snippet = plain[a - 1][:60]
        msgs.append(f"L{a}" + (f"-{b}" if b != a else "") + f": {snippet!r}")
    return msgs


def main() -> None:
    check_only = "--check" in sys.argv
    if not SRC.exists():
        raise SystemExit(f"Missing {SRC}")

    lines = SRC.read_text(encoding="utf-8").splitlines(keepends=True)
    sections = resolve_sections(lines)
    gaps = audit_coverage(lines, sections)

    if check_only:
        print(f"CAMPAIGNS_v2.md: {len(lines)} lines")
        for sec in sections:
            extra = ""
            if sec.get("study_start"):
                extra = f" + study L{sec['study_start']}-{sec['study_end']}"
            print(f"  {sec['file']}: L{sec['start']}-{sec['end']}{extra}")
        if gaps:
            print(f"\nFAIL: {len(gaps)} uncovered line group(s):")
            for g in gaps:
                print(f"  {g}".encode("ascii", "replace").decode())
            raise SystemExit(1)
        print("\nOK: full campaign body covered by runbooks + index")
        return

    preamble = study_preamble(lines)
    for spec in SECTION_SPECS:
        path = RUNBOOKS / spec[0]
        include_preamble = spec[0] == "CAMPAIGNS-RUNBOOK-3.5.md"
        content = build_runbook(spec, lines, preamble, include_preamble)
        path.write_text(content, encoding="utf-8")
        sec = next(s for s in sections if s["file"] == spec[0])
        print(f"wrote {spec[0]} (L{sec['start']}-{sec['end']})")

    (CAMPAIGN / "CAMPAIGNS.md").write_text(build_index(lines), encoding="utf-8")
    print("wrote CAMPAIGNS.md (index)")

    (RUNBOOKS / "CAMPAIGNS-RUNBOOK-README.md").write_text(build_readme(), encoding="utf-8")
    print("wrote CAMPAIGNS-RUNBOOK-README.md")

    if gaps:
        print(f"\nWARNING: {len(gaps)} uncovered line group(s) after regen:")
        for g in gaps:
            print(f"  {g}")
        raise SystemExit(1)
    print("\nCoverage check: OK")


if __name__ == "__main__":
    main()
