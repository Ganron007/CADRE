import json
cfg = json.load(open("C:/STUDY/Github/CADRE/lab/data/config.json"))
for d in cfg["domains"]:
    if d["name"] == "range.local":
        for u in d["users"]:
            if u["name"] == "svc_naa":
                print(f"svc_naa groups: {u['groups']}")
print("---")
total_users = sum(len(d["users"]) for d in cfg["domains"])
total_groups = sum(len(d["groups"]) for d in cfg["domains"])
print(f"Total users: {total_users}, Total groups: {total_groups}")
print(f"Trusts: {len(cfg['trusts'])}")
print(f"Hosts: {len(cfg['hosts'])}")
print(f"Shares: {len(cfg['shares'])}")
print(f"Bait files: {len(cfg['bait_files'])}")
print(f"GPOs: {len(cfg['gpos'])}")
