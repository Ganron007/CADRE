#!/usr/bin/env python3
"""Fail if campaign-graph.yaml script paths or staged payloads are missing under 04-automation/linux."""
from __future__ import annotations

import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None

ROOT = Path(__file__).resolve().parents[3]
GRAPH = Path(__file__).resolve().parent / "campaign-graph.yaml"
LINUX = ROOT / "attack-matrix" / "04-automation" / "linux"

STAGE_RES = (
    re.compile(r"campaign_stage_run_ps1\s+\S+\s+\S+\s+(\S+\.(?:ps1|py))"),
    re.compile(r"campaign_stage_file\s+(\S+\.(?:ps1|py))"),
    re.compile(r"campaign_vagrant_run_ps1\s+(\S+\.(?:ps1|py))"),
)


def load_nodes() -> list[dict]:
    text = GRAPH.read_text(encoding="utf-8")
    if yaml is not None:
        data = yaml.safe_load(text)
        return list(data.get("nodes") or [])
    nodes: list[dict] = []
    current: dict | None = None
    for raw in text.splitlines():
        line = raw.rstrip()
        if line.startswith("  - id:"):
            if current:
                nodes.append(current)
            current = {"id": line.split(":", 1)[1].strip()}
        elif current is not None and line.startswith("    script:"):
            current["script"] = line.split(":", 1)[1].strip().strip('"').strip("'")
        elif current is not None and line.strip() == "stub: true":
            current["stub"] = True
    if current:
        nodes.append(current)
    return nodes


def staged_payload_path(name: str) -> Path:
    name = name.strip().strip("'\"")
    if "/" in name or "\\" in name:
        return LINUX / name.replace("\\", "/")
    return LINUX / "windows" / name


def check_staged_payloads() -> list[str]:
    missing: list[str] = []
    for sh in LINUX.rglob("*.sh"):
        text = sh.read_text(encoding="utf-8", errors="replace")
        names: set[str] = set()
        for rx in STAGE_RES:
            names.update(rx.findall(text))
        for name in names:
            path = staged_payload_path(name)
            if not path.is_file():
                missing.append(f"{sh.relative_to(LINUX)} -> {name}")
    return missing


def main() -> int:
    missing: list[str] = []
    empty: list[str] = []
    for node in load_nodes():
        nid = node.get("id", "?")
        script = node.get("script")
        if script is None:
            continue
        script = str(script).strip()
        if not script:
            empty.append(nid)
            continue
        path = LINUX / script
        if not path.is_file():
            missing.append(f"{nid}: {script}")
    staged_missing = check_staged_payloads()
    if empty or missing or staged_missing:
        if empty:
            print("empty script: (every graph node must point at 04-automation/linux/):")
            for nid in empty:
                print(f"  {nid}")
        if missing:
            print("missing graph files:")
            for row in missing:
                print(f"  {row}")
        if staged_missing:
            print("missing staged payloads:")
            for row in staged_missing:
                print(f"  {row}")
        return 1
    print(f"OK: {len(load_nodes())} graph nodes; all script: and staged payloads exist under {LINUX}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
