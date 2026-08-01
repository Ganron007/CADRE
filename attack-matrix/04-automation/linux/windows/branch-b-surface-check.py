# Branch B surface check — enumerate ADCS templates + CA from ws01 as chief_command
# Verifies: CADRE-ESC1/2/3-Agent/3-Target/4/9/13/14 exist, are published, key flags set
import sys
import ldap3

DC = "dc01.cadre.local"
CONFIG = "CN=Configuration,DC=cadre,DC=local"
USER = "cadre.local\\chief_command"
PASSWORD = "C0mm@nd_Ch1ef!"

server = ldap3.Server("ldaps://" + DC, get_info=ldap3.ALL)
conn = ldap3.Connection(
    server, user=USER, password=PASSWORD, authentication=ldap3.NTLM, auto_bind=True
)
tpl_base = f"CN=Certificate Templates,CN=Public Key Services,CN=Services,{CONFIG}"
conn.search(
    tpl_base,
    "(|(cn=CADRE-ESC1)(cn=CADRE-ESC2)(cn=CADRE-ESC3-Agent)(cn=CADRE-ESC3-Target)(cn=CADRE-ESC4)(cn=CADRE-ESC9)(cn=CADRE-ESC13)(cn=CADRE-ESC14))",
    attributes=["cn", "msPKI-Certificate-Name-Flag", "msPKI-Certificate-Application-Policy", "msPKI-RA-Signature", "msPKI-Enrollment-Flag", "msPKI-Cert-Template-OID", "ntSecurityDescriptor"],
    search_scope=ldap3.SUBTREE,
)
found = {}
for e in conn.entries:
    name = e.cn.value
    found[name] = {
        "nameflag": int(e["msPKI-Certificate-Name-Flag"].value) if "msPKI-Certificate-Name-Flag" in e and e["msPKI-Certificate-Name-Flag"].value is not None else None,
        "app_policy": e["msPKI-Certificate-Application-Policy"].value if "msPKI-Certificate-Application-Policy" in e and e["msPKI-Certificate-Application-Policy"].value else [],
        "ra_sig": int(e["msPKI-RA-Signature"].value) if "msPKI-RA-Signature" in e and e["msPKI-RA-Signature"].value is not None else None,
        "enrollflag": int(e["msPKI-Enrollment-Flag"].value) if "msPKI-Enrollment-Flag" in e and e["msPKI-Enrollment-Flag"].value is not None else None,
    }

for name in ["CADRE-ESC1", "CADRE-ESC2", "CADRE-ESC3-Agent", "CADRE-ESC3-Target", "CADRE-ESC4", "CADRE-ESC9", "CADRE-ESC13", "CADRE-ESC14"]:
    if name in found:
        f = found[name]
        flags = f["nameflag"]
        esc1_ok = flags is not None and (flags & 1) == 1
        esc9_ok = f["enrollflag"] is not None and (f["enrollflag"] & 0x80000) != 0
        print(f"TEMPLATE {name}: PRESENT nameflag={flags} esc1_supplies_subject={esc1_ok} enrollflag={f['enrollflag']} esc9_nosec={esc9_ok} ra_sig={f['ra_sig']} eku={','.join(str(x) for x in f['app_policy'])}")
    else:
        print(f"TEMPLATE {name}: MISSING")

# CA object
conn.search(
    f"CN=Enrollment Services,CN=Public Key Services,CN=Services,{CONFIG}",
    "(cn=cadre-CA)",
    attributes=["cn", "cACertificate", "dnsHostName", "certificateTemplates"],
    search_scope=ldap3.SUBTREE,
)
if conn.entries:
    e = conn.entries[0]
    tpls = e["certificateTemplates"].value if "certificateTemplates" in e else []
    print(f"CA cadre-CA: PRESENT host={e['dnsHostName'].value if 'dnsHostName' in e else '?'} published_templates={tpls}")
else:
    print("CA cadre-CA: MISSING")

conn.unbind()
