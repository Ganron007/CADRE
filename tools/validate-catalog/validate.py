#!/usr/bin/env python3
"""
CADRE Telemetry Catalog Validator.

Reads schema.yml and index-reference.yml, then validates every .yml file
in the catalog directory against them.

Usage:
    python tools/validate-catalog/validate.py
    python tools/validate-catalog/validate.py attack-matrix/06-telemetry-catalog/
    python tools/validate-catalog/validate.py --verbose

Exit code 0 = all valid. Non-zero = issues found.
"""

import os
import sys
import json
import re
from pathlib import Path
from collections import Counter

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML required. Install with: pip install pyyaml", file=sys.stderr)
    sys.exit(1)

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CATALOG_DIR = PROJECT_ROOT / "attack-matrix" / "06-telemetry-catalog"
SCHEMA_PATH = DEFAULT_CATALOG_DIR / "schema.yml"
INDEX_PATH = DEFAULT_CATALOG_DIR / "index-reference.yml"
WALKTHROUGH_DIR = PROJECT_ROOT / "attack-matrix" / "01-walkthroughs"


def load_yaml(path, label):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"  FAIL  Could not load {label}: {e}")
        sys.exit(1)


def load_index_ref():
    """Load index-reference.yml and build lookup sets."""
    data = load_yaml(INDEX_PATH, "index-reference.yml")
    indices = {}
    for entry in data.get("elastic_indices", []):
        indices[entry["pattern"]] = entry
    hunt_names = {h["name"] for h in data.get("velociraptor_hunts", [])}
    zeek_names = {z["name"] for z in data.get("zeek_logs", [])}
    rule_ids = {r["rule_id"] for r in data.get("detection_rules", [])}
    return indices, hunt_names, zeek_names, rule_ids


def validate_entry(entry, filepath, known_walkthroughs, indices, hunt_names, rule_ids, verbose):
    """Validate a single catalog entry YAML. Returns list of error strings."""
    errors = []

    # Required fields
    required = ["attack_id", "walkthrough", "mitre_technique", "campaign",
                 "tools", "difficulty", "certifications", "post_exploit_chain",
                 "telemetry", "detection_rules", "time_estimate"]
    for field in required:
        if field not in entry:
            errors.append(f"Missing required field: {field}")

    if errors:
        return errors

    aid = entry.get("attack_id", "")
    if not re.match(r"^(T\d{3}|ART-T\d)", aid):
        errors.append(f"attack_id '{aid}' does not match pattern T\\d{{3}} or ART- prefix")

    wt_path = entry.get("walkthrough", "")
    if wt_path:
        # Extract filename from repo-relative path
        wt_filename = Path(wt_path).name
        full_path = WALKTHROUGH_DIR / wt_filename
        if wt_filename not in known_walkthroughs:
            errors.append(f"walkthrough '{wt_path}' — file '{wt_filename}' not found in {WALKTHROUGH_DIR}")

    mitre = entry.get("mitre_technique", "")
    if not re.match(r"^T\d{4}(\.\d{3})?$", mitre):
        errors.append(f"mitre_technique '{mitre}' does not match pattern T####.###")

    campaign = entry.get("campaign", "")
    if campaign not in ("A", "B", "C", "D"):
        errors.append(f"campaign '{campaign}' must be A, B, C, or D")

    difficulty = entry.get("difficulty", "")
    if difficulty not in ("Easy", "Medium", "Hard"):
        errors.append(f"difficulty '{difficulty}' must be Easy, Medium, or Hard")

    # Validate telemetry.elastic indices
    for el_item in entry.get("telemetry", {}).get("elastic", []):
        idx = el_item.get("index", "")
        if idx and idx not in indices:
            errors.append(f"elastic.index '{idx}' not found in index-reference.yml")
        threshold = el_item.get("threshold")
        if threshold is not None and not isinstance(threshold, int):
            errors.append(f"elastic.threshold must be integer, got {type(threshold).__name__}")
        detection_rule = el_item.get("detection_rule")
        if detection_rule and detection_rule not in rule_ids:
            errors.append(f"elastic.detection_rule '{detection_rule}' not found in index-reference.yml detection_rules")

    # Validate velociraptor hunts
    for vr_item in entry.get("telemetry", {}).get("velociraptor", []):
        hunt_name = vr_item.get("hunt", "")
        if hunt_name and hunt_name not in hunt_names:
            errors.append(f"velociraptor.hunt '{hunt_name}' not found in index-reference.yml")

    # Validate detection_rules
    for dr_item in entry.get("detection_rules", []):
        rid = dr_item.get("rule_id")
        if rid and rid not in rule_ids:
            errors.append(f"detection_rules.rule_id '{rid}' not found in index-reference.yml")

    # Validate time_estimate
    te = entry.get("time_estimate", "")
    if not re.match(r"^\d+[smh]$", te):
        errors.append(f"time_estimate '{te}' must match pattern \\d+[smh] (e.g. 30s, 2m)")

    # Validate alternative_paths if present
    for alt in entry.get("alternative_paths", []):
        if "technique" not in alt:
            errors.append("alternative_paths entry missing required 'technique' field")

    return errors


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Validate CADRE telemetry catalog entries")
    parser.add_argument("catalog_dir", nargs="?", default=str(DEFAULT_CATALOG_DIR),
                        help="Path to catalog directory (default: %(default)s)")
    parser.add_argument("--verbose", "-v", action="store_true", help="Verbose output")
    args = parser.parse_args()

    catalog_dir = Path(args.catalog_dir).resolve()
    if not catalog_dir.exists():
        print(f"FAIL  Catalog directory not found: {catalog_dir}")
        sys.exit(1)

    print(f"CADRE Telemetry Catalog Validator")
    print(f"  Schema:      {SCHEMA_PATH}")
    print(f"  Index ref:   {INDEX_PATH}")
    print(f"  Catalog dir: {catalog_dir}")
    print(f"  Walkthroughs:{WALKTHROUGH_DIR}")
    print()

    # Load index reference
    indices, hunt_names, zeek_names, rule_ids = load_index_ref()
    print(f"  Loaded {len(indices)} elastic index patterns, {len(hunt_names)} VR hunts, {len(rule_ids)} seed rules")
    print()

    # Build known walkthrough file list
    known_walkthroughs = set()
    if WALKTHROUGH_DIR.exists():
        known_walkthroughs = {f.name for f in WALKTHROUGH_DIR.iterdir()
                             if f.name.startswith("WT") and f.suffix == ".md"}

    # Find all catalog yml files (not schema/index)
    catalog_files = sorted(
        f for f in catalog_dir.iterdir()
        if f.suffix in (".yml", ".yaml")
        and f.name not in ("schema.yml", "index-reference.yml")
    )

    if not catalog_files:
        print("  No catalog entries found (only schema.yml and index-reference.yml exist)")
        print("\nResult: NO ENTRIES TO VALIDATE")
        sys.exit(0)

    print(f"  Found {len(catalog_files)} catalog entry file(s):")
    for cf in catalog_files:
        print(f"    - {cf.name}")
    print()

    # Validate each entry
    all_errors = {}
    total_checks = 0
    valid_count = 0

    for filepath in catalog_files:
        entry = load_yaml(filepath, filepath.name)
        if entry is None:
            all_errors[filepath.name] = ["Empty YAML file"]
            continue

        errors = validate_entry(entry, filepath, known_walkthroughs,
                                indices, hunt_names, rule_ids, args.verbose)
        total_checks += 1
        if errors:
            all_errors[filepath.name] = errors
            if args.verbose:
                print(f"  FAIL  {filepath.name}")
                for e in errors:
                    print(f"         - {e}")
        else:
            valid_count += 1
            if args.verbose:
                print(f"  PASS  {filepath.name}")

    print()
    if all_errors:
        print(f"  {len(all_errors)}/{total_checks} file(s) FAILED validation:")
        for fname, errs in sorted(all_errors.items()):
            print(f"    {fname}:")
            for e in errs:
                print(f"      - {e}")
        print(f"\nResult: {valid_count}/{total_checks} VALID")
        sys.exit(1)
    else:
        print(f"Result: {valid_count}/{total_checks} VALID, 0 errors")
        sys.exit(0)


if __name__ == "__main__":
    main()
