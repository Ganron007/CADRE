#!/usr/bin/env python3
"""
Drift test — ensures config.json matches the deployed Ansible playbook roles.
Run: python tools/deploy-harness/test_config_sync.py
Exit code 0 = no drift. Non-zero = drift found.
"""
import sys
import json
sys.path.insert(0, str(__import__('pathlib').Path(__file__).resolve().parents[2] / 'tools' / 'regen-config'))

# Import the regen module's parsing functions
import importlib.util
spec = importlib.util.spec_from_file_location("regen", str(__import__('pathlib').Path(__file__).resolve().parents[2] / 'tools' / 'regen-config' / 'regen.py'))
regen = importlib.util.module_from_spec(spec)
spec.loader.exec_module(regen)

ROOT = regen.ROOT
CONFIG_PATH = regen.CONFIG_PATH

def main():
    # Read current config.json
    current = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    
    # Regenerate from playbook
    regen.main()
    
    # Read regenerated version
    regenerated = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    
    # Compare key sections
    drift = []
    
    # Compare domains
    for i, d in enumerate(current["domains"]):
        r = regenerated["domains"][i]
        if d["ous"] != r["ous"]:
            drift.append(f"{d['name']} OUs mismatch")
        if len(d["users"]) != len(r["users"]):
            drift.append(f"{d['name']} user count: {len(d['users'])} vs {len(r['users'])}")
        if len(d["groups"]) != len(r["groups"]):
            drift.append(f"{d['name']} group count: {len(d['groups'])} vs {len(r['groups'])}")
        # Compare user passwords
        for u in d["users"]:
            for ru in r["users"]:
                if u["name"] == ru["name"]:
                    if u["password"] != ru["password"]:
                        drift.append(f"{d['name']}: {u['name']} password mismatch")
                    if u["ou"] != ru["ou"]:
                        drift.append(f"{d['name']}: {u['name']} OU mismatch")
    
    # Compare hosts
    if len(current["hosts"]) != len(regenerated["hosts"]):
        drift.append(f"Host count: {len(current['hosts'])} vs {len(regenerated['hosts'])}")
    
    # Compare vulns
    for key in regenerated["vulns"]:
        if key not in current["vulns"]:
            drift.append(f"Vuln key missing: {key}")
    
    # Compare trusts
    if len(current["trusts"]) != len(regenerated["trusts"]):
        drift.append(f"Trust count mismatch")
    
    # Compare gMSA
    if current.get("gmsa", {}).get("principals") != regenerated.get("gmsa", {}).get("principals"):
        drift.append("gMSA principals mismatch")
    
    # Compare shares
    if len(current.get("shares", [])) != len(regenerated.get("shares", [])):
        drift.append("Shares count mismatch")
    
    if drift:
        print(f"DRIFT FOUND: {len(drift)} issue(s)")
        for d in drift:
            print(f"  - {d}")
        sys.exit(1)
    else:
        print("OK — config.json matches playbook (0 drift)")
        sys.exit(0)

if __name__ == "__main__":
    main()
