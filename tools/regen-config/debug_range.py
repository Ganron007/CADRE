import re
with open("C:/STUDY/Github/CADRE/ansible/roles/members/tasks/range.yml") as f:
    text = f.read()

user_sec = text.split("# --- Service accounts ---")[0]
pat = r'\{\s*username:\s*([^,]+),\s*password:\s*"([^"]+)",\s*ou:\s*(\w+)\s*\}'
user_matches = re.findall(pat, user_sec)
print(f"User section matches: {len(user_matches)}")

svc_sec = text.split("# --- Service accounts ---")[1].split("# --- Group membership ---")[0]
svc_matches = re.findall(pat, svc_sec)
print(f"Svc section matches: {len(svc_matches)}")
for m in svc_matches:
    print(f"  {m}")

after = text.split("# --- Group membership ---")[1]
after_matches = re.findall(pat, after)
print(f"After memership: {len(after_matches)}")
for m in after_matches:
    print(f"  {m}")
