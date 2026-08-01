import struct

# MSDS-MANAGEDPASSWORD_BLOB (MS-ADTS)
# Header:
#   Version (2) = 1
#   Reserved (2) = 0
#   Length (4) = total blob length
#   CurrentPasswordOffset (2)
#   PreviousPasswordOffset (2)
#   QueryPasswordIntervalOffset (2)
#   UnchangedPasswordIntervalOffset (2)
# Then variable fields:
#   CurrentPassword: null-terminated WCHAR
#   PreviousPassword: null-terminated WCHAR (may be absent/empty)
#   QueryPasswordInterval (8): 100ns units
#   UnchangedPasswordInterval (8): 100ns units

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

data = open('/tmp/gmsa-blob.bin', 'rb').read()
version, reserved, length = struct.unpack_from('<HHI', data, 0)
cur_off, prev_off, query_off, unchanged_off = struct.unpack_from('<HHHH', data, 8)
print('VERSION', version)
print('LENGTH', length, 'ACTUAL', len(data))
print('CUR_OFF', cur_off)
print('PREV_OFF', prev_off)
print('QUERY_OFF', query_off)
print('UNCHANGED_OFF', unchanged_off)

def read_wstr_raw(off):
    if off == 0:
        return None
    end = data.index(b'\x00\x00', off)
    return data[off:end]

cur_raw = read_wstr_raw(cur_off)
prev_raw = read_wstr_raw(prev_off)
print('CURRENT_PW_RAW_BYTES', len(cur_raw) if cur_raw else 0)
print('PREVIOUS_PW_RAW_BYTES', len(prev_raw) if prev_raw else 0)

# NT hash = MD4 of raw UTF-16LE bytes (NO decode/re-encode round trip)
if cur_raw:
    nt = md4(cur_raw).hex()
    open('/tmp/gmsa-nt.txt', 'w').write(nt)
    print('NTHASH', nt)
    open('/tmp/gmsa-rawpw.bin', 'wb').write(cur_raw)
if prev_raw:
    nt_prev = md4(prev_raw).hex()
    print('NTHASH_PREV', nt_prev)
    open('/tmp/gmsa-nt-prev.txt', 'w').write(nt_prev)

# Query interval (100ns units)
if query_off and query_off + 8 <= len(data):
    q = struct.unpack_from('<Q', data, query_off)[0]
    print('QUERY_INTERVAL_100NS', q, 'HOURS', round(q / 1e7 / 3600, 2))
if unchanged_off and unchanged_off + 8 <= len(data):
    u = struct.unpack_from('<Q', data, unchanged_off)[0]
    print('UNCHANGED_INTERVAL_100NS', u, 'HOURS', round(u / 1e7 / 3600, 2))
print('DECODE_DONE')
