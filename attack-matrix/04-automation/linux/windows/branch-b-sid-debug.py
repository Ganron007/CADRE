# Debug objectSid representation from ldap3
import ldap3

server = ldap3.Server("ldaps://dc01.cadre.local", get_info=ldap3.ALL)
conn = ldap3.Connection(
    server, user="cadre.local\\chief_command", password="C0mm@nd_Ch1ef!",
    authentication=ldap3.NTLM, auto_bind=True,
)
conn.search(
    "DC=cadre,DC=local",
    "(&(objectCategory=person)(sAMAccountName=chief_command))",
    attributes=["objectSid", "sAMAccountName"],
)
for e in conn.entries:
    v = e["objectSid"].value
    print("TYPE", type(v))
    print("VALUE", repr(v))
    print("LEN", len(v))
conn.unbind()
