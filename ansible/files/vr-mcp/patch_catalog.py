#!/usr/bin/env python3
"""Set defaults.artifact_definitions_directories on a Velociraptor server config."""
from __future__ import annotations

import sys

import yaml

path = sys.argv[1] if len(sys.argv) > 1 else "/etc/velociraptor/server.config.yaml"
dirs = ["/opt/cadre-hunts", "/opt/cadre-artifacts"]
with open(path, encoding="utf-8") as f:
    cfg = yaml.safe_load(f)
cfg.setdefault("defaults", {})
current = cfg["defaults"].get("artifact_definitions_directories") or []
if list(current) == dirs:
    print("OK")
    raise SystemExit(0)
cfg["defaults"]["artifact_definitions_directories"] = dirs
with open(path, "w", encoding="utf-8") as f:
    yaml.dump(cfg, f, default_flow_style=False)
print("CHANGED")
