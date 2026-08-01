# Get administrator SID from cadre.local via LDAPS
import ldap3

server = ldap3.Server("ldaps://dc01.cadre.local", get_info=ldap3.ALL)
conn = ldap3.Connection(
    server, user="cadre.local\\chief_command", password="C0mm@nd_Ch1ef!",
    authentication=ldap3.NTLM, auto_bind=True,
)
conn.search(
    "CN=Users,DC=cadre,DC=local",
    "(&(objectCategory=person)(sAMAccountName=administrator))",
    attributes=["objectSid", "sAMAccountName", "userPrincipalName"],
)
import struct

def decode_sid(raw):
    if isinstance(raw, str):
        raw = raw.encode("latin-1")
    rev = raw[0]
    subauth_count = raw[1]
    authority = int.from_bytes(raw[2:8], "big")
    subs = [struct.unpack("<I", raw[8 + 4 * i : 12 + 4 * i])[0] for i in range(subauth_count)]
    return f"S-{rev}-{authority}-" + "-".join(str(s) for s in subs)

for e in conn.entries:
    sid = decode_sid(e["objectSid"].value)
    print("ADMIN_SID", sid)
    print("ADMIN_UPN", e["userPrincipalName"].value if "userPrincipalName" in e else None)
conn.unbind()
