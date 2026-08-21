#!/usr/bin/env python3
"""Retired 30-node spine check. Forwards to the 90-node full-graph validator."""
from __future__ import annotations

import runpy
import sys
from pathlib import Path

print(
    "WARN: dfir-spine-ready-check.py is retired. Using dfir-full-ready-check.py (90-node graph v9).",
    file=sys.stderr,
)
target = Path(__file__).with_name("dfir-full-ready-check.py")
if not target.is_file():
    print("DFIR_FULL_READY=NO")
    print(f"FAIL: missing {target}")
    sys.exit(1)
sys.argv[0] = str(target)
runpy.run_path(str(target), run_name="__main__")
