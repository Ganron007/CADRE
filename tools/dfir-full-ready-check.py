#!/usr/bin/env python3
"""Fail-closed validator for a RedStrike DFIR *full* graph v9 dump (90 nodes)."""
from __future__ import annotations

import json
import sys
from pathlib import Path

REQUIRED_NODES = (
    "T028",
    "H-ASSUME",
    "T003",
    "T040",
    "T045",
    "T015",
    "T050",
    "T034",
    "T031",
    "H-01",
    "WT069",
    "F01",
    "T-SQL-AI",
)
FORBIDDEN_PREFIXES = ("DEMO-",)
EXPECTED_STUBS = {"T100", "T103", "T104", "T107", "T108", "T-SQL-AI", "WT093"}
EXPECTED_BRANCHES = {"spine", "A", "B", "C", "D", "E", "F", "G", "H", "sql-ai"}


def _fail(errors: list[str]) -> int:
    print("DFIR_FULL_READY=NO")
    for item in errors:
        print(f"FAIL: {item}")
    return 1


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("usage: dfir-full-ready-check.py <merged.json>", file=sys.stderr)
        return 2
    path = Path(argv[1])
    if not path.is_file():
        return _fail([f"missing JSON {path}"])
    data = json.loads(path.read_text(encoding="utf-8"))
    errors: list[str] = []
    warnings: list[str] = []

    graph = str(data.get("graph") or "")
    if "campaign-graph.yaml" not in graph.replace("\\", "/"):
        errors.append(f"graph is not CADRE campaign-graph.yaml: {graph}")
    if "campaign-graph.m1.yaml" in graph.replace("\\", "/"):
        errors.append("graph resolved to bundled demo campaign-graph.m1.yaml")
    if data.get("graph_name") != "cadre-campaign-m5":
        errors.append(f"graph_name={data.get('graph_name')!r} (want cadre-campaign-m5)")
    if data.get("operator") != "provisioning":
        errors.append(f"operator={data.get('operator')!r} (want provisioning)")

    steps = data.get("steps") or []
    ids = [str(s.get("node_id") or "") for s in steps]
    id_set = set(ids)
    n = int(data.get("node_count") or len(ids))
    if n != 90 or len(id_set) != 90:
        errors.append(f"node_count={n} unique={len(id_set)} (want 90 unique graph nodes)")
    for node in REQUIRED_NODES:
        if node not in id_set:
            errors.append(f"missing required node {node}")
    for nid in id_set:
        if nid.startswith(FORBIDDEN_PREFIXES):
            errors.append(f"demo node present {nid}")

    branches = set(data.get("branches") or [])
    missing_br = EXPECTED_BRANCHES - branches
    if missing_br:
        errors.append(f"missing branches {sorted(missing_br)}")

    mechs = {str(s.get("mechanism") or "") for s in steps}
    if "local-ws01" in mechs or int(data.get("local_ws01_count") or 0) != 0:
        errors.append("local-ws01 present — do not run the pin as native ws01 on the laptop")
    if "ws01-exec" not in mechs and int(data.get("ws01_exec_count") or 0) < 1:
        errors.append("no ws01-exec steps — Rule 1 hybrid path missing")
    if "direct-linux60" not in mechs and int(data.get("linux_direct_count") or 0) < 1:
        errors.append("no direct-linux60 steps — linux01 Branch D (T045-T048) missing")
    if "external60_phase0" not in mechs:
        errors.append("no external60_phase0 steps — Kali/provisioning origin missing (T028/H/T031/E/F)")

    preflight = data.get("preflight") or {}
    hosts = preflight.get("required_hosts") or []
    for host in ("ws01", "linux01", "elk", "monitor", "vr"):
        if hosts and host not in hosts:
            warnings.append(f"P-DFIR host {host} not in preflight.required_hosts")

    stubs = {
        s.get("node_id")
        for s in steps
        if s.get("stub") or (s.get("skipped") and "stub" in str(s.get("skip_reason") or ""))
    }
    extra_stubs = stubs - EXPECTED_STUBS
    missing_stubs = EXPECTED_STUBS - stubs
    if extra_stubs:
        warnings.append(f"unexpected stubs {sorted(x for x in extra_stubs if x)}")
    if missing_stubs:
        warnings.append(f"expected stubs not marked skipped {sorted(missing_stubs)}")

    if errors:
        for item in warnings:
            print(f"WARN: {item}")
        return _fail(errors)

    print("DFIR_FULL_READY=YES")
    print(f"graph={graph}")
    print(f"nodes={n} branches={sorted(branches)}")
    print(
        f"ws01_exec={data.get('ws01_exec_count')} linux60={data.get('linux_direct_count')} "
        f"stubs={len(stubs)}"
    )
    for item in warnings:
        print(f"WARN: {item}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
