# WT002 ACE#18 surface check — intern_blue ForceChangePassword on analyst_t2 (child.cadre.local)
import ldap3

server = ldap3.Server("ldaps://dc02.child.cadre.local", get_info=ldap3.ALL)
conn = ldap3.Connection(
    server,
    user="child.cadre.local\\intern_blue",
    password="1nt3rn_Blu3!",
    authentication=ldap3.NTLM,
    auto_bind=True,
)
# get intern_blue SID
conn.search("DC=child,DC=cadre,DC=local", "(sAMAccountName=intern_blue)", attributes=["objectSid"])
ib_sid = conn.entries[0].objectSid.value
sub_count = ib_sid[1]
auth = int.from_bytes(ib_sid[2:8], "big")
subs = [int.from_bytes(ib_sid[8+4*i:12+4*i], "little") for i in range(sub_count)]
ib_sid_str = f"S-{ib_sid[0]}-{auth}-" + "-".join(str(x) for x in subs)
print("INTERN_BLUE_SID", ib_sid_str)

conn.search("CN=analyst_t2,OU=Detection,DC=child,DC=cadre,DC=local", "(objectClass=*)",
            attributes=["objectSid"], search_scope=ldap3.BASE)
# Use raw ntSecurityDescriptor via read with control — ldap3 needs special handling.
# Simpler: use the DirectoryServices path from PowerShell instead.
print("OK surface check started")
conn.unbind()
