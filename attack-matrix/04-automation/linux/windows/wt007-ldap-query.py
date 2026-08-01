# Helper: query AD object attributes via LDAPS + NTLM (works on ws01)
import sys
import ldap3

server = ldap3.Server("ldaps://dc02.child.cadre.local", get_info=ldap3.ALL)
conn = ldap3.Connection(
    server,
    user="child.cadre.local\\analyst_t1",
    password="T13r_An@lyst!",
    authentication=ldap3.NTLM,
    auto_bind=True,
)
base = "DC=child,DC=cadre,DC=local"
filter_ = sys.argv[1]
attrs = sys.argv[2].split(",")
conn.search(base, filter_, attributes=attrs)
for e in conn.entries:
    print("DN", e.entry_dn)
    for a in attrs:
        v = getattr(e, a, None)
        if v is None:
            print(a, "<none>")
            continue
        if a == "objectSid":
            raw = e[a].value
            if isinstance(raw, (bytes, bytearray)):
                try:
                    from impacket.nt_errors import STATUS_SUCCESS  # noqa
                except ImportError:
                    pass
                # decode binary SID
                subauth_count = raw[1]
                # authority (6 bytes little endian, only last 4 used typically)
                ident_auth = int.from_bytes(raw[2:8], "big")
                subauths = [int.from_bytes(raw[8 + 4 * i : 12 + 4 * i], "little") for i in range(subauth_count)]
                sid = f"S-{raw[0]}-{ident_auth}-" + "-".join(str(x) for x in subauths)
                print(a, sid)
            else:
                print(a, raw)
        else:
            print(a, v)
conn.unbind()
