# WT007 cleanup as chief_command (DA) — delete FakePC$
import ldap3

server = ldap3.Server("ldaps://dc02.child.cadre.local", get_info=ldap3.ALL)
conn = ldap3.Connection(
    server,
    user="cadre.local\\chief_command",
    password="C0mm@nd_Ch1ef!",
    authentication=ldap3.NTLM,
    auto_bind=True,
)
conn.delete("CN=FakePC,CN=Computers,DC=child,DC=cadre,DC=local")
print("FAKEPC_DELETE", conn.result["result"] == 0, conn.result.get("message", ""))
conn.unbind()
