# Set mail attribute on all cadre.local users (ESC3 template requires email)
import ldap3

server = ldap3.Server("ldaps://dc01.cadre.local", get_info=ldap3.ALL)
conn = ldap3.Connection(
    server, user="cadre.local\\chief_command", password="C0mm@nd_Ch1ef!",
    authentication=ldap3.NTLM, auto_bind=True,
)
users = [
    "chief_command", "lead_engineering", "eng_agentic", "eng_cloud",
    "analyst_cloud", "hunter_dfir", "analyst_dfir", "ops_redcell",
    "lead_redcell", "analyst_purple", "svc_ldap", "mssql-linux01",
    "Administrator", "vagrant",
]
for u in users:
    conn.search(
        "DC=cadre,DC=local",
        f"(&(objectCategory=person)(sAMAccountName={u}))",
        attributes=["distinguishedName", "mail"],
    )
    if not conn.entries:
        print(f"SKIP {u}: not found")
        continue
    dn = conn.entries[0]["distinguishedName"].value
    mail = f"{u}@cadre.local"
    conn.modify(dn, {"mail": [(ldap3.MODIFY_REPLACE, [mail])]})
    ok = conn.result["result"] == 0
    print(f"{u}: mail={mail} mod_ok={ok} {conn.result.get('message','')}")
conn.unbind()
