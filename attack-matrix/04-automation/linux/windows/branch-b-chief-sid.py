# Get chief_command SID from cadre.local via LDAPS
import struct
import ldap3

server = ldap3.Server("ldaps://dc01.cadre.local", get_info=ldap3.ALL)
conn = ldap3.Connection(
    server, user="cadre.local\\chief_command", password="C0mm@nd_Ch1ef!",
    authentication=ldap3.NTLM, auto_bind=True,
)
conn.search(
    "DC=cadre,DC=local",
    "(&(objectCategory=person)(sAMAccountName=chief_command))",
    attributes=["objectSid", "sAMAccountName", "distinguishedName"],
)
for e in conn.entries:
    raw = e["objectSid"].value
    if isinstance(raw, str):
        raw = raw.encode("latin-1")
    rev = raw[0]
    cnt = raw[1]
    auth = int.from_bytes(raw[2:8], "big")
    subs = [struct.unpack("<I", raw[8 + 4 * i : 12 + 4 * i])[0] for i in range(cnt)]
    sid = f"S-{rev}-{auth}-" + "-".join(str(s) for s in subs)
    print("CHIEF_SID", sid)
    print("CHIEF_DN", e["distinguishedName"].value)
conn.unbind()
