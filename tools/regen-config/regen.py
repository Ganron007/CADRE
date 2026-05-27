#!/usr/bin/env python3
"""
config.json Regenerator — source of truth is the Ansible playbook roles.
Reads the deployed role files (cadre.yml, child.yml, range.yml, shares.yml)
and translates their loop items into config.json structure.
"""
import json, re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONFIG_PATH = ROOT / "lab" / "data" / "config.json"
ROLES_DIR = ROOT / "ansible" / "roles" / "members" / "tasks"

def parse_ou(yml_path, domain_dn):
    text = yml_path.read_text(encoding="utf-8")
    ou_section = text.split("# --- Groups ---")[0]
    pattern = r'-\s*\{\s*name:\s*(\w+),\s*description:\s*([^}]+)\s*\}'
    names = [m[0] for m in re.findall(pattern, ou_section)]
    return sorted([f"OU={n},{domain_dn}" for n in names])

def parse_groups(yml_path, domain_dn):
    text = yml_path.read_text(encoding="utf-8")
    groups_section = text.split("# --- Groups ---")[1].split("# --- Users ---")[0]
    pattern = r'\{\s*name:\s*([^,]+),\s*ou:\s*(\w+),\s*scope:\s*(\w+)\s*\}'
    matches = re.findall(pattern, groups_section)
    groups = []
    for name, ou, _ in matches:
        groups.append({"name": name, "ou": f"OU={ou},{domain_dn}"})
    
    mem_section = text.split("# --- Group membership ---")[1] if "# --- Group membership ---" in text else ""
    mem_pat = r'\{\s*group:\s*"([^"]+)",\s*users:\s*\[([^\]]+)\]\s*\}'
    mem = re.findall(mem_pat, mem_section)
    for group, users_str in mem:
        users = [u.strip().strip('"') for u in users_str.split(',')]
        for g in groups:
            if g["name"] == group:
                g["members"] = users
    return groups

def parse_users(yml_path, domain_dn):
    text = yml_path.read_text(encoding="utf-8")
    # Regular users section
    user_section = text.split("# --- Service accounts ---")[0] if "# --- Service accounts ---" in text else text.split("# --- Group membership ---")[0]
    pattern = r'\{\s*username:\s*([^,]+),\s*password:\s*"([^"]+)",\s*ou:\s*(\w+)\s*\}'
    users = []
    seen = set()
    for username, password, ou in re.findall(pattern, user_section):
        name = username.replace('.', '_')
        if name not in seen:
            users.append({"name": name, "password": password, "ou": f"OU={ou},{domain_dn}", "groups": ["Domain Users"]})
            seen.add(name)
    # Service accounts section
    if "# --- Service accounts ---" in text:
        svc_section = text.split("# --- Service accounts ---")[1]
        svc_section = svc_section.split("# --- Group membership ---")[0] if "# --- Group membership ---" in text else svc_section.split("# --- gMSA")[0]
        for username, password, ou in re.findall(pattern, svc_section):
            name = username.replace('.', '_')
            if name not in seen:
                users.append({"name": name, "password": password, "ou": f"OU={ou},{domain_dn}", "groups": ["Domain Users"]})
                seen.add(name)
    return users

FILES = [
    ("cadre.local", "cadre.yml", "DC=cadre,DC=local"),
    ("child.cadre.local", "child.yml", "DC=child,DC=cadre,DC=local"),
    ("range.local", "range.yml", "DC=range,DC=local"),
]

DOMAINS_META = {
    "cadre.local": {
        "netbios": "CADRE", "dc": "dc01", "ip": "192.168.77.10",
        "admin": "D0m@1n_Adm1n!", "dsrm": "DSRM_C@dre!",
        "type": "forest_root"
    },
    "child.cadre.local": {
        "netbios": "CHILD", "dc": "dc02", "ip": "192.168.77.11",
        "admin": "Ch1ld_D0m@1n!", "dsrm": "DSRM_Ch1ld!",
        "type": "child", "parent": "cadre.local"
    },
    "range.local": {
        "netbios": "RANGE", "dc": "dc03", "ip": "192.168.77.12",
        "admin": "R@ng3_F0r3st!", "dsrm": "DSRM_R@ng3!",
        "type": "external_forest"
    },
}

def main():
    domains = []
    for name, yml, dn in FILES:
        fp = ROLES_DIR / yml
        meta = DOMAINS_META[name]
        d = {
            "name": name,
            "type": meta["type"],
            "netbios": meta["netbios"],
            "functional_level": "WinThreshold",
            "dc": meta["dc"],
            "ip": meta["ip"],
            "admin_password": meta["admin"],
            "dsrm_password": meta["dsrm"],
            "ous": parse_ou(fp, dn),
            "users": parse_users(fp, dn),
            "groups": parse_groups(fp, dn),
        }
        if "parent" in meta:
            d["parent_domain"] = meta["parent"]
        if name == "cadre.local":
            for u in d["users"]:
                if u["name"] == "chief_command":
                    u["groups"] = ["Domain Admins", "Enterprise Admins"]
        if name == "range.local":
            d["dmsa"] = {"name": "dmsaPrivService", "description": "dMSA for BadSuccessor target"}
            for u in d["users"]:
                if u["name"] == "svc_naa":
                    u["groups"] = ["Domain Admins"]
        domains.append(d)
    
    config = {
        "domains": domains,
        "hosts": [
            {"hostname": "dc01", "ip": "192.168.77.10", "os": "windows", "role": "dc"},
            {"hostname": "dc02", "ip": "192.168.77.11", "os": "windows", "role": "dc"},
            {"hostname": "dc03", "ip": "192.168.77.12", "os": "windows", "role": "dc"},
            {"hostname": "mbr01", "ip": "192.168.77.22", "os": "windows", "role": "member"},
            {"hostname": "mbr02", "ip": "192.168.77.23", "os": "windows", "role": "member"},
            {"hostname": "linux01", "ip": "192.168.77.40", "os": "linux", "role": "member"},
            {"hostname": "elk", "ip": "192.168.77.50", "os": "linux", "role": "telemetry"},
            {"hostname": "vr", "ip": "192.168.77.51", "os": "linux", "role": "telemetry"},
            {"hostname": "monitor", "ip": "192.168.77.55", "os": "linux", "role": "telemetry"},
            {"hostname": "provisioning", "ip": "192.168.77.60", "os": "linux", "role": "provisioner"},
        ],
        "network": {"subnet": "192.168.77.0/24", "vmnet": "vmnet2", "gateway": "192.168.77.1"},
        "vulns": {
            "dc01": {"adcs_ca": True, "esc_templates": ["ESC1","ESC2","ESC3-Agent","ESC3-Target","ESC4","ESC7","ESC9","ESC13","ESC14","ESC15"], "rc4_enabled": True, "cloud_sync_agent": True},
            "dc02": {"child_domain": True},
            "dc03": {"aes_only": True, "dmsa_enabled": True, "external_forest": True},
            "mbr01": {"mssql": True, "mssql_instance": "SQLEXPRESS", "iis": True, "unconstrained_delegation": True, "shares": ["public", "restricted"]},
            "mbr02": {"sccm": False, "wsus": True, "virtual_smart_card_ca": True},
            "linux01": {"sssd": True, "mssql_linux": True, "nfs_krb5": True, "podman_privileged": True},
        },
        "adcs": {
            "ca_hostname": "dc01", "ca_name": "CADRE-CA", "ca_common_name": "CADRE Certification Authority",
            "templates": {
                "ESC1": {"name": "ESC1-WebServer", "enrollee_supplies_subject": True, "client_auth": True},
                "ESC2": {"name": "ESC2-SubCA", "enrollee_supplies_subject": True, "subca": True},
                "ESC3-Agent": {"name": "ESC3-Agent", "agent": True},
                "ESC3-Target": {"name": "ESC3-Target", "target": True},
                "ESC4": {"name": "ESC4-Modified", "modified": True},
                "ESC7": {"name": "ESC7-CA-Manager", "ca_manager": True},
                "ESC9": {"name": "ESC9-NoSecurityExt", "no_security_ext": True},
                "ESC13": {"name": "ESC13-OldCert", "old_cert": True},
                "ESC14": {"name": "ESC14-EnrolleeSuppliesSubject", "enrollee_supplies_subject": True},
                "ESC15": {"name": "ESC15-NoEKU", "no_eku": True},
            }
        },
        "trusts": [
            {"source": "cadre.local", "target": "child.cadre.local", "type": "parent-child", "direction": "ParentChild", "sid_filtering": False},
            {"source": "cadre.local", "target": "range.local", "type": "forest", "direction": "Bidirectional", "sid_filtering": True},
        ],
        "dns_forwarders": [
            {"dc": "dc01", "domain": "range.local", "forward_to": "192.168.77.12"},
            {"dc": "dc01", "domain": "child.cadre.local", "forward_to": "192.168.77.11"},
            {"dc": "dc03", "domain": "cadre.local", "forward_to": "192.168.77.10"},
        ],
        "gmsa": {"name": "gmsaTools", "description": "gMSA for tooling services", "principals": ["CADRE\\eng_cloud"]},
        "shares": [
            {"server": "mbr01", "name": "public", "path": "C:\\Shares\\Public", "description": "Public share for all users"},
            {"server": "mbr01", "name": "restricted", "path": "C:\\Shares\\Restricted", "description": "Restricted share for analysts"},
            {"server": "mbr02", "name": "vault", "path": "C:\\Shares\\Vault", "description": "Vault share for command staff"},
        ],
        "bait_files": [
            {"share": "public", "name": "cadre-handbook.txt", "content": "Recon intel - fake operations manual"},
            {"share": "public", "name": "incident-log.txt", "content": "Recon intel - fake incident log"},
            {"share": "vault", "name": "naa-rotation-notice.txt", "content": "Recon intel - fake NAA password rotation notice"},
            {"share": "vault", "name": "sccm-recovery-key.txt", "content": "Recon intel - fake SCCM recovery key"},
        ],
        "gpos": [
            {"name": "Vulnerable-GPO", "target": "OU=DFIR,DC=cadre,DC=local", "settings": {"WDigest": True, "LmCompatibilityLevel": 1}},
            {"name": "SCCM-Client-Push", "target": "dc=range,dc=local", "settings": {"AutoClientPush": True}},
        ],
    }
    
    CONFIG_PATH.write_text(json.dumps(config, indent=2), encoding="utf-8")
    print(f"Regenerated: {CONFIG_PATH}")
    for d in domains:
        print(f"  {d['name']}: {len(d['ous'])} OUs, {len(d['users'])} users, {len(d['groups'])} groups")

if __name__ == "__main__":
    main()
