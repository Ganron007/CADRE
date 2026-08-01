# Parse certipy find JSON to list templates + EKUs + enroll rights
import json

with open(r"C:\STUDY\Github\CADRE-Platform\CADRE\attack-matrix\04-automation\linux\windows\certipy-find-20260731.json", encoding="utf-8") as f:
    d = json.load(f)

print("=== CA ===")
for k, ca in (d.get("Certificate Authorities", {}) or {}).items():
    print(f"CA {ca.get('CA Name')} host={ca.get('DNS Name')} web_http={ca.get('Web Enrollment',{}).get('http',{}).get('enabled')}")

print("\n=== Templates (name | EKU | enrollees | flags) ===")
for k, t in (d.get("Certificate Templates", {}) or {}).items():
    name = t.get("Template Name")
    eku = ",".join(t.get("Extended Key Usage", []) or ["(none)"])
    enrollees = ",".join([p.get("Name", "?") for p in t.get("Enroll Principals", [])])
    flags = [a for a in ["Enrollee Supplies Subject", "Requires Manager Approval", "No Security Extension", "Smart Card Required", "Requires Any EKU", "Requires a Signature", "Authorized Signatures Required"] if t.get(a)]
    print(f"{name} | EKU={eku} | enrollees={enrollees} | flags={','.join(flags)}")
