# WT007 cleanup — remove RBCD attribute from mbr01$, delete FakePC$
import sys
import ldap3

DC = "dc02.child.cadre.local"
BASE = "DC=child,DC=cadre,DC=local"
USER = "child.cadre.local\\analyst_t1"
PASSWORD = "T13r_An@lyst!"
TARGET_DN = "CN=MBR01,CN=Computers,DC=child,DC=cadre,DC=local"

server = ldap3.Server("ldaps://" + DC, get_info=ldap3.ALL)
conn = ldap3.Connection(
    server,
    user=USER,
    password=PASSWORD,
    authentication=ldap3.NTLM,
    auto_bind=True,
)
# remove RBCD value
conn.modify(TARGET_DN, {"msDS-AllowedToActOnBehalfOfOtherIdentity": [(ldap3.MODIFY_REPLACE, [])]})
print("RBCD_CLEAR", conn.result["result"] == 0, conn.result.get("message", ""))
# delete fake PC
conn.delete("CN=FakePC,CN=Computers,DC=child,DC=cadre,DC=local")
print("FAKEPC_DELETE", conn.result["result"] == 0, conn.result.get("message", ""))
conn.unbind()
