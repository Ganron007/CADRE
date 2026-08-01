# Check mail attributes for cadre.local users
import ldap3

server = ldap3.Server("ldaps://dc01.cadre.local", get_info=ldap3.ALL)
conn = ldap3.Connection(
    server, user="cadre.local\\chief_command", password="C0mm@nd_Ch1ef!",
    authentication=ldap3.NTLM, auto_bind=True,
)
conn.search(
    "DC=cadre,DC=local",
    "(&(objectCategory=person)(objectClass=user))",
    attributes=["sAMAccountName", "mail", "userPrincipalName"],
)
for e in conn.entries:
    sam = e["sAMAccountName"].value
    mail = e["mail"].value if "mail" in e and e["mail"].value else "-"
    print(f"{sam:20s} mail={mail}")
conn.unbind()
